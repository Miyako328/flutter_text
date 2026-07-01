import Cocoa
import FlutterMacOS
import ImageIO
import NetFS
import Vision

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)

    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    setupSmbMountChannel(flutterViewController: flutterViewController)
    setupSubjectDetectionChannel(flutterViewController: flutterViewController)

    super.awakeFromNib()
  }

  private func setupSubjectDetectionChannel(flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "flutter_text/subject_detector",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    let detector = SubjectDetectionPlugin()
    channel.setMethodCallHandler { call, result in
      guard call.method == "detectSubject" else {
        result(FlutterMethodNotImplemented)
        return
      }
      detector.detectSubject(call: call, result: result)
    }
  }

  private func setupSmbMountChannel(flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "flutter_text/smb_mount",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "mountSmb" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let arguments = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing SMB mount arguments", details: nil))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        self.mountSmb(arguments: arguments, result: result)
      }
    }
  }

  private func mountSmb(arguments: [String: Any], result: @escaping FlutterResult) {
    let host = (arguments["host"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let shareName = (arguments["shareName"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let port = arguments["port"] as? Int ?? 445
    let username = (arguments["username"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    let password = arguments["password"] as? String ?? ""

    guard !host.isEmpty else {
      DispatchQueue.main.async {
        result(FlutterError(code: "HOST_REQUIRED", message: "SMB host is required", details: nil))
      }
      return
    }

    guard !shareName.isEmpty else {
      DispatchQueue.main.async {
        result(FlutterError(code: "SHARE_REQUIRED", message: "SMB share name is required for app initiated mounting", details: nil))
      }
      return
    }

    var components = URLComponents()
    components.scheme = "smb"
    components.host = host
    if port != 445 {
      components.port = port
    }
    components.path = "/" + shareName

    guard let url = components.url else {
      DispatchQueue.main.async {
        result(FlutterError(code: "INVALID_URL", message: "Unable to build SMB URL", details: nil))
      }
      return
    }

    NSLog("[SmbMount] mounting \(url.absoluteString), user=\(username.isEmpty ? "<guest>" : username)")
    let openOptions = NSMutableDictionary()
    openOptions[kNAUIOptionKey] = kNAUIOptionAllowUI
    if username.isEmpty && password.isEmpty {
      openOptions[kNetFSUseGuestKey] = true
    }
    let mountOptions = NSMutableDictionary()
    mountOptions[kNetFSSoftMountKey] = true
    mountOptions[kNetFSOpenURLMountKey] = true

    var mountPoints: Unmanaged<CFArray>?
    let status = NetFSMountURLSync(
      url as CFURL,
      nil,
      username.isEmpty ? nil : username as CFString,
      password.isEmpty ? nil : password as CFString,
      openOptions,
      mountOptions,
      &mountPoints
    )
    NSLog("[SmbMount] mount completed status=\(status)")

    if status == 0 || status == EEXIST {
      var points = mountPoints?.takeRetainedValue() as? [String] ?? []
      if points.isEmpty, let existingPoint = findExistingMountPoint(shareName: shareName) {
        points = [existingPoint]
      }
      DispatchQueue.main.async {
        result([
          "mountPoints": points,
          "smbUrl": url.absoluteString,
          "alreadyMounted": status == EEXIST
        ])
      }
    } else {
      DispatchQueue.main.async {
        result(FlutterError(
          code: "MOUNT_FAILED",
          message: "SMB mount failed with status \(status)",
          details: ["status": status, "smbUrl": url.absoluteString]
        ))
      }
    }
  }

  private func findExistingMountPoint(shareName: String) -> String? {
    let volumesURL = URL(fileURLWithPath: "/Volumes", isDirectory: true)
    let fileManager = FileManager.default
    guard let volumeURLs = try? fileManager.contentsOfDirectory(
      at: volumesURL,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ) else {
      return nil
    }

    let expectedNames = [
      shareName,
      shareName.removingPercentEncoding ?? shareName
    ]

    for expectedName in expectedNames {
      if let exact = volumeURLs.first(where: { $0.lastPathComponent == expectedName }) {
        return exact.path
      }
      if let numbered = volumeURLs.first(where: { $0.lastPathComponent.hasPrefix(expectedName + "-") }) {
        return numbered.path
      }
    }
    return nil
  }
}

private final class SubjectDetectionPlugin {
  func detectSubject(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let path = arguments["path"] as? String,
          !path.isEmpty else {
      result(FlutterError(code: "BAD_ARGUMENTS", message: "Missing image path", details: nil))
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let detection = try self.detectSubject(path: path)
        DispatchQueue.main.async {
          result(detection.toFlutterMap())
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "DETECT_FAILED", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private func detectSubject(path: String) throws -> SubjectDetection {
    let imageURL = URL(fileURLWithPath: path)
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
      throw SubjectDetectionError.unreadableImage
    }

    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

    if #available(macOS 10.15, *) {
      if let saliencyRect = try detectSaliencyRect(handler: handler, imageSize: imageSize) {
        return SubjectDetection(
          rect: padded(saliencyRect, in: imageSize, ratio: 0.08),
          imageSize: imageSize,
          source: "vision-saliency"
        )
      }
    }

    if let faceRect = try detectFaceRect(handler: handler, imageSize: imageSize) {
      return SubjectDetection(
        rect: padded(faceRect, in: imageSize, ratio: 0.65),
        imageSize: imageSize,
        source: "vision-face"
      )
    }

    return SubjectDetection(
      rect: defaultRect(in: imageSize),
      imageSize: imageSize,
      source: "center-fallback"
    )
  }

  @available(macOS 10.15, *)
  private func detectSaliencyRect(
    handler: VNImageRequestHandler,
    imageSize: CGSize
  ) throws -> CGRect? {
    let objectnessRequest = VNGenerateObjectnessBasedSaliencyImageRequest()
    try handler.perform([objectnessRequest])
    if let rect = bestSaliencyRect(from: objectnessRequest.results, imageSize: imageSize) {
      return rect
    }

    let attentionRequest = VNGenerateAttentionBasedSaliencyImageRequest()
    try handler.perform([attentionRequest])
    return bestSaliencyRect(from: attentionRequest.results, imageSize: imageSize)
  }

  @available(macOS 10.15, *)
  private func bestSaliencyRect(
    from observations: [VNSaliencyImageObservation]?,
    imageSize: CGSize
  ) -> CGRect? {
    let objects = observations?.flatMap { $0.salientObjects ?? [] } ?? []
    let best = objects.max { lhs, rhs in
      lhs.boundingBox.width * lhs.boundingBox.height < rhs.boundingBox.width * rhs.boundingBox.height
    }
    return best.map { convertNormalizedRect($0.boundingBox, imageSize: imageSize) }
  }

  private func detectFaceRect(
    handler: VNImageRequestHandler,
    imageSize: CGSize
  ) throws -> CGRect? {
    let request = VNDetectFaceRectanglesRequest()
    try handler.perform([request])
    let best = request.results?.max { lhs, rhs in
      lhs.boundingBox.width * lhs.boundingBox.height < rhs.boundingBox.width * rhs.boundingBox.height
    }
    return best.map { convertNormalizedRect($0.boundingBox, imageSize: imageSize) }
  }

  private func convertNormalizedRect(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect {
    let width = normalizedRect.width * imageSize.width
    let height = normalizedRect.height * imageSize.height
    let x = normalizedRect.minX * imageSize.width
    let y = (1 - normalizedRect.maxY) * imageSize.height
    return CGRect(x: x, y: y, width: width, height: height).standardized
  }

  private func padded(_ rect: CGRect, in imageSize: CGSize, ratio: CGFloat) -> CGRect {
    let dx = rect.width * ratio
    let dy = rect.height * ratio
    return clamp(rect.insetBy(dx: -dx, dy: -dy), in: imageSize)
  }

  private func clamp(_ rect: CGRect, in imageSize: CGSize) -> CGRect {
    let left = max(0, rect.minX)
    let top = max(0, rect.minY)
    let right = min(imageSize.width, rect.maxX)
    let bottom = min(imageSize.height, rect.maxY)
    if right <= left || bottom <= top {
      return defaultRect(in: imageSize)
    }
    return CGRect(x: left, y: top, width: right - left, height: bottom - top)
  }

  private func defaultRect(in imageSize: CGSize) -> CGRect {
    let side = min(imageSize.width, imageSize.height) * 0.55
    let width = imageSize.width >= imageSize.height
      ? side
      : side * imageSize.width / imageSize.height
    let height = imageSize.height > imageSize.width
      ? side
      : side * imageSize.height / imageSize.width
    return CGRect(
      x: (imageSize.width - width) / 2,
      y: (imageSize.height - height) / 2,
      width: width,
      height: height
    )
  }
}

private struct SubjectDetection {
  let rect: CGRect
  let imageSize: CGSize
  let source: String

  func toFlutterMap() -> [String: Any] {
    [
      "rect": [
        "left": rect.minX,
        "top": rect.minY,
        "right": rect.maxX,
        "bottom": rect.maxY,
      ],
      "imageSize": [
        "width": imageSize.width,
        "height": imageSize.height,
      ],
      "source": source,
    ]
  }
}

private enum SubjectDetectionError: LocalizedError {
  case unreadableImage

  var errorDescription: String? {
    switch self {
    case .unreadableImage:
      return "Unable to read image file."
    }
  }
}

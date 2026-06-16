import Cocoa
import FlutterMacOS
import NetFS

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

    super.awakeFromNib()
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

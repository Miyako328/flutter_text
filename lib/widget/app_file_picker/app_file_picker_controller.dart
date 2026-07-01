import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart'
    as wechat_camera;

import 'app_file_picker_models.dart';

class AppFilePickerController extends GetxController {
  final bool isMulti;
  final int? maxLimit;
  final AppPickerMimeType mimeType;
  final List<String>? allowedExtensions;

  AppFilePickerController({
    required this.isMulti,
    required this.maxLimit,
    required this.mimeType,
    required this.allowedExtensions,
  });

  final List<AppPickedFile> pickedFiles = <AppPickedFile>[];
  final Set<String> selectedPaths = <String>{};
  final List<AppPickerPath> paths = <AppPickerPath>[
    const AppPickerPath(
      id: 'all',
      name: '全部文件',
      fallbackIcon: Icons.photo_library_outlined,
    ),
    const AppPickerPath(
      id: 'gallery',
      name: '相册',
      fallbackIcon: Icons.photo_outlined,
    ),
    const AppPickerPath(
      id: 'file_system',
      name: '文件',
      fallbackIcon: Icons.folder_open_rounded,
    ),
  ];
  final ImagePicker _imagePicker = ImagePicker();
  AppPickerPath? currentPath;
  bool isPicking = false;
  bool isPathSelectorExpanded = false;

  @override
  void onInit() {
    super.onInit();
    currentPath = paths.first;
  }

  bool get hasFiles => pickedFiles.isNotEmpty;

  bool get hasSelection => selectedPaths.isNotEmpty;

  bool get isMobileDevice => Platform.isAndroid || Platform.isIOS;

  bool get canUseWechatMediaPicker =>
      isMobileDevice && mimeType != AppPickerMimeType.custom;

  bool get canShowCameraEntry =>
      canUseWechatMediaPicker && mimeType != AppPickerMimeType.video;

  List<AppPickedFile> get selectedFiles => pickedFiles
      .where((AppPickedFile file) => selectedPaths.contains(file.path))
      .toList(growable: false);

  List<AppPickedFile> get visibleFiles {
    switch (currentPath?.id) {
      case 'gallery':
        return pickedFiles
            .where(
              (AppPickedFile file) =>
                  file.source == AppPickerSource.gallery ||
                  file.source == AppPickerSource.camera,
            )
            .toList(growable: false);
      case 'file_system':
        return pickedFiles
            .where(
              (AppPickedFile file) => file.source == AppPickerSource.fileSystem,
            )
            .toList(growable: false);
      case 'all':
      default:
        return pickedFiles;
    }
  }

  List<AppPickerPath> get displayPaths {
    return paths
        .map(
          (AppPickerPath path) => path.copyWith(
            count: _countForPath(path.id),
          ),
        )
        .toList(growable: false);
  }

  int get remainingCount {
    if (!isMulti) {
      return selectedPaths.isEmpty ? 1 : 0;
    }
    if (maxLimit == null) {
      return 999999;
    }
    return (maxLimit! - selectedPaths.length).clamp(0, maxLimit!);
  }

  Future<void> pickFromFileSystem() async {
    if (remainingCount <= 0) {
      return;
    }
    await _guardPick(() async {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: isMulti,
        type: _fileType,
        allowedExtensions:
            mimeType == AppPickerMimeType.custom ? allowedExtensions : null,
      );
      if (result == null) {
        return;
      }
      await _addFiles(
        result.files
            .where((PlatformFile file) => file.path?.isNotEmpty == true)
            .map(
              (PlatformFile file) => AppPickedFile(
                path: file.path!,
                name: file.name,
                source: AppPickerSource.fileSystem,
                size: file.size,
                extension: file.extension,
              ),
            )
            .toList(),
      );
    });
  }

  Future<void> pickFromGallery(
    BuildContext context, {
    bool allowCameraEntry = true,
  }) async {
    if (remainingCount <= 0) {
      return;
    }
    await _guardPick(() async {
      if (canUseWechatMediaPicker) {
        await _pickFromWechatAssets(
          context,
          allowCameraEntry: allowCameraEntry && canShowCameraEntry,
        );
        return;
      }

      if (mimeType == AppPickerMimeType.video) {
        final XFile? video = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
        );
        if (video != null) {
          await _addFiles(
            <AppPickedFile>[
              await _fromXFile(video, source: AppPickerSource.gallery),
            ],
          );
        }
        return;
      }

      if (isMulti) {
        final List<XFile> images = await _imagePicker.pickMultiImage();
        await _addFiles(
          await Future.wait(
            images.map(
              (XFile file) => _fromXFile(
                file,
                source: AppPickerSource.gallery,
              ),
            ),
          ),
        );
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          await _addFiles(
            <AppPickedFile>[
              await _fromXFile(image, source: AppPickerSource.gallery),
            ],
          );
        }
      }
    });
  }

  Future<void> pickFromCamera(BuildContext context) async {
    if (remainingCount <= 0) {
      return;
    }
    await _guardPick(() async {
      if (canShowCameraEntry) {
        await _pickFromWechatCamera(context);
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        await _addFiles(
          <AppPickedFile>[
            await _fromXFile(image, source: AppPickerSource.camera),
          ],
        );
      }
    });
  }

  void removeAt(int index) {
    if (index < 0 || index >= pickedFiles.length) {
      return;
    }
    final AppPickedFile file = pickedFiles.removeAt(index);
    selectedPaths.remove(file.path);
    update();
  }

  void removeFile(AppPickedFile file) {
    pickedFiles.removeWhere((AppPickedFile item) => item.path == file.path);
    selectedPaths.remove(file.path);
    update();
  }

  void clear() {
    pickedFiles.clear();
    selectedPaths.clear();
    update();
  }

  bool isSelected(AppPickedFile file) {
    return selectedPaths.contains(file.path);
  }

  void toggleSelection(AppPickedFile file, {bool? selected}) {
    final bool shouldSelect = selected ?? !selectedPaths.contains(file.path);
    if (shouldSelect) {
      if (!isMulti) {
        selectedPaths
          ..clear()
          ..add(file.path);
      } else if (selectedPaths.contains(file.path)) {
        return;
      } else if (remainingCount > 0) {
        selectedPaths.add(file.path);
      }
    } else {
      selectedPaths.remove(file.path);
    }
    update();
  }

  void selectRange(int from, int to, {required bool selected}) {
    if (pickedFiles.isEmpty) {
      return;
    }
    final int start = from < to ? from : to;
    final int end = from < to ? to : from;
    bool changed = false;
    for (int i = start; i <= end && i < pickedFiles.length; i++) {
      final AppPickedFile file = pickedFiles[i];
      if (selected) {
        if (!selectedPaths.contains(file.path) && remainingCount > 0) {
          selectedPaths.add(file.path);
          changed = true;
        }
      } else if (selectedPaths.remove(file.path)) {
        changed = true;
      }
      if (!isMulti && selectedPaths.isNotEmpty) {
        break;
      }
    }
    if (changed) {
      update();
    }
  }

  void selectVisibleRange(int from, int to, {required bool selected}) {
    final List<AppPickedFile> files = visibleFiles;
    if (files.isEmpty) {
      return;
    }
    final int start = from < to ? from : to;
    final int end = from < to ? to : from;
    bool changed = false;
    for (int i = start; i <= end && i < files.length; i++) {
      final AppPickedFile file = files[i];
      if (selected) {
        if (!selectedPaths.contains(file.path) && remainingCount > 0) {
          selectedPaths.add(file.path);
          changed = true;
        }
      } else if (selectedPaths.remove(file.path)) {
        changed = true;
      }
      if (!isMulti && selectedPaths.isNotEmpty) {
        break;
      }
    }
    if (changed) {
      update();
    }
  }

  void clearSelection() {
    selectedPaths.clear();
    update();
  }

  void togglePathSelector() {
    isPathSelectorExpanded = !isPathSelectorExpanded;
    update();
  }

  void switchPath(AppPickerPath path) {
    currentPath = path;
    isPathSelectorExpanded = false;
    update();
  }

  Future<void> _guardPick(Future<void> Function() action) async {
    if (isPicking) {
      return;
    }
    isPicking = true;
    update();
    try {
      await action();
    } catch (error) {
      debugPrint('AppFilePicker pick failed: $error');
    } finally {
      isPicking = false;
      update();
    }
  }

  Future<void> _addFiles(List<AppPickedFile> files) async {
    if (files.isEmpty) {
      return;
    }

    final List<AppPickedFile> existingFiles = <AppPickedFile>[];
    for (final AppPickedFile file in files) {
      if (await File(file.path).exists()) {
        existingFiles.add(file);
      }
    }

    final List<AppPickedFile> nextFiles = existingFiles
        .where(
          (AppPickedFile file) =>
              !pickedFiles.any((AppPickedFile item) => item.path == file.path),
        )
        .toList();

    if (nextFiles.isEmpty) {
      return;
    }

    if (!isMulti) {
      pickedFiles
        ..clear()
        ..add(nextFiles.first);
      selectedPaths
        ..clear()
        ..add(nextFiles.first.path);
      update();
      return;
    }

    pickedFiles.addAll(nextFiles);
    for (final AppPickedFile file in nextFiles) {
      if (remainingCount <= 0) {
        break;
      }
      selectedPaths.add(file.path);
    }
    update();
  }

  Future<void> _pickFromWechatAssets(
    BuildContext context, {
    required bool allowCameraEntry,
  }) async {
    final int maxAssets = isMulti ? (maxLimit ?? 999) : 1;
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: maxAssets,
        requestType: _requestType,
        specialItemPosition: allowCameraEntry
            ? SpecialItemPosition.prepend
            : SpecialItemPosition.none,
        specialItemBuilder: allowCameraEntry
            ? (
                BuildContext itemContext,
                AssetPathEntity? path,
                int length,
              ) {
                return _WechatCameraEntry(
                  onTap: () async {
                    Navigator.of(itemContext).maybePop();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 120),
                    );
                    if (context.mounted) {
                      await _pickFromWechatCamera(context);
                    }
                  },
                );
              }
            : null,
      ),
    );
    if (assets == null || assets.isEmpty) {
      return;
    }
    await _addFiles(
      (await Future.wait(
        assets.map(
          (AssetEntity asset) => _fromAssetEntity(
            asset,
            source: AppPickerSource.gallery,
          ),
        ),
      ))
          .whereType<AppPickedFile>()
          .toList(),
    );
  }

  Future<void> _pickFromWechatCamera(BuildContext context) async {
    final AssetEntity? asset = await wechat_camera.CameraPicker.pickFromCamera(
      context,
      pickerConfig: const wechat_camera.CameraPickerConfig(
        enableRecording: false,
      ),
    );
    if (asset == null) {
      return;
    }
    final AppPickedFile? file = await _fromAssetEntity(
      asset,
      source: AppPickerSource.camera,
    );
    if (file != null) {
      await _addFiles(<AppPickedFile>[file]);
    }
  }

  Future<AppPickedFile?> _fromAssetEntity(
    AssetEntity asset, {
    required AppPickerSource source,
  }) async {
    final File? file = await asset.originFile ?? await asset.file;
    if (file == null) {
      return null;
    }
    final String name = await _assetName(asset, file);
    final int? size = await file.exists() ? await file.length() : null;
    return AppPickedFile(
      path: file.path,
      name: name,
      source: source,
      size: size,
      extension: _extensionFromName(name),
    );
  }

  Future<String> _assetName(AssetEntity asset, File file) async {
    final String? title = asset.title;
    if (title != null && title.trim().isNotEmpty) {
      return title;
    }
    try {
      final String asyncTitle = await asset.titleAsync;
      if (asyncTitle.trim().isNotEmpty) {
        return asyncTitle;
      }
    } catch (_) {
      // Some platform assets do not expose a title. Fall back to the file name.
    }
    return file.path.split(Platform.pathSeparator).last;
  }

  int _countForPath(String id) {
    switch (id) {
      case 'gallery':
        return pickedFiles
            .where(
              (AppPickedFile file) =>
                  file.source == AppPickerSource.gallery ||
                  file.source == AppPickerSource.camera,
            )
            .length;
      case 'file_system':
        return pickedFiles
            .where(
              (AppPickedFile file) => file.source == AppPickerSource.fileSystem,
            )
            .length;
      case 'all':
      default:
        return pickedFiles.length;
    }
  }

  Future<AppPickedFile> _fromXFile(
    XFile file, {
    required AppPickerSource source,
  }) async {
    final int? size = await file.length();
    final String name =
        file.name.isNotEmpty ? file.name : file.path.split('/').last;
    return AppPickedFile(
      path: file.path,
      name: name,
      source: source,
      size: size,
      extension: _extensionFromName(name),
    );
  }

  FileType get _fileType {
    switch (mimeType) {
      case AppPickerMimeType.image:
        return FileType.image;
      case AppPickerMimeType.video:
        return FileType.video;
      case AppPickerMimeType.custom:
        return FileType.custom;
      case AppPickerMimeType.all:
        return FileType.any;
    }
  }

  String? _extensionFromName(String name) {
    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) {
      return null;
    }
    return name.substring(dotIndex + 1);
  }

  RequestType get _requestType {
    switch (mimeType) {
      case AppPickerMimeType.image:
        return RequestType.image;
      case AppPickerMimeType.video:
        return RequestType.video;
      case AppPickerMimeType.all:
        return RequestType.common;
      case AppPickerMimeType.custom:
        return RequestType.all;
    }
  }
}

class _WechatCameraEntry extends StatelessWidget {
  final VoidCallback onTap;

  const _WechatCameraEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: InkWell(
        onTap: onTap,
        child: const Center(
          child: Icon(
            Icons.photo_camera_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

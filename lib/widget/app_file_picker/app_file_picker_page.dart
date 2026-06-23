import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_file_picker_controller.dart';
import 'app_file_picker_models.dart';
import 'app_file_picker_sheet.dart';
import 'wechat_path_selector.dart';

class AppFilePickerPage extends StatelessWidget {
  final bool isMulti;
  final int? maxLimit;
  final AppPickerMimeType mimeType;
  final List<String>? allowedExtensions;
  final String title;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowFileSystem;

  const AppFilePickerPage({
    required this.isMulti,
    required this.mimeType,
    super.key,
    this.maxLimit,
    this.allowedExtensions,
    this.title = '选择文件',
    this.allowCamera = true,
    this.allowGallery = true,
    this.allowFileSystem = true,
  });

  static Future<List<AppPickedFile>?> pick(
    BuildContext context, {
    bool isMulti = true,
    int? maxLimit,
    AppPickerMimeType mimeType = AppPickerMimeType.all,
    List<String>? allowedExtensions,
    String title = '选择文件',
    bool allowCamera = true,
    bool allowGallery = true,
    bool allowFileSystem = true,
  }) {
    return Navigator.of(context).push<List<AppPickedFile>>(
      MaterialPageRoute<List<AppPickedFile>>(
        builder: (_) => AppFilePickerPage(
          isMulti: isMulti,
          maxLimit: maxLimit,
          mimeType: mimeType,
          allowedExtensions: allowedExtensions,
          title: title,
          allowCamera: allowCamera,
          allowGallery: allowGallery,
          allowFileSystem: allowFileSystem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppFilePickerController>(
      init: AppFilePickerController(
        isMulti: isMulti,
        maxLimit: maxLimit,
        mimeType: mimeType,
        allowedExtensions: allowedExtensions,
      ),
      builder: (AppFilePickerController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                onPressed: controller.hasSelection
                    ? () => Navigator.of(context).pop(
                          controller.selectedFiles,
                        )
                    : null,
                child: Text(
                  controller.hasSelection
                      ? '完成(${controller.selectedFiles.length})'
                      : '完成',
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              _PickerActionBar(
                controller: controller,
                allowCamera: allowCamera,
                allowGallery: allowGallery,
                allowFileSystem: allowFileSystem,
              ),
              WechatPathSelector(
                paths: controller.displayPaths,
                currentPath: controller.currentPath,
                isExpanded: controller.isPathSelectorExpanded,
                isEnabled: !controller.isPicking,
                onPathChanged: controller.switchPath,
              ),
              Expanded(
                child: controller.visibleFiles.isNotEmpty
                    ? _PickedFileList(controller: controller)
                    : controller.hasFiles
                        ? const _EmptyPathState()
                        : _EmptyPickerState(
                            onPick: () => _showSourceSheet(context, controller),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showSourceSheet(
    BuildContext context,
    AppFilePickerController controller,
  ) async {
    final AppPickerSource? source = await showAppFilePickerSourceSheet(
      context,
      allowCamera: allowCamera && controller.canShowCameraEntry,
      allowGallery: allowGallery,
      allowFileSystem: allowFileSystem,
    );
    if (source == null) {
      return;
    }
    switch (source) {
      case AppPickerSource.camera:
        await controller.pickFromCamera(context);
        break;
      case AppPickerSource.gallery:
        await controller.pickFromGallery(
          context,
          allowCameraEntry: allowCamera,
        );
        break;
      case AppPickerSource.fileSystem:
        await controller.pickFromFileSystem();
        break;
    }
  }
}

class _PickerActionBar extends StatelessWidget {
  final AppFilePickerController controller;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowFileSystem;

  const _PickerActionBar({
    required this.controller,
    required this.allowCamera,
    required this.allowGallery,
    required this.allowFileSystem,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: controller.togglePathSelector,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          controller.currentPath?.name ?? '全部文件',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        AnimatedRotation(
                          turns: controller.isPathSelectorExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (controller.hasFiles)
                  Text(
                    '${controller.visibleFiles.length} 项',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                if (allowCamera && controller.canShowCameraEntry)
                  _ActionButton(
                    icon: Icons.photo_camera_outlined,
                    label: '拍照',
                    onPressed: controller.remainingCount > 0
                        ? () => controller.pickFromCamera(context)
                        : null,
                  ),
                if (allowGallery)
                  _ActionButton(
                    icon: Icons.photo_library_outlined,
                    label: '相册',
                    onPressed: controller.remainingCount > 0
                        ? () => controller.pickFromGallery(
                              context,
                              allowCameraEntry: allowCamera,
                            )
                        : null,
                  ),
                if (allowFileSystem)
                  _ActionButton(
                    icon: Icons.folder_open_rounded,
                    label: '文件',
                    onPressed: controller.remainingCount > 0
                        ? controller.pickFromFileSystem
                        : null,
                  ),
                const Spacer(),
                if (controller.hasFiles)
                  IconButton(
                    tooltip: '清空',
                    onPressed: controller.clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
                if (controller.hasSelection)
                  IconButton(
                    tooltip: '取消选择',
                    onPressed: controller.clearSelection,
                    icon: const Icon(Icons.deselect_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _summaryText(controller),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (controller.isPicking) ...<Widget>[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _summaryText(AppFilePickerController controller) {
    final String limitText =
        controller.maxLimit == null ? '不限数量' : '最多 ${controller.maxLimit} 个';
    return '已选 ${controller.selectedFiles.length} 个，$limitText';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _PickedFileList extends StatefulWidget {
  final AppFilePickerController controller;

  const _PickedFileList({required this.controller});

  @override
  State<_PickedFileList> createState() => _PickedFileListState();
}

class _PickedFileListState extends State<_PickedFileList> {
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  int? _dragStartIndex;
  int? _lastDragIndex;
  bool _dragSelectMode = true;

  GlobalKey _keyForIndex(int index) {
    return _itemKeys.putIfAbsent(index, GlobalKey.new);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (DragStartDetails details) {
        final int? index = _indexAt(details.globalPosition);
        if (index == null) {
          return;
        }
        final AppPickedFile file = widget.controller.visibleFiles[index];
        _dragStartIndex = index;
        _lastDragIndex = index;
        _dragSelectMode = !widget.controller.isSelected(file);
        widget.controller.toggleSelection(file, selected: _dragSelectMode);
      },
      onPanUpdate: (DragUpdateDetails details) {
        final int? index = _indexAt(details.globalPosition);
        if (index == null || index == _lastDragIndex) {
          return;
        }
        final int start = _dragStartIndex ?? index;
        _lastDragIndex = index;
        widget.controller.selectVisibleRange(
          start,
          index,
          selected: _dragSelectMode,
        );
      },
      onPanEnd: (_) => _resetDrag(),
      onPanCancel: _resetDrag,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: widget.controller.visibleFiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          final AppPickedFile file = widget.controller.visibleFiles[index];
          return KeyedSubtree(
            key: _keyForIndex(index),
            child: _SelectedFileTile(
              file: file,
              selected: widget.controller.isSelected(file),
              onTap: () => widget.controller.toggleSelection(file),
              onRemove: () => widget.controller.removeFile(file),
            ),
          );
        },
      ),
    );
  }

  int? _indexAt(Offset globalPosition) {
    for (final MapEntry<int, GlobalKey> entry in _itemKeys.entries) {
      final BuildContext? context = entry.value.currentContext;
      if (context == null) {
        continue;
      }
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset localPosition = box.globalToLocal(globalPosition);
      if (box.size.contains(localPosition)) {
        return entry.key;
      }
    }
    return null;
  }

  void _resetDrag() {
    _dragStartIndex = null;
    _lastDragIndex = null;
  }
}

class _SelectedFileTile extends StatelessWidget {
  final AppPickedFile file;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SelectedFileTile({
    required this.file,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.08)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.62)
                  : colorScheme.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                _FilePreview(file: file),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _fileMeta(file),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: selected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey<String>('selected'),
                          color: colorScheme.primary,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey<String>('unselected'),
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
                IconButton(
                  tooltip: '移除',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fileMeta(AppPickedFile file) {
    final String type = file.isImage
        ? '图片'
        : file.isVideo
            ? '视频'
            : '文件';
    final int? size = file.size;
    if (size == null) {
      return type;
    }
    return '$type · ${_formatSize(size)}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
}

class _FilePreview extends StatelessWidget {
  final AppPickedFile file;

  const _FilePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        width: 58,
        height: 58,
        child: file.isImage
            ? Image.file(
                File(file.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _IconPreview(file: file),
              )
            : ColoredBox(
                color: colorScheme.surfaceContainerHighest,
                child: _IconPreview(file: file),
              ),
      ),
    );
  }
}

class _IconPreview extends StatelessWidget {
  final AppPickedFile file;

  const _IconPreview({required this.file});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Icon(
      file.isVideo
          ? Icons.play_circle_outline_rounded
          : Icons.insert_drive_file_outlined,
      color: colorScheme.onSurfaceVariant,
    );
  }
}

class _EmptyPickerState extends StatelessWidget {
  final VoidCallback onPick;

  const _EmptyPickerState({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 58,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '还没有选择文件',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '可以从相册、相机或文件系统中选择。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add_rounded),
              label: const Text('开始选择'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPathState extends StatelessWidget {
  const _EmptyPathState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.folder_off_outlined,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              '这个分组暂时没有文件',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '切换到其他分组，或者继续添加文件。',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

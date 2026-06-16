import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/smb_mount/smb_mount_controller.dart';
import 'package:get/get.dart';

class SmbFileBrowserPage extends StatefulWidget {
  const SmbFileBrowserPage({Key? key}) : super(key: key);

  @override
  State<SmbFileBrowserPage> createState() => _SmbFileBrowserPageState();
}

class _SmbFileBrowserPageState extends State<SmbFileBrowserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      final SmbMountController controller = Get.find<SmbMountController>();
      if (controller.mountPath.isNotEmpty && controller.entries.isEmpty) {
        controller.loadEntries(path: controller.mountPath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SmbMountController>(
      builder: (SmbMountController controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('NAS 目录浏览'),
            actions: <Widget>[
              IconButton(
                tooltip: '返回上级',
                onPressed: controller.currentBrowsePath == controller.mountPath
                    ? null
                    : controller.browseParent,
                icon: const Icon(Icons.arrow_upward_outlined),
              ),
              IconButton(
                tooltip: '刷新',
                onPressed: controller.loadEntries,
                icon: const Icon(Icons.refresh_outlined),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SmbFileBrowserView(controller: controller),
          ),
        );
      },
    );
  }
}

class SmbFileBrowserView extends StatelessWidget {
  final SmbMountController controller;
  final bool embedded;

  const SmbFileBrowserView({
    required this.controller,
    this.embedded = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget content = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Row(
            children: <Widget>[
              Icon(Icons.account_tree_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '挂载目录浏览',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      controller.currentBrowsePath.isEmpty
                          ? '还没有读取目录'
                          : controller.currentBrowsePath,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (controller.isLoadingEntries)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        Expanded(
          child: _BrowserBody(controller: controller),
        ),
      ],
    );

    if (!embedded) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: content,
      );
    }

    return content;
  }
}

class _BrowserBody extends StatelessWidget {
  final SmbMountController controller;

  const _BrowserBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.currentBrowsePath.isEmpty) {
      return const Center(child: Text('挂载成功后会在这里显示 NAS 目录。'));
    }
    if (controller.entries.isEmpty) {
      return const Center(child: Text('当前目录为空。'));
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        final SmbFileEntry entry = controller.entries[index];
        return _FileEntryTile(
          entry: entry,
          onTap: () {
            controller.openEntry(entry);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1,
          indent: 68,
          color: Theme.of(context).colorScheme.outlineVariant,
        );
      },
      itemCount: controller.entries.length,
    );
  }
}

class _FileEntryTile extends StatelessWidget {
  final SmbFileEntry entry;
  final VoidCallback onTap;

  const _FileEntryTile({
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                entry.isDirectory
                    ? Icons.folder_outlined
                    : Icons.insert_drive_file_outlined,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.isDirectory
                        ? '文件夹'
                        : '${_formatSize(entry.size)} · ${_formatDate(entry.modified)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              entry.isDirectory
                  ? Icons.chevron_right
                  : Icons.open_in_new_outlined,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int size) {
    if (size < 1024) {
      return '$size B';
    }
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }
    if (size < 1024 * 1024 * 1024) {
      return '${(size / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

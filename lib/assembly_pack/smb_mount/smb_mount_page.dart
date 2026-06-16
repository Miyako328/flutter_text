import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/smb_mount/smb_file_browser_page.dart';
import 'package:flutter_text/assembly_pack/smb_mount/smb_mount_controller.dart';
import 'package:flutter_text/global/global.dart';
import 'package:get/get.dart';

class SmbMountPage extends StatefulWidget {
  const SmbMountPage({Key? key}) : super(key: key);

  @override
  State<SmbMountPage> createState() => _SmbMountPageState();
}

class _SmbMountPageState extends State<SmbMountPage> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _shareController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mountPathController = TextEditingController();
  final TextEditingController _inboxFolderController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _shareController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _mountPathController.dispose();
    _inboxFolderController.dispose();
    super.dispose();
  }

  void _syncTextFields(SmbMountController controller) {
    _setTextIfNeeded(_hostController, controller.host);
    _setTextIfNeeded(_portController, '${controller.port}');
    _setTextIfNeeded(_shareController, controller.shareName);
    _setTextIfNeeded(_usernameController, controller.username);
    _setTextIfNeeded(_mountPathController, controller.mountPath);
    _setTextIfNeeded(_inboxFolderController, controller.inboxFolder);
  }

  void _setTextIfNeeded(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.text = value;
  }

  void _save(SmbMountController controller) {
    controller.saveSettings(
      nextHost: _hostController.text,
      nextPort: _portController.text,
      nextShareName: _shareController.text,
      nextUsername: _usernameController.text,
      nextMountPath: _mountPathController.text,
      nextInboxFolder: _inboxFolderController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SmbMountController>(
      init: SmbMountController(),
      builder: (SmbMountController controller) {
        _syncTextFields(controller);
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: GlobalStore.isMobile
              ? AppBar(
                  title: const Text('SMB 挂载目录'),
                )
              : null,
          backgroundColor: colorScheme.surface,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
            children: <Widget>[
              _Header(controller: controller),
              const SizedBox(height: 18),
              _Panel(
                title: 'SMB 连接',
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: _TextField(
                          controller: _hostController,
                          label: 'SMB IP',
                          icon: Icons.dns_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 130,
                        child: _TextField(
                          controller: _portController,
                          label: '端口',
                          icon: Icons.settings_ethernet_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TextField(
                    controller: _shareController,
                    label: '共享名，应用内挂载必填',
                    icon: Icons.folder_shared_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _TextField(
                          controller: _usernameController,
                          label: '用户名，可留空',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TextField(
                          controller: _passwordController,
                          label: '密码，不保存',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ActionRow(
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () => _save(controller),
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('保存配置'),
                      ),
                      OutlinedButton.icon(
                        onPressed: controller.isChecking
                            ? null
                            : () {
                                _save(controller);
                                controller.checkConnection();
                              },
                        icon: controller.isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.wifi_find_outlined, size: 18),
                        label: const Text('检测连接'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _save(controller);
                          controller.openSmbUrl();
                        },
                        icon: const Icon(Icons.open_in_new_outlined, size: 18),
                        label: const Text('系统挂载 SMB'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: controller.isMounting
                            ? null
                            : () {
                                _save(controller);
                                controller.mountSmb(
                                  password: _passwordController.text,
                                );
                              },
                        icon: controller.isMounting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.link_outlined, size: 18),
                        label: const Text('应用内挂载 SMB'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InlineStatus(controller: controller),
                ],
              ),
              const SizedBox(height: 18),
              _Panel(
                title: '本地挂载目录',
                children: <Widget>[
                  _TextField(
                    controller: _mountPathController,
                    label: '本地挂载路径，例如 /Volumes/Share',
                    icon: Icons.folder_open_outlined,
                  ),
                  const SizedBox(height: 12),
                  _TextField(
                    controller: _inboxFolderController,
                    label: 'DropDock 收件箱子目录',
                    icon: Icons.move_to_inbox_outlined,
                  ),
                  const SizedBox(height: 12),
                  _PathPreview(
                    label: '当前 SMB 地址',
                    value: controller.smbUrl,
                  ),
                  const SizedBox(height: 8),
                  _PathPreview(
                    label: '当前收件箱',
                    value: controller.inboxPath.isEmpty
                        ? '请先选择本地挂载目录'
                        : controller.inboxPath,
                  ),
                  const SizedBox(height: 12),
                  _ActionRow(
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: () async {
                          await controller.chooseMountDirectory();
                        },
                        icon: const Icon(Icons.folder_copy_outlined, size: 18),
                        label: const Text('选择挂载目录'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          _save(controller);
                          controller.createInboxDirectory();
                        },
                        icon: const Icon(Icons.create_new_folder_outlined,
                            size: 18),
                        label: const Text('创建收件箱'),
                      ),
                      OutlinedButton.icon(
                        onPressed: controller.openMountDirectory,
                        icon: const Icon(Icons.folder_open_outlined, size: 18),
                        label: const Text('打开挂载目录'),
                      ),
                      OutlinedButton.icon(
                        onPressed: controller.openInboxDirectory,
                        icon: const Icon(Icons.inbox_outlined, size: 18),
                        label: const Text('打开收件箱'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.loadEntries(path: controller.mountPath);
                        },
                        icon: const Icon(Icons.refresh_outlined, size: 18),
                        label: const Text('刷新目录'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: controller.mountPath.trim().isEmpty
                            ? null
                            : () {
                                controller.loadEntries(
                                  path: controller.mountPath,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const SmbFileBrowserPage(),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.account_tree_outlined, size: 18),
                        label: const Text('打开 NAS 目录浏览'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _Panel(
                title: '挂载方式',
                children: <Widget>[
                  Text(
                    '系统挂载 SMB 会打开 macOS 自带挂载入口；应用内挂载 SMB 会通过 macOS NetFS API 在应用里发起挂载，并把返回的挂载点写入本地挂载路径。',
                  ),
                  SizedBox(height: 8),
                  Text(
                    '这仍然是 macOS 系统级挂载，不是纯 Dart SMB 文件系统。纯应用内读写后续可以继续接 AMSMB2/libsmb2。',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StatusPanel(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final SmbMountController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.lan_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SMB 挂载目录',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '先把 NAS 作为本机目录接入，后续 DropDock 的文件投递会落到这个收件箱。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Panel({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final List<Widget> children;

  const _ActionRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: children,
    );
  }
}

class _PathPreview extends StatelessWidget {
  final String label;
  final String value;

  const _PathPreview({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 112,
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Expanded(
              child: SelectableText(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineStatus extends StatelessWidget {
  final SmbMountController controller;

  const _InlineStatus({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            if (controller.isMounting || controller.isChecking)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.info_outline,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.statusMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final SmbMountController controller;

  const _StatusPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '状态',
      children: <Widget>[
        _StatusRow(
          label: 'SMB 端口',
          value: _statusText(controller.portReachable),
          ok: controller.portReachable,
        ),
        const SizedBox(height: 8),
        _StatusRow(
          label: '挂载目录',
          value: _statusText(controller.mountDirectoryReady),
          ok: controller.mountDirectoryReady,
        ),
        const SizedBox(height: 8),
        _StatusRow(
          label: '收件箱',
          value: _statusText(controller.inboxReady),
          ok: controller.inboxReady,
        ),
        const SizedBox(height: 12),
        Text(controller.statusMessage),
      ],
    );
  }

  String _statusText(bool? value) {
    if (value == null) {
      return '未检测';
    }
    return value ? '正常' : '未就绪';
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? ok;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = ok == true
        ? Colors.green
        : ok == false
            ? Colors.orange
            : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: <Widget>[
        Icon(
          ok == true ? Icons.check_circle : Icons.info_outline,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        SizedBox(width: 90, child: Text(label)),
        Text(value, style: TextStyle(color: color)),
      ],
    );
  }
}

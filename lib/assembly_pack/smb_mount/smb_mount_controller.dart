import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:self_utils/global/store.dart';

class SmbMountController extends GetxController {
  static const MethodChannel _channel = MethodChannel('flutter_text/smb_mount');

  static const String _hostKey = 'smb_mount_host';
  static const String _portKey = 'smb_mount_port';
  static const String _shareKey = 'smb_mount_share';
  static const String _usernameKey = 'smb_mount_username';
  static const String _mountPathKey = 'smb_mount_path';
  static const String _inboxFolderKey = 'smb_mount_inbox_folder';

  String host = '192.168.1.108';
  int port = 445;
  String shareName = '';
  String username = '';
  String mountPath = '';
  String inboxFolder = 'DropDock/inbox';

  bool isChecking = false;
  bool isMounting = false;
  bool isLoadingEntries = false;
  bool? portReachable;
  bool? mountDirectoryReady;
  bool? inboxReady;
  String statusMessage = '还没有检测 SMB 连接';
  DateTime? lastCheckedAt;
  String currentBrowsePath = '';
  List<SmbFileEntry> entries = <SmbFileEntry>[];

  String get smbUrl {
    final String cleanShare = shareName.trim();
    final String path = cleanShare.isEmpty ? '' : '/$cleanShare';
    return 'smb://$host:$port$path';
  }

  String get launchSmbUrl {
    final String cleanShare = shareName.trim();
    final String path = cleanShare.isEmpty ? '' : '/$cleanShare';
    if (port == 445) {
      return 'smb://$host$path';
    }
    return smbUrl;
  }

  String get inboxPath {
    if (mountPath.trim().isEmpty) {
      return '';
    }
    return '${mountPath.trim()}/$inboxFolder';
  }

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    host = LocateStorage.getString(_hostKey) ?? host;
    port = LocateStorage.getInt(_portKey) ?? port;
    shareName = LocateStorage.getString(_shareKey) ?? shareName;
    username = LocateStorage.getString(_usernameKey) ?? username;
    mountPath = LocateStorage.getString(_mountPathKey) ?? mountPath;
    inboxFolder = LocateStorage.getString(_inboxFolderKey) ?? inboxFolder;
    _refreshDirectoryStatus();
    update();
  }

  void saveSettings({
    required String nextHost,
    required String nextPort,
    required String nextShareName,
    required String nextUsername,
    required String nextMountPath,
    required String nextInboxFolder,
  }) {
    host = nextHost.trim().isEmpty ? '192.168.1.108' : nextHost.trim();
    port = int.tryParse(nextPort.trim()) ?? 445;
    shareName = nextShareName.trim();
    username = nextUsername.trim();
    mountPath = nextMountPath.trim();
    inboxFolder = nextInboxFolder.trim().isEmpty
        ? 'DropDock/inbox'
        : nextInboxFolder.trim();

    LocateStorage.setString(_hostKey, host);
    LocateStorage.setInt(_portKey, port);
    LocateStorage.setString(_shareKey, shareName);
    LocateStorage.setString(_usernameKey, username);
    LocateStorage.setString(_mountPathKey, mountPath);
    LocateStorage.setString(_inboxFolderKey, inboxFolder);
    statusMessage = 'SMB 配置已保存';
    _refreshDirectoryStatus();
    update();
  }

  Future<void> mountSmb({required String password}) async {
    if (!Platform.isMacOS) {
      statusMessage = '应用内 SMB 挂载目前只实现了 macOS';
      update();
      return;
    }
    if (shareName.trim().isEmpty) {
      statusMessage = '应用内挂载需要填写共享名';
      update();
      return;
    }

    isMounting = true;
    statusMessage = '正在挂载 $launchSmbUrl ...';
    debugPrint('[SmbMount] start mount $launchSmbUrl');
    update();

    try {
      if (username.trim().isEmpty && password.trim().isEmpty) {
        statusMessage = '正在以访客方式尝试挂载 $launchSmbUrl ...';
        update();
      }
      final Map<Object?, Object?> result =
          await _channel.invokeMethod<Map<Object?, Object?>>(
                'mountSmb',
                <String, Object?>{
                  'host': host,
                  'port': port,
                  'shareName': shareName,
                  'username': username,
                  'password': password,
                },
              ).timeout(const Duration(seconds: 20)) ??
              <Object?, Object?>{};
      debugPrint('[SmbMount] native result $result');
      final bool alreadyMounted = result['alreadyMounted'] == true;
      final List<Object?> mountPoints =
          (result['mountPoints'] as List<Object?>?) ?? <Object?>[];
      String? firstMountPoint;
      for (final String value in mountPoints.whereType<String>()) {
        if (value.trim().isNotEmpty) {
          firstMountPoint = value;
          break;
        }
      }
      if (firstMountPoint != null) {
        mountPath = firstMountPoint;
        LocateStorage.setString(_mountPathKey, mountPath);
      }
      if (firstMountPoint == null) {
        statusMessage = alreadyMounted
            ? 'SMB 已经挂载，但没有找到 /Volumes 下的挂载点，请手动选择目录'
            : 'SMB 已挂载，但没有返回挂载点，请手动选择目录';
      } else {
        statusMessage = alreadyMounted
            ? 'SMB 已经挂载：$firstMountPoint'
            : 'SMB 已挂载：$firstMountPoint';
      }
    } on TimeoutException {
      statusMessage = '挂载超时：macOS 可能正在等待认证或共享响应。请确认共享名正确；如果 NAS 需要账号密码，请填写后再试。';
    } on PlatformException catch (err) {
      final Object? status = err.details is Map
          ? (err.details as Map<Object?, Object?>)['status']
          : null;
      if (status == 1) {
        statusMessage =
            '挂载失败：macOS 返回 Operation not permitted。通常是 App Sandbox 阻止应用内挂载，已关闭沙盒配置，请重新运行 macOS 应用后再试。';
      } else {
        statusMessage = '挂载失败：${err.message ?? err.code}';
      }
    } catch (err) {
      statusMessage = '挂载失败：$err';
    }

    isMounting = false;
    _refreshDirectoryStatus();
    if (mountDirectoryReady == true) {
      await loadEntries(path: mountPath);
    }
    update();
  }

  Future<void> checkConnection() async {
    isChecking = true;
    statusMessage = '正在检测 $host:$port ...';
    update();

    try {
      final Socket socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      portReachable = true;
      statusMessage = 'SMB 端口可连接，继续检查本地挂载目录';
    } catch (err) {
      portReachable = false;
      statusMessage = '无法连接 $host:$port，请确认 NAS 和 SMB 服务在线';
    }

    _refreshDirectoryStatus();
    lastCheckedAt = DateTime.now();
    isChecking = false;
    update();
  }

  Future<void> chooseMountDirectory() async {
    try {
      final String? selectedPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择 NAS 已挂载目录',
      );
      if (selectedPath == null || selectedPath.isEmpty) {
        return;
      }
      mountPath = selectedPath;
      LocateStorage.setString(_mountPathKey, mountPath);
      statusMessage = '已选择本地挂载目录';
      await loadEntries(path: mountPath);
    } on PlatformException catch (err) {
      statusMessage = err.code == 'ENTITLEMENT_NOT_FOUND'
          ? '选择目录失败：macOS 需要开启 user-selected read-write entitlement，已在工程里补上，重新运行后生效'
          : '选择目录失败：${err.message ?? err.code}';
    } catch (err) {
      statusMessage = '选择目录失败：$err';
    }
    _refreshDirectoryStatus();
    update();
  }

  Future<void> createInboxDirectory() async {
    if (inboxPath.isEmpty) {
      statusMessage = '请先选择本地挂载目录';
      update();
      return;
    }
    try {
      await Directory(inboxPath).create(recursive: true);
      statusMessage = 'DropDock 收件箱已准备好';
    } catch (err) {
      statusMessage = '创建收件箱失败：$err';
    }
    _refreshDirectoryStatus();
    update();
  }

  Future<void> openSmbUrl() async {
    await _openPath(launchSmbUrl);
  }

  Future<void> openMountDirectory() async {
    if (mountPath.trim().isEmpty) {
      statusMessage = '请先选择本地挂载目录';
      update();
      return;
    }
    await _openPath(mountPath);
  }

  Future<void> openInboxDirectory() async {
    if (inboxPath.isEmpty) {
      statusMessage = '请先创建 DropDock 收件箱';
      update();
      return;
    }
    await _openPath(inboxPath);
  }

  Future<void> loadEntries({String? path}) async {
    final String targetPath = path ?? currentBrowsePath;
    if (targetPath.trim().isEmpty) {
      entries = <SmbFileEntry>[];
      currentBrowsePath = '';
      statusMessage = '请先挂载或选择目录';
      update();
      return;
    }

    isLoadingEntries = true;
    currentBrowsePath = targetPath;
    update();

    try {
      final Directory directory = Directory(targetPath);
      final List<FileSystemEntity> children = await directory.list().toList();
      final List<SmbFileEntry> nextEntries = <SmbFileEntry>[];
      for (final FileSystemEntity entity in children) {
        final FileStat stat = await entity.stat();
        final String name = _displayNameForPath(entity.path);
        nextEntries.add(
          SmbFileEntry(
            name: name,
            path: entity.path,
            isDirectory: stat.type == FileSystemEntityType.directory,
            size: stat.size,
            modified: stat.modified,
          ),
        );
      }
      nextEntries.sort((SmbFileEntry a, SmbFileEntry b) {
        if (a.isDirectory != b.isDirectory) {
          return a.isDirectory ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      entries = nextEntries;
      statusMessage = '已读取 ${entries.length} 个条目';
    } catch (err) {
      entries = <SmbFileEntry>[];
      statusMessage = '读取目录失败：$err';
    }

    isLoadingEntries = false;
    update();
  }

  Future<void> openEntry(SmbFileEntry entry) async {
    if (entry.isDirectory) {
      await loadEntries(path: entry.path);
      return;
    }
    await _openPath(entry.path);
  }

  Future<void> browseParent() async {
    if (currentBrowsePath.trim().isEmpty || currentBrowsePath == mountPath) {
      return;
    }
    final Directory parent = Directory(currentBrowsePath).parent;
    await loadEntries(path: parent.path);
  }

  String _displayNameForPath(String path) {
    final List<String> parts = path
        .split(Platform.pathSeparator)
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return path;
    }
    return parts.last;
  }

  void _refreshDirectoryStatus() {
    mountDirectoryReady =
        mountPath.trim().isNotEmpty && Directory(mountPath).existsSync();
    inboxReady = inboxPath.isNotEmpty && Directory(inboxPath).existsSync();
    if (mountDirectoryReady == true && currentBrowsePath.isEmpty) {
      currentBrowsePath = mountPath;
    }
  }

  Future<void> _openPath(String target) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', <String>[target]);
      } else if (Platform.isWindows) {
        await Process.run('explorer', <String>[target]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', <String>[target]);
      }
    } catch (err) {
      statusMessage = '打开失败：$err';
      update();
    }
  }
}

class SmbFileEntry {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;

  const SmbFileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
  });
}

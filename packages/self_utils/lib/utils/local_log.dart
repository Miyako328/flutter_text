import 'dart:async';
import 'dart:io';

import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalLog {
  static String _log = '';
  static Timer? timer;

  static Future<File> _getDocument() async {
    final document = await getTemporaryDirectory();
    final PackageInfo info = await PackageInfo.fromPlatform();
    final filePath =  path.join(document.path, '${info.packageName}_log.log');

    final File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  static void setLog(String log) {
    _log += '$log\n';
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = Timer(const Duration(milliseconds: 1000), () async {
      await _setLocalLog();
      timer = null;
    });
  }

  static Future<String> getLogInfo() async {
    final File file = await _getDocument();
    return await file.readAsString();
  }

  static Future<void> _setLocalLog() async {
    final File file = await _getDocument();
    if ((file.readAsBytesSync().lengthInBytes / 1024 / 1024) < 5) {
      final String a = await file.readAsString();
      if (a.isNotEmpty == true) {
        _log = '$a$_log';
      }
    }
    await file.writeAsString(_log);
    _log = '';
  }

  static Future<void> clear() async {
    final File file = await _getDocument();
    await file.writeAsString('');
  }
}

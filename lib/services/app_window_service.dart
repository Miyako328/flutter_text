import 'dart:io';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';

class AppWindowService {
  const AppWindowService._();

  static Future<void> initializeDesktopWindow() async {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }

    await windowManager.ensureInitialized();
    const WindowOptions windowOptions = WindowOptions(
      size: Size(1080, 700),
      minimumSize: Size(1080, 700),
      center: true,
      title: 'flutter学习组件',
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

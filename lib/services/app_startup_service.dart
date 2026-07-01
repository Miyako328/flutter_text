import 'dart:io';

import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:flutter_text/controllers/main_controller.dart';
import 'package:flutter_text/global/global.dart';
import 'package:get/get.dart';
import 'package:self_utils/global/store.dart';
import 'package:self_utils/utils/shortcuts/quick_actions_method.dart';
import 'package:self_utils/utils/shortcuts/shortcuts_model.dart';
import 'package:self_utils/widget/keyboard/security_keyboard.dart';

class AppStartupService {
  const AppStartupService._();

  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static void configurePlatformFlags() {
    if (isDesktop) {
      GlobalStore.isMobile = false;
    }
  }

  static void registerSecurityKeyboard() {
    SecurityKeyboardCenter.register();
  }

  static void registerCoreControllers() {
    if (!Get.isRegistered<MainController>()) {
      Get.put(MainController());
    }
    if (!Get.isRegistered<HomeShellController>()) {
      Get.put(HomeShellController(), permanent: true);
    }
  }

  static void registerQuickActions(List<ShortCutsModel> shortcuts) {
    if (isMobile) {
      ShortCutsQuick(shortCutsAction: shortcuts);
    }
  }

  static Future<bool> initializeAppState() async {
    await LocateStorage.init();
    final bool todayShowAd = _resolveTodayShowAd();
    Get.find<HomeShellController>().loadSettings();
    return todayShowAd;
  }

  static bool _resolveTodayShowAd() {
    if (!GlobalStore.isMobile) {
      return false;
    }
    return LocateStorage.getBoolWithExpire('SplashShow') == true;
  }
}

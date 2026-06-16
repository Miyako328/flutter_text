import 'dart:async';

import 'package:get/get.dart';
import 'package:self_utils/global/store.dart';
import 'package:self_utils/widget/management/common/view_key.dart';

enum DockPosition {
  side,
  bottom,
}

enum DockRevealMode {
  hover,
  click,
}

class HomeShellController extends GetxController {
  static const String _dockPositionKey = 'home_shell_dock_position';
  static const String _dockAutoHideKey = 'home_shell_dock_auto_hide';
  static const String _dockAutoHideSecondsKey =
      'home_shell_dock_auto_hide_seconds';
  static const String _dockRevealModeKey = 'home_shell_dock_reveal_mode';

  bool isImmersive = false;
  DockPosition dockPosition = DockPosition.side;
  bool dockAutoHide = false;
  int dockAutoHideSeconds = 8;
  DockRevealMode dockRevealMode = DockRevealMode.hover;
  bool isDockVisible = true;
  ViewKey? currentKey;
  Timer? _dockHideTimer;

  @override
  void onClose() {
    _dockHideTimer?.cancel();
    super.onClose();
  }

  void loadSettings() {
    final String? savedDockPosition = LocateStorage.getString(_dockPositionKey);
    final String? savedRevealMode = LocateStorage.getString(_dockRevealModeKey);
    dockPosition = DockPosition.values.firstWhere(
      (DockPosition value) => value.name == savedDockPosition,
      orElse: () => DockPosition.side,
    );
    dockAutoHide = LocateStorage.getBool(_dockAutoHideKey) ?? false;
    final int savedSeconds =
        LocateStorage.getInt(_dockAutoHideSecondsKey) ?? dockAutoHideSeconds;
    dockAutoHideSeconds =
        <int>[5, 8, 15].contains(savedSeconds) ? savedSeconds : 8;
    dockRevealMode = DockRevealMode.values.firstWhere(
      (DockRevealMode value) => value.name == savedRevealMode,
      orElse: () => DockRevealMode.hover,
    );
    isDockVisible = true;
    _scheduleDockHide();
    update();
  }

  void setImmersive(bool value) {
    if (isImmersive == value) {
      return;
    }
    isImmersive = value;
    update();
  }

  void setCurrentKey(ViewKey? value) {
    if (currentKey == value) {
      return;
    }
    currentKey = value;
    update();
  }

  void activateDockPage(ViewKey value) {
    registerDockActivity();
    bool hasChange = false;
    if (currentKey != value) {
      currentKey = value;
      hasChange = true;
    }
    if (!isImmersive) {
      isImmersive = true;
      hasChange = true;
    }
    if (hasChange) {
      update();
    }
  }

  void setDockPosition(DockPosition value) {
    if (dockPosition == value) {
      return;
    }
    dockPosition = value;
    LocateStorage.setString(_dockPositionKey, value.name);
    revealDock();
    update();
  }

  void setDockAutoHide(bool value) {
    if (dockAutoHide == value) {
      return;
    }
    dockAutoHide = value;
    LocateStorage.setBool(_dockAutoHideKey, value);
    if (value) {
      revealDock();
    } else {
      _dockHideTimer?.cancel();
      isDockVisible = true;
    }
    update();
  }

  void setDockAutoHideSeconds(int value) {
    final int normalized = value.clamp(3, 30);
    if (dockAutoHideSeconds == normalized) {
      return;
    }
    dockAutoHideSeconds = normalized;
    LocateStorage.setInt(_dockAutoHideSecondsKey, normalized);
    _scheduleDockHide();
    update();
  }

  void setDockRevealMode(DockRevealMode value) {
    if (dockRevealMode == value) {
      return;
    }
    dockRevealMode = value;
    LocateStorage.setString(_dockRevealModeKey, value.name);
    update();
  }

  void registerDockActivity() {
    if (!isDockVisible) {
      isDockVisible = true;
      update();
    }
    _scheduleDockHide();
  }

  void revealDock() {
    if (!isDockVisible) {
      isDockVisible = true;
      update();
    }
    _scheduleDockHide();
  }

  void _scheduleDockHide() {
    _dockHideTimer?.cancel();
    if (!dockAutoHide) {
      return;
    }
    _dockHideTimer = Timer(Duration(seconds: dockAutoHideSeconds), () {
      isDockVisible = false;
      update();
    });
  }
}

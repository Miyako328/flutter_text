import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LayoutPageController extends GetxController {
  RxBool isDesktop = false.obs;
  RxBool isMobile = false.obs;
  RxBool isTablet = false.obs;
  RxDouble screenWidth = 0.0.obs;
  RxDouble screenHeight = 0.0.obs;
  RxString currentLayout = '未知'.obs;
  RxString deviceType = '未知'.obs;
  
  final List<String> layoutHistory = <String>[].obs;
  final List<String> deviceInfo = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _detectDeviceType();
  }
  
  void _detectDeviceType() {
    // 模拟设备检测
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDeviceInfo();
    });
  }
  
  void _updateDeviceInfo() {
    // 这里应该获取实际的屏幕尺寸
    // 模拟不同的设备类型
    final random = DateTime.now().millisecondsSinceEpoch;
    final deviceIndex = random % 3;
    
    switch (deviceIndex) {
      case 0:
        _setDesktopMode();
        break;
      case 1:
        _setMobileMode();
        break;
      case 2:
        _setTabletMode();
        break;
    }
    
    _addLayoutHistory();
  }
  
  void _setDesktopMode() {
    isDesktop.value = true;
    isMobile.value = false;
    isTablet.value = false;
    screenWidth.value = 1920.0;
    screenHeight.value = 1080.0;
    currentLayout.value = '桌面端';
    deviceType.value = 'Desktop';
  }
  
  void _setMobileMode() {
    isDesktop.value = false;
    isMobile.value = true;
    isTablet.value = false;
    screenWidth.value = 375.0;
    screenHeight.value = 812.0;
    currentLayout.value = '手机端';
    deviceType.value = 'Mobile';
  }
  
  void _setTabletMode() {
    isDesktop.value = false;
    isMobile.value = false;
    isTablet.value = true;
    screenWidth.value = 768.0;
    screenHeight.value = 1024.0;
    currentLayout.value = '平板端';
    deviceType.value = 'Tablet';
  }
  
  void _addLayoutHistory() {
    final timestamp = DateTime.now().toString();
    final historyEntry = '$timestamp: ${currentLayout.value} (${screenWidth.value}x${screenHeight.value})';
    layoutHistory.add(historyEntry);
    
    // 保持历史记录在合理范围内
    if (layoutHistory.length > 50) {
      layoutHistory.removeAt(0);
    }
  }
  
  void switchToDesktop() {
    _setDesktopMode();
    _addLayoutHistory();
  }
  
  void switchToMobile() {
    _setMobileMode();
    _addLayoutHistory();
  }
  
  void switchToTablet() {
    _setTabletMode();
    _addLayoutHistory();
  }
  
  void toggleLayout() {
    if (isDesktop.value) {
      switchToMobile();
    } else if (isMobile.value) {
      switchToTablet();
    } else {
      switchToDesktop();
    }
  }
  
  void cycleLayout() {
    if (isDesktop.value) {
      switchToMobile();
    } else if (isMobile.value) {
      switchToTablet();
    } else {
      switchToDesktop();
    }
  }
  
  void updateScreenSize(double width, double height) {
    screenWidth.value = width;
    screenHeight.value = height;
    
    // 根据尺寸自动判断设备类型
    if (width >= 1200) {
      switchToDesktop();
    } else if (width >= 600) {
      switchToTablet();
    } else {
      switchToMobile();
    }
  }
  
  void addDeviceInfo(String info) {
    deviceInfo.add('${DateTime.now().toString()}: $info');
    
    // 保持设备信息在合理范围内
    if (deviceInfo.length > 100) {
      deviceInfo.removeAt(0);
    }
  }
  
  void clearLayoutHistory() {
    layoutHistory.clear();
  }
  
  void clearDeviceInfo() {
    deviceInfo.clear();
  }
  
  void resetLayout() {
    _detectDeviceType();
  }
  
  void forceLayout(String layout) {
    switch (layout.toLowerCase()) {
      case 'desktop':
      case '桌面':
        switchToDesktop();
        break;
      case 'mobile':
      case '手机':
        switchToMobile();
        break;
      case 'tablet':
      case '平板':
        switchToTablet();
        break;
      default:
        _detectDeviceType();
    }
  }
  
  bool get isResponsive => isDesktop.value || isMobile.value || isTablet.value;
  bool get hasLayoutHistory => layoutHistory.isNotEmpty;
  bool get hasDeviceInfo => deviceInfo.isNotEmpty;
  String get screenInfo => '屏幕尺寸: ${screenWidth.value.toStringAsFixed(0)} x ${screenHeight.value.toStringAsFixed(0)}';
  String get aspectRatio => '宽高比: ${(screenWidth.value / screenHeight.value).toStringAsFixed(2)}';
  String get layoutStatus => '当前布局: ${currentLayout.value} (${deviceType.value})';
  int get layoutCount => layoutHistory.length;
  double get screenArea => screenWidth.value * screenHeight.value;
}

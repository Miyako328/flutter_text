import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DebounceThrottleController extends GetxController {
  RxInt normalCount = 0.obs;
  RxInt debounceCount = 0.obs;
  RxInt throttleCount = 0.obs;
  
  RxBool canThrottle = true.obs;
  RxBool isDebouncing = false.obs;
  RxBool isThrottling = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  
  final List<String> actionHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeCounters();
  }
  
  void _initializeCounters() {
    normalCount.value = 0;
    debounceCount.value = 0;
    throttleCount.value = 0;
    canThrottle.value = true;
    statusMessage.value = '准备就绪';
  }
  
  void incrementNormal() {
    normalCount.value++;
    _logAction('基础点击', normalCount.value);
    statusMessage.value = '基础点击: ${normalCount.value}';
  }
  
  void incrementDebounce() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    isDebouncing.value = true;
    statusMessage.value = '防抖中...';
    
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      debounceCount.value++;
      isDebouncing.value = false;
      statusMessage.value = '防抖完成: ${debounceCount.value}';
      _logAction('防抖点击', debounceCount.value);
    });
  }
  
  void incrementThrottle() async {
    if (!canThrottle.value) {
      statusMessage.value = '节流中，请稍候...';
      return;
    }
    
    try {
      canThrottle.value = false;
      isThrottling.value = true;
      statusMessage.value = '节流中...';
      
      await Future.delayed(const Duration(milliseconds: 2000));
      
      throttleCount.value++;
      statusMessage.value = '节流完成: ${throttleCount.value}';
      _logAction('节流点击', throttleCount.value);
      
    } catch (e) {
      statusMessage.value = '节流失败: $e';
      print('Throttle error: $e');
    } finally {
      canThrottle.value = true;
      isThrottling.value = false;
    }
  }
  
  void _logAction(String action, int count) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $action - 计数: $count';
    actionHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (actionHistory.length > 100) {
      actionHistory.removeAt(0);
    }
  }
  
  void resetCounters() {
    _initializeCounters();
    _logAction('重置计数器', 0);
  }
  
  void clearActionHistory() {
    actionHistory.clear();
  }
  
  void setDebounceDelay(Duration delay) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    isDebouncing.value = true;
    statusMessage.value = '防抖中...';
    
    _debounceTimer = Timer(delay, () {
      debounceCount.value++;
      isDebouncing.value = false;
      statusMessage.value = '防抖完成: ${debounceCount.value}';
      _logAction('防抖点击(自定义延迟)', debounceCount.value);
    });
  }
  
  void setThrottleDelay(Duration delay) async {
    if (!canThrottle.value) {
      statusMessage.value = '节流中，请稍候...';
      return;
    }
    
    try {
      canThrottle.value = false;
      isThrottling.value = true;
      statusMessage.value = '节流中...';
      
      await Future.delayed(delay);
      
      throttleCount.value++;
      statusMessage.value = '节流完成: ${throttleCount.value}';
      _logAction('节流点击(自定义延迟)', throttleCount.value);
      
    } catch (e) {
      statusMessage.value = '节流失败: $e';
      print('Custom throttle error: $e');
    } finally {
      canThrottle.value = true;
      isThrottling.value = false;
    }
  }
  
  void cancelDebounce() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
      _debounceTimer = null;
      isDebouncing.value = false;
      statusMessage.value = '防抖已取消';
      _logAction('取消防抖', debounceCount.value);
    }
  }
  
  void cancelThrottle() {
    if (_throttleTimer != null) {
      _throttleTimer!.cancel();
      _throttleTimer = null;
      isThrottling.value = false;
      canThrottle.value = true;
      statusMessage.value = '节流已取消';
      _logAction('取消节流', throttleCount.value);
    }
  }
  
  void rapidFire() {
    // 快速连续点击测试
    for (int i = 0; i < 10; i++) {
      incrementNormal();
      incrementDebounce();
      incrementThrottle();
    }
  }
  
  void testDebounce() {
    // 测试防抖功能
    for (int i = 0; i < 5; i++) {
      incrementDebounce();
    }
  }
  
  void testThrottle() {
    // 测试节流功能
    for (int i = 0; i < 5; i++) {
      incrementThrottle();
    }
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    super.onClose();
  }
  
  bool get canDebounce => !isDebouncing.value;
  bool get canThrottleAction => canThrottle.value && !isThrottling.value;
  bool get hasActionHistory => actionHistory.isNotEmpty;
  bool get isAnyActionActive => isDebouncing.value || isThrottling.value;
  String get normalInfo => '基础点击: ${normalCount.value}';
  String get debounceInfo => '防抖点击: ${debounceCount.value}';
  String get throttleInfo => '节流点击: ${throttleCount.value}';
  String get totalClicks => '总点击: ${normalCount.value + debounceCount.value + throttleCount.value}';
  int get actionCount => actionHistory.length;
  String get statusInfo => '状态: ${statusMessage.value}';
}

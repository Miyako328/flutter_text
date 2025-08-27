import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PageEvent {
  String test;
  PageEvent(this.test);
}

class EventBusController extends GetxController {
  StreamSubscription<PageEvent>? eventBus;
  RxString eventData = ''.obs;
  RxBool isListening = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  final List<String> eventHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeEventBus();
  }
  
  void _initializeEventBus() {
    try {
      // 模拟事件总线初始化
      isListening.value = true;
      statusMessage.value = '事件总线已启动';
      _logEvent('事件总线初始化');
    } catch (e) {
      statusMessage.value = '事件总线启动失败: $e';
      print('Event bus initialization error: $e');
    }
  }
  
  void fireEvent(String data) {
    try {
      final event = PageEvent(data);
      eventData.value = data;
      statusMessage.value = '事件已发送: $data';
      _logEvent('发送事件: $data');
      
      // 模拟事件发送
      _simulateEventReceived(event);
    } catch (e) {
      statusMessage.value = '事件发送失败: $e';
      print('Event fire error: $e');
    }
  }
  
  void _simulateEventReceived(PageEvent event) {
    // 模拟事件接收
    Future.delayed(Duration(milliseconds: 100), () {
      _onEventReceived(event);
    });
  }
  
  void _onEventReceived(PageEvent event) {
    eventData.value = event.test;
    statusMessage.value = '事件已接收: ${event.test}';
    _logEvent('接收事件: ${event.test}');
  }
  
  void clearEventData() {
    eventData.value = '';
    statusMessage.value = '事件数据已清除';
    _logEvent('清除事件数据');
  }
  
  void clearEventHistory() {
    eventHistory.clear();
    statusMessage.value = '事件历史已清除';
  }
  
  void _logEvent(String action) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $action';
    eventHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (eventHistory.length > 100) {
      eventHistory.removeAt(0);
    }
  }
  
  void testEventSequence() {
    // 测试事件序列
    final testEvents = ['测试事件1', '测试事件2', '测试事件3', '测试事件4', '测试事件5'];
    
    for (int i = 0; i < testEvents.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        fireEvent(testEvents[i]);
      });
    }
  }
  
  void sendRandomEvent() {
    final randomData = '随机事件_${DateTime.now().millisecondsSinceEpoch}';
    fireEvent(randomData);
  }
  
  void sendEmptyEvent() {
    fireEvent('');
  }
  
  void sendLongEvent() {
    final longData = '这是一个很长的事件数据，用来测试事件总线的处理能力。'
        '它包含了多个句子和标点符号，以确保事件系统能够正确处理各种类型的数据。';
    fireEvent(longData);
  }
  
  void toggleEventBus() {
    if (isListening.value) {
      isListening.value = false;
      statusMessage.value = '事件总线已停止';
      _logEvent('停止事件总线');
    } else {
      isListening.value = true;
      statusMessage.value = '事件总线已启动';
      _logEvent('启动事件总线');
    }
  }
  
  void resetEventBus() {
    eventData.value = '';
    isListening.value = true;
    statusMessage.value = '事件总线已重置';
    _logEvent('重置事件总线');
  }
  
  @override
  void onClose() {
    eventBus?.cancel();
    super.onClose();
  }
  
  bool get hasEventData => eventData.value.isNotEmpty;
  bool get hasEventHistory => eventHistory.isNotEmpty;
  int get eventCount => eventHistory.length;
  String get currentEventData => eventData.value;
  String get currentStatus => statusMessage.value;
  bool get isEventBusActive => isListening.value;
}

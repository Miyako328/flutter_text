import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Increment extends Intent {}
class Decrement extends Intent {}

class PCKeyboardController extends GetxController {
  RxInt counter = 0.obs;
  RxBool isKeyboardEnabled = true.obs;
  RxString statusMessage = '准备就绪'.obs;
  
  final List<String> keyboardEvents = <String>[].obs;
  final List<LogicalKeyboardKey> pressedKeys = <LogicalKeyboardKey>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  void _initializeController() {
    try {
      statusMessage.value = '键盘控制器已初始化';
      _logKeyboardEvent('控制器初始化');
    } catch (e) {
      statusMessage.value = '控制器初始化失败: $e';
      print('Controller initialization error: $e');
    }
  }
  
  void incrementCounter() {
    try {
      counter.value++;
      statusMessage.value = '计数器增加: ${counter.value}';
      _logKeyboardEvent('计数器增加: ${counter.value}');
    } catch (e) {
      statusMessage.value = '增加计数器失败: $e';
      print('Increment counter error: $e');
    }
  }
  
  void decrementCounter() {
    try {
      counter.value--;
      statusMessage.value = '计数器减少: ${counter.value}';
      _logKeyboardEvent('计数器减少: ${counter.value}');
    } catch (e) {
      statusMessage.value = '减少计数器失败: $e';
      print('Decrement counter error: $e');
    }
  }
  
  void resetCounter() {
    try {
      counter.value = 0;
      statusMessage.value = '计数器已重置';
      _logKeyboardEvent('计数器重置');
    } catch (e) {
      statusMessage.value = '重置计数器失败: $e';
      print('Reset counter error: $e');
    }
  }
  
  void setCounter(int value) {
    try {
      counter.value = value;
      statusMessage.value = '计数器设置为: $value';
      _logKeyboardEvent('计数器设置为: $value');
    } catch (e) {
      statusMessage.value = '设置计数器失败: $e';
      print('Set counter error: $e');
    }
  }
  
  void handleKeyPress(LogicalKeyboardKey key) {
    try {
      if (!pressedKeys.contains(key)) {
        pressedKeys.add(key);
        _logKeyboardEvent('按键按下: ${_getKeyName(key)}');
      }
      
      // 处理特定按键
      switch (key) {
        case LogicalKeyboardKey.arrowUp:
          incrementCounter();
          break;
        case LogicalKeyboardKey.arrowDown:
          decrementCounter();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _handleLeftArrow();
          break;
        case LogicalKeyboardKey.arrowRight:
          _handleRightArrow();
          break;
        case LogicalKeyboardKey.space:
          _handleSpace();
          break;
        case LogicalKeyboardKey.enter:
          _handleEnter();
          break;
        case LogicalKeyboardKey.escape:
          _handleEscape();
          break;
        default:
          _handleOtherKey(key);
          break;
      }
    } catch (e) {
      print('Handle key press error: $e');
    }
  }
  
  void handleKeyRelease(LogicalKeyboardKey key) {
    try {
      pressedKeys.remove(key);
      _logKeyboardEvent('按键释放: ${_getKeyName(key)}');
    } catch (e) {
      print('Handle key release error: $e');
    }
  }
  
  void _handleLeftArrow() {
    try {
      counter.value = (counter.value - 10).clamp(-1000, 1000);
      statusMessage.value = '快速减少: ${counter.value}';
      _logKeyboardEvent('左箭头: 快速减少到 ${counter.value}');
    } catch (e) {
      print('Handle left arrow error: $e');
    }
  }
  
  void _handleRightArrow() {
    try {
      counter.value = (counter.value + 10).clamp(-1000, 1000);
      statusMessage.value = '快速增加: ${counter.value}';
      _logKeyboardEvent('右箭头: 快速增加到 ${counter.value}');
    } catch (e) {
      print('Handle right arrow error: $e');
    }
  }
  
  void _handleSpace() {
    try {
      // 空格键暂停/继续
      isKeyboardEnabled.value = !isKeyboardEnabled.value;
      statusMessage.value = isKeyboardEnabled.value ? '键盘控制已启用' : '键盘控制已禁用';
      _logKeyboardEvent(isKeyboardEnabled.value ? '启用键盘控制' : '禁用键盘控制');
    } catch (e) {
      print('Handle space error: $e');
    }
  }
  
  void _handleEnter() {
    try {
      // 回车键确认当前值
      statusMessage.value = '确认当前值: ${counter.value}';
      _logKeyboardEvent('回车确认: ${counter.value}');
    } catch (e) {
      print('Handle enter error: $e');
    }
  }
  
  void _handleEscape() {
    try {
      // ESC键重置
      resetCounter();
      _logKeyboardEvent('ESC重置计数器');
    } catch (e) {
      print('Handle escape error: $e');
    }
  }
  
  void _handleOtherKey(LogicalKeyboardKey key) {
    try {
      final keyName = _getKeyName(key);
      statusMessage.value = '按下按键: $keyName';
      _logKeyboardEvent('其他按键: $keyName');
    } catch (e) {
      print('Handle other key error: $e');
    }
  }
  
  String _getKeyName(LogicalKeyboardKey key) {
    try {
      if (key == LogicalKeyboardKey.arrowUp) {
        return '↑';
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        return '↓';
      }
      if (key == LogicalKeyboardKey.arrowLeft) {
        return '←';
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        return '→';
      }
      if (key == LogicalKeyboardKey.space) {
        return 'Space';
      }
      if (key == LogicalKeyboardKey.enter) {
        return 'Enter';
      }
      if (key == LogicalKeyboardKey.escape) {
        return 'ESC';
      }
      if (key == LogicalKeyboardKey.keyW) {
        return 'W';
      }
      if (key == LogicalKeyboardKey.keyA) {
        return 'A';
      }
      if (key == LogicalKeyboardKey.keyS) {
        return 'S';
      }
      if (key == LogicalKeyboardKey.keyD) {
        return 'D';
      }
      return key.toString().replaceAll('LogicalKeyboardKey.', '');
    } catch (e) {
      return 'Unknown';
    }
  }
  
  void _logKeyboardEvent(String event) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $event';
    keyboardEvents.add(logEntry);
    
    // 保持事件记录在合理范围内
    if (keyboardEvents.length > 100) {
      keyboardEvents.removeAt(0);
    }
  }
  
  void clearKeyboardEvents() {
    keyboardEvents.clear();
    statusMessage.value = '键盘事件已清除';
  }
  
  void clearPressedKeys() {
    pressedKeys.clear();
    statusMessage.value = '按键状态已清除';
  }
  
  void toggleKeyboardControl() {
    isKeyboardEnabled.value = !isKeyboardEnabled.value;
    statusMessage.value = isKeyboardEnabled.value ? '键盘控制已启用' : '键盘控制已禁用';
    _logKeyboardEvent(isKeyboardEnabled.value ? '手动启用键盘控制' : '手动禁用键盘控制');
  }
  
  void simulateKeyPress(LogicalKeyboardKey key) {
    if (isKeyboardEnabled.value) {
      handleKeyPress(key);
    }
  }
  
  void batchIncrement(int count) {
    try {
      for (int i = 0; i < count; i++) {
        incrementCounter();
      }
      statusMessage.value = '批量增加完成: $count 次';
      _logKeyboardEvent('批量增加: $count 次');
    } catch (e) {
      statusMessage.value = '批量增加失败: $e';
      print('Batch increment error: $e');
    }
  }
  
  void batchDecrement(int count) {
    try {
      for (int i = 0; i < count; i++) {
        decrementCounter();
      }
      statusMessage.value = '批量减少完成: $count 次';
      _logKeyboardEvent('批量减少: $count 次');
    } catch (e) {
      statusMessage.value = '批量减少失败: $e';
      print('Batch decrement error: $e');
    }
  }
  
  @override
  void onClose() {
    keyboardEvents.clear();
    pressedKeys.clear();
    super.onClose();
  }
  
  bool get hasKeyboardEvents => keyboardEvents.isNotEmpty;
  bool get hasPressedKeys => pressedKeys.isNotEmpty;
  bool get isCounterPositive => counter.value > 0;
  bool get isCounterNegative => counter.value < 0;
  bool get isCounterZero => counter.value == 0;
  
  String get counterInfo => '计数器: ${counter.value}';
  String get keyboardStatus => isKeyboardEnabled.value ? '已启用' : '已禁用';
  String get pressedKeysInfo => '已按按键: ${pressedKeys.length} 个';
  int get eventCount => keyboardEvents.length;
  int get pressedKeyCount => pressedKeys.length;
}

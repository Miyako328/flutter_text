import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class MouseTextController extends GetxController {
  RxBool isMouseEntered = false.obs;
  RxBool isMouseHovering = false.obs;
  RxBool isMouseExited = false.obs;
  Rx<Offset> mousePosition = Offset.zero.obs;
  Rx<MouseCursor> currentCursor = SystemMouseCursors.click.obs;
  RxBool isOpaque = false.obs;
  
  final List<PointerEvent> mouseEvents = <PointerEvent>[].obs;
  final List<String> eventLog = <String>[].obs;
  
  final List<MouseCursor> availableCursors = [
    SystemMouseCursors.click,
    SystemMouseCursors.basic,
    SystemMouseCursors.forbidden,
    SystemMouseCursors.wait,
    SystemMouseCursors.progress,
    SystemMouseCursors.contextMenu,
    SystemMouseCursors.help,
    SystemMouseCursors.text,
    SystemMouseCursors.verticalText,
    SystemMouseCursors.cell,
    SystemMouseCursors.precise,
    SystemMouseCursors.move,
    SystemMouseCursors.grab,
    SystemMouseCursors.grabbing,
    SystemMouseCursors.noDrop,
    SystemMouseCursors.alias,
    SystemMouseCursors.copy,
    SystemMouseCursors.disappearing,
    SystemMouseCursors.allScroll,
    SystemMouseCursors.zoomIn,
    SystemMouseCursors.zoomOut,
  ];
  
  void onMouseEnter(PointerEnterEvent event) {
    isMouseEntered.value = true;
    isMouseHovering.value = false;
    isMouseExited.value = false;
    mousePosition.value = event.position;
    
    _logEvent('Mouse Enter', event);
    print('onEnter: $event');
  }
  
  void onMouseHover(PointerHoverEvent event) {
    isMouseHovering.value = true;
    mousePosition.value = event.position;
    
    _logEvent('Mouse Hover', event);
    print('onHover: $event');
  }
  
  void onMouseExit(PointerExitEvent event) {
    isMouseEntered.value = false;
    isMouseHovering.value = false;
    isMouseExited.value = true;
    mousePosition.value = event.position;
    
    _logEvent('Mouse Exit', event);
    print('onExit: $event');
  }
  
  void _logEvent(String eventType, PointerEvent event) {
    final timestamp = DateTime.now().toString();
    final eventInfo = '$timestamp: $eventType at ${event.position}';
    
    eventLog.add(eventInfo);
    mouseEvents.add(event);
    
    // 保持日志数量在合理范围内
    if (eventLog.length > 100) {
      eventLog.removeAt(0);
      mouseEvents.removeAt(0);
    }
  }
  
  void changeCursor(MouseCursor cursor) {
    currentCursor.value = cursor;
  }
  
  void cycleCursors() {
    final currentIndex = availableCursors.indexOf(currentCursor.value);
    final nextIndex = (currentIndex + 1) % availableCursors.length;
    currentCursor.value = availableCursors[nextIndex];
  }
  
  void toggleOpaque() {
    isOpaque.value = !isOpaque.value;
  }
  
  void setOpaque(bool opaque) {
    isOpaque.value = opaque;
  }
  
  void clearEventLog() {
    eventLog.clear();
    mouseEvents.clear();
  }
  
  void resetMouseState() {
    isMouseEntered.value = false;
    isMouseHovering.value = false;
    isMouseExited.value = false;
    mousePosition.value = Offset.zero;
  }
  
  void resetToDefaults() {
    currentCursor.value = SystemMouseCursors.click;
    isOpaque.value = false;
    resetMouseState();
    clearEventLog();
  }
  
  void randomizeCursor() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final cursorIndex = random % availableCursors.length;
    currentCursor.value = availableCursors[cursorIndex];
  }
  
  bool get isMouseActive => isMouseEntered.value || isMouseHovering.value;
  bool get hasMouseEvents => mouseEvents.isNotEmpty;
  bool get hasEventLog => eventLog.isNotEmpty;
  String get mouseStatus => isMouseEntered.value 
      ? '鼠标已进入' 
      : isMouseHovering.value 
          ? '鼠标悬停中' 
          : isMouseExited.value 
              ? '鼠标已退出' 
              : '等待鼠标';
  String get cursorName => currentCursor.value.toString().split('.').last;
  String get positionText => '位置: (${mousePosition.value.dx.toStringAsFixed(1)}, ${mousePosition.value.dy.toStringAsFixed(1)})';
  int get eventCount => mouseEvents.length;
}

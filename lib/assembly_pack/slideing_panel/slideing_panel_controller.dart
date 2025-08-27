import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SlideingPanelController extends GetxController {
  RxBool isPanelOpen = false.obs;
  RxBool isPanelMoving = false.obs;
  RxDouble panelPosition = 0.0.obs;
  RxDouble offsetDistance = 0.0.obs;
  RxDouble offsetXDistance = 0.0.obs;
  RxDouble offsetY = 0.0.obs;
  RxDouble offsetX = 0.0.obs;
  RxString slideDirection = 'none'.obs;
  RxString panelStatus = '关闭'.obs;
  
  final List<String> slideHistory = <String>[].obs;
  
  // 面板配置
  RxDouble minWidth = 0.0.obs;
  RxDouble maxWidth = 250.0.obs;
  RxDouble minHeight = 0.0.obs;
  RxDouble maxHeight = 300.0.obs;
  Rx<SlideDirection> slideDirectionEnum = SlideDirection.UP.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializePanel();
  }
  
  void _initializePanel() {
    panelPosition.value = 0.0;
    isPanelOpen.value = false;
    panelStatus.value = '关闭';
    slideDirection.value = 'none';
  }
  
  void openPanel() {
    try {
      isPanelMoving.value = true;
      panelStatus.value = '正在打开...';
      
      // 模拟面板打开动画
      _animatePanel(0.0, 1.0, () {
        isPanelOpen.value = true;
        panelStatus.value = '已打开';
        _logSlideAction('打开面板');
      });
      
    } catch (e) {
      panelStatus.value = '打开失败: $e';
      print('Open panel error: $e');
    }
  }
  
  void closePanel() {
    try {
      isPanelMoving.value = true;
      panelStatus.value = '正在关闭...';
      
      // 模拟面板关闭动画
      _animatePanel(1.0, 0.0, () {
        isPanelOpen.value = false;
        panelStatus.value = '已关闭';
        _logSlideAction('关闭面板');
      });
      
    } catch (e) {
      panelStatus.value = '关闭失败: $e';
      print('Close panel error: $e');
    }
  }
  
  void _animatePanel(double from, double to, VoidCallback onComplete) {
    // 模拟动画过程
    const duration = Duration(milliseconds: 300);
    const steps = 30;
    final stepValue = (to - from) / steps;
    
    int currentStep = 0;
    
    Timer.periodic(Duration(milliseconds: duration.inMilliseconds ~/ steps), (timer) {
      if (currentStep < steps) {
        panelPosition.value = from + (stepValue * currentStep);
        currentStep++;
      } else {
        panelPosition.value = to;
        timer.cancel();
        isPanelMoving.value = false;
        onComplete();
      }
    });
  }
  
  void setPanelPosition(double position) {
    if (position >= 0.0 && position <= 1.0) {
      panelPosition.value = position;
      
      if (position > 0.5) {
        isPanelOpen.value = true;
        panelStatus.value = '已打开';
      } else {
        isPanelOpen.value = false;
        panelStatus.value = '已关闭';
      }
    }
  }
  
  void onHorizontalDragDown(DragDownDetails details) {
    offsetXDistance.value = details.globalPosition.dx;
    _logSlideAction('水平拖拽开始: ${details.globalPosition.dx}');
  }
  
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    offsetX.value = details.globalPosition.dx - offsetXDistance.value;
    
    if (offsetX.value > 0) {
      slideDirection.value = '向左';
      print("向左${offsetX.value}");
    } else {
      slideDirection.value = '向右';
      print("向右${offsetX.value}");
      
      double position = offsetX.value.abs() / 300;
      position = position > 1 ? 1 : position;
      setPanelPosition(position);
      
      if (position > 0.4) {
        openPanel();
      }
    }
    
    _logSlideAction('水平拖拽: ${slideDirection.value} ${offsetX.value.abs().toStringAsFixed(2)}');
  }
  
  void onVerticalDragDown(DragDownDetails details) {
    offsetDistance.value = details.globalPosition.dy;
    _logSlideAction('垂直拖拽开始: ${details.globalPosition.dy}');
  }
  
  void onVerticalDragUpdate(DragUpdateDetails details) {
    offsetY.value = details.globalPosition.dy - offsetDistance.value;
    
    if (offsetY.value > 0) {
      slideDirection.value = '向下';
      print("向下${offsetY.value}");
    } else {
      slideDirection.value = '向上';
      print("向上${offsetY.value}");
      
      double position = offsetY.value.abs() / 300;
      position = position > 1 ? 1 : position;
      setPanelPosition(position);
      
      if (position > 0.4) {
        openPanel();
      }
    }
    
    _logSlideAction('垂直拖拽: ${slideDirection.value} ${offsetY.value.abs().toStringAsFixed(2)}');
  }
  
  void onTap() {
    if (isPanelOpen.value) {
      closePanel();
    } else {
      openPanel();
    }
  }
  
  void _logSlideAction(String action) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $action';
    slideHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (slideHistory.length > 100) {
      slideHistory.removeAt(0);
    }
  }
  
  void togglePanel() {
    if (isPanelOpen.value) {
      closePanel();
    } else {
      openPanel();
    }
  }
  
  void setSlideDirection(SlideDirection direction) {
    slideDirectionEnum.value = direction;
    slideDirection.value = direction.toString().split('.').last;
  }
  
  void setPanelDimensions(double minW, double maxW, double minH, double maxH) {
    minWidth.value = minW;
    maxWidth.value = maxW;
    minHeight.value = minH;
    maxHeight.value = maxH;
  }
  
  void resetPanel() {
    _initializePanel();
    slideHistory.clear();
  }
  
  void clearSlideHistory() {
    slideHistory.clear();
  }
  
  void setCustomPanelPosition(double position) {
    setPanelPosition(position);
  }
  
  void snapToPosition(double position) {
    if (position >= 0.0 && position <= 1.0) {
      panelPosition.value = position;
      
      if (position > 0.5) {
        isPanelOpen.value = true;
        panelStatus.value = '已打开';
      } else {
        isPanelOpen.value = false;
        panelStatus.value = '已关闭';
      }
      
      _logSlideAction('快速定位到: ${position.toStringAsFixed(2)}');
    }
  }
  
  bool get canMove => !isPanelMoving.value;
  bool get hasSlideHistory => slideHistory.isNotEmpty;
  bool get isFullyOpen => panelPosition.value >= 1.0;
  bool get isFullyClosed => panelPosition.value <= 0.0;
  bool get isPartiallyOpen => panelPosition.value > 0.0 && panelPosition.value < 1.0;
  String get panelPositionText => '面板位置: ${(panelPosition.value * 100).toStringAsFixed(1)}%';
  String get slideDirectionInfo => '滑动方向: ${slideDirection.value}';
  String get panelStatusInfo => '面板状态: ${panelStatus.value}';
  String get dimensionsInfo => '尺寸: ${minWidth.value}x${minHeight.value} - ${maxWidth.value}x${maxHeight.value}';
  int get slideCount => slideHistory.length;
  double get currentOffset => offsetX.value.abs() + offsetY.value.abs();
}

enum SlideDirection {
  UP,
  DOWN,
  LEFT,
  RIGHT,
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OtaUpdateController extends GetxController {
  RxString updateText = ''.obs;
  RxBool isUpdating = false.obs;
  RxBool isLocked = false.obs;
  RxString statusMessage = '准备更新'.obs;
  RxDouble progress = 0.0.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;
  
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  final List<String> updateHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
  }
  
  void _onTextChanged() {
    updateText.value = textController.text;
  }
  
  void startUpdate() {
    if (updateText.value.isEmpty) {
      setError('请输入更新内容');
      return;
    }
    
    try {
      isUpdating.value = true;
      hasError.value = false;
      errorMessage.value = '';
      statusMessage.value = '正在更新...';
      progress.value = 0.0;
      
      // 模拟更新过程
      _simulateUpdate();
      
    } catch (e) {
      setError('更新失败: $e');
    }
  }
  
  void _simulateUpdate() {
    const updateSteps = [
      {'step': '检查更新', 'progress': 0.1},
      {'step': '下载更新包', 'progress': 0.3},
      {'step': '验证更新包', 'progress': 0.5},
      {'step': '安装更新', 'progress': 0.8},
      {'step': '完成更新', 'progress': 1.0},
    ];
    
    int currentStep = 0;
    
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (currentStep < updateSteps.length) {
        final step = updateSteps[currentStep];
        statusMessage.value = step['step'] as String;
        progress.value = step['progress'] as double;
        currentStep++;
      } else {
        timer.cancel();
        _completeUpdate();
      }
    });
  }
  
  void _completeUpdate() {
    isUpdating.value = false;
    statusMessage.value = '更新完成';
    progress.value = 1.0;
    
    // 添加到更新历史
    updateHistory.add('${DateTime.now().toString()}: ${updateText.value}');
    
    // 清空输入
    textController.clear();
    updateText.value = '';
    
    print('OTA update completed successfully');
  }
  
  void cancelUpdate() {
    isUpdating.value = false;
    statusMessage.value = '更新已取消';
    progress.value = 0.0;
  }
  
  void setError(String error) {
    hasError.value = true;
    errorMessage.value = error;
    statusMessage.value = '更新失败';
    isUpdating.value = false;
  }
  
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }
  
  void toggleLock() {
    isLocked.value = !isLocked.value;
    if (isLocked.value) {
      textController.clear();
      updateText.value = '';
    }
  }
  
  void resetUpdate() {
    isUpdating.value = false;
    hasError.value = false;
    errorMessage.value = '';
    statusMessage.value = '准备更新';
    progress.value = 0.0;
    textController.clear();
    updateText.value = '';
  }
  
  void clearHistory() {
    updateHistory.clear();
  }
  
  void saveUpdateText() {
    if (formKey.currentState?.validate() == true) {
      formKey.currentState?.save();
      print('Update text saved: ${updateText.value}');
    }
  }
  
  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
  
  bool get canUpdate => !isUpdating.value && updateText.value.isNotEmpty && !isLocked.value;
  bool get isUpdateComplete => progress.value >= 1.0;
  bool get hasUpdateHistory => updateHistory.isNotEmpty;
  String get progressText => '${(progress.value * 100).toInt()}%';
}

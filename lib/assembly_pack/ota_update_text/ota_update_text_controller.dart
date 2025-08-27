import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/widget/text_input_lock.dart';

class OtaUpdateTextController extends GetxController {
  final TextEditingController textController = TextEditingController();
  RxBool isLocked = false.obs;
  RxBool isUpdating = false.obs;
  RxString updateStatus = '准备就绪'.obs;
  RxString currentText = ''.obs;
  RxBool showPreview = false.obs;

  @override
  void onInit() {
    super.onInit();
    textController.text = 'OTA更新文本示例';
    currentText.value = textController.text;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void toggleLock() {
    isLocked.value = !isLocked.value;
    if (isLocked.value) {
      updateStatus.value = '文本已锁定';
    } else {
      updateStatus.value = '文本已解锁';
    }
  }

  void updateText(String newText) {
    if (!isLocked.value) {
      currentText.value = newText;
      textController.text = newText;
      updateStatus.value = '文本已更新';
    } else {
      updateStatus.value = '文本已锁定，无法更新';
    }
  }

  void startUpdate() async {
    if (isUpdating.value) return;
    
    try {
      isUpdating.value = true;
      updateStatus.value = '正在更新...';
      
      // 模拟OTA更新过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟更新成功
      updateStatus.value = '更新完成';
      showPreview.value = true;
      
      Get.snackbar(
        '更新成功',
        'OTA更新已完成',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      updateStatus.value = '更新失败: $e';
      Get.snackbar(
        '更新失败',
        'OTA更新过程中发生错误',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void resetText() {
    if (!isLocked.value) {
      textController.text = 'OTA更新文本示例';
      currentText.value = textController.text;
      updateStatus.value = '文本已重置';
      showPreview.value = false;
    } else {
      updateStatus.value = '文本已锁定，无法重置';
    }
  }

  void clearStatus() {
    updateStatus.value = '准备就绪';
  }

  bool get canEdit => !isLocked.value;
  bool get hasText => currentText.value.isNotEmpty;
  String get lockStatus => isLocked.value ? '已锁定' : '未锁定';
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/widget/float_box.dart';

class OverlayDemoController extends GetxController {
  OverlayEntry? entry;
  RxBool isOverlayVisible = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  RxBool canShowOverlay = true.obs;

  @override
  void onInit() {
    super.onInit();
    statusMessage.value = '准备就绪';
  }

  @override
  void onClose() {
    _removeOverlay();
    super.onClose();
  }

  void showOverlay() {
    if (!canShowOverlay.value) {
      statusMessage.value = '悬浮按钮已显示';
      return;
    }

    try {
      // 先移除现有的悬浮按钮
      _removeOverlay();
      
      // 创建新的悬浮按钮
      entry = OverlayEntry(
        builder: (context) => const FloatBox(),
      );
      
      // 插入到Overlay中
      final overlay = Overlay.of(Get.context!);
      if (overlay != null) {
        overlay.insert(entry!);
        isOverlayVisible.value = true;
        canShowOverlay.value = false;
        statusMessage.value = '悬浮按钮已显示';
        
        Get.snackbar(
          '成功',
          '悬浮按钮已开启',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        statusMessage.value = '无法获取Overlay上下文';
      }
    } catch (e) {
      statusMessage.value = '显示悬浮按钮失败: $e';
      Get.snackbar(
        '错误',
        '显示悬浮按钮失败',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void hideOverlay() {
    if (!isOverlayVisible.value) {
      statusMessage.value = '悬浮按钮未显示';
      return;
    }

    try {
      _removeOverlay();
      isOverlayVisible.value = false;
      canShowOverlay.value = true;
      statusMessage.value = '悬浮按钮已隐藏';
      
      Get.snackbar(
        '成功',
        '悬浮按钮已关闭',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      statusMessage.value = '隐藏悬浮按钮失败: $e';
      Get.snackbar(
        '错误',
        '隐藏悬浮按钮失败',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _removeOverlay() {
    if (entry != null) {
      try {
        entry!.remove();
        entry = null;
      } catch (e) {
        print('移除Overlay时发生错误: $e');
      }
    }
  }

  void toggleOverlay() {
    if (isOverlayVisible.value) {
      hideOverlay();
    } else {
      showOverlay();
    }
  }

  void resetStatus() {
    statusMessage.value = '准备就绪';
  }

  bool get hasActiveOverlay => entry != null && isOverlayVisible.value;
  String get currentStatus => isOverlayVisible.value ? '已显示' : '已隐藏';
}

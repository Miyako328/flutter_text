import 'package:get/get.dart';
import 'package:flutter/material.dart';

class WidgetToJsonController extends GetxController {
  RxBool isExpanded = false.obs;
  RxBool showBorder = false.obs;
  Rx<Color> textColor = Colors.black.obs;
  Rx<Color> backgroundColor = Colors.transparent.obs;
  RxString exportResult = ''.obs;
  RxBool hasExported = false.obs;

  final TextEditingController textController = TextEditingController();
  final GlobalKey exportKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    textController.text = 'Widget to json text';
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  void toggleBorder() {
    showBorder.value = !showBorder.value;
  }

  void changeTextColor(Color color) {
    textColor.value = color;
  }

  void changeBackgroundColor(Color color) {
    backgroundColor.value = color;
  }

  void updateText(String text) {
    textController.text = text;
  }

  void exportWidget() {
    try {
      // 模拟导出功能
      final String jsonData = '''
{
  "type": "Container",
  "child": {
    "type": "Text",
    "data": "${textController.text}",
    "style": {
      "color": "${textColor.value.value.toRadixString(16)}",
      "fontSize": 20
    }
  },
  "decoration": ${showBorder.value ? '{"border": {"color": "grey", "width": 1}}' : 'null'}
}
      '''.trim();
      
      exportResult.value = jsonData;
      hasExported.value = true;
      
      // 显示成功消息
      Get.snackbar(
        '导出成功',
        'Widget已导出为JSON格式',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      exportResult.value = '导出失败: $e';
      hasExported.value = true;
      
      Get.snackbar(
        '导出失败',
        '导出过程中发生错误',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearExport() {
    exportResult.value = '';
    hasExported.value = false;
  }

  void resetToDefault() {
    isExpanded.value = false;
    showBorder.value = false;
    textColor.value = Colors.black;
    backgroundColor.value = Colors.transparent;
    textController.text = 'Widget to json text';
    clearExport();
  }
}

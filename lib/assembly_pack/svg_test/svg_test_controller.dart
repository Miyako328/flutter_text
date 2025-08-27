import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SvgTestController extends GetxController {
  RxDouble svgWidth = 200.0.obs;
  RxDouble svgHeight = 200.0.obs;
  RxString svgPath = 'assets/relaxation.svg'.obs;
  RxBool showBorder = false.obs;
  RxBool showBackground = false.obs;
  Rx<Color> backgroundColor = Colors.transparent.obs;
  Rx<Color> borderColor = Colors.grey.obs;
  RxDouble borderWidth = 1.0.obs;

  final List<String> availableSvgs = [
    'assets/relaxation.svg',
    'assets/icon.svg',
    'assets/logo.svg',
  ];

  void changeSvgSize(double width, double height) {
    svgWidth.value = width;
    svgHeight.value = height;
  }

  void toggleBorder() {
    showBorder.value = !showBorder.value;
  }

  void toggleBackground() {
    showBackground.value = !showBackground.value;
    if (showBackground.value) {
      backgroundColor.value = Colors.grey[200]!;
    } else {
      backgroundColor.value = Colors.transparent;
    }
  }

  void changeBorderColor(Color color) {
    borderColor.value = color;
  }

  void changeBorderWidth(double width) {
    borderWidth.value = width;
  }

  void changeSvgPath(String path) {
    svgPath.value = path;
  }

  void resetToDefault() {
    svgWidth.value = 200.0;
    svgHeight.value = 200.0;
    svgPath.value = 'assets/relaxation.svg';
    showBorder.value = false;
    showBackground.value = false;
    backgroundColor.value = Colors.transparent;
    borderColor.value = Colors.grey;
    borderWidth.value = 1.0;
  }
}

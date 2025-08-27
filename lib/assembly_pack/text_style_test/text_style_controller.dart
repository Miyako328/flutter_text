import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TextStyleController extends GetxController {
  RxDouble fontSize = 50.0.obs;
  RxDouble textHeight = 1.0.obs;
  RxDouble leading = 0.0.obs;
  RxBool forceStrutHeight = true.obs;
  Rx<Color> containerColor = Colors.red.obs;
  RxString displayText = 'AgB'.obs;
  
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];
  
  void changeFontSize(double size) {
    fontSize.value = size;
  }
  
  void changeTextHeight(double height) {
    textHeight.value = height;
  }
  
  void changeLeading(double value) {
    leading.value = value;
  }
  
  void toggleForceStrutHeight() {
    forceStrutHeight.value = !forceStrutHeight.value;
  }
  
  void changeContainerColor(Color color) {
    containerColor.value = color;
  }
  
  void changeDisplayText(String text) {
    displayText.value = text;
  }
  
  void resetToDefaults() {
    fontSize.value = 50.0;
    textHeight.value = 1.0;
    leading.value = 0.0;
    forceStrutHeight.value = true;
    containerColor.value = Colors.red;
    displayText.value = 'AgB';
  }
  
  void cycleColors() {
    final currentIndex = availableColors.indexOf(containerColor.value);
    final nextIndex = (currentIndex + 1) % availableColors.length;
    containerColor.value = availableColors[nextIndex];
  }
  
  TextStyle get currentTextStyle => TextStyle(
    fontSize: fontSize.value,
    height: textHeight.value,
  );
  
  StrutStyle get currentStrutStyle => StrutStyle(
    forceStrutHeight: forceStrutHeight.value,
    fontSize: fontSize.value,
    height: textHeight.value,
    leading: leading.value,
  );
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RaisedButtonController extends GetxController {
  RxString buttonText = 'Hello World'.obs;
  RxDouble fontSize = 26.0.obs;
  Rx<Color> buttonColor = Colors.blue.obs;
  Rx<Color> textColor = Colors.white.obs;
  RxBool isEnabled = true.obs;
  RxBool isPressed = false.obs;
  RxInt pressCount = 0.obs;
  
  final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];
  
  final List<String> availableTexts = [
    'Hello World',
    'Click Me',
    'Press Here',
    'Tap This',
    'Button',
    'Submit',
    'OK',
    'Cancel',
    'Confirm',
    'Next',
  ];
  
  void onButtonPressed() {
    isPressed.value = true;
    pressCount.value++;
    print('按钮按下操作 - 第${pressCount.value}次');
    
    // 重置按下状态
    Future.delayed(Duration(milliseconds: 200), () {
      isPressed.value = false;
    });
  }
  
  void changeButtonText(String newText) {
    buttonText.value = newText;
  }
  
  void changeFontSize(double size) {
    fontSize.value = size;
  }
  
  void changeButtonColor(Color color) {
    buttonColor.value = color;
  }
  
  void changeTextColor(Color color) {
    textColor.value = color;
  }
  
  void toggleEnabled() {
    isEnabled.value = !isEnabled.value;
  }
  
  void cycleColors() {
    final currentIndex = availableColors.indexOf(buttonColor.value);
    final nextIndex = (currentIndex + 1) % availableColors.length;
    buttonColor.value = availableColors[nextIndex];
  }
  
  void cycleTexts() {
    final currentIndex = availableTexts.indexOf(buttonText.value);
    final nextIndex = (currentIndex + 1) % availableTexts.length;
    buttonText.value = availableTexts[nextIndex];
  }
  
  void resetToDefaults() {
    buttonText.value = 'Hello World';
    fontSize.value = 26.0;
    buttonColor.value = Colors.blue;
    textColor.value = Colors.white;
    isEnabled.value = true;
    isPressed.value = false;
    pressCount.value = 0;
  }
  
  void randomizeButton() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final colorIndex = random % availableColors.length;
    final textIndex = random % availableTexts.length;
    
    buttonColor.value = availableColors[colorIndex];
    buttonText.value = availableTexts[textIndex];
    fontSize.value = 20.0 + (random % 20); // 20-40之间的字体大小
  }
  
  TextStyle get currentTextStyle => TextStyle(
    fontSize: fontSize.value,
    color: textColor.value,
  );
  
  Color get currentButtonColor => isEnabled.value ? buttonColor.value : Colors.grey;
  
  bool get hasBeenPressed => pressCount.value > 0;
  String get pressCountText => '已按下 $pressCount 次';
}

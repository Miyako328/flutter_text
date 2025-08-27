import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TextInputUpDownController extends GetxController {
  RxInt currentValue = 0.obs;
  RxInt minValue = 0.obs;
  RxInt maxValue = 100.obs;
  RxInt stepValue = 1.obs;
  RxBool isEnabled = true.obs;
  RxBool isReadOnly = false.obs;
  RxString inputText = '0'.obs;
  RxBool isValid = true.obs;
  RxString validationMessage = ''.obs;
  
  final TextEditingController textController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    textController.text = currentValue.value.toString();
    textController.addListener(_onTextChanged);
  }
  
  void _onTextChanged() {
    inputText.value = textController.text;
    _validateInput();
  }
  
  void _validateInput() {
    if (inputText.value.isEmpty) {
      isValid.value = false;
      validationMessage.value = '请输入数值';
      return;
    }
    
    try {
      final int value = int.parse(inputText.value);
      if (value < minValue.value) {
        isValid.value = false;
        validationMessage.value = '数值不能小于${minValue.value}';
      } else if (value > maxValue.value) {
        isValid.value = false;
        validationMessage.value = '数值不能大于${maxValue.value}';
      } else {
        isValid.value = true;
        validationMessage.value = '';
        currentValue.value = value;
      }
    } catch (e) {
      isValid.value = false;
      validationMessage.value = '请输入有效的整数';
    }
  }
  
  void increment() {
    if (isEnabled.value && !isReadOnly.value) {
      final newValue = currentValue.value + stepValue.value;
      if (newValue <= maxValue.value) {
        currentValue.value = newValue;
        textController.text = newValue.toString();
        inputText.value = newValue.toString();
        isValid.value = true;
        validationMessage.value = '';
      }
    }
  }
  
  void decrement() {
    if (isEnabled.value && !isReadOnly.value) {
      final newValue = currentValue.value - stepValue.value;
      if (newValue >= minValue.value) {
        currentValue.value = newValue;
        textController.text = newValue.toString();
        inputText.value = newValue.toString();
        isValid.value = true;
        validationMessage.value = '';
      }
    }
  }
  
  void setValue(int value) {
    if (value >= minValue.value && value <= maxValue.value) {
      currentValue.value = value;
      textController.text = value.toString();
      inputText.value = value.toString();
      isValid.value = true;
      validationMessage.value = '';
    }
  }
  
  void setMinValue(int min) {
    minValue.value = min;
    if (currentValue.value < min) {
      setValue(min);
    }
  }
  
  void setMaxValue(int max) {
    maxValue.value = max;
    if (currentValue.value > max) {
      setValue(max);
    }
  }
  
  void setStepValue(int step) {
    if (step > 0) {
      stepValue.value = step;
    }
  }
  
  void toggleEnabled() {
    isEnabled.value = !isEnabled.value;
  }
  
  void toggleReadOnly() {
    isReadOnly.value = !isReadOnly.value;
  }
  
  void resetToMin() {
    setValue(minValue.value);
  }
  
  void resetToMax() {
    setValue(maxValue.value);
  }
  
  void resetToZero() {
    setValue(0);
  }
  
  void resetToDefaults() {
    minValue.value = 0;
    maxValue.value = 100;
    stepValue.value = 1;
    currentValue.value = 0;
    isEnabled.value = true;
    isReadOnly.value = false;
    textController.text = '0';
    inputText.value = '0';
    isValid.value = true;
    validationMessage.value = '';
  }
  
  void randomizeValue() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final randomValue = minValue.value + (random % (maxValue.value - minValue.value + 1));
    setValue(randomValue);
  }
  
  void clearInput() {
    textController.clear();
    inputText.value = '';
    isValid.value = false;
    validationMessage.value = '请输入数值';
  }
  
  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
  
  bool get canIncrement => isEnabled.value && !isReadOnly.value && currentValue.value < maxValue.value;
  bool get canDecrement => isEnabled.value && !isReadOnly.value && currentValue.value > minValue.value;
  bool get isAtMin => currentValue.value == minValue.value;
  bool get isAtMax => currentValue.value == maxValue.value;
  bool get hasInput => inputText.value.isNotEmpty;
  String get valueText => currentValue.value.toString();
  String get rangeText => '范围: ${minValue.value} - ${maxValue.value}';
  String get stepText => '步长: ${stepValue.value}';
  double get progressPercentage => (currentValue.value - minValue.value) / (maxValue.value - minValue.value);
}

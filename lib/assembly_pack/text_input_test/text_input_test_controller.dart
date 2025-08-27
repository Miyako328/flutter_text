import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputTestController extends GetxController {
  final TextEditingController controller = TextEditingController();
  
  RxString inputText = ''.obs;
  RxString formattedText = ''.obs;
  RxBool isValid = true.obs;
  RxString validationMessage = ''.obs;
  RxBool isFocused = false.obs;
  RxInt maxLength = 100.obs;
  RxInt decimalMaxLength = 4.obs;
  RxInt integerMaxLength = 3.obs;
  
  final List<TextInputFormatter> formatters = <TextInputFormatter>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    controller.addListener(_onTextChanged);
    _setupFormatters();
  }
  
  void _setupFormatters() {
    // 设置价格输入格式化器
    formatters.addAll([
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      LengthLimitingTextInputFormatter(maxLength.value),
    ]);
  }
  
  void _onTextChanged() {
    inputText.value = controller.text;
    _formatText();
    _validateInput();
  }
  
  void _formatText() {
    if (inputText.value.isEmpty) {
      formattedText.value = '';
      return;
    }
    
    try {
      // 模拟价格格式化
      final double? value = double.tryParse(inputText.value);
      if (value != null) {
        formattedText.value = '¥${value.toStringAsFixed(2)}';
      } else {
        formattedText.value = inputText.value;
      }
    } catch (e) {
      formattedText.value = inputText.value;
    }
  }
  
  void _validateInput() {
    if (inputText.value.isEmpty) {
      isValid.value = true;
      validationMessage.value = '';
      return;
    }
    
    try {
      final double? value = double.tryParse(inputText.value);
      if (value == null) {
        isValid.value = false;
        validationMessage.value = '请输入有效的数字';
      } else if (value < 0) {
        isValid.value = false;
        validationMessage.value = '价格不能为负数';
      } else if (value > 999999) {
        isValid.value = false;
        validationMessage.value = '价格超出范围';
      } else {
        isValid.value = true;
        validationMessage.value = '输入有效';
      }
    } catch (e) {
      isValid.value = false;
      validationMessage.value = '格式错误';
    }
  }
  
  void setText(String text) {
    controller.text = text;
  }
  
  void clearText() {
    controller.clear();
    inputText.value = '';
    formattedText.value = '';
    isValid.value = true;
    validationMessage.value = '';
  }
  
  void setMaxLength(int length) {
    maxLength.value = length;
    _setupFormatters();
  }
  
  void setDecimalMaxLength(int length) {
    decimalMaxLength.value = length;
  }
  
  void setIntegerMaxLength(int length) {
    integerMaxLength.value = length;
  }
  
  void addFormatter(TextInputFormatter formatter) {
    formatters.add(formatter);
  }
  
  void removeFormatter(int index) {
    if (index >= 0 && index < formatters.length) {
      formatters.removeAt(index);
    }
  }
  
  void clearFormatters() {
    formatters.clear();
  }
  
  void resetFormatters() {
    _setupFormatters();
  }
  
  void setFocus(bool focused) {
    isFocused.value = focused;
  }
  
  void formatAsCurrency() {
    if (inputText.value.isNotEmpty) {
      try {
        final double? value = double.tryParse(inputText.value);
        if (value != null) {
          formattedText.value = '¥${value.toStringAsFixed(2)}';
        }
      } catch (e) {
        print('Currency formatting error: $e');
      }
    }
  }
  
  void formatAsPercentage() {
    if (inputText.value.isNotEmpty) {
      try {
        final double? value = double.tryParse(inputText.value);
        if (value != null) {
          formattedText.value = '${(value * 100).toStringAsFixed(2)}%';
        }
      } catch (e) {
        print('Percentage formatting error: $e');
      }
    }
  }
  
  void resetToDefaults() {
    maxLength.value = 100;
    decimalMaxLength.value = 4;
    integerMaxLength.value = 3;
    clearText();
    resetFormatters();
  }
  
  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
  
  bool get hasText => inputText.value.isNotEmpty;
  bool get hasFormattedText => formattedText.value.isNotEmpty;
  bool get isInputValid => isValid.value;
  String get displayText => formattedText.value.isNotEmpty ? formattedText.value : inputText.value;
  int get textLength => inputText.value.length;
  double get textValue {
    try {
      return double.tryParse(inputText.value) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

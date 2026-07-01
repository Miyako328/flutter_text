import 'dart:io';

import 'package:flutter/material.dart';
import 'keyboard_controller.dart';
import 'keyboard_list/number.dart';
import 'keyboard_list/text.dart';
import 'keyboard_manager.dart';

typedef KeyboardSwitch = Function(SecurityKeyboardType type);

enum SecurityKeyboardType { text, number }

extension SecurityKeyboardTypeTxt on SecurityKeyboardType {
  String get enumToString {
    switch (this) {
      case SecurityKeyboardType.number:
        return 'SecurityKeyboardTypeNumber';
        break;
      case SecurityKeyboardType.text:
        return 'SecurityKeyboardTypeText';
        break;
    }
  }
}

class SecurityKeyboardCenter {
  static SecurityTextInputType number =
      SecurityTextInputType(name: SecurityKeyboardType.number.enumToString);

  static SecurityTextInputType text =
      SecurityTextInputType(name: SecurityKeyboardType.text.enumToString);

  static void register() {
    if (Platform.isWindows || Platform.isMacOS) {
      return;
    }
    KeyboardManager.addKeyboard(
      SecurityKeyboardCenter.number,
      KeyboardConfig(
          builder: (context, controller, params) {
            return SecurityKeyboard(
              controller: controller,
              type: SecurityKeyboardType.number,
            );
          },
          getHeight: SecurityKeyboard.getHeight),
    );
    KeyboardManager.addKeyboard(
      SecurityKeyboardCenter.text,
      KeyboardConfig(
          builder: (context, controller, params) {
            return SecurityKeyboard(
              controller: controller,
              type: SecurityKeyboardType.text,
            );
          },
          getHeight: SecurityKeyboard.getHeight),
    );
  }
}

class SecurityKeyboard extends StatelessWidget {
  static double getHeight(BuildContext ctx) {
    final MediaQueryData mediaQuery = MediaQuery.of(ctx);
    return mediaQuery.size.width / 3 / 2 * 4;
  }

  final KeyboardController controller;

  final SecurityKeyboardType type;

  const SecurityKeyboard({required this.controller, required this.type});

  @override
  Widget build(BuildContext context) {
    Widget keyboard;
    switch (type) {
      case SecurityKeyboardType.number:
        keyboard = SecurityKeyboardNumber(
          controller: controller,
        );
        break;
      case SecurityKeyboardType.text:
        keyboard = SecurityKeyboardText(
          controller: controller,
        );
        break;
    }
    return keyboard;
  }
}

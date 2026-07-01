import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/datetime_utils.dart';
import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';
import 'package:flutter_text/widget/chat/helper/user/user_db.dart';
import 'package:get/get.dart';

import 'state.dart';

class UserRegisterLogic extends GetxController {
  final UserRegisterState state = UserRegisterState();

  Future<void> onRegister() async {
    final FormState? from = state.formKey.currentState;
    if (from != null && from.validate()) {
      from.save();
      final String name = state.nameController.text.trim();
      final User? exists = await PostgresUser.findByName(name);
      if (exists != null) {
        ToastUtils.showToast(msg: '用户名已存在');
        return;
      }
      final User user = User()
        ..image = state.imageController.text.trim()
        ..name = name
        ..passwordHash = _hashPassword(state.passwordController.text)
        ..createTime = DateTimeHelper.getLocalTimeStamp() ~/ 1000
        ..updateTime = DateTimeHelper.getLocalTimeStamp() ~/ 1000;

      try {
        await PostgresUser.addUser(user);
        ToastUtils.showToast(msg: '注册成功，正在跳转中');
        int i = 2;
        Navigator.popUntil(Get.context!, (_) => i-- == 0);
      } catch (error, stack) {
        Log.error(error, stackTrace: stack);
        rethrow;
      }
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';
import 'package:get/get.dart';

import 'state.dart';

class UserLoginLogic extends GetxController {
  final UserLoginState state = UserLoginState();

  Future<void> onLogin() async {
    final FormState? from = state.formKey.currentState;
    if (from != null && from.validate()) {
      from.save();
      final String passwordHash = _hashPassword(state.passwordController.text);
      final User? result = await PostgresUser.loginWithPassword(
        nameValue: state.nameController.text.trim(),
        passwordHash: passwordHash,
      );
      if (result != null) {
        GlobalStore.user = result;
        LocateStorage.setString('user', jsonEncode(result));
        ToastUtils.showToast(msg: '登陆成功');
        NavigatorUtils.pop(Get.context!, results: true);
      } else {
        ToastUtils.showToast(msg: '请输入正确的用户名和密码');
      }
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}

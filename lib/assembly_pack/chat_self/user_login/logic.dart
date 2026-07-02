import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';
import 'package:get/get.dart';
import 'package:self_utils/widget/management/common/view_key.dart';

import 'state.dart';

class UserLoginLogic extends GetxController {
  final UserLoginState state = UserLoginState();

  Future<void> onLogin(BuildContext context) async {
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
        if (GlobalStore.isMobile) {
          NavigatorUtils.pop(context, results: true);
        } else {
          final ViewKey? loginKey = WindowsNavigator.c.current?.key;
          WindowsNavigator().pushWidget(
            context,
            ChatListWidget(),
            title: '聊天',
          );
          if (loginKey != null) {
            WindowsNavigator.c.close(loginKey);
          }
        }
      } else {
        ToastUtils.showToast(msg: '请输入正确的用户名和密码');
      }
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}

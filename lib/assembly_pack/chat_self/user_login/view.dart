import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/chat_self/user_register/view.dart';
import 'package:flutter_text/global/global.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final UserLoginLogic logic = Get.put(UserLoginLogic());
  final UserLoginState state = Get.find<UserLoginLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('登陆'),
              actions: <Widget>[
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      child: const Text('注册'),
                      onTap: () {
                        Get.to(() => UserRegisterPage());
                      },
                    ),
                  ),
                )
              ],
            )
          : null,
      body: Center(
        child: Form(
          key: state.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   child: Text('logo'),
              // ),
              Container(
                width: 500,
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                    controller: state.nameController,
                    decoration: const InputDecoration(helperText: '请输入用户名'),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入用户名';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      state.nameController.text = value;
                    }),
              ),
              Container(
                width: 500,
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                    controller: state.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(helperText: '请输入密码'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      return null;
                    },
                    onFieldSubmitted: (String value) {
                      state.passwordController.text = value;
                    }),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 250,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: CupertinoButton(
                            color: Theme.of(context).primaryColorDark,
                            child: const Text(
                              '登陆',
                            ),
                            onPressed: () {
                              logic.onLogin();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 250,
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: CupertinoButton(
                            color: Theme.of(context).primaryColorDark,
                            child: const Text(
                              '注册',
                            ),
                            onPressed: () {
                              Get.to(() => UserRegisterPage());
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<UserLoginLogic>();
    super.dispose();
  }
}

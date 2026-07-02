import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class UserRegisterPage extends StatefulWidget {
  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final UserRegisterLogic logic = Get.put(UserRegisterLogic());
  final UserRegisterState state = Get.find<UserRegisterLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Form(
        key: state.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                  controller: state.nameController,
                  decoration: const InputDecoration(helperText: '请输入名字'),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入名字';
                    }
                    return null;
                  },
                  onFieldSubmitted: (String value) {
                    state.nameController.text = value;
                  }),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                  controller: state.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(helperText: '请输入密码'),
                  validator: (String? value) {
                    if (value == null || value.length < 6) {
                      return '密码至少 6 位';
                    }
                    return null;
                  },
                  onFieldSubmitted: (String value) {
                    state.passwordController.text = value;
                  }),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                  controller: state.imageController,
                  decoration: const InputDecoration(helperText: '上传网络头像'),
                  onFieldSubmitted: (String value) {
                    state.imageController.text = value;
                  }),
            ),
            Container(
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
                        logic.onRegister(context);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<UserRegisterLogic>();
    super.dispose();
  }
}

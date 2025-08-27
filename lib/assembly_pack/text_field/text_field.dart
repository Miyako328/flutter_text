import 'package:flutter/material.dart';
import 'package:self_utils/widget/keyboard/security_keyboard.dart';

class TextFieldPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'slider Study',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('text_field 组件'),
        ),
        body: Center(
          child: _contextPage(),
        ),
      ),
    );
  }
}

class _contextPage extends StatefulWidget  {

  @override
  State<StatefulWidget> createState() => _contextPageState();

}

class _contextPageState extends State<_contextPage> {
  @override

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: usernameController,
          textCapitalization: TextCapitalization.none,          //键盘大小写显示
          keyboardType: TextInputType.text,                     //键盘类型
          decoration: const InputDecoration(                          //设置装饰
            contentPadding: EdgeInsets.all(10.0),               //控制input高度
            icon: Icon(Icons.person),
            labelText: "请输入你的手机号",
            helperText: "请输入注册的手机号"
          ),
          textInputAction: TextInputAction.go,                  //控制键盘的功能键，指enter键。
        ),
        TextField(
          controller: passwordController,
          keyboardType: SecurityKeyboardCenter.number,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(10.0),
            icon: Icon(Icons.lock),
            labelText: "请输入密码"
          ),
          obscureText: true,                                      //是否为密码
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 50, 0, 20),
          child: ElevatedButton(
            onPressed: () {
              loginCheck();
            },
            child: Text('注册'),
          ),
        ),
      ],
    );
  }

  //简单的登录判断
  void loginCheck() {
    String content = '登录成功';

    if ( passwordController.text.length < 6 ) {
      content = '请输入6位数以上的密码';
    }

    if ( usernameController.text.length != 11 ) {
        content = '请输入正确的手机号码';
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.pop(context, '取消选择');
              },
            ),
            ElevatedButton(
              child: const Text("确定"),
              onPressed: () {
                Navigator.pop(context, usernameController);
              },
            ),
          ],
        ));
  }
}


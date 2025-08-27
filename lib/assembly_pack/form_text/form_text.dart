import 'package:flutter/material.dart';

class FormText extends StatefulWidget {
  @override
  _FormTextState createState() =>  _FormTextState();
}

class _FormTextState extends State<FormText> {
  GlobalKey<FormState> _formKey =  GlobalKey<FormState>();

  String? _name;

  String? _password;

  void _forSubmitted() {
    final FormState? _form = _formKey.currentState;

    if (_form != null && _form.validate()) {
      _form.save();
      print(_name);
      print(_password);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter data',
      home: Scaffold(
        appBar:  AppBar(
          title: const Text('Flutter Form'),
        ),
        floatingActionButton:  FloatingActionButton(
          onPressed: _forSubmitted,
          child:  Text('提交'),
        ),
        body:  Container(
          padding: const EdgeInsets.all(16.0),
          child:  Form(
            key: _formKey,
            child:  Column(
              children: <Widget>[
                 TextFormField(
                  decoration:  InputDecoration(
                    labelText: 'Your Name',
                  ),
                  onSaved: (String? val) {
                    _name = val;
                  },
                ),
                 TextFormField(
                  decoration:  InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (String? val) {
                    return (val?.length??0) < 4 ? "密码长度错误" : null;
                  },
                  onSaved: (val) {
                    _password = val;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
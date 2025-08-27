import 'package:flutter/material.dart';

class RaisedButtonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'slider Study',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('layoutRow 组件'),
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
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text(
          'Hello World',
          style: TextStyle(fontSize: 26.0),
        ),                                                 //墨汁飞溅的颜色
        clipBehavior: Clip.antiAlias,
        onPressed: () {                                                                 //设置了onpressed以上颜色才有效果，不然就是失效状态
          print('按钮按下操作');
        },
      ),
    );
  }
}


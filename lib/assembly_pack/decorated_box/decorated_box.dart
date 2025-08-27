import 'package:flutter/material.dart';

class DecoratedBoxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'slider Study',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Decorated Box 组件'),
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
      child: Container(
        width: 300,
        height: 300,
        child: DecoratedBox (
          position: DecorationPosition.background,        //装饰定位，background背景模式，foreground前景模式
          decoration: BoxDecoration(
            color: Colors.grey,
            image: const DecorationImage(                     //设置图片，图片的填充方式
              fit: BoxFit.cover,
              image: ExactAssetImage('images/timg.jpg'),
            ),
            border: Border.all(
              color: Colors.white,
              width: 6.0,
            ),
            shape: BoxShape.rectangle,
          ),
          child: Container(                                 //外部一层container就可以设置位置
            alignment: Alignment.topCenter,
            child: const Text(
                '定位演示',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
            ),
          ),
        ),
      )
    );
  }
}


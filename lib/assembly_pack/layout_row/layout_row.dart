import 'package:flutter/material.dart';

class layoutRow extends StatelessWidget {
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
    return const Center(
      child: Text('Hello layoutRow'),
    );
  }
}


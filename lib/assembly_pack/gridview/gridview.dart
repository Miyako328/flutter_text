import 'package:flutter/material.dart';

class GridViewPage extends StatelessWidget {
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
    return new Center(
      child: _buildGridCustom(),
    );
  }

  //SliverGridDelegateWithFixedCrossAxisCount可以指定列的个数的Grid
  //SliverGridDelegateWithMaxCrossAxisExtent根据每个宽度自动计算的Grid
  Widget _buildGridCustom() {
    return GridView.custom(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              return Image.asset('images/timg3.jpg');
            },
            childCount: 10
        ),
    );
  }

}


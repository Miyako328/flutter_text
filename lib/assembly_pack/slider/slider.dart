import 'package:flutter/material.dart';

class slider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'slider Study',
      home: Scaffold(
        appBar: AppBar(
          title: Text('slider 组件'),
        ),
        body: Center(
          child: contextPage(),
        ),
      ),
    );
  }
}

class contextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => contextPageState();
}

class contextPageState extends State<contextPage> {
  @override
  double value = 0.0;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.greenAccent,
        //已拖动的颜色
        inactiveTrackColor: Colors.green,
        //未拖动的颜色
        valueIndicatorColor: Colors.green,
        //提示进度的气泡背景颜色
        valueIndicatorTextStyle: TextStyle(
          //提示进度的气泡文本颜色
          color: Colors.white,
        ),
        thumbColor: Colors.blueAccent,
        //滑块中心的颜色
        overlayColor: Colors.white,
        //滑块边缘的颜色
        inactiveTickMarkColor: Colors.white, //divsions对进度条先分割后，断续线中间间隔的颜色
      ),
      child: Slider(
        value: value,
        //控件位置
        label: '$value',
        //divisions设置显示在节点上的label
        min: 0.0,
        //最小值
        max: 100.0,
        //最大值
        divisions: 100,
        //分成几块
        onChanged: (val) {
          setState(() {
            value = val.floorToDouble();
          });
        },
      ),
    );
  }
}

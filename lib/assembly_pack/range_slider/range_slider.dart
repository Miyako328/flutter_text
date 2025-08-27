import 'package:flutter/material.dart';

class RangeSliderPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyRangeSliderPage(title: 'Flutter Demo Home Page');
  }
}

class MyRangeSliderPage extends StatefulWidget {
  MyRangeSliderPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyRangeSliderPage> {
  int _counter = 0;

  double rangeSlideMin = 0;
  double rangeSlideMax = 10;

  void _rangeSlideChange(min, max) {
    setState(() {
      rangeSlideMin = min;
      rangeSlideMax = max;
    });
  }

  Widget getRangeSlider() {
    return SliderTheme(//样式的设计
      data: const SliderThemeData(
        inactiveTickMarkColor: Colors.red,
        inactiveTrackColor: Colors.yellow,
      ),
      child: RangeSlider(//滑动时上方的提示标签
        labels: RangeLabels("$rangeSlideMin", "$rangeSlideMax"), //当前Widget滑块的值
        values: RangeValues(rangeSlideMin, rangeSlideMax), //最小值
        min: 0, //最大值
        max: 100, //最小滑动单位值
        divisions: 10, //未滑动的颜色
        inactiveColor: Colors.grey, //活动的颜色
        activeColor: Colors.blue, //滑动事件
        onChanged: (RangeValues values) {//滑动时更新widget的状态值
          _rangeSlideChange(values.start, values.end);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$rangeSlideMin - $rangeSlideMax'),
            getRangeSlider(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
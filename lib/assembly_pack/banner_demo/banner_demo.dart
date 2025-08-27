import 'package:flutter/material.dart';
import 'package:flutter_text/model/img_model.dart';
import 'package:flutter_text/widget/banner.dart';

class bannerDemo extends StatefulWidget {
  @override
  _bannerDemoState createState() => _bannerDemoState();
}

class _bannerDemoState extends State<bannerDemo> {
  final List<ImageModel> _imgData = [
    ImageModel()
      ..image =
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201311%2F17%2F174124tp3sa6vvckc25oc8.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625624528&t=f27d73f1455c17f3fc1c4296f0e11957",
    ImageModel()
      ..image =
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201311%2F17%2F174124tp3sa6vvckc25oc8.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625624528&t=f27d73f1455c17f3fc1c4296f0e11957"
      ..overBrowerUrl = "https://www.baidu.com",
    ImageModel()
      ..image =
          "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201311%2F17%2F174124tp3sa6vvckc25oc8.jpg&refer=http%3A%2F%2Fattach.bbs.miui.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1625624528&t=f27d73f1455c17f3fc1c4296f0e11957",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WidgetBanner(_imgData));
  }
}

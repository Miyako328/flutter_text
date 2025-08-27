import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text/init.dart';
import 'package:self_utils/widget/animated_wave.dart';
import 'package:simple_animations/simple_animations.dart';

class Hello extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: HelloDemo());
  }
}

//scene主场景
class HelloDemo extends StatefulWidget {
  @override
  HelloDemoState createState() => HelloDemoState();
}

class HelloDemoState extends State<HelloDemo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    ); //清除手机顶部和底部状态栏
    _getPlane();
  }

  //获取gif图的帧数
  Future<void> _getPlane() async {
    final ByteData data = await rootBundle.load('images/plane2.gif');
    final Uint8List uintList = Uint8List.view(data.buffer);
    final ui.Codec code = await ui.instantiateImageCodec(uintList);
    final ui.FrameInfo first = await code.getNextFrame();
    Log.info(first.image);
    Log.info(code.frameCount);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: LinearBackground()),
        Positioned.fill(
            child: Align(
          alignment: Alignment.topLeft,
          child: Image.asset("images/cloud5.gif",
              width: MediaQuery.of(context).size.width),
        )),
        onWave(AnimatedWave(
          height: 180,
          speed: 1.0,
        )),
        onWave(AnimatedWave(
          height: 120,
          speed: 0.9,
          offset: pi,
        )),
        onWave(AnimatedWave(
          height: 220,
          speed: 1.2,
          offset: pi / 2,
        )),
        Positioned.fill(
            child: Center(
          child: Image.asset(
            "images/plane2.gif",
            width: 60,
          ),
        )),
      ],
    );
  }

  Widget onWave(Widget child) => Positioned.fill(
          child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ));
}

//背景渐变
class LinearBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MovieTween tween = MovieTween()
      ..tween(
        'color1',
        ColorTween(begin: Colors.red, end: Colors.blueAccent.shade700),
        duration: const Duration(seconds: 20),
      ).thenTween(
        'color2',
        ColorTween(begin: Colors.deepOrange, end: Colors.blue.shade600),
        duration: const Duration(seconds: 20),
      );
    return MirrorAnimationBuilder<Movie>(
      tween: tween,
      duration: tween.duration,
      builder: (BuildContext context, animation, _) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [animation.get('color1'), animation.get('color2')],
          )),
        );
      },
    );
  }
}

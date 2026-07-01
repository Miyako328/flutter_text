import 'dart:math';
import 'package:flutter/material.dart';

class FlutterText extends StatefulWidget {
  var str;
  var style;

  FlutterText(this.str, this.style);

  @override
  _FlutterTextState createState() => _FlutterTextState();
}

class _FlutterTextState extends State<FlutterText>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    animation = TweenSequence<double>([//使用TweenSequence进行多组补间动画
      TweenSequenceItem<double>(tween: Tween(begin: 0, end: 15), weight: 1),
      TweenSequenceItem<double>(tween: Tween(begin: 15, end: 0), weight: 2),
      TweenSequenceItem<double>(tween: Tween(begin: 0, end: -15), weight: 3),
      TweenSequenceItem<double>(tween: Tween(begin: -15, end: 0), weight: 4),
    ]).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() {});
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    Transform result = Transform(
      transform: Matrix4.rotationZ(animation.value * pi / 180),
      alignment: Alignment.center,
      child: Text(
        widget.str,
        style: widget.style,
      ),
    );

    return result;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


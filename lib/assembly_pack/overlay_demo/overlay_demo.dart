import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/widget/float_box.dart';

class overlayDemo extends StatefulWidget {

  @override
  overlayDemoState createState() => overlayDemoState();
}

class overlayDemoState extends State<overlayDemo> {
  static OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text("开启悬浮按钮"),
            onPressed: () {
              entry?.remove();
              entry = null;
              entry = OverlayEntry(builder: (context) {
                return FloatBox();
              });
              Overlay.of(context)?.insert(entry!);
            },
          ),
          ElevatedButton(
            child: Text("关闭悬浮按钮"),
            onPressed: () {
              entry?.remove();
            },
          )
        ],
      ),
    );
  }
}
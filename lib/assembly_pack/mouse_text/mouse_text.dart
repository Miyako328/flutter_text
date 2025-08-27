import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/log_utils.dart';

class MouseTextPage extends StatefulWidget {

  @override
  _MouseTextState createState() => _MouseTextState();
}

class _MouseTextState extends State<MouseTextPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('textField text'),
      ),
      body: Center(
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) {
            Log.info('onEnter: $event');
          },
          onHover: (PointerHoverEvent event) {
            Log.info('onHover: $event');
          },
          onExit: (PointerExitEvent event) {
            Log.info('onExit: $event');
          },
          opaque: false,
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
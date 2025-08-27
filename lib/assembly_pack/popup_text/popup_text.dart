import 'package:flutter/material.dart';
import 'package:flutter_text/global/global.dart';
import 'package:self_utils/widget/popup_widget.dart';

class PopupTextPage extends StatefulWidget {
  @override
  _PopupTextState createState() => _PopupTextState();
}

class _PopupTextState extends State<PopupTextPage> {
  final GlobalKey _textKey = GlobalKey<_PopupTextState>();
  final GlobalKey _textKey2 = GlobalKey<_PopupTextState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile ? AppBar(
        title: const Text('popup_text'),
      ) : null,
      body: Column(
        children: [
          Container(
            alignment: Alignment.bottomLeft,
            margin: const EdgeInsets.only(right: 20, left: 20),
            child: GestureDetector(
              key: _textKey,
              onTap: () {
                PopupToastWindow.showPopWindow(
                  context,
                  '啊，被点了',
                  _textKey,
                  spaceMargin: 0,
                );
              },
              child: const Text('点击下'),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(right: 20, left: 20),
            child: GestureDetector(
              key: _textKey2,
              onTap: () {
                PopupToastWindow.showPopWindow(
                  context,
                  '啊，被点了看看有没有双行，啊，被点了看看有没有双行啊，被点了看看有没有双行啊，被点了看看有没有双行啊，被点了看看有没有双行',
                  _textKey2,
                  spaceMargin: 0,
                  canWrap: true,
                  width: 200,
                );
              },
              child: const Text('点击下2'),
            ),
          ),
        ],
      ),
    );
  }
}

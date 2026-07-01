import 'package:flutter/material.dart';

import 'keyboard_manager.dart';

class KeyboardMediaQuery extends StatefulWidget {
  final Widget child;

  KeyboardMediaQuery({required this.child}) : assert(child != null);

  @override
  State<StatefulWidget> createState() => KeyboardMediaQueryState();
}

class KeyboardMediaQueryState extends State<KeyboardMediaQuery> {
  double keyboardHeight = 0;
  ValueNotifier<double> keyboardHeightNotifier = KeyboardManager.keyboardHeightNotifier;

  @override
  void initState(){
    super.initState();
    KeyboardManager.keyboardHeightNotifier.addListener(onUpdateHeight);
  }

  void onUpdateHeight(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(()=>{});
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);

    ///消息传递，更新控件边距
    var bottom = KeyboardManager.keyboardHeightNotifier.value != 0 ? KeyboardManager.keyboardHeightNotifier.value : data.viewInsets.bottom;

    return MediaQuery(
        child: widget.child,
        data: data.copyWith(
            viewInsets: data.viewInsets
                .copyWith(bottom: bottom)));
  }

  ///通知更新
  void update() {
    setState(() => {});
  }
}

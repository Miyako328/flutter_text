import 'package:flutter/material.dart';
import 'package:self_utils/widget/layout_widget.dart';

class LayoutTestPage extends StatefulWidget {
  const LayoutTestPage({Key? key}) : super(key: key);

  @override
  State<LayoutTestPage> createState() => _LayoutTestPageState();
}

class _LayoutTestPageState extends State<LayoutTestPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      desktopWidget: SingleChildScrollView(
        child: Container(
          child: const Text('桌面端'),
        ),
      ),
      mobileWidget: Container(
        child: const Text('手机端'),
      ),
    );
  }
}

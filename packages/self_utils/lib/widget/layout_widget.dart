import 'package:flutter/material.dart';
import 'package:self_utils/utils/log_utils.dart';

///自适应组件
class LayoutWidget extends StatelessWidget {
  const LayoutWidget({
    Key? key,
    required this.desktopWidget,
    required this.mobileWidget,
  }) : super(key: key);

  final Widget mobileWidget;
  final Widget desktopWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      if (width > 1100) {
        return desktopWidget;
      } else {
        return mobileWidget;
      }
    });
  }
}

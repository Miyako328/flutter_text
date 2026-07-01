
import 'package:flutter/material.dart';

enum AnimateType {
  Fade, //渐进
  Scale,  //缩放
  Rotation, //旋转缩放
  Slide,  //滑动
}

class CustomRouter<T> extends PageRouteBuilder<T> {
  final Widget widget;

  final AnimateType type;

  CustomRouter(this.widget, this.type)
      : super(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (BuildContext context, Animation<double> animate1,
              Animation<double> animate2) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            //FadeTransition渐隐渐现
            if (type == AnimateType.Fade) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 2.0)
                    //fastOutSlowIn快出慢进
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.fastOutSlowIn)),
                child: child,
              );
            } else if (type == AnimateType.Scale) {
              //缩放动画
              return ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation, curve: Curves.fastOutSlowIn)),
                child: child,
              );
            } else if (type == AnimateType.Rotation) {
              //旋转缩放动画
              return RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.fastOutSlowIn),
                ),
                child: ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                        parent: animation, curve: Curves.fastOutSlowIn)),
                    child: child),
              );
            } else if (type == AnimateType.Slide) {
              //左右滑动动画
              return SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0))
                    .animate(CurvedAnimation(
                        parent: animation, curve: Curves.slowMiddle)),
                child: child,
              );
            } else {
              return child;
            }
          },
        );
}

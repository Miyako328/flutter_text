import 'package:bot_toast/bot_toast.dart';

import 'package:flutter/material.dart';

part  'text_widget.dart';

typedef Cancel = void Function();

///BotToastInit 初始化
///BotToastInit(
//       child: MaterialApp(
//         title: 'Flutter Study',
//         navigatorObservers: [BotToastNavigatorObserver()],
//         home: Scaffold(
//           appBar: AppBar(
//             title: Text('组件列表'),
//           ),
//           body: Center(
//             child: TabBarDemo(),
//           ),
//         ),
//       ),
//     );

class ToastUtils {
  static Cancel showToast(
      {required String msg,
        Duration duration = const Duration(seconds: 2),
        bool clickClose = false,
        Color backgroundColor = Colors.transparent,
        Color contentBackgroundColor = Colors.black54,
        Alignment align = const Alignment(0, 0.75),
        Widget? preIcon,
        Widget? suffixIcon,
        TextStyle? textStyle,
        BorderRadiusGeometry borderRadius =
        const BorderRadius.all(Radius.circular(8)),
        EdgeInsetsGeometry contentPadding =
        const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 7)}) {
    textStyle ??= TextStyle(fontSize: (20), color: Colors.white);

    return BotToast.showCustomText(
        toastBuilder: (_) => _TextToast(
          contentBackgroundColor: contentBackgroundColor,
          align: align,
          preIcon: preIcon,
          suffixIcon: suffixIcon,
          textStyle: textStyle,
          borderRadius: borderRadius,
          contentPadding: contentPadding,
          text: msg,
        ),
        duration: duration,
        clickClose: clickClose,
        backgroundColor: backgroundColor,
        onlyOne: true);
  }

  static Cancel showLoading(
      {bool clickClose = false,
        bool allowClick = false,
        Widget? customLoading}) {
    if (customLoading != null) {
      return BotToast.showCustomLoading(
          toastBuilder: (_) => Center(
            child: customLoading,
          ),
          allowClick: allowClick,
          clickClose: clickClose,
          crossPage: false);
    }
    return BotToast.showLoading(
        clickClose: clickClose, allowClick: allowClick, crossPage: false);
  }

  ///此方法一般使用在dispose里面,防止因为开发人员没有主动去关闭,或者是请求api时的出现异常
  ///导致CancelFunc方法没有执行到等等,导致用户点击不了app
  static void cleanLoading() {
    //以此方式移除将不会触发关闭动画
    BotToast.closeAllLoading();
  }
}

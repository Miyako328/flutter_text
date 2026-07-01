import 'dart:io';

import 'package:flutter/material.dart';
import 'package:self_utils/global/utils_global.dart';
import 'package:self_utils/utils/event_bus_helper.dart';
import 'package:self_utils/widget/animate_router.dart';
import 'package:get/get.dart';

// 如需继承和重写方法就不能使用静态方法
class NavigatorUtils {
  Future<T?>? pushWidget<T>(
    BuildContext context,
    Widget widget, {
    bool replaceRoot = false,
    Duration? duration,
    bool opaque = false,
    bool replaceCurrent = false,
    bool cleanFocus = false,
    bool isAddRoute = true,
    AnimateType? type,
  }) {
    if (isAddRoute == true)
      EventBusHelper.asyncStreamController?.add(EventCache()..isRoute = true);
    if (cleanFocus == true)
      FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
    if (type != null) {
      return pushRoute<T>(
        context,
        CustomRouter<T>(widget, type),
        replaceRoot: replaceRoot,
        replaceCurrent: replaceCurrent,
      );
    }
    return pushRoute<T>(
      context,
      MaterialPageRoute<T>(builder: (BuildContext ctx) => widget),
      replaceRoot: replaceRoot,
      replaceCurrent: replaceCurrent,
    );
  }

  static Future<T?> pushRoute<T>(
    BuildContext context,
    PageRoute<T> route, {
    bool replaceRoot = false,
    bool replaceCurrent = false,
    bool cleanFocus = false,
  }) {
    assert(!(replaceRoot == true && replaceCurrent == true));

    if (cleanFocus == true)
      FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
    if (replaceRoot == true) {
      return Navigator.pushAndRemoveUntil<T>(
        context,
        route,
        ModalRoute.withName('main'),
      );
    }
    if (replaceCurrent == true) {
      return Navigator.pushReplacement(context, route);
    }
    return Navigator.push<T>(context, route);
  }

  static bool pop(BuildContext context, {dynamic results}) {
    if (Navigator.of(context).canPop()) {
      EventBusHelper.asyncStreamController?.add(EventCache().isRoute = false);
      Navigator.of(context).pop(results);
      return true;
    } else
      return false;
  }

  //用于跳转get路由 arguments参数
  //todo 等价于
  // Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) => GetxTextPage(),
  //     settings: const RouteSettings(arguments: {'count': 10}),
  //     ),
  // );
  static Future<T?> getXOfPush<T>(
    BuildContext context,
    Widget widget, {
    dynamic arguments,
    bool cleanFocus = false,
  }) async {
    if (cleanFocus == true)
      FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);

    return await Get.to<T>(() => widget, arguments: arguments);
  }
}

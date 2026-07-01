import 'dart:async';

import 'package:flutter/material.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/utils/toast_utils.dart';

///所有异常信息在全局处理哪里弹出,不再默认自动弹出小黑窗
///[enableErrorTip] 如果为true则自动弹出Text Toast进行提示
///[errTip]报错时弹出的提示文本,没有则使用Error的message
Future<T> loadingCallback<T>(Future<T> callback(),
    {Widget? customLoading,
      String? errTip,
      @Deprecated('参数已被忽视') bool enableErrorTip = true}) async {
  final Cancel cancel = ToastUtils.showLoading(customLoading: customLoading);
  try {
    return await callback();
  } catch (e) {
    if (errTip != null) {
      ToastUtils.showToast(
          msg: errTip,
          textStyle: TextStyle(
              fontSize: screenUtil.getAutoSp(50),
              color: const Color(0xffffffff)));
    }
    rethrow;
  } finally {
    cancel();
  }
}

typedef TimeoutFunc = Future<void> Function(TimeoutException exception);

///异步函数超时包裹
///[timeout]默认超时时间 30s
///[timeoutFunc] 超时执行函数,
Future<T?> timeoutWrapCallback<T>(Future<T> callBack(),
    {Duration? timeout, TimeoutFunc? timeoutFunc}) async {
  timeout ??= const Duration(seconds: 30);
  try {
    return await callBack.call().timeout(timeout, onTimeout: () async {
      throw TimeoutException('函数执行超时');
    });
  } catch (e) {
    if (e.runtimeType == TimeoutException) {
      if (timeoutFunc != null) {
        timeoutFunc.call(e as TimeoutException);
        rethrow;
      } else {
        rethrow;
      }
    } else {
      rethrow;
    }
  }
}


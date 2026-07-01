import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:self_utils/utils/api_exception.dart';
import 'package:self_utils/utils/init.dart';
import 'package:self_utils/utils/local_log.dart';
import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:self_utils/widget/navigator_helper.dart';

class AppErrorService {
  const AppErrorService._();

  static Future<void> handleFlutterError(FlutterErrorDetails details) async {
    await ReportError().reportError(details.exception, details.stack);
    LocalLog.setLog(
      '${LogLevel.ERROR.toString()} -- ${DateTime.now().toString()} -- ${details.exception}',
    );

    if (ReportError().isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }

    await _handleKnownException(details.exception);
  }

  static Future<void> _handleKnownException(Object exception) async {
    if (exception is ApiException) {
      await _handleApiException(exception);
    } else if (exception is SocketException) {
      ToastUtils.showToast(msg: '网络不可用');
    } else if (exception is TimeoutException) {
      ToastUtils.showToast(msg: exception.message ?? '');
    }
  }

  static Future<void> _handleApiException(ApiException exception) async {
    switch (exception.code) {
      case 401:
        await _popToFirstRoute('401错误');
        break;
      case 403:
        await _popToFirstRoute('403错误');
        break;
      default:
        ToastUtils.showToast(msg: exception.message ?? '');
        break;
    }
  }

  static Future<void> _popToFirstRoute(String message) async {
    final NavigatorState navigatorHelper = await NavigatorHelper.navigatorState;
    ToastUtils.showToast(msg: message);
    navigatorHelper.popUntil((Route<dynamic> route) => route.isFirst);
  }
}

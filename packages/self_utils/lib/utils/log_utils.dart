import 'dart:developer';

import 'package:self_utils/utils/local_log.dart';

enum LogLevel { DEBUG, INFO, WARNING, ERROR }

class Log {
  static bool _debugMode = false;
  static int _maxLen = 128;

  static void init({bool isDebug = false, int maxLen = 128}) {
    _debugMode = isDebug;
    _maxLen = maxLen;
  }

  static void debug(Object message, {StackTrace? stackTrace}) {
    if (_debugMode) {
      log('${LogLevel.DEBUG.toString()} -- ${DateTime.now().toString()} -- ${message.toString()}',
          stackTrace: stackTrace, level: 0);
    }
    LocalLog.setLog(
        '${LogLevel.DEBUG.toString()} -- ${DateTime.now().toString()} -- $message');
  }

  static void info(Object message) {
    if (_debugMode) {
      log('${LogLevel.INFO.toString()} -- ${DateTime.now().toString()} -- $message',
          level: 500);
    }
    LocalLog.setLog(
        '${LogLevel.INFO.toString()} -- ${DateTime.now().toString()} -- $message');
  }

  static void warning(Object message, {StackTrace? stackTrace}) {
    log('${LogLevel.WARNING.toString()} -- ${DateTime.now().toString()} -- $message',
        stackTrace: stackTrace, level: 1000);
    LocalLog.setLog(
        '${LogLevel.WARNING.toString()} -- ${DateTime.now().toString()} -- $message');
  }

  static void error(Object message, {StackTrace? stackTrace}) {
    log('${LogLevel.ERROR.toString()} -- ${DateTime.now().toString()} -- $message',
        stackTrace: stackTrace, level: 2000);
    LocalLog.setLog(
        '${LogLevel.ERROR.toString()} -- ${DateTime.now().toString()} -- $message');
  }
}

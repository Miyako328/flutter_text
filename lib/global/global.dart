import 'package:flutter/material.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';

const kActionAccessibilitySettings = "android.settings.ACCESSIBILITY_SETTINGS";

class GlobalStore {
  static bool isShowOverlay = false; //flutter自带的性能监听 控制
  static bool isShowGary = false; //灰度屏
  static Locale locale = const Locale('zh');
  static String homeIp = '192.168.9.138';
  static String url = 'https://bing.com';
  static String companyIp = '172.31.172.83'; //todo ipconfig 因为非公司内网所以无法使用
  static bool isUserFiddle = false; //是否使用fiddle
  static bool isMobile = true; // 判断是否是桌面端
  static String theme = 'light'; //主题

  // webrtc使用
  static String server = '192.169.3.24'; // 192.168.32.103 172.16.0.117
  static int port = 8086;

  static User? user;

  static ColorFilter greyScale = const ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}

class Setting {

  static Color tabBottomColor = const Color(0xff027DB4);
  static Color tableBarColor = const Color(0xffE5EDF9);
  static Color backGroundColor = const Color(0xffD2E0F4);
  static Color backBorderColor = const Color(0xff8FB6EF);
  static Color tabSelectColor = const Color(0xff8FB6EF);
  static Color orderSubmitColor = const Color(0xffCCE9FF);
  static Color bottomBorderColor = Colors.blue.shade100;
  static Color onSelectColor = Colors.blue.shade50;

  static Color onSubmitColor = const Color(0xff8FB6EF);
  static Color onCancelColor = const Color(0xffD2E0F4);

  /// table的特殊颜色
  static Color tableBlue = const Color(0xff027DB4);
  static Color tableRed = const Color(0xffD9001B);
  static Color tableLightBlue = const Color(0xff02A7F0);
}

class EventBusM {
  String? theme;
}



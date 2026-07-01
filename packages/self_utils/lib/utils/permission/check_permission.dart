import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:bot_toast/src/toast_widget/animation.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  ///程序权限请求被拒绝后的弹窗(neverAskAgain)次数,每次启动只弹出一次
  static final Set<Permission> _permissionSet = <Permission>{};

  //检查位置授权
  static Future<bool> checkLocationPermission(
      {String? textTip, void Function(bool check)? onCancel}) async {
    return await checkPermission(
        checkPermission: Permission.locationWhenInUse,
        textTip: textTip,
        onCancel: onCancel);
  }

  //检查文件or存储授权 IOS没有Storage权限用photos
  static Future<bool> checkStorageOrPhotosPermission(
      {String? textTip, void Function(bool check)? onCancel}) async {
    return await checkPermission(
        checkPermission:
            Platform.isIOS ? Permission.photos : Permission.storage,
        textTip: textTip);
  }

  //只检查存储权限 -- 用于Android
  static Future<bool> checkStoragePermission(
      {String? textTip, void Function(bool check)? onCancel}) async {
    return await checkPermission(
        checkPermission: Permission.storage, textTip: textTip);
  }

  //检查麦克风授权
  static Future<bool> checkMicrophonePermission(
      {String? textTip, void Function(bool check)? onCancel}) async {
    return await checkPermission(
        checkPermission: Permission.microphone, textTip: textTip);
  }

  //检查照相机授权
  static Future<bool> checkCameraPermission(
      {String? textTip, void Function(bool check)? onCancel}) async {
    return await checkPermission(
        checkPermission: Permission.camera, textTip: textTip);
  }

  ///通用检查权限函数,使用权限枚举之前需要自行审查平台差异
  static Future<bool> checkPermission(
      {required Permission checkPermission,
      String? textTip,
      void Function(bool check)? onCancel}) async {
    final PermissionStatus status = await checkPermission.request();
    switch (status) {
      case PermissionStatus.granted:
        return true;
        break;
      case PermissionStatus.denied:
        if (Platform.isIOS) {
          if (!_permissionSet.contains(checkPermission)) {
            gotoIOSPermissionTip(checkPermission, onCancel: onCancel);
          }
          return false;
        }
        return await requestPermission(checkPermission,
            onCancel: onCancel, textTip: textTip);
        break;
      case PermissionStatus.restricted:
        if (!_permissionSet.contains(checkPermission)) {
          gotoIOSPermissionTip(checkPermission, onCancel: onCancel);
        }
        return false;
        break;
      default:
        return false;
    }
  }

  static Future<bool> requestPermission(Permission requestPermission,
      {void Function(bool check)? onCancel, String? textTip}) async {
    final Map<Permission, PermissionStatus> future =
        await [requestPermission].request();
    final PermissionStatus status = future[requestPermission]!;
    switch (status) {
      case PermissionStatus.restricted:
        if (!_permissionSet.contains(requestPermission))
          gotoIOSPermissionTip(requestPermission, onCancel: onCancel);
        return false;
        break;
      case PermissionStatus.granted:
        return true;
        break;
      case PermissionStatus.denied:
        return false;
        break;
      default:
        return false;
    }
  }

//安卓
  static Future<void> gotoAndroidPermissionTip(Permission requestPermission,
      {void Function(bool check)? onCancel, String? textTip}) async {
    _permissionSet.add(requestPermission);

    String permissionTipTitle = '';
    if (requestPermission == Permission.calendar) {
      permissionTipTitle = '日历';
    } else if (requestPermission == Permission.camera) {
      permissionTipTitle = '相机';
    } else if (requestPermission == Permission.contacts) {
      permissionTipTitle = '通讯录';
    } else if (requestPermission == Permission.microphone ||
        requestPermission == Permission.speech) {
      permissionTipTitle = '麦克风';
    } else if (requestPermission == Permission.photos) {
      permissionTipTitle = '相册';
    } else if (requestPermission == Permission.sms) {
      permissionTipTitle = '短信';
    } else if (requestPermission == Permission.storage) {
      permissionTipTitle = '存储';
    } else if (requestPermission == Permission.location ||
        requestPermission == Permission.locationAlways ||
        requestPermission == Permission.locationWhenInUse) {
      permissionTipTitle = '位置信息';
    }

    //不能导入tl_wight,使用不了TlTextStyle，暂时先使用fontSize: screenUtil.getAutoSp
    BotToast.showAnimationWidget(
        animationDuration: const Duration(milliseconds: 500),
        toastBuilder: (CancelFunc cancelFunc) =>
            Builder(builder: (BuildContext context) {
              return Material(
                color: const Color(0x66000000),
                child: Center(
                  child: Container(
                    width: screenUtil.adaptive(872),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff), // 底色
                      borderRadius:
                          BorderRadius.circular(screenUtil.adaptive(30)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            top: screenUtil.adaptive(76),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '权限申请',
                            style: TextStyle(
                              color: const Color(0xff111111),
                              fontSize: screenUtil.getAutoSp(52),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: screenUtil.adaptive(72),
                            left: screenUtil.adaptive(66),
                            right: screenUtil.adaptive(60),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: '在手机桌面找到“设置”，在',
                                  style: TextStyle(
                                    color: const Color(0xff656565),
                                    fontSize: screenUtil.getAutoSp(43),
                                    height: 1.7,
                                  ),
                                ),
                                TextSpan(
                                  text: ' “设置-应用管理” ',
                                  style: TextStyle(
                                    color: const Color(0xff656565),
                                    fontSize: screenUtil.getAutoSp(43),
                                    height: 1.7,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '权限中，开启$permissionTipTitle权限，以正常使用${textTip ?? ''}。',
                                  style: TextStyle(
                                    color: const Color(0xff656565),
                                    fontSize: screenUtil.getAutoSp(43),
                                    height: 1.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: screenUtil.adaptive(110),
                            left: screenUtil.adaptive(25),
                            right: screenUtil.adaptive(25),
                          ),
                          height: screenUtil.adaptive(1),
                          color: const Color(0xffaaaaaa),
                          alignment: Alignment.center,
                        ),
                        Container(
                          height: screenUtil.adaptive(135),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                  child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    screenUtil.adaptive(30)),
                                onTap: () async {
                                  if (permissionTipTitle == '位置信息') {
                                    onCancel?.call(true);
                                  }
                                  cancelFunc.call();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                        color: const Color(0xff828282),
                                        fontSize: screenUtil.getAutoSp(47)),
                                  ),
                                ),
                              )),
                              Container(
                                alignment: Alignment.center,
                                width: screenUtil.adaptive(1),
                                height: screenUtil.adaptive(110),
                                color: const Color(0xffaaaaaa),
                              ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(
                                      screenUtil.adaptive(30)),
                                  onTap: () async {
                                    cancelFunc.call();
                                    await openAppSettings();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '去设置',
                                      style: TextStyle(
                                          color: const Color(0xff5A739B),
                                          fontSize: screenUtil.getAutoSp(47)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
        wrapAnimation: (AnimationController controller, _, Widget child) =>
            FadeAnimation(
              controller: controller,
              child: child,
            ),
        allowClick: true,
        clickClose: false,
        onlyOne: true);
  }

//ios
  static Future<void> gotoIOSPermissionTip(Permission requestPermission,
      {void Function(bool check)? onCancel}) async {
    _permissionSet.add(requestPermission);

    String permissionTipTitle = '';
    String permissionTipComment = '功能中，找到该app，将开关打开。';
    String permissionTipLocation = ''; //定位权限内容
    Function locationContainer = ({Widget? child}) => Container();
    if (requestPermission == Permission.calendar) {
      permissionTipTitle = '日历';
    } else if (requestPermission == Permission.camera) {
      permissionTipTitle = '相机';
    } else if (requestPermission == Permission.contacts) {
      permissionTipTitle = '通讯录';
    } else if (requestPermission == Permission.microphone ||
        requestPermission == Permission.speech) {
      permissionTipTitle = '麦克风';
    } else if (requestPermission == Permission.photos) {
      permissionTipTitle = '相册';
    } else if (requestPermission == Permission.sms) {
      permissionTipTitle = '短信';
    } else if (requestPermission == Permission.storage) {
      permissionTipTitle = '存储';
    } else if (requestPermission == Permission.location ||
        requestPermission == Permission.locationAlways ||
        requestPermission == Permission.locationWhenInUse) {
      permissionTipTitle = '定位';
      permissionTipComment = '功能中打开定位服务，再找到该app，允许使用App期间访问。';
      permissionTipLocation = '服务';
      locationContainer = ({Widget? child}) => Container(
        margin: EdgeInsets.only(
          left: screenUtil.adaptive(66),
          right: screenUtil.adaptive(60),
          bottom: screenUtil.adaptive(70),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          '开启位置服务',
          style: TextStyle(
            color: const Color(0xff3e3e3e),
            fontSize: screenUtil.getAutoSp(43),
            height: 1.7,
          ),
        ),
      );
    }

    BotToast.showAnimationWidget(
        animationDuration: const Duration(milliseconds: 500),
        toastBuilder: (CancelFunc cancelFunc) => Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  backgroundColor: const Color(0x00000000),
                  body: Center(
                    child: Container(
                      width: screenUtil.adaptive(850),
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff), // 底色
                        borderRadius:
                            BorderRadius.circular(screenUtil.adaptive(30)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              top: screenUtil.adaptive(80),
                              bottom: screenUtil.adaptive(80),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '【${permissionTipTitle == '麦克风' ? '录音' : permissionTipTitle}功能】未开启',
                              style: TextStyle(
                                color: const Color(0xff3e3e3e),
                                fontSize: screenUtil.getAutoSp(48),
                              ),
                            ),
                          ),
                          locationContainer(),
                          Container(
                            padding: EdgeInsets.only(
                              left: screenUtil.adaptive(66),
                              right: screenUtil.adaptive(60),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '请在手机的 ',
                                    style: TextStyle(
                                      color: const Color(0xff656565),
                                      fontSize: screenUtil.getAutoSp(43),
                                      height: 1.7,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '“设置-隐私-$permissionTipTitle$permissionTipLocation” ',
                                    style: TextStyle(
                                      color: const Color(0xff656565),
                                      fontSize: screenUtil.getAutoSp(43),
                                      height: 1.7,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '$permissionTipComment',
                                    style: TextStyle(
                                      color: const Color(0xff656565),
                                      fontSize: screenUtil.getAutoSp(43),
                                      height: 1.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: screenUtil.adaptive(100),
                              left: screenUtil.adaptive(30),
                              right: screenUtil.adaptive(30),
                            ),
                            child: Divider(
                              height: screenUtil.adaptive(1),
                              color: const Color(0xffdddddd),
                            ),
                          ),
                          Container(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  screenUtil.adaptive(20)),
                              onTap: () async {
                                if (permissionTipTitle == '定位') {
                                  onCancel?.call(true);
                                }
                                cancelFunc.call();
                              },
                              child: Container(
                                height: screenUtil.adaptive(135),
                                alignment: Alignment.center,
                                child: Text(
                                  '我知道了',
                                  style: TextStyle(
                                      color: const Color(0xff828282),
                                      fontSize: screenUtil.getAutoSp(44)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        wrapAnimation: (AnimationController controller, _, Widget child) =>
            FadeAnimation(
              controller: controller,
              child: child,
            ),
        allowClick: true,
        clickClose: false,
        onlyOne: true);
  }
}

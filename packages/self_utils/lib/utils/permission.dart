import 'package:permission_handler/permission_handler.dart';

class Permissions {
  //请求权限
  static Future<void> init() async {
    Map<Permission, PermissionStatus> permissions =
        await [
          Permission.location,
          Permission.camera,
          Permission.storage,
          Permission.photos,
          Permission.microphone,
          Permission.mediaLibrary,
          Permission.speech
    ].request();
    //校验权限
    if (permissions[Permission.camera] != PermissionStatus.granted) {
      print('无照相权限');
    }

    if (permissions[Permission.storage] != PermissionStatus.granted) {
      print('无存储权限');
    }

    if (permissions[Permission.photos] != PermissionStatus.granted) {
      print('无相册权限');
    }

    if (permissions[Permission.mediaLibrary] != PermissionStatus.granted) {
      print('无媒体权限');
    }

    if (permissions[Permission.speech] != PermissionStatus.granted) {
      print('无语音权限');
    }

    if (permissions[Permission.microphone] != PermissionStatus.granted) {
      print('无语音权限');
    }
  }
}

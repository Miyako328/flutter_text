import 'package:self_utils/utils/toast_utils.dart';
import 'package:url_launcher/url_launcher.dart' as u;

import 'log_utils.dart';

class WebUrl {
  //判断链接的可用性
  static Future<String?> checkUrl(String value,
      {bool enable = true, String errorMsg = '该链接不可用'}) async {
    if (!enable) return null;
    return await u.canLaunchUrl(Uri.parse(value)) ? null : errorMsg;
  }

  //跳转链接
  static Future<void> launchUrl(String url) async {
    final String? result = await checkUrl(url);
    if (result == null) {
      await u.launchUrl(Uri.parse(url));
    } else {
      ToastUtils.showToast(msg: result);
      return;
    }
  }

  //scheme跳转
  static Future<void> launchSchemeUrl(String url) async {
    try {
      await u.launchUrl(Uri(scheme: url));
    } catch (error, stack) {
      Log.error(error, stackTrace: stack);
      rethrow;
    }
  }
}

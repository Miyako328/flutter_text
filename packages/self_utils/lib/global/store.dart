import 'package:self_utils/utils/log_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocateStorage {
  static late SharedPreferences lStorage;

  //初始化
  static Future<SharedPreferences> init() async {
    lStorage = await SharedPreferences.getInstance();
    return lStorage;
  }

  //是否有这个val值为key的缓存
  static bool containsKey(String val) {
    return lStorage.containsKey(val);
  }

  //请理缓存
  static void clean({String? key}) {
    if (key != null && key.isNotEmpty == true) {
      lStorage.remove(key);
    } else {
      lStorage.clear();
    }
  }

  //查看所有keys
  static Set<String> getAllKey() {
    final keys = lStorage.getKeys();
    return keys;
  }

  //查看keys 仅用于缓存一段时间
  static String? getOneKey(String key) {
    final keys = lStorage.getKeys();
    if (keys.isNotEmpty == true) {
      String hasKey = keys.firstWhere((element) => element.contains('$key '), orElse: () => '');
      if (hasKey.isNotEmpty == true) {
        List<String> keyWithTime = hasKey.split(' ');
        if (DateTime.now().millisecondsSinceEpoch >
            int.tryParse(keyWithTime[1])!) {
          clean(key: hasKey);
          return null;
        } else {
          return hasKey;
        }
      }
    }
    return null;
  }

  //设置String缓存
  static void setString(String key, String val) {
    lStorage.setString(key, val);
    Log.info('setString: $key');
  }

  //获取String缓存
  static String? getString(String key) {
    final value = lStorage.getString(key);
    return value;
  }

  //设置bool缓存
  static void setBool(String key, bool val) {
    lStorage.setBool(key, val);
    Log.info('setBool: $key');
  }

  //获取bool缓存
  static bool? getBool(String key) {
    final value = lStorage.getBool(key);
    return value;
  }

  //设置int缓存
  static void setInt(String key, int val) {
    lStorage.setInt(key, val);
    Log.info('setInt: $key');
  }

  //获取int缓存
  static int? getInt(String key) {
    final value = lStorage.getInt(key);
    return value;
  }

  //设置字符串数组
  static void setStringList(String key, List<String> lists) {
    lStorage.setStringList(key, lists);
    Log.info('setStringList: $key');
  }

  //获取字符串数组
  static List<String>? getStringList(String key) {
    final List<String>? lists = lStorage.getStringList(key);
    return lists;
  }

  //获取过期时间
  static int getExpireTime(int expireTime) {
    return DateTime.now().millisecondsSinceEpoch + (expireTime * 1000);
  }

  //设置String缓存
  static void setStringWithExpire(String key, String val, Duration expireTime) {
    int exTime = getExpireTime(expireTime.inSeconds);
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      clean(key: hasKey);
    }
    lStorage.setString('$key $exTime', val);
    Log.info('setStringWithExpire: $key $exTime');
  }

  //获取String缓存
  static String? getStringWithExpire(String key) {
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      final value = lStorage.getString(hasKey);
      return value;
    } else {
      return null;
    }
  }

  //设置bool缓存
  static void setBoolWithExpire(String key, bool val, Duration expireTime) {
    int exTime = getExpireTime(expireTime.inSeconds);
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      clean(key: hasKey);
    }
    lStorage.setBool('$key $exTime', val);
    Log.info('setBoolWithExpire: $key $exTime');
  }

  //获取bool缓存
  static bool? getBoolWithExpire(String key) {
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      final value = lStorage.getBool(hasKey);
      return value;
    } else {
      return null;
    }
  }

  //设置int缓存
  static void setIntWithExpire(String key, int val, Duration expireTime) {
    int exTime = getExpireTime(expireTime.inSeconds);
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      clean(key: hasKey);
    }
    lStorage.setInt('$key $exTime', val);
    Log.info('setIntWithExpire: $key $exTime');
  }

  //获取int缓存
  static int? getIntWithExpire(String key) {
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      final value = lStorage.getInt(hasKey);
      return value;
    } else {
      return null;
    }
  }

  //设置字符串数组
  static void setStringListWithExpire(
      String key, List<String> lists, Duration expireTime) {
    int exTime = getExpireTime(expireTime.inSeconds);
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      clean(key: hasKey);
    }
    lStorage.setStringList('$key $exTime', lists);
    Log.info('setStringListWithExpire: $key $exTime');
  }

  //获取字符串数组
  static List<String>? getStringListWithExpire(String key) {
    final hasKey = getOneKey(key);
    if (hasKey != null) {
      final List<String>? lists = lStorage.getStringList(hasKey);
      return lists;
    } else {
      return null;
    }
  }
}

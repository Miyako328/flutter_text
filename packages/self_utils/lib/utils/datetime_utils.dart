import 'package:intl/intl.dart';

class DateTimeHelper {
  static const Duration zone = Duration(hours: 8);

  static int lastStamp = 0;

  static int sequence = 1;

  //返回两个时间戳是不是同一天(不传则和今天比)(秒,秒)
  static bool isItTheSameDay(int utcTime, {int? utcTime2}) {
    utcTime2 ??= (timeToTimeStamp(getNow())).floor();

    if (getDateDifference(utcTime, utcTime2: utcTime2) != 0) {
      return false;
    } else {
      if (DateTime.fromMillisecondsSinceEpoch(utcTime * 1000).day ==
          DateTime.fromMillisecondsSinceEpoch(utcTime2 * 1000).day) {
        return true;
      } else {
        return false;
      }
    }
  }

  //这个方法只返回两个时间的差距(和今天比)(整天数(舍))(秒,秒)
  static int getTimeDifference(int utcTime) {
    //utc时间戳
    final DateTime utc = DateTime.fromMillisecondsSinceEpoch(utcTime * 1000);
    final DateTime localTime = getNow();
    return utc.difference(localTime).inDays;
  }

  //不能判断是不是同一天,只返回两个日期之间的所差的天数(秒,秒)
  //这个方法只返回两个日期的差距(不传则和今天比)(整天数(入))
  static int? getDateDifference(int utcTime, {int? utcTime2}) {
    if (utcTime == 0) return null;
    //获取服务器时间戳/时间
    utcTime = utcTime * 1000;
    if (utcTime2 == null || utcTime2 == 0) {
      //获取当前时间戳/时间
      utcTime2 = timeToTimeStamp(getNow()) * 1000;
    } else {
      //获取当前时间戳/时间
      utcTime2 = utcTime2 * 1000;
    }
    final DateTime nowTime =
        transformationIntDateToUtc8((utcTime2 / 1000).floor())!;

    //这里获取一个值为两个时间差(整天)用于判断整天 (取小(舍))
    int day = ((utcTime - utcTime2) / 86400000).floor();
    //获取除了整天剩余时间毫秒
    final int surplus = (utcTime - utcTime2) % 86400000;

    //然后对时间开始操作
    final DateTime newTime = nowTime.add(Duration(milliseconds: surplus));
    if (newTime.day != nowTime.day) {
      if (surplus > 0) {
        //剩余时间可能为正为负
        day += 1;
      } else {
        day -= 1;
      }
    }
    return day;
  }

  //获取一个本地时间
  static DateTime getNow() {
    return DateTime.now();
  }

  //判断一个时间戳是不是昨天(秒)
  static bool yesterday(int time) {
    return (DateTimeHelper.getNow().add(const Duration(days: -1)).day) ==
        (DateTime.fromMillisecondsSinceEpoch(time * 1000).day);
  }

  //判断一个时间戳是不是昨天,是返回昨日,不是返回日期
  static String? isYesterday(int date) {
    if (date == 0) {
      return null;
    } else {
      if (yesterday(date)) {
        return '昨日';
      } else {
        final DateTime thisDate = transformationIntDateToUtc8(date)!;
        return '${thisDate.month}月${thisDate.day}日';
      }
    }
  }

  //返回 true=过期,false=没有过期
  static bool? isTimeExpired(int utcTime) {
    //utc时间戳
    if (utcTime == 0) {
      return null;
    }
    return utcTime < timeToTimeStamp(getNow());
  }

  //获取本地时间戳
  static int getLocalTimeStamp() {
    return getNow().millisecondsSinceEpoch;
  }

  //判断时区 false不是系统支持时区,true是
  static bool thisDateIsTrueZone() {
    if (!getNow().add(zone).isUtc) {
      return false;
    }
    return true;
  }

//将时间戳格式化(这里的时间是服务器的10位数时间戳)
  static String? datetimeFormat(int date, String type) {
    if (date == 0) {
      return null;
    }
    return DateFormat(type).format(transformationIntDateToUtc8(date)!);
  }

//获取本地时间,转换为需要的时区时间(只能用于显示,时间戳已改变)
  ///(慎用)
  static DateTime thisLocalDateZone() {
    return getNow().toUtc().add(zone);
  }

  //警告,这个方法只能用于展示时间,因为会更改实际时间戳(不允许重新上传-详情见test)
  //将服务端获取到的时间戳转换为系统支持时区时间
  static DateTime? transformationIntDateToUtc8(int date) {
    if (date == 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(date * 1000).toUtc().add(zone);
  }

  //判断两个时间戳是不是同一周(秒,秒)
  static bool isItTheSameWeek(int utcTime, {int? utcTime2}) {
    if (utcTime == 0) return false;
    //首先取整86400 对天数取整
    utcTime = (utcTime ~/ 86400) * 86400;
    utcTime = utcTime * 1000;
    if (utcTime2 == null || utcTime2 == 0) {
      utcTime2 = getLocalTimeStamp();
    } else {
      utcTime2 = utcTime2 * 1000;
    }
    //获取当前时间戳的那天的开始时间
    final DateTime dayBeginTime =
        DateTime.fromMillisecondsSinceEpoch(utcTime, isUtc: true);
    //获取当前是一周第几天
    final int weekDay = dayBeginTime.weekday;
    final DateTime thisWeekBeginTime =
        dayBeginTime.add(Duration(days: -(weekDay - 1)));
    final DateTime thisWeekEndTime =
        dayBeginTime.add(Duration(days: 7 - (weekDay - 1)));

    final DateTime time2 =
        DateTime.fromMillisecondsSinceEpoch(utcTime2, isUtc: true).add(zone);
    if (thisWeekBeginTime == time2) {
      return true;
    }
    if (thisWeekEndTime == time2) {
      return false;
    }
    if (time2.isAfter(thisWeekBeginTime) && time2.isBefore(thisWeekEndTime)) {
      return true;
    } else {
      return false;
    }
  }

  //返回两个时间戳中的差值的字符串(秒,秒)(1分钟之前,1小时之前,1天之前,1年之前)
  static String? differenceValueString(int utcTime, {int? utcTime2}) {
    if (utcTime == 0) return null;
    utcTime = utcTime * 1000;
    if (utcTime2 == null || utcTime2 == 0) {
      utcTime2 = getLocalTimeStamp();
    } else {
      utcTime2 = utcTime2 * 1000;
    }
    assert(utcTime2 > utcTime); //第一个时间必须为小的那个
    final int timeSpan = utcTime2 - utcTime;
    if (timeSpan < 3600000) {
      return '${(timeSpan / 60000).ceil()}分钟之前';
    } else if (timeSpan < 86400000) {
      return '${(timeSpan / 3600000).ceil()}小时之前';
    } else if (timeSpan < 31536000000) {
      return '${(timeSpan / 86400000).ceil()}天之前';
    } else {
      return '${(timeSpan / 31536000000).ceil()}年之前';
    }
  }

  //todo 这个方法可以把Datetime.millisecondsSinceEpoch重写(等待优化)
  //将时间转换为时间戳(实际已8时区转换的)_秒数   (这个方法实际原理是因为将时间转为时间戳时,依据本地时区,而我们要求同一使用utc+8,所以在转换时间戳时会用到这个方法)
  static int timeToTimeStamp(DateTime? time) {
    if (time == null) throw Exception('time为空');
    return (time.millisecondsSinceEpoch / 1000).floor() -
        (time.timeZoneOffset).inSeconds +
        (28800);
  }

  ///获取该天0点时间戳
  static int timeToZeroTimeStamp(DateTime? time) {
    time ??= DateTimeHelper.getNow();
    int timeStamp = 0;
    final int getStamp = time.millisecondsSinceEpoch ~/ 1000;
    timeStamp = (getStamp ~/ 86400) * 86400;
    timeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000)
        .add(const Duration(hours: -8))
        .millisecondsSinceEpoch;

    return timeStamp ~/ 1000;
  }

  //根据时间戳获取周几
  static String timeToWeekDay(int? time) {
    time ??= DateTimeHelper.getLocalTimeStamp() ~/ 1000;
    final int weekDay =
        DateTime.fromMillisecondsSinceEpoch(time * 1000).weekday;
    String result = '';
    switch (weekDay) {
      case 1:
        result = '周一';
        break;
      case 2:
        result = '周二';
        break;
      case 3:
        result = '周三';
        break;
      case 4:
        result = '周四';
        break;
      case 5:
        result = '周五';
        break;
      case 6:
        result = '周六';
        break;
      case 7:
        result = '周日';
        break;
    }
    return result;
  }

  //根据时间戳获取当月的时间戳范围
  static List<int> timeToMouthTimeStamp(int time) {
    final List<int> result = <int>[];
    String date = '';
    final String mouth = datetimeFormat(time, 'MM') ?? '';
    final String year = datetimeFormat(time, 'yyyy') ?? '';

    const List<String> big_mouth = <String>[
      '01',
      '03',
      '05',
      '07',
      '08',
      '10',
      '12'
    ];
    date = year + mouth;
    if (big_mouth.any((e) => e == mouth) == true) {
      result.add(DateTime.parse('${date}01').millisecondsSinceEpoch ~/ 1000);
      result.add(DateTime.parse('${date}31').millisecondsSinceEpoch ~/ 1000);
    } else {
      result.add(DateTime.parse('${date}01').millisecondsSinceEpoch ~/ 1000);
      if (mouth == '02') {
        if (int.tryParse(year)! % 4 == 0) {
          result
              .add(DateTime.parse('${date}29').millisecondsSinceEpoch ~/ 1000);
        } else {
          result
              .add(DateTime.parse('${date}28').millisecondsSinceEpoch ~/ 1000);
        }
      } else {
        result.add(DateTime.parse('${date}30').millisecondsSinceEpoch ~/ 1000);
      }
    }
    return result;
  }

  ///获取聊天时间，当日显示小时当年显示月日，其他时间显示年月日
  static String? toChatTime(int time) {
    if (isItTheSameDay(time)) {
      final utcTime2 = (getLocalTimeStamp() / 1000).floor();
      final spanTime = utcTime2 - time;
      if (spanTime < 60000 || spanTime < 0) {
        return '现在';
      } else if (spanTime < 3600000) {
        return '${(spanTime / 60000).floor()}分钟前';
      } else {
        return datetimeFormat(time, 'HH:mm');
      }
    } else {
      final int now = (timeToTimeStamp(getNow())).floor();

      if (DateTime.fromMillisecondsSinceEpoch(time * 1000).year ==
          DateTime.fromMillisecondsSinceEpoch(now * 1000).year) {
        return datetimeFormat(time, 'MM-dd');
      } else {
        return datetimeFormat(time, 'yyyy-MM-dd');
      }
    }
  }

  static String secToMSTime(int? sec) {
    if (sec == null) {
      return '0';
    }
    String result = '';
    if (sec > 3600) {
      result =
          '${sec ~/ 3600} : ${(sec % 3600) ~/ 60} : ${(sec % 3600) % 60 > 9 ? (sec % 3600) % 60 : '0${(sec % 3600) % 60}'}';
    } else {
      result = '${sec ~/ 60} : ${sec % 60 > 9 ? sec % 60 : '0${sec % 60}'}';
    }

    return result;
  }

  //将时间戳格式化(这里的时间是后端服务器的13位数时间戳)
  static String? millDatetimeFormat(int date, String type) {
    if (date == 0) {
      return null;
    }
    return DateFormat(type).format(DateTime.fromMillisecondsSinceEpoch(date).toUtc().add(zone));
  }
}

extension GenerateDate on num {
  String? get getLocalTimeStamp {
    return DateTimeHelper.datetimeFormat(this as int, 'yyyy-MM-dd');
  }
}

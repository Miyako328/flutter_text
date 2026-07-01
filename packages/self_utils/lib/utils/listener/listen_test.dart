import 'package:flutter/cupertino.dart';
import 'package:self_utils/utils/event_bus/event_util.dart';
import 'package:self_utils/global/store.dart';
import 'package:self_utils/utils/utils.dart';

//监听案例实现
class ListenStateTest {
  static final StreamController<ListenTestModel> _controller =
      StreamController<ListenTestModel>.broadcast();

  static const String _key = 'listenKey';

  static int getNum() {
    return LocateStorage.getInt(_key) ?? 0;
  }

  static void setNum(ListenTestModel test) {
    _controller.add(test);
    LocateStorage.setInt(_key, test.num);
  }

  //清楚缓存
  static void clear() {
    LocateStorage.clean(key: _key);
  }

  static CancelCallBack listenNum(
      {required Function(ListenTestModel test) listenFunc}) {
    final CancelCallBack callBack =
        _controller.stream.listen((ListenTestModel event) {
      listenFunc(event);
    }).cancel;
    return callBack;
  }
}

class ListenTestModel {
  late int num;
}

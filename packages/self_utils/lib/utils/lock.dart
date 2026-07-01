import 'dart:async';

//使用例子请看[mutex]方法
class Lock {
  Completer<void>? _completer;

  Future<T> mutex<T>(Future<T> Function() callback) async {
    await lock();
    try {
      return await callback();
    } finally {
      unlock();
    }
  }

  bool isUsing() => _completer != null;

  Future<void> waitDone(){
    assert(_completer!=null);
    return _completer!.future;
  }

  Future<void> lock() async {
    if (_completer != null) {
      await _completer!.future;
      return lock();
    }

    _completer = Completer<void>();
    return;
  }

  void unlock() {
    if (_completer == null) {
      throw Exception('锁状态错误');
    }
    _completer?.complete();
    _completer = null;
  }
}
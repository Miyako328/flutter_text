import 'dart:async';

//eventBus封装
class EventBusHelper {
  //ignore:close_sinks
  static final StreamController<void>? asyncStreamController =
  _GetAsyncStreamController.getInstance();

  static StreamSubscription<void> listen<T>(void onData(T event),
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    return asyncStreamController!.stream.listen((dynamic event) {
      if (event is T) {
        onData(event);
      }
    }, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _GetAsyncStreamController {
  _GetAsyncStreamController._();

  //ignore:close_sinks
  static StreamController<void>? _asyncStreamController;

  static StreamController<void>? getInstance() {
    _asyncStreamController ??= StreamController<void>.broadcast();
    return _asyncStreamController;
  }
}

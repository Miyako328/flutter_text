import 'package:event_bus/event_bus.dart';
export 'dart:async';

class EventBusUtil {
  static EventBus? _eventBus;
  static EventBus? getInstance() {
    _eventBus ??= EventBus();
    return _eventBus;
  }
}

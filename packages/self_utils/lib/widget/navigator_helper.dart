import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class NavigatorHelper {
  static late NavigatorState _navigatorState;

  static Future<NavigatorState> get navigatorState async {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      final Completer<NavigatorState> completer = Completer<NavigatorState>();
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) async {
        completer.complete(_navigatorState);
      });
      return completer.future;
    } else {
      return _navigatorState;
    }
  }

  static void _configNavigatorState(BuildContext context) {
    void visitor(Element element) {
      if (element.widget is Navigator) {
        _navigatorState = (element as StatefulElement).state as NavigatorState;
      } else {
        element.visitChildElements(visitor);
      }
    }

    context.visitChildElements(visitor);
  }
}

class NavigatorInitializer extends StatefulWidget {
  final Widget child;

  const NavigatorInitializer({Key? key, required this.child}) : super(key: key);

  @override
  _NavigatorInitializerState createState() => _NavigatorInitializerState();
}

class _NavigatorInitializerState extends State<NavigatorInitializer> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigatorHelper._configNavigatorState(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didUpdateWidget(NavigatorInitializer oldWidget) {
    super.didUpdateWidget(oldWidget);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigatorHelper._configNavigatorState(context);
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }
}


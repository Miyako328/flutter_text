import 'package:flutter/material.dart';
import 'package:self_utils/utils/log_utils.dart';

class AppLifecycleWidget extends StatefulWidget {
  final Widget child;

  const AppLifecycleWidget({Key? key, required this.child});

  @override
  _AppLifecycleWidgetState createState() => _AppLifecycleWidgetState();
}

class _AppLifecycleWidgetState extends State<AppLifecycleWidget>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Log.info('==========Now AppLifeCycle is $state');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

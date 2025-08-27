import 'package:flutter/material.dart';

import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/widget/navigator_helper.dart';

class ApiTextPage extends StatefulWidget {
  @override
  _ApiTextState createState() => _ApiTextState();
}

class _ApiTextState extends State<ApiTextPage> {
  @override
  void initState() {
    super.initState();
  }

  /// [NavigatorState]的route.overlayEntries
  Future<void> _getRoute() async {
    final NavigatorState navigatorHelper = await NavigatorHelper.navigatorState;
    navigatorHelper.popUntil((Route route) {
      Log.info(route);
      return route.isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('401 text'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                _getRoute();
              },
              child: const Text('401'),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

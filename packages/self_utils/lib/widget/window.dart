import 'dart:developer';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:self_utils/global/utils_global.dart';
import 'package:self_utils/utils/event_bus_helper.dart';
import 'package:self_utils/utils/log_utils.dart';

import 'float_box.dart';

class WindowsWidget extends StatefulWidget {
  BuildContext outSideContext;
  Widget? child;

  WindowsWidget({required this.outSideContext, this.child});

  @override
  _WindowsWidgetState createState() => _WindowsWidgetState();
}

class _WindowsWidgetState extends State<WindowsWidget> {
  OverlayEntry? entry;
  VoidCallback? voidCallback;
  bool canPop = false;

  @override
  void initState() {
    super.initState();
    getPlatformType();
    setListen();
  }

  void setListen() {
    final Future<void> Function() cancel = EventBusHelper.listen<EventCache>((EventCache event) {
      if (event.isRoute != null) {
        canPop = event.isRoute!;

        if (canPop == true) {
          entry = OverlayEntry(builder: (context) {
            return  FloatBox();
          });
          Overlay.of(widget.outSideContext)?.insert(entry!);
        } else {
          entry?.remove();
        }
        setState(() {});
      }
    }).cancel;

    voidCallback = cancel;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    voidCallback?.call();
  }

  void getPlatformType() {
    final Map<String, String> result = Platform.environment;
    Log.info(' =========================== $result');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}

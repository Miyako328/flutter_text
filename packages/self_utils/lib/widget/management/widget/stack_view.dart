import 'dart:math';

import 'package:flutter/material.dart';
import 'package:self_utils/widget/management/common/listenable.dart';
import 'package:self_utils/widget/management/common/view_key.dart';

abstract class StackViewListener {
  void onOpen(ViewKey key, WidgetBuilder createIfAbsent);

  void onClose(ViewKey key);
}

class StackController with GenericListenable<StackViewListener> {
  void open(ViewKey key, WidgetBuilder createIfAbsent) {
    foreach((StackViewListener entry) {
      entry.onOpen(key, createIfAbsent);
    });
  }

  void close(ViewKey key) {
    foreach((StackViewListener entry) {
      entry.onClose(key);
    });
  }
}

class StackView extends StatefulWidget {
  final StackController? controller;
  final Widget? child;
  final ValueChanged<ViewKey?>? onCurrentIndexChanged;

  const StackView({Key? key, this.controller, this.onCurrentIndexChanged, this.child}) : super(key: key);

  @override
  _StackViewState createState() => _StackViewState();
}

class _StackViewState extends State<StackView> implements StackViewListener {
  int _currentIndex = 0;
  final List<ViewKeyWidget> _list = <ViewKeyWidget>[];

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.removeListener(this);
  }

  @override
  void didUpdateWidget(covariant StackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(this);
      widget.controller?.addListener(this);
    }
  }

  @override
  void onOpen(ViewKey key, WidgetBuilder createIfAbsent) {
    _open(key, createIfAbsent);
  }

  @override
  void onClose(ViewKey key) {
    _close(key);
  }

  void _open(ViewKey key, WidgetBuilder createIfAbsent) {
    int index = _list.indexWhere((ViewKeyWidget element) => element.key == key);
    if (index == _currentIndex) {
      return;
    }

    if (index == -1) {
    } else {
      _list.removeAt(index);
    }
    _currentIndex = _list.length;
    _list.add(ViewKeyWidget(key: key, child: createIfAbsent(context)));
    widget.onCurrentIndexChanged?.call(_list[_currentIndex].key as ViewKey);
    _markNeedUpdate();
  }

  void _close(ViewKey key) {
    int index = _list.indexWhere((ViewKeyWidget element) => element.key == key);
    if (index == -1) {
      return;
    }
    _list.removeAt(index);
    if (index <= _currentIndex) {
      _currentIndex--;
      _currentIndex = max(0, _currentIndex);
      if(_list.isEmpty){
        widget.onCurrentIndexChanged?.call(null);
      }else{
        widget.onCurrentIndexChanged?.call(_list[_currentIndex].key as ViewKey);
      }
    }
    _markNeedUpdate();
  }

  void _markNeedUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _list.isNotEmpty ? IndexedStack(
      index: _currentIndex,
      children: _list,
    ) : Container(
      child: widget.child,
    );
  }
}

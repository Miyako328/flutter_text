import 'package:flutter/material.dart';

class BlocWidget<T extends BlocBase> extends StatefulWidget {
  final T? bloc;
  final Widget child;

  const BlocWidget({Key? key, required this.child, this.bloc});

  @override
  BlocWidgetState createState() => BlocWidgetState();

  static T? of<T extends BlocBase>(BuildContext context) {
    final BlocWidget<T>? provider =
        context.findAncestorWidgetOfExactType<BlocWidget<T>>();
    return provider?.bloc;
  }
}

class BlocWidgetState extends State<BlocWidget<BlocBase>> {
  @override
  void dispose() {
    super.dispose();
    widget.bloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

abstract class BlocBase {
  void dispose();
}

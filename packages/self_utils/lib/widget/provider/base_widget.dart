import 'package:flutter/material.dart';
import 'package:self_utils/widget/provider/base_model.dart';
import 'package:provider/provider.dart';

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  final Widget? child;
  final T model;

  const BaseView({Key? key, this.child, required this.model, required this.builder});

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  late T model;

  @override
  void initState() {
    model = widget.model;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
        child: Consumer<T>(
          builder: widget.builder,
          child: widget.child,
        ),
        create: (BuildContext context) {
          return model;
        });
  }
}

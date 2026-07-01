import 'package:flutter/material.dart';

class OpaqueMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  OpaqueMaterialPageRoute({
    required this.builder,
    this.maintainState = true,
  }) : super();

  @override
  bool get opaque => false;

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

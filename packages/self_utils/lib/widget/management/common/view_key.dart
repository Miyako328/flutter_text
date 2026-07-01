import 'package:flutter/material.dart';


class ViewKey implements LocalKey {
  final String namespace;

  final String id;

  const ViewKey({required this.namespace, required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewKey &&
          runtimeType == other.runtimeType &&
          namespace == other.namespace &&
          id == other.id;

  @override
  int get hashCode => namespace.hashCode ^ id.hashCode;
}

class ViewKeyWidget extends StatelessWidget {
  final Widget child;

  const ViewKeyWidget({required ViewKey key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class ConstViewKey {
  static const ViewKey promotionalInfo = ViewKey(namespace: 'promotional', id: 'info');
  static const ViewKey manageListPage = ViewKey(namespace: 'manageList', id: 'manageList');

}

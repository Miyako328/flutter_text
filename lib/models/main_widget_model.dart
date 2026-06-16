import 'package:flutter/material.dart';

class MainWidgetModel {
  String title;
  Icon icon;
  Widget? route;
  void Function(BuildContext context)? onTapFunc;
  String? category;
  String? description;
  List<String> tags;
  String? sourcePath;

  MainWidgetModel({
    required this.title,
    required this.icon,
    this.route,
    this.onTapFunc,
    this.category,
    this.description,
    this.tags = const <String>[],
    this.sourcePath,
  });

  bool get canOpen => route != null || onTapFunc != null;

  String get displayTitle {
    return title.replaceAll('--', '').trim();
  }

  bool matches(String keyword) {
    final String query = keyword.trim().toLowerCase();
    if (query.isEmpty) {
      return false;
    }
    return <String>[
      title,
      displayTitle,
      category ?? '',
      description ?? '',
      sourcePath ?? '',
      ...tags,
    ].any((String value) => value.toLowerCase().contains(query));
  }
}

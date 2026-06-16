import 'package:flutter_text/assembly_pack/layout_teach/basic/basic_type.dart';
import 'package:flutter_text/assembly_pack/layout_teach/basic/inheritwidget_test.dart';
import 'package:flutter_text/assembly_pack/layout_teach/material/material_main.dart';
import 'package:flutter_text/model/AComponent.dart';
import 'package:get/get.dart';

class StudyCenterController extends GetxController {
  final List<PageModel> pages = <PageModel>[
    PageModel()
      ..name = 'BasicTypePage'
      ..desc = 'Dart 和 Flutter 基础类型、基础组件入口'
      ..pageUrl = const BasicTypePage(),
    PageModel()
      ..name = 'Material3学习'
      ..desc = 'Material3 常用组件、导航、选择器、输入组件'
      ..pageUrl = const MaterialThreeMain(),
    PageModel()
      ..name = 'inheritedWidget'
      ..desc = 'InheritedWidget 状态传递和依赖更新示例'
      ..pageUrl = const InheritedWidgetTest(),
  ];
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_text/knowledge/knowledge_catalog.dart';
import 'package:flutter_text/models/main_widget_model.dart';

class KnowledgeSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  List<MainWidgetModel> results = <MainWidgetModel>[];

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_search);
  }

  void _search() {
    results = KnowledgeCatalog.search(textController.text);
    update();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:flutter_text/knowledge/knowledge_catalog.dart';
import 'package:flutter_text/models/main_widget_model.dart';

class KnowledgeHomeController extends GetxController {
  List<KnowledgeSection> get sections => KnowledgeCatalog.sections;

  List<MainWidgetModel> get recommended => KnowledgeCatalog.recommended;

  int get entryCount => KnowledgeCatalog.all.length;

  int get sidebarCount => KnowledgeCatalog.sidebarItems.length;
}

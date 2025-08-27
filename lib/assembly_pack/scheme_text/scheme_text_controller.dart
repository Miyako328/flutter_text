import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemeTextController extends GetxController {
  RxBool isLaunching = false.obs;
  RxString lastLaunchedUrl = ''.obs;
  RxString lastError = ''.obs;
  RxBool hasError = false.obs;
  RxString statusMessage = '准备启动'.obs;
  
  final List<String> launchHistory = <String>[].obs;
  final List<String> errorHistory = <String>[].obs;
  
  final List<SchemeAction> availableSchemes = [
    SchemeAction(
      name: '跳转到exhibition',
      scheme: 'exhibition://',
      type: SchemeType.custom,
    ),
    SchemeAction(
      name: '跳转到错误链接',
      scheme: 'exhibition//',
      type: SchemeType.invalid,
    ),
    SchemeAction(
      name: '跳转到flutter text',
      scheme: 'flutterTextLx://',
      type: SchemeType.custom,
    ),
    SchemeAction(
      name: '跳转到flutter.cn',
      scheme: 'https://flutter.cn',
      type: SchemeType.web,
    ),
  ];
  
  Future<void> launchScheme(String scheme) async {
    try {
      isLaunching.value = true;
      hasError.value = false;
      lastError.value = '';
      statusMessage.value = '正在启动...';
      
      print('Launching scheme: $scheme');
      
      final Uri uri = Uri.parse(scheme);
      final bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        final bool launched = await launchUrl(uri);
        
        if (launched) {
          lastLaunchedUrl.value = scheme;
          launchHistory.add('${DateTime.now().toString()}: $scheme');
          statusMessage.value = '启动成功';
          print('Scheme launched successfully: $scheme');
        } else {
          throw Exception('启动失败');
        }
      } else {
        throw Exception('无法启动此链接');
      }
      
    } catch (e) {
      hasError.value = true;
      lastError.value = e.toString();
      statusMessage.value = '启动失败';
      errorHistory.add('${DateTime.now().toString()}: $scheme - $e');
      print('Scheme launch error: $e');
    } finally {
      isLaunching.value = false;
    }
  }
  
  Future<void> launchExhibition() async {
    await launchScheme('exhibition://');
  }
  
  Future<void> launchInvalidScheme() async {
    await launchScheme('exhibition//');
  }
  
  Future<void> launchFlutterText() async {
    await launchScheme('flutterTextLx://');
  }
  
  Future<void> launchFlutterCN() async {
    await launchScheme('https://flutter.cn');
  }
  
  Future<void> launchCustomScheme(String scheme) async {
    await launchScheme(scheme);
  }
  
  Future<void> launchWebUrl(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    await launchScheme(url);
  }
  
  void clearHistory() {
    launchHistory.clear();
    errorHistory.clear();
  }
  
  void clearError() {
    hasError.value = false;
    lastError.value = '';
  }
  
  void clearLastLaunched() {
    lastLaunchedUrl.value = '';
  }
  
  void resetStatus() {
    statusMessage.value = '准备启动';
    clearError();
    clearLastLaunched();
  }
  
  void addCustomScheme(String name, String scheme) {
    availableSchemes.add(SchemeAction(
      name: name,
      scheme: scheme,
      type: SchemeType.custom,
    ));
  }
  
  void removeScheme(int index) {
    if (index >= 0 && index < availableSchemes.length) {
      availableSchemes.removeAt(index);
    }
  }
  
  void updateScheme(int index, String name, String scheme) {
    if (index >= 0 && index < availableSchemes.length) {
      availableSchemes[index] = SchemeAction(
        name: name,
        scheme: scheme,
        type: availableSchemes[index].type,
      );
    }
  }
  
  bool get canLaunch => !isLaunching.value;
  bool get hasLaunchHistory => launchHistory.isNotEmpty;
  bool get hasErrorHistory => errorHistory.isNotEmpty;
  bool get hasLaunched => lastLaunchedUrl.value.isNotEmpty;
  String get successCount => '成功: ${launchHistory.length}';
  String get errorCount => '失败: ${errorHistory.length}';
  int get totalSchemes => availableSchemes.length;
}

enum SchemeType {
  custom,
  web,
  invalid,
}

class SchemeAction {
  final String name;
  final String scheme;
  final SchemeType type;
  
  SchemeAction({
    required this.name,
    required this.scheme,
    required this.type,
  });
}

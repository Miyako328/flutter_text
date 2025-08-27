import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:self_utils/utils/local_log.dart';

class LogController extends GetxController {
  String log = '';
  RxBool isShow = false.obs;
  RxBool isLoading = true.obs;
  RxBool textFieldMouse = false.obs;
  RxString? key = ''.obs;
  TextEditingController controller = TextEditingController();
  late ScrollController scrollController;
  late ListObserverController observerController;
  RxList<int> searchIndexes = <int>[].obs;
  RxList<String> logList = <String>[].obs;
  RxInt index = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    observerController = ListObserverController(controller: scrollController);
    init();
  }
  
  Future<void> init() async {
    try {
      isLoading.value = true;
      log = await LocalLog.getLogInfo();
      logList.value = log.split('\n');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('Error initializing log: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void scrollToIndex(int targetIndex) {
    if (targetIndex >= 0 && targetIndex < searchIndexes.length) {
      observerController.jumpTo(index: searchIndexes[targetIndex]);
    }
  }
  
  void onSearchChanged(String value) {
    key?.value = value;
    searchIndexes.clear();
    index.value = 0;
    
    if (value.isNotEmpty) {
      for (int i = 0; i < logList.length; i++) {
        if (logList[i].toLowerCase().contains(value.toLowerCase())) {
          searchIndexes.add(i);
        }
      }
    }
  }
  
  void toggleShow() {
    isShow.value = !isShow.value;
  }
  
  void setTextFieldMouse(bool value) {
    textFieldMouse.value = value;
  }
  
  @override
  void onClose() {
    scrollController.dispose();
    controller.dispose();
    super.onClose();
  }
}

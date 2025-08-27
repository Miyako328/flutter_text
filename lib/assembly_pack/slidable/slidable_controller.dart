import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SlidableController extends GetxController {
  RxList<String> data = <String>['1', '2', '3', '4', '5', '6'].obs;
  RxBool isSliding = false.obs;
  RxInt slidingItemIndex = (-1).obs;
  RxString slidingDirection = 'none'.obs;
  RxString slideStatus = '准备就绪'.obs;
  
  final List<String> slideHistory = <String>[].obs;
  final List<String> actionHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  void _initializeData() {
    data.value = ['1', '2', '3', '4', '5', '6'];
  }
  
  void onItemReorder(int from, int to) {
    try {
      isSliding.value = true;
      slideStatus.value = '正在重新排序...';
      
      if (from >= 0 && from < data.length && to >= 0 && to < data.length) {
        final String temp = data[from];
        data[from] = data[to];
        data[to] = temp;
        
        _logSlideOperation('重新排序', from, to, temp);
        slideStatus.value = '重新排序完成';
        
        print('from: $from');
        print('to: $to');
        print(data);
      }
      
    } catch (e) {
      slideStatus.value = '重新排序失败: $e';
      print('Reorder error: $e');
    } finally {
      isSliding.value = false;
    }
  }
  
  void onSlideStart(int index, String direction) {
    slidingItemIndex.value = index;
    slidingDirection.value = direction;
    isSliding.value = true;
    slideStatus.value = '正在滑动...';
    
    _logSlideOperation('开始滑动', index, -1, direction);
  }
  
  void onSlideEnd(int index) {
    isSliding.value = false;
    slidingItemIndex.value = -1;
    slidingDirection.value = 'none';
    slideStatus.value = '滑动完成';
    
    _logSlideOperation('结束滑动', index, -1, '');
  }
  
  void onSlideAction(int index, String action) {
    try {
      slideStatus.value = '正在执行操作...';
      
      switch (action.toLowerCase()) {
        case 'delete':
        case '删除':
          _deleteItem(index);
          break;
        case 'edit':
        case '编辑':
          _editItem(index);
          break;
        case 'share':
        case '分享':
          _shareItem(index);
          break;
        case 'archive':
        case '归档':
          _archiveItem(index);
          break;
        default:
          _customAction(index, action);
      }
      
      _logAction('执行操作', index, action);
      slideStatus.value = '操作完成';
      
    } catch (e) {
      slideStatus.value = '操作失败: $e';
      print('Action error: $e');
    }
  }
  
  void _deleteItem(int index) {
    if (index >= 0 && index < data.length) {
      final deletedItem = data[index];
      data.removeAt(index);
      
      slideStatus.value = '删除项目: $deletedItem';
      print('Deleted item: $deletedItem at index: $index');
    }
  }
  
  void _editItem(int index) {
    if (index >= 0 && index < data.length) {
      slideStatus.value = '编辑项目: ${data[index]}';
      print('Edit item: ${data[index]} at index: $index');
    }
  }
  
  void _shareItem(int index) {
    if (index >= 0 && index < data.length) {
      slideStatus.value = '分享项目: ${data[index]}';
      print('Share item: ${data[index]} at index: $index');
    }
  }
  
  void _archiveItem(int index) {
    if (index >= 0 && index < data.length) {
      slideStatus.value = '归档项目: ${data[index]}';
      print('Archive item: ${data[index]} at index: $index');
    }
  }
  
  void _customAction(int index, String action) {
    if (index >= 0 && index < data.length) {
      slideStatus.value = '自定义操作: $action on ${data[index]}';
      print('Custom action: $action on ${data[index]} at index: $index');
    }
  }
  
  void _logSlideOperation(String operation, int from, int to, String item) {
    final timestamp = DateTime.now().toString();
    String logEntry;
    
    if (to >= 0) {
      logEntry = '$timestamp: $operation - 从位置$from到位置$to';
    } else {
      logEntry = '$timestamp: $operation - 位置$from';
    }
    
    if (item.isNotEmpty) {
      logEntry += ' (项目: $item)';
    }
    
    slideHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (slideHistory.length > 100) {
      slideHistory.removeAt(0);
    }
  }
  
  void _logAction(String operation, int index, String action) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $operation - 位置$index, 操作: $action';
    actionHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (actionHistory.length > 100) {
      actionHistory.removeAt(0);
    }
  }
  
  void addItem(String item) {
    data.add(item);
    _logSlideOperation('添加项目', data.length - 1, -1, item);
  }
  
  void updateItem(int index, String newValue) {
    if (index >= 0 && index < data.length) {
      final oldValue = data[index];
      data[index] = newValue;
      
      _logSlideOperation('更新项目', index, -1, '$oldValue -> $newValue');
    }
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < data.length) {
      final removedItem = data[index];
      data.removeAt(index);
      
      _logSlideOperation('移除项目', index, -1, removedItem);
    }
  }
  
  void clearData() {
    final itemCount = data.length;
    data.clear();
    
    _logSlideOperation('清空数据', -1, -1, '清除了$itemCount个项目');
  }
  
  void resetData() {
    _initializeData();
    slideStatus.value = '数据已重置';
  }
  
  void clearSlideHistory() {
    slideHistory.clear();
  }
  
  void clearActionHistory() {
    actionHistory.clear();
  }
  
  void shuffleData() {
    data.shuffle();
    _logSlideOperation('随机排序', -1, -1, '');
  }
  
  void sortData() {
    data.sort();
    _logSlideOperation('排序', -1, -1, '');
  }
  
  void reverseData() {
    final reversedList = data.reversed.toList();
    data.clear();
    data.addAll(reversedList);
    _logSlideOperation('反转', -1, -1, '');
  }
  
  bool get canSlide => !isSliding.value;
  bool get hasSlideHistory => slideHistory.isNotEmpty;
  bool get hasActionHistory => actionHistory.isNotEmpty;
  bool get isItemSliding => slidingItemIndex.value >= 0;
  String get slideDirectionInfo => '滑动方向: ${slidingDirection.value}';
  String get slideStatusInfo => '滑动状态: ${slideStatus.value}';
  String get dataInfo => '数据项: ${data.length}个';
  int get slideCount => slideHistory.length;
  int get actionCount => actionHistory.length;
}

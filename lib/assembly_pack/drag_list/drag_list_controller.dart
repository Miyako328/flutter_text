import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DragListController extends GetxController {
  RxList<String> data = <String>['1', '2', '3', '4', '5', '6'].obs;
  RxList<String> list1 = <String>['A', 'B', 'C'].obs;
  RxList<String> list2 = <String>['X', 'Y', 'Z'].obs;
  RxList<String> list3 = <String>['1', '2', '3'].obs;
  
  RxBool isDragging = false.obs;
  RxInt draggedItemIndex = (-1).obs;
  RxInt draggedListIndex = (-1).obs;
  RxString dragStatus = '准备就绪'.obs;
  
  final List<String> dragHistory = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeLists();
  }
  
  void _initializeLists() {
    // 初始化多个列表用于拖拽演示
    list1.value = ['A', 'B', 'C'];
    list2.value = ['X', 'Y', 'Z'];
    list3.value = ['1', '2', '3'];
  }
  
  void onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    try {
      isDragging.value = true;
      dragStatus.value = '正在重新排序...';
      
      // 获取源列表和目标列表
      RxList<String> sourceList = _getListByIndex(oldListIndex);
      RxList<String> targetList = _getListByIndex(newListIndex);
      
      if (sourceList != targetList) {
        // 跨列表拖拽
        final String item = sourceList[oldItemIndex];
        sourceList.removeAt(oldItemIndex);
        targetList.insert(newItemIndex, item);
        
        _logDragOperation('跨列表拖拽', oldListIndex, oldItemIndex, newListIndex, newItemIndex, item);
      } else {
        // 同列表内拖拽
        final String item = sourceList[oldItemIndex];
        sourceList.removeAt(oldItemIndex);
        sourceList.insert(newItemIndex, item);
        
        _logDragOperation('同列表拖拽', oldListIndex, oldItemIndex, newListIndex, newItemIndex, item);
      }
      
      dragStatus.value = '重新排序完成';
      
    } catch (e) {
      dragStatus.value = '重新排序失败: $e';
      print('Item reorder error: $e');
    } finally {
      isDragging.value = false;
    }
  }
  
  void onListReorder(int oldListIndex, int newListIndex) {
    try {
      isDragging.value = true;
      dragStatus.value = '正在重新排序列表...';
      
      // 这里可以实现列表重新排序的逻辑
      // 由于我们使用的是固定的列表，这里只是记录操作
      
      _logDragOperation('列表重排序', oldListIndex, -1, newListIndex, -1, '');
      dragStatus.value = '列表重新排序完成';
      
    } catch (e) {
      dragStatus.value = '列表重新排序失败: $e';
      print('List reorder error: $e');
    } finally {
      isDragging.value = false;
    }
  }
  
  RxList<String> _getListByIndex(int index) {
    switch (index) {
      case 0:
        return list1;
      case 1:
        return list2;
      case 2:
        return list3;
      default:
        return data;
    }
  }
  
  void _logDragOperation(String operation, int oldListIndex, int oldItemIndex, int newListIndex, int newItemIndex, String item) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $operation - 从列表${oldListIndex}项${oldItemIndex}到列表${newListIndex}项${newItemIndex}';
    if (item.isNotEmpty) {
      dragHistory.add('$logEntry (项目: $item)');
    } else {
      dragHistory.add(logEntry);
    }
    
    // 保持历史记录在合理范围内
    if (dragHistory.length > 100) {
      dragHistory.removeAt(0);
    }
  }
  
  void addItemToList(int listIndex, String item) {
    final list = _getListByIndex(listIndex);
    list.add(item);
  }
  
  void removeItemFromList(int listIndex, int itemIndex) {
    final list = _getListByIndex(listIndex);
    if (itemIndex >= 0 && itemIndex < list.length) {
      final removedItem = list[itemIndex];
      list.removeAt(itemIndex);
      
      final timestamp = DateTime.now().toString();
      dragHistory.add('$timestamp: 删除项目 - 列表${listIndex}项${itemIndex} (项目: $removedItem)');
    }
  }
  
  void updateItemInList(int listIndex, int itemIndex, String newValue) {
    final list = _getListByIndex(listIndex);
    if (itemIndex >= 0 && itemIndex < list.length) {
      final oldValue = list[itemIndex];
      list[itemIndex] = newValue;
      
      final timestamp = DateTime.now().toString();
      dragHistory.add('$timestamp: 更新项目 - 列表${listIndex}项${itemIndex} "$oldValue" -> "$newValue"');
    }
  }
  
  void clearList(int listIndex) {
    final list = _getListByIndex(listIndex);
    final itemCount = list.length;
    list.clear();
    
    final timestamp = DateTime.now().toString();
    dragHistory.add('$timestamp: 清空列表 - 列表${listIndex} (删除了${itemCount}个项目)');
  }
  
  void resetLists() {
    _initializeLists();
    dragStatus.value = '列表已重置';
  }
  
  void clearDragHistory() {
    dragHistory.clear();
  }
  
  void shuffleList(int listIndex) {
    final list = _getListByIndex(listIndex);
    list.shuffle();
    
    final timestamp = DateTime.now().toString();
    dragHistory.add('$timestamp: 随机排序 - 列表${listIndex}');
  }
  
  void sortList(int listIndex) {
    final list = _getListByIndex(listIndex);
    list.sort();
    
    final timestamp = DateTime.now().toString();
    dragHistory.add('$timestamp: 排序 - 列表${listIndex}');
  }
  
  void reverseList(int listIndex) {
    final list = _getListByIndex(listIndex);
    final reversedList = list.reversed.toList();
    list.clear();
    list.addAll(reversedList);
    
    final timestamp = DateTime.now().toString();
    dragHistory.add('$timestamp: 反转 - 列表${listIndex}');
  }
  
  bool get canDrag => !isDragging.value;
  bool get hasDragHistory => dragHistory.isNotEmpty;
  String get list1Info => '列表1: ${list1.length}个项目';
  String get list2Info => '列表2: ${list2.length}个项目';
  String get list3Info => '列表3: ${list3.length}个项目';
  int get totalItems => list1.length + list2.length + list3.length;
  String get dragStatusInfo => '拖拽状态: ${dragStatus.value}';
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class RefreshViewController extends GetxController {
  RxList<int> time = <int>[].obs;
  RxInt total = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxBool isLoadMore = false.obs;
  
  final List<Color> colors = [
    const Color(0x1db84329),
    const Color(0xffecad00),
    const Color(0xfff77200),
    const Color(0xcc9b4948),
    const Color(0xffea7c3f),
  ];
  
  @override
  void onInit() {
    super.onInit();
    load();
  }
  
  Future<void> load({bool isLoadMore = false}) async {
    try {
      if (isLoadMore == false) {
        time.clear();
        total.value = 0;
      }
      
      isLoading.value = true;
      const int top = 100;
      final int skip = isLoadMore ? total.value : 0;
      final List<int> result = [];

      for (int i = 0; i < top; i++) {
        result.add(i + skip);
      }

      time.addAll(result);
      total.value = time.length;
      
      // 模拟网络延迟
      await Future.delayed(Duration(milliseconds: 500));
      
    } catch (e) {
      print('Load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    try {
      isRefreshing.value = true;
      await load();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    try {
      isLoadMore.value = true;
      await load(isLoadMore: true);
    } finally {
      isLoadMore.value = false;
    }
  }
  
  void clearData() {
    time.clear();
    total.value = 0;
  }
  
  void addItem(int item) {
    time.add(item);
    total.value = time.length;
  }
  
  void removeItem(int index) {
    if (index >= 0 && index < time.length) {
      time.removeAt(index);
      total.value = time.length;
    }
  }
  
  void updateItem(int index, int newValue) {
    if (index >= 0 && index < time.length) {
      time[index] = newValue;
    }
  }
  
  void shuffleData() {
    time.shuffle();
  }
  
  void sortData() {
    time.sort();
  }
  
  void reverseData() {
    time = time.reversed.toList().obs;
  }
  
  void filterData(int minValue) {
    time.removeWhere((item) => item < minValue);
    total.value = time.length;
  }
  
  void resetData() {
    clearData();
    load();
  }
  
  Color getColorForIndex(int index) {
    final int colorIndex = index % colors.length;
    return colors[colorIndex];
  }
  
  bool get hasData => time.isNotEmpty;
  bool get canLoadMore => !isLoading.value && !isRefreshing.value;
  bool get isDataLoading => isLoading.value || isRefreshing.value || isLoadMore.value;
  String get statusMessage => isRefreshing.value 
      ? '正在刷新...' 
      : isLoadMore.value 
          ? '正在加载更多...' 
          : isLoading.value 
              ? '正在加载...' 
              : hasData 
                  ? '加载完成' 
                  : '暂无数据';
}

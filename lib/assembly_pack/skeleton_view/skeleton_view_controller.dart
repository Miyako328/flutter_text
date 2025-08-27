import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SqlUser {
  int? id;
  String? name;
  
  SqlUser({this.id, this.name});
}

class SkeletonViewController extends GetxController {
  RxList<SqlUser> users = <SqlUser>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSkeletonVisible = true.obs;
  RxInt totalCount = 0.obs;
  RxInt loadedCount = 0.obs;
  RxString statusMessage = '准备加载'.obs;
  
  // 模拟数据库提供者
  // UserDbProvider provider = UserDbProvider();
  
  @override
  void onInit() {
    super.onInit();
    load();
  }
  
  Future<void> load() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在加载...';
      
      // 模拟获取总数
      final int count = await _getTableCount();
      totalCount.value = count;
      
      // 创建骨架屏数据
      _createSkeletonData(count);
      
      // 模拟加载延迟
      await Future.delayed(Duration(seconds: 2));
      
      // 加载真实数据
      await _loadRealData();
      
      statusMessage.value = '加载完成';
      
    } catch (error, stack) {
      print('Load error: $error');
      statusMessage.value = '加载失败: $error';
    } finally {
      isLoading.value = false;
    }
  }
  
  void _createSkeletonData(int count) {
    users.clear();
    for (int i = 0; i < count; i++) {
      users.add(SqlUser()); // 空的SqlUser对象作为骨架屏
    }
    loadedCount.value = 0;
  }
  
  Future<int> _getTableCount() async {
    // 模拟数据库查询
    await Future.delayed(Duration(milliseconds: 500));
    return 10; // 返回模拟的总数
  }
  
  Future<void> _loadRealData() async {
    // 模拟从数据库获取用户数据
    final List<SqlUser> realUsers = [
      SqlUser(id: 1, name: '用户1'),
      SqlUser(id: 2, name: '用户2'),
      SqlUser(id: 3, name: '用户3'),
      SqlUser(id: 4, name: '用户4'),
      SqlUser(id: 5, name: '用户5'),
      SqlUser(id: 6, name: '用户6'),
      SqlUser(id: 7, name: '用户7'),
      SqlUser(id: 8, name: '用户8'),
      SqlUser(id: 9, name: '用户9'),
      SqlUser(id: 10, name: '用户10'),
    ];
    
    // 逐个替换骨架屏数据
    for (int i = 0; i < realUsers.length && i < users.length; i++) {
      await Future.delayed(Duration(milliseconds: 200)); // 模拟逐个加载
      users[i] = realUsers[i];
      loadedCount.value = i + 1;
    }
  }
  
  void refresh() {
    load();
  }
  
  void clearData() {
    users.clear();
    totalCount.value = 0;
    loadedCount.value = 0;
  }
  
  void addUser(String name) {
    final newUser = SqlUser(
      id: users.length + 1,
      name: name,
    );
    users.add(newUser);
    totalCount.value = users.length;
  }
  
  void removeUser(int index) {
    if (index >= 0 && index < users.length) {
      users.removeAt(index);
      totalCount.value = users.length;
      // 重新分配ID
      for (int i = 0; i < users.length; i++) {
        if (users[i].id != null) {
          users[i].id = i + 1;
        }
      }
    }
  }
  
  void updateUserName(int index, String newName) {
    if (index >= 0 && index < users.length) {
      users[index].name = newName;
    }
  }
  
  void toggleSkeleton() {
    isSkeletonVisible.value = !isSkeletonVisible.value;
  }
  
  void showSkeleton() {
    isSkeletonVisible.value = true;
  }
  
  void hideSkeleton() {
    isSkeletonVisible.value = false;
  }
  
  void resetData() {
    clearData();
    load();
  }
  
  bool get hasData => users.isNotEmpty;
  bool get isDataLoading => isLoading.value;
  bool get isSkeletonShown => isSkeletonVisible.value;
  double get loadingProgress => totalCount.value > 0 ? loadedCount.value / totalCount.value : 0.0;
  String get progressText => '${loadedCount.value}/${totalCount.value}';
  
  List<SqlUser> get skeletonUsers => users.where((user) => user.id == null).toList();
  List<SqlUser> get realUsers => users.where((user) => user.id != null).toList();
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class StorageTestController extends GetxController {
  final TextEditingController controller = TextEditingController();
  
  RxString inputText = ''.obs;
  RxString storedValue = ''.obs;
  RxBool isSaving = false.obs;
  RxBool isLoading = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  RxBool hasStoredData = false.obs;
  
  final List<String> storageHistory = <String>[].obs;
  final List<String> allKeys = <String>[].obs;
  
  static const String storageKey = 'StorageTest';
  
  @override
  void onInit() {
    super.onInit();
    controller.addListener(_onTextChanged);
    _loadStoredValue();
  }
  
  void _onTextChanged() {
    inputText.value = controller.text;
  }
  
  Future<void> _loadStoredValue() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在加载...';
      
      // 模拟从存储加载数据
      await Future.delayed(Duration(milliseconds: 300));
      
      // 这里应该调用实际的存储API
      // final String? value = LocateStorage.getString(storageKey);
      final String? value = _getMockStoredValue();
      
      if (value != null && value.isNotEmpty) {
        storedValue.value = value;
        controller.text = value;
        hasStoredData.value = true;
        statusMessage.value = '加载完成';
      } else {
        hasStoredData.value = false;
        statusMessage.value = '暂无缓存数据';
      }
      
    } catch (e) {
      statusMessage.value = '加载失败: $e';
      print('Load error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> save() async {
    if (inputText.value.isEmpty) {
      statusMessage.value = '请输入要保存的内容';
      return;
    }
    
    try {
      isSaving.value = true;
      statusMessage.value = '正在保存...';
      
      // 模拟保存延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 这里应该调用实际的存储API
      // LocateStorage.setString(storageKey, inputText.value);
      _setMockStoredValue(inputText.value);
      
      storedValue.value = inputText.value;
      hasStoredData.value = true;
      
      // 添加到历史记录
      storageHistory.add('${DateTime.now().toString()}: 保存 "$inputText"');
      
      statusMessage.value = '保存成功';
      print('Saved: ${inputText.value}');
      
    } catch (e) {
      statusMessage.value = '保存失败: $e';
      print('Save error: $e');
    } finally {
      isSaving.value = false;
    }
  }
  
  Future<void> getStoredValue() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在获取...';
      
      // 模拟获取延迟
      await Future.delayed(Duration(milliseconds: 300));
      
      // 这里应该调用实际的存储API
      // final String? value = LocateStorage.getString(storageKey);
      final String? value = _getMockStoredValue();
      
      if (value != null && value.isNotEmpty) {
        storedValue.value = value;
        controller.text = value;
        hasStoredData.value = true;
        statusMessage.value = '获取成功: $value';
      } else {
        storedValue.value = '';
        controller.text = '';
        hasStoredData.value = false;
        statusMessage.value = '暂无缓存数据';
      }
      
    } catch (e) {
      statusMessage.value = '获取失败: $e';
      print('Get error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> getAllKeys() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在获取所有键...';
      
      // 模拟获取延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 这里应该调用实际的存储API
      // LocateStorage.getAllKey();
      final mockKeys = _getMockAllKeys();
      allKeys.clear();
      allKeys.addAll(mockKeys);
      
      statusMessage.value = '获取完成，共${allKeys.length}个键';
      
    } catch (e) {
      statusMessage.value = '获取失败: $e';
      print('Get all keys error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> clearStorage() async {
    try {
      isLoading.value = true;
      statusMessage.value = '正在清除...';
      
      // 模拟清除延迟
      await Future.delayed(Duration(milliseconds: 800));
      
      // 这里应该调用实际的存储API
      // LocateStorage.clean();
      _clearMockStorage();
      
      storedValue.value = '';
      controller.text = '';
      hasStoredData.value = false;
      allKeys.clear();
      
      statusMessage.value = '清除完成';
      print('Storage cleared');
      
    } catch (e) {
      statusMessage.value = '清除失败: $e';
      print('Clear error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void clearInput() {
    controller.clear();
    inputText.value = '';
  }
  
  void clearHistory() {
    storageHistory.clear();
  }
  
  void resetStatus() {
    statusMessage.value = '准备就绪';
  }
  
  // 模拟存储方法
  String? _getMockStoredValue() {
    // 这里可以返回模拟的存储值
    return null; // 模拟没有存储数据
  }
  
  void _setMockStoredValue(String value) {
    // 这里可以设置模拟的存储值
    print('Mock storage set: $value');
  }
  
  List<String> _getMockAllKeys() {
    // 返回模拟的键列表
    return ['StorageTest', 'UserSettings', 'AppConfig', 'CacheData'];
  }
  
  void _clearMockStorage() {
    // 清除模拟存储
    print('Mock storage cleared');
  }
  
  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
  
  bool get canSave => !isSaving.value && inputText.value.isNotEmpty;
  bool get canGet => !isLoading.value;
  bool get canClear => !isLoading.value && hasStoredData.value;
  bool get hasInput => inputText.value.isNotEmpty;
  bool get hasHistory => storageHistory.isNotEmpty;
  bool get hasKeys => allKeys.isNotEmpty;
  String get inputLength => '输入长度: ${inputText.value.length}';
  String get storedLength => '存储长度: ${storedValue.value.length}';
}

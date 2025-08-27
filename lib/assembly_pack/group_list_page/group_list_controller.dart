import 'package:get/get.dart';
import 'package:self_utils/widget/group_list_widget.dart';

class GroupListController extends GetxController {
  final RxList<GroupListModel> data = <GroupListModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;
  RxBool showExpanded = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  void _initializeData() {
    try {
      isLoading.value = true;
      
      // 初始化示例数据
      data.addAll(<GroupListModel>[
        GroupListModel()..title = '技术组'..children = <String>['前端开发', '后端开发', '移动端开发'],
        GroupListModel()..title = '设计组'..children = <String>['UI设计', 'UX设计', '平面设计'],
        GroupListModel()..title = '产品组'..children = <String>['产品经理', '产品运营', '数据分析'],
        GroupListModel()..title = '测试组'..children = <String>['功能测试', '性能测试', '自动化测试'],
        GroupListModel()..title = '运维组'..children = <String>['系统运维', '网络运维', '安全运维'],
      ]);
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Initialize data error: $e');
    }
  }
  
  void addGroup(String title, List<String> children) {
    try {
      data.add(GroupListModel()..title = title..children = children);
    } catch (e) {
      print('Add group error: $e');
    }
  }
  
  void removeGroup(int index) {
    try {
      if (index >= 0 && index < data.length) {
        data.removeAt(index);
      }
    } catch (e) {
      print('Remove group error: $e');
    }
  }
  
  void updateGroup(int index, String title, List<String> children) {
    try {
      if (index >= 0 && index < data.length) {
        data[index] = GroupListModel()..title = title..children = children;
      }
    } catch (e) {
      print('Update group error: $e');
    }
  }
  
  void addChildToGroup(int groupIndex, String child) {
    try {
      if (groupIndex >= 0 && groupIndex < data.length) {
        data[groupIndex].children?.add(child);
      }
    } catch (e) {
      print('Add child to group error: $e');
    }
  }
  
  void removeChildFromGroup(int groupIndex, int childIndex) {
    try {
      if (groupIndex >= 0 && groupIndex < data.length) {
        final group = data[groupIndex];
        if (childIndex >= 0 && childIndex < (group.children?.length ?? 0)) {
          group.children?.removeAt(childIndex);
        }
      }
    } catch (e) {
      print('Remove child from group error: $e');
    }
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void clearSearch() {
    searchQuery.value = '';
  }
  
  void toggleExpanded() {
    showExpanded.value = !showExpanded.value;
  }
  
  void expandAll() {
    showExpanded.value = true;
  }
  
  void collapseAll() {
    showExpanded.value = false;
  }
  
  void refreshData() {
    try {
      isLoading.value = true;
      data.clear();
      _initializeData();
    } catch (e) {
      isLoading.value = false;
      print('Refresh data error: $e');
    }
  }
  
  void resetToDefault() {
    try {
      isLoading.value = true;
      data.clear();
      _initializeData();
      searchQuery.value = '';
      showExpanded.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Reset to default error: $e');
    }
  }
  
  List<GroupListModel> get filteredData {
    if (searchQuery.value.isEmpty) {
      return data;
    }
    
    return data.where((group) {
      return (group.title?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false) ||
             (group.children?.any((child) => 
               child.toLowerCase().contains(searchQuery.value.toLowerCase())) ?? false);
    }).toList();
  }
  
  int get totalGroups => data.length;
  int get totalChildren => data.fold(0, (sum, group) => sum + (group.children?.length ?? 0));
  bool get hasData => data.isNotEmpty;
  bool get hasSearchQuery => searchQuery.value.isNotEmpty;
  bool get isExpanded => showExpanded.value;
  
  String get searchStatus => hasSearchQuery 
      ? '搜索结果: ${filteredData.length} 个分组' 
      : '共 $totalGroups 个分组';
  
  String get dataInfo => '分组: $totalGroups, 子项: $totalChildren';
}

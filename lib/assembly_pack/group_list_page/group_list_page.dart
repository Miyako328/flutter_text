import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_utils/widget/group_list_widget.dart';
import 'group_list_controller.dart';

class GroupListPage extends StatelessWidget {
  const GroupListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GroupListController controller = Get.put(GroupListController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('分组列表'),
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
          IconButton(
            onPressed: controller.toggleExpanded,
            icon: Obx(() => Icon(
              controller.isExpanded ? Icons.expand_less : Icons.expand_more,
            )),
            tooltip: '切换展开状态',
          ),
        ],
      ),
      body: GetBuilder<GroupListController>(
        builder: (controller) => Column(
          children: [
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: '搜索分组或子项...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.hasSearchQuery
                      ? IconButton(
                          onPressed: controller.clearSearch,
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            
            // 状态信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    controller.searchStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  )),
                  Obx(() => Text(
                    controller.dataInfo,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 控制按钮
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.expandAll,
                      icon: const Icon(Icons.expand_more),
                      label: const Text('全部展开'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.collapseAll,
                      icon: const Icon(Icons.expand_less),
                      label: const Text('全部收起'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.resetToDefault,
                      icon: const Icon(Icons.restore),
                      label: const Text('重置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 加载状态
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('加载中...'),
                      ],
                    ),
                  ),
                );
              } else if (!controller.hasData) {
                return const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无数据'),
                      ],
                    ),
                  ),
                );
              } else {
                // 分组列表
                return Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GroupListWidget(
                      list: controller.filteredData,
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 添加新分组的逻辑
          _showAddGroupDialog(context, controller);
        },
        tooltip: '添加分组',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showAddGroupDialog(BuildContext context, GroupListController controller) {
    final titleController = TextEditingController();
    final childrenController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加新分组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '分组标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: childrenController,
              decoration: const InputDecoration(
                labelText: '子项 (用逗号分隔)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final childrenText = childrenController.text.trim();
              
              if (title.isNotEmpty) {
                final children = childrenText.isNotEmpty
                    ? childrenText.split(',').map((e) => e.trim()).toList()
                    : <String>[];
                
                controller.addGroup(title, children);
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
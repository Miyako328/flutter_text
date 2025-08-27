
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pc_keyboard_controller.dart';

class PCKeyboardPage extends StatelessWidget {
  const PCKeyboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PCKeyboardController controller = Get.put(PCKeyboardController());
    
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowUp): Increment(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): Decrement(),
      },
      child: Actions(
        actions: {
          Increment: CallbackAction<Increment>(
              onInvoke: (intent) => controller.incrementCounter()),
          Decrement: CallbackAction<Decrement>(
              onInvoke: (intent) => controller.decrementCounter()),
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('PC 键盘控制器'),
            actions: [
              IconButton(
                onPressed: controller.toggleKeyboardControl,
                icon: Obx(() => Icon(
                  controller.isKeyboardEnabled.value 
                      ? Icons.keyboard 
                      : Icons.block,
                )),
                tooltip: '切换键盘控制',
              ),
            ],
          ),
          body: GetBuilder<PCKeyboardController>(
            builder: (controller) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 状态显示
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                                                         Obx(() => Icon(
                               controller.isKeyboardEnabled.value 
                                   ? Icons.keyboard 
                                   : Icons.block,
                               color: controller.isKeyboardEnabled.value 
                                   ? Colors.green 
                                   : Colors.red,
                             )),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                    '键盘状态: ${controller.keyboardStatus}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  )),
                                  Obx(() => Text(
                                    controller.statusMessage.value,
                                    style: const TextStyle(fontSize: 14),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() => Text(
                          '计数器: ${controller.counter.value}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 控制按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.incrementCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('增加'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.decrementCounter,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('减少'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 重置按钮
                  ElevatedButton(
                    onPressed: controller.resetCounter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('重置计数器'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 键盘事件日志
                  if (controller.hasKeyboardEvents)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '键盘事件日志 (${controller.eventCount})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: controller.clearKeyboardEvents,
                                      icon: const Icon(Icons.clear),
                                      tooltip: '清除日志',
                                    ),
                                                                         IconButton(
                                       onPressed: controller.clearPressedKeys,
                                       icon: const Icon(Icons.block),
                                       tooltip: '清除按键状态',
                                     ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.keyboardEvents.length,
                                itemBuilder: (context, index) {
                                  final event = controller.keyboardEvents[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      event,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // 说明文字
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '使用说明:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• 使用键盘方向键 ↑↓ 控制计数器\n'
                          '• 空格键切换键盘控制状态\n'
                          '• 回车键确认当前值\n'
                          '• ESC键重置计数器',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.incrementCounter,
            tooltip: '增加',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
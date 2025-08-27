import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';

class GetBuilderTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetBuilder测试页面'),
      ),
      body: GetBuilder<MainController>(
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '当前标签页: ${controller.currentIndex.value + 1}',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                Text(
                  '点击次数: ${controller.tapTimes.value}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    controller.updateTapTimes(controller.tapTimes.value + 1);
                  },
                  child: Text('增加点击次数'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.onTabTapped((controller.currentIndex.value + 1) % 3);
                  },
                  child: Text('切换到下一个标签页'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 
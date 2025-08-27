import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DragText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('DragList可拖动列表组件'),
      ),
      body: DragDemo(),
    );
  }
}

class DragDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DragDemoState();
}

class DragDemoState extends State<DragDemo> {
  List<String> data = ['1', '2', '3', '4', '5', '6'];
  int a = 1;

  Widget build(BuildContext context) {
    return Container(
      // 改成使用[DragAndDropLists]
      child: DragAndDropLists(
        onItemReorder: (int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {

        },
        onListReorder: (int oldListIndex, int newListIndex) {

        },
        children: [],
      ),
    );
  }
}

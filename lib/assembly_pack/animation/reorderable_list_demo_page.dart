import 'package:flutter/material.dart';

class ReorderableListDemoPage extends StatefulWidget {
  const ReorderableListDemoPage({Key? key}) : super(key: key);

  @override
  State<ReorderableListDemoPage> createState() =>
      _ReorderableListDemoPageState();
}

class _ReorderableListDemoPageState extends State<ReorderableListDemoPage> {
  final List<String> _items = <String>[
    '设计走查',
    '接口联调',
    '动效验收',
    '发布检查',
    '复盘记录',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reorderable List')),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _items.length,
        proxyDecorator: (
          Widget child,
          int index,
          Animation<double> animation,
        ) {
          return ScaleTransition(
            scale: Tween<double>(begin: 1, end: 1.04).animate(animation),
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(8),
              child: child,
            ),
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final String item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        itemBuilder: (BuildContext context, int index) {
          return Container(
            key: ValueKey<String>(_items[index]),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_items[index]),
              subtitle: const Text('长按拖动调整顺序'),
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}

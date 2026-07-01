import 'package:flutter/material.dart';

class AnimatedListDemoPage extends StatefulWidget {
  const AnimatedListDemoPage({Key? key}) : super(key: key);

  @override
  State<AnimatedListDemoPage> createState() => _AnimatedListDemoPageState();
}

class _AnimatedListDemoPageState extends State<AnimatedListDemoPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _items = <String>[
    '消息提醒',
    '下载完成',
    '日程同步',
  ];
  int _nextIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedList')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '适合消息、任务、购物车等新增和删除场景。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _insertItem,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('新增'),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(18),
              initialItemCount: _items.length,
              itemBuilder: (
                BuildContext context,
                int index,
                Animation<double> animation,
              ) {
                return _buildItem(_items[index], index, animation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String text, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text('${index + 1}'),
              ),
              title: Text(text),
              subtitle: const Text('滑入、淡入，并在删除时收起'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _removeItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _insertItem() {
    const int index = 0;
    _items.insert(index, '新任务 ${_nextIndex++}');
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 360),
    );
  }

  void _removeItem(int index) {
    final String removed = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return _buildItem(removed, index, animation);
      },
      duration: const Duration(milliseconds: 300),
    );
  }
}

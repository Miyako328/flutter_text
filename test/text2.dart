import 'package:flutter/material.dart';
import 'package:flutter_text/gen/assets.gen.dart';

/// 开卷2 4题
class MyDraggableWidget extends StatefulWidget {
  const MyDraggableWidget({super.key});

  @override
  State<MyDraggableWidget> createState() => _MyDraggableWidgetState();
}

class _MyDraggableWidgetState extends State<MyDraggableWidget> {
  @override
  Widget build(BuildContext context) {
    /// 底部页面拖拽框
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          color: Colors.blueGrey[50],
          child: ListView.builder(
            controller: scrollController,
            itemCount: 30,
            itemBuilder: (BuildContext context, int index) {
              return buttonWidget(
                index: index,
              );
            },
          ),
        );
      },
    );
  }
}

// 按钮页面 点击变蓝色长安变灰
class buttonWidget extends StatefulWidget {
  int index;

  buttonWidget({super.key, required this.index});

  @override
  State<buttonWidget> createState() => _buttonWidgetState();
}

class _buttonWidgetState extends State<buttonWidget> {
  String type = 'normal';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          InkWell(
            onTap: () {
              type = 'click';
              setState(() {});
            },
            onLongPress: () {
              type = 'delete';
              setState(() {});
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: type == 'click' ? Colors.blue : null,
                border: Border.all(
                  color: type == 'click'
                      ? Colors.lightBlueAccent
                      : type == 'delete'
                          ? Colors.black26
                          : Colors.black,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                '${widget.index}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: type == 'click'
                      ? Colors.lightBlueAccent
                      : type == 'delete'
                          ? Colors.black26
                          : null,
                ),
              ),
            ),
          ),
          Text(
            '1232312312312321312312',
            style: type == 'delete'
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// 开卷3
class MyPicWidget extends StatefulWidget {
  const MyPicWidget({super.key});

  @override
  State<MyPicWidget> createState() => _MyPicWidgetState();
}

class _MyPicWidgetState extends State<MyPicWidget> {
  List<dynamic> a = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  //初始化
  void init() {
    a = getListData();
    if (a.isEmpty || a == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: const Text('Notification'),
              content: Text('无信息'),
            );
          });
    }
    setState(() {});
  }

  //获取数据方法
  List<dynamic> getListData() {
    return [1, 2, 3, 5, 5, 4, 232, 323, 23, 23, 2];
  }

  //数据处理组件
  Widget _picWidget(int index) {
    return Stack(
      children: [
        Assets.imagesTimg3.image(
          fit: BoxFit.cover,
          height: 200.0,
          width: MediaQuery.of(context).size.width,
        ),
        Positioned(
          child: Container(
            child: Text('${index}'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    /// list
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _picWidget(index);
            },
            childCount: a.length,
          ),
        ),
      ],
    );
  }
}

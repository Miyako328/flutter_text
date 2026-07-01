import 'package:flutter/material.dart';
import 'package:self_utils/utils/log_utils.dart';

class ShareDataWidget extends InheritedWidget {
  final int data; // 需要共享的数据

  // 定义一个便捷方法，方便子树中widget获取共享数据
  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShareDataWidget>();
  }

  const ShareDataWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    return oldWidget.data != data;
  }
}

class _TextInheritedWidget extends StatefulWidget {
  @override
  _TextInheritedState createState() => _TextInheritedState();
}

class _TextInheritedState extends State<_TextInheritedWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(ShareDataWidget.of(context)!.data.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.info('data isChange');
  }
}

class InheritedShowPage extends StatefulWidget {
  @override
  _InheritedShowState createState() => _InheritedShowState();
}

class _InheritedShowState extends State<InheritedShowPage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: ShareDataWidget(
            key: const Key('inherited page'),
            data: count,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _TextInheritedWidget(),
                ),
                ElevatedButton(
                  onPressed: () {
                    count++;
                    setState(() {});
                  },
                  child: const Text('Add'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

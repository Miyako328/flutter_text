import 'package:flutter/cupertino.dart';
import 'package:flutter_text/init.dart';

//todo 有问题！！！ Ios组件
class CupertinoContextMenuPage extends StatefulWidget {
  @override
  _CupertinoContextMenuState createState() {
    return _CupertinoContextMenuState();
  }
}

class _CupertinoContextMenuState extends State<CupertinoContextMenuPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('CupertinoContextMenu'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 200),
            CupertinoContextMenu(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'CupertinoContextMenu',
                  style: TextStyle(
                      //设置字体样式
                      fontSize: 20,
                      decoration: TextDecoration.none,
                      color: Colors.white),
                ),
                color: Colors.red,
                height: 200,
                width: 400,
              ),
              actions: <Widget>[
                CupertinoContextMenuAction(
                  child: const Text('Navigator.pop(context)'),
                  onPressed: () {
                    Navigator.pop(context);
                    Log.info('message');
                  },
                ),
                CupertinoContextMenuAction(
                  child: const Text('Navigator.pop(context)'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}

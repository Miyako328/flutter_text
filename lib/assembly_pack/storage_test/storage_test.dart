import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/global/store.dart';
import 'package:self_utils/utils/toast_utils.dart';

class StorageTest extends StatefulWidget {

  @override
  _StorageTestState createState() => _StorageTestState();
}

class _StorageTestState extends State<StorageTest> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void save() {
    LocateStorage.setString('StorageTest', controller.text);
    ToastUtils.showToast(msg: '保存成功');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('缓存测试'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: controller,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '保存',
                ),
                onPressed: () {
                  save();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '获取缓存',
                ),
                onPressed: () {
                  final String? getValue =
                      LocateStorage.getString('StorageTest');
                  ToastUtils.showToast(msg: getValue ?? '暂无缓存');
                  setState(() {
                    controller.text = getValue ?? '';
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '获取所有缓存',
                ),
                onPressed: () {
                  LocateStorage.getAllKey();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: Text(
                  '清除缓存',
                ),
                onPressed: () {
                  LocateStorage.clean();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

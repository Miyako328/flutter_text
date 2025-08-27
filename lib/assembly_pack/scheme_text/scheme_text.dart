import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/web_url.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemeText extends StatefulWidget {

  @override
  _SchemeTextState createState() => _SchemeTextState();
}

class _SchemeTextState extends State<SchemeText> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('scheme 测试'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '跳转到exhibition',
                ),
                onPressed: () async {
                  WebUrl.launchSchemeUrl('exhibition://');
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '跳转到错误链接',
                ),
                onPressed: () async {
                  WebUrl.launchSchemeUrl('exhibition//');
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '跳转到flutter text',
                ),
                onPressed: () async {
                  WebUrl.launchSchemeUrl('flutterTextLx://');
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: CupertinoButton(
                color: Theme.of(context).primaryColorDark,
                child: const Text(
                  '跳转到flutter.cn',
                ),
                onPressed: () async {
                  WebUrl.launchUrl('https://flutter.cn');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

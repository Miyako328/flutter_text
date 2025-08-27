import 'package:flutter/material.dart';

import 'icloud_utils.dart';

class ICloudView extends StatefulWidget {
  const ICloudView({super.key});

  @override
  State<ICloudView> createState() => _ICloudViewState();
}

class _ICloudViewState extends State<ICloudView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = 'https://www.icloud.com/sharedalbum/#B1tJtdOXmK1XeTT';
    setState(() {});
  }

  void checkAlbumUrl(String albumUrl) async {
    final album = await ICloudSharedAlbumRepository.getICloudAlbum(albumUrl);
  }

  void _onSubmitted(String value) {
    checkAlbumUrl(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iCloud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '请输入iCloud分享链接',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                // 在这里处理输入的iCloud分享链接
                print('输入的iCloud分享链接: $value');
                // 可以调用解析函数或其他操作
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 在这里处理按钮点击事件
                String link = _controller.text;
                print('输入的iCloud分享链接: $link');
                // 可以调用解析函数或其他操作
                _onSubmitted(link);
              },
              child: Text('解析链接'),
            ),
          ],
        ),
      ),
    );
  }
}

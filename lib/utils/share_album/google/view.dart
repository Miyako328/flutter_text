import 'package:flutter/material.dart';
import 'package:flutter_text/utils/share_album/google/google_utils.dart';

class GoogleView extends StatefulWidget {
  const GoogleView({super.key});

  @override
  State<GoogleView> createState() => _GoogleViewState();
}

class _GoogleViewState extends State<GoogleView> {
  final TextEditingController _controller = TextEditingController();

  /// https://photos.app.goo.gl/hSbm4B7884yTLXza7
  /// https://photos.google.com/share/AF1QipOUoyCG-Hf_N6sxUPIT_s5kIC7lHnndBEaoOHI3-UHpdNUgzsYg-nyoMrEmI5A9XQ?key=azRwa21Hend3NWxDODlBWlB2QmY0UG1wQU5rYzVR

  @override
  void initState() {
    super.initState();
    _controller.text = 'https://photos.app.goo.gl/hSbm4B7884yTLXza7';
    setState(() {});
  }

  void _onSubmitted(String value) async {
    await GoogleAlbumRepository.getAlbumData(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('google'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '请输入google分享链接',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                // 在这里处理输入的iCloud分享链接
                print('输入的google分享链接: $value');
                // 可以调用解析函数或其他操作
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 在这里处理按钮点击事件
                String link = _controller.text;
                print('输入的google分享链接: $link');
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

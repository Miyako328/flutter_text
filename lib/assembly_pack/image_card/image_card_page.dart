import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_text/gen/assets.gen.dart';
import 'package:flutter_text/init.dart';
import 'package:self_utils/init.dart';

import 'dart:ui' as ui;

class ImageCardPage extends StatefulWidget {
  const ImageCardPage({super.key});

  @override
  State<ImageCardPage> createState() => _ImageCardPageState();
}

class _ImageCardPageState extends State<ImageCardPage> {
  GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: _key,
        child: Container(
          child: Row(
            children: [
              Container(
                child: Assets.bannerBack.image(),
              ),
              const Expanded(
                child: Text('test'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTap,
      ),
    );
  }

  void _onTap() async {
    RenderRepaintBoundary boundary =
        _key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    // double dpr = ui.window.devicePixelRatio; //获取设备的像素
    ui.Image image = await boundary.toImage(pixelRatio: 0.8);
    ByteData? byteData = await image.toByteData();

    if (byteData != null) {
      Uint8List imagesBytes = byteData.buffer.asUint8List();
      Log.info(imagesBytes);
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/image_${DateTime.now().millisecond}.png')
              .create();
      await file.writeAsBytes(imagesBytes);
      await ImageGallerySaver.saveFile(file.path);
    }
  }
}

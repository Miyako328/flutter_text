import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_text/init.dart';

class DecodeGifPage extends StatefulWidget {
  @override
  _DecodeGifState createState() => _DecodeGifState();
}

class GifModel {
  int? duration;
  int? frameCount;
  List<List<List<Color>>>? value;

  GifModel({this.value, this.duration, this.frameCount});
}

class _DecodeGifState extends State<DecodeGifPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<int> _animation;

  List<List<List<Color>>> _gifFrames = [];

  @override
  void initState() {
    super.initState();
    _getDecodeGif().then((GifModel res) async {
      if (!mounted) return;

      _controller = AnimationController(
          vsync: this, duration: Duration(milliseconds: (res.frameCount??1) * (res.duration??1)));
      _animation = IntTween(begin: 0, end:(res.frameCount??1)).animate(_controller);

      _gifFrames = res.value??[];
      setState(() {
        _controller.repeat();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //获取gif图的帧数
  Future<GifModel> _getDecodeGif() async {
    final ByteData data = await rootBundle.load('images/test.gif');
    final Uint8List uintList = Uint8List.view(data.buffer);
    final ui.Codec code = await ui.instantiateImageCodec(uintList);
    Log.info(code.frameCount);
    final List<List<List<Color>>> frames = [];
    GifModel result;
    int sec = 0;

    final ui.FrameInfo frameInfo = await code.getNextFrame();
    final Duration duration = frameInfo.duration;
    final int width = frameInfo.image.width;
    final int height = frameInfo.image.height;
    sec = duration.inMilliseconds;
    Log.info(
        'width: $width height: $height duration: ${duration.inMilliseconds}');

    for (int i = 0; i < code.frameCount; i++) {
      final ui.FrameInfo frameInfo = await code.getNextFrame();

      final ByteData? byteData =
          await frameInfo.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final Uint8List uint8List = Uint8List.view(byteData!.buffer);

      final List<Color> colors = [];
      Color color;
      for (int j = 0, r, g, b, a; j < uint8List.length; j += 4) {
        r = uint8List[j + 0];
        g = uint8List[j + 1];
        b = uint8List[j + 2];
        a = uint8List[j + 3];
        color = Color.fromARGB(a, r, g, b);
        colors.add(color);
      }

      final int kv = math.sqrt(colors.length).toInt();
      final List<List<Color>> newArr = [];
      for (int i = 0; i < colors.length; i += kv) {
        newArr.add(
            colors.sublist(i, i + kv > colors.length ? colors.length : i + kv));
      }

      frames.add(newArr);
      frameInfo.image.dispose();
    }
    result = GifModel()
      ..value = frames
      ..frameCount = code.frameCount
      ..duration = sec;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_gifFrames.isNotEmpty)
                Container(
                  width: 60,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (BuildContext context, Widget? child) {
                        return AspectRatio(
                          aspectRatio: 1,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: SelfGif(
                              frames: _gifFrames,
                              frameIndex: _animation.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelfGif extends CustomPainter {
  final List<List<List<Color>>>? frames;

  final int frameIndex;

  const SelfGif({this.frames, this.frameIndex = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = math.min(size.width, size.height);
    final List<List<Color>> frame = ArrayHelper.get(frames!, frameIndex)!;
    final double perWidth = width / frame.length;

    final Paint paint = Paint();

    paint..isAntiAlias = true;

    paint.style = PaintingStyle.fill;
    Color color;

    for (int i = 0; i < frame.length; i++) {
      for (int j = 0; j < frame[i].length; j++) {
        color = frame[i][j];
        if (color.alpha == 0) continue;
        paint.color = color;
        canvas.drawRect(
            Rect.fromLTWH(j * perWidth, i * perWidth, perWidth, perWidth),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SelfGif oldDelegate) {
    return frameIndex != oldDelegate.frameIndex;
  }
}

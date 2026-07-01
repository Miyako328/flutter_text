import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_text/init.dart';

class GifModel {
  int? duration;
  int? frameCount;
  List<List<List<Color>>>? value;

  GifModel({this.value, this.duration, this.frameCount});
}

class DecodeGifController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> animation;

  RxList<List<List<Color>>> gifFrames = <List<List<Color>>>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentFrame = 0.obs;
  RxInt totalFrames = 0.obs;
  RxInt duration = 0.obs;
  RxInt width = 0.obs;
  RxInt height = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _getDecodeGif();
  }

  Future<void> _getDecodeGif() async {
    try {
      isLoading.value = true;
      final ByteData data = await rootBundle.load('assets/images/test.gif');
      final Uint8List uintList = Uint8List.view(data.buffer);
      final ui.Codec code = await ui.instantiateImageCodec(uintList);

      Log.info(code.frameCount);
      final List<List<List<Color>>> frames = [];
      GifModel result;
      int sec = 0;

      final ui.FrameInfo frameInfo = await code.getNextFrame();
      final Duration frameDuration = frameInfo.duration;
      final int frameWidth = frameInfo.image.width;
      final int frameHeight = frameInfo.image.height;
      sec = frameDuration.inMilliseconds;

      Log.info(
          'width: $frameWidth height: $frameHeight duration: ${frameDuration.inMilliseconds}');

      width.value = frameWidth;
      height.value = frameHeight;
      duration.value = sec;
      totalFrames.value = code.frameCount;

      for (int i = 0; i < code.frameCount; i++) {
        final ui.FrameInfo frameInfo = await code.getNextFrame();

        final ByteData? byteData = await frameInfo.image
            .toByteData(format: ui.ImageByteFormat.rawRgba);
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
          newArr.add(colors.sublist(
              i, i + kv > colors.length ? colors.length : i + kv));
        }

        frames.add(newArr);
        frameInfo.image.dispose();
      }

      result = GifModel()
        ..value = frames
        ..frameCount = code.frameCount
        ..duration = sec;

      gifFrames.value = frames;

      // 设置动画控制器
      controller = AnimationController(
          vsync: this,
          duration: Duration(
              milliseconds: (result.frameCount ?? 1) * (result.duration ?? 1)));
      animation =
          IntTween(begin: 0, end: (result.frameCount ?? 1)).animate(controller);

      controller.repeat();
    } catch (e) {
      print('Error decoding GIF: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void playAnimation() {
    controller.repeat();
  }

  void pauseAnimation() {
    controller.stop();
  }

  void setCurrentFrame(int frame) {
    currentFrame.value = frame;
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class HelloController extends GetxController {
  RxBool isLoading = false.obs;
  RxInt frameCount = 0.obs;
  RxString planeImagePath = "assets/images/plane2.gif".obs;

  @override
  void onInit() {
    super.onInit();
    _getPlane();
  }

  //获取gif图的帧数
  Future<void> _getPlane() async {
    try {
      isLoading.value = true;
      final ByteData data = await rootBundle.load('assets/images/plane2.gif');
      final Uint8List uintList = Uint8List.view(data.buffer);
      final ui.Codec code = await ui.instantiateImageCodec(uintList);
      final ui.FrameInfo first = await code.getNextFrame();
      frameCount.value = code.frameCount;
      print('Frame count: ${code.frameCount}');
    } catch (e) {
      print('Error loading plane: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
  }

  void restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}

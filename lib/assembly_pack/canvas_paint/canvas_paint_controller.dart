import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LinePoints {
  final List<Offset> points;
  final Color color;

  LinePoints(this.points, this.color);
}

class CanvasPaintController extends GetxController {
  RxList<LinePoints> lines = <LinePoints>[].obs;
  RxList<Offset> nowPoints = <Offset>[].obs;
  Rx<Color> nowColor = Colors.redAccent.obs;
  
  final List<Color> colors = <Color>[
    Colors.redAccent,
    Colors.pink,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.amber,
    Colors.purpleAccent,
    Colors.deepPurpleAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.cyanAccent,
  ];
  
  void moveGestureDetector(DragUpdateDetails detail, BuildContext context) {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Offset xy = box.globalToLocal(detail.globalPosition);
    Offset p = Offset(xy.dx, xy.dy - 60);
    nowPoints.add(p);
  }

  void newGestureDetector(DragStartDetails detail, BuildContext context) {
    if (nowPoints.isNotEmpty) {
      LinePoints l = LinePoints(List<Offset>.from(nowPoints), nowColor.value);
      lines.add(l);
      nowPoints.clear();
    }
    RenderBox box = context.findRenderObject() as RenderBox;
    final Offset xy = box.globalToLocal(detail.globalPosition);
    Offset p = Offset(xy.dx, xy.dy - 60);
    nowPoints.add(p);
  }

  void changeColor(Color c) {
    if (nowPoints.isNotEmpty) {
      final LinePoints l = LinePoints(List<Offset>.from(nowPoints), nowColor.value);
      lines.add(l);
    }
    nowPoints.clear();
    nowColor.value = c;
  }

  void tapClear() {
    lines.clear();
    nowPoints.clear();
  }

  void savePic() {
    // 保存图片的逻辑
    print('Saving picture...');
  }
  
  bool get isDrawing => nowPoints.isNotEmpty;
  int get lineCount => lines.length;
  int get pointCount => nowPoints.length;
}

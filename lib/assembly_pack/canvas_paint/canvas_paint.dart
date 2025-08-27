import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:self_utils/utils/screen.dart';

class PainterSketchDome extends StatefulWidget {
  PainterSketchDome({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _PainterSketchDomeState createState() => new _PainterSketchDomeState();
}

class _PainterSketchDomeState extends State<PainterSketchDome> {
  List<LinePoints> lines = <LinePoints>[];
  List<Offset> nowPoints = <Offset>[];
  Color nowColor = Colors.redAccent;

  void moveGestureDetector(DragUpdateDetails detail) {
    RenderBox box = context.findRenderObject() as RenderBox;
    final Offset xy = box.globalToLocal(detail.globalPosition); // 重要需要转换以下坐标位置
    Offset p = Offset(xy.dx, xy.dy - 60);
    //Offset p = Offset(detail.globalPosition.dx, detail.globalPosition.dy - 60);
    if (mounted) {
      setState(() {
        nowPoints.add(p);
      });
    }
  }

  void newGestureDetector(DragStartDetails detail) {
    if (nowPoints.length != 0) {
      LinePoints l = LinePoints(new List<Offset>.from(nowPoints), nowColor);
      lines.add(l);
      nowPoints.clear();
    }
    RenderBox box = context.findRenderObject() as RenderBox;
    final Offset xy = box.globalToLocal(detail.globalPosition); // 重要需要转换以下坐标位置
    Offset p = Offset(xy.dx, xy.dy - 60);
    if (mounted) {
      setState(() {
        nowPoints.add(p);
      });
    }
  }

  void changeColor(Color c) {
    if (nowPoints.isNotEmpty) {
      final LinePoints l = LinePoints(List<Offset>.from(nowPoints), nowColor);
      lines.add(l);
    }
    if (mounted) {
      setState(() {
        nowPoints.clear();
        nowColor = c;
      });
    }
  }

  List<Color> colors = <Color>[
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

  void _tapClear() {
    if (mounted) {
      setState(() {
        lines.clear();
        nowPoints.clear();
      });
    }
  }

  void _savePic() {}

  @override
  Widget build(BuildContext context) {
    List<Widget> pallet = <Widget>[];
    for (int i = 0; i < colors.length; i++) {
      Color c = colors[i];
      pallet.add(ColorPallet(
        color: c,
        changeColor: changeColor,
        isSelect: c == nowColor,
      ));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Scaffold(
          primary: false,
          body: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.black12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: pallet,
                  ),
                  height: 60.0,
                ),
                Expanded(
                    child: RepaintBoundary(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      child: CustomPaint(
                        painter: PaintCanvas(lines, nowPoints, nowColor),
                      ),
                      onHorizontalDragUpdate: moveGestureDetector,
                      onVerticalDragUpdate: moveGestureDetector,
                      onHorizontalDragStart: newGestureDetector,
                      onVerticalDragStart: newGestureDetector,
                    ),
                  ),
                ))
              ],
            ),
          ),
          floatingActionButton: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: _tapClear,
                heroTag: 'save',
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.save),
              ),
              Container(
                margin: EdgeInsets.only(right: screenUtil.adaptive(25)),
              ),
              FloatingActionButton(
                onPressed: _tapClear,
                heroTag: 'delete',
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                child: const Icon(Icons.delete),
              ),
            ],
          )),
    );
  }
}

class PaintCanvas extends CustomPainter {
  final List<LinePoints> lines;
  final List<Offset> nowPoints;
  final Color nowColor;

  PaintCanvas(this.lines, this.nowPoints, this.nowColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    canvas.save();
    for (int i = 0; i < lines.length; i++) {
      final LinePoints l = lines[i];
      for (int j = 1; j < l.points.length; j++) {
        final Offset p1 = l.points[j - 1];
        final Offset p2 = l.points[j];
        p.color = l.lineColor;
        canvas.drawLine(p1, p2, p);
      }
    }
    for (int i = 1; i < nowPoints.length; i++) {
      final Offset p1 = nowPoints[i - 1];
      final Offset p2 = nowPoints[i];
      p.color = nowColor;
      canvas.drawLine(p1, p2, p);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class LinePoints {
  final List<Offset> points;
  final Color lineColor;

  LinePoints(this.points, this.lineColor);
}

class ColorPallet extends StatelessWidget {
  final Color? color;
  final Function? changeColor;

  const ColorPallet({Key? key, this.color, this.changeColor, this.isSelect = false})
      : super(key: key);
  final bool isSelect;

  void onPressed() {
    changeColor?.call(color);
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 60.0, minHeight: 50.0),
      child: Container(
        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(25.0)),
            border:
                Border.all(color: Colors.white, width: isSelect ? 3.0 : 0.0)),
      ),
    );
  }
}

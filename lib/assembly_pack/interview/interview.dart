import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class InterViewPage extends StatefulWidget {
  @override
  _InterViewState createState() => _InterViewState();
}

Rect axisAlignedBoundingBox(Quad quad) {
  double? xMin;
  double? xMax;
  double? yMin;
  double? yMax;
  for (final Vector3 point in <Vector3>[
    quad.point0,
    quad.point1,
    quad.point2,
    quad.point3
  ]) {
    if (xMin == null || point.x < xMin) {
      xMin = point.x;
    }
    if (xMax == null || point.x > xMax) {
      xMax = point.x;
    }
    if (yMin == null || point.y < yMin) {
      yMin = point.y;
    }
    if (yMax == null || point.y > yMax) {
      yMax = point.y;
    }
  }
  return Rect.fromLTRB(xMin??0, yMin??0, xMax??0, yMax??0);
}

class _InterViewState extends State<InterViewPage> {
  static const int _rowCount = 100;
  static const int _columnCount = 100;
  static const double _cellWidth = 200.0;
  static const double _cellHeight = 200.0;

  Quad? _cachedViewport;
  int? _firstVisibleColumn;
  int? _firstVisibleRow;
  int? _lastVisibleColumn;
  int? _lastVisibleRow;

  @override
  void initState() {
    super.initState();
  }

  //是否显示出来
  bool _isCellVisible(int row, int column, Quad viewport) {
    if (viewport != _cachedViewport) {
      final Rect aabb = axisAlignedBoundingBox(viewport);
      _cachedViewport = viewport;
      _firstVisibleRow = (aabb.top / _cellHeight).floor();
      _firstVisibleColumn = (aabb.left / _cellWidth).floor();
      _lastVisibleRow = (aabb.bottom / _cellHeight).floor();
      _lastVisibleColumn = (aabb.right / _cellWidth).floor();
    }
    return row >= _firstVisibleRow! &&
        row <= _lastVisibleRow! &&
        column >= _firstVisibleColumn! &&
        column <= _lastVisibleColumn!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InteractiveViewer.builder(
          builder: (BuildContext context, Quad viewport) {
        return Column(
          children: [
            for (int row = 0; row < _rowCount; row++)
              Row(
                children: [
                  for (int column = 0; column < _columnCount; column++)
                    _isCellVisible(row, column, viewport)
                        ? Container(
                            height: _cellHeight,
                            width: _cellWidth,
                            child: Image.asset(
                              'images/plane2.gif',
                              width: 60,
                            ),
                          )
                        : Container(width: _cellWidth, height: _cellHeight),
                ],
              )
          ],
        );
      }),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DragOverlay {
  static late Widget view;
  static OverlayEntry? _holder;

  static void remove() {
    if (_holder != null) {
      _holder?.remove();
      _holder = null;
    }
  }

  static void show({required BuildContext context, required Widget view}) {
    DragOverlay.view = view;
    remove();
    final OverlayEntry overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        top: MediaQuery.of(context).size.height * 0.7,
        child: _buildDraggable(context),
      );
    });
    Overlay.of(context)?.insert(overlayEntry);
    _holder = overlayEntry;
  }

  static Draggable _buildDraggable(context) {
    return Draggable(
      child: view,
      feedback: view,
      onDragStarted: () {},
      onDragEnd: (DraggableDetails detail) {
        createDragTarget(offset: detail.offset, context: context);
      },
      childWhenDragging: Container(),
      ignoringFeedbackSemantics: false,
    );
  }

  static void createDragTarget({required Offset offset, required BuildContext context}) {
    if (_holder != null) {
      _holder?.remove();
    }
    _holder = OverlayEntry(builder: (BuildContext context) {
      double maxY = MediaQuery.of(context).size.height - 100;
      double maxX = MediaQuery.of(context).size.width - 100;

      return Positioned(
        top: offset.dy < 50
            ? 50
            : offset.dy > maxY
                ? maxY
                : offset.dy,
        left: offset.dx < 0
            ? 0
            : offset.dx > maxX
                ? maxX
                : offset.dx,
        child: DragTarget(
          onWillAccept: (data) {
            print('onWillAccept:$data');

            ///返回true 会将data数据添加到candidateData列表中，false时会将data添加到rejectData
            return true;
          },
          onAccept: (data) {
            print('onAccept : $data');
          },
          onLeave: (data) {
            print('onLeave');
          },
          builder: (BuildContext context, List incoming, List rejected) {
            return _buildDraggable(context);
          },
        ),
      );
    });
    Overlay.of(context)?.insert(_holder!);
  }
}

class OverlayWidget extends StatelessWidget {
  final String title;
  final Widget child;

  const OverlayWidget({required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(title),
                InkWell(
                  onTap: () {
                    DragOverlay.remove();
                  },
                  child: const Icon(Icons.close),
                )
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

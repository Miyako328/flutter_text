import 'package:flutter/material.dart';
import 'package:self_utils/widget/slide_panel_left.dart';

class SlidingUpPanelText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingDemo(),
    );
  }
}

class SlidingDemo extends StatefulWidget {
  @override
  SlidingDemoState createState() => SlidingDemoState();
}

class SlidingDemoState extends State<SlidingDemo> {
  PanelController panel = PanelController();
  double offsetDistance = 0.0;
  double offsetXDistance = 0.0;
  double offsetY = 0;
  double offsetX = 0;

  @override
  void initState() {
    super.initState();
    _open();
  }

  void _open() {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SlidingUpPanel(
        controller: panel,
        slideDirection: SlideDirection.UP,
        minWidth: 0,
        maxWidth: 250,
        minHeight: 0,
        panel: Container(
          child: const Center(
            child: Text("评论区",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none)),
          ),
        ),
        body: GestureDetector(
          child: new ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: new Image.asset(
              "images/lake.jpg",
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            panel.close();
          },
          onHorizontalDragDown: (details) {
            // print(details.globalPosition.dy);
            offsetXDistance = details.globalPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            offsetX = details.globalPosition.dx - offsetXDistance;
            if (offsetX > 0) {
              print("向左" + offsetX.toString());
            } else {
              print("向右" + offsetX.toString());
              double position = offsetX.abs() / 300;
              position = position > 1 ? 1 : position;
              panel.setPanelPosition(position);
              if (position > 0.4) {
                panel.open();
              }
            }
          },
          onVerticalDragDown: (details) {
            // print(details.globalPosition.dy);
            offsetDistance = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (details) {
            offsetY = details.globalPosition.dy - offsetDistance;
            if (offsetY > 0) {
              print("向下" + offsetY.toString());
            } else {
              print("向上" + offsetY.toString());
              double position = offsetY.abs() / 300;
              position = position > 1 ? 1 : position;
              panel.setPanelPosition(position);
              if (position > 0.4) {
                panel.open();
              }
            }
          },
        ),
      ),
    );
  }
}

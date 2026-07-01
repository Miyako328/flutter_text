import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatBox extends StatefulWidget {
  final Widget? icon;
  final void Function()? onTap;

  const FloatBox({Key? key, this.onTap, this.icon});

  @override
  _FloatBoxState createState() => _FloatBoxState();
}

class _FloatBoxState extends State<FloatBox> {
  Offset offset = const Offset(10, kToolbarHeight + 100);

  Offset _calOffset(Size size, Offset offset, Offset nextOffset) {
    double dx = 0;
    if (offset.dx + nextOffset.dx <= 0) {
      dx = 0;
    } else if (offset.dx + nextOffset.dx >= (size.width - 50)) {
      dx = size.width - 50;
    } else {
      dx = offset.dx + nextOffset.dx;
    }
    double dy = 0;
    if (offset.dy + nextOffset.dy >= (size.height - 100)) {
      dy = size.height - 100;
    } else if (offset.dy + nextOffset.dy <= kToolbarHeight) {
      dy = kToolbarHeight;
    } else {
      dy = offset.dy + nextOffset.dy;
    }
    return Offset(
      dx,
      dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        appBarTheme: AppBarTheme.of(context).copyWith(
          
        ),
      ),
      child: Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanUpdate: (detail) {
            setState(() {
              offset =
                  _calOffset(MediaQuery.of(context).size, offset, detail.delta);
            });
            print(offset);
            print(MediaQuery.of(context).size.width);
          },
          onTap: () {
            widget.onTap?.call();
          },
          onPanEnd: (detail) {},
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              border: Border.all(width: 1, color: Colors.lightBlue),
              borderRadius: const BorderRadius.all(Radius.circular(33.0)),
            ),
            child: widget.icon ??
                const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

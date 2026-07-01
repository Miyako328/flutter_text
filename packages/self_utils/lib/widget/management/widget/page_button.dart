import 'dart:math';

import 'package:flutter/material.dart';

class PageButton extends StatefulWidget {
  ///当前的页数
  final int? current;

  ///总页数
  final int? total;

  final ValueChanged<int>? onChanged;

  const PageButton({Key? key, this.current, this.total, this.onChanged})
      : super(key: key);

  @override
  _PageButtonState createState() => _PageButtonState();
}

class _PageButtonState extends State<PageButton> {
  Widget buildPageButton(
      {String? text, VoidCallback? onTap, bool primary = false}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: OutlinedButton(
        onPressed: onTap,
        style: ButtonStyle(
            backgroundColor: primary
                ? MaterialStateProperty.all(Theme.of(context).primaryColor)
                : null),
        child: Text(
          text ?? '',
          style: TextStyle(color: primary ? Colors.white : null),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    if (widget.current != 0) {
      children.add(buildPageButton(
        onTap: () {
          widget.onChanged!(widget.current! - 1);
        },
        text: '上一页',
      ));
    }

    int start = max(widget.current! - 2, 0);
    int end = min(widget.current! + 3, widget.total!);

    final List<int> pages = <int>[];
    if (start != 0) {
      pages.add(0);
    }

    for (int i = start; i < end; i++) {
      pages.add(i);
    }

    if (end != widget.total) {
      pages.add(widget.total! - 1);
    }
    children.addAll(pages.map((e) => buildPageButton(
        onTap: () {
          widget.onChanged!(e);
        },
        primary: widget.current == e,
        text: (e+1).toString())));

    if (widget.current != widget.total!-1) {
      children.add(buildPageButton(
        onTap: () {
          widget.onChanged!(widget.current! + 1);
        },
        text: '下一页',
      ));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

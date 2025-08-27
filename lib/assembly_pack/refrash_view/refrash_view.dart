import 'dart:math';

import 'package:flutter/material.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/api_call_back.dart';
import 'package:self_utils/widget/refresh.dart';

///加载更多也没
class RefreshPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ViewBuild(),
    );
  }
}

class _ViewBuild extends StatefulWidget {
  @override
  _ViewBuildState createState() => _ViewBuildState();
}

class _ViewBuildState extends State<_ViewBuild> {
  List<int> time = <int>[];
  int total = 0;

  List<Color> colors = [
    const Color(0x1db84329),
    const Color(0xffecad00),
    const Color(0xfff77200),
    const Color(0xcc9b4948),
    const Color(0xffea7c3f),
  ];

  @override
  void initState() {
    super.initState();
    loadingCallback(() => load());
  }

  Future<void> load({bool isLoadMore = false}) async {
    if (isLoadMore == false) {
      setState(() {
        time = [];
        total = 0;
      });
    }
    const int top = 100;
    final int skip = isLoadMore ? total : 0;
    final List<int> result = [];

    for (int i = 0; i < top; i++) {
      result.add(i + skip);
    }

    setState(() {
      time.addAll(result.toList());
      total = time.length;
    });
  }

  Future<void> reFreshFunc() async {
    await loadingCallback(() => load());
  }

  Future<void> loadMoreFunc() async {
    await loadingCallback(() => load(isLoadMore: true));
  }

  @override
  Widget build(BuildContext context) {
    return Refresh(
      refreshFunc: (_) async => await reFreshFunc(),
      loadMoreFunc: (_) async => await loadMoreFunc(),
      child: RepaintBoundary(
        child: ListView(
          children: time.map((int e) {
            final int i = e % 5;
            return Container(
              padding: EdgeInsets.only(left: screenUtil.adaptive(20)),
              width: MediaQuery.of(context).size.width,
              color: ArrayHelper.get(colors, i),
              height: screenUtil.adaptive(120),
              child: Text('$e'),
            );
          }).toList(),
        ),
      ),
    );
  }
}

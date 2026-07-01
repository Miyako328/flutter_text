import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text/gen/assets.gen.dart';
import 'package:flutter_text/init.dart';

import 'setting.dart';
import 'game_main.dart';

class CellContainer extends StatelessWidget {
  Color backColor;
  int value;
  BlockType blockType;

  CellContainer({
    required this.backColor,
    required this.value,
    required this.blockType,
  });

  static GameSetting gameSetting = GameSetting();

  @override
  Widget build(BuildContext context) {
    Widget container;
    if (blockType == BlockType.figure) {
      //点击为数字
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[0]
              : gameSetting.c_A0BBFF[0],
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Text(
          "${value != 0 ? value : ''}",
          style: TextStyle(
              fontSize: screenUtil.getAutoSp(30), color: Colors.white),
        ),
      );
    } else if (blockType == BlockType.mine) {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[1]
              : gameSetting.c_A0BBFF[1],
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Assets.imagesBomb.image(),
      );
    } else if (blockType == BlockType.label) {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor == const Color(0xFF5ADFD0)
              ? gameSetting.c_5ADFD0[2]
              : gameSetting.c_A0BBFF[2],
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Assets.imagesFlag.image(),
      );
    } else {
      container = Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backColor,
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
      );
    }
    return container;
  }
}

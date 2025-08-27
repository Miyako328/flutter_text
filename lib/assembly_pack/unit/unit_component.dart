import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/assembly_pack/unit/SelectText.dart';
import 'package:flutter_text/assembly_pack/unit/StepView.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/model/AComponent.dart';
import 'package:self_utils/utils/array_helper.dart';

import '../mine_sweep/game_main.dart';
import '../popup_text/popup_text.dart';
import '../sudu/sudo_game.dart';
import 'Reorderable.dart';
import 'auto_complete_test.dart';
import 'curve_animated/curve_animated.dart';
import 'overlay_text.dart';

class UnitComponentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UnitComponentPageState();
}

class UnitComponentPageState extends State<UnitComponentPage> {
  List<PageModel> _page = [];

  @override
  void initState() {
    super.initState();
    _page = [
      PageModel()
        ..name = 'SelectTextPage'
        ..pageUrl = SelectTextPage(),
      PageModel()
        ..name = 'ReorderablePage'
        ..pageUrl = ReorderablePage(),
      PageModel()
        ..name = 'CurpertinoViewPage'
        ..pageUrl = CurpertinoViewPage(),
      PageModel()
        ..name = 'CurveAnimatedPage'
        ..pageUrl = CurveAnimatedPage(),
      PageModel()
        ..name = 'SudoGamePage'
        ..pageUrl = SudoGamePage(),
      PageModel()
        ..name = 'OverlayText'
        ..pageUrl = OverlayText(),
      // PageModel()
      //   ..name = 'JsonWidgetPage'
      //   ..pageUrl = const JsonWidgetPage(),
      PageModel()
        ..name = 'AutoCompleteTest'
        ..pageUrl = const AutoCompleteTest(),
      PageModel()
        ..name = 'MineSweeping'
        ..pageUrl = const MineSweeping(),
      PageModel()
        ..name = 'PopupTextPage'
        ..pageUrl = PopupTextPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('Unit_list'),
            )
          : null,
      body: Center(
        child: GridView.custom(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          childrenDelegate: SliverChildBuilderDelegate((context, index) {
            return GestureDetector(
              onTap: () {
                WindowsNavigator().pushWidget(
                  context,
                  ArrayHelper.get(_page, index)?.pageUrl,
                  title: ArrayHelper.get(_page, index)?.name,
                );
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(width: 1)),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('${ArrayHelper.get(_page, index)?.name}'),
              ),
            );
          }, childCount: _page.length),
        ),
      ),
    );
  }
}

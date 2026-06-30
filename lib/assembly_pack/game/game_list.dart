import 'package:flutter_text/assembly_pack/mine_sweep/game_main.dart';
import 'package:flutter_text/assembly_pack/paint/example_forth.dart';
import 'package:flutter_text/assembly_pack/sudu/sudo_game.dart';
import 'package:flutter_text/model/AComponent.dart';

import '../../init.dart';

class GameListPage extends StatefulWidget {
  const GameListPage({Key? key}) : super(key: key);

  @override
  State<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  List<PageModel> _page = <PageModel>[];

  @override
  void initState() {
    super.initState();
    _page = <PageModel>[
      PageModel()
        ..name = '五子棋'
        ..pageUrl = const PaintExampleForth(),
      PageModel()
        ..name = '扫雷'
        ..pageUrl = const MineSweeping(),
      PageModel()
        ..name = '数独'
        ..pageUrl = SudoGamePage(),
      PageModel()
        ..name = '迷宫'
        ..pageUrl = const MazeGamePage(),
      PageModel()
        ..name = '2048'
        ..pageUrl = const Game2048Page(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.custom(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          childrenDelegate: SliverChildBuilderDelegate((
            BuildContext context,
            int index,
          ) {
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

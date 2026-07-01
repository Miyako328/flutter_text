import 'dart:math';

import 'package:flutter_text/gen/assets.gen.dart';
import 'package:flutter_text/init.dart';
import 'package:self_utils/generated/l10n.dart';

import 'setting.dart';
import 'cell_container.dart';

enum BlockType {
  //数字
  figure,
  //雷
  mine,
  //标记
  label,
  //未标记（未被翻开）
  unlabeled,
}

class _MineSolverResult {
  final Set<Point<int>> safeCells;
  final Set<Point<int>> mineCells;
  final List<String> logs;

  const _MineSolverResult({
    required this.safeCells,
    required this.mineCells,
    required this.logs,
  });
}

class _Constraint {
  final Set<Point<int>> cells;
  final int mines;

  const _Constraint({
    required this.cells,
    required this.mines,
  });
}

class MineSweeping extends StatefulWidget {
  const MineSweeping({Key? key}) : super(key: key);

  @override
  State<MineSweeping> createState() => _MineSweepingState();
}

class _MineSweepingState extends State<MineSweeping> {
  static GameSetting gameSetting = GameSetting();
  late List<List<int>> board; // 棋盘
  late List<List<bool>> revealed; // 记录格子是否被翻开
  late List<List<bool>> flagged; // 记录格子是否被标记
  late bool gameOver; // 游戏是否结束
  late bool win; // 是否获胜

  late int numRows; // 行数
  late int numCols; // 列数
  late int numMines; // 雷数
  int flags = 0; //棋子数量
  final Set<Point<int>> _safeHints = <Point<int>>{};
  final Set<Point<int>> _mineHints = <Point<int>>{};
  final List<String> _solverLogs = <String>[];

  //游戏时间
  late int _playTime;

  String get playTime {
    final int minutes = (_playTime ~/ 60);
    final int seconds = (_playTime % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Timer? _timer;

  ///重置游戏
  void reset() {
    setState(() {
      numRows = gameSetting.difficulty;
      numCols = gameSetting.difficulty;
      numMines = gameSetting.mines;
      flags = 0;
      // 初始化棋盘
      board = List<List<int>>.generate(
        numRows,
        (int index) => List<int>.filled(numCols, 0),
      );
      // 初始化格子是否被翻开
      revealed = List<List<bool>>.generate(
        numRows,
        (int index) => List<bool>.filled(numCols, false),
      );
      // 初始化格子是否被标记
      flagged = List<List<bool>>.generate(
        numRows,
        (int index) => List<bool>.filled(numCols, false),
      );
      // 将游戏定义为未结束
      gameOver = false;
      // 将游戏定义为还未获胜
      win = false;
      _safeHints.clear();
      _mineHints.clear();
      _solverLogs
        ..clear()
        ..add('新局开始：点击“算法分析”查看推理过程。');

      //在棋盘上随机放置地雷，直到放置的地雷数量达到预定的 numMines
      int numMinesPlaced = 0;
      while (numMinesPlaced < numMines) {
        //使用 Random().nextInt 方法生成两个随机数 i 和 j
        //分别用于表示棋盘中的行和列
        final int i = Random().nextInt(numRows);
        final int j = Random().nextInt(numCols);
        //通过 board[i][j] != -1 的判断语句，检查这个位置是否已经放置了地雷。如果没有
        //则将 board[i][j] 的值设置为 -1，表示在这个位置放置了地雷，并将 numMinesPlaced 的值加 1。
        if (board[i][j] != -1) {
          board[i][j] = -1;
          numMinesPlaced++;
        }
      }

      //计算每个非地雷格子周围的地雷数量
      //然后将计算得到的数量保存在对应的格子上。
      //通过两个嵌套的 for 循环遍历整个棋盘
      //内层的两个嵌套循环会计算这个格子周围的所有格子中地雷的数量
      //并将这个数量保存在 count 变量中
      for (int i = 0; i < numRows; i++) {
        for (int j = 0; j < numCols; j++) {
          //在每个单元格上，如果它不是地雷（值不为-1）
          //则内部嵌套两个循环遍历当前单元格周围的所有单元格
          //计算地雷数量并存储在当前单元格中。
          if (board[i][j] != -1) {
            int count = 0;
            //max(0, i - 1) 和 max(0, j - 1)
            //用于确保 i2 和 j2 不会小于 0，即不会越界到数组的负数索引。
            //min(numRows - 1, i + 1) 和 min(numCols - 1, j + 1) 用于确保 i2 和 j2 不会超出数组的边界
            // ·不会越界到数组的行列索引大于等于 numRows 和 numCols。
            for (int i2 = max(0, i - 1); i2 <= min(numRows - 1, i + 1); i2++) {
              for (int j2 = max(0, j - 1);
                  j2 <= min(numCols - 1, j + 1);
                  j2++) {
                if (board[i2][j2] == -1) {
                  count++;
                }
              }
            }
            board[i][j] = count;
          }
        }
      }
      //开始计时
      startTimer();
    });
  }

  void reveal(int i, int j) {
    if (!revealed[i][j] && !flagged[i][j] && !gameOver) {
      setState(() {
        _safeHints.clear();
        _mineHints.clear();
        //将该格子设置为翻开
        revealed[i][j] = true;

        //如果翻开的是地雷
        if (board[i][j] == -1) {
          //结束动画，将所有的地雷翻开
          for (int i2 = 0; i2 < numRows; i2++) {
            for (int j2 = 0; j2 < numCols; j2++) {
              if (board[i2][j2] == -1) {
                revealed[i2][j2] = true;
              }
            }
          }
          //游戏结束
          gameOver = true;
          stopTimer();
          //结束动画
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('${S.of(context).gameOverTitle}'),
              content: Text('${S.of(context).gameOverText}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    reset();
                    Navigator.pop(context);
                  },
                  child: Text('${S.of(context).playAgain}'),
                ),
              ],
            ),
          );
        }

        // 如果点击的格子周围都没有雷就自动翻开相邻的空格
        if (board[i][j] == 0) {
          for (int i2 = max(0, i - 1); i2 <= min(numRows - 1, i + 1); i2++) {
            for (int j2 = max(0, j - 1); j2 <= min(numCols - 1, j + 1); j2++) {
              if (!revealed[i2][j2]) {
                reveal(i2, j2);
              }
            }
          }
        }

        // 检查胜利条件
        if (checkWin()) {
          win = true;
          gameOver = true;
          stopTimer();
          //成功动画
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('${S.of(context).winTitle}'),
              content: Text('${S.of(context).winText}: $playTime'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    reset();
                    Navigator.pop(context);
                  },
                  child: Text('${S.of(context).playAgain}'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  //这段代码是用来检查游戏是否获胜的。
  //具体来说，它会遍历整个棋盘，检查每一个未被翻开的格子是否都是地雷，
  //如果有任何一个未翻开的格子不是地雷，就说明游戏还没有获胜，返回false。
  //如果所有未翻开的格子都是地雷，就说明游戏已经获胜了，返回true。
  //
  //这个函数被用于在用户点击一个格子后检查游戏是否获胜，以及在重置游戏时重新初始化游戏状态。
  //通过这样的方式，可以实现自动检查游戏是否获胜的功能，并且让用户能够清楚地知道游戏是否已经结束。
  bool checkWin() {
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        if (board[i][j] != -1 && !revealed[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  ///标记雷
  void toggleFlag(int i, int j) {
    if (!gameOver) {
      setState(() {
        _safeHints.clear();
        _mineHints.clear();
        flagged[i][j] = !flagged[i][j];
        final List<dynamic> list = ArrayHelper.flatten(flagged);
        flags =
            list.where((dynamic element) => element == true).toList().length;
      });
    }
  }

  void analyzeBoard() {
    final _MineSolverResult result = _solveVisibleBoard();
    setState(() {
      _safeHints
        ..clear()
        ..addAll(result.safeCells);
      _mineHints
        ..clear()
        ..addAll(result.mineCells);
      _solverLogs
        ..clear()
        ..addAll(result.logs);
    });
  }

  void algorithmStep() {
    final _MineSolverResult result = _solveVisibleBoard();
    setState(() {
      _safeHints
        ..clear()
        ..addAll(result.safeCells);
      _mineHints
        ..clear()
        ..addAll(result.mineCells);
      _solverLogs
        ..clear()
        ..addAll(result.logs);
    });

    bool changed = false;
    for (final Point<int> mine in result.mineCells) {
      if (!flagged[mine.x][mine.y] && !revealed[mine.x][mine.y]) {
        setState(() {
          flagged[mine.x][mine.y] = true;
          final List<dynamic> list = ArrayHelper.flatten(flagged);
          flags =
              list.where((dynamic element) => element == true).toList().length;
        });
        changed = true;
      }
    }
    if (changed) {
      setState(() {
        _solverLogs.add('执行：已自动标记确定是雷的格子。');
      });
      return;
    }

    if (result.safeCells.isNotEmpty) {
      final Point<int> safe = result.safeCells.first;
      setState(() {
        _solverLogs.add('执行：自动翻开安全格 (${safe.x + 1}, ${safe.y + 1})。');
      });
      reveal(safe.x, safe.y);
      return;
    }

    setState(() {
      _solverLogs.add('执行：没有确定安全或确定是雷的格子，需要猜测或继续手动打开信息。');
    });
  }

  _MineSolverResult _solveVisibleBoard() {
    final Set<Point<int>> safeCells = <Point<int>>{};
    final Set<Point<int>> mineCells = <Point<int>>{};
    final List<String> logs = <String>['开始分析：只使用已经翻开的数字格。'];
    final List<_Constraint> constraints = <_Constraint>[];

    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        if (!revealed[i][j] || board[i][j] <= 0) {
          continue;
        }
        final List<Point<int>> hidden = <Point<int>>[];
        int flaggedCount = 0;
        for (final Point<int> n in _neighbors(i, j)) {
          if (flagged[n.x][n.y]) {
            flaggedCount++;
          } else if (!revealed[n.x][n.y]) {
            hidden.add(n);
          }
        }
        final int remaining = board[i][j] - flaggedCount;
        if (hidden.isEmpty) {
          continue;
        }
        logs.add(
          '数字 (${i + 1}, ${j + 1}) = ${board[i][j]}：周围未开 ${hidden.length} 个，已标记 $flaggedCount 个，还需要 $remaining 个雷。',
        );
        constraints.add(_Constraint(cells: hidden.toSet(), mines: remaining));
        if (remaining == 0) {
          safeCells.addAll(hidden);
          logs.add('推理：剩余雷数为 0，所以这些未开格都安全。');
        } else if (remaining == hidden.length) {
          mineCells.addAll(hidden);
          logs.add('推理：剩余雷数等于未开格数量，所以这些格都是雷。');
        }
      }
    }

    for (int a = 0; a < constraints.length; a++) {
      for (int b = 0; b < constraints.length; b++) {
        if (a == b) {
          continue;
        }
        final _Constraint small = constraints[a];
        final _Constraint large = constraints[b];
        if (small.cells.length >= large.cells.length ||
            !large.cells.containsAll(small.cells)) {
          continue;
        }
        final Set<Point<int>> diff = large.cells.difference(small.cells);
        final int mineDiff = large.mines - small.mines;
        if (diff.isEmpty) {
          continue;
        }
        if (mineDiff == 0) {
          safeCells.addAll(diff);
          logs.add('集合推理：一个数字格包含另一个数字格的未知集合，差集雷数为 0，差集安全。');
        } else if (mineDiff == diff.length) {
          mineCells.addAll(diff);
          logs.add('集合推理：差集雷数等于差集格子数，差集全是雷。');
        }
      }
    }

    safeCells
        .removeWhere((Point<int> p) => revealed[p.x][p.y] || flagged[p.x][p.y]);
    mineCells.removeWhere((Point<int> p) => revealed[p.x][p.y]);
    safeCells.removeAll(mineCells);
    logs.add('结果：确定安全 ${safeCells.length} 个，确定是雷 ${mineCells.length} 个。');
    if (safeCells.isEmpty && mineCells.isEmpty) {
      logs.add('说明：当前信息不足，基础约束推理无法继续，需要打开更多格子或猜测。');
    }
    return _MineSolverResult(
      safeCells: safeCells,
      mineCells: mineCells,
      logs: logs,
    );
  }

  List<Point<int>> _neighbors(int row, int col) {
    final List<Point<int>> result = <Point<int>>[];
    for (int i = max(0, row - 1); i <= min(numRows - 1, row + 1); i++) {
      for (int j = max(0, col - 1); j <= min(numCols - 1, col + 1); j++) {
        if (i == row && j == col) {
          continue;
        }
        result.add(Point<int>(i, j));
      }
    }
    return result;
  }

  void changeDifficulty(int difficulty) {
    setState(() {
      gameSetting.difficulty = difficulty;
    });
    reset();
  }

  void changeThemeColor(Color color) {
    setState(() {
      gameSetting.themeColor = color;
    });
    reset();
  }

  void setting() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Setting!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    height: 24, child: Text('${S.of(context).themeColor}：')),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => changeThemeColor(const Color(0xFF5ADFD0)),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(
                          color: Color(0xFF5ADFD0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    GestureDetector(
                      onTap: () => changeThemeColor(const Color(0xFFA0BBFF)),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(
                          color: Color(0xFFA0BBFF),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24, child: Text('${S.of(context).gamePlay}：')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => changeDifficulty(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(color: Color(0xFFA0BBFF)),
                        width: 50,
                        height: 50,
                        child: Text(S.of(context).easy),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => changeDifficulty(12),
                      child: Container(
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(color: Color(0xFFEF9A0D)),
                        width: 50,
                        height: 50,
                        child: Text(S.of(context).normal),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => changeDifficulty(16),
                      child: Container(
                        alignment: Alignment.center,
                        decoration:
                            const BoxDecoration(color: Color(0xFFCE3C39)),
                        width: 50,
                        height: 50,
                        child: Text(S.of(context).hard),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  ///游戏计时器
  void startTimer() {
    const Duration duration = Duration(seconds: 1);
    _playTime = 0;
    _timer ??= Timer.periodic(duration, (Timer timer) {
      _playTime++;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? MediaQuery.of(context).size.width * 0.45
            : MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: Text(S.of(context).mineSweeping),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                    onPressed: () => setting(),
                    icon: const Icon(Icons.settings))
              ],
            )
          : null,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 96,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Assets.imagesBomb.image(),
                        Text(
                          '$numMines',
                          style: const TextStyle(fontSize: 28),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Assets.imagesFlag.image(),
                        Text(
                          '$flags',
                          style: const TextStyle(fontSize: 28),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton(
                    onPressed: reset,
                    child: const Text('重新开始'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: analyzeBoard,
                    icon: const Icon(Icons.psychology_outlined),
                    label: const Text('算法分析'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: algorithmStep,
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('算法走一步'),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.punch_clock_outlined),
                        Text(
                          playTime,
                          style: const TextStyle(fontSize: 28),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth > 900;
                final Widget boardWidget = RepaintBoundary(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: numCols,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final int i = index ~/ numCols;
                        final int j = index % numCols;
                        BlockType blockType;
                        //格子被翻开
                        if (revealed[i][j]) {
                          //是地雷
                          if (board[i][j] == -1) {
                            blockType = BlockType.mine;
                          } else {
                            blockType = BlockType.figure;
                          }
                        } else {
                          //被用户标记
                          if (flagged[i][j]) {
                            blockType = BlockType.label;
                          } else {
                            blockType = BlockType.unlabeled;
                          }
                        }
                        final Point<int> point = Point<int>(i, j);
                        final bool safeHint = _safeHints.contains(point);
                        final bool mineHint = _mineHints.contains(point);
                        return RepaintBoundary(
                          child: GestureDetector(
                            onTap: () {
                              Utils.checkTime(() => reveal(i, j));
                            },
                            onDoubleTap: () => toggleFlag(i, j),
                            onLongPress: () => toggleFlag(i, j),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: safeHint
                                      ? Colors.greenAccent
                                      : mineHint
                                          ? Colors.redAccent
                                          : Colors.transparent,
                                  width: safeHint || mineHint ? 3 : 0,
                                ),
                              ),
                              child: CellContainer(
                                backColor: gameSetting.themeColor,
                                value: revealed[i][j] && board[i][j] != 0
                                    ? board[i][j]
                                    : 0,
                                blockType: blockType,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: numRows * numCols,
                    ),
                  ),
                );
                final Widget logPanel = _MineSolverLogPanel(logs: _solverLogs);
                if (wide) {
                  return Row(
                    children: <Widget>[
                      Expanded(child: Center(child: boardWidget)),
                      SizedBox(width: 340, child: logPanel),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    Expanded(child: Center(child: boardWidget)),
                    SizedBox(height: 180, child: logPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !GlobalStore.isMobile
          ? FloatingActionButton(
              child: const Icon(Icons.settings),
              onPressed: () => setting(),
              tooltip: '设置',
            )
          : null,
    );
  }
}

class _MineSolverLogPanel extends StatelessWidget {
  final List<String> logs;

  const _MineSolverLogPanel({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Text(
                '扫雷算法日志',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      logs[index],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

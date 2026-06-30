import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_text/assembly_pack/animation/drop_selectable_widget.dart';
import 'package:flutter_text/init.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

import 'alert.dart';
import 'style.dart';

class _SudokuSolveStats {
  final int emptyCount;
  final int triedCount;
  final int backtrackCount;
  final int elapsedMicroseconds;
  final bool solved;

  const _SudokuSolveStats({
    required this.emptyCount,
    required this.triedCount,
    required this.backtrackCount,
    required this.elapsedMicroseconds,
    required this.solved,
  });

  const _SudokuSolveStats.empty()
      : emptyCount = 0,
        triedCount = 0,
        backtrackCount = 0,
        elapsedMicroseconds = 0,
        solved = false;
}

class _SudokuSolveResult {
  final List<List<int>> solvedGame;
  final _SudokuSolveStats stats;
  final List<String> logs;

  const _SudokuSolveResult({
    required this.solvedGame,
    required this.stats,
    required this.logs,
  });
}

class SudoGamePage extends StatefulWidget {
  @override
  _SudoGameState createState() => _SudoGameState();
}

class _SudokuStatsPanel extends StatelessWidget {
  final _SudokuSolveStats stats;

  const _SudokuStatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenUtil.adaptive(75)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Styles.grey.shade50.withValues(alpha: 0.12),
          border: Border.all(color: Styles.grey.shade100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _SudokuStatsChip(
                label: '回溯算法',
                value: stats.emptyCount == 0
                    ? '等待运行'
                    : stats.solved
                        ? '已求解'
                        : '无解',
              ),
              _SudokuStatsChip(label: '空格', value: '${stats.emptyCount}'),
              _SudokuStatsChip(label: '尝试', value: '${stats.triedCount}'),
              _SudokuStatsChip(label: '回退', value: '${stats.backtrackCount}'),
              _SudokuStatsChip(
                label: '耗时',
                value:
                    '${(stats.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SudokuStatsChip extends StatelessWidget {
  final String label;
  final String value;

  const _SudokuStatsChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(color: Styles.darkGrey, fontSize: 12),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  color: Styles.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SudokuLogsPanel extends StatelessWidget {
  final List<String> logs;
  final Size size;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragUpdateDetails> onResizeUpdate;
  final VoidCallback onClose;

  const _SudokuLogsPanel({
    required this.logs,
    required this.size,
    required this.onDragUpdate,
    required this.onResizeUpdate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Styles.darkGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: onDragUpdate,
                    child: SizedBox(
                      height: 42,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 4),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                '回溯算法日志',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onClose,
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              tooltip: '关闭日志',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: <Widget>[
                        const _SudokuLogHelp(),
                        const SizedBox(height: 10),
                        ...logs.map(
                          (String log) => Text(
                            log,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: onResizeUpdate,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      Icons.open_in_full,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: IgnorePointer(
                  child: Text(
                    '${size.width.round()} x ${size.height.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SudokuLogHelp extends StatelessWidget {
  const _SudokuLogHelp();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          '说明：r3c5 表示第 3 行第 5 列。\n'
          '候选数：这个格子当前允许填的数字。\n'
          '尝试：先把某个候选数放进去继续往后算。\n'
          '保留：后续能解通，所以这个数字是对的。\n'
          '回退：后续走不通，撤销刚才的数字换下一个。',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _SudoGameState extends State<SudoGamePage> {
  bool firstRun = true;
  bool gameOver = false;
  bool gameSolution = false;
  int timesCalled = 0;
  bool isButtonDisabled = false;
  late List<List<List<int>>> gameList;
  late List<List<int>> game;
  late List<List<int>> gameCopy;
  late List<List<int>> gameSolved;
  static String currentDifficultyLevel = 'easy';
  static String? currentAccentColor;
  static late String platform;

  int time = 0;
  Timer? _timer;
  Timer? _autoSolverTimer;
  bool _isAutoSolving = false;
  _SudokuSolveStats _solveStats = const _SudokuSolveStats.empty();
  List<String> _solveLogs = <String>[];
  Offset? _logsOffset;
  Size _logsSize = const Size(380, 320);
  final Set<Point<int>> _autoSolvedCells = <Point<int>>{};

  static List<String> gameLevel = <String>[
    'test',
    'beginner',
    'easy',
    'medium',
    'hard'
  ];

  @override
  void initState() {
    super.initState();
    getPrefs().whenComplete(() {
      currentDifficultyLevel = 'easy';
      currentAccentColor = 'Blue';
      setPrefs('currentDifficultyLevel');
      setPrefs('currentAccentColor');
      newGame(currentDifficultyLevel);
      changeAccentColor(currentAccentColor!, true);
    });
    if (kIsWeb) {
      platform = 'web-' +
          defaultTargetPlatform
              .toString()
              .replaceFirst('TargetPlatform.', '')
              .toLowerCase();
    } else {
      platform = defaultTargetPlatform
          .toString()
          .replaceFirst('TargetPlatform.', '')
          .toLowerCase();
    }
  }

  @override
  void dispose() {
    stop();
    _autoSolverTimer?.cancel();
    super.dispose();
  }

  Future<void> setTime() async {
    time = 0;
    _timer ??= Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      time++;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> getPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentDifficultyLevel =
          prefs.getString('currentDifficultyLevel') ?? 'easy';
      currentAccentColor = prefs.getString('currentAccentColor');
    });
  }

  Future<void> setPrefs(String property) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (property == 'currentDifficultyLevel') {
      prefs.setString('currentDifficultyLevel', currentDifficultyLevel);
    } else if (property == 'currentAccentColor') {
      prefs.setString('currentAccentColor', currentAccentColor!);
    }
  }

  void changeAccentColor(String color, [bool firstRun = false]) {
    setState(() {
      if (Styles.accentColors.keys.contains(color)) {
        Styles.primaryColor = Styles.accentColors[color]!;
      } else {
        currentAccentColor = 'Blue';
        Styles.primaryColor = Styles.accentColors[color]!;
      }
      if (color == 'Red') {
        Styles.secondaryColor = Styles.orange;
      } else {
        Styles.secondaryColor = Styles.lightRed;
      }
      if (!firstRun) {
        setPrefs('currentAccentColor');
      }
    });
  }

  void checkResult() {
    try {
      if (SudokuUtilities.isSolved(game)) {
        isButtonDisabled = !isButtonDisabled;
        gameOver = true;
        stop();
        Timer(const Duration(milliseconds: 500), () {
          showDialog(
              context: context,
              builder: (_) => AlertGameOver(
                    time: time,
                  )).whenComplete(() {
            if (AlertGameOver.newGame) {
              newGame(currentDifficultyLevel);
              AlertGameOver.newGame = false;
            } else if (AlertGameOver.restartGame) {
              restartGame();
              AlertGameOver.restartGame = false;
            }
          });
        });
      }
    } on InvalidSudokuConfigurationException {
      return;
    }
  }

  static List<List<List<int>>> getNewGame([String difficulty = 'easy']) {
    late int emptySquares;
    switch (difficulty) {
      case 'test':
        {
          emptySquares = 2;
        }
        break;
      case 'beginner':
        {
          emptySquares = 18;
        }
        break;
      case 'easy':
        {
          emptySquares = 27;
        }
        break;
      case 'medium':
        {
          emptySquares = 36;
        }
        break;
      case 'hard':
        {
          emptySquares = 54;
        }
        break;
    }
    final SudokuGenerator generator =
        SudokuGenerator(emptySquares: emptySquares);
    return <List<List<int>>>[generator.newSudoku, generator.newSudokuSolved];
  }

  void setGame(int mode, [String difficulty = 'easy']) {
    if (mode == 1) {
      game = List<List<int>>.generate(
        9,
        (int i) => <int>[0, 0, 0, 0, 0, 0, 0, 0, 0],
      );
      gameCopy = SudokuUtilities.copySudoku(game);
      gameSolved = SudokuUtilities.copySudoku(game);
    } else {
      gameList = getNewGame(difficulty);
      game = gameList[0];
      gameCopy = SudokuUtilities.copySudoku(game);
      gameSolved = gameList[1];
    }
    setTime();
  }

  void showSolution() {
    setState(() {
      gameSolution = true;
      Timer(const Duration(seconds: 5), () {
        gameSolution = false;
        setState(() {});
      });
    });
  }

  void newGame([String difficulty = 'easy']) {
    _autoSolverTimer?.cancel();
    setState(() {
      setGame(2, difficulty);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
      _isAutoSolving = false;
      _solveStats = const _SudokuSolveStats.empty();
      _solveLogs = <String>[];
      _autoSolvedCells.clear();
    });
  }

  void restartGame() {
    _autoSolverTimer?.cancel();
    setState(() {
      game = SudokuUtilities.copySudoku(gameCopy);
      isButtonDisabled =
          isButtonDisabled ? !isButtonDisabled : isButtonDisabled;
      gameOver = false;
      _isAutoSolving = false;
      _solveStats = const _SudokuSolveStats.empty();
      _solveLogs = <String>[];
      _autoSolvedCells.clear();
    });
  }

  void autoPlayWithAlgorithm() {
    if (_isAutoSolving || gameOver) {
      return;
    }
    final _SudokuSolveResult result = _solveCurrentGame();
    setState(() {
      _solveStats = result.stats;
      _solveLogs = result.logs;
      _autoSolvedCells.clear();
    });
    if (!result.stats.solved) {
      ToastUtils.showToast(msg: '当前盘面无解，请检查已填数字');
      return;
    }

    final List<Point<int>> cells = <Point<int>>[];
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (gameCopy[row][col] == 0 && game[row][col] == 0) {
          cells.add(Point<int>(row, col));
        }
      }
    }
    if (cells.isEmpty) {
      checkResult();
      return;
    }

    int index = 0;
    setState(() {
      _isAutoSolving = true;
    });
    _autoSolverTimer?.cancel();
    _autoSolverTimer = Timer.periodic(
      const Duration(milliseconds: 90),
      (Timer timer) {
        if (!mounted || index >= cells.length) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _isAutoSolving = false;
            });
            checkResult();
          }
          return;
        }
        final Point<int> cell = cells[index];
        setState(() {
          game[cell.x][cell.y] = result.solvedGame[cell.x][cell.y];
          _autoSolvedCells.add(cell);
        });
        index++;
      },
    );
  }

  _SudokuSolveResult _solveCurrentGame() {
    final Stopwatch stopwatch = Stopwatch()..start();
    final List<List<int>> board = SudokuUtilities.copySudoku(game);
    final int emptyCount = _countEmptyCells(board);
    final List<String> logs = <String>[
      '开始：空格 $emptyCount 个，难度 $currentDifficultyLevel',
    ];
    int triedCount = 0;
    int backtrackCount = 0;

    void appendLog(String message) {
      logs.add('${logs.length.toString().padLeft(4, '0')}  $message');
    }

    bool solve() {
      final Point<int>? cell = _findBestEmptyCell(board);
      if (cell == null) {
        appendLog('完成：已经没有空格，盘面解出来了');
        return true;
      }
      final List<int> candidates = _candidatesFor(board, cell.x, cell.y);
      appendLog(
        '查看 r${cell.x + 1}c${cell.y + 1}：候选数 ${candidates.isEmpty ? '无' : candidates.join(',')}',
      );
      if (candidates.isEmpty) {
        appendLog('死路：r${cell.x + 1}c${cell.y + 1} 没有可填数字，需要回退');
      }
      for (final int number in candidates) {
        triedCount++;
        appendLog('尝试 #$triedCount：r${cell.x + 1}c${cell.y + 1} 填 $number');
        board[cell.x][cell.y] = number;
        if (solve()) {
          appendLog('保留：r${cell.x + 1}c${cell.y + 1} = $number');
          return true;
        }
        board[cell.x][cell.y] = 0;
        backtrackCount++;
        appendLog(
          '回退 #$backtrackCount：撤销 r${cell.x + 1}c${cell.y + 1} 的 $number',
        );
      }
      return false;
    }

    final bool solved = solve();
    stopwatch.stop();
    appendLog(
      '结束：${solved ? '找到解' : '无解'}，尝试 $triedCount 次，回退 $backtrackCount 次，耗时 ${(stopwatch.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms',
    );
    return _SudokuSolveResult(
      solvedGame: board,
      stats: _SudokuSolveStats(
        emptyCount: emptyCount,
        triedCount: triedCount,
        backtrackCount: backtrackCount,
        elapsedMicroseconds: stopwatch.elapsedMicroseconds,
        solved: solved,
      ),
      logs: logs,
    );
  }

  int _countEmptyCells(List<List<int>> board) {
    int count = 0;
    for (final List<int> row in board) {
      for (final int value in row) {
        if (value == 0) {
          count++;
        }
      }
    }
    return count;
  }

  Point<int>? _findBestEmptyCell(List<List<int>> board) {
    Point<int>? bestCell;
    int bestCandidateCount = 10;
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] != 0) {
          continue;
        }
        final int candidateCount = _candidatesFor(board, row, col).length;
        if (candidateCount < bestCandidateCount) {
          bestCandidateCount = candidateCount;
          bestCell = Point<int>(row, col);
        }
        if (candidateCount == 0) {
          return bestCell;
        }
      }
    }
    return bestCell;
  }

  List<int> _candidatesFor(List<List<int>> board, int row, int col) {
    return List<int>.generate(9, (int index) => index + 1)
        .where((int number) => _canPlace(board, row, col, number))
        .toList(growable: false);
  }

  bool _canPlace(List<List<int>> board, int row, int col, int number) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == number || board[i][col] == number) {
        return false;
      }
    }
    final int boxRow = row ~/ 3 * 3;
    final int boxCol = col ~/ 3 * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c] == number) {
          return false;
        }
      }
    }
    return true;
  }

  Color buttonColor(int k, int i) {
    Color color;
    if ((<int>[0, 1, 2].contains(k) && <int>[3, 4, 5].contains(i)) ||
        (<int>[3, 4, 5].contains(k) && <int>[0, 1, 2, 6, 7, 8].contains(i)) ||
        (<int>[6, 7, 8].contains(k) && <int>[3, 4, 5].contains(i))) {
      if (Styles.white == Styles.darkGrey) {
        color = Styles.grey;
      } else {
        color = Colors.grey[300]!;
      }
    } else {
      color = Styles.white;
    }

    return color;
  }

  double buttonSize() {
    double size = 50;
    if (_SudoGameState.platform.contains('android') ||
        _SudoGameState.platform.contains('ios')) {
      size = 38;
    }
    return size;
  }

  double buttonFontSize() {
    double size = 20;
    if (_SudoGameState.platform.contains('android') ||
        _SudoGameState.platform.contains('ios')) {
      size = 16;
    }
    return size;
  }

  BorderRadiusGeometry buttonEdgeRadius(int k, int i) {
    if (k == 0 && i == 0) {
      return const BorderRadius.only(topLeft: Radius.circular(5));
    } else if (k == 0 && i == 8) {
      return const BorderRadius.only(topRight: Radius.circular(5));
    } else if (k == 8 && i == 0) {
      return const BorderRadius.only(bottomLeft: Radius.circular(5));
    } else if (k == 8 && i == 8) {
      return const BorderRadius.only(bottomRight: Radius.circular(5));
    }
    return BorderRadius.circular(0);
  }

  List<SizedBox> createButtons() {
    if (firstRun) {
      setGame(1);
      firstRun = false;
    }
    MaterialColor emptyColor;
    if (gameOver) {
      emptyColor = Styles.primaryColor;
    } else {
      emptyColor = Styles.secondaryColor;
    }
    final List<SizedBox> buttonList =
        List<SizedBox>.filled(9, const SizedBox());
    for (int i = 0; i <= 8; i++) {
      final int k = timesCalled;
      buttonList[i] = SizedBox(
        width: buttonSize(),
        height: buttonSize(),
        child: TextButton(
          onPressed: isButtonDisabled || _isAutoSolving || gameCopy[k][i] != 0
              ? null
              : () {
                  showDialog<void>(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) =>
                          AlertNumbersState()).whenComplete(() {
                    callback(<int>[k, i], AlertNumbersState.number);
                    AlertNumbersState.number = 0;
                  });
                },
          onLongPress: isButtonDisabled || _isAutoSolving || gameCopy[k][i] != 0
              ? null
              : () => callback(<int>[k, i], 0),
          style: ButtonStyle(
            backgroundColor: isButtonDisabled ||
                    gameCopy[k][i] != 0 ||
                    game[k][i] == 0 ||
                    gameSolution == false
                ? WidgetStateProperty.all<Color>(
                    _autoSolvedCells.contains(Point<int>(k, i))
                        ? Styles.aospExtendedGreen.shade50
                        : buttonColor(k, i),
                  )
                : game[k][i] == gameSolved[k][i]
                    ? WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) =>
                            Styles.aospExtendedGreen.shade50,
                      )
                    : WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) => Styles.lightRed.shade50,
                      ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return gameCopy[k][i] == 0 ? emptyColor : Styles.darkGrey;
              }
              return game[k][i] == 0 ? buttonColor(k, i) : Styles.textColor;
            }),
            shape:
                WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
              borderRadius: buttonEdgeRadius(k, i),
            )),
            side: WidgetStateProperty.all<BorderSide>(BorderSide(
              color: Styles.darkGrey,
              width: 1,
              style: BorderStyle.solid,
            )),
          ),
          child: Text(
            game[k][i] != 0 ? game[k][i].toString() : ' ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: buttonFontSize()),
          ),
        ),
      );
    }
    timesCalled++;
    if (timesCalled == 9) {
      timesCalled = 0;
    }
    return buttonList;
  }

  Row oneRow() {
    return Row(
      children: createButtons(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<Row> createRows() {
    final List<Row> rowList = List<Row>.filled(9, const Row());
    for (int i = 0; i <= 8; i++) {
      rowList[i] = oneRow();
    }
    return rowList;
  }

  void callback(List<int> index, int number) {
    _autoSolvedCells.remove(Point<int>(index[0], index[1]));
    setState(() {
      if (number == 0) {
        game[index[0]][index[1]] = number;
      } else {
        game[index[0]][index[1]] = number;
        checkResult();
      }
    });
  }

  Offset _defaultLogsOffset(Size bounds, Size panelSize) {
    return Offset(max(18, bounds.width - panelSize.width - 18), 18);
  }

  Size _clampLogsSize(Size size, Size bounds) {
    final double maxWidth = max(260, bounds.width - 36);
    final double maxHeight = max(180, bounds.height - 36);
    return Size(
      size.width.clamp(260, maxWidth) as double,
      size.height.clamp(180, maxHeight) as double,
    );
  }

  Offset _clampLogsOffset(Offset offset, Size panelSize, Size bounds) {
    final double maxLeft = max(18, bounds.width - panelSize.width - 18);
    final double maxTop = max(18, bounds.height - panelSize.height - 18);
    return Offset(
      offset.dx.clamp(18, maxLeft) as double,
      offset.dy.clamp(18, maxTop) as double,
    );
  }

  void showOptionModalSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (BuildContext context) {
          final TextStyle customStyle =
              TextStyle(inherit: false, color: Styles.darkGrey);
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.refresh, color: Styles.darkGrey),
                title: Text('Restart Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200), () => restartGame());
                },
              ),
              ListTile(
                leading: Icon(Icons.add_rounded, color: Styles.darkGrey),
                title: Text('New Game', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200),
                      () => newGame(currentDifficultyLevel));
                },
              ),
              ListTile(
                leading: Icon(Icons.lightbulb_outline_rounded,
                    color: Styles.darkGrey),
                title: Text('Show Solution', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(
                      const Duration(milliseconds: 200), () => showSolution());
                },
              ),
              ListTile(
                leading: Icon(Icons.smart_toy_outlined, color: Styles.darkGrey),
                title: Text('Algorithm Auto Play', style: customStyle),
                onTap: () {
                  Navigator.pop(context);
                  Timer(const Duration(milliseconds: 200),
                      () => autoPlayWithAlgorithm());
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !kIsWeb,
      child: Scaffold(
        backgroundColor: Styles.white,
        appBar: GlobalStore.isMobile
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: AppBar(
                  centerTitle: true,
                  title: const Text('数 独'),
                  backgroundColor: Styles.primaryColor,
                ),
              )
            : null,
        body: Builder(builder: (BuildContext builder) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Size bounds = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final Size panelSize = _clampLogsSize(_logsSize, bounds);
              final Offset panelOffset = _clampLogsOffset(
                _logsOffset ?? _defaultLogsOffset(bounds, panelSize),
                panelSize,
                bounds,
              );
              return Stack(
                children: <Widget>[
                  Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            left: screenUtil.adaptive(75),
                            right: screenUtil.adaptive(75)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('当前难度：$currentDifficultyLevel'),
                            RepaintBoundary(
                              child:
                                  Text('${DateTimeHelper.secToMSTime(time)}'),
                            ),
                            TextButton.icon(
                              onPressed: _isAutoSolving
                                  ? null
                                  : () => autoPlayWithAlgorithm(),
                              icon: const Icon(Icons.smart_toy_outlined,
                                  size: 18),
                              label: Text(_isAutoSolving ? '算法中' : '算法玩'),
                            ),
                            RepaintBoundary(
                              child: DropSelectableWidget(
                                fontSize: 12,
                                data: gameLevel,
                                value: currentDifficultyLevel,
                                iconSize: 20,
                                height: 30,
                                width: 100,
                                widgetHeight: 150,
                                disableColor: const Color(0xff1F425F),
                                onDropSelected: (int index) async {
                                  Log.info(index);
                                  currentDifficultyLevel =
                                      ArrayHelper.get(gameLevel, index)!;
                                  newGame(currentDifficultyLevel);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _SudokuStatsPanel(stats: _solveStats),
                      const SizedBox(height: 12),
                      RepaintBoundary(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: createRows(),
                        ),
                      ),
                    ],
                  )),
                  if (_solveLogs.isNotEmpty)
                    Positioned(
                      left: panelOffset.dx,
                      top: panelOffset.dy,
                      child: _SudokuLogsPanel(
                        logs: _solveLogs,
                        size: panelSize,
                        onDragUpdate: (DragUpdateDetails details) {
                          setState(() {
                            _logsOffset = _clampLogsOffset(
                              panelOffset + details.delta,
                              panelSize,
                              bounds,
                            );
                          });
                        },
                        onResizeUpdate: (DragUpdateDetails details) {
                          setState(() {
                            _logsSize = _clampLogsSize(
                              Size(
                                panelSize.width + details.delta.dx,
                                panelSize.height + details.delta.dy,
                              ),
                              bounds,
                            );
                            _logsOffset = _clampLogsOffset(
                              panelOffset,
                              _logsSize,
                              bounds,
                            );
                          });
                        },
                        onClose: () {
                          setState(() {
                            _solveLogs = <String>[];
                          });
                        },
                      ),
                    ),
                ],
              );
            },
          );
        }),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Styles.white,
          backgroundColor: Styles.primaryColor,
          onPressed: () => showOptionModalSheet(context),
          child: const Icon(Icons.menu_rounded),
        ),
      ),
    );
  }
}

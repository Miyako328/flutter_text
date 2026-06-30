import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text/global/global.dart';

enum _MoveDirection {
  up('上', Icons.keyboard_arrow_up_rounded),
  down('下', Icons.keyboard_arrow_down_rounded),
  left('左', Icons.keyboard_arrow_left_rounded),
  right('右', Icons.keyboard_arrow_right_rounded);

  final String label;
  final IconData icon;

  const _MoveDirection(this.label, this.icon);
}

class _MoveResult {
  final List<List<int>> board;
  final int score;
  final bool moved;

  const _MoveResult({
    required this.board,
    required this.score,
    required this.moved,
  });
}

class _LineResult {
  final List<int> line;
  final int score;

  const _LineResult(this.line, this.score);
}

class _AiMoveScore {
  final _MoveDirection direction;
  final double score;
  final int immediateScore;
  final int emptyCount;
  final int maxTile;
  final double smoothness;
  final double monotonicity;

  const _AiMoveScore({
    required this.direction,
    required this.score,
    required this.immediateScore,
    required this.emptyCount,
    required this.maxTile,
    required this.smoothness,
    required this.monotonicity,
  });
}

class Game2048Page extends StatefulWidget {
  const Game2048Page({Key? key}) : super(key: key);

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  static const int _size = 4;
  final Random _random = Random();
  final FocusNode _focusNode = FocusNode();
  List<List<int>> _board = _emptyBoard();
  List<List<int>> _previousBoard = _emptyBoard();
  List<_AiMoveScore> _lastAnalysis = <_AiMoveScore>[];
  List<String> _logs = <String>[];
  Timer? _autoTimer;
  int _score = 0;
  int _bestScore = 0;
  int _moves = 0;
  bool _gameOver = false;
  bool _autoPlaying = false;
  int _searchDepth = 3;

  @override
  void initState() {
    super.initState();
    _newGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  static List<List<int>> _emptyBoard() {
    return List<List<int>>.generate(
      _size,
      (_) => List<int>.filled(_size, 0),
    );
  }

  void _newGame() {
    _autoTimer?.cancel();
    _autoPlaying = false;
    _board = _emptyBoard();
    _previousBoard = _cloneBoard(_board);
    _score = 0;
    _moves = 0;
    _gameOver = false;
    _lastAnalysis = <_AiMoveScore>[];
    _logs = <String>['新游戏：随机生成两个数字块。'];
    _addRandomTile(_board);
    _addRandomTile(_board);
    setState(() {});
  }

  void _undo() {
    if (_autoPlaying) {
      return;
    }
    setState(() {
      _board = _cloneBoard(_previousBoard);
      _gameOver = false;
      _logs.insert(0, '撤回到上一步棋盘。');
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _playMove(_MoveDirection.up, source: '键盘');
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _playMove(_MoveDirection.down, source: '键盘');
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _playMove(_MoveDirection.left, source: '键盘');
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _playMove(_MoveDirection.right, source: '键盘');
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final Offset velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance < 220) {
      return;
    }
    if (velocity.dx.abs() > velocity.dy.abs()) {
      _playMove(
        velocity.dx > 0 ? _MoveDirection.right : _MoveDirection.left,
        source: '拖拽',
      );
    } else {
      _playMove(
        velocity.dy > 0 ? _MoveDirection.down : _MoveDirection.up,
        source: '拖拽',
      );
    }
  }

  void _playMove(_MoveDirection direction, {String source = '手动'}) {
    if (_gameOver) {
      return;
    }
    final _MoveResult result = _move(_board, direction);
    if (!result.moved) {
      _pushLog('$source：向${direction.label}滑，没有数字块移动。');
      return;
    }
    setState(() {
      _previousBoard = _cloneBoard(_board);
      _board = result.board;
      _score += result.score;
      _moves += 1;
      _addRandomTile(_board);
      _bestScore = max(_bestScore, _score);
      _gameOver = !_hasMoves(_board);
      _pushLog(
        '$source：向${direction.label}滑，合并得分 +${result.score}，空格 ${_emptyCells(_board).length}。',
      );
      if (_gameOver) {
        _pushLog('游戏结束：四个方向都无法移动。');
        _autoTimer?.cancel();
        _autoPlaying = false;
      }
    });
  }

  void _analyzeMove({bool playBest = false}) {
    if (_gameOver) {
      return;
    }
    final List<_AiMoveScore> analysis = _analyzeBoard(_board, _searchDepth);
    if (analysis.isEmpty) {
      setState(() {
        _gameOver = true;
        _logs.insert(0, 'Expectimax：没有可行动作。');
      });
      return;
    }
    final _AiMoveScore best = analysis.first;
    setState(() {
      _lastAnalysis = analysis;
      _logs.insertAll(0, <String>[
        'Expectimax 深度 $_searchDepth：选择向${best.direction.label}，预估分 ${best.score.toStringAsFixed(1)}。',
        '理由：空格 ${best.emptyCount}、最大块 ${best.maxTile}、平滑度 ${best.smoothness.toStringAsFixed(1)}、单调性 ${best.monotonicity.toStringAsFixed(1)}。',
      ]);
      _trimLogs();
    });
    if (playBest) {
      _playMove(best.direction, source: '算法');
    }
  }

  void _toggleAutoPlay() {
    if (_autoPlaying) {
      _autoTimer?.cancel();
      setState(() {
        _autoPlaying = false;
        _pushLog('算法自动玩已暂停。');
      });
      return;
    }
    setState(() {
      _autoPlaying = true;
      _pushLog('算法自动玩开始：每 420ms 走一步。');
    });
    _autoTimer = Timer.periodic(const Duration(milliseconds: 420), (_) {
      if (!mounted || _gameOver) {
        _autoTimer?.cancel();
        _autoPlaying = false;
        return;
      }
      _analyzeMove(playBest: true);
    });
  }

  List<_AiMoveScore> _analyzeBoard(List<List<int>> board, int depth) {
    final List<_AiMoveScore> result = <_AiMoveScore>[];
    for (final _MoveDirection direction in _MoveDirection.values) {
      final _MoveResult moveResult = _move(board, direction);
      if (!moveResult.moved) {
        continue;
      }
      final double futureScore = _expectimax(
        moveResult.board,
        depth - 1,
        false,
      );
      final int emptyCount = _emptyCells(moveResult.board).length;
      final double smoothness = _smoothness(moveResult.board);
      final double monotonicity = _monotonicity(moveResult.board);
      result.add(
        _AiMoveScore(
          direction: direction,
          score: moveResult.score + futureScore,
          immediateScore: moveResult.score,
          emptyCount: emptyCount,
          maxTile: _maxTile(moveResult.board),
          smoothness: smoothness,
          monotonicity: monotonicity,
        ),
      );
    }
    result.sort((_AiMoveScore a, _AiMoveScore b) => b.score.compareTo(a.score));
    return result;
  }

  double _expectimax(List<List<int>> board, int depth, bool playerTurn) {
    if (depth <= 0 || !_hasMoves(board)) {
      return _evaluate(board);
    }
    if (playerTurn) {
      double best = -double.infinity;
      for (final _MoveDirection direction in _MoveDirection.values) {
        final _MoveResult moveResult = _move(board, direction);
        if (moveResult.moved) {
          best = max(
            best,
            moveResult.score + _expectimax(moveResult.board, depth - 1, false),
          );
        }
      }
      return best == -double.infinity ? _evaluate(board) : best;
    }

    final List<Point<int>> emptyCells = _emptyCells(board);
    if (emptyCells.isEmpty) {
      return _evaluate(board);
    }
    double expected = 0;
    final double cellProbability = 1 / emptyCells.length;
    for (final Point<int> cell in emptyCells) {
      for (final int value in <int>[2, 4]) {
        final List<List<int>> next = _cloneBoard(board);
        next[cell.y][cell.x] = value;
        final double tileProbability = value == 2 ? 0.9 : 0.1;
        expected += cellProbability *
            tileProbability *
            _expectimax(next, depth - 1, true);
      }
    }
    return expected;
  }

  double _evaluate(List<List<int>> board) {
    final int emptyCount = _emptyCells(board).length;
    final int maxTile = _maxTile(board);
    final double smoothness = _smoothness(board);
    final double monotonicity = _monotonicity(board);
    return emptyCount * 850 +
        log(maxTile) / ln2 * 220 +
        monotonicity * 22 +
        smoothness * 8;
  }

  _MoveResult _move(List<List<int>> board, _MoveDirection direction) {
    final List<List<int>> next = _emptyBoard();
    int gainedScore = 0;

    for (int i = 0; i < _size; i += 1) {
      final List<int> line = <int>[];
      for (int j = 0; j < _size; j += 1) {
        line.add(_valueAt(board, direction, i, j));
      }
      final _LineResult result = _mergeLine(line);
      gainedScore += result.score;
      for (int j = 0; j < _size; j += 1) {
        _setValueAt(next, direction, i, j, result.line[j]);
      }
    }

    return _MoveResult(
      board: next,
      score: gainedScore,
      moved: !_sameBoard(board, next),
    );
  }

  int _valueAt(
    List<List<int>> board,
    _MoveDirection direction,
    int line,
    int offset,
  ) {
    return switch (direction) {
      _MoveDirection.left => board[line][offset],
      _MoveDirection.right => board[line][_size - 1 - offset],
      _MoveDirection.up => board[offset][line],
      _MoveDirection.down => board[_size - 1 - offset][line],
    };
  }

  void _setValueAt(
    List<List<int>> board,
    _MoveDirection direction,
    int line,
    int offset,
    int value,
  ) {
    switch (direction) {
      case _MoveDirection.left:
        board[line][offset] = value;
      case _MoveDirection.right:
        board[line][_size - 1 - offset] = value;
      case _MoveDirection.up:
        board[offset][line] = value;
      case _MoveDirection.down:
        board[_size - 1 - offset][line] = value;
    }
  }

  _LineResult _mergeLine(List<int> line) {
    final List<int> values = line.where((int value) => value != 0).toList();
    final List<int> merged = <int>[];
    int score = 0;
    int i = 0;
    while (i < values.length) {
      if (i + 1 < values.length && values[i] == values[i + 1]) {
        final int value = values[i] * 2;
        merged.add(value);
        score += value;
        i += 2;
      } else {
        merged.add(values[i]);
        i += 1;
      }
    }
    while (merged.length < _size) {
      merged.add(0);
    }
    return _LineResult(merged, score);
  }

  void _addRandomTile(List<List<int>> board) {
    final List<Point<int>> emptyCells = _emptyCells(board);
    if (emptyCells.isEmpty) {
      return;
    }
    final Point<int> cell = emptyCells[_random.nextInt(emptyCells.length)];
    board[cell.y][cell.x] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  List<Point<int>> _emptyCells(List<List<int>> board) {
    final List<Point<int>> cells = <Point<int>>[];
    for (int y = 0; y < _size; y += 1) {
      for (int x = 0; x < _size; x += 1) {
        if (board[y][x] == 0) {
          cells.add(Point<int>(x, y));
        }
      }
    }
    return cells;
  }

  bool _hasMoves(List<List<int>> board) {
    if (_emptyCells(board).isNotEmpty) {
      return true;
    }
    for (final _MoveDirection direction in _MoveDirection.values) {
      if (_move(board, direction).moved) {
        return true;
      }
    }
    return false;
  }

  bool _sameBoard(List<List<int>> a, List<List<int>> b) {
    for (int y = 0; y < _size; y += 1) {
      for (int x = 0; x < _size; x += 1) {
        if (a[y][x] != b[y][x]) {
          return false;
        }
      }
    }
    return true;
  }

  static List<List<int>> _cloneBoard(List<List<int>> board) {
    return board.map((List<int> row) => List<int>.from(row)).toList();
  }

  int _maxTile(List<List<int>> board) {
    int maxValue = 0;
    for (final List<int> row in board) {
      for (final int value in row) {
        maxValue = max(maxValue, value);
      }
    }
    return maxValue;
  }

  double _smoothness(List<List<int>> board) {
    double score = 0;
    for (int y = 0; y < _size; y += 1) {
      for (int x = 0; x < _size; x += 1) {
        final int value = board[y][x];
        if (value == 0) {
          continue;
        }
        final double current = log(value) / ln2;
        if (x + 1 < _size && board[y][x + 1] != 0) {
          score -= (current - log(board[y][x + 1]) / ln2).abs();
        }
        if (y + 1 < _size && board[y + 1][x] != 0) {
          score -= (current - log(board[y + 1][x]) / ln2).abs();
        }
      }
    }
    return score;
  }

  double _monotonicity(List<List<int>> board) {
    double total = 0;
    for (int y = 0; y < _size; y += 1) {
      double inc = 0;
      double dec = 0;
      for (int x = 0; x < _size - 1; x += 1) {
        final double a = board[y][x] == 0 ? 0 : log(board[y][x]) / ln2;
        final double b = board[y][x + 1] == 0 ? 0 : log(board[y][x + 1]) / ln2;
        if (a > b) {
          dec += b - a;
        } else {
          inc += a - b;
        }
      }
      total += max(inc, dec);
    }
    for (int x = 0; x < _size; x += 1) {
      double inc = 0;
      double dec = 0;
      for (int y = 0; y < _size - 1; y += 1) {
        final double a = board[y][x] == 0 ? 0 : log(board[y][x]) / ln2;
        final double b = board[y + 1][x] == 0 ? 0 : log(board[y + 1][x]) / ln2;
        if (a > b) {
          dec += b - a;
        } else {
          inc += a - b;
        }
      }
      total += max(inc, dec);
    }
    return total;
  }

  void _pushLog(String value) {
    _logs.insert(0, value);
    _trimLogs();
  }

  void _trimLogs() {
    if (_logs.length > 80) {
      _logs = _logs.take(80).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: GlobalStore.isMobile
            ? AppBar(
                title: const Text('2048 Expectimax'),
              )
            : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 900;
              final Widget board = _BoardPanel(
                board: _board,
                score: _score,
                bestScore: _bestScore,
                moves: _moves,
                gameOver: _gameOver,
                onDragEnd: _handleDragEnd,
                onMove: _playMove,
                colorScheme: colorScheme,
              );
              final Widget side = _SidePanel(
                analysis: _lastAnalysis,
                logs: _logs,
                searchDepth: _searchDepth,
                autoPlaying: _autoPlaying,
                onDepthChanged: (double value) {
                  setState(() => _searchDepth = value.round());
                },
                onAnalyze: () => _analyzeMove(),
                onAiStep: () => _analyzeMove(playBest: true),
                onAutoPlay: _toggleAutoPlay,
                onNewGame: _newGame,
                onUndo: _undo,
              );
              if (compact) {
                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: <Widget>[
                    board,
                    const SizedBox(height: 18),
                    side,
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(flex: 11, child: board),
                    const SizedBox(width: 22),
                    Expanded(flex: 9, child: side),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BoardPanel extends StatelessWidget {
  final List<List<int>> board;
  final int score;
  final int bestScore;
  final int moves;
  final bool gameOver;
  final ValueChanged<DragEndDetails> onDragEnd;
  final ValueChanged<_MoveDirection> onMove;
  final ColorScheme colorScheme;

  const _BoardPanel({
    required this.board,
    required this.score,
    required this.bestScore,
    required this.moves,
    required this.gameOver,
    required this.onDragEnd,
    required this.onMove,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '2048',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                _ScoreBox(label: '分数', value: '$score'),
                const SizedBox(width: 10),
                _ScoreBox(label: '最佳', value: '$bestScore'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _InfoChip(icon: Icons.swipe_rounded, text: '$moves 步'),
                const SizedBox(width: 8),
                const _InfoChip(
                  icon: Icons.keyboard_outlined,
                  text: '方向键 / 拖拽',
                ),
                if (gameOver) ...<Widget>[
                  const SizedBox(width: 8),
                  const _InfoChip(icon: Icons.flag_outlined, text: '已结束'),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onVerticalDragEnd: onDragEnd,
                  onHorizontalDragEnd: onDragEnd,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _BoardGrid(board: board),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MovePad(onMove: onMove),
          ],
        ),
      ),
    );
  }
}

class _BoardGrid extends StatelessWidget {
  final List<List<int>> board;

  const _BoardGrid({required this.board});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFB9ADA1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: 16,
          itemBuilder: (BuildContext context, int index) {
            final int value = board[index ~/ 4][index % 4];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: _tileColor(value),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: value == 0
                  ? const SizedBox.shrink()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: value <= 4
                              ? const Color(0xFF665E57)
                              : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 36,
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _MovePad extends StatelessWidget {
  final ValueChanged<_MoveDirection> onMove;

  const _MovePad({required this.onMove});

  @override
  Widget build(BuildContext context) {
    Widget button(_MoveDirection direction) {
      return IconButton.filledTonal(
        tooltip: '向${direction.label}滑',
        onPressed: () => onMove(direction),
        icon: Icon(direction.icon),
      );
    }

    return Column(
      children: <Widget>[
        button(_MoveDirection.up),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            button(_MoveDirection.left),
            const SizedBox(width: 44),
            button(_MoveDirection.right),
          ],
        ),
        button(_MoveDirection.down),
      ],
    );
  }
}

class _SidePanel extends StatelessWidget {
  final List<_AiMoveScore> analysis;
  final List<String> logs;
  final int searchDepth;
  final bool autoPlaying;
  final ValueChanged<double> onDepthChanged;
  final VoidCallback onAnalyze;
  final VoidCallback onAiStep;
  final VoidCallback onAutoPlay;
  final VoidCallback onNewGame;
  final VoidCallback onUndo;

  const _SidePanel({
    required this.analysis,
    required this.logs,
    required this.searchDepth,
    required this.autoPlaying,
    required this.onDepthChanged,
    required this.onAnalyze,
    required this.onAiStep,
    required this.onAutoPlay,
    required this.onNewGame,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Expectimax 算法',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Text('搜索深度'),
                Expanded(
                  child: Slider(
                    min: 2,
                    max: 5,
                    divisions: 3,
                    value: searchDepth.toDouble(),
                    label: '$searchDepth',
                    onChanged: onDepthChanged,
                  ),
                ),
                Text('$searchDepth'),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: onAnalyze,
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text('分析'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAiStep,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('走一步'),
                ),
                OutlinedButton.icon(
                  onPressed: onAutoPlay,
                  icon: Icon(
                    autoPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(autoPlaying ? '暂停' : '自动玩'),
                ),
                IconButton.outlined(
                  tooltip: '撤回',
                  onPressed: onUndo,
                  icon: const Icon(Icons.undo_rounded),
                ),
                IconButton.outlined(
                  tooltip: '新游戏',
                  onPressed: onNewGame,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('方向评分', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (analysis.isEmpty)
              Text(
                '点击“分析”后，这里会显示上/下/左/右每个方向的预估分。',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              ...analysis.map((_AiMoveScore score) {
                return _AnalysisRow(score: score);
              }),
            const SizedBox(height: 16),
            Text('Logs', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final _AiMoveScore score;

  const _AnalysisRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Icon(score.direction.icon),
              const SizedBox(width: 8),
              SizedBox(width: 28, child: Text(score.direction.label)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '预估 ${score.score.toStringAsFixed(1)} · 立即 +${score.immediateScore}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '空格 ${score.emptyCount} · 最大 ${score.maxTile} · 平滑 ${score.smoothness.toStringAsFixed(1)} · 单调 ${score.monotonicity.toStringAsFixed(1)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 82,
        height: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 15),
            const SizedBox(width: 5),
            Text(text, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

Color _tileColor(int value) {
  return switch (value) {
    0 => const Color(0xFFCDC1B4),
    2 => const Color(0xFFEEE4DA),
    4 => const Color(0xFFEDE0C8),
    8 => const Color(0xFFF2B179),
    16 => const Color(0xFFF59563),
    32 => const Color(0xFFF67C5F),
    64 => const Color(0xFFF65E3B),
    128 => const Color(0xFFEDCF72),
    256 => const Color(0xFFEDCC61),
    512 => const Color(0xFFEDC850),
    1024 => const Color(0xFFEDC53F),
    2048 => const Color(0xFFEDC22E),
    _ => const Color(0xFF3C3A32),
  };
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text/global/global.dart';

enum MazeDifficulty {
  easy(11, '简单'),
  normal(15, '普通'),
  hard(21, '困难'),
  expert(31, '专家'),
  nightmare(41, '噩梦');

  final int size;
  final String label;

  const MazeDifficulty(this.size, this.label);
}

enum _Direction {
  up(0, -1),
  right(1, 0),
  down(0, 1),
  left(-1, 0);

  final int dx;
  final int dy;

  const _Direction(this.dx, this.dy);
}

class _BfsStats {
  final int visitedCount;
  final int expandedCount;
  final int frontierCount;
  final int maxFrontierCount;
  final int pathLength;
  final int elapsedMicroseconds;
  final Point<int>? currentPoint;
  final bool foundPath;

  const _BfsStats({
    required this.visitedCount,
    required this.expandedCount,
    required this.frontierCount,
    required this.maxFrontierCount,
    required this.pathLength,
    required this.elapsedMicroseconds,
    required this.currentPoint,
    required this.foundPath,
  });

  const _BfsStats.empty()
      : visitedCount = 0,
        expandedCount = 0,
        frontierCount = 0,
        maxFrontierCount = 0,
        pathLength = 0,
        elapsedMicroseconds = 0,
        currentPoint = null,
        foundPath = false;
}

class _MazeSolveResult {
  final List<Point<int>> path;
  final _BfsStats stats;
  final List<String> logs;

  const _MazeSolveResult({
    required this.path,
    required this.stats,
    required this.logs,
  });
}

class MazeGamePage extends StatefulWidget {
  const MazeGamePage({Key? key}) : super(key: key);

  @override
  State<MazeGamePage> createState() => _MazeGamePageState();
}

class _MazeGamePageState extends State<MazeGamePage> {
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();
  MazeDifficulty _difficulty = MazeDifficulty.normal;
  late List<List<bool>> _walls;
  late Point<int> _player;
  late Point<int> _goal;
  Timer? _timer;
  Timer? _solverTimer;
  List<Point<int>> _solutionPath = <Point<int>>[];
  _BfsStats _bfsStats = const _BfsStats.empty();
  List<String> _bfsLogs = <String>[];
  Offset? _logsOffset;
  Size _logsSize = const Size(420, 320);
  int _seconds = 0;
  int _moves = 0;
  bool _finished = false;
  bool _isSolving = false;

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
    _timer?.cancel();
    _solverTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _newGame() {
    _timer?.cancel();
    _solverTimer?.cancel();
    _seconds = 0;
    _moves = 0;
    _finished = false;
    _isSolving = false;
    _walls = _generateMaze(_difficulty.size);
    _player = const Point<int>(1, 1);
    _goal = _findFarthestReachablePoint(_player);
    _solutionPath = <Point<int>>[];
    _bfsStats = const _BfsStats.empty();
    _bfsLogs = <String>[];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_finished && mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
    setState(() {});
  }

  List<List<bool>> _generateMaze(int size) {
    final List<List<bool>> walls = List<List<bool>>.generate(
      size,
      (_) => List<bool>.filled(size, true),
    );
    final List<Point<int>> stack = <Point<int>>[const Point<int>(1, 1)];
    walls[1][1] = false;

    while (stack.isNotEmpty) {
      final Point<int> current = stack.last;
      final List<_Direction> directions = List<_Direction>.from(
        _Direction.values,
      )..shuffle(_random);
      bool carved = false;

      for (final _Direction direction in directions) {
        final int nextX = current.x + direction.dx * 2;
        final int nextY = current.y + direction.dy * 2;
        if (nextX <= 0 ||
            nextY <= 0 ||
            nextX >= size - 1 ||
            nextY >= size - 1) {
          continue;
        }
        if (!walls[nextY][nextX]) {
          continue;
        }
        walls[current.y + direction.dy][current.x + direction.dx] = false;
        walls[nextY][nextX] = false;
        stack.add(Point<int>(nextX, nextY));
        carved = true;
        break;
      }

      if (!carved) {
        stack.removeLast();
      }
    }

    walls[size - 2][size - 2] = false;
    return walls;
  }

  Point<int> _findFarthestReachablePoint(Point<int> start) {
    final List<Point<int>> queue = <Point<int>>[start];
    final List<List<bool>> visited = List<List<bool>>.generate(
      _difficulty.size,
      (_) => List<bool>.filled(_difficulty.size, false),
    );
    visited[start.y][start.x] = true;
    Point<int> farthest = start;

    for (int cursor = 0; cursor < queue.length; cursor++) {
      final Point<int> current = queue[cursor];
      farthest = current;
      for (final Point<int> next in _openNeighbors(current)) {
        if (visited[next.y][next.x]) {
          continue;
        }
        visited[next.y][next.x] = true;
        queue.add(next);
      }
    }
    return farthest;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.keyW) {
      _move(_Direction.up);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.keyD) {
      _move(_Direction.right);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS) {
      _move(_Direction.down);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.keyA) {
      _move(_Direction.left);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      _newGame();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _move(_Direction direction) {
    if (_finished || _isSolving) {
      return;
    }
    _moveTo(
      Point<int>(_player.x + direction.dx, _player.y + direction.dy),
    );
  }

  void _moveTo(Point<int> next) {
    if (!_isOpen(next)) {
      return;
    }
    setState(() {
      _player = next;
      _moves++;
    });
    if (_player == _goal) {
      _finishGame();
    }
  }

  void _playWithAlgorithm() {
    if (_finished || _isSolving) {
      return;
    }
    final _MazeSolveResult result = _findShortestPath(_player, _goal);
    final List<Point<int>> path = result.path;
    setState(() {
      _bfsStats = result.stats;
      _bfsLogs = result.logs;
    });
    if (path.length <= 1) {
      return;
    }
    _solverTimer?.cancel();
    setState(() {
      _solutionPath = path;
      _isSolving = true;
    });
    int index = 1;
    _solverTimer = Timer.periodic(
      const Duration(milliseconds: 120),
      (Timer timer) {
        if (!mounted || index >= path.length || _finished) {
          timer.cancel();
          if (mounted && !_finished) {
            setState(() {
              _isSolving = false;
            });
          }
          return;
        }
        _moveTo(path[index]);
        index++;
        if (_finished) {
          timer.cancel();
        }
      },
    );
  }

  _MazeSolveResult _findShortestPath(Point<int> start, Point<int> goal) {
    final Stopwatch stopwatch = Stopwatch()..start();
    final List<Point<int>> queue = <Point<int>>[start];
    final Map<Point<int>, Point<int>?> previous = <Point<int>, Point<int>?>{
      start: null,
    };
    final List<String> logs = <String>[
      '0000  start BFS from ${_formatPoint(start)} to ${_formatPoint(goal)}',
    ];
    int expandedCount = 0;
    int maxFrontierCount = queue.length;
    Point<int>? currentPoint;

    void appendLog(String message) {
      logs.add('${logs.length.toString().padLeft(4, '0')}  $message');
    }

    for (int cursor = 0; cursor < queue.length; cursor++) {
      final Point<int> current = queue[cursor];
      currentPoint = current;
      expandedCount++;
      appendLog(
        'dequeue ${_formatPoint(current)} expanded=$expandedCount queue=${queue.length - cursor - 1}',
      );
      if (current == goal) {
        appendLog('goal reached at ${_formatPoint(current)}');
        break;
      }
      for (final Point<int> next in _openNeighbors(current)) {
        if (previous.containsKey(next)) {
          appendLog(
              'skip ${_formatPoint(next)} from ${_formatPoint(current)}: visited');
          continue;
        }
        previous[next] = current;
        queue.add(next);
        appendLog(
          'visit ${_formatPoint(next)} from ${_formatPoint(current)} queue=${queue.length - cursor - 1}',
        );
      }
      maxFrontierCount = max(maxFrontierCount, queue.length - cursor - 1);
    }

    if (!previous.containsKey(goal)) {
      stopwatch.stop();
      final _BfsStats stats = _BfsStats(
        visitedCount: previous.length,
        expandedCount: expandedCount,
        frontierCount: 0,
        maxFrontierCount: maxFrontierCount,
        pathLength: 0,
        elapsedMicroseconds: stopwatch.elapsedMicroseconds,
        currentPoint: currentPoint,
        foundPath: false,
      );
      appendLog(
        'finish: found=false visited=${stats.visitedCount} expanded=${stats.expandedCount} elapsed=${(stats.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms',
      );
      return _MazeSolveResult(
        path: <Point<int>>[],
        stats: stats,
        logs: logs,
      );
    }
    final List<Point<int>> path = <Point<int>>[];
    Point<int>? current = goal;
    while (current != null) {
      path.add(current);
      current = previous[current];
    }
    final List<Point<int>> result = path.reversed.toList(growable: false);
    stopwatch.stop();
    final _BfsStats stats = _BfsStats(
      visitedCount: previous.length,
      expandedCount: expandedCount,
      frontierCount: max(queue.length - expandedCount, 0),
      maxFrontierCount: maxFrontierCount,
      pathLength: result.length,
      elapsedMicroseconds: stopwatch.elapsedMicroseconds,
      currentPoint: currentPoint,
      foundPath: true,
    );
    appendLog('rebuild path: ${result.map(_formatPoint).join(' -> ')}');
    appendLog(
      'finish: found=true path=${stats.pathLength} visited=${stats.visitedCount} expanded=${stats.expandedCount} elapsed=${(stats.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms',
    );
    return _MazeSolveResult(
      path: result,
      stats: stats,
      logs: logs,
    );
  }

  String _formatPoint(Point<int> point) {
    return '(${point.x},${point.y})';
  }

  Offset _defaultLogsOffset(Size bounds, Size panelSize) {
    return Offset(max(18, bounds.width - panelSize.width - 18), 18);
  }

  Size _clampLogsSize(Size size, Size bounds) {
    final double maxWidth = max(280, bounds.width - 36);
    final double maxHeight = max(180, bounds.height - 36);
    return Size(
      size.width.clamp(280, maxWidth) as double,
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

  List<Point<int>> _openNeighbors(Point<int> point) {
    return _Direction.values
        .map(
          (_Direction direction) => Point<int>(
            point.x + direction.dx,
            point.y + direction.dy,
          ),
        )
        .where(_isOpen)
        .toList(growable: false);
  }

  bool _isOpen(Point<int> point) {
    return point.x >= 0 &&
        point.y >= 0 &&
        point.x < _difficulty.size &&
        point.y < _difficulty.size &&
        !_walls[point.y][point.x];
  }

  void _finishGame() {
    _finished = true;
    _timer?.cancel();
    _solverTimer?.cancel();
    _isSolving = false;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('抵达终点'),
          content: Text('用时 $_seconds 秒，走了 $_moves 步。'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('看看迷宫'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newGame();
              },
              child: const Text('再来一局'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      autofocus: true,
      child: Scaffold(
        appBar: GlobalStore.isMobile
            ? AppBar(
                title: const Text('迷宫'),
                centerTitle: true,
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
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
                    Column(
                      children: <Widget>[
                        _MazeToolbar(
                          difficulty: _difficulty,
                          seconds: _seconds,
                          moves: _moves,
                          isSolving: _isSolving,
                          solutionLength: _solutionPath.length,
                          onDifficultyChanged: (MazeDifficulty value) {
                            setState(() {
                              _difficulty = value;
                            });
                            _newGame();
                          },
                          onRestart: _newGame,
                          onSolve: _playWithAlgorithm,
                        ),
                        const SizedBox(height: 12),
                        _BfsStatsPanel(stats: _bfsStats),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Center(
                            child: LayoutBuilder(
                              builder: (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                final double boardSize = min(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                return SizedBox.square(
                                  dimension: boardSize,
                                  child: _MazeBoard(
                                    walls: _walls,
                                    player: _player,
                                    goal: _goal,
                                    solutionPath: _solutionPath,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DirectionPad(onMove: _move),
                      ],
                    ),
                    if (_bfsLogs.isNotEmpty)
                      Positioned(
                        left: panelOffset.dx,
                        top: panelOffset.dy,
                        child: _BfsLogsPanel(
                          logs: _bfsLogs,
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
                              _bfsLogs = <String>[];
                            });
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MazeToolbar extends StatelessWidget {
  final MazeDifficulty difficulty;
  final int seconds;
  final int moves;
  final bool isSolving;
  final int solutionLength;
  final ValueChanged<MazeDifficulty> onDifficultyChanged;
  final VoidCallback onRestart;
  final VoidCallback onSolve;

  const _MazeToolbar({
    required this.difficulty,
    required this.seconds,
    required this.moves,
    required this.isSolving,
    required this.solutionLength,
    required this.onDifficultyChanged,
    required this.onRestart,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _InfoTile(
          icon: Icons.timer_outlined,
          label: '时间',
          value: '${seconds}s',
        ),
        _InfoTile(
          icon: Icons.directions_walk_outlined,
          label: '步数',
          value: '$moves',
        ),
        _InfoTile(
          icon: Icons.route_outlined,
          label: '路径',
          value: solutionLength == 0 ? '-' : '$solutionLength',
        ),
        SegmentedButton<MazeDifficulty>(
          segments: MazeDifficulty.values
              .map(
                (MazeDifficulty value) => ButtonSegment<MazeDifficulty>(
                  value: value,
                  label: Text(value.label),
                ),
              )
              .toList(),
          selected: <MazeDifficulty>{difficulty},
          onSelectionChanged: (Set<MazeDifficulty> values) {
            onDifficultyChanged(values.first);
          },
        ),
        FilledButton.icon(
          onPressed: isSolving ? null : onSolve,
          icon: const Icon(Icons.smart_toy_outlined),
          label: Text(isSolving ? '算法中' : '算法玩'),
        ),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh),
          label: const Text('重开'),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 44,
        width: 118,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text('$label $value'),
          ],
        ),
      ),
    );
  }
}

class _BfsStatsPanel extends StatelessWidget {
  final _BfsStats stats;

  const _BfsStatsPanel({required this.stats});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String current = stats.currentPoint == null
        ? '-'
        : '(${stats.currentPoint!.x}, ${stats.currentPoint!.y})';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            _BfsChip(
              label: 'BFS',
              value: stats.visitedCount == 0
                  ? '等待运行'
                  : stats.foundPath
                      ? '找到路径'
                      : '未找到',
            ),
            _BfsChip(label: '访问', value: '${stats.visitedCount}'),
            _BfsChip(label: '展开', value: '${stats.expandedCount}'),
            _BfsChip(label: '队列剩余', value: '${stats.frontierCount}'),
            _BfsChip(label: '最大队列', value: '${stats.maxFrontierCount}'),
            _BfsChip(label: '当前点', value: current),
            _BfsChip(label: '最短路', value: '${stats.pathLength}'),
            _BfsChip(
              label: '耗时',
              value:
                  '${(stats.elapsedMicroseconds / 1000).toStringAsFixed(2)}ms',
            ),
          ],
        ),
      ),
    );
  }
}

class _BfsChip extends StatelessWidget {
  final String label;
  final String value;

  const _BfsChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 34,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _BfsLogsPanel extends StatelessWidget {
  final List<String> logs;
  final Size size;
  final ValueChanged<DragUpdateDetails> onDragUpdate;
  final ValueChanged<DragUpdateDetails> onResizeUpdate;
  final VoidCallback onClose;

  const _BfsLogsPanel({
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
          color: Colors.black87,
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
                                'BFS Logs',
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
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: logs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(
                          logs[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.35,
                          ),
                        );
                      },
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

class _MazeBoard extends StatelessWidget {
  final List<List<bool>> walls;
  final Point<int> player;
  final Point<int> goal;
  final List<Point<int>> solutionPath;

  const _MazeBoard({
    required this.walls,
    required this.player,
    required this.goal,
    required this.solutionPath,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: _MazePainter(
            walls: walls,
            player: player,
            goal: goal,
            solutionPath: solutionPath,
            wallColor: colorScheme.onSurface,
            pathColor: colorScheme.surface,
            solutionColor: colorScheme.primary.withValues(alpha: 0.20),
            playerColor: colorScheme.primary,
            goalColor: Colors.green,
          ),
        ),
      ),
    );
  }
}

class _MazePainter extends CustomPainter {
  final List<List<bool>> walls;
  final Point<int> player;
  final Point<int> goal;
  final List<Point<int>> solutionPath;
  final Color wallColor;
  final Color pathColor;
  final Color solutionColor;
  final Color playerColor;
  final Color goalColor;

  const _MazePainter({
    required this.walls,
    required this.player,
    required this.goal,
    required this.solutionPath,
    required this.wallColor,
    required this.pathColor,
    required this.solutionColor,
    required this.playerColor,
    required this.goalColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int count = walls.length;
    final double cell = size.width / count;
    final Paint paint = Paint();

    canvas.drawRect(Offset.zero & size, paint..color = pathColor);
    for (int y = 0; y < count; y++) {
      for (int x = 0; x < count; x++) {
        if (!walls[y][x]) {
          continue;
        }
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          paint..color = wallColor,
        );
      }
    }

    for (final Point<int> point in solutionPath) {
      canvas.drawCircle(
        Offset(point.x * cell + cell / 2, point.y * cell + cell / 2),
        cell * 0.18,
        paint..color = solutionColor,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          goal.x * cell + cell * 0.18,
          goal.y * cell + cell * 0.18,
          cell * 0.64,
          cell * 0.64,
        ),
        Radius.circular(cell * 0.18),
      ),
      paint..color = goalColor,
    );
    canvas.drawCircle(
      Offset(player.x * cell + cell / 2, player.y * cell + cell / 2),
      cell * 0.34,
      paint..color = playerColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) {
    return oldDelegate.walls != walls ||
        oldDelegate.player != player ||
        oldDelegate.goal != goal ||
        oldDelegate.solutionPath != solutionPath ||
        oldDelegate.wallColor != wallColor ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.solutionColor != solutionColor ||
        oldDelegate.playerColor != playerColor ||
        oldDelegate.goalColor != goalColor;
  }
}

class _DirectionPad extends StatelessWidget {
  final ValueChanged<_Direction> onMove;

  const _DirectionPad({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 172,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_up,
              onPressed: () => onMove(_Direction.up),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_left,
              onPressed: () => onMove(_Direction.left),
            ),
          ),
          Positioned(
            bottom: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_down,
              onPressed: () => onMove(_Direction.down),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _DirectionButton(
              icon: Icons.keyboard_arrow_right,
              onPressed: () => onMove(_Direction.right),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _DirectionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: '移动',
      style: IconButton.styleFrom(
        fixedSize: const Size.square(52),
      ),
    );
  }
}

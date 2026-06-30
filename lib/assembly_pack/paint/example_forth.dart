import 'dart:math';

import 'package:flutter_text/init.dart';

enum GameStatus { finish, playing }

enum GomokuMode {
  humanVsAi('我 vs 算法'),
  aiVsAi('算法互下');

  final String label;

  const GomokuMode(this.label);
}

enum _ForbiddenType {
  none,
  overline,
  doubleThree,
  doubleFour;
}

class _GomokuMove {
  final int row;
  final int col;

  const _GomokuMove(this.row, this.col);

  @override
  bool operator ==(Object other) {
    return other is _GomokuMove && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

class _AiChoice {
  final _GomokuMove move;
  final int score;
  final List<String> logs;

  const _AiChoice({
    required this.move,
    required this.score,
    required this.logs,
  });
}

class PaintExampleForth extends StatefulWidget {
  const PaintExampleForth({Key? key}) : super(key: key);

  @override
  State<PaintExampleForth> createState() => _PaintExampleForthState();
}

class _PaintExampleForthState extends State<PaintExampleForth> {
  static const int _size = 15;
  static const int _empty = 0;
  static const int _black = 1;
  static const int _white = 2;
  static const List<List<int>> _directions = <List<int>>[
    <int>[1, 0],
    <int>[0, 1],
    <int>[1, 1],
    <int>[1, -1],
  ];

  final Random _random = Random();
  late List<List<int>> _board;
  final List<_GomokuMove> _moves = <_GomokuMove>[];
  final List<String> _logs = <String>[];
  GomokuMode _mode = GomokuMode.humanVsAi;
  GameStatus _status = GameStatus.playing;
  int _turn = _black;
  Timer? _autoTimer;
  bool _aiThinking = false;
  _GomokuMove? _lastMove;
  _GomokuMove? _suggestMove;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _reset() {
    _autoTimer?.cancel();
    _board = List<List<int>>.generate(
      _size,
      (_) => List<int>.filled(_size, _empty),
    );
    _moves.clear();
    _logs
      ..clear()
      ..add('新局开始：黑棋先行。黑棋禁手：长连、三三、四四。');
    _turn = _black;
    _status = GameStatus.playing;
    _lastMove = null;
    _suggestMove = null;
    _aiThinking = false;
    setState(() {});
    _syncAiVsAi();
  }

  void _setMode(GomokuMode mode) {
    if (_mode == mode) {
      return;
    }
    setState(() {
      _mode = mode;
      _logs.add('模式切换：${mode.label}');
    });
    _syncAiVsAi();
  }

  void _syncAiVsAi() {
    _autoTimer?.cancel();
    if (_mode != GomokuMode.aiVsAi || _status != GameStatus.playing) {
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (mounted && _mode == GomokuMode.aiVsAi && !_aiThinking) {
        _playAiMove();
      }
    });
    _autoTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (mounted && !_aiThinking && _status == GameStatus.playing) {
        _playAiMove();
      }
    });
  }

  bool get _isHumanTurn {
    return _mode == GomokuMode.humanVsAi &&
        _turn == _black &&
        _status == GameStatus.playing &&
        !_aiThinking;
  }

  void _handleTap(int row, int col) {
    if (!_isHumanTurn || !_inside(row, col) || _board[row][col] != _empty) {
      return;
    }
    final _ForbiddenType forbidden = _forbiddenType(_board, row, col, _black);
    if (forbidden != _ForbiddenType.none) {
      setState(() {
        _logs.add(
            '黑棋 ${_formatMove(row, col)} 禁手：${_forbiddenText(forbidden)}。');
      });
      return;
    }
    _commitMove(row, col, _black, '你');
    if (_status == GameStatus.playing) {
      Future<void>.delayed(const Duration(milliseconds: 360), () {
        if (mounted && _turn == _white) {
          _playAiMove();
        }
      });
    }
  }

  void _playAiMove() {
    if (_status != GameStatus.playing) {
      return;
    }
    setState(() {
      _aiThinking = true;
    });
    final _AiChoice choice = _chooseAiMove(_turn);
    setState(() {
      _logs.addAll(choice.logs);
      _suggestMove = choice.move;
    });
    _commitMove(
      choice.move.row,
      choice.move.col,
      _turn,
      _turn == _black ? '黑棋算法' : '白棋算法',
      score: choice.score,
    );
    if (mounted) {
      setState(() {
        _aiThinking = false;
      });
    }
  }

  void _commitMove(
    int row,
    int col,
    int player,
    String actor, {
    int? score,
  }) {
    setState(() {
      _board[row][col] = player;
      _moves.add(_GomokuMove(row, col));
      _lastMove = _GomokuMove(row, col);
      _logs.add(
        '$actor 落子 ${_formatMove(row, col)}${score == null ? '' : '，评分 $score'}。',
      );
      final bool win = _isWin(_board, row, col, player);
      if (win) {
        _status = GameStatus.finish;
        _autoTimer?.cancel();
        _logs.add('${_playerName(player)}获胜。');
        ToastUtils.showToast(msg: '${_playerName(player)}获胜！');
        return;
      }
      if (_moves.length >= _size * _size) {
        _status = GameStatus.finish;
        _autoTimer?.cancel();
        _logs.add('棋盘已满，和棋。');
        return;
      }
      _turn = _opponent(player);
    });
  }

  _AiChoice _chooseAiMove(int player) {
    final List<String> logs = <String>[
      '${_playerName(player)}算法开始搜索：候选点来自已有棋子周围两格。',
    ];
    final List<_GomokuMove> candidates = _candidateMoves(_board);
    if (candidates.isEmpty) {
      return _AiChoice(
        move: const _GomokuMove(_size ~/ 2, _size ~/ 2),
        score: 0,
        logs: logs,
      );
    }

    _GomokuMove best = candidates.first;
    int bestScore = -1 << 30;
    int checked = 0;
    for (final _GomokuMove move in candidates) {
      if (_board[move.row][move.col] != _empty) {
        continue;
      }
      if (player == _black &&
          _forbiddenType(_board, move.row, move.col, _black) !=
              _ForbiddenType.none) {
        continue;
      }
      final List<List<int>> next = _copyBoard(_board);
      next[move.row][move.col] = player;
      final int score = _minimax(
        next,
        depth: 2,
        currentPlayer: _opponent(player),
        aiPlayer: player,
        alpha: -1 << 30,
        beta: 1 << 30,
      );
      checked++;
      if (score > bestScore || (score == bestScore && _random.nextBool())) {
        bestScore = score;
        best = move;
      }
    }
    logs.add('搜索完成：评估 $checked 个候选点，选择 ${_formatMove(best.row, best.col)}。');
    logs.add(_explainMove(best, player, bestScore));
    return _AiChoice(move: best, score: bestScore, logs: logs);
  }

  int _minimax(
    List<List<int>> board, {
    required int depth,
    required int currentPlayer,
    required int aiPlayer,
    required int alpha,
    required int beta,
  }) {
    final int winner = _winner(board);
    if (winner == aiPlayer) {
      return 1000000 + depth;
    }
    if (winner == _opponent(aiPlayer)) {
      return -1000000 - depth;
    }
    if (depth == 0) {
      return _evaluateBoard(board, aiPlayer) -
          _evaluateBoard(board, _opponent(aiPlayer));
    }

    final List<_GomokuMove> candidates =
        _candidateMoves(board).take(18).toList();
    if (candidates.isEmpty) {
      return _evaluateBoard(board, aiPlayer);
    }
    final bool maximizing = currentPlayer == aiPlayer;
    int best = maximizing ? -1 << 30 : 1 << 30;
    for (final _GomokuMove move in candidates) {
      if (currentPlayer == _black &&
          _forbiddenType(board, move.row, move.col, _black) !=
              _ForbiddenType.none) {
        continue;
      }
      final List<List<int>> next = _copyBoard(board);
      next[move.row][move.col] = currentPlayer;
      final int score = _minimax(
        next,
        depth: depth - 1,
        currentPlayer: _opponent(currentPlayer),
        aiPlayer: aiPlayer,
        alpha: alpha,
        beta: beta,
      );
      if (maximizing) {
        best = max(best, score);
        alpha = max(alpha, best);
      } else {
        best = min(best, score);
        beta = min(beta, best);
      }
      if (beta <= alpha) {
        break;
      }
    }
    return best;
  }

  List<_GomokuMove> _candidateMoves(List<List<int>> board) {
    final Set<_GomokuMove> result = <_GomokuMove>{};
    if (_moves.isEmpty && identical(board, _board)) {
      return const <_GomokuMove>[_GomokuMove(_size ~/ 2, _size ~/ 2)];
    }
    bool hasStone = false;
    for (int row = 0; row < _size; row++) {
      for (int col = 0; col < _size; col++) {
        if (board[row][col] == _empty) {
          continue;
        }
        hasStone = true;
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final int nr = row + dr;
            final int nc = col + dc;
            if (_inside(nr, nc) && board[nr][nc] == _empty) {
              result.add(_GomokuMove(nr, nc));
            }
          }
        }
      }
    }
    if (!hasStone) {
      result.add(const _GomokuMove(_size ~/ 2, _size ~/ 2));
    }
    final List<_GomokuMove> sorted = result.toList()
      ..sort(
        (_GomokuMove a, _GomokuMove b) =>
            _quickMoveScore(board, b).compareTo(_quickMoveScore(board, a)),
      );
    return sorted;
  }

  int _quickMoveScore(List<List<int>> board, _GomokuMove move) {
    int score = 0;
    for (final int player in <int>[_black, _white]) {
      final List<List<int>> next = _copyBoard(board);
      next[move.row][move.col] = player;
      score += _linePotential(next, move.row, move.col, player);
    }
    const int center = _size ~/ 2;
    score += 20 - ((move.row - center).abs() + (move.col - center).abs());
    return score;
  }

  int _evaluateBoard(List<List<int>> board, int player) {
    int score = 0;
    for (int row = 0; row < _size; row++) {
      for (int col = 0; col < _size; col++) {
        if (board[row][col] == player) {
          score += _linePotential(board, row, col, player);
        }
      }
    }
    return score;
  }

  int _linePotential(List<List<int>> board, int row, int col, int player) {
    int score = 0;
    for (final List<int> d in _directions) {
      final _LineInfo info = _lineInfo(board, row, col, player, d[0], d[1]);
      score += _scoreLine(info.count, info.openEnds);
    }
    return score;
  }

  int _scoreLine(int count, int openEnds) {
    if (count >= 5) {
      return 100000;
    }
    if (count == 4 && openEnds == 2) {
      return 20000;
    }
    if (count == 4 && openEnds == 1) {
      return 5000;
    }
    if (count == 3 && openEnds == 2) {
      return 1200;
    }
    if (count == 3 && openEnds == 1) {
      return 260;
    }
    if (count == 2 && openEnds == 2) {
      return 120;
    }
    if (count == 2 && openEnds == 1) {
      return 30;
    }
    return count * 6 + openEnds;
  }

  String _explainMove(_GomokuMove move, int player, int score) {
    final _ForbiddenType forbidden = player == _black
        ? _forbiddenType(_board, move.row, move.col, player)
        : _ForbiddenType.none;
    if (forbidden != _ForbiddenType.none) {
      return '说明：这个点原本会触发${_forbiddenText(forbidden)}，算法已避开。';
    }
    final List<List<int>> next = _copyBoard(_board);
    next[move.row][move.col] = player;
    if (_isWin(next, move.row, move.col, player)) {
      return '说明：这是直接成五的胜手。';
    }
    final int opponent = _opponent(player);
    for (final _GomokuMove candidate in _candidateMoves(_board)) {
      final List<List<int>> block = _copyBoard(_board);
      block[candidate.row][candidate.col] = opponent;
      if (_isWin(block, candidate.row, candidate.col, opponent) &&
          candidate == move) {
        return '说明：这手是在挡对方的直接胜点。';
      }
    }
    return '说明：综合攻防和棋形评分，当前局面此点评分为 $score。';
  }

  bool _isWin(List<List<int>> board, int row, int col, int player) {
    for (final List<int> d in _directions) {
      final _LineInfo info = _lineInfo(board, row, col, player, d[0], d[1]);
      if (player == _black && info.count > 5) {
        continue;
      }
      if (info.count >= 5) {
        return true;
      }
    }
    return false;
  }

  int _winner(List<List<int>> board) {
    for (int row = 0; row < _size; row++) {
      for (int col = 0; col < _size; col++) {
        final int player = board[row][col];
        if (player != _empty && _isWin(board, row, col, player)) {
          return player;
        }
      }
    }
    return _empty;
  }

  _ForbiddenType _forbiddenType(
    List<List<int>> board,
    int row,
    int col,
    int player,
  ) {
    if (player != _black || board[row][col] != _empty) {
      return _ForbiddenType.none;
    }
    final List<List<int>> next = _copyBoard(board);
    next[row][col] = player;
    if (_hasOverline(next, row, col, player)) {
      return _ForbiddenType.overline;
    }
    if (_openFourCount(next, row, col, player) >= 2) {
      return _ForbiddenType.doubleFour;
    }
    if (_openThreeCount(next, row, col, player) >= 2) {
      return _ForbiddenType.doubleThree;
    }
    return _ForbiddenType.none;
  }

  bool _hasOverline(List<List<int>> board, int row, int col, int player) {
    return _directions.any((List<int> d) {
      return _lineInfo(board, row, col, player, d[0], d[1]).count > 5;
    });
  }

  int _openFourCount(List<List<int>> board, int row, int col, int player) {
    int count = 0;
    for (final List<int> d in _directions) {
      final _LineInfo info = _lineInfo(board, row, col, player, d[0], d[1]);
      if (info.count == 4 && info.openEnds >= 1) {
        count++;
      }
    }
    return count;
  }

  int _openThreeCount(List<List<int>> board, int row, int col, int player) {
    int count = 0;
    for (final List<int> d in _directions) {
      final _LineInfo info = _lineInfo(board, row, col, player, d[0], d[1]);
      if (info.count == 3 && info.openEnds == 2) {
        count++;
      }
    }
    return count;
  }

  _LineInfo _lineInfo(
    List<List<int>> board,
    int row,
    int col,
    int player,
    int dr,
    int dc,
  ) {
    int count = 1;
    int openEnds = 0;

    int r = row + dr;
    int c = col + dc;
    while (_inside(r, c) && board[r][c] == player) {
      count++;
      r += dr;
      c += dc;
    }
    if (_inside(r, c) && board[r][c] == _empty) {
      openEnds++;
    }

    r = row - dr;
    c = col - dc;
    while (_inside(r, c) && board[r][c] == player) {
      count++;
      r -= dr;
      c -= dc;
    }
    if (_inside(r, c) && board[r][c] == _empty) {
      openEnds++;
    }

    return _LineInfo(count: count, openEnds: openEnds);
  }

  List<List<int>> _copyBoard(List<List<int>> board) {
    return board.map((List<int> row) => List<int>.from(row)).toList();
  }

  int _opponent(int player) {
    return player == _black ? _white : _black;
  }

  bool _inside(int row, int col) {
    return row >= 0 && row < _size && col >= 0 && col < _size;
  }

  String _playerName(int player) {
    return player == _black ? '黑棋' : '白棋';
  }

  String _formatMove(int row, int col) {
    const String letters = 'ABCDEFGHIJKLMNO';
    return '${letters[col]}${_size - row}';
  }

  String _forbiddenText(_ForbiddenType type) {
    switch (type) {
      case _ForbiddenType.overline:
        return '长连';
      case _ForbiddenType.doubleThree:
        return '三三';
      case _ForbiddenType.doubleFour:
        return '四四';
      case _ForbiddenType.none:
        return '无';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('五子棋'),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 900;
              final Widget board = Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _GomokuBoard(
                    board: _board,
                    lastMove: _lastMove,
                    suggestMove: _suggestMove,
                    enabled: _isHumanTurn,
                    onTap: _handleTap,
                  ),
                ),
              );
              final Widget side = _GomokuSidePanel(
                mode: _mode,
                status: _status,
                turn: _turn,
                aiThinking: _aiThinking,
                moveCount: _moves.length,
                logs: _logs,
                onModeChanged: _setMode,
                onRestart: _reset,
                onAiMove: _playAiMove,
              );
              if (compact) {
                return Column(
                  children: <Widget>[
                    Expanded(child: board),
                    const SizedBox(height: 12),
                    SizedBox(height: 260, child: side),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: board),
                  const SizedBox(width: 18),
                  SizedBox(width: 380, child: side),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LineInfo {
  final int count;
  final int openEnds;

  const _LineInfo({
    required this.count,
    required this.openEnds,
  });
}

class _GomokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final _GomokuMove? lastMove;
  final _GomokuMove? suggestMove;
  final bool enabled;
  final void Function(int row, int col) onTap;

  const _GomokuBoard({
    required this.board,
    required this.lastMove,
    required this.suggestMove,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: enabled
          ? (TapUpDetails details) {
              final RenderBox box = context.findRenderObject()! as RenderBox;
              final Offset local = box.globalToLocal(details.globalPosition);
              final double cell = box.size.width / board.length;
              final int col =
                  (local.dx / cell).floor().clamp(0, board.length - 1);
              final int row =
                  (local.dy / cell).floor().clamp(0, board.length - 1);
              onTap(row, col);
            }
          : null,
      child: CustomPaint(
        painter: _GomokuPainter(
          board: board,
          lastMove: lastMove,
          suggestMove: suggestMove,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GomokuPainter extends CustomPainter {
  final List<List<int>> board;
  final _GomokuMove? lastMove;
  final _GomokuMove? suggestMove;

  const _GomokuPainter({
    required this.board,
    required this.lastMove,
    required this.suggestMove,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int count = board.length;
    final double cell = size.width / count;
    final Paint paint = Paint()..isAntiAlias = true;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      paint..color = const Color(0xffd8b36a),
    );

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black87;
    for (int i = 0; i < count; i++) {
      final double p = cell / 2 + i * cell;
      canvas.drawLine(
          Offset(cell / 2, p), Offset(size.width - cell / 2, p), paint);
      canvas.drawLine(
          Offset(p, cell / 2), Offset(p, size.height - cell / 2), paint);
    }

    paint.style = PaintingStyle.fill;
    for (final int star in <int>[3, 7, 11]) {
      canvas.drawCircle(
        Offset(cell / 2 + star * cell, cell / 2 + star * cell),
        cell * 0.08,
        paint..color = Colors.black87,
      );
    }

    if (suggestMove != null) {
      canvas.drawCircle(
        _centerOf(suggestMove!, cell),
        cell * 0.18,
        paint..color = Colors.blueAccent.withValues(alpha: 0.65),
      );
    }

    for (int row = 0; row < count; row++) {
      for (int col = 0; col < count; col++) {
        final int stone = board[row][col];
        if (stone == 0) {
          continue;
        }
        final Offset center =
            Offset(cell / 2 + col * cell, cell / 2 + row * cell);
        canvas.drawCircle(
          center + Offset(cell * 0.05, cell * 0.06),
          cell * 0.38,
          paint..color = Colors.black.withValues(alpha: 0.2),
        );
        canvas.drawCircle(
          center,
          cell * 0.38,
          paint..color = stone == 1 ? Colors.black : Colors.white,
        );
        canvas.drawCircle(
          center,
          cell * 0.38,
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.black87,
        );
        paint.style = PaintingStyle.fill;
      }
    }

    if (lastMove != null) {
      canvas.drawCircle(
        _centerOf(lastMove!, cell),
        cell * 0.12,
        paint..color = Colors.redAccent,
      );
    }
  }

  Offset _centerOf(_GomokuMove move, double cell) {
    return Offset(cell / 2 + move.col * cell, cell / 2 + move.row * cell);
  }

  @override
  bool shouldRepaint(covariant _GomokuPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.lastMove != lastMove ||
        oldDelegate.suggestMove != suggestMove;
  }
}

class _GomokuSidePanel extends StatelessWidget {
  final GomokuMode mode;
  final GameStatus status;
  final int turn;
  final bool aiThinking;
  final int moveCount;
  final List<String> logs;
  final ValueChanged<GomokuMode> onModeChanged;
  final VoidCallback onRestart;
  final VoidCallback onAiMove;

  const _GomokuSidePanel({
    required this.mode,
    required this.status,
    required this.turn,
    required this.aiThinking,
    required this.moveCount,
    required this.logs,
    required this.onModeChanged,
    required this.onRestart,
    required this.onAiMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            SegmentedButton<GomokuMode>(
              segments: GomokuMode.values
                  .map(
                    (GomokuMode value) => ButtonSegment<GomokuMode>(
                      value: value,
                      label: Text(value.label),
                    ),
                  )
                  .toList(),
              selected: <GomokuMode>{mode},
              onSelectionChanged: (Set<GomokuMode> values) {
                onModeChanged(values.first);
              },
            ),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('新局'),
            ),
            OutlinedButton.icon(
              onPressed:
                  status == GameStatus.playing && !aiThinking ? onAiMove : null,
              icon: const Icon(Icons.smart_toy_outlined),
              label: const Text('算法走一步'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _InfoTile(label: '当前', value: turn == 1 ? '黑棋' : '白棋'),
            _InfoTile(label: '步数', value: '$moveCount'),
            _InfoTile(
                label: '状态',
                value: aiThinking
                    ? '算法思考'
                    : status == GameStatus.finish
                        ? '结束'
                        : '进行中'),
            const _InfoTile(label: '禁手', value: '黑棋'),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
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
        width: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

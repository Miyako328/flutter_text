import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../idle_models.dart';

class IdleExpeditionGameView extends StatefulWidget {
  const IdleExpeditionGameView({
    required this.state,
    required this.onHeroTap,
    required this.onCampTap,
    required this.onRouteTap,
    required this.onUnavailableTap,
    super.key,
  });

  final MoonlitIdleState state;
  final VoidCallback onHeroTap;
  final VoidCallback onCampTap;
  final void Function(MoonlitRoute route) onRouteTap;
  final void Function(String label) onUnavailableTap;

  @override
  State<IdleExpeditionGameView> createState() => _IdleExpeditionGameViewState();
}

class _IdleExpeditionGameViewState extends State<IdleExpeditionGameView> {
  late final IdleExpeditionGame _game;

  @override
  void initState() {
    super.initState();
    _game = IdleExpeditionGame(widget.state);
  }

  @override
  void didUpdateWidget(covariant IdleExpeditionGameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game.updateState(widget.state);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        _handleTap(details.localPosition, context.size ?? Size.zero);
      },
      child: GameWidget<IdleExpeditionGame>(game: _game),
    );
  }

  void _handleTap(Offset position, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final Rect heroRect = _scaledRect(
      const Rect.fromLTWH(0.20, 0.25, 0.18, 0.40),
      size,
    );
    if (heroRect.contains(position)) {
      widget.onHeroTap();
      return;
    }

    final Offset campCenter = _scale(const Offset(0.16, 0.65), size);
    if ((position - campCenter).distance <= 42) {
      widget.onCampTap();
      return;
    }

    for (final _ClickableMapNode node in _clickableNodes) {
      if (node.isCamp) {
        continue;
      }
      final Offset center = _scale(node.position, size);
      if ((position - center).distance <= 42) {
        final MoonlitRoute? route = _routeByKey(node.key);
        if (route != null) {
          widget.onRouteTap(route);
        } else {
          widget.onUnavailableTap(node.label);
        }
        return;
      }
    }
  }

  MoonlitRoute? _routeByKey(String key) {
    for (final MoonlitRoute route in widget.state.openRoutes) {
      if (route.routeKey == key) {
        return route;
      }
    }
    return null;
  }

  Offset _scale(Offset value, Size size) {
    return Offset(value.dx * size.width, value.dy * size.height);
  }

  Rect _scaledRect(Rect rect, Size size) {
    return Rect.fromLTWH(
      rect.left * size.width,
      rect.top * size.height,
      rect.width * size.width,
      rect.height * size.height,
    );
  }
}

class IdleExpeditionGame extends FlameGame<World> {
  IdleExpeditionGame(MoonlitIdleState state) : _state = state;

  MoonlitIdleState _state;
  late final _IdleExpeditionScene _scene;

  MoonlitIdleState get state => _state;

  void updateState(MoonlitIdleState value) {
    _state = value;
    if (isLoaded) {
      _scene.updateState(value);
    }
  }

  @override
  Color backgroundColor() => const Color(0xff17151b);

  @override
  Future<void> onLoad() async {
    _scene = _IdleExpeditionScene(_state);
    add(_scene);
  }
}

class _IdleExpeditionScene extends Component
    with HasGameReference<IdleExpeditionGame> {
  _IdleExpeditionScene(this._state);

  MoonlitIdleState _state;
  ui.Image? _heroSheet;
  double _time = 0;

  static const List<_ExpeditionNode> _nodes = <_ExpeditionNode>[
    _ExpeditionNode(
      key: 'twilight_investigation',
      label: '暮色镇',
      position: Offset(0.16, 0.65),
      icon: Icons.home_work_outlined,
    ),
    _ExpeditionNode(
      key: 'forest_edge_patrol',
      label: '森林外缘',
      position: Offset(0.40, 0.45),
      icon: Icons.forest_outlined,
    ),
    _ExpeditionNode(
      key: 'old_road_ruin_search',
      label: '旧路遗迹',
      position: Offset(0.63, 0.58),
      icon: Icons.account_balance_outlined,
    ),
    _ExpeditionNode(
      key: 'maclay_ruins_deep',
      label: '玛克莱遗址',
      position: Offset(0.84, 0.34),
      icon: Icons.castle_outlined,
    ),
  ];

  void updateState(MoonlitIdleState value) {
    _state = value;
  }

  @override
  Future<void> onLoad() async {
    try {
      _heroSheet = await game.images.load('sylvia/spritesheet.webp');
    } catch (_) {
      _heroSheet = null;
    }
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final Size size = Size(game.size.x, game.size.y);
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    _paintBackdrop(canvas, size);
    _paintTerrain(canvas, size);
    _paintRoute(canvas, size);
    _paintNodes(canvas, size);
    _paintHero(canvas, size);
    _paintParty(canvas, size);
    _paintCornerStatus(canvas, size);
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xff3a2d35),
          Color(0xff211b24),
          Color(0xff3b2923),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final Paint vignette = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 0.82,
        colors: <Color>[
          Color(0x0017151b),
          Color(0x44100e12),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _paintTerrain(Canvas canvas, Size size) {
    final Paint forest = Paint()..color = const Color(0xaa3f7550);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.37, size.height * 0.52),
        width: size.width * 0.46,
        height: size.height * 0.40,
      ),
      forest,
    );

    final Path rift = Path()
      ..moveTo(size.width * 0.08, size.height * 0.86)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.70,
        size.width * 0.92,
        size.height * 0.74,
      );
    canvas.drawPath(
      rift,
      Paint()
        ..color = const Color(0xaa5a4550)
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      rift,
      Paint()
        ..color = const Color(0xffc29a65)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final Paint ruinGlow = Paint()..color = const Color(0x66d7b06c);
    canvas.drawCircle(
      _scale(_nodes.last.position, size),
      math.min(size.width, size.height) * 0.18,
      ruinGlow,
    );
  }

  void _paintRoute(Canvas canvas, Size size) {
    final Path path = Path();
    for (int i = 0; i < _nodes.length; i++) {
      final Offset point = _scale(_nodes[i].position, size);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xaa09080a)
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xffb58c55)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final String? activeRouteKey = _state.activeExpedition?.routeKey;
    final int activeIndex = _nodes.indexWhere(
      (_ExpeditionNode node) => node.key == activeRouteKey,
    );
    if (activeIndex >= 0) {
      final Offset start = _scale(_nodes[activeIndex].position, size);
      final Offset end = _scale(
        _nodes[(activeIndex + 1).clamp(0, _nodes.length - 1)].position,
        size,
      );
      canvas.drawLine(
        start,
        Offset.lerp(start, end, _state.activeExpedition!.currentProgress)!,
        Paint()
          ..color = const Color(0xffffd27d)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintNodes(Canvas canvas, Size size) {
    final bool ruinsUnlocked =
        _state.stageByKey('maclay_ruins_deep')?.unlocked == true;
    final String? activeRouteKey = _state.activeExpedition?.routeKey;
    final double pulse = (math.sin(_time * 4) + 1) / 2;

    for (final _ExpeditionNode node in _nodes) {
      final bool active = node.key == activeRouteKey;
      final bool locked = node.key == 'maclay_ruins_deep' && !ruinsUnlocked;
      final Offset center = _scale(node.position, size);
      final double radius = active ? 24 + pulse * 4 : 21;

      if (active) {
        canvas.drawCircle(
          center,
          radius + 13,
          Paint()
            ..color = Color.lerp(
              const Color(0x22ffd27d),
              const Color(0x66ffd27d),
              pulse,
            )!,
        );
      }

      canvas.drawCircle(
        center + const Offset(0, 4),
        radius,
        Paint()..color = const Color(0x88000000),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = active
              ? const Color(0xffffd27d)
              : locked
                  ? const Color(0xff665760)
                  : const Color(0xffc5a36a),
      );
      canvas.drawCircle(
        center,
        radius - 6,
        Paint()
          ..color = locked ? const Color(0xff28242b) : const Color(0xff332934),
      );

      _paintIcon(canvas, node.icon, center, active, locked);
      _paintLabel(
        canvas,
        node.label,
        center + Offset(0, active ? 34 : 31),
        active,
        locked,
      );
    }
  }

  void _paintParty(Canvas canvas, Size size) {
    final MoonlitExpedition? expedition = _state.activeExpedition;
    if (expedition == null) {
      return;
    }

    final int index = _nodes.indexWhere(
      (_ExpeditionNode node) => node.key == expedition.routeKey,
    );
    if (index < 0) {
      return;
    }

    final Offset start = _scale(_nodes[index].position, size);
    final Offset end = _scale(
      _nodes[(index + 1).clamp(0, _nodes.length - 1)].position,
      size,
    );
    final Offset current = Offset.lerp(start, end, expedition.currentProgress)!;
    final double bob = math.sin(_time * 7) * 2;

    canvas.drawCircle(
      current + Offset(0, 7 + bob.abs()),
      11,
      Paint()..color = const Color(0x99000000),
    );
    canvas.drawCircle(
      current + Offset(0, bob),
      10,
      Paint()..color = const Color(0xffd64a3d),
    );
    canvas.drawCircle(
      current + Offset(0, bob),
      4,
      Paint()..color = const Color(0xffffe7bf),
    );
    _paintLabel(
      canvas,
      expedition.liveCanClaim ? '归队' : '远征队',
      current + Offset(0, -32 + bob),
      true,
      false,
    );
  }

  void _paintHero(Canvas canvas, Size size) {
    final Offset feet = Offset(size.width * 0.28, size.height * 0.62);
    final double bob = math.sin(_time * 2.2) * 2;
    final ui.Image? sheet = _heroSheet;

    canvas.drawOval(
      Rect.fromCenter(
        center: feet + const Offset(0, 7),
        width: 64,
        height: 18,
      ),
      Paint()..color = const Color(0x88000000),
    );

    if (sheet != null) {
      final Rect src = Rect.fromLTWH(
        0,
        0,
        sheet.width / 8,
        sheet.height / 9,
      );
      final Rect dst = Rect.fromCenter(
        center: feet + Offset(0, -55 + bob),
        width: 96,
        height: 104,
      );
      canvas.drawImageRect(sheet, src, dst, Paint());
    } else {
      canvas.drawCircle(
        feet + Offset(0, -36 + bob),
        30,
        Paint()..color = const Color(0xffffd27d),
      );
      canvas.drawCircle(
        feet + Offset(0, -36 + bob),
        22,
        Paint()..color = const Color(0xffd64a3d),
      );
      _paintIcon(
        canvas,
        Icons.person,
        feet + Offset(0, -36 + bob),
        true,
        false,
      );
    }

    _paintLabel(
      canvas,
      '希尔薇娅',
      feet + Offset(0, 16 + bob),
      true,
      false,
    );
  }

  void _paintCornerStatus(Canvas canvas, Size size) {
    final bool ruinsUnlocked =
        _state.stageByKey('maclay_ruins_deep')?.unlocked == true;
    final String line = _state.activeExpedition == null
        ? '待命'
        : '${(_state.activeExpedition!.currentProgress * 100).floor()}%';
    final String lock = ruinsUnlocked ? '遗址已定位' : '收集中';

    _paintPill(
      canvas,
      Offset(size.width - 118, size.height - 38),
      '$lock · $line',
    );
  }

  void _paintPill(Canvas canvas, Offset origin, String text) {
    final TextPainter painter = TextPainter(
      text: const TextSpan(
        text: '',
        style: TextStyle(),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Color(0xffffe7bf),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
    painter.layout(maxWidth: 120);

    final Rect rect = Rect.fromLTWH(
      origin.dx,
      origin.dy,
      painter.width + 18,
      painter.height + 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = const Color(0xcc211d23),
    );
    painter.paint(canvas, origin + const Offset(9, 6));
  }

  void _paintIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    bool active,
    bool locked,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(
            locked ? Icons.lock_outline.codePoint : icon.codePoint),
        style: TextStyle(
          fontSize: active ? 18 : 16,
          fontFamily: locked ? Icons.lock_outline.fontFamily : icon.fontFamily,
          package: locked ? Icons.lock_outline.fontPackage : icon.fontPackage,
          color: active ? const Color(0xff5c2a22) : const Color(0xffe0cfaa),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset center,
    bool active,
    bool locked,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: active
              ? const Color(0xffffe7bf)
              : locked
                  ? const Color(0xffa99ba1)
                  : const Color(0xffd7c7a7),
          fontSize: active ? 15 : 14,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 96);
    painter.paint(canvas, center - Offset(painter.width / 2, 0));
  }

  Offset _scale(Offset value, Size size) {
    return Offset(value.dx * size.width, value.dy * size.height);
  }
}

class _ExpeditionNode {
  const _ExpeditionNode({
    required this.key,
    required this.label,
    required this.position,
    required this.icon,
  });

  final String key;
  final String label;
  final Offset position;
  final IconData icon;
}

const List<_ClickableMapNode> _clickableNodes = <_ClickableMapNode>[
  _ClickableMapNode(
    key: 'twilight_investigation',
    label: '暮色镇',
    position: Offset(0.16, 0.65),
    isCamp: true,
  ),
  _ClickableMapNode(
    key: 'forest_edge_patrol',
    label: '森林外缘',
    position: Offset(0.40, 0.45),
  ),
  _ClickableMapNode(
    key: 'old_road_ruin_search',
    label: '旧路遗迹',
    position: Offset(0.63, 0.58),
  ),
  _ClickableMapNode(
    key: 'maclay_ruins_deep',
    label: '玛克莱遗址',
    position: Offset(0.84, 0.34),
  ),
];

class _ClickableMapNode {
  const _ClickableMapNode({
    required this.key,
    required this.label,
    required this.position,
    this.isCamp = false,
  });

  final String key;
  final String label;
  final Offset position;
  final bool isCamp;
}

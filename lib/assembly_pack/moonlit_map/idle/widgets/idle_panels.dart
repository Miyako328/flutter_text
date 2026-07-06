import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_text/gen/assets.gen.dart';

import '../flame/idle_expedition_game.dart';
import '../idle_models.dart';

class _MoonlitColors {
  static const Color panel = Color(0xee211d23);
  static const Color panelDeep = Color(0xff17151b);
  static const Color border = Color(0xff6e573a);
  static const Color gold = Color(0xffffd27d);
  static const Color text = Color(0xffffe7bf);
  static const Color muted = Color(0xffd7c7a7);
  static const Color red = Color(0xffd64a3d);
  static const Color green = Color(0xff6ea56f);
}

class _GamePanel extends StatelessWidget {
  const _GamePanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight ? const Color(0xee2a2124) : _MoonlitColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? _MoonlitColors.gold : _MoonlitColors.border,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _GameIconSeal extends StatelessWidget {
  const _GameIconSeal({
    required this.icon,
    this.active = false,
  });

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: active ? _MoonlitColors.gold : _MoonlitColors.panelDeep,
        shape: BoxShape.circle,
        border: Border.all(color: _MoonlitColors.border),
      ),
      child: Icon(
        icon,
        color: active ? const Color(0xff43241f) : _MoonlitColors.gold,
        size: 20,
      ),
    );
  }
}

class _GameResourceChip extends StatelessWidget {
  const _GameResourceChip({
    required this.label,
    required this.enough,
  });

  final String label;
  final bool enough;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: enough ? const Color(0x333d6b46) : const Color(0x332c2830),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: enough ? _MoonlitColors.green : const Color(0xff5c5159),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: enough ? const Color(0xffdff0d0) : _MoonlitColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class IdleExpeditionMapPanel extends StatelessWidget {
  const IdleExpeditionMapPanel({
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
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff17151b),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xff4b3a33)),
      ),
      child: SizedBox(
        height: 320,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size mapSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final Offset heroPosition = _heroPosition(mapSize);
            final bool exploring = state.activeExpedition != null &&
                state.activeExpedition!.liveCanClaim == false;
            final MoonlitActiveEncounter? encounter = state.activeEncounter;
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IdleExpeditionGameView(
                    state: state,
                    onHeroTap: onHeroTap,
                    onCampTap: onCampTap,
                    onRouteTap: onRouteTap,
                    onUnavailableTap: onUnavailableTap,
                  ),
                ),
                Positioned(
                  left: heroPosition.dx - 52,
                  top: heroPosition.dy - 118,
                  child: _SylviaHeroButton(
                    running: exploring && encounter == null,
                    battle: encounter != null,
                    onTap: onHeroTap,
                  ),
                ),
                if (encounter != null)
                  Positioned(
                    left: (heroPosition.dx + 34).clamp(
                      12,
                      mapSize.width - 76,
                    ),
                    top: (heroPosition.dy - 92).clamp(
                      58,
                      mapSize.height - 118,
                    ),
                    child: _MonsterMarker(encounter: encounter),
                  ),
                if (encounter != null)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: _LiveBattleOverlay(encounter: encounter),
                  ),
                Positioned(
                  left: 16,
                  top: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '南境裂谷与暮色镇',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xffffe7bf),
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.activeExpedition == null
                            ? '选择一条路线派出远征'
                            : '远征中 · ${state.activeExpedition!.routeName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xffd7c7a7),
                            ),
                      ),
                    ],
                  ),
                ),
                if (encounter == null)
                  Positioned(
                    right: 14,
                    bottom: 12,
                    child: _MapLegend(
                      unlocked:
                          state.stageByKey('maclay_ruins_deep')?.unlocked ==
                              true,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Offset _heroPosition(Size size) {
    final MoonlitExpedition? expedition = state.activeExpedition;
    if (expedition == null) {
      return Offset(size.width * 0.28, size.height * 0.62);
    }

    final int index = _mapRouteNodes.indexWhere(
      (_MapRouteNode node) => node.key == expedition.routeKey,
    );
    if (index < 0) {
      return Offset(size.width * 0.28, size.height * 0.62);
    }

    final Offset start = _scale(_mapRouteNodes[index].position, size);
    final Offset end = _scale(
      _mapRouteNodes[(index + 1).clamp(0, _mapRouteNodes.length - 1)].position,
      size,
    );
    return Offset.lerp(start, end, expedition.currentProgress)!;
  }

  Offset _scale(Offset value, Size size) {
    return Offset(value.dx * size.width, value.dy * size.height);
  }
}

const List<_MapRouteNode> _mapRouteNodes = <_MapRouteNode>[
  _MapRouteNode('twilight_investigation', Offset(0.16, 0.65)),
  _MapRouteNode('forest_edge_patrol', Offset(0.40, 0.45)),
  _MapRouteNode('old_road_ruin_search', Offset(0.63, 0.58)),
  _MapRouteNode('maclay_ruins_deep', Offset(0.84, 0.34)),
];

class _MapRouteNode {
  const _MapRouteNode(this.key, this.position);

  final String key;
  final Offset position;
}

class _SylviaHeroButton extends StatefulWidget {
  const _SylviaHeroButton({
    required this.running,
    required this.battle,
    required this.onTap,
  });

  final bool running;
  final bool battle;
  final VoidCallback onTap;

  @override
  State<_SylviaHeroButton> createState() => _SylviaHeroButtonState();
}

class _SylviaHeroButtonState extends State<_SylviaHeroButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          final double wave = _controller.value < 0.5
              ? _controller.value * 2
              : (1 - _controller.value) * 2;
          final double dy = widget.running || widget.battle ? 0 : -3 + wave * 6;
          final double dx = widget.battle ? (wave - 0.5) * 3 : 0;
          return Transform.translate(
            offset: Offset(dx, dy),
            child: _buildBody(),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final int frameCount = widget.battle ? 6 : 8;
    final int frame =
        (_controller.value * frameCount).floor().clamp(0, frameCount - 1);
    return SizedBox(
      width: 104,
      height: 132,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            bottom: 12,
            child: Container(
              width: widget.running || widget.battle ? 70 : 62,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0x88000000),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (widget.battle)
            _buildBattleFrame(frame)
          else if (widget.running)
            _buildRunFrame(frame)
          else
            _buildImage(
              Assets.imagesSylviaSylviaIdle,
            ),
          const Positioned(
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xcc211d23),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '希尔薇娅',
                  style: TextStyle(
                    color: Color(0xffffe7bf),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunFrame(int frame) {
    switch (frame) {
      case 0:
        return _buildImage(Assets.imagesSylviaRunRun0);
      case 1:
        return _buildImage(Assets.imagesSylviaRunRun1);
      case 2:
        return _buildImage(Assets.imagesSylviaRunRun2);
      case 3:
        return _buildImage(Assets.imagesSylviaRunRun3);
      case 4:
        return _buildImage(Assets.imagesSylviaRunRun4);
      case 5:
        return _buildImage(Assets.imagesSylviaRunRun5);
      case 6:
        return _buildImage(Assets.imagesSylviaRunRun6);
      default:
        return _buildImage(Assets.imagesSylviaRunRun7);
    }
  }

  Widget _buildBattleFrame(int frame) {
    switch (frame) {
      case 0:
        return _buildImage(Assets.imagesSylviaBattleBattle0);
      case 1:
        return _buildImage(Assets.imagesSylviaBattleBattle1);
      case 2:
        return _buildImage(Assets.imagesSylviaBattleBattle2);
      case 3:
        return _buildImage(Assets.imagesSylviaBattleBattle3);
      case 4:
        return _buildImage(Assets.imagesSylviaBattleBattle4);
      case 5:
        return _buildImage(Assets.imagesSylviaBattleBattle5);
      default:
        return _buildImage(Assets.imagesSylviaBattleBattle5);
    }
  }

  Widget _buildImage(AssetGenImage image) {
    return image.image(
      width: 104,
      height: 108,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Container(
          width: 96,
          height: 104,
          decoration: const BoxDecoration(
            color: Color(0xffffd27d),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xff43241f),
            size: 42,
          ),
        );
      },
    );
  }
}

class _MonsterMarker extends StatelessWidget {
  const _MonsterMarker({required this.encounter});

  final MoonlitActiveEncounter encounter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xee3a1f22),
        shape: BoxShape.circle,
        border: Border.all(color: _MoonlitColors.red, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: MonsterPortrait(
            monsterKey: encounter.monster.monsterKey,
            monsterName: encounter.monster.name,
            compact: true,
          ),
        ),
      ),
    );
  }
}

class _LiveBattleOverlay extends StatefulWidget {
  const _LiveBattleOverlay({required this.encounter});

  final MoonlitActiveEncounter encounter;

  @override
  State<_LiveBattleOverlay> createState() => _LiveBattleOverlayState();
}

class _LiveBattleOverlayState extends State<_LiveBattleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MoonlitActiveEncounter encounter = widget.encounter;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final double impact = math.sin(_controller.value * math.pi * 2);
        final double shake = impact.abs() > 0.72 ? impact * 2.4 : 0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: _GamePanel(
            padding: const EdgeInsets.all(12),
            highlight: true,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _BattleEffectPainter(
                        progress: _controller.value,
                        monsterKey: encounter.monster.monsterKey,
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(-shake * 0.6, 0),
                      child: SizedBox(
                        width: 76,
                        height: 96,
                        child: MonsterPortrait(
                          monsterKey: encounter.monster.monsterKey,
                          monsterName: encounter.monster.name,
                          pulse: _controller.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LiveBattleInfo(
                        encounter: encounter,
                        pulse: _controller.value,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveBattleInfo extends StatelessWidget {
  const _LiveBattleInfo({
    required this.encounter,
    required this.pulse,
  });

  final MoonlitActiveEncounter encounter;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '遭遇 ${encounter.monster.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _MoonlitColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${encounter.playerPower} / ${encounter.monsterThreat}',
              style: const TextStyle(
                color: _MoonlitColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${encounter.resultLabel} · 胜率 ${encounter.winPercent}%',
          style: const TextStyle(
            color: _MoonlitColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _BattleHpRow(
          label: '希尔薇娅',
          value: encounter.playerHpRatio,
          color: _MoonlitColors.green,
          pulse: pulse,
        ),
        const SizedBox(height: 6),
        _BattleHpRow(
          label: encounter.monster.name,
          value: encounter.monsterHpRatio,
          color: _MoonlitColors.red,
          pulse: (pulse + 0.5) % 1,
        ),
        if (encounter.monster.battleText.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            encounter.monster.battleText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MoonlitColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _BattleEffectPainter extends CustomPainter {
  const _BattleEffectPainter({
    required this.progress,
    required this.monsterKey,
  });

  final double progress;
  final String monsterKey;

  @override
  void paint(Canvas canvas, Size size) {
    final Color accent = _accentFor(monsterKey);
    final double slashPhase = (progress * 2) % 1;
    final double slashAlpha = (1 - slashPhase).clamp(0, 1).toDouble();
    final Paint slashPaint = Paint()
      ..color = _MoonlitColors.gold.withValues(alpha: slashAlpha * 0.50)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final double slashX = size.width * (0.24 + slashPhase * 0.56);
    canvas.drawLine(
      Offset(slashX - size.width * 0.13, size.height * 0.20),
      Offset(slashX + size.width * 0.07, size.height * 0.70),
      slashPaint,
    );

    final Paint sparkPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 9; i++) {
      final double seed = i * 0.137;
      final double t = (progress + seed) % 1;
      final double x = size.width * (0.18 + ((seed * 7) % 0.70));
      final double y = size.height * (0.72 - t * 0.56);
      final double radius = 1.3 + (1 - t) * 2.4;
      sparkPaint.color = accent.withValues(alpha: (1 - t) * 0.30);
      canvas.drawCircle(Offset(x, y), radius, sparkPaint);
    }

    final Paint pulsePaint = Paint()
      ..color = accent.withValues(
        alpha: math.sin(progress * math.pi).abs() * 0.14,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(8),
      ),
      pulsePaint,
    );
  }

  Color _accentFor(String key) {
    switch (key) {
      case 'black_forest_wolf':
        return const Color(0xff7fa36e);
      case 'mist_parasite':
        return const Color(0xff9bb8b5);
      case 'old_road_soldier':
      case 'maclay_guard_echo':
        return const Color(0xffc29a65);
      case 'blood_contract_echo':
        return const Color(0xffd64a3d);
      case 'atlas_whisper':
        return const Color(0xff9e7bff);
      default:
        return const Color(0xffffd27d);
    }
  }

  @override
  bool shouldRepaint(covariant _BattleEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.monsterKey != monsterKey;
  }
}

class MonsterPortrait extends StatelessWidget {
  const MonsterPortrait({
    required this.monsterKey,
    required this.monsterName,
    this.compact = false,
    this.pulse = 0,
    super.key,
  });

  final String monsterKey;
  final String monsterName;
  final bool compact;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final double glow = compact ? 0 : math.sin(pulse * math.pi).abs() * 0.30;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(
              const Color(0xff3b252a),
              const Color(0xff5a2c30),
              glow,
            )!,
            const Color(0xff17151b),
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 999 : 8),
        border: Border.all(
          color: compact ? _MoonlitColors.red : _MoonlitColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 999 : 8),
        child: CustomPaint(
          painter: _MonsterPortraitPainter(monsterKey, pulse: pulse),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, compact ? 3 : 6),
              child: Text(
                compact ? '!' : monsterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _MoonlitColors.text,
                  fontSize: compact ? 11 : 10,
                  fontWeight: FontWeight.w800,
                  shadows: const <Shadow>[
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonsterPortraitPainter extends CustomPainter {
  const _MonsterPortraitPainter(this.monsterKey, {required this.pulse});

  final String monsterKey;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint mist = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.25),
        radius: 0.76,
        colors: <Color>[
          _accent.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, mist);

    final Paint glow = Paint()
      ..color = _accent.withValues(
        alpha: 0.22 + math.sin(pulse * math.pi).abs() * 0.12,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.50),
        width: size.width * 0.72,
        height: size.height * 0.62,
      ),
      glow,
    );

    switch (monsterKey) {
      case 'black_forest_wolf':
        _paintWolf(canvas, size);
      case 'mist_parasite':
        _paintParasite(canvas, size);
      case 'old_road_soldier':
      case 'maclay_guard_echo':
        _paintSoldier(canvas, size);
      case 'blood_contract_echo':
        _paintBloodEcho(canvas, size);
      case 'atlas_whisper':
        _paintAtlas(canvas, size);
      case 'rift_wanderer':
      default:
        _paintWanderer(canvas, size);
    }

    final Paint floor = Paint()..color = Colors.black.withValues(alpha: 0.40);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.82),
        width: size.width * 0.66,
        height: size.height * 0.11,
      ),
      floor,
    );
  }

  Color get _accent {
    switch (monsterKey) {
      case 'black_forest_wolf':
        return const Color(0xff7fa36e);
      case 'mist_parasite':
        return const Color(0xff9bb8b5);
      case 'old_road_soldier':
      case 'maclay_guard_echo':
        return const Color(0xffc29a65);
      case 'blood_contract_echo':
        return const Color(0xffd64a3d);
      case 'atlas_whisper':
        return const Color(0xff9e7bff);
      default:
        return const Color(0xffffd27d);
    }
  }

  Paint get _bodyPaint => Paint()..color = const Color(0xff130e12);

  Paint get _edgePaint => Paint()
    ..color = _accent.withValues(alpha: 0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  void _paintWanderer(Canvas canvas, Size size) {
    final Path body = Path()
      ..moveTo(size.width * 0.35, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.45,
        size.width * 0.45,
        size.height * 0.26,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.36,
        size.width * 0.62,
        size.height * 0.78,
      )
      ..close();
    canvas.drawPath(body, _bodyPaint);
    canvas.drawPath(body, _edgePaint);
    _drawEye(canvas, size, const Offset(0.48, 0.42));
    _drawSlash(
      canvas,
      size,
      const Offset(0.38, 0.33),
      const Offset(0.68, 0.50),
    );
  }

  void _paintWolf(Canvas canvas, Size size) {
    final Path body = Path()
      ..moveTo(size.width * 0.18, size.height * 0.68)
      ..lineTo(size.width * 0.34, size.height * 0.43)
      ..lineTo(size.width * 0.44, size.height * 0.24)
      ..lineTo(size.width * 0.50, size.height * 0.42)
      ..lineTo(size.width * 0.73, size.height * 0.50)
      ..lineTo(size.width * 0.59, size.height * 0.58)
      ..lineTo(size.width * 0.66, size.height * 0.78)
      ..lineTo(size.width * 0.39, size.height * 0.69)
      ..close();
    canvas.drawPath(body, _bodyPaint);
    canvas.drawPath(body, _edgePaint);
    _drawEye(canvas, size, const Offset(0.53, 0.46));
  }

  void _paintParasite(Canvas canvas, Size size) {
    final Paint body = _bodyPaint;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.48),
        width: size.width * 0.34,
        height: size.height * 0.42,
      ),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.48),
        width: size.width * 0.34,
        height: size.height * 0.42,
      ),
      _edgePaint,
    );
    for (final double x in <double>[0.30, 0.40, 0.60, 0.70]) {
      _drawTentacle(canvas, size, x);
    }
    _drawEye(canvas, size, const Offset(0.50, 0.43));
  }

  void _paintSoldier(Canvas canvas, Size size) {
    final Path helm = Path()
      ..moveTo(size.width * 0.32, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.18,
        size.width * 0.68,
        size.height * 0.42,
      )
      ..lineTo(size.width * 0.62, size.height * 0.68)
      ..lineTo(size.width * 0.38, size.height * 0.68)
      ..close();
    canvas.drawPath(helm, _bodyPaint);
    canvas.drawPath(helm, _edgePaint);
    _drawSlash(
      canvas,
      size,
      const Offset(0.36, 0.49),
      const Offset(0.64, 0.49),
    );
    _drawEye(canvas, size, const Offset(0.44, 0.47));
    _drawEye(canvas, size, const Offset(0.56, 0.47));
  }

  void _paintBloodEcho(Canvas canvas, Size size) {
    final Path body = Path()
      ..moveTo(size.width * 0.50, size.height * 0.20)
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.44,
        size.width * 0.67,
        size.height * 0.75,
        size.width * 0.50,
        size.height * 0.80,
      )
      ..cubicTo(
        size.width * 0.33,
        size.height * 0.75,
        size.width * 0.24,
        size.height * 0.44,
        size.width * 0.50,
        size.height * 0.20,
      );
    canvas.drawPath(body, _bodyPaint);
    canvas.drawPath(body, _edgePaint);
    _drawEye(canvas, size, const Offset(0.50, 0.47));
    _drawSlash(
      canvas,
      size,
      const Offset(0.38, 0.60),
      const Offset(0.62, 0.60),
    );
  }

  void _paintAtlas(Canvas canvas, Size size) {
    final Path crown = Path()
      ..moveTo(size.width * 0.25, size.height * 0.60)
      ..lineTo(size.width * 0.32, size.height * 0.28)
      ..lineTo(size.width * 0.44, size.height * 0.48)
      ..lineTo(size.width * 0.50, size.height * 0.22)
      ..lineTo(size.width * 0.56, size.height * 0.48)
      ..lineTo(size.width * 0.68, size.height * 0.28)
      ..lineTo(size.width * 0.75, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.78,
        size.width * 0.25,
        size.height * 0.60,
      );
    canvas.drawPath(crown, _bodyPaint);
    canvas.drawPath(crown, _edgePaint);
    _drawEye(canvas, size, const Offset(0.50, 0.56));
  }

  void _drawEye(Canvas canvas, Size size, Offset ratio) {
    canvas.drawCircle(
      Offset(size.width * ratio.dx, size.height * ratio.dy),
      size.shortestSide * 0.035,
      Paint()..color = _accent,
    );
  }

  void _drawSlash(Canvas canvas, Size size, Offset a, Offset b) {
    canvas.drawLine(
      Offset(size.width * a.dx, size.height * a.dy),
      Offset(size.width * b.dx, size.height * b.dy),
      Paint()
        ..color = _accent.withValues(alpha: 0.82)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTentacle(Canvas canvas, Size size, double x) {
    final Path path = Path()
      ..moveTo(size.width * 0.50, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * x,
        size.height * 0.75,
        size.width * (x - 0.06),
        size.height * 0.86,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xff130e12)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _accent.withValues(alpha: 0.65)
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MonsterPortraitPainter oldDelegate) {
    return oldDelegate.monsterKey != monsterKey || oldDelegate.pulse != pulse;
  }
}

class _BattleHpRow extends StatelessWidget {
  const _BattleHpRow({
    required this.label,
    required this.value,
    required this.color,
    this.pulse = 0,
  });

  final String label;
  final double value;
  final Color color;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 58,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MoonlitColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 8,
            child: CustomPaint(
              painter: _BattleHpPainter(
                value: value,
                color: color,
                pulse: pulse,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BattleHpPainter extends CustomPainter {
  const _BattleHpPainter({
    required this.value,
    required this.color,
    required this.pulse,
  });

  final double value;
  final Color color;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect bg = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(999),
    );
    canvas.drawRRect(
      bg,
      Paint()..color = const Color(0xff332934),
    );

    final double width = size.width * value.clamp(0, 1);
    if (width <= 0) {
      return;
    }

    final RRect fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, size.height),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      fill,
      Paint()..color = color,
    );

    final double sheenWidth = math.min(size.width * 0.26, 54);
    final double sheenX = (size.width + sheenWidth) * pulse - sheenWidth;
    final Rect sheenRect = Rect.fromLTWH(
      sheenX,
      0,
      sheenWidth,
      size.height,
    ).intersect(Rect.fromLTWH(0, 0, width, size.height));
    if (!sheenRect.isEmpty) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(sheenRect, const Radius.circular(999)),
        Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: 0.36),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(sheenRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BattleHpPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.pulse != pulse;
  }
}

class IdleInteractionHint extends StatelessWidget {
  const IdleInteractionHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GamePanel(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          _GameIconSeal(icon: Icons.touch_app_outlined, active: true),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '点主角进行局外养成，点营地查看库存与线索，点地图地点派出探索。',
              style: TextStyle(color: _MoonlitColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.unlocked});

  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xcc211d23),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              unlocked ? Icons.lock_open : Icons.lock_outline,
              color: const Color(0xffffd27d),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              unlocked ? '遗址深入已出现' : '遗址深入未定位',
              style: const TextStyle(color: Color(0xffffe7bf), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class IdleRegionHeader extends StatelessWidget {
  const IdleRegionHeader({required this.state, super.key});

  final MoonlitIdleState state;

  @override
  Widget build(BuildContext context) {
    final MoonlitRegion? region =
        state.regions.isNotEmpty ? state.regions.first : null;
    final MoonlitStage? nextStage = state.stageByKey('maclay_ruins_deep');

    return _GamePanel(
      highlight: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _GameIconSeal(
            icon: nextStage?.unlocked == true
                ? Icons.lock_open
                : Icons.lock_outline,
            active: nextStage?.unlocked == true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  region?.name ?? '南境裂谷与暮色镇',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _MoonlitColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  region?.description ?? '暮色镇周边探索已开放。',
                  style: const TextStyle(color: _MoonlitColors.muted),
                ),
                const SizedBox(height: 10),
                Text(
                  nextStage?.unlocked == true
                      ? '玛克莱遗址深入已常驻解锁，进入时需要线索门票。'
                      : '收集全部线索后，玛克莱遗址深入会常驻出现在区域中。',
                  style: const TextStyle(
                    color: _MoonlitColors.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IdleActiveExpeditionPanel extends StatelessWidget {
  const IdleActiveExpeditionPanel({
    required this.expedition,
    required this.busy,
    required this.onClaim,
    super.key,
  });

  final MoonlitExpedition? expedition;
  final bool busy;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    if (expedition == null) {
      return const _GamePanel(
        child: Row(
          children: <Widget>[
            _GameIconSeal(icon: Icons.nights_stay_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '远征队正在营地待命。',
                style: TextStyle(color: _MoonlitColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    final bool ready = expedition!.liveCanClaim;

    return _GamePanel(
      highlight: ready,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _GameIconSeal(
                icon: ready ? Icons.inventory_outlined : Icons.explore_outlined,
                active: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  expedition!.routeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _MoonlitColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xff332934),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _MoonlitColors.border),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    ready
                        ? '可领取'
                        : formatSeconds(expedition!.liveRemainingSeconds),
                    style: const TextStyle(
                      color: _MoonlitColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: expedition!.currentProgress,
              minHeight: 9,
              backgroundColor: const Color(0xff332934),
              color: ready ? _MoonlitColors.gold : _MoonlitColors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            expedition!.resultContent,
            style: const TextStyle(color: _MoonlitColors.muted),
          ),
          if (ready) ...<Widget>[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: busy ? null : onClaim,
                icon: const Icon(Icons.inventory_outlined),
                label: const Text('领取战利品'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class IdleBattleReportSheet extends StatelessWidget {
  const IdleBattleReportSheet({
    required this.result,
    super.key,
  });

  final MoonlitClaimResult result;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          shrinkWrap: true,
          children: <Widget>[
            Row(
              children: <Widget>[
                const _GameIconSeal(
                  icon: Icons.assignment_outlined,
                  active: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.resultTitle.isEmpty ? '远征战报' : result.resultTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _MoonlitColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: '关闭',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: _MoonlitColors.gold,
                  ),
                ),
              ],
            ),
            if (result.resultContent.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                result.resultContent,
                style: const TextStyle(color: _MoonlitColors.muted),
              ),
            ],
            const SizedBox(height: 14),
            _GamePanel(
              padding: const EdgeInsets.all(12),
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const IdleSectionTitle(
                    icon: Icons.inventory_2_outlined,
                    title: '本次收获',
                    subtitle: '战斗表现会影响最终掉落数量',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result.rewards.isEmpty
                        ? const <Widget>[
                            _GameResourceChip(label: '没有获得资源', enough: false),
                          ]
                        : result.rewards
                            .map(
                              (MoonlitClaimReward reward) => _GameResourceChip(
                                label: '${reward.name} +${reward.amount}',
                                enough: true,
                              ),
                            )
                            .toList(),
                  ),
                  if (result.rewardFactor > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      '收益倍率 x${result.rewardFactor.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _MoonlitColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            const IdleSectionTitle(
              icon: Icons.local_fire_department_outlined,
              title: '遭遇记录',
              subtitle: '怪物越强，越能检验当前局外养成强度',
            ),
            const SizedBox(height: 8),
            if (result.battleLogs.isEmpty)
              const _GamePanel(
                padding: EdgeInsets.all(12),
                child: Text(
                  '这次探索没有遭遇魔物。',
                  style: TextStyle(color: _MoonlitColors.muted),
                ),
              )
            else
              for (final MoonlitBattleLog log in result.battleLogs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BattleLogTile(log: log),
                ),
          ],
        ),
      ),
    );
  }
}

class _BattleLogTile extends StatelessWidget {
  const _BattleLogTile({required this.log});

  final MoonlitBattleLog log;

  @override
  Widget build(BuildContext context) {
    return _GamePanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 54,
                height: 70,
                child: MonsterPortrait(
                  monsterKey: log.monsterKey,
                  monsterName: log.monsterName,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${log.encounterIndex}. ${log.monsterName}',
                      style: const TextStyle(
                        color: _MoonlitColors.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${log.resultLabel} · 胜率 ${log.winPercent}%',
                      style: const TextStyle(
                        color: _MoonlitColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${log.playerPower} / ${log.monsterThreat}',
                style: const TextStyle(
                  color: _MoonlitColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            log.logText,
            style: const TextStyle(color: _MoonlitColors.muted),
          ),
        ],
      ),
    );
  }
}

class IdleRouteTile extends StatelessWidget {
  const IdleRouteTile({
    required this.route,
    required this.disabled,
    required this.onStart,
    super.key,
  });

  final MoonlitRoute route;
  final bool disabled;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final Widget info = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _GameIconSeal(icon: Icons.flag_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                route.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _MoonlitColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                route.description,
                style: const TextStyle(color: _MoonlitColors.muted),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.hourglass_bottom,
                    color: _MoonlitColors.gold,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    formatSeconds(route.durationSeconds),
                    style: const TextStyle(
                      color: _MoonlitColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final Widget button = SizedBox(
      width: 96,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: disabled ? null : onStart,
        child: const Text(
          '出发',
          softWrap: false,
        ),
      ),
    );

    return _GamePanel(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                info,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: button),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: info),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class IdleUnlockProgressTile extends StatelessWidget {
  const IdleUnlockProgressTile({required this.item, super.key});

  final MoonlitUnlockRequirement item;

  @override
  Widget build(BuildContext context) {
    final double value =
        item.requiredTotal == 0 ? 1 : item.totalEarned / item.requiredTotal;
    final double clamped = value.clamp(0, 1).toDouble();

    return _GamePanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _GameIconSeal(icon: Icons.manage_search, active: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: _MoonlitColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${item.totalEarned} / ${item.requiredTotal}',
                style: const TextStyle(
                  color: _MoonlitColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: const Color(0xff332934),
              color: _MoonlitColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class IdleTicketPanel extends StatelessWidget {
  const IdleTicketPanel({required this.tickets, super.key});

  final List<MoonlitStageTicket> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const SizedBox.shrink();
    }

    return _GamePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _GameIconSeal(icon: Icons.key_outlined),
              const SizedBox(width: 10),
              Text(
                '玛克莱遗址深入门票',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _MoonlitColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tickets.map((MoonlitStageTicket ticket) {
              final bool enough = ticket.currentAmount >= ticket.amount;
              return _GameResourceChip(
                enough: enough,
                label:
                    '${ticket.name} ${ticket.currentAmount}/${ticket.amount}',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class IdleUpgradeTile extends StatelessWidget {
  const IdleUpgradeTile({
    required this.upgrade,
    required this.costs,
    required this.resources,
    required this.busy,
    required this.onUpgrade,
    super.key,
  });

  final MoonlitUpgrade upgrade;
  final List<MoonlitUpgradeCost> costs;
  final Map<String, MoonlitResource> resources;
  final bool busy;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final bool maxed = upgrade.level >= upgrade.maxLevel;
    final bool enough = costs.every((MoonlitUpgradeCost cost) {
      return (resources[cost.resourceKey]?.amount ?? 0) >= cost.amount;
    });

    return _GamePanel(
      highlight: enough && !maxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _GameIconSeal(icon: _upgradeIcon(upgrade.upgradeKey)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      upgrade.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _MoonlitColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lv.${upgrade.level} / ${upgrade.maxLevel}',
                      style: const TextStyle(
                        color: _MoonlitColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 96,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: busy || maxed || !enough ? null : onUpgrade,
                  child: Text(
                    maxed ? '满级' : '强化',
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            upgrade.effectDesc,
            style: const TextStyle(color: _MoonlitColors.muted),
          ),
          if (costs.isNotEmpty && !maxed) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: costs.map((MoonlitUpgradeCost cost) {
                final MoonlitResource? resource = resources[cost.resourceKey];
                final int amount = resource?.amount ?? 0;
                return _GameResourceChip(
                  enough: amount >= cost.amount,
                  label: '${cost.name} $amount/${cost.amount}',
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  IconData _upgradeIcon(String key) {
    switch (key) {
      case 'twilight_guild':
        return Icons.account_balance_outlined;
      case 'maclay_archive':
        return Icons.menu_book_outlined;
      case 'shia_combat':
        return Icons.local_fire_department_outlined;
      case 'blood_contract_control':
        return Icons.bloodtype_outlined;
      case 'magie_echo':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.upgrade_outlined;
    }
  }
}

class IdleResourceGrid extends StatelessWidget {
  const IdleResourceGrid({required this.resources, super.key});

  final List<MoonlitResource> resources;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth > 760 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.85,
          ),
          itemCount: resources.length,
          itemBuilder: (BuildContext context, int index) {
            final MoonlitResource item = resources[index];
            return _GamePanel(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: <Widget>[
                  _GameIconSeal(icon: _resourceIcon(item.resourceKey)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _MoonlitColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.amount} / ${item.totalEarned}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _MoonlitColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _resourceIcon(String key) {
    switch (key) {
      case 'gold':
        return Icons.monetization_on_outlined;
      case 'twilight_reputation':
        return Icons.shield_moon_outlined;
      case 'twilight_intel':
        return Icons.search_outlined;
      case 'maclay_mark':
        return Icons.key_outlined;
      case 'old_empire_fragment':
        return Icons.account_balance_outlined;
      case 'blood_trace_shard':
        return Icons.bloodtype_outlined;
      case 'blood_mist_sample':
        return Icons.water_drop_outlined;
      case 'atlas_echo':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

class IdleSectionTitle extends StatelessWidget {
  const IdleSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: _MoonlitColors.gold, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
        child: Row(
          children: <Widget>[
            Icon(icon, color: _MoonlitColors.gold, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _MoonlitColors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _MoonlitColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IdleErrorView extends StatelessWidget {
  const IdleErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _MoonlitColors.panelDeep),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _GamePanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _GameIconSeal(icon: Icons.cloud_off, active: true),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _MoonlitColors.muted),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

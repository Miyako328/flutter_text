import 'dart:math' as math;

import 'package:flutter/material.dart';

class ImplicitAnimationsPage extends StatefulWidget {
  const ImplicitAnimationsPage({Key? key}) : super(key: key);

  @override
  State<ImplicitAnimationsPage> createState() => _ImplicitAnimationsPageState();
}

class _ImplicitAnimationsPageState extends State<ImplicitAnimationsPage> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Implicit Animations')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          _DemoHeader(
            title: '隐式动画合集',
            subtitle: '点击右上角按钮切换状态，观察常用 Animated* 组件的变化。',
            trailing: Switch(
              value: _active,
              onChanged: (bool value) {
                setState(() {
                  _active = value;
                });
              },
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _DemoCard(
                title: 'AnimatedOpacity',
                child: AnimatedOpacity(
                  opacity: _active ? 1 : 0.32,
                  duration: const Duration(milliseconds: 420),
                  child: const _ColorBlock(
                    color: Color(0xFF2563EB),
                    icon: Icons.visibility_rounded,
                  ),
                ),
              ),
              _DemoCard(
                title: 'AnimatedScale',
                child: AnimatedScale(
                  scale: _active ? 1.18 : 0.78,
                  curve: Curves.easeOutBack,
                  duration: const Duration(milliseconds: 420),
                  child: const _ColorBlock(
                    color: Color(0xFF0F766E),
                    icon: Icons.zoom_out_map_rounded,
                  ),
                ),
              ),
              _DemoCard(
                title: 'AnimatedRotation',
                child: AnimatedRotation(
                  turns: _active ? 0.12 : -0.08,
                  curve: Curves.easeOutCubic,
                  duration: const Duration(milliseconds: 420),
                  child: const _ColorBlock(
                    color: Color(0xFF9333EA),
                    icon: Icons.refresh_rounded,
                  ),
                ),
              ),
              _DemoCard(
                title: 'AnimatedAlign',
                child: Container(
                  width: 150,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedAlign(
                    alignment:
                        _active ? Alignment.centerRight : Alignment.centerLeft,
                    curve: Curves.easeOutCubic,
                    duration: const Duration(milliseconds: 420),
                    child: const _MiniDot(),
                  ),
                ),
              ),
              _DemoCard(
                title: 'AnimatedSwitcher',
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    _active
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    key: ValueKey<bool>(_active),
                    size: 64,
                    color: _active
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ),
              _DemoCard(
                title: 'TweenAnimationBuilder',
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _active ? 0.82 : 0.36),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  builder: (
                    BuildContext context,
                    double value,
                    Widget? child,
                  ) {
                    return SizedBox(
                      width: 86,
                      height: 86,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF2563EB),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _active = !_active;
          });
        },
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('切换'),
      ),
    );
  }
}

class _DemoHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _DemoHeader({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DemoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 170,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              child,
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorBlock extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _ColorBlock({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }
}

class _MiniDot extends StatelessWidget {
  const _MiniDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Transform.rotate(
        angle: math.pi / 4,
        child: const Icon(Icons.navigation_rounded, color: Colors.white),
      ),
    );
  }
}

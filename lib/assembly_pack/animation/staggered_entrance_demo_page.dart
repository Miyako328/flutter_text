import 'package:flutter/material.dart';

class StaggeredEntranceDemoPage extends StatefulWidget {
  const StaggeredEntranceDemoPage({Key? key}) : super(key: key);

  @override
  State<StaggeredEntranceDemoPage> createState() =>
      _StaggeredEntranceDemoPageState();
}

class _StaggeredEntranceDemoPageState extends State<StaggeredEntranceDemoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered Entrance')),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 1.35,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          final double start = index * 0.045;
          final double end = (start + 0.42).clamp(0.0, 1.0);
          final Animation<double> animation = CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 26 * (1 - animation.value)),
                  child: child,
                ),
              );
            },
            child: _EntranceCard(index: index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _controller
            ..reset()
            ..forward();
        },
        icon: const Icon(Icons.replay_rounded),
        label: const Text('重播'),
      ),
    );
  }
}

class _EntranceCard extends StatelessWidget {
  final int index;

  const _EntranceCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final Color color = <Color>[
      const Color(0xFF2563EB),
      const Color(0xFF0F766E),
      const Color(0xFF9333EA),
      const Color(0xFFEA580C),
    ][index % 4];

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

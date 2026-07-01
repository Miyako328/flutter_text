import 'package:flutter/material.dart';

class HeroTransitionPage extends StatelessWidget {
  const HeroTransitionPage({Key? key}) : super(key: key);

  static const List<Color> _colors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF0F766E),
    Color(0xFF9333EA),
    Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Transition')),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: _colors.length,
        itemBuilder: (BuildContext context, int index) {
          final String tag = 'hero-demo-$index';
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return _HeroDetailPage(
                      tag: tag,
                      color: _colors[index],
                      index: index,
                    );
                  },
                ),
              );
            },
            child: Hero(
              tag: tag,
              child: _HeroTile(color: _colors[index], index: index),
            ),
          );
        },
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final Color color;
  final int index;

  const _HeroTile({
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 46 + index * 4,
        ),
      ),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  final String tag;
  final Color color;
  final int index;

  const _HeroDetailPage({
    required this.tag,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hero Item ${index + 1}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: tag,
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: _HeroTile(color: color, index: index),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '共享元素转场',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '常用于图片列表进入详情页，让用户清楚知道当前页面和上一个页面的元素关系。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

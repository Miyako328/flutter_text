import 'package:flutter/material.dart';

class ShimmerLoadingDemoPage extends StatefulWidget {
  const ShimmerLoadingDemoPage({Key? key}) : super(key: key);

  @override
  State<ShimmerLoadingDemoPage> createState() => _ShimmerLoadingDemoPageState();
}

class _ShimmerLoadingDemoPageState extends State<ShimmerLoadingDemoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shimmer Loading')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '骨架屏适合接口加载、图片加载和首屏占位。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ),
              Switch(
                value: _loading,
                onChanged: (bool value) {
                  setState(() {
                    _loading = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _loading
                ? Column(
                    key: const ValueKey<String>('skeleton'),
                    children: List<Widget>.generate(
                      4,
                      (int index) => _SkeletonCard(controller: _controller),
                    ),
                  )
                : Column(
                    key: const ValueKey<String>('content'),
                    children: List<Widget>.generate(
                      4,
                      (int index) => _ContentCard(index: index),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Animation<double> controller;

  const _SkeletonCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      animation: controller,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: <Widget>[
            _SkeletonBox(width: 58, height: 58),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SkeletonBox(width: double.infinity, height: 16),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 180, height: 12),
                  SizedBox(height: 10),
                  _SkeletonBox(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _Shimmer({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const <Color>[
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: const <double>[0.18, 0.5, 0.82],
              transform: _SlidingGradientTransform(animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double percent;

  const _SlidingGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (percent * 2 - 1), 0, 0);
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBox({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final int index;

  const _ContentCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text('加载完成的内容 ${index + 1}'),
        subtitle: const Text('骨架屏切换到真实内容'),
      ),
    );
  }
}

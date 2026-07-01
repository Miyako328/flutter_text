import 'package:flutter/material.dart';

class RouteTransitionDemoPage extends StatelessWidget {
  const RouteTransitionDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Transition')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          _RouteButton(
            title: '淡入',
            icon: Icons.opacity_rounded,
            routeBuilder: (Widget page) => PageRouteBuilder<void>(
              pageBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return page;
              },
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          _RouteButton(
            title: '右侧滑入',
            icon: Icons.arrow_forward_rounded,
            routeBuilder: (Widget page) => PageRouteBuilder<void>(
              pageBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return page;
              },
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                final Animation<Offset> offset = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic),
                );
                return SlideTransition(position: offset, child: child);
              },
            ),
          ),
          _RouteButton(
            title: '缩放弹出',
            icon: Icons.open_in_full_rounded,
            routeBuilder: (Widget page) => PageRouteBuilder<void>(
              opaque: false,
              barrierColor: Colors.black.withValues(alpha: 0.28),
              pageBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) {
                return page;
              },
              transitionsBuilder: (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child,
              ) {
                final Animation<double> curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                );
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: curved, child: child),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final PageRoute<void> Function(Widget page) routeBuilder;

  const _RouteButton({
    required this.title,
    required this.icon,
    required this.routeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2563EB)),
          title: Text(title),
          subtitle: const Text('点击查看自定义 PageRouteBuilder 转场'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            Navigator.of(context).push<void>(
              routeBuilder(_RoutePreviewPage(title: title)),
            );
          },
        ),
      ),
    );
  }
}

class _RoutePreviewPage extends StatelessWidget {
  final String title;

  const _RoutePreviewPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.route_rounded,
                size: 54,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                '这里可以替换成业务详情页、弹窗页或引导页。',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

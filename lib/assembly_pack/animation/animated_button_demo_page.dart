import 'package:flutter/material.dart';

class AnimatedButtonDemoPage extends StatefulWidget {
  const AnimatedButtonDemoPage({Key? key}) : super(key: key);

  @override
  State<AnimatedButtonDemoPage> createState() => _AnimatedButtonDemoPageState();
}

class _AnimatedButtonDemoPageState extends State<AnimatedButtonDemoPage> {
  bool _liked = false;
  bool _loading = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Buttons')),
      body: Center(
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _ActionPanel(
              title: '点赞按钮',
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                  });
                },
                child: AnimatedScale(
                  scale: _liked ? 1.18 : 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: _liked
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _liked
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B),
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            _ActionPanel(
              title: '加载按钮',
              child: SizedBox(
                width: 190,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _startLoading,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _loading
                        ? const SizedBox(
                            key: ValueKey<String>('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _done ? '已完成' : '提交',
                            key: ValueKey<bool>(_done),
                          ),
                  ),
                ),
              ),
            ),
            _ActionPanel(
              title: '成功状态',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: _done ? 118 : 82,
                height: 82,
                decoration: BoxDecoration(
                  color:
                      _done ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _done
                      ? const Row(
                          key: ValueKey<String>('done'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.check_rounded,
                              color: Color(0xFF16A34A),
                            ),
                            SizedBox(width: 6),
                            Text('Done'),
                          ],
                        )
                      : const Icon(
                          key: ValueKey<String>('idle'),
                          Icons.touch_app_rounded,
                          color: Color(0xFF2563EB),
                          size: 38,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startLoading() async {
    setState(() {
      _loading = true;
      _done = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _done = true;
    });
  }
}

class _ActionPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _ActionPanel({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

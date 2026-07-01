import 'package:flutter/material.dart';

class ExpandCollapseDemoPage extends StatefulWidget {
  const ExpandCollapseDemoPage({Key? key}) : super(key: key);

  @override
  State<ExpandCollapseDemoPage> createState() => _ExpandCollapseDemoPageState();
}

class _ExpandCollapseDemoPageState extends State<ExpandCollapseDemoPage>
    with TickerProviderStateMixin {
  final List<bool> _expanded = <bool>[true, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expand Collapse')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: <Widget>[
          Text(
            '常用于 FAQ、筛选条件、详情区域展开。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 16),
          for (int index = 0; index < _expanded.length; index++)
            _ExpandableTile(
              title: '配置项 ${index + 1}',
              expanded: _expanded[index],
              onTap: () {
                setState(() {
                  _expanded[index] = !_expanded[index];
                });
              },
            ),
        ],
      ),
    );
  }
}

class _ExpandableTile extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandableTile({
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(title),
            subtitle: const Text('AnimatedSize + AnimatedRotation'),
            trailing: AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 240),
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            onTap: onTap,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '这里可以放表单、说明文字、筛选项或更多操作。收起时高度会自然动画到 0。',
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

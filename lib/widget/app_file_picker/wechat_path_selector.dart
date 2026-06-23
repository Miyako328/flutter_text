import 'package:flutter/material.dart';

import 'app_file_picker_models.dart';

class WechatPathSelector extends StatefulWidget {
  final List<AppPickerPath> paths;
  final AppPickerPath? currentPath;
  final ValueChanged<AppPickerPath> onPathChanged;
  final bool isExpanded;
  final bool isEnabled;

  const WechatPathSelector({
    required this.paths,
    required this.currentPath,
    required this.onPathChanged,
    super.key,
    this.isExpanded = false,
    this.isEnabled = true,
  });

  @override
  State<WechatPathSelector> createState() => _WechatPathSelectorState();
}

class _WechatPathSelectorState extends State<WechatPathSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.isExpanded ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant WechatPathSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded == oldWidget.isExpanded) {
      return;
    }
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paths.isEmpty) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _animation,
      child: _PathList(
        paths: widget.paths,
        currentPath: widget.currentPath,
        isEnabled: widget.isEnabled,
        onPathChanged: widget.onPathChanged,
      ),
      builder: (BuildContext context, Widget? child) {
        return ClipRect(
          child: Align(
            heightFactor: _animation.value,
            child: child,
          ),
        );
      },
    );
  }
}

class _PathList extends StatelessWidget {
  final List<AppPickerPath> paths;
  final AppPickerPath? currentPath;
  final bool isEnabled;
  final ValueChanged<AppPickerPath> onPathChanged;

  const _PathList({
    required this.paths,
    required this.currentPath,
    required this.isEnabled,
    required this.onPathChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: paths.length,
          itemBuilder: (BuildContext context, int index) {
            final AppPickerPath path = paths[index];
            return _PathTile(
              path: path,
              selected: currentPath?.id == path.id,
              enabled: isEnabled,
              onTap: () => onPathChanged(path),
            );
          },
        ),
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  final AppPickerPath path;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _PathTile({
    required this.path,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: path.thumbnailBytes == null
                        ? ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              path.fallbackIcon,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : Image.memory(
                            path.thumbnailBytes!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                path.fallbackIcon,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          path.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: enabled
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.48),
                          ),
                        ),
                      ),
                      if (path.count != null) ...<Widget>[
                        const SizedBox(width: 5),
                        Text(
                          '(${path.count})',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_rounded,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

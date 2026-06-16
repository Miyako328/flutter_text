import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/desktop_list/desktop_drop_text.dart';
import 'package:flutter_text/assembly_pack/desktop_list/desktop_notifier.dart';
import 'package:flutter_text/assembly_pack/desktop_list/desktop_picker.dart';
import 'package:flutter_text/assembly_pack/desktop_list/download.dart';
import 'package:flutter_text/assembly_pack/desktop_list/keyborard_listener.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/assembly_pack/mine_sweep/game_main.dart';
import 'package:flutter_text/assembly_pack/popup_text/popup_text.dart';
import 'package:flutter_text/assembly_pack/sudu/sudo_game.dart';
import 'package:flutter_text/assembly_pack/unit/Reorderable.dart';
import 'package:flutter_text/assembly_pack/unit/SelectText.dart';
import 'package:flutter_text/assembly_pack/unit/StepView.dart';
import 'package:flutter_text/assembly_pack/unit/auto_complete_test.dart';
import 'package:flutter_text/assembly_pack/unit/curve_animated/curve_animated.dart';
import 'package:flutter_text/assembly_pack/unit/overlay_text.dart';
import 'package:flutter_text/global/global.dart';

enum ComponentLibraryFilter {
  all,
  unit,
  desktop,
}

class ComponentLibraryPage extends StatefulWidget {
  final ComponentLibraryFilter initialFilter;

  const ComponentLibraryPage({
    Key? key,
    this.initialFilter = ComponentLibraryFilter.all,
  }) : super(key: key);

  @override
  State<ComponentLibraryPage> createState() => _ComponentLibraryPageState();
}

class _ComponentLibraryPageState extends State<ComponentLibraryPage> {
  late ComponentLibraryFilter _filter;
  late final List<_ComponentEntry> _entries;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _entries = _buildEntries();
  }

  List<_ComponentEntry> get _visibleEntries {
    if (_filter == ComponentLibraryFilter.all) {
      return _entries;
    }
    return _entries
        .where((_ComponentEntry entry) => entry.filter == _filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<_ComponentEntry> unitEntries = _visibleEntries
        .where((_ComponentEntry entry) =>
            entry.filter == ComponentLibraryFilter.unit)
        .toList();
    final List<_ComponentEntry> desktopEntries = _visibleEntries
        .where((_ComponentEntry entry) =>
            entry.filter == ComponentLibraryFilter.desktop)
        .toList();

    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('组件能力库'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
        children: <Widget>[
          _LibraryHeader(
            total: _entries.length,
            unitCount: _entries
                .where((_ComponentEntry entry) =>
                    entry.filter == ComponentLibraryFilter.unit)
                .length,
            desktopCount: _entries
                .where((_ComponentEntry entry) =>
                    entry.filter == ComponentLibraryFilter.desktop)
                .length,
          ),
          const SizedBox(height: 18),
          _FilterBar(
            value: _filter,
            onChanged: (ComponentLibraryFilter value) {
              setState(() {
                _filter = value;
              });
            },
          ),
          const SizedBox(height: 18),
          if (unitEntries.isNotEmpty)
            _ComponentSection(
              title: 'Unit 基础组件',
              description: '文本选择、排序、弹层、自动完成、动画和小游戏实验。',
              icon: Icons.widgets_outlined,
              entries: unitEntries,
            ),
          if (unitEntries.isNotEmpty && desktopEntries.isNotEmpty)
            const SizedBox(height: 18),
          if (desktopEntries.isNotEmpty)
            _ComponentSection(
              title: 'Desktop 桌面能力',
              description: '文件拖拽、本地通知、文件选择、下载和键盘监听。',
              icon: Icons.desktop_mac_outlined,
              entries: desktopEntries,
            ),
        ],
      ),
    );
  }

  List<_ComponentEntry> _buildEntries() {
    return <_ComponentEntry>[
      _ComponentEntry(
        title: 'SelectText',
        description: '可选择文本和富交互文本区域示例。',
        tags: <String>['Text', 'Selection'],
        icon: Icons.text_fields_outlined,
        page: SelectTextPage(),
        filter: ComponentLibraryFilter.unit,
      ),
      _ComponentEntry(
        title: 'Reorderable',
        description: '拖拽排序列表，适合整理可编辑条目。',
        tags: <String>['Drag', 'List'],
        icon: Icons.drag_indicator,
        page: ReorderablePage(),
        filter: ComponentLibraryFilter.unit,
      ),
      _ComponentEntry(
        title: 'Cupertino View',
        description: 'iOS 风格组件和页面结构示例。',
        tags: <String>['Cupertino', 'Platform'],
        icon: Icons.phone_iphone_outlined,
        page: CurpertinoViewPage(),
        filter: ComponentLibraryFilter.unit,
      ),
      _ComponentEntry(
        title: 'Curve Animated',
        description: '曲线动画和自定义绘制动效。',
        tags: <String>['Animation', 'Curve'],
        icon: Icons.auto_graph_outlined,
        page: CurveAnimatedPage(),
        filter: ComponentLibraryFilter.unit,
      ),
      _ComponentEntry(
        title: 'Sudo Game',
        description: '数独交互页面，适合观察复杂状态组织。',
        tags: <String>['Game', 'State'],
        icon: Icons.grid_4x4_outlined,
        page: SudoGamePage(),
        filter: ComponentLibraryFilter.unit,
      ),
      const _ComponentEntry(
        title: 'Overlay Text',
        description: 'Overlay 浮层文本和弹出层控制。',
        tags: <String>['Overlay', 'Popup'],
        icon: Icons.layers_outlined,
        page: OverlayText(),
        filter: ComponentLibraryFilter.unit,
      ),
      const _ComponentEntry(
        title: 'Auto Complete',
        description: '输入联想和自动补全交互。',
        tags: <String>['Input', 'Autocomplete'],
        icon: Icons.manage_search_outlined,
        page: AutoCompleteTest(),
        filter: ComponentLibraryFilter.unit,
      ),
      const _ComponentEntry(
        title: 'Mine Sweeping',
        description: '扫雷小游戏，包含网格交互和状态推导。',
        tags: <String>['Game', 'Grid'],
        icon: Icons.flag_outlined,
        page: MineSweeping(),
        filter: ComponentLibraryFilter.unit,
      ),
      _ComponentEntry(
        title: 'Popup Text',
        description: '文本弹出菜单和轻量提示交互。',
        tags: <String>['Popup', 'Text'],
        icon: Icons.chat_bubble_outline,
        page: PopupTextPage(),
        filter: ComponentLibraryFilter.unit,
      ),
      const _ComponentEntry(
        title: 'Desktop Drop',
        description: '桌面文件拖入 Flutter 窗口并读取路径。',
        tags: <String>['Desktop', 'Drag', 'File'],
        icon: Icons.file_download_outlined,
        page: DesktopDropText(),
        filter: ComponentLibraryFilter.desktop,
      ),
      const _ComponentEntry(
        title: 'Desktop Notifier',
        description: '桌面本地通知和系统消息提醒。',
        tags: <String>['Desktop', 'Notification'],
        icon: Icons.notifications_none_outlined,
        page: DesktopNotifierPage(),
        filter: ComponentLibraryFilter.desktop,
      ),
      const _ComponentEntry(
        title: 'Desktop Picker',
        description: '桌面文件选择器和本地文件访问。',
        tags: <String>['Desktop', 'Picker', 'File'],
        icon: Icons.folder_open_outlined,
        page: DesktopPickerPage(),
        filter: ComponentLibraryFilter.desktop,
      ),
      const _ComponentEntry(
        title: 'Download',
        description: '下载流程和桌面端文件保存能力。',
        tags: <String>['Desktop', 'Download'],
        icon: Icons.downloading_outlined,
        page: DownLoadPage(),
        filter: ComponentLibraryFilter.desktop,
      ),
      const _ComponentEntry(
        title: 'Keyboard Listener',
        description: '桌面键盘事件监听和快捷键输入。',
        tags: <String>['Desktop', 'Keyboard'],
        icon: Icons.keyboard_outlined,
        page: KeyBoardListenerPage(),
        filter: ComponentLibraryFilter.desktop,
      ),
    ];
  }
}

class _LibraryHeader extends StatelessWidget {
  final int total;
  final int unitCount;
  final int desktopCount;

  const _LibraryHeader({
    required this.total,
    required this.unitCount,
    required this.desktopCount,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 760;
        final List<Widget> metrics = <Widget>[
          _Metric(label: '全部', value: '$total'),
          const SizedBox(width: 10),
          _Metric(label: 'Unit', value: '$unitCount'),
          const SizedBox(width: 10),
          _Metric(label: 'Desktop', value: '$desktopCount'),
        ];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _HeaderIntro(colorScheme: colorScheme),
                      const SizedBox(height: 18),
                      Row(children: metrics),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      Expanded(
                        child: _HeaderIntro(colorScheme: colorScheme),
                      ),
                      const SizedBox(width: 16),
                      ...metrics,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _HeaderIntro extends StatelessWidget {
  final ColorScheme colorScheme;

  const _HeaderIntro({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.view_in_ar_outlined,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '组件能力库',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '把基础组件和桌面能力放在同一个工作台里，按用途查找，按条目进入示例。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ComponentLibraryFilter value;
  final ValueChanged<ComponentLibraryFilter> onChanged;

  const _FilterBar({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SegmentedButton<ComponentLibraryFilter>(
          segments: const <ButtonSegment<ComponentLibraryFilter>>[
            ButtonSegment<ComponentLibraryFilter>(
              value: ComponentLibraryFilter.all,
              icon: Icon(Icons.all_inbox_outlined),
              label: Text('全部'),
            ),
            ButtonSegment<ComponentLibraryFilter>(
              value: ComponentLibraryFilter.unit,
              icon: Icon(Icons.widgets_outlined),
              label: Text('Unit'),
            ),
            ButtonSegment<ComponentLibraryFilter>(
              value: ComponentLibraryFilter.desktop,
              icon: Icon(Icons.desktop_mac_outlined),
              label: Text('Desktop'),
            ),
          ],
          selected: <ComponentLibraryFilter>{value},
          onSelectionChanged: (Set<ComponentLibraryFilter> selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }
}

class _ComponentSection extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<_ComponentEntry> entries;

  const _ComponentSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: <Widget>[
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text('${entries.length} 项'),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          ...entries.map(
            (_ComponentEntry entry) => _ComponentRow(entry: entry),
          ),
        ],
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  final _ComponentEntry entry;

  const _ComponentRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        WindowsNavigator().pushWidget(
          context,
          entry.page,
          title: entry.title,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(entry.icon, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 6,
              children: entry.tags.take(2).map((String tag) {
                return Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(tag),
                );
              }).toList(),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ComponentEntry {
  final String title;
  final String description;
  final List<String> tags;
  final IconData icon;
  final Widget page;
  final ComponentLibraryFilter filter;

  const _ComponentEntry({
    required this.title,
    required this.description,
    required this.tags,
    required this.icon,
    required this.page,
    required this.filter,
  });
}

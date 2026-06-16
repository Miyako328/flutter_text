import 'dart:convert';

import 'package:flutter_text/assembly_pack/management/function_page/windows_main_page.dart';
import 'package:flutter_text/assembly_pack/management/function_page/windows_setting.dart';
import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:flutter_text/assembly_pack/management/home_page/theme.dart';
import 'package:flutter_text/assembly_pack/management/home_page/tool.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/knowledge/knowledge_catalog.dart';
import 'package:flutter_text/models/main_widget_model.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';
import 'package:get/get.dart';
import 'package:self_utils/widget/management/common/view_key.dart';

import 'editor.dart';

class ManagementPage extends StatefulWidget {
  @override
  _ManagementPageState createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  final EditorController editorController = EditorController();

  @override
  void initState() {
    super.initState();
    WindowsNavigator.init(editorController);
    PostgresUser.init().then((void value) => _checkUser());
    Request.init();
    FileUtils();
    Log.init(isDebug: true);
  }

  void _checkUser() async {
    try {
      final String? res = LocateStorage.getString('user');
      if (res != null) {
        final User user = User.fromJson(jsonDecode(res));
        final User? result = await PostgresUser.checkUser(user);
        if (result != null) {
          GlobalStore.user = user;
          ToastUtils.showToast(msg: '自动登录MQTT成功');
          setState(() {});
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Tool(
                controller: editorController,
              ),
              Expanded(
                child: Editor(
                  controller: editorController,
                ),
              ),
            ],
          ),
          _CapsuleDock(controller: editorController),
        ],
      ),
    );
  }
}

class _CapsuleDock extends StatelessWidget {
  final EditorController controller;

  const _CapsuleDock({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController shellController) {
        final List<_DockEntry> entries = <_DockEntry>[
          _DockEntry(
            key: ContViewKey.mainPage,
            icon: Icons.home,
            label: '主页',
            onTap: () {
              shellController.activateDockPage(ContViewKey.mainPage);
              controller.tabs.clear();
              controller.open(
                key: ContViewKey.mainPage,
                tab: '主页',
                contentIfAbsent: (_) => const WindowsMainPage(),
              );
            },
          ),
          ...KnowledgeCatalog.sidebarItems.map(
            (MainWidgetModel item) => _DockEntry(
              key: ViewKey(
                namespace: item.hashCode.toString(),
                id: item.hashCode.toString(),
              ),
              icon: item.icon.icon ?? Icons.widgets_outlined,
              label: item.displayTitle,
              onTap: () {
                if (item.route != null) {
                  final ViewKey key = ViewKey(
                    namespace: item.hashCode.toString(),
                    id: item.hashCode.toString(),
                  );
                  shellController.activateDockPage(key);
                  controller.open(
                    key: key,
                    tab: item.displayTitle,
                    contentIfAbsent: (_) => item.route!,
                  );
                } else {
                  item.onTapFunc?.call(context);
                }
              },
            ),
          ),
          _DockEntry(
            key: ContViewKey.setting,
            icon: Icons.settings,
            label: '设置',
            onTap: () {
              shellController.activateDockPage(ContViewKey.setting);
              controller.open(
                key: ContViewKey.setting,
                tab: '设置',
                contentIfAbsent: (_) => const WindowsSettingPage(),
              );
            },
          ),
        ];

        final bool isBottom =
            shellController.dockPosition == DockPosition.bottom;
        return AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: isBottom ? Alignment.bottomCenter : Alignment.centerLeft,
          child: Padding(
            padding: isBottom
                ? const EdgeInsets.only(bottom: 18)
                : const EdgeInsets.only(left: 18),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: shellController.isDockVisible
                  ? MouseRegion(
                      key: const ValueKey<String>('dock'),
                      onEnter: (_) {
                        shellController.registerDockActivity();
                      },
                      child: _DockSurface(
                        entries: entries,
                        current: shellController.currentKey,
                        direction: isBottom ? Axis.horizontal : Axis.vertical,
                      ),
                    )
                  : _DockHandle(
                      key: const ValueKey<String>('dock-handle'),
                      direction: isBottom ? Axis.horizontal : Axis.vertical,
                      revealMode: shellController.dockRevealMode,
                      onReveal: shellController.revealDock,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _DockSurface extends StatelessWidget {
  final List<_DockEntry> entries;
  final ViewKey? current;
  final Axis direction;

  const _DockSurface({
    required this.entries,
    required this.current,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final Color dockColor = (GlobalStore.theme == 'light'
            ? HomeTheme.lightBgColor
            : HomeTheme.darkBgColor) ??
        Theme.of(context).colorScheme.surface;
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dockColor.withValues(alpha: 0.72),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.36),
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: direction == Axis.horizontal
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Flex(
            direction: direction,
            mainAxisSize: MainAxisSize.min,
            children: entries
                .map(
                  (_DockEntry entry) => Padding(
                    padding: direction == Axis.horizontal
                        ? const EdgeInsets.symmetric(horizontal: 3)
                        : const EdgeInsets.symmetric(vertical: 3),
                    child: Tooltip(
                      message: entry.label,
                      child: _DockButton(
                        icon: entry.icon,
                        selected: current == entry.key,
                        onTap: entry.onTap,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _DockHandle extends StatelessWidget {
  final Axis direction;
  final DockRevealMode revealMode;
  final VoidCallback onReveal;

  const _DockHandle({
    required this.direction,
    required this.revealMode,
    required this.onReveal,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHorizontal = direction == Axis.horizontal;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget handle = Tooltip(
      message: revealMode == DockRevealMode.hover ? '悬停展开 Dock' : '点击展开 Dock',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: revealMode == DockRevealMode.click ? onReveal : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.58),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.58),
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SizedBox(
              width: isHorizontal ? 76 : 28,
              height: isHorizontal ? 28 : 76,
              child: Icon(
                isHorizontal
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );

    if (revealMode == DockRevealMode.hover) {
      return MouseRegion(
        onEnter: (_) {
          onReveal();
        },
        child: handle,
      );
    }
    return handle;
  }
}

class _DockButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DockButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: selected ? 42 : 38,
        height: selected ? 42 : 38,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: selected ? 23 : 21,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}

class _DockEntry {
  final ViewKey key;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _DockEntry({
    required this.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

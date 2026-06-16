import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:get/get.dart';
import 'package:self_utils/init.dart';

import '../../../init.dart';

class WindowsSettingPage extends StatefulWidget {
  const WindowsSettingPage({Key? key}) : super(key: key);

  @override
  State<WindowsSettingPage> createState() => _WindowsSettingPageState();
}

class _WindowsSettingPageState extends State<WindowsSettingPage> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController shellController) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              shellController.dockPosition == DockPosition.side ? 104 : 36,
              44,
              36,
              shellController.dockPosition == DockPosition.bottom ? 118 : 44,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '设置',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '调整知识库的显示方式和基础偏好。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 28),
                    const _SettingSection(
                      title: 'Dock',
                      children: <Widget>[
                        _SettingTile(
                          icon: Icons.dock_outlined,
                          title: 'Dock 位置',
                          subtitle: '选择左侧胶囊栏或底部悬浮栏。',
                          trailing: _DockPositionSetting(),
                        ),
                        _SettingTile(
                          icon: Icons.visibility_off_outlined,
                          title: '自动隐藏',
                          subtitle: '一段时间没有操作 Dock 后收起为小胶囊把手。',
                          trailing: _DockAutoHideSetting(),
                        ),
                        _SettingTile(
                          icon: Icons.timer_outlined,
                          title: '隐藏延迟',
                          subtitle: '设置 Dock 自动收起前等待多久。',
                          trailing: _DockHideDelaySetting(),
                        ),
                        _SettingTile(
                          icon: Icons.open_in_full_outlined,
                          title: '展开方式',
                          subtitle: '隐藏后通过悬停或点击小胶囊把手展开。',
                          trailing: _DockRevealModeSetting(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingSection(
                      title: '外观',
                      children: <Widget>[
                        _SettingTile(
                          icon: Icons.contrast_outlined,
                          title: '主题模式',
                          subtitle: '切换浅色或深色界面。',
                          trailing: _chooseSunNight(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SettingSection(
                      title: '通用',
                      children: <Widget>[
                        _SettingTile(
                          icon: Icons.language_outlined,
                          title: '${S.of(context).langSetting}',
                          subtitle: '切换应用显示语言。',
                          trailing: const SizedBox(
                            width: 280,
                            height: 54,
                            child: ChooseLangPage(),
                          ),
                        ),
                        _SettingTile(
                          icon: Icons.cleaning_services_outlined,
                          title: '清理数据',
                          subtitle: '清理本地缓存和保存的偏好。',
                          trailing: FilledButton.tonalIcon(
                            onPressed: () {
                              SettingToast.tipToast(context, onFunc: () {
                                LocateStorage.clean();
                              });
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('清理'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chooseSunNight() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        _ThemeChoice(
          label: '浅色',
          selected: GlobalStore.theme == 'light',
          background: Colors.white,
          foreground: const Color(0xff1f2937),
          onTap: () => _changeTheme('light'),
        ),
        _ThemeChoice(
          label: '深色',
          selected: GlobalStore.theme == 'dark',
          background: const Color(0xff111827),
          foreground: Colors.white,
          onTap: () => _changeTheme('dark'),
        ),
      ],
    );
  }

  void _changeTheme(String theme) {
    GlobalStore.theme = theme;
    EventBusHelper.asyncStreamController?.add(EventBusM()..theme = theme);
    setState(() {});
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < children.length; index++) ...<Widget>[
                children[index],
                if (index != children.length - 1)
                  Divider(
                    height: 1,
                    indent: 68,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 640;
        final Widget leading = Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        );
        final Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        leading,
                        const SizedBox(width: 14),
                        Expanded(child: content),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: trailing,
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    leading,
                    const SizedBox(width: 14),
                    Expanded(child: content),
                    const SizedBox(width: 20),
                    trailing,
                  ],
                ),
        );
      },
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.selected,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 92,
        height: 56,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.9),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? colorScheme.primary : foreground,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockPositionSetting extends StatelessWidget {
  const _DockPositionSetting();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController controller) {
        return SegmentedButton<DockPosition>(
          segments: const <ButtonSegment<DockPosition>>[
            ButtonSegment<DockPosition>(
              value: DockPosition.side,
              icon: Icon(Icons.vertical_distribute),
              label: Text('侧边'),
            ),
            ButtonSegment<DockPosition>(
              value: DockPosition.bottom,
              icon: Icon(Icons.horizontal_distribute),
              label: Text('底边'),
            ),
          ],
          selected: <DockPosition>{controller.dockPosition},
          onSelectionChanged: (Set<DockPosition> value) {
            controller.setDockPosition(value.first);
          },
        );
      },
    );
  }
}

class _DockAutoHideSetting extends StatelessWidget {
  const _DockAutoHideSetting();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController controller) {
        return Switch(
          value: controller.dockAutoHide,
          onChanged: controller.setDockAutoHide,
        );
      },
    );
  }
}

class _DockHideDelaySetting extends StatelessWidget {
  const _DockHideDelaySetting();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController controller) {
        return SegmentedButton<int>(
          segments: const <ButtonSegment<int>>[
            ButtonSegment<int>(
              value: 5,
              label: Text('5s'),
            ),
            ButtonSegment<int>(
              value: 8,
              label: Text('8s'),
            ),
            ButtonSegment<int>(
              value: 15,
              label: Text('15s'),
            ),
          ],
          selected: <int>{controller.dockAutoHideSeconds},
          onSelectionChanged: controller.dockAutoHide
              ? (Set<int> value) {
                  controller.setDockAutoHideSeconds(value.first);
                }
              : null,
        );
      },
    );
  }
}

class _DockRevealModeSetting extends StatelessWidget {
  const _DockRevealModeSetting();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeShellController>(
      builder: (HomeShellController controller) {
        return SegmentedButton<DockRevealMode>(
          segments: const <ButtonSegment<DockRevealMode>>[
            ButtonSegment<DockRevealMode>(
              value: DockRevealMode.hover,
              icon: Icon(Icons.ads_click_outlined),
              label: Text('悬停'),
            ),
            ButtonSegment<DockRevealMode>(
              value: DockRevealMode.click,
              icon: Icon(Icons.touch_app_outlined),
              label: Text('点击'),
            ),
          ],
          selected: <DockRevealMode>{controller.dockRevealMode},
          onSelectionChanged: (Set<DockRevealMode> value) {
            controller.setDockRevealMode(value.first);
          },
        );
      },
    );
  }
}

class SettingToast {
  static Future<void> tipToast(BuildContext context,
      {String? title, void Function()? onFunc}) async {
    await ModalUtils.showModal(
      context,
      modalBackgroundColor: const Color(0xffffffff),
      modalSize: ModalSize(width: 300),
      dynamicBottom: Container(
        alignment: Alignment.center,
        child: Container(
          width: 300,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(screenUtil.adaptive(30))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  '提示',
                  style: TextStyle(color: Color(0xff404040)),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 30,
                  left: 30,
                ),
                child: Text(
                  '${title ?? '是否清理所有数据？'}',
                  style: const TextStyle(
                    color: Color(0xff426ba5),
                  ),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    bottom: screenUtil.adaptive(30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: InkWell(
                          onTap: () {
                            NavigatorUtils.pop(context);
                          },
                          borderRadius:
                              BorderRadius.circular(screenUtil.adaptive(20)),
                          child: Container(
                            width: 90,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xb3eeeeee),
                              borderRadius: BorderRadius.circular(
                                  screenUtil.adaptive(20)),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: Color(0xff878787),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: InkWell(
                          onTap: () {
                            NavigatorUtils.pop(context);
                            onFunc?.call();
                          },
                          borderRadius:
                              BorderRadius.circular(screenUtil.adaptive(20)),
                          child: Container(
                            width: 90,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xff577fba),
                              borderRadius: BorderRadius.circular(
                                  screenUtil.adaptive(20)),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '确定',
                              style: TextStyle(
                                color: Color(0xffffffff),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

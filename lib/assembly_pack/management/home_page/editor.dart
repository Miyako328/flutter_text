import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/chat_self/user_login/view.dart';
import 'package:flutter_text/assembly_pack/management/function_page/windows_search_page.dart';
import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:flutter_text/init.dart';
import 'package:get/get.dart';
import 'package:self_utils/widget/management/common/listenable.dart';
import 'package:self_utils/widget/management/common/view_key.dart';
import 'package:self_utils/widget/management/widget/stack_view.dart';

import 'theme.dart';
import 'tool.dart';

abstract class EditorListener {
  void onOpen(
      {required ViewKey key,
      required String tab,
      required WidgetBuilder contentIfAbsent,
      VoidCallback? onTapTab});

  void onClose(ViewKey key);
}

class EditorController with GenericListenable<EditorListener> {
  void open(
      {required ViewKey key,
      required String tab,
      required WidgetBuilder contentIfAbsent,
      VoidCallback? onTapTab}) {
    foreach((entry) {
      entry.onOpen(
          key: key,
          contentIfAbsent: contentIfAbsent,
          tab: tab,
          onTapTab: onTapTab);
    });
  }

  void close(ViewKey key) {
    foreach((entry) {
      entry.onClose(key);
    });
  }

  List<TabPage> tabs = <TabPage>[];

  TabPage? current;

  void dispose() {
    current = null;
    tabs = <TabPage>[];
  }
}

class Editor extends StatefulWidget {
  final EditorController controller;

  const Editor({Key? key, required this.controller}) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class TabPage {
  final String tab;
  final WidgetBuilder builder;
  final ViewKey key;
  final VoidCallback? onTapTab;

  TabPage(
      {required this.tab,
      required this.builder,
      required this.key,
      this.onTapTab});
}

class _EditorTopBar extends StatelessWidget {
  final EditorController controller;

  const _EditorTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: GlobalStore.theme == 'light'
          ? HomeTheme.lightBgColor
          : HomeTheme.darkBgColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: controller.tabs.length > 1
                ? Row(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Utils.debounce(() {
                            final TabPage lastOne = controller.tabs.last;
                            controller.close(lastOne.key);
                          }, delay: const Duration(milliseconds: 180));
                        },
                        child: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(width: 20),
                      Text('${controller.current?.tab ?? ''}'),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Visibility(
            visible: controller.current?.key != ContViewKey.search,
            child: InkWell(
              onTap: () {
                controller.open(
                  key: ContViewKey.search,
                  tab: '搜索',
                  contentIfAbsent: (_) => const WindowsSearchPage(),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        right: 30,
                        left: 30,
                        top: 1,
                        bottom: 1,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                        border: Border.all(
                          color: GlobalStore.theme == 'light'
                              ? HomeTheme.lightBorderLineColor
                              : HomeTheme.darkBorderLineColor,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '搜索内部组件',
                        style: TextStyle(
                          color: GlobalStore.theme == 'light'
                              ? HomeTheme.lightBorderTxColor
                              : HomeTheme.darkBorderTxColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.search, size: 20),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (GlobalStore.user == null) {
                WindowsNavigator().pushWidget(
                  context,
                  UserLoginPage(),
                  title: '登陆',
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: GlobalStore.user != null
                  ? SizedBox(
                      width: 30,
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(GlobalStore.user?.image ?? ''),
                      ),
                    )
                  : const SizedBox(
                      width: 30,
                      child: Icon(Icons.person),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorState extends State<Editor> implements EditorListener {
  final StackController controller = StackController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(this);
  }

  @override
  void didUpdateWidget(covariant Editor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(this);
      widget.controller.addListener(this);
    }
  }

  @override
  void onClose(ViewKey key) {
    _close(key);
  }

  @override
  void onOpen(
      {required ViewKey key,
      required String tab,
      required WidgetBuilder contentIfAbsent,
      VoidCallback? onTapTab}) {
    _open(
        key: key,
        tab: tab,
        contentIfAbsent: contentIfAbsent,
        onTapTab: onTapTab);
  }

  void _open(
      {required ViewKey key,
      required String tab,
      required WidgetBuilder contentIfAbsent,
      VoidCallback? onTapTab}) {
    if (widget.controller.tabs.any((TabPage element) => element.key == key)) {
      if (widget.controller.current?.key != key) {
        widget.controller.tabs
            .removeWhere((TabPage element) => element.key == key);
        widget.controller.tabs.add(TabPage(
            tab: tab, builder: contentIfAbsent, key: key, onTapTab: onTapTab));
        controller.open(key, contentIfAbsent);
      }
    } else {
      widget.controller.tabs.add(TabPage(
          tab: tab, builder: contentIfAbsent, key: key, onTapTab: onTapTab));
      controller.open(key, contentIfAbsent);
    }
    setState(() {});
  }

  void _close(ViewKey key) {
    int index =
        widget.controller.tabs.indexWhere((element) => element.key == key);
    if (index == -1) {
      return;
    }
    controller.close(key);
    widget.controller.tabs.removeAt(index);
    setState(() {});
  }

  void _onCurrentIndexChanged(ViewKey? key) {
    if (key == null) {
      widget.controller.current = null;
    } else {
      widget.controller.current =
          widget.controller.tabs.firstWhere((element) => element.key == key);
      assert(widget.controller.current != null);
    }
    Get.find<HomeShellController>().setCurrentKey(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        children: [
          // if (widget.controller.tabs.isNotEmpty)
          //   Container(
          //     padding: const EdgeInsets.only(left: 3, top: 4),
          //     alignment: Alignment.topLeft,
          //     child: Wrap(
          //         alignment: WrapAlignment.start,
          //         spacing: 0,
          //         children: widget.controller.tabs.map((e) => _buildButton(e)).toList()),
          //   ),
          // if (widget.controller.tabs.isNotEmpty)
          //   const SizedBox(
          //     child: Divider(
          //       height: 1,
          //       thickness: 0,
          //     ),
          //   ),
          GetBuilder<HomeShellController>(
            builder: (HomeShellController shellController) {
              return AnimatedContainer(
                height: shellController.isImmersive ? 0 : 50,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: shellController.isImmersive,
                  child: AnimatedOpacity(
                    opacity: shellController.isImmersive ? 0 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: _EditorTopBar(controller: widget.controller),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StackView(
              controller: controller,
              onCurrentIndexChanged: _onCurrentIndexChanged,
            ),
          )
        ],
      ),
    );
  }
}

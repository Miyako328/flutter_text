import 'package:flutter_text/assembly_pack/management/function_page/windows_main_page.dart';
import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:flutter_text/init.dart';
import 'package:get/get.dart';
import 'package:self_utils/widget/management/common/view_key.dart';

import 'editor.dart';

class ContViewKey {
  static const ViewKey mainPage =
      ViewKey(namespace: 'mainPage', id: 'mainPage');
  static const ViewKey media = ViewKey(namespace: 'media', id: 'media');
  static const ViewKey search = ViewKey(namespace: 'search', id: 'search');
  static const ViewKey setting = ViewKey(namespace: 'setting', id: 'setting');
}

class Tool extends StatefulWidget {
  final EditorController controller;

  const Tool({
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _ToolState createState() => _ToolState();
}

class _ToolState extends State<Tool> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      widget.controller.tabs.clear();
      widget.controller.open(
        key: ContViewKey.mainPage,
        tab: '主页',
        contentIfAbsent: (_) => const WindowsMainPage(),
      );
      Get.find<HomeShellController>().activateDockPage(ContViewKey.mainPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

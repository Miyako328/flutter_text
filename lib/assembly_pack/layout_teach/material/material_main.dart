import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/layout_teach/material/action/m_float_button.dart';
import 'package:flutter_text/assembly_pack/layout_teach/material/action/m_icon_button.dart';
import 'package:flutter_text/assembly_pack/layout_teach/material/communication/badge.dart';
import 'package:flutter_text/assembly_pack/layout_teach/material/nagivator/m_appBar.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/model/AComponent.dart';
import 'package:get/get.dart';
import 'package:self_utils/init.dart';

import 'action/m_common_button.dart';
import 'action/m_segment_button.dart';
import 'communication/m_progress.dart';
import 'communication/m_snackbar.dart';
import 'containment/m_alertdialog.dart';
import 'containment/m_card.dart';
import 'containment/m_divider.dart';
import 'containment/m_listtile.dart';
import 'inputs/m_textInputs.dart';
import 'nagivator/m_bottom_bar.dart';
import 'nagivator/m_nagivator_bar.dart';
import 'nagivator/m_navigation_drawer.dart';
import 'nagivator/m_navigation_rail.dart';
import 'nagivator/m_tab_bar.dart';
import 'selection/m_date_picker.dart';
import 'selection/m_menu.dart';
import 'selection/m_switch.dart';
import 'selection/m_timer_picker.dart';

class MaterialThreeMain extends StatelessWidget {
  const MaterialThreeMain({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialThreeController>(
      init: MaterialThreeController(),
      builder: (MaterialThreeController controller) {
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.sections.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 18),
          itemBuilder: (BuildContext context, int index) {
            final MaterialThreeSection section =
                ArrayHelper.get(controller.sections, index)!;
            return _MaterialSection(section: section);
          },
        );
      },
    );
  }
}

class MaterialThreeController extends GetxController {
  final List<MaterialThreeSection> sections = <MaterialThreeSection>[
    MaterialThreeSection(
      title: 'Action',
      icon: Icons.touch_app_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'Common Button'
          ..desc = '普通常见的点击按钮'
          ..pageUrl = const MCommonButton(),
        PageModel()
          ..name = 'Float Action Button'
          ..desc = 'Flutter 里的 FloatingActionButton'
          ..pageUrl = const MFloatButton(),
        PageModel()
          ..name = 'Icon Button'
          ..desc = 'Material3 版本下的 IconButton'
          ..pageUrl = const MIconButton(),
        PageModel()
          ..name = 'Segmented Button'
          ..desc = '单选、多选分段选择器'
          ..pageUrl = const MSegmentedButton(),
      ],
    ),
    MaterialThreeSection(
      title: 'Communication',
      icon: Icons.campaign_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'Badge'
          ..desc = '消息红点组件'
          ..pageUrl = const MBadge(),
        PageModel()
          ..name = 'linearProgressIndicator'
          ..desc = '进度条'
          ..pageUrl = const MProgress(),
        PageModel()
          ..name = 'snackBar'
          ..desc = '底部提示弹框'
          ..pageUrl = const MSnackBar(),
      ],
    ),
    MaterialThreeSection(
      title: 'Containment',
      icon: Icons.inventory_2_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'AlertDialog'
          ..desc = '弹窗组件'
          ..pageUrl = const MAlertDialog(),
        PageModel()
          ..name = 'card'
          ..desc = '卡片视图'
          ..pageUrl = const MCard(),
        PageModel()
          ..name = 'divider'
          ..desc = '分割线'
          ..pageUrl = const MDivider(),
        PageModel()
          ..name = 'ListTile'
          ..desc = 'ListTile 展示'
          ..pageUrl = const MListTile(),
      ],
    ),
    MaterialThreeSection(
      title: 'Navigator',
      icon: Icons.alt_route_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'AppBar'
          ..desc = 'AppBar 展示'
          ..pageUrl = const MAppBar(),
        PageModel()
          ..name = 'BottomBar'
          ..desc = '底部 Bar 展示'
          ..pageUrl = const MBottomBar(),
        PageModel()
          ..name = 'MNavigationBar'
          ..desc = '底部导航栏展示'
          ..pageUrl = const MNavigationBar(),
        PageModel()
          ..name = 'MNavigationDrawer'
          ..desc = '抽屉导航栏'
          ..pageUrl = const MNavigationDrawer(),
        PageModel()
          ..name = 'MNavigationRail'
          ..desc = '侧边导航栏'
          ..pageUrl = const MNavigationRail(),
        PageModel()
          ..name = 'MTabBar'
          ..desc = 'Material3 样式的 TabBar'
          ..pageUrl = const MTabBar(),
      ],
    ),
    MaterialThreeSection(
      title: 'Selection',
      icon: Icons.checklist_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'MDatePicker'
          ..desc = 'Material3 样式的日期选择器'
          ..pageUrl = const MDatePicker(),
        PageModel()
          ..name = 'MSwitch'
          ..desc = 'Material3 样式的 Switch'
          ..pageUrl = const MSwitch(),
        PageModel()
          ..name = 'MMenuAnchor'
          ..desc = '菜单栏'
          ..pageUrl = const MMenuAnchor(),
        PageModel()
          ..name = 'MShowTimePicker'
          ..desc = '时间选择器'
          ..pageUrl = const MShowTimePicker(),
      ],
    ),
    MaterialThreeSection(
      title: 'Text input',
      icon: Icons.edit_note_outlined,
      items: <PageModel>[
        PageModel()
          ..name = 'MTextInput'
          ..desc = '表单输入样式'
          ..pageUrl = const MTextFieldExamples(),
      ],
    ),
  ];
}

class MaterialThreeSection {
  final String title;
  final IconData icon;
  final List<PageModel> items;

  MaterialThreeSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class _MaterialSection extends StatelessWidget {
  final MaterialThreeSection section;

  const _MaterialSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(section.icon),
                const SizedBox(width: 10),
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${section.items.length} 个组件'),
              ],
            ),
            const SizedBox(height: 12),
            ...section.items
                .map(
                  (PageModel item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _MaterialItemTile(item: item),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _MaterialItemTile extends StatelessWidget {
  final PageModel item;

  const _MaterialItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        WindowsNavigator().pushWidget(
          context,
          item.pageUrl,
          title: item.name,
        );
      },
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              const Icon(Icons.widgets_outlined, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.desc ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

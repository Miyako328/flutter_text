import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/animation/animated_button_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/animated_container.dart';
import 'package:flutter_text/assembly_pack/animation/animated_cross_fade.dart';
import 'package:flutter_text/assembly_pack/animation/animated_list_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/expand_collapse_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/hero_transition_page.dart';
import 'package:flutter_text/assembly_pack/animation/implicit_animations_page.dart';
import 'package:flutter_text/assembly_pack/animation/reorderable_list_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/route_transition_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/shimmer_loading_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/staggered_entrance_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/up_animation_example.dart';
import 'package:flutter_text/assembly_pack/choose_seat/choose_seat.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/assembly_pack/neumorphic/calculator/calculator_sample.dart';
import 'package:flutter_text/assembly_pack/neumorphic/clock.dart';
import 'package:flutter_text/assembly_pack/neumorphic/example_one.dart';
import 'package:flutter_text/assembly_pack/neumorphic/example_two.dart';
import 'package:flutter_text/assembly_pack/neumorphic/neumorphic_example.dart';
import 'package:flutter_text/assembly_pack/sort_widget/sort_animation.dart';
import 'package:flutter_text/global/global.dart';
import 'package:flutter_text/model/AComponent.dart';
import 'package:self_utils/utils/array_helper.dart';

import 'animated_physical_page.dart';
import 'circle_light.dart';
import 'cupetino.dart';

class AnimaComponentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AnimaComponentPageState();
}

class AnimaComponentPageState extends State<AnimaComponentPage> {
  List<PageModel> _page = <PageModel>[];
  final List<IconData> _icons = <IconData>[
    Icons.crop_square_rounded,
    Icons.compare_arrows_rounded,
    Icons.blur_circular_rounded,
    Icons.layers_rounded,
    Icons.view_in_ar_rounded,
    Icons.filter_1_rounded,
    Icons.filter_2_rounded,
    Icons.access_time_rounded,
    Icons.calculate_rounded,
    Icons.touch_app_rounded,
    Icons.event_seat_rounded,
    Icons.vertical_align_top_rounded,
    Icons.sort_rounded,
    Icons.auto_awesome_motion_rounded,
    Icons.playlist_add_rounded,
    Icons.image_rounded,
    Icons.route_rounded,
    Icons.smart_button_rounded,
    Icons.hourglass_empty_rounded,
    Icons.unfold_more_rounded,
    Icons.drag_indicator_rounded,
    Icons.grid_view_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _page = <PageModel>[
      PageModel()
        ..name = 'AnimatedContainerPage'
        ..desc = '容器尺寸、颜色、圆角等属性的平滑过渡'
        ..pageUrl = AnimatedContainerPage(),
      PageModel()
        ..name = 'AnimatedCrossFadePage'
        ..desc = '两个组件之间的淡入淡出切换'
        ..pageUrl = AnimatedCrossFadePage(),
      PageModel()
        ..name = 'circle_light'
        ..desc = '呼吸光圈与自定义绘制动画'
        ..pageUrl = CircleLightPage(),
      PageModel()
        ..name = 'AnimatedPhysicalPage'
        ..desc = '带阴影和形状变化的物理动画'
        ..pageUrl = AnimatedPhysicalPage(),
      PageModel()
        ..name = 'NeumorphicExamplePage'
        ..desc = '柔和拟物风格组件集合'
        ..pageUrl = NeumorphicExamplePage(),
      PageModel()
        ..name = 'ExampleOnePage'
        ..desc = '拟物 UI 示例一'
        ..pageUrl = ExampleOnePage(),
      PageModel()
        ..name = 'ExampleTwoPage'
        ..desc = '拟物 UI 示例二'
        ..pageUrl = ExampleTwoPage(),
      PageModel()
        ..name = 'ClockAlarmPage'
        ..desc = '时钟与闹钟动效示例'
        ..pageUrl = ClockAlarmPage(),
      PageModel()
        ..name = 'CalculatorSample'
        ..desc = '计算器交互组件'
        ..pageUrl = CalculatorSample(),
      PageModel()
        ..name = 'CupertinoContextMenuPage'
        ..desc = 'iOS 风格上下文菜单'
        ..pageUrl = CupertinoContextMenuPage(),
      PageModel()
        ..name = 'ChooseSeat'
        ..desc = '选座缩放与拖拽交互'
        ..pageUrl = ChooseSeat(),
      PageModel()
        ..name = 'UpAnimationExample'
        ..desc = '上滑出现的入场动画'
        ..pageUrl = const UpAnimationExample(),
      PageModel()
        ..name = 'SortAnimationPage'
        ..desc = '列表排序过程动画'
        ..pageUrl = const SortAnimationPage(),
      PageModel()
        ..name = 'ImplicitAnimationsPage'
        ..desc = 'AnimatedOpacity、Scale、Switcher 等隐式动画合集'
        ..pageUrl = const ImplicitAnimationsPage(),
      PageModel()
        ..name = 'AnimatedListDemoPage'
        ..desc = '列表新增、删除时的滑入和收起动画'
        ..pageUrl = const AnimatedListDemoPage(),
      PageModel()
        ..name = 'HeroTransitionPage'
        ..desc = '列表到详情页的共享元素转场'
        ..pageUrl = const HeroTransitionPage(),
      PageModel()
        ..name = 'RouteTransitionDemoPage'
        ..desc = '淡入、滑入、缩放等页面转场'
        ..pageUrl = const RouteTransitionDemoPage(),
      PageModel()
        ..name = 'AnimatedButtonDemoPage'
        ..desc = '点赞、加载、成功状态的按钮动效'
        ..pageUrl = const AnimatedButtonDemoPage(),
      PageModel()
        ..name = 'ShimmerLoadingDemoPage'
        ..desc = '接口加载和首屏占位常用的骨架屏动效'
        ..pageUrl = const ShimmerLoadingDemoPage(),
      PageModel()
        ..name = 'ExpandCollapseDemoPage'
        ..desc = 'FAQ、筛选项、详情区的展开折叠'
        ..pageUrl = const ExpandCollapseDemoPage(),
      PageModel()
        ..name = 'ReorderableListDemoPage'
        ..desc = '长按拖拽排序和拖动代理动画'
        ..pageUrl = const ReorderableListDemoPage(),
      PageModel()
        ..name = 'StaggeredEntranceDemoPage'
        ..desc = '卡片列表分批入场动画'
        ..pageUrl = const StaggeredEntranceDemoPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('动画常用组件'),
            )
          : null,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
          final double horizontalPadding =
              constraints.maxWidth >= 900 ? 32 : 18;

          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  GlobalStore.isMobile ? 18 : 28,
                  horizontalPadding,
                  12,
                ),
                sliver: SliverToBoxAdapter(
                  child: _Header(total: _page.length),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  28,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: crossAxisCount == 1 ? 3.4 : 2.35,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final PageModel? item = ArrayHelper.get(_page, index);
                      return _AnimationEntryCard(
                        icon: _icons[index % _icons.length],
                        title: item?.name ?? '',
                        description: item?.desc ?? '',
                        onTap: () {
                          WindowsNavigator().pushWidget(
                            context,
                            item?.pageUrl,
                            title: item?.name,
                          );
                        },
                      );
                    },
                    childCount: _page.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) {
      return 4;
    }
    if (width >= 820) {
      return 3;
    }
    if (width >= 560) {
      return 2;
    }
    return 1;
  }
}

class _Header extends StatelessWidget {
  final int total;

  const _Header({required this.total});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.animation_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '动画常用组件',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total 个动画和交互示例',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimationEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AnimationEntryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

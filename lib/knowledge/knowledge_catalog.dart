import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/animation/animated_button_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/animated_list_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/expand_collapse_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/hero_transition_page.dart';
import 'package:flutter_text/assembly_pack/animation/implicit_animations_page.dart';
import 'package:flutter_text/assembly_pack/animation/reorderable_list_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/route_transition_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/shimmer_loading_demo_page.dart';
import 'package:flutter_text/assembly_pack/animation/staggered_entrance_demo_page.dart';
import 'package:flutter_text/assembly_pack/chat_self/chat_list.dart';
import 'package:flutter_text/assembly_pack/chat_self/user_change/view.dart';
import 'package:flutter_text/assembly_pack/chat_self/user_login/view.dart';
import 'package:flutter_text/assembly_pack/chat_self/user_register/view.dart';
import 'package:flutter_text/assembly_pack/moonlit_map/moonlit_idle_page.dart';
import 'package:flutter_text/assembly_pack/moonlit_map/moonlit_map_page.dart';
import 'package:flutter_text/index.dart';
import 'package:flutter_text/models/main_widget_model.dart';

class KnowledgeSection {
  final String title;
  final String description;
  final IconData icon;
  final List<MainWidgetModel> entries;
  final MainWidgetModel? mainEntry;

  const KnowledgeSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.entries,
    this.mainEntry,
  });

  MainWidgetModel? get primaryEntry {
    if (mainEntry != null) {
      return mainEntry;
    }
    if (entries.isEmpty) {
      return null;
    }
    return entries.first;
  }
}

class KnowledgeCatalog {
  static List<MainWidgetModel> get all {
    return _uniqueByTitle(<MainWidgetModel>[
      ...page4,
      ...page2,
      ...page1,
      ...page3,
      ...extraSearchEntries,
    ]).where((MainWidgetModel item) => item.canOpen).toList();
  }

  static List<MainWidgetModel> get sidebarItems {
    return _uniqueByTitle(<MainWidgetModel>[
      ...page4,
      ...page2,
      ...page1,
      ...page3,
    ])
        .where((MainWidgetModel item) =>
            _sidebarTitles.contains(item.displayTitle))
        .where((MainWidgetModel item) => item.canOpen)
        .toList();
  }

  static List<KnowledgeSection> get sections {
    final List<MainWidgetModel> entries = all;
    return <KnowledgeSection>[
      KnowledgeSection(
        title: '基础与 Material',
        description: '从基础语法、状态传递到 Material3 组件，适合作为系统学习入口。',
        icon: Icons.school_outlined,
        mainEntry: _findByTitle(entries, 'StudyCenter 学习中心'),
        entries: _whereAny(entries, <String>[
          'StudyCenter',
          'Material',
          'Basic',
          'TextStyle',
          'PropertyEnum',
          'Svg',
          'chip',
        ]),
      ),
      KnowledgeSection(
        title: '组件与布局',
        description: '常用控件、列表、表单、导航、弹层和布局实验，适合边查边用。',
        icon: Icons.widgets_outlined,
        mainEntry: _findByTitle(entries, '组件能力库'),
        entries: _whereAny(entries, <String>[
          '组件',
          'Button',
          'Layout',
          'GridView',
          'Form',
          'Popup',
          'Slidable',
          'slider',
          'Box',
          'List',
          'Navigation',
          '底部',
          '布局',
        ]),
      ),
      KnowledgeSection(
        title: '动画与绘制',
        description: '动画组件、画板、Canvas、刮刮乐、游戏与视觉效果实验。',
        icon: Icons.animation_outlined,
        entries: _whereAny(entries, <String>[
          '动画',
          'Animations',
          'paint',
          'canvas',
          'Game',
          '闪闪',
          'Scratch',
          'Sliding Image',
          'sort',
        ]),
      ),
      KnowledgeSection(
        title: '桌面与系统能力',
        description: '桌面端窗口、文件拖拽、键盘、Shell、DLL、本地通知等能力。',
        icon: Icons.desktop_mac_outlined,
        entries: _whereAny(entries, <String>[
          'desktop',
          'SMB',
          'NAS',
          'DropDock',
          'Shell',
          'DLL',
          'Keyboard',
          '本地消息',
          'localAuth',
          'scheme',
          'package info',
        ]),
      ),
      KnowledgeSection(
        title: '数据、网络与媒体',
        description: '数据库、缓存、API、WebView、WebRTC、音视频、PDF、书架等综合能力。',
        icon: Icons.hub_outlined,
        entries: _whereAny(entries, <String>[
          'Sql',
          'redis',
          'mqtt',
          'api',
          '天气',
          '翻译',
          'webRtc',
          'WebView',
          '视频',
          '音乐',
          'pdf',
          '书架',
          '浏览器',
        ]),
      ),
    ];
  }

  static List<MainWidgetModel> get recommended {
    return _uniqueByTitle(<MainWidgetModel>[
      ...sidebarItems,
      ...sections.expand((KnowledgeSection section) => section.entries.take(2)),
    ]).take(10).toList();
  }

  static List<MainWidgetModel> search(String keyword) {
    return all.where((MainWidgetModel item) => item.matches(keyword)).toList();
  }

  static List<MainWidgetModel> get extraSearchEntries {
    return <MainWidgetModel>[
      MainWidgetModel(
        title: '月下地图册',
        route: const MoonlitMapPage(),
        icon: const Icon(Icons.map_outlined),
        category: '小说资料库',
        description: '从 NAS 读取地图和点位，查看《月下，她与她的长夜》的互动地图。',
        tags: const <String>['月下', '地图', '小说', '资料库', 'moonlit', 'NAS'],
      ),
      MainWidgetModel(
        title: '月下远征',
        route: const MoonlitIdlePage(),
        icon: const Icon(Icons.explore_outlined),
        category: '小说资料库',
        description: '暮色镇周边探索、线索收集与局外养成。',
        tags: const <String>['月下', '远征', '放置', '暮色镇', '玛克莱', 'idle'],
      ),
      MainWidgetModel(
        title: '登录 / 登陆',
        route: UserLoginPage(),
        icon: const Icon(Icons.login_rounded),
        category: '用户系统',
        description: '使用用户名和密码登录本地 MySQL 用户系统。',
        tags: const <String>['登录', '登陆', 'login', '用户', '账号', '密码'],
      ),
      MainWidgetModel(
        title: '注册用户',
        route: UserRegisterPage(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        category: '用户系统',
        description: '创建用户账号，保存用户名、密码和头像。',
        tags: const <String>['注册', 'register', '用户', '账号', 'mysql'],
      ),
      MainWidgetModel(
        title: '修改用户资料',
        route: UserChangePage(),
        icon: const Icon(Icons.manage_accounts_rounded),
        category: '用户系统',
        description: '修改当前用户的昵称和头像地址。',
        tags: const <String>['用户', '资料', '头像', '昵称', '修改'],
      ),
      MainWidgetModel(
        title: '聊天',
        route: ChatListWidget(),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        category: '用户系统',
        description: '登录后进入聊天房间列表和消息页面。',
        tags: const <String>['聊天', '聊天室', 'chat', '消息', '房间'],
      ),
      MainWidgetModel(
        title: '隐式动画合集',
        route: const ImplicitAnimationsPage(),
        icon: const Icon(Icons.auto_awesome_motion_rounded),
        category: '动画',
        description: 'AnimatedOpacity、Scale、Switcher 等常用隐式动画。',
        tags: const <String>['动画', 'implicit', 'AnimatedSwitcher', 'Tween'],
      ),
      MainWidgetModel(
        title: 'AnimatedList 列表动画',
        route: const AnimatedListDemoPage(),
        icon: const Icon(Icons.playlist_add_rounded),
        category: '动画',
        description: '列表新增、删除时的滑入和收起动画。',
        tags: const <String>['动画', '列表', 'AnimatedList', '删除', '新增'],
      ),
      MainWidgetModel(
        title: 'Hero 共享元素转场',
        route: const HeroTransitionPage(),
        icon: const Icon(Icons.image_rounded),
        category: '动画',
        description: '列表到详情页的共享元素转场。',
        tags: const <String>['动画', 'Hero', '转场', '共享元素'],
      ),
      MainWidgetModel(
        title: '页面转场动画',
        route: const RouteTransitionDemoPage(),
        icon: const Icon(Icons.route_rounded),
        category: '动画',
        description: '淡入、滑入、缩放等 PageRouteBuilder 转场。',
        tags: const <String>['动画', '路由', '转场', 'Route', 'PageRoute'],
      ),
      MainWidgetModel(
        title: '按钮动效',
        route: const AnimatedButtonDemoPage(),
        icon: const Icon(Icons.smart_button_rounded),
        category: '动画',
        description: '点赞、加载、成功状态的按钮动画。',
        tags: const <String>['动画', '按钮', '点赞', '加载', '成功'],
      ),
      MainWidgetModel(
        title: '骨架屏 Shimmer Loading',
        route: const ShimmerLoadingDemoPage(),
        icon: const Icon(Icons.hourglass_empty_rounded),
        category: '动画',
        description: '接口加载和首屏占位常用的骨架屏动效。',
        tags: const <String>['动画', '骨架屏', 'Shimmer', 'Loading', '加载'],
      ),
      MainWidgetModel(
        title: '展开折叠面板',
        route: const ExpandCollapseDemoPage(),
        icon: const Icon(Icons.unfold_more_rounded),
        category: '动画',
        description: 'FAQ、筛选项、详情区的展开折叠。',
        tags: const <String>['动画', '展开', '折叠', '面板', 'FAQ'],
      ),
      MainWidgetModel(
        title: '拖拽排序列表',
        route: const ReorderableListDemoPage(),
        icon: const Icon(Icons.drag_indicator_rounded),
        category: '动画',
        description: '长按拖拽排序和拖动代理动画。',
        tags: const <String>['动画', '拖拽', '排序', 'ReorderableListView'],
      ),
      MainWidgetModel(
        title: '分批入场动画',
        route: const StaggeredEntranceDemoPage(),
        icon: const Icon(Icons.grid_view_rounded),
        category: '动画',
        description: '卡片列表分批进入页面的错峰动画。',
        tags: const <String>['动画', '入场', 'Staggered', '卡片', '列表'],
      ),
    ];
  }

  static List<MainWidgetModel> _uniqueByTitle(List<MainWidgetModel> items) {
    final Set<String> titles = <String>{};
    final List<MainWidgetModel> result = <MainWidgetModel>[];

    for (final MainWidgetModel item in items) {
      final String key = item.displayTitle.toLowerCase();
      if (titles.add(key)) {
        result.add(item);
      }
    }
    return result;
  }

  static List<MainWidgetModel> _whereAny(
    List<MainWidgetModel> entries,
    List<String> keywords,
  ) {
    final List<String> normalized =
        keywords.map((String value) => value.toLowerCase()).toList();
    return entries.where((MainWidgetModel item) {
      final String text = <String>[
        item.title,
        item.displayTitle,
        item.category ?? '',
        item.description ?? '',
        ...item.tags,
      ].join(' ').toLowerCase();
      return normalized.any(text.contains);
    }).toList();
  }

  static MainWidgetModel? _findByTitle(
    List<MainWidgetModel> entries,
    String title,
  ) {
    for (final MainWidgetModel item in entries) {
      if (item.displayTitle == title) {
        return item;
      }
    }
    return null;
  }

  static final Set<String> _sidebarTitles = <String>{
    'StudyCenter 学习中心',
    '组件能力库',
    '书架',
    '浏览器',
  };
}

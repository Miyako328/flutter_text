import 'package:flutter/material.dart';
import 'package:flutter_text/index.dart';
import 'package:flutter_text/models/main_widget_model.dart';

class KnowledgeSection {
  final String title;
  final String description;
  final IconData icon;
  final List<MainWidgetModel> entries;

  const KnowledgeSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.entries,
  });

  MainWidgetModel? get primaryEntry {
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
        entries: _whereAny(entries, <String>[
          'StudyCenter',
          '组件能力库',
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

  static final Set<String> _sidebarTitles = <String>{
    'StudyCenter 学习中心',
    '组件能力库',
    '书架',
    '浏览器',
  };
}

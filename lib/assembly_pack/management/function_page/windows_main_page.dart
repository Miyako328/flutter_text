import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/management/function_page/windows_search_page.dart';
import 'package:flutter_text/assembly_pack/management/home_page/home_shell_controller.dart';
import 'package:flutter_text/assembly_pack/management/utils/navigator.dart';
import 'package:flutter_text/knowledge/knowledge_catalog.dart';
import 'package:flutter_text/knowledge/knowledge_home_controller.dart';
import 'package:flutter_text/model/img_model.dart';
import 'package:flutter_text/models/main_widget_model.dart';
import 'package:get/get.dart';

class WindowsMainPage extends StatefulWidget {
  const WindowsMainPage({Key? key}) : super(key: key);

  @override
  State<WindowsMainPage> createState() => _WindowsMainPageState();
}

class _WindowsMainPageState extends State<WindowsMainPage> {
  final List<ImageModel> _imgData = <ImageModel>[
    ImageModel()..fileImage = 'images/001.jpeg',
    ImageModel()..fileImage = 'images/002.jpg',
    ImageModel()..fileImage = 'images/003.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      Get.find<HomeShellController>().setImmersive(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KnowledgeHomeController>(
      init: KnowledgeHomeController(),
      builder: (KnowledgeHomeController controller) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _HeroBanner(images: _imgData),
                  _Header(controller: controller),
                  const _StudyPath(),
                  _SectionList(sections: controller.sections),
                  _RecommendedList(items: controller.recommended),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatefulWidget {
  final List<ImageModel> images;

  const _HeroBanner({required this.images});

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  late final PageController _pageController;
  late int _currentIndex;
  Timer? _timer;

  List<ImageModel> get _safeImages {
    return widget.images.isEmpty
        ? <ImageModel>[ImageModel()..fileImage = 'images/001.jpeg']
        : widget.images;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients || _safeImages.length <= 1) {
        return;
      }
      final int nextIndex = (_currentIndex + 1) % _safeImages.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ImageModel> safeImages = _safeImages;
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            itemCount: safeImages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              final ImageModel item = safeImages[index];
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (item.fileImage != null)
                    Image.asset(
                      item.fileImage!,
                      fit: BoxFit.cover,
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Flutter Study',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '沉浸式学习工作台，搜索和导航都在页面里完成。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                ),
                const SizedBox(height: 18),
                _HeroSearchButton(),
              ],
            ),
          ),
          Positioned(
            right: 28,
            bottom: 28,
            child: Row(
              children: List<Widget>.generate(safeImages.length, (int index) {
                final bool selected = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: selected ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: selected ? 0.9 : 0.4),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSearchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        WindowsNavigator().pushWidget(
          context,
          const WindowsSearchPage(),
          title: '搜索',
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
        ),
        child: SizedBox(
          width: 420,
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.black.withValues(alpha: 0.68),
                ),
                const SizedBox(width: 12),
                Text(
                  '搜索组件、能力、关键词...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.62),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final KnowledgeHomeController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Flutter 知识库',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '把组件、桌面能力、网络数据和实战页面收进一个可搜索、可扩展的学习工作台。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _MetricTile(
                label: '可打开示例',
                value: '${controller.entryCount}',
                icon: Icons.apps_outlined,
              ),
              _MetricTile(
                label: '知识分类',
                value: '${controller.sections.length}',
                icon: Icons.category_outlined,
              ),
              _MetricTile(
                label: '侧栏高频入口',
                value: '${controller.sidebarCount}',
                icon: Icons.push_pin_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyPath extends StatelessWidget {
  const _StudyPath();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('学习路线', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              Expanded(
                child: _PathStep(
                  index: '01',
                  title: '先搭骨架',
                  desc: '基础语法、布局、状态管理',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PathStep(
                  index: '02',
                  title: '再练组件',
                  desc: 'Material、表单、列表、导航',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PathStep(
                  index: '03',
                  title: '最后做能力',
                  desc: '桌面、网络、媒体、数据',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  final List<KnowledgeSection> sections;

  const _SectionList({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('知识分类', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...sections
              .map(
                (KnowledgeSection section) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SectionTile(section: section),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _RecommendedList extends StatelessWidget {
  final List<MainWidgetModel> items;

  const _RecommendedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('推荐入口', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...items
              .map(
                (MainWidgetModel item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EntryTile(item: item),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: 180,
        height: 74,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  final String index;
  final String title;
  final String desc;

  const _PathStep({
    required this.index,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Text(index, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _SectionTile extends StatelessWidget {
  final KnowledgeSection section;

  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    final MainWidgetModel? primaryEntry = section.primaryEntry;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: primaryEntry == null
          ? null
          : () {
              _openEntry(context, primaryEntry);
            },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 118,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(section.icon, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              section.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Text('${section.entries.length} 个条目'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        primaryEntry == null
                            ? '待补充入口'
                            : '进入：${primaryEntry.displayTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final MainWidgetModel item;

  const _EntryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        _openEntry(context, item);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: <Widget>[
                item.icon,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openEntry(BuildContext context, MainWidgetModel item) {
  if (item.route != null) {
    WindowsNavigator().pushWidget(
      context,
      item.route!,
      title: item.displayTitle,
    );
  } else {
    item.onTapFunc?.call(context);
  }
}

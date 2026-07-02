import 'package:flutter_text/assembly_pack/management/home_page/theme.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/knowledge/knowledge_search_controller.dart';
import 'package:flutter_text/models/main_widget_model.dart';
import 'package:get/get.dart';

class WindowsSearchPage extends StatelessWidget {
  const WindowsSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KnowledgeSearchController>(
      init: KnowledgeSearchController(),
      builder: (KnowledgeSearchController controller) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(60, 90, 60, 40),
            child: Column(
              children: <Widget>[
                _SearchInput(controller: controller),
                const SizedBox(height: 32),
                Expanded(
                  child: controller.results.isEmpty
                      ? const _EmptyResult()
                      : _SearchResultList(results: controller.results),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchInput extends StatelessWidget {
  final KnowledgeSearchController controller;

  const _SearchInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(right: 12, left: 14),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(
            color: GlobalStore.theme == 'light'
                ? HomeTheme.lightBorderLineColor
                : HomeTheme.darkBorderLineColor,
            width: 1.0,
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 520),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: controller.textController,
                decoration: const InputDecoration(
                  hintText: '搜索组件、能力、关键词...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
            ),
            const Icon(Icons.search),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/images/plane2.gif',
            width: 60,
          ),
          const SizedBox(height: 18),
          Text(
            '输入关键词查找知识条目',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SearchResultList extends StatelessWidget {
  final List<MainWidgetModel> results;

  const _SearchResultList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final MainWidgetModel item = ArrayHelper.get(results, index)!;
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (item.route != null) {
              WindowsNavigator().pushWidget(
                context,
                item.route!,
                title: item.displayTitle,
              );
            } else {
              item.onTapFunc?.call(context);
            }
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    item.icon,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.black.withValues(
                                        alpha: 0.56,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitle(MainWidgetModel item) {
    final List<String> values = <String>[
      if (item.category?.isNotEmpty == true) item.category!,
      if (item.description?.isNotEmpty == true) item.description!,
      if (item.tags.isNotEmpty) item.tags.take(3).join(' / '),
    ];
    if (values.isEmpty) {
      return '点击打开';
    }
    return values.join(' · ');
  }
}

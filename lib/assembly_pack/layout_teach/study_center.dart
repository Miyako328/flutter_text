import 'package:flutter_text/assembly_pack/layout_teach/study_center_controller.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/model/AComponent.dart';
import 'package:get/get.dart';

class StudyCenterPage extends StatelessWidget {
  const StudyCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StudyCenterController>(
      init: StudyCenterController(),
      builder: (StudyCenterController controller) {
        return Scaffold(
          appBar: GlobalStore.isMobile
              ? AppBar(
                  title: const Text('学习中心'),
                )
              : null,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '学习中心',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '按主题进入学习页面，每个页面里都可以继续查看具体组件示例。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: controller.pages.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final PageModel item =
                          ArrayHelper.get(controller.pages, index)!;
                      return _StudyCenterTile(item: item);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudyCenterTile extends StatelessWidget {
  final PageModel item;

  const _StudyCenterTile({required this.item});

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
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                const Icon(Icons.menu_book_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
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
      ),
    );
  }
}

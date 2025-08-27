import 'package:flutter_text/assembly_pack/webRTC/get_display_media.dart';
import 'package:flutter_text/assembly_pack/webRTC/get_user_media.dart';
import 'package:self_utils/generated/l10n.dart';
import 'assembly_pack/layout_teach/study_center.dart';
import 'assembly_pack/webRTC/call_sample.dart';
import 'init.dart';
import 'package:get/get.dart';
import 'controllers/main_controller.dart';
import 'models/main_widget_model.dart';

part 'index.init.dart';

class MainIndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return PlaneIsland(
          child: Scaffold(
            appBar: AppBar(
              title: Text('${S.of(context).appName}'),
              actions: [
                GestureDetector(
                  onTap: () {
                    NavigatorUtils().pushWidget(context, const WindowsSearchPage());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (BuildContext context) => TabBarView(
                controller: controller.tabController,
                children: <Widget>[
                  RepaintBoundary(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final MainWidgetModel mainModel =
                              ArrayHelper.get(controller.page1, index)!;
                              return ListTile(
                                leading: mainModel.icon,
                                title: Text(
                                  '${mainModel.title}',
                                  style: TextStyle(
                                    fontSize: screenUtil.adaptive(40),
                                  ),
                                ),
                                onTap: () {
                                  if (mainModel.route != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => mainModel.route!),
                                    );
                                  } else {
                                    mainModel.onTapFunc?.call(context);
                                  }
                                },
                              );
                            },
                            itemCount: controller.page1.length,
                          )
                        ],
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: Container(
                      child: ScrollListenerWidget(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            final MainWidgetModel mainModel =
                            ArrayHelper.get(controller.page2, index)!;
                            return ListTile(
                              leading: mainModel.icon,
                              title: Text(
                                '${mainModel.title}',
                                style: TextStyle(
                                  fontSize: screenUtil.adaptive(40),
                                ),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                if (mainModel.route != null) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                        mainModel.route!),
                                  );
                                } else {
                                  mainModel.onTapFunc?.call(context);
                                }
                              },
                            );
                          },
                          itemCount: controller.page2.length,
                        ),
                        callback: (int first, int last) {
                          Log.info('firstIndex - lastIndex: $first - $last');
                        },
                      ),
                    ),
                  ),
                  RepaintBoundary(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        final MainWidgetModel mainModel =
                        ArrayHelper.get(controller.page3, index)!;
                        return ListTile(
                          leading: mainModel.icon,
                          title: Text(
                            '${mainModel.title}',
                            style: TextStyle(
                              fontSize: screenUtil.adaptive(40),
                            ),
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            if (mainModel.route != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    mainModel.route!),
                              );
                            } else {
                              mainModel.onTapFunc?.call(context);
                            }
                          },
                        );
                      },
                      itemCount: controller.page3.length,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.contacts), label: '聊天室'),
                BottomNavigationBarItem(icon: Icon(Icons.apps), label: '组件'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: 'Api'),
              ],
              currentIndex: controller.currentIndex.value,
              onTap: (index) {
                controller.onTabTapped(index);
              },
            ),
          ),
        );
      },
    );
  }
}

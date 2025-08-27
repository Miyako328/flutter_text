import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/management/home_page/theme.dart';
import 'package:flutter_text/index.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/models/main_widget_model.dart';

class WindowsSearchPage extends StatefulWidget {
  const WindowsSearchPage({Key? key}) : super(key: key);

  @override
  State<WindowsSearchPage> createState() => _WindowsSearchPageState();
}

class _WindowsSearchPageState extends State<WindowsSearchPage> {
  TextEditingController controller = TextEditingController();
  List<MainWidgetModel> _search = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      searchFunc();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void searchFunc() {
    _search.clear();
    final List<MainWidgetModel> all = [...page1, ...page2, ...page3];
    all.map((MainWidgetModel e) {
      if (e.title.toLowerCase().contains(controller.text) &&
          controller.text.isNotEmpty) {
        _search.add(e);
      }
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.only(right: 10, left: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                border: Border.all(color: (GlobalStore.theme == 'light'
                    ? HomeTheme.lightBorderLineColor
                    : HomeTheme.darkBorderLineColor), width: 1.0),
              ),
              width: 400,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: '你想知道些什么....',
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
          ),
          if (_search.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 150),
              child: Column(
                children: [
                  Image.asset(
                    'images/plane2.gif',
                    width: 60,
                  ),
                ],
              ),
            )
          else
            RepaintBoundary(
              child: Container(
                height: 300,
                margin: const EdgeInsets.only(top: 100, right: 60, left: 60),
                child: GridView.builder(
                  itemCount: _search.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final MainWidgetModel item =
                        ArrayHelper.get(_search, index)!;
                    return InkWell(
                      onTap: () {
                        if (item.route != null) {
                          WindowsNavigator().pushWidget(
                            context,
                            item.route!,
                            title: item.title,
                          );
                        }
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            item.icon,
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(item.title),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

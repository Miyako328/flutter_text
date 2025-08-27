import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:self_utils/init.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/local_log.dart';
import 'package:self_utils/utils/log_utils.dart';

import '../highlight/highlight.dart';

class SearchResult {
  final int start;
  final int end;
  final TextSpan widget;

  SearchResult({required this.start, required this.widget, required this.end});
}

class LogInfoPage extends StatefulWidget {
  const LogInfoPage({Key? key}) : super(key: key);

  @override
  State<LogInfoPage> createState() => _LogInfoPageState();
}

class _LogInfoPageState extends State<LogInfoPage> {
  String log = '';
  bool isShow = false;
  bool isLoading = true;
  bool textFieldMouse = false;
  String? key;
  TextEditingController controller = TextEditingController();
  late ScrollController _scrollController;
  late ListObserverController observerController;
  List<int> searchIndexes = [];
  List<String> logList = [];
  int index = 0;

  @override
  void initState() {
    _scrollController = ScrollController();
    observerController = ListObserverController(controller: _scrollController);
    init();
    super.initState();
  }

  Future<void> init() async {
    log = await LocalLog.getLogInfo();
    logList = log.split('\n');
    // isLoading = false;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void scrollToIndex(int index) {
    observerController.jumpTo(index: searchIndexes[index]);
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            child: Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    onEnter: (PointerEnterEvent event) {
                      textFieldMouse = true;
                      setState(() {});
                    },
                    onExit: (PointerExitEvent event) {
                      textFieldMouse = false;
                      setState(() {});
                    },
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                          right: 30, left: 10, top: 1, bottom: 1),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(fontSize: 15),
                        decoration: const InputDecoration(
                            hintText: '搜索', hintStyle: TextStyle(fontSize: 15)),
                        onChanged: (String val) {
                          key = val;
                          searchIndexes.clear();
                          index=0;
                          if (val.isNotEmpty) {
                            for (var key in logList) {
                              if (key
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                                searchIndexes.add(logList.indexOf(key));
                                index = searchIndexes.length-1;
                              }
                            }
                            scrollToIndex(index);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
                key != null && key!.isNotEmpty ?
                Row(
                  children: [
                    Text('搜索结果: ${index + 1}/${searchIndexes.length}'),
                    GestureDetector(
                      onTap: () {
                        index -= 1;
                        if (index < 0) {
                          index = searchIndexes.length;
                        }
                        scrollToIndex(index);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.arrow_upward,
                        size: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        index += 1;
                        if (index >= searchIndexes.length) {
                          index = 0;
                        }
                        scrollToIndex(index);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.arrow_downward,
                        size: 13,
                      ),
                    ),
                  ],
                ): Container()
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              child: ListViewObserver(
                controller: observerController,
                child: highLightText(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget highLightText() {
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: (_, int index) {
        return Container(
          color: const Color.fromRGBO(0, 0, 0, 0.08),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                margin: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Text(
                  '$index',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              searchIndexes.isEmpty
                  ? Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 1, bottom: 1),
                  color: Colors.white,
                  child: Text(
                    ArrayHelper.get(logList, index)!,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 14),
                  ),
                ),
              )
                  : Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 10, top: 1, bottom: 1),
                  color: Colors.white,
                  child: TextHighlight(
                    searchContent: key ?? '',
                    content: ArrayHelper.get(logList, index)!,
                    ordinaryStyle: const TextStyle(
                        color: Colors.black, fontSize: 14),
                    highlightStyle: const TextStyle(
                        color: Colors.red, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: logList.length,
    );
  }
}

part of 'common_form.dart';

class GroupCommonForm<T> extends StatefulWidget {
  final List<FormColumn<T>> columns;
  final List<T> values;
  final bool canDrag;
  final TapCallBack<T?>? onTapFunc; //点击回调
  final DragCallBack<T>? onDragFunc; //拖拽后的回调
  final DragTitleCallBack<T>? onDragTitleFunc; //拖拽表格标题后的回调
  final double? height;
  final Color? titleColor;
  final Color? formColor;

  /// 选中反馈
  final bool showSelectItem;

  final RightMenuFunc? rightMenuFunc; // 鼠标右键方法

  const GroupCommonForm(
      {super.key,
      required this.values,
      required this.columns,
      this.canDrag = true,
      this.formColor,
      this.height,
      this.onDragFunc,
      this.onDragTitleFunc,
      this.onTapFunc,
      this.rightMenuFunc,
      this.showSelectItem = true,
      this.titleColor});

  @override
  State<GroupCommonForm<T>> createState() => _GroupCommonFormState<T>();
}

class _GroupCommonFormState<T> extends State<GroupCommonForm<T>>
    with WidgetsBindingObserver {
  ScrollController hController = ScrollController();
  ScrollController vController = ScrollController();

  bool shouldReact = false;
  int onSelectHash = -1;
  int onHoverHash = -1;

  ///选中item的hash值
  List<int> hashcodes = [];

  final StreamController<List<FormColumn<T>>> controller =
      StreamController<List<FormColumn<T>>>();
  List<FormColumn<T>> columns = <FormColumn<T>>[];
  List<T> values = [];
  GroupingResult<T> mapValues = GroupingResult<T>();

  /// 拖拽锁
  final self_lock.Lock _lock = self_lock.Lock();

  /// 子表
  List<int> hashCodeList = [];

  /// 排序
  SortType sortType = SortType.normal;
  FormColumn<T>? sortE;
  String sortName = '';

  //todo group分组的类别实现？
  int groupBoxIndex = 0;
  double maxWidth = 0;

  @override
  void initState() {
    super.initState();
    columns = widget.columns;
    values.clear();
    values.addAll(widget.values);
    if (sortE != null) {
      changeSort(sortE!);
    }
    initColumn();
    WidgetsBinding.instance.addObserver(this);
    initWidth();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant GroupCommonForm<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      columns = widget.columns;
      values.clear();
      values.addAll(widget.values);
      if (sortE != null) {
        changeSort(sortE!);
      }
      initColumn();
      controller.sink.add(columns);
      setState(() {});
    }
  }

  /// 确定nullBox的位置
  void initColumn() {
    columns.removeWhere((element) => element.nullBox == true);
    columns.insert(
      groupBoxIndex,
      FormColumn<T>(
        title: Container(),
        width: 30,
        nullBox: true,
        builder: (_, v) => Container(),
      ),
    );
  }

  void initWidth() {
    for (var i in columns) {
      maxWidth += i.width ?? FormSetting.width;
    }
  }

  void setGroupData() {
    final List<FormColumn<T>> res = columns.sublist(0, groupBoxIndex);
    if (res.isNotEmpty == true) {
      res.reversed;
      final GroupingResult<T> result = ArrayHelper.groupByMultiple(
          values, res.map((e) => e.getGroupKey!).toList());
      mapValues = result;
    } else {
      hashCodeList.clear();
      mapValues = GroupingResult<T>();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (ScreenUtil.checkNeedUpdate()) {
      setState(() {});
    }
  }

  void changeSort(FormColumn<T> e) {
    if (sortType == SortType.order) {
      values.sort((a, b) => e.comparator!(1, a, b));
    } else if (sortType == SortType.reverse) {
      values.sort((a, b) => e.comparator!(0, a, b));
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Widget buildTitleRow(List<FormColumn<T>> formList) {
    return Row(
      children: widget.canDrag
          ? formList
              .map(
                (e) => LongPressDraggable(
                  data: e.nullBox == true ? '' : e,
                  delay: const Duration(milliseconds: 300),
                  feedback: e.nullBox == true
                      ? Container()
                      : WrapWidget(
                          width: e.width,
                          color: widget.titleColor,
                          child: e.title),
                  child: DragTarget<FormColumn<T>>(
                    onAccept: (data) {
                      final index = columns.indexOf(e);
                      setState(() {
                        columns.remove(data);
                        columns.insert(index, data);
                        controller.sink.add(columns);
                        groupBoxIndex = columns
                            .indexWhere((element) => element.nullBox == true);
                      });
                      setGroupData();
                      widget.onDragTitleFunc?.call(columns);
                    },
                    builder: (context, data, rejects) {
                      return e.nullBox == true
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.1, color: const Color(0xE6797979)),
                              ),
                              height: 26,
                              width: e.width ?? 40,
                              padding: const EdgeInsets.all(1),
                            )
                          : GestureDetector(
                              onTap: e.onTitleTap != null
                                  ? () {
                                      e.onTitleTap!.call();
                                    }
                                  : e.comparator != null
                                      ? () {
                                          if ((sortType == SortType.normal &&
                                                  sortName == '') ||
                                              sortName !=
                                                  '${e.comparator.hashCode}') {
                                            sortE = e;
                                            sortType = SortType.order;
                                            values.sort((a, b) =>
                                                e.comparator!(1, a, b));
                                            sortName =
                                                '${e.comparator.hashCode}';
                                          } else if (sortType ==
                                                  SortType.order &&
                                              sortName ==
                                                  '${e.comparator.hashCode}') {
                                            sortType = SortType.reverse;
                                            values.sort((a, b) =>
                                                e.comparator!(0, a, b));
                                          } else {
                                            sortType = SortType.normal;
                                            sortName = '';
                                            sortE = null;
                                            values.clear();
                                            values.addAll(widget.values);
                                          }
                                          setGroupData();
                                          setState(() {});
                                        }
                                      : null,
                              child: WrapWidget(
                                  width: e.width,
                                  color: widget.titleColor,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      e.title,
                                      ((sortType == SortType.normal &&
                                                  sortName == '') ||
                                              sortName !=
                                                  '${e.comparator.hashCode}')
                                          ? Container()
                                          : (sortType == SortType.order &&
                                                  sortName ==
                                                      '${e.comparator.hashCode}')
                                              ? const Icon(Icons
                                                  .arrow_drop_down_outlined)
                                              : const Icon(Icons.arrow_drop_up),
                                    ],
                                  )),
                            );
                    },
                  ),
                ),
              )
              .toList(growable: false)
          : formList
              .map(
                (e) => WrapWidget(
                    width: e.width, color: widget.titleColor, child: e.title),
              )
              .toList(growable: false),
    );
  }

  Widget buildRow(T value, {Color? color}) {
    final List<FormColumn<T>> res = columns.sublist(0, groupBoxIndex);
    return Listener(
      onPointerDown: (e) {
        shouldReact = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (e) async {
        if (!shouldReact) return;
        shouldReact = false;

        final position = Offset(
          e.position.dx + Offset.zero.dx,
          e.position.dy + Offset.zero.dy,
        );

        final selectedItem = await native.showContextMenu(
          native.ShowMenuArgs(
            MediaQuery.of(context).devicePixelRatio,
            position,
            widget.rightMenuFunc?.menuItems ?? [],
          ),
        );

        if (selectedItem != null) {
          widget.rightMenuFunc?.onItemSelected
              ?.call(selectedItem, values.indexOf(value));
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          if (onHoverHash != value.hashCode) {
            onHoverHash = value.hashCode ?? -1;
          }
          setState(() {});
        },
        onExit: (event) {
          if (onHoverHash == value.hashCode) {
            onHoverHash = -1;
          }
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            color:
                value.hashCode == onSelectHash || value.hashCode == onHoverHash
                    ? Colors.blue.shade50
                    : color,
          ),
          child: GestureDetector(
            onTap: () {
              if (onSelectHash != value.hashCode) {
                onSelectHash = value.hashCode ?? -1;
              } else {
                onSelectHash = -1;
              }
              if (!_lock.isUsing()) {
                widget.onTapFunc?.call(onSelectHash != -1 ? value : null);
              }
              setState(() {});
            },
            child: Row(
              children: widget.columns
                  .map((e) => WrapWidget(
                      color: e.color?.call(value),
                      width: e.width,
                      child:
                          res.any((element) => element.hashCode == e.hashCode)
                              ? Container()
                              : e.builder(context, value)))
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGroupRow(dynamic key, GroupingResult<T> values, {double width = 0, deep = 0}) {
    final List<FormColumn<T>> res = columns.sublist(0, groupBoxIndex);
    final List<Widget> children = <Widget>[];
    if (values.subGroups.isNotEmpty == true) {
      double nextWidth = width + (res[deep].width??screenUtil.getHeight(100));
      deep++;
      for (var k in values.subGroups.keys) {
        children.add(buildGroupRow(k, values.subGroups[k]!, width: nextWidth, deep: deep));
      }
    } else {
      children.addAll(
          values.items.map((e) => buildRow(e, color: widget.formColor)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.1, color: Color(0xE6797979)),
              top: BorderSide(width: 0.1, color: Color(0xE6797979)),
            ),
          ),
          height: screenUtil.adaptive(60),
          padding: EdgeInsets.only(left: width),
          width: maxWidth,
          child: GestureDetector(
            onTap: () {
              if (hashCodeList.contains(values.hashCode)) {
                hashCodeList
                    .removeWhere((element) => element == values.hashCode);
              } else {
                hashCodeList.add(values.hashCode);
              }
              setState(() {});
            },
            child: Row(
              children: [
                hashCodeList.contains(values.hashCode)
                    ? const Icon(
                        Icons.remove,
                        size: 18,
                      )
                    : const Icon(
                        Icons.add,
                        size: 18,
                      ),
                Text(
                  key,
                ),
              ],
            ),
          ),
        ),
        if (hashCodeList.contains(values.hashCode))
          Column(
            children: children,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (mapValues.subGroups.isNotEmpty == true) {
      for (var k in mapValues.subGroups.keys) {
        children.add(buildGroupRow(k, mapValues.subGroups[k]!));
      }
    } else {
      children.addAll(values.map((e) => buildRow(e, color: widget.formColor)));
    }

    return StreamBuilder<List<FormColumn<T>>>(
      stream: controller.stream,
      initialData: columns,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RepaintBoundary(
          child: Scrollbar(
            controller: hController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: hController,
              child: SizedBox(
                height: widget.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitleRow(snapshot.data as List<FormColumn<T>>),
                    Expanded(
                      child: Scrollbar(
                        controller: vController,
                        child: SingleChildScrollView(
                          controller: vController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: children,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

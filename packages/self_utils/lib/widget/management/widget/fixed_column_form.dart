part of 'common_form.dart';

/// 固定前几列的Form表格
///
class FixedColumnForm<T> extends StatefulWidget {
  final int fixedColumn;
  final List<FormColumn<T>> columns;
  final List<T> values;
  final Color? titleColor;
  final bool showExtra;
  final bool canDrag;
  final TapCallBack<T>? onTapFunc; //点击回调
  final DragCallBack<T>? onDragFunc; //拖拽后的回调
  final double? height;
  final Color? formColor;
  final bool showSelectItem;

  final RightMenuFunc? rightMenuFunc; // 鼠标右键方法

  const FixedColumnForm(
      {Key? key,
        required this.values,
        required this.columns,
        this.onDragFunc,
        this.onTapFunc,
        required this.fixedColumn,
        this.titleColor,
        this.canDrag = false,
        this.height,
        this.showExtra = false,
        this.rightMenuFunc,
        this.showSelectItem = false,
        this.formColor})
      : super(key: key);

  @override
  State<FixedColumnForm<T>> createState() => FixedColumnFormState<T>();
}

/// 1 拆分list
class FixedColumnFormState<T> extends State<FixedColumnForm<T>> {
  ScrollController hController = ScrollController();
  ScrollController barController = ScrollController();
  ScrollController tController = ScrollController();

  List<FormColumn<T>> allList = [];
  List<FormColumn<T>> fixedList = [];
  List<FormColumn<T>> normalList = [];

  final StreamController<List<FormColumn<T>>> controller =
  StreamController<List<FormColumn<T>>>();

  double fixedWidth = 0;

  bool shouldReact = false;
  int onSelectHash = -1;

  /// 拖拽锁
  final self_lock.Lock _lock = self_lock.Lock();
  String side = 'right';

  @override
  void initState() {
    super.initState();
    init();
    // addListenScroll();
  }

  void addListenScroll() {
    hController.addListener(() {
      tController.jumpTo(hController.offset);
    });
    // tController.addListener(() {
    //   hController.jumpTo(tController.offset);
    // });
    setState(() {});
  }

  /// 设置固定区域的宽度
  void setWidth() {
    if (fixedList.isNotEmpty) {
      double width = 0;
      fixedList.map((e) => width += e.width ?? FormSetting.width).toList();
      fixedWidth = width;
    }
  }

  Future<void> init() async {
    if (widget.columns.isNotEmpty && widget.fixedColumn > 0) {
      allList = widget.columns;
      fixedList = allList.sublist(0, widget.fixedColumn);
      normalList = allList.sublist(widget.fixedColumn, allList.length);
      setWidth();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FixedColumnForm<T> oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      init();
      setState(() {
        controller.sink.add(normalList);
      });
    }
  }

  /// 表格title
  Widget buildTitleRow(List<FormColumn<T>> formList, {bool canDrag = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: canDrag
          ? formList
          .map((e) => LongPressDraggable(
          data: e,
          delay: const Duration(milliseconds: 300),
          feedback: WrapWidget(
              width: e.width, color: widget.titleColor, child: e.title),
          child: DragTarget<FormColumn<T>>(
            onAccept: (data) {
              final index = allList.indexOf(e);
              setState(() {
                allList.remove(data);
                allList.insert(index, data);
                normalList =
                    allList.sublist(widget.fixedColumn, allList.length);
                controller.sink.add(normalList);
              });
            },
            builder: (context, data, rejects) {
              return WrapWidget(
                  width: e.width,
                  color: widget.titleColor,
                  child: e.title);
            },
          )))
          .toList(growable: false)
          : formList
          .map(
            (e) => WrapWidget(
            width: e.width, color: widget.titleColor, child: e.title),
      )
          .toList(growable: false),
    );
  }

  ///实现table的每一行
  Widget buildRow(
      {required List<FormColumn<T>> formList, required T value, Color? color}) {
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
              ?.call(selectedItem, widget.values.indexOf(value));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: color),
        child: GestureDetector(
          onTap: () {
            if (onSelectHash != value.hashCode) {
              onSelectHash = value.hashCode ?? -1;
            } else {
              onSelectHash = -1;
            }
            if (!_lock.isUsing()) {
              widget.onTapFunc?.call(value);
            }
            setState(() {});
          },
          child: Row(
            children: formList
                .map((e) => WrapWidget(
                color: value.hashCode == onSelectHash
                    ? Colors.blue.shade50
                    : e.color?.call(value),
                width: e.width,
                child: e.builder(context, value)))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  ///可拖拽
  Widget buildDragRow(
      {required List<FormColumn<T>> formList, required int index}) {
    return LongPressDraggable(
      data: index,
      delay: const Duration(milliseconds: 200),
      feedback: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 0.4, color: Colors.red.shade50),
            color: Colors.red.shade50),
        child: buildRow(
            formList: allList,
            value: ArrayHelper.get(widget.values, index) as T),
      ),
      child: DragTarget<int>(
        onAccept: (data) {
          final temp = widget.values[data];
          setState(() {
            widget.values.remove(temp);
            widget.values.insert(index, temp);
          });
          widget.onDragFunc?.call(temp, index);
        },
        //绘制widget
        builder: (context, data, rejects) {
          return buildRow(
              formList: formList,
              value: ArrayHelper.get(widget.values, index)!,
              color: widget.formColor);
        },
      ),
      onDragStarted: () {
        _lock.lock();
      },
      onDragCompleted: () {
        _lock.unlock();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> fixedChild = <Widget>[];
    final List<Widget> normalChild = <Widget>[];
    if (widget.canDrag == true) {
      for (int x = 0; x < widget.values.length; x++) {
        fixedChild.add(buildDragRow(formList: fixedList, index: x));
        normalChild.add(buildDragRow(formList: normalList, index: x));
      }
    } else {
      fixedChild.addAll(widget.values.map((e) =>
          buildRow(formList: fixedList, value: e, color: widget.formColor)));
      normalChild.addAll(widget.values.map((e) =>
          buildRow(formList: normalList, value: e, color: widget.formColor)));
    }
    if (widget.showExtra == true) {
      fixedChild.add(ExtraRow<T>(
        color: widget.formColor,
        columns: fixedList,
      ));
      normalChild.add(ExtraRow<T>(
        color: widget.formColor,
        columns: normalList,
      ));
    }
    return StreamBuilder<List<FormColumn<T>>>(
      stream: controller.stream,
      initialData: normalList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return RepaintBoundary(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: widget.height,
            child: Row(
              children: [
                Listener(
                  onPointerHover: (details) {
                    side = 'left';
                    setState(() {});
                  },
                  child: SizedBox(
                    width: fixedWidth,
                    child: Column(
                      children: [
                        buildTitleRow(fixedList),
                        Expanded(
                            child: ScrollConfiguration(
                              behavior: MyCustomScrollBehavior(),
                              child: NotificationListener(
                                onNotification: (ScrollNotification notification) {
                                  if (side == 'left') {
                                    hController.jumpTo(
                                      notification.metrics.pixels,
                                    );
                                  }
                                  return true;
                                },
                                child: SingleChildScrollView(
                                  controller: tController,
                                  child: Column(
                                    children: fixedChild,
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Listener(
                    onPointerHover: (details) {
                      side = 'right';
                      setState(() {});
                    },
                    child: Scrollbar(
                      controller: barController,
                      child: SingleChildScrollView(
                        controller: barController,
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            buildTitleRow(normalList, canDrag: widget.canDrag),
                            Expanded(
                              child: NotificationListener(
                                onNotification:
                                    (ScrollNotification notification) {
                                  if (side == 'right') {
                                    tController.jumpTo(
                                      notification.metrics.pixels,
                                    );
                                  }
                                  return true;
                                },
                                child: SingleChildScrollView(
                                  controller: hController,
                                  child: Column(
                                    children: normalChild,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

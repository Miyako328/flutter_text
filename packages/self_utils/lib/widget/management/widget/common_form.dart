import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/global/utils_global.dart';
import 'package:self_utils/global/setting.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:native_context_menu/native_context_menu.dart' as native;
import 'package:self_utils/utils/lock.dart' as self_lock;
import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/management/common/function_util.dart';

part 'form_utils/_child_row.dart';

part 'form_utils/form_widget.dart';

part 'form_utils/_row_widget.dart';

part 'fixed_column_form.dart';

part 'group_common_form.dart';

/// 排序方法
enum SortType {
  reverse,
  order,
  normal,
}

extension SortTxt on SortType {
  String get enumToString {
    switch (this) {
      case SortType.order:
        return '顺序';
      case SortType.reverse:
        return '逆序';
      case SortType.normal:
        return '正常';
    }
  }
}

/// 点击的回调方法[onTapFunc]
///
///
/// 拖拽的回调方法[onDragFunc]，按需选择是否实现
/// [value]当前的值，[index]拖拽到当前位置的索引
///
/// 鼠标右键的回调方法[onMouseEvent]
/// [event]获取鼠标位置 [index]获取当前点击的索引
/// Future<void> onMouseEvent(PointerDownEvent event, int index) async {
///        Log.info(event);
///        Log.info(index);
///  }
///
///
/// 额外功能：
/// 1. 固定前几列，只滑动后面的区域
/// 2. 分组表格 <T, D>，两泛型实现

class CommonForm<T, D> extends StatefulWidget {
  final List<FormColumn<T>> columns;
  final List<FormChildColumn<D>>? childWidget;
  final List<T> values;
  final List<D> Function(T value)? childValues;
  final bool canDrag;
  final bool showExtra;
  final TapCallBack<T?>? onTapFunc; //点击回调
  final DragCallBack<T>? onDragFunc; //拖拽后的回调
  final DragTitleCallBack<T>? onDragTitleFunc; //拖拽表格标题后的回调
  final double? height;
  final Color? titleColor;
  final Color? formColor;

  /// 选中反馈
  final bool showSelectItem;

  final RightMenuFunc? rightMenuFunc; // 鼠标右键方法

  const CommonForm(
      {Key? key,
        required this.columns,
        required this.values,
        this.childValues,
        this.canDrag = false,
        this.showExtra = false,
        this.onDragFunc,
        this.onDragTitleFunc,
        this.childWidget,
        this.onTapFunc,
        this.titleColor,
        this.rightMenuFunc,
        this.formColor,
        this.showSelectItem = false,
        this.height})
      : super(key: key);

  @override
  _CommonFormState<T, D> createState() => _CommonFormState<T, D>();
}

///
/// 通过[StreamBuilder]和[StreamController]实现列的拖拽。
/// 每一次拖拽触发一次[StreamController.sink]，
/// 并通过widget生态的[didUpdateWidget]进行更新，使用[RepaintBoundary]优化组件
///

class _CommonFormState<T, D> extends State<CommonForm<T, D>>
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

  /// 拖拽锁
  final self_lock.Lock _lock = self_lock.Lock();

  /// 子表
  bool isShowChild = false;

  /// 排序
  SortType sortType = SortType.normal;
  FormColumn<T>? sortE;
  String sortName = '';

  @override
  void initState() {
    super.initState();
    columns = widget.columns;
    values.clear();
    values.addAll(widget.values);
    if (sortE != null) {
      changeSort(sortE!);
    }
    WidgetsBinding.instance.addObserver(this);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant CommonForm<T, D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      columns = widget.columns;
      values = widget.values;
      if (sortE != null) {
        changeSort(sortE!);
      }
      controller.sink.add(columns);
      setState(() {});
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
          .map((e) => LongPressDraggable(
          data: e,
          delay: const Duration(milliseconds: 300),
          feedback: WrapWidget(
              width: e.width, color: widget.titleColor, child: e.title),
          child: DragTarget<FormColumn<T>>(
            onAccept: (data) {
              final index = columns.indexOf(e);
              setState(() {
                columns.remove(data);
                columns.insert(index, data);
                controller.sink.add(columns);
              });
              widget.onDragTitleFunc?.call(columns);
            },
            builder: (context, data, rejects) {
              return GestureDetector(
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
                    values.sort(
                            (a, b) => e.comparator!(1, a, b));
                    sortName = '${e.comparator.hashCode}';
                  } else if (sortType == SortType.order &&
                      sortName ==
                          '${e.comparator.hashCode}') {
                    sortType = SortType.reverse;
                    values.sort(
                            (a, b) => e.comparator!(0, a, b));
                  } else {
                    sortType = SortType.normal;
                    sortName = '';
                    sortE = null;
                    values.clear();
                    values.addAll(widget.values);
                  }
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
                            sortName != '${e.comparator.hashCode}')
                            ? Container()
                            : (sortType == SortType.order &&
                            sortName ==
                                '${e.comparator.hashCode}')
                            ? const Icon(
                            Icons.arrow_drop_down_outlined)
                            : const Icon(Icons.arrow_drop_up),
                      ],
                    )),
              );
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

  ///可拖拽
  Widget buildDragRow(int index) {
    return LongPressDraggable(
      data: index,
      delay: const Duration(milliseconds: 200),
      feedback: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 0.4, color: Colors.red.shade50),
            color: Colors.red.shade50),
        child: buildRow(ArrayHelper.get(values, index) as T),
      ),
      child: DragTarget<int>(
        onAccept: (data) {
          final temp = values[data];
          setState(() {
            values.remove(temp);
            values.insert(index, temp);
          });
          widget.onDragFunc?.call(temp, index);
        },
        //绘制widget
        builder: (context, data, rejects) {
          return buildRow(ArrayHelper.get(values, index)!,
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

  ///实现table的每一行
  Widget buildRow(T value, {Color? color}) {
    List<D> childValues = [];
    if (widget.childValues != null) {
      childValues = widget.childValues!.call(value);
    }
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
      child: RepaintBoundary(
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
              color: value.hashCode == onSelectHash || value.hashCode == onHoverHash ? Colors.blue.shade50 : color,
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
                if (childValues.isNotEmpty && widget.childWidget != null) {
                  if (!hashcodes.contains(value.hashCode)) {
                    hashcodes.add(value.hashCode);
                  } else {
                    hashcodes.remove(value.hashCode);
                  }
                }
                setState(() {});
              },
              child: widget.childWidget != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: widget.columns
                        .map((e) => WrapWidget(
                        color: e.color?.call(value),
                        width: e.width,
                        child: widget.columns.indexOf(e) == 0
                            ? Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            hashcodes.contains(value.hashCode)
                                ? const Icon(
                              Icons.remove,
                              size: 14,
                              color: Color(0xe5999999),
                            )
                                : const Icon(
                              Icons.add_box_outlined,
                              size: 14,
                              color: Color(0xe5999999),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            e.builder(context, value),
                          ],
                        )
                            : e.builder(context, value)))
                        .toList(growable: false),
                  ),
                  if (hashcodes.contains(value.hashCode))
                    _ChildWidget<D>(
                      key: Key(value.hashCode.toString()),
                      children: widget.childWidget!,
                      values: childValues,
                    ),
                ],
              )
                  : Row(
                children: widget.columns
                    .map((e) => WrapWidget(
                    color: e.color?.call(value),
                    width: e.width,
                    child: e.builder(context, value)))
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (widget.canDrag == true) {
      for (int x = 0; x < values.length; x++) {
        children.add(buildDragRow(x));
      }
    } else {
      children.addAll(values.map((e) => buildRow(e, color: widget.formColor)));
    }
    if (widget.showExtra == true) {
      children.add(ExtraRow<T>(
        color: widget.formColor,
        columns: widget.columns,
      ));
    }

    return StreamBuilder<List<FormColumn<T>>>(
      stream: controller.stream,
      initialData: columns,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return widget.height != null
            ? RepaintBoundary(
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
        )
            : RepaintBoundary(
          child: Scrollbar(
            controller: hController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: hController,
              child: Column(
                children: [
                  buildTitleRow(snapshot.data as List<FormColumn<T>>),
                  Scrollbar(
                    controller: vController,
                    child: SingleChildScrollView(
                      controller: vController,
                      child: Column(
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RightMenuFunc {
  List<native.MenuItem>? menuItems;
  void Function(native.MenuItem item, int index)? onItemSelected;

  RightMenuFunc({this.menuItems, this.onItemSelected});
}

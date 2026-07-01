import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/log_utils.dart';
import 'package:self_utils/utils/screen.dart';


typedef CanLoadMore = Future<RefreshEnum> Function(BuildContext ctx);
typedef RefreshFunc = Future<void> Function(BuildContext ctx);
typedef LoadMoreFunc = Future<void> Function(BuildContext ctx);
typedef FirstFunc = Future<void> Function(BuildContext ctx);

enum RefreshEnum { noMore, needMore }

class Refresh extends StatefulWidget {
  final CanLoadMore? canLoadMore;

  final RefreshFunc? refreshFunc;

  final LoadMoreFunc? loadMoreFunc;

  final FirstFunc? firstFunc;

  final Widget child;

  const Refresh({
    required this.child,
    Key? key,
    this.canLoadMore,
    this.refreshFunc,
    this.loadMoreFunc,
    this.firstFunc,
  })  : assert(refreshFunc != null || loadMoreFunc != null,
  'refreshFunc和loadMoreFunc至少有一个'),
        super(key: key);

  @override
  _RefreshState createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  AsyncMemoizer asyncMemoizer = AsyncMemoizer();
  bool handleLoadMoreing = false;


  @override
  Widget build(BuildContext context) {
    Widget w = widget.child;
    if (widget.refreshFunc != null) {
      w = RefreshIndicator(
        //下拉的高度
          displacement: screenUtil.adaptive(250),
          //转动箭头的大小
          strokeWidth: screenUtil.adaptive(5),
          color: const Color(0xff666666),
          backgroundColor: const Color(0xb3f2f2f2),
          child: w, onRefresh: () => widget.refreshFunc!(context));
    }
    if (widget.loadMoreFunc != null) {
      w = NotificationListener<ScrollNotification>(
        child: w,
        onNotification: (ScrollNotification notification) {
          //表示列表全部内容高度的总和都没有超过viewport的高度
          if (notification.metrics.minScrollExtent == 0 &&
              notification.metrics.maxScrollExtent == 0) return false;

          //表示在边缘
          if (notification.metrics.extentAfter == 0 && !handleLoadMoreing) {
            handleLoadMoreing = true;
            Log.info('handleLoadMoreing');
                () async {
              try{
                final refreshEnum = await widget.canLoadMore?.call(context);
                if (refreshEnum == null || refreshEnum == RefreshEnum.needMore) {
                  Log.info('需要加载更多');
                  if (mounted) {
                    await widget.loadMoreFunc!(context);
                  }
                  Log.info('加载更多完成');
                } else {
                  Log.info('没调用加载更多方法');
                }
              }finally{
                handleLoadMoreing = false;
              }
            }();
          }

          return false;
        },
      );
    }
    if (widget.firstFunc != null) {
      return FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  Future(() {
                    //必须异步抛出异常
                    throw snapshot.error!;
                  });

                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          asyncMemoizer = AsyncMemoizer();
                        });
                      },
                      child: Text(
                        '出错啦点击我重试',
                        style: TextStyle(
                          color: const Color(0xff666666),
                          fontSize: screenUtil.getAutoSp(42),
                        ),
                      ),
                    ),
                  );
                }
                return w;
              case ConnectionState.waiting:
                return const Align(
                  alignment: Alignment(0.0, -0.75),
                  child: RefreshProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                  ),
                );
                break;
              default:
                return Container();
            }
          },
          future: asyncMemoizer.runOnce(() => widget.firstFunc!(context)));
    } else {
      return w;
    }
  }
}

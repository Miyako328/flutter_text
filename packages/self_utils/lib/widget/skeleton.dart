import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

/// SchedulerBinding 任务调度器

enum SkeletonStatus { waitLoad, cache, loadDone }

class SkeletonManager<T> {
  final Future<void> Function(List<T> source) load;
  final Duration delay;
  final bool hideSocketException;

  SkeletonManager(this.load, {this.delay = const Duration(milliseconds: 500),this.hideSocketException=true});

  final Set<T> _sourceList = <T>{};

  bool _handle = false;

  bool _isRelease = false;

  bool _isFirst = true;


  int _version = 0;

  Future<void>? doing;

  void release() {
    _isRelease = true;
  }

  void _addSource(T source) {
    _sourceList.add(source);
    _version++;
    int oldVersion = _version;
    if(_isFirst){
      /// Frame完成之后的回调方法
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _tryLoad();
      });
      /// 更新
      SchedulerBinding.instance.ensureVisualUpdate();
      _isFirst=false;
      return;
    }
    if (doing == null) {
      Future<void> _f() {
        return Future<void>.delayed(delay, () async {
          if (oldVersion == _version) {
            try{
              await _tryLoad();
            }finally{
              doing=null;
            }
          } else {
            if(_isRelease){
              return;
            }
            oldVersion=_version;
            _f();
          }
        });
      }
      doing = _f();
    }
  }


  void _removeSource(T source) {
    _sourceList.remove(source);
  }

  Future<void> _tryLoad() async {
    if (_isRelease) {
      return;
    }
    if (_handle) {
      return;
    }
    if (_sourceList.isEmpty) {
      return;
    }
    _handle = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        if (_sourceList.isEmpty) {
          return;
        }
        await _doLoad();
      } catch (e, s) {
        if (e is SocketException) {
          //网络问题,2秒后重试
          Future<void>.delayed(const Duration(seconds: 2), () {
            _tryLoad();
          });
        }
        if(hideSocketException){
        }else{
          rethrow;
        }
      } finally {
        _handle = false;
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  Future<void> _doLoad() async {
    assert(_sourceList.isNotEmpty);
    await load(_sourceList.toList());
    await SchedulerBinding.instance.endOfFrame;
  }
}

class SkeletonItem<T> extends StatefulWidget {
  final SkeletonStatus status;

  final T source;

  //如果status==[SkeletonStatus.waitLoad] 将会使用skeleton进行显示
  final WidgetBuilder skeleton;

  final WidgetBuilder child;

  final SkeletonManager<T> skeletonManager;

  const SkeletonItem({
    required this.child,
    required this.skeleton,
    required this.source,
    required this.status,
    required this.skeletonManager,
    Key? key,
  }) : super(key: key);

  @override
  _SkeletonItemState createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<SkeletonItem> {
  bool get needLoad => widget.status != SkeletonStatus.loadDone;

  @override
  void initState() {
    super.initState();
    if (needLoad) {
      widget.skeletonManager._addSource(widget.source);
    }
  }

  @override
  void didUpdateWidget(SkeletonItem oldWidget) {
    if (oldWidget.status != SkeletonStatus.loadDone) {
      oldWidget.skeletonManager._removeSource(oldWidget.source);
    }
    if (widget.status != SkeletonStatus.loadDone) {
      widget.skeletonManager._addSource(widget.source);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    if (needLoad) {
      widget.skeletonManager._removeSource(widget.source);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == SkeletonStatus.waitLoad) {
      return widget.skeleton(context);
    } else {
      return widget.child(context);
    }
  }
}

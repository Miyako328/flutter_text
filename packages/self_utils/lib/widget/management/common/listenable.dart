

import 'dart:collection';

import 'package:flutter/material.dart';

/// [LinkedListEntry]是flutter里的一个抽象基类 用于表示双向链表中的元素。
/// 所有链表元素都必须扩展此类，
/// 该类提供了将元素链接在一起的内部链接以及当前元素所属链接列表的引用。

final class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  final T listener;

  _ListenerEntry(this.listener);
}

mixin class GenericListenable<T>  {
  final LinkedList<_ListenerEntry<T>> _list = LinkedList<_ListenerEntry<T>>();


  bool hasListener(){
    return _list.isNotEmpty;
  }

  void addListener(T listener) {
    _list.add(_ListenerEntry<T>(listener));
  }

  void removeListener(T listener) {
    for (final _ListenerEntry<T> entry in _list) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  void foreach(void Function(T entry) action){
    final List<_ListenerEntry<T>> copy = List<_ListenerEntry<T>>.from(_list);
    copy.forEach((entry) {
      action(entry.listener);
    });
  }
}


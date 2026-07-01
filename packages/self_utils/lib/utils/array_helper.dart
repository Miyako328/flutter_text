import 'package:flutter/material.dart';

//数组有关的方法
class ArrayHelper {
  static T? get<T>(List<T>? list, int index) {
    if (list != null && list.isNotEmpty == true) {
      return list[index];
    } else {
      return null;
    }
  }

  static List<int> uniqueInt(List<int> list) {
    return unique<int>(listData: list, getKey: (int item) => item);
  }

  /// 对比两个数组
  /// [1, 2, 3] 和 [2, 3] 或者 [1, 2, 3] 和 [2, 3, 1]
  static bool containList<T>(List<T> first, List<T> sec) {
    if (first.length == sec.first && identical(first, sec)) {
      return true;
    }
    List<T> long = first.length > sec.length ? first : sec;
    List<T> short = first.length > sec.length ? sec : first;
    for (T key in short) {
      if (!long.contains(key)) {
        return false;
      }
    }
    return true;
  }

  //去重_泛型
  static List<T> unique<T>(
      {required List<T> listData, required dynamic Function(T value) getKey}) {
    if (listData.isNotEmpty == true) {
      final Map<dynamic, List<T>> maps = {
        for (var e in listData)
          getKey(e): listData
              .where((T element) => getKey(element) == getKey(e))
              .toList()
      };
      final List<T> list = maps.values.map((List<T> e) => e.first).toList();
      return list..removeWhere((T? element) => element == null);
    } else {
      return <T>[];
    }
  }

  /// 判断数组是否相同
  static bool listIsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length == list2.length) {
      for (var element in list1) {
        if (list2.contains(element) &&
            list1.indexOf(element) == list2.indexOf(element)) {
        } else {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  /// 分组
  static List<List<T>> groupBy<T>(
      {required List<T> list, required dynamic Function(T value) getKey}) {
    if (list.isNotEmpty) {
      final List<List<T>> result = [];
      final Map<dynamic, List<T>> maps = {
        for (var e in list)
          getKey(e):
              list.where((T element) => getKey(element) == getKey(e)).toList()
      };
      result.addAll(maps.values);
      return result;
    } else {
      return [];
    }
  }

  // 数组降维
  static List<T> flatten<T>(List<dynamic> list) {
    List<T> result = [];
    for (var item in list) {
      if (item is List) {
        result.addAll(flatten(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// 多重分组
  static GroupingResult<T> groupByMultiple<T>(
    List<T> items,
    List<Function(T)> groupByFunctions,
  ) {
    final root = GroupingResult<T>();

    for (var item in items) {
      var currentGroup = root;
      for (var groupByFunction in groupByFunctions) {
        final groupKey = groupByFunction(item);
        currentGroup.subGroups[groupKey] ??= GroupingResult<T>();
        currentGroup = currentGroup.subGroups[groupKey]!;
      }
      currentGroup.items.add(item);
    }

    return root;
  }
}

class GroupingResult<T> {
  final Map<dynamic, GroupingResult<T>> subGroups;
  final List<T> items;

  GroupingResult()
      : subGroups = {},
        items = [];
}

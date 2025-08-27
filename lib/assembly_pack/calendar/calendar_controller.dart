import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

enum EventType {
  normal,
  finish,
  expire,
}

extension EventTypeTxt on EventType {
  String get enumToString {
    switch (this) {
      case EventType.normal:
        return 'normal';
      case EventType.finish:
        return 'finish';
      case EventType.expire:
        return 'expire';
    }
  }
}

extension EventTypeEunm on String {
  EventType? get stringToEnum {
    switch (this) {
      case 'normal':
        return EventType.normal;
      case 'finish':
        return EventType.finish;
      case 'expire':
        return EventType.expire;
    }
    return null;
  }
}

class Event {
  int id;
  String title;
  String desc; //内容
  String time;
  String type;

  Event(this.id, this.title, this.time, this.desc, this.type);

  String getTitle() => title;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        json['id'] as int,
        json['title'] as String,
        json['time'] as String,
        json['desc'] as String,
        json['type'] as String,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['desc'] = desc;
    data['time'] = time;
    data['type'] = type;
    return data;
  }

  static List<Event> listFromJson(List<dynamic>? json) {
    return json == null
        ? <Event>[]
        : json.map((e) => Event.fromJson(e)).toList();
  }
}

class CalendarController extends GetxController {
  Rx<DateTime> focusedDay = DateTime.now().obs;
  Rx<DateTime?> selectedDay = Rx<DateTime?>(null);
  Rx<DateTime?> rangeStart = Rx<DateTime?>(null);
  Rx<DateTime?> rangeEnd = Rx<DateTime?>(null);
  Rx<RangeSelectionMode> rangeSelectionMode = RangeSelectionMode.toggledOff.obs;
  RxList<Event> selectedEvents = <Event>[].obs;
  RxBool isLoading = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  
  final List<Event> allEvents = <Event>[].obs;
  static const String key = 'calendar';
  
  @override
  void onInit() {
    super.onInit();
    selectedDay.value = focusedDay.value;
    _loadEvents();
    _updateSelectedEvents();
  }
  
  void _loadEvents() {
    try {
      isLoading.value = true;
      statusMessage.value = '正在加载事件...';
      
      // 模拟从存储加载事件
      _loadEventsFromStorage();
      
      statusMessage.value = '事件加载完成';
    } catch (e) {
      statusMessage.value = '事件加载失败: $e';
      print('Load events error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _loadEventsFromStorage() {
    // 模拟从本地存储加载事件
    final mockEvents = [
      Event(1, '会议', DateFormat('yyyy-MM-dd').format(DateTime.now()), '项目讨论会议', 'normal'),
      Event(2, '完成报告', DateFormat('yyyy-MM-dd').format(DateTime.now()), '季度报告完成', 'finish'),
      Event(3, '过期任务', DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 1))), '已过期的任务', 'expire'),
    ];
    
    allEvents.clear();
    allEvents.addAll(mockEvents);
  }
  
  void _updateSelectedEvents() {
    if (selectedDay.value != null) {
      selectedEvents.value = _getEventsForDay(selectedDay.value!);
    }
  }
  
  List<Event> _getEventsForDay(DateTime day) {
    List<Event> res = allEvents.where((e) => e.time == DateFormat('yyyy-MM-dd').format(day)).toList();
    res.sort((a, b) => b.type.compareTo(a.type));
    return res;
  }
  
  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }
  
  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    List<Event> events = [];
    
    for (final DateTime d in days) {
      events.addAll(_getEventsForDay(d));
    }
    
    return events;
  }
  
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_isSameDay(this.selectedDay.value, selectedDay)) {
      this.selectedDay.value = selectedDay;
      this.focusedDay.value = focusedDay;
      rangeStart.value = null;
      rangeEnd.value = null;
      rangeSelectionMode.value = RangeSelectionMode.toggledOff;
      
      selectedEvents.value = _getEventsForDay(selectedDay);
      statusMessage.value = '已选择日期: ${DateFormat('yyyy-MM-dd').format(selectedDay)}';
    }
  }
  
  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    selectedDay.value = null;
    this.focusedDay.value = focusedDay;
    rangeStart.value = start;
    rangeEnd.value = end;
    rangeSelectionMode.value = RangeSelectionMode.toggledOn;
    
    if (start != null && end != null) {
      selectedEvents.value = _getEventsForRange(start, end);
      statusMessage.value = '已选择范围: ${DateFormat('yyyy-MM-dd').format(start)} 到 ${DateFormat('yyyy-MM-dd').format(end)}';
    } else if (start != null) {
      selectedEvents.value = _getEventsForDay(start);
      statusMessage.value = '已选择开始日期: ${DateFormat('yyyy-MM-dd').format(start)}';
    } else if (end != null) {
      selectedEvents.value = _getEventsForDay(end);
      statusMessage.value = '已选择结束日期: ${DateFormat('yyyy-MM-dd').format(end)}';
    }
  }
  
  void onPageChanged(DateTime focusedDay) {
    this.focusedDay.value = focusedDay;
  }
  
  void addEvent(Event event) {
    try {
      allEvents.add(event);
      _saveEvents();
      _updateSelectedEvents();
      statusMessage.value = '事件添加成功: ${event.title}';
    } catch (e) {
      statusMessage.value = '事件添加失败: $e';
      print('Add event error: $e');
    }
  }
  
  void deleteEvent(Event event) {
    try {
      allEvents.removeWhere((element) => element.id == event.id);
      _saveEvents();
      _updateSelectedEvents();
      statusMessage.value = '事件删除成功: ${event.title}';
    } catch (e) {
      statusMessage.value = '事件删除失败: $e';
      print('Delete event error: $e');
    }
  }
  
  void updateEvent(Event event) {
    try {
      final index = allEvents.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        allEvents[index] = event;
        _saveEvents();
        _updateSelectedEvents();
        statusMessage.value = '事件更新成功: ${event.title}';
      }
    } catch (e) {
      statusMessage.value = '事件更新失败: $e';
      print('Update event error: $e');
    }
  }
  
  void _saveEvents() {
    try {
      // 模拟保存到本地存储
      final jsonString = jsonEncode(allEvents.map((e) => e.toJson()).toList());
      print('Events saved: $jsonString');
    } catch (e) {
      print('Save events error: $e');
    }
  }
  
  void refreshEvents() {
    _loadEvents();
    _updateSelectedEvents();
  }
  
  void clearSelectedRange() {
    rangeStart.value = null;
    rangeEnd.value = null;
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    _updateSelectedEvents();
    statusMessage.value = '已清除选择范围';
  }
  
  void goToToday() {
    final today = DateTime.now();
    focusedDay.value = today;
    selectedDay.value = today;
    rangeStart.value = null;
    rangeEnd.value = null;
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    _updateSelectedEvents();
    statusMessage.value = '已跳转到今天';
  }
  
  void goToDate(DateTime date) {
    focusedDay.value = date;
    selectedDay.value = date;
    rangeStart.value = null;
    rangeEnd.value = null;
    rangeSelectionMode.value = RangeSelectionMode.toggledOff;
    _updateSelectedEvents();
    statusMessage.value = '已跳转到: ${DateFormat('yyyy-MM-dd').format(date)}';
  }
  
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  bool get hasSelectedDay => selectedDay.value != null;
  bool get hasSelectedRange => rangeStart.value != null && rangeEnd.value != null;
  bool get isRangeSelectionMode => rangeSelectionMode.value == RangeSelectionMode.toggledOn;
  String get selectedDayText => selectedDay.value != null ? DateFormat('yyyy-MM-dd').format(selectedDay.value!) : '未选择';
  String get rangeText {
    if (rangeStart.value != null && rangeEnd.value != null) {
      return '${DateFormat('yyyy-MM-dd').format(rangeStart.value!)} 到 ${DateFormat('yyyy-MM-dd').format(rangeEnd.value!)}';
    }
    return '未选择范围';
  }
  int get totalEvents => allEvents.length;
  int get selectedEventsCount => selectedEvents.length;
  bool get hasEvents => allEvents.isNotEmpty;
  bool get hasSelectedEvents => selectedEvents.isNotEmpty;
}

// 为了兼容性，保留原有的EventHelper类
class EventHelper {
  static List<Event> event = [];
  static String key = 'calendar';

  static List<Event> getEvents(DateTime time) {
    final List<Event> res = _getAllEvents();
    event = res;
    return event
        .where(
          (e) => e.time == DateFormat('yyyy-MM-dd').format(time),
        )
        .toList();
  }

  static void setEvents(Event val) {
    event.add(val);
    _setEvents(val);
  }

  static void deleteOneEvent(Event val) {
    final List<Event> res = _getAllEvents();
    res.removeWhere((Event element) => element.id == val.id);
    event = res;
    // LocateStorage.setString(key, jsonEncode(res)); // 注释掉依赖
  }

  static List<Event> _getAllEvents() {
    // 模拟获取所有事件
    return [];
  }

  static void _setEvents(Event val) {
    // 模拟设置事件
    print('Event set: ${val.title}');
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class SpeedDialController extends GetxController {
  Rx<IconData> currentIcon = Icons.list.obs;
  RxBool isOpen = false.obs;
  RxInt selectedChildIndex = 0.obs;
  RxInt tapCount = 0.obs;
  
  late List<SpeedDialChildData> children;
  
  final List<IconData> availableIcons = [
    Icons.list,
    Icons.menu,
    Icons.add,
    Icons.more_vert,
    Icons.expand_more,
    Icons.keyboard_arrow_up,
    Icons.arrow_upward,
    Icons.arrow_forward,
  ];
  
  @override
  void onInit() {
    super.onInit();
    _initializeChildren();
  }
  
  void _initializeChildren() {
    children = [
      SpeedDialChildData(
        icon: Icons.accessibility,
        backgroundColor: Colors.red,
        label: 'Accessibility',
        onTap: () => _onChildTapped(0),
      ),
      SpeedDialChildData(
        icon: Icons.brush,
        backgroundColor: Colors.orange,
        label: 'Brush',
        onTap: () => _onChildTapped(1),
      ),
      SpeedDialChildData(
        icon: Icons.keyboard_voice,
        backgroundColor: Colors.green,
        label: 'Voice',
        onTap: () => _onChildTapped(2),
      ),
    ];
  }
  
  void _onChildTapped(int index) {
    selectedChildIndex.value = index;
    tapCount.value++;
    print('CHILD ${index + 1} TAPPED - Total taps: ${tapCount.value}');
    
    // 根据选择的子项更新主图标
    currentIcon.value = children[index].icon;
  }
  
  void changeMainIcon(IconData icon) {
    currentIcon.value = icon;
  }
  
  void cycleIcons() {
    final currentIndex = availableIcons.indexOf(currentIcon.value);
    final nextIndex = (currentIndex + 1) % availableIcons.length;
    currentIcon.value = availableIcons[nextIndex];
  }
  
  void addChild(SpeedDialChildData child) {
    children.add(child);
  }
  
  void removeChild(int index) {
    if (index >= 0 && index < children.length) {
      children.removeAt(index);
    }
  }
  
  void updateChild(int index, SpeedDialChildData newChild) {
    if (index >= 0 && index < children.length) {
      children[index] = newChild;
    }
  }
  
  void resetIcon() {
    currentIcon.value = Icons.list;
  }
  
  void resetTapCount() {
    tapCount.value = 0;
  }
  
  void toggleSpeedDial() {
    isOpen.value = !isOpen.value;
  }
  
  SpeedDialChild getSpeedDialChild(SpeedDialChildData data) {
    return SpeedDialChild(
      child: Icon(data.icon),
      backgroundColor: data.backgroundColor,
      label: data.label,
      onTap: data.onTap,
    );
  }
  
  List<SpeedDialChild> get allChildren {
    return children.map((data) => getSpeedDialChild(data)).toList();
  }
  
  int get childCount => children.length;
  bool get hasChildren => children.isNotEmpty;
  String get selectedChildName => children.isNotEmpty && selectedChildIndex.value < children.length 
      ? children[selectedChildIndex.value].label 
      : 'None';
}

class SpeedDialChildData {
  final IconData icon;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;
  
  SpeedDialChildData({
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });
}

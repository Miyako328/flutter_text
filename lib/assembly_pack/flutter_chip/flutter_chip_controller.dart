import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FlutterChipController extends GetxController {
  RxList<ChipData> chips = <ChipData>[].obs;
  RxBool showDeleteIcon = true.obs;
  RxBool showAvatar = false.obs;
  RxString chipText = 'first chip'.obs;
  RxString avatarText = '2'.obs;
  RxString longText = 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis temporibus alias eligendi quas ullam atque numquam repudiandae est minima do'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeChips();
  }
  
  void _initializeChips() {
    chips.value = [
      ChipData(
        label: 'first chip',
        showDeleteIcon: true,
        showAvatar: false,
        avatarText: '',
        onDeleted: () => _onChipDeleted(0),
      ),
      ChipData(
        label: 'chip',
        showDeleteIcon: true,
        showAvatar: true,
        avatarText: '2',
        onDeleted: () => _onChipDeleted(1),
      ),
    ];
  }
  
  void _onChipDeleted(int index) {
    if (index >= 0 && index < chips.length) {
      chips.removeAt(index);
      print('Chip deleted at index: $index');
    }
  }
  
  void addChip(String label, {bool showAvatar = false, String avatarText = ''}) {
    final newChip = ChipData(
      label: label,
      showDeleteIcon: showDeleteIcon.value,
      showAvatar: showAvatar,
      avatarText: avatarText,
      onDeleted: () => _onChipDeleted(chips.length),
    );
    chips.add(newChip);
  }
  
  void removeChip(int index) {
    if (index >= 0 && index < chips.length) {
      chips.removeAt(index);
    }
  }
  
  void updateChipLabel(int index, String newLabel) {
    if (index >= 0 && index < chips.length) {
      final chip = chips[index];
      chips[index] = ChipData(
        label: newLabel,
        showDeleteIcon: chip.showDeleteIcon,
        showAvatar: chip.showAvatar,
        avatarText: chip.avatarText,
        onDeleted: chip.onDeleted,
      );
    }
  }
  
  void toggleDeleteIcon() {
    showDeleteIcon.value = !showDeleteIcon.value;
    // 更新所有chips的删除图标状态
    for (int i = 0; i < chips.length; i++) {
      final chip = chips[i];
      chips[i] = ChipData(
        label: chip.label,
        showDeleteIcon: showDeleteIcon.value,
        showAvatar: chip.showAvatar,
        avatarText: chip.avatarText,
        onDeleted: chip.onDeleted,
      );
    }
  }
  
  void toggleAvatar(int index) {
    if (index >= 0 && index < chips.length) {
      final chip = chips[index];
      chips[index] = ChipData(
        label: chip.label,
        showDeleteIcon: chip.showDeleteIcon,
        showAvatar: !chip.showAvatar,
        avatarText: chip.avatarText,
        onDeleted: chip.onDeleted,
      );
    }
  }
  
  void updateAvatarText(int index, String newText) {
    if (index >= 0 && index < chips.length) {
      final chip = chips[index];
      chips[index] = ChipData(
        label: chip.label,
        showDeleteIcon: chip.showDeleteIcon,
        showAvatar: chip.showAvatar,
        avatarText: newText,
        onDeleted: chip.onDeleted,
      );
    }
  }
  
  void updateLongText(String newText) {
    longText.value = newText;
  }
  
  void resetChips() {
    _initializeChips();
  }
  
  int get chipCount => chips.length;
  bool get hasChips => chips.isNotEmpty;
}

class ChipData {
  final String label;
  final bool showDeleteIcon;
  final bool showAvatar;
  final String avatarText;
  final VoidCallback onDeleted;
  
  ChipData({
    required this.label,
    required this.showDeleteIcon,
    required this.showAvatar,
    required this.avatarText,
    required this.onDeleted,
  });
}

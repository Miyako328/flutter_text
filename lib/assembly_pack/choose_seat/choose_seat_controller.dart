import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChooseSeatController extends GetxController {
  static const int defaultRow = 10;
  static const int defaultColumn = 30;
  
  RxInt rowCount = defaultRow.obs;
  RxInt columnCount = defaultColumn.obs;
  RxDouble currentScale = 0.2.obs;
  RxDouble minScale = 0.1.obs;
  RxDouble maxScale = 2.0.obs;
  
  RxBool isInteractive = true.obs;
  RxBool isZooming = false.obs;
  RxBool isPanning = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  
  Rx<Offset> panOffset = Offset.zero.obs;
  Rx<Matrix4> transformationMatrix = Matrix4.identity().obs;
  
  final List<SeatPosition> selectedSeats = <SeatPosition>[].obs;
  final List<SeatPosition> availableSeats = <SeatPosition>[].obs;
  final List<SeatPosition> occupiedSeats = <SeatPosition>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSeats();
    _setupTransformationController();
  }
  
  void _initializeSeats() {
    try {
      // 初始化座位数据
      availableSeats.clear();
      occupiedSeats.clear();
      selectedSeats.clear();
      
      for (int row = 0; row < rowCount.value; row++) {
        for (int col = 0; col < columnCount.value; col++) {
          final seat = SeatPosition(row: row, column: col);
          availableSeats.add(seat);
        }
      }
      
      // 模拟一些已占用的座位
      _simulateOccupiedSeats();
      
      statusMessage.value = '座位初始化完成';
    } catch (e) {
      statusMessage.value = '座位初始化失败: $e';
      print('Initialize seats error: $e');
    }
  }
  
  void _simulateOccupiedSeats() {
    // 模拟一些已占用的座位
    final random = DateTime.now().millisecondsSinceEpoch;
    final occupiedCount = (random % 20) + 5; // 5-25个已占用座位
    
    for (int i = 0; i < occupiedCount; i++) {
      if (availableSeats.isNotEmpty) {
        final randomIndex = (random + i) % availableSeats.length;
        final seat = availableSeats[randomIndex];
        availableSeats.removeAt(randomIndex);
        occupiedSeats.add(seat);
      }
    }
  }
  
  void _setupTransformationController() {
    transformationMatrix.value = Matrix4.identity()..scale(currentScale.value);
  }
  
  void onScaleStart(ScaleStartDetails details) {
    isZooming.value = true;
    statusMessage.value = '开始缩放';
  }
  
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      currentScale.value = (currentScale.value * details.scale).clamp(minScale.value, maxScale.value);
      transformationMatrix.value = Matrix4.identity()..scale(currentScale.value);
      statusMessage.value = '缩放: ${currentScale.value.toStringAsFixed(2)}';
    }
    
    if (details.focalPointDelta != Offset.zero) {
      panOffset.value += details.focalPointDelta;
      transformationMatrix.value = Matrix4.translationValues(
        panOffset.value.dx,
        panOffset.value.dy,
        0.0,
      )..scale(currentScale.value);
      statusMessage.value = '平移: (${panOffset.value.dx.toStringAsFixed(1)}, ${panOffset.value.dy.toStringAsFixed(1)})';
    }
  }
  
  void onScaleEnd(ScaleEndDetails details) {
    isZooming.value = false;
    statusMessage.value = '缩放结束';
  }
  
  void selectSeat(int row, int column) {
    try {
      final seat = SeatPosition(row: row, column: column);
      
      if (occupiedSeats.any((s) => s.row == row && s.column == column)) {
        statusMessage.value = '该座位已被占用';
        return;
      }
      
      if (selectedSeats.any((s) => s.row == row && s.column == column)) {
        // 取消选择
        selectedSeats.removeWhere((s) => s.row == row && s.column == column);
        statusMessage.value = '已取消选择座位 ($row, $column)';
      } else {
        // 选择座位
        selectedSeats.add(seat);
        statusMessage.value = '已选择座位 ($row, $column)';
      }
    } catch (e) {
      statusMessage.value = '选择座位失败: $e';
      print('Select seat error: $e');
    }
  }
  
  void clearSelection() {
    selectedSeats.clear();
    statusMessage.value = '已清除所有选择';
  }
  
  void confirmSelection() {
    if (selectedSeats.isEmpty) {
      statusMessage.value = '请先选择座位';
      return;
    }
    
    try {
      // 模拟确认选择
      for (final seat in selectedSeats) {
        if (availableSeats.any((s) => s.row == seat.row && s.column == seat.column)) {
          availableSeats.removeWhere((s) => s.row == seat.row && s.column == seat.column);
          occupiedSeats.add(seat);
        }
      }
      
      final selectedCount = selectedSeats.length;
      selectedSeats.clear();
      statusMessage.value = '已确认选择 $selectedCount 个座位';
    } catch (e) {
      statusMessage.value = '确认选择失败: $e';
      print('Confirm selection error: $e');
    }
  }
  
  void resetView() {
    currentScale.value = 0.2;
    panOffset.value = Offset.zero;
    transformationMatrix.value = Matrix4.identity()..scale(currentScale.value);
    statusMessage.value = '视图已重置';
  }
  
  void zoomIn() {
    final newScale = (currentScale.value * 1.2).clamp(minScale.value, maxScale.value);
    currentScale.value = newScale;
    transformationMatrix.value = Matrix4.identity()..scale(newScale);
    statusMessage.value = '放大: ${newScale.toStringAsFixed(2)}';
  }
  
  void zoomOut() {
    final newScale = (currentScale.value / 1.2).clamp(minScale.value, maxScale.value);
    currentScale.value = newScale;
    transformationMatrix.value = Matrix4.identity()..scale(newScale);
    statusMessage.value = '缩小: ${newScale.toStringAsFixed(2)}';
  }
  
  void setRowCount(int count) {
    if (count > 0 && count <= 50) {
      rowCount.value = count;
      _initializeSeats();
      statusMessage.value = '行数已设置为: $count';
    } else {
      statusMessage.value = '行数必须在1-50之间';
    }
  }
  
  void setColumnCount(int count) {
    if (count > 0 && count <= 100) {
      columnCount.value = count;
      _initializeSeats();
      statusMessage.value = '列数已设置为: $count';
    } else {
      statusMessage.value = '列数必须在1-100之间';
    }
  }
  
  void toggleInteractive() {
    isInteractive.value = !isInteractive.value;
    statusMessage.value = isInteractive.value ? '交互模式已启用' : '交互模式已禁用';
  }
  
  bool isSeatAvailable(int row, int column) {
    return availableSeats.any((s) => s.row == row && s.column == column);
  }
  
  bool isSeatOccupied(int row, int column) {
    return occupiedSeats.any((s) => s.row == row && s.column == column);
  }
  
  bool isSeatSelected(int row, int column) {
    return selectedSeats.any((s) => s.row == row && s.column == column);
  }
  
  void refreshSeats() {
    _initializeSeats();
    statusMessage.value = '座位已刷新';
  }
  
  @override
  void onClose() {
    selectedSeats.clear();
    availableSeats.clear();
    occupiedSeats.clear();
    super.onClose();
  }
  
  bool get hasSelectedSeats => selectedSeats.isNotEmpty;
  bool get hasAvailableSeats => availableSeats.isNotEmpty;
  bool get hasOccupiedSeats => occupiedSeats.isNotEmpty;
  int get selectedSeatsCount => selectedSeats.length;
  int get availableSeatsCount => availableSeats.length;
  int get occupiedSeatsCount => occupiedSeats.length;
  int get totalSeats => rowCount.value * columnCount.value;
  String get scaleInfo => '缩放: ${currentScale.value.toStringAsFixed(2)}';
  String get panInfo => '平移: (${panOffset.value.dx.toStringAsFixed(1)}, ${panOffset.value.dy.toStringAsFixed(1)})';
  String get seatsInfo => '总座位: $totalSeats, 可用: $availableSeatsCount, 已占: $occupiedSeatsCount, 已选: $selectedSeatsCount';
}

class SeatPosition {
  final int row;
  final int column;
  
  SeatPosition({required this.row, required this.column});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;
  
  @override
  int get hashCode => row.hashCode ^ column.hashCode;
  
  @override
  String toString() => 'Seat($row, $column)';
}

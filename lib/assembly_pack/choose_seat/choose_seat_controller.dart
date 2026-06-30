import 'package:get/get.dart';

enum SeatSlotType {
  seat,
  aisle,
  empty,
  blocked,
}

enum SeatStatus {
  available,
  occupied,
  selected,
  disabled,
}

class SeatKey {
  const SeatKey({
    required this.row,
    required this.column,
  });

  final int row;
  final int column;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SeatKey && row == other.row && column == other.column;
  }

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => '$row-$column';
}

class SeatSlot {
  const SeatSlot({
    required this.key,
    required this.type,
    required this.label,
  });

  final SeatKey key;
  final SeatSlotType type;
  final String label;

  bool get isSeatShape =>
      type == SeatSlotType.seat || type == SeatSlotType.blocked;

  bool get isSelectable => type == SeatSlotType.seat;
}

class ChooseSeatController extends GetxController {
  static const String layoutId = 'seat_layout';
  static const String selectionId = 'seat_selection';

  ChooseSeatController() {
    ensureLayout();
  }

  final List<List<SeatSlot>> rows = <List<SeatSlot>>[];
  final Map<SeatKey, SeatStatus> _seatStates = <SeatKey, SeatStatus>{};
  final Set<SeatKey> selectedSeats = <SeatKey>{};

  @override
  void onInit() {
    super.onInit();
    ensureLayout();
  }

  void ensureLayout() {
    if (rows.isNotEmpty) {
      return;
    }
    loadLayout(_demoLayout);
    print(
      '[ChooseSeat] layout loaded: rows=$rowCount, columns=$maxColumnCount, seats=$totalSeatCount',
    );
  }

  void loadLayout(List<String> layout) {
    rows
      ..clear()
      ..addAll(_parseLayout(layout));
    selectedSeats.clear();
    _seedSeatStates();
    update(<Object>[layoutId, selectionId]);
  }

  void toggleSeat(SeatSlot slot) {
    if (!slot.isSelectable) {
      return;
    }

    final SeatStatus status = statusOf(slot);
    if (status == SeatStatus.occupied || status == SeatStatus.disabled) {
      return;
    }

    if (selectedSeats.contains(slot.key)) {
      selectedSeats.remove(slot.key);
    } else {
      selectedSeats.add(slot.key);
    }

    update(<Object>[layoutId, selectionId]);
  }

  SeatStatus statusOf(SeatSlot slot) {
    if (selectedSeats.contains(slot.key)) {
      return SeatStatus.selected;
    }
    if (slot.type == SeatSlotType.blocked) {
      return SeatStatus.disabled;
    }
    return _seatStates[slot.key] ?? SeatStatus.available;
  }

  String rowLabel(int rowIndex) {
    return String.fromCharCode('A'.codeUnitAt(0) + rowIndex);
  }

  String columnLabel(int columnIndex) {
    return '${columnIndex + 1}';
  }

  int get rowCount => rows.length;

  int get maxColumnCount {
    if (rows.isEmpty) {
      return 0;
    }
    return rows.map((List<SeatSlot> row) => row.length).reduce(
          (int value, int element) => value > element ? value : element,
        );
  }

  int get selectedCount => selectedSeats.length;

  int get totalSeatCount {
    return rows.fold<int>(
      0,
      (int count, List<SeatSlot> row) =>
          count + row.where((SeatSlot slot) => slot.isSelectable).length,
    );
  }

  List<List<SeatSlot>> _parseLayout(List<String> layout) {
    return <List<SeatSlot>>[
      for (int row = 0; row < layout.length; row += 1)
        <SeatSlot>[
          for (int column = 0; column < layout[row].length; column += 1)
            SeatSlot(
              key: SeatKey(row: row, column: column),
              type: _typeForCode(layout[row][column]),
              label: '${rowLabel(row)}${column + 1}',
            ),
        ],
    ];
  }

  SeatSlotType _typeForCode(String code) {
    switch (code) {
      case 'S':
        return SeatSlotType.seat;
      case '_':
        return SeatSlotType.aisle;
      case 'X':
        return SeatSlotType.blocked;
      case '.':
      default:
        return SeatSlotType.empty;
    }
  }

  void _seedSeatStates() {
    _seatStates.clear();

    for (final List<SeatSlot> row in rows) {
      for (final SeatSlot slot in row) {
        if (!slot.isSelectable) {
          continue;
        }

        if (_demoOccupiedSeats.contains(slot.key)) {
          _seatStates[slot.key] = SeatStatus.occupied;
        }
      }
    }
  }

  static const List<String> _demoLayout = <String>[
    '....SSSSSSSSSSSSSSSS....',
    '..SSSSSSSSSSSSSSSSSSSS..',
    '.SSSSSSSSSS__SSSSSSSSSS.',
    'SSSSSSSSSSS__SSSSSSSSSSS',
    'SSSSSSSSSSS__SSSSSSSSSSS',
    'SSSSSS....XXXX....SSSSSS',
    'SSSSSS....XXXX....SSSSSS',
    'SSSSSSSSSSS__SSSSSSSSSSS',
    '.SSSSSSSSSS__SSSSSSSSSS.',
    '..SSSSSSSSSSSSSSSSSSSS..',
  ];

  static final Set<SeatKey> _demoOccupiedSeats = <SeatKey>{
    const SeatKey(row: 1, column: 8),
    const SeatKey(row: 1, column: 9),
    const SeatKey(row: 2, column: 5),
    const SeatKey(row: 3, column: 15),
    const SeatKey(row: 4, column: 16),
    const SeatKey(row: 7, column: 7),
    const SeatKey(row: 8, column: 18),
  };
}

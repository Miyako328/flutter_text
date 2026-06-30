import '../../init.dart';
import 'choose_seat_controller.dart';
import 'package:get/get.dart';

class ChooseSeat extends StatefulWidget {
  @override
  State<ChooseSeat> createState() => _ChooseSeatState();
}

class _ChooseSeatState extends State<ChooseSeat> {
  static const double _rowLabelWidth = 46;
  static const double _cellWidth = 30;
  static const double _cellHeight = 34;
  static const double _seatWidth = 22;
  static const double _seatHeight = 26;
  static const double _minZoom = 0.8;
  static const double _maxZoom = 2.2;

  late final ChooseSeatController seatController;
  late final TransformationController _viewerController;
  double _zoom = 1;

  @override
  void initState() {
    super.initState();
    seatController = ChooseSeatController();
    seatController.ensureLayout();
    _viewerController = TransformationController();
  }

  @override
  void dispose() {
    _viewerController.dispose();
    seatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('选择位置'),
            )
          : null,
      body: GetBuilder<ChooseSeatController>(
        id: ChooseSeatController.layoutId,
        init: seatController,
        builder: (ChooseSeatController controller) {
          controller.ensureLayout();

          return Column(
            children: <Widget>[
              _buildHeader(controller),
              _buildScreen(),
              Expanded(child: _buildSeatArea(controller)),
              _buildLegend(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ChooseSeatController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: <Widget>[
          const Text(
            '影厅选座',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Text(
              '已选 ${controller.selectedCount} 座',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildZoomControls(),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildZoomButton(Icons.remove, () => _setZoom(_zoom - 0.15)),
          SizedBox(
            width: 48,
            child: Text(
              '${(_zoom * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _buildZoomButton(Icons.add, () => _setZoom(_zoom + 0.15)),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(54, 6, 24, 24),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.elliptical(420, 82),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.white,
              const Color(0xFFBFDBFE).withValues(alpha: 0.92),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF60A5FA).withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'SCREEN',
          style: TextStyle(
            color: Color(0xFF31527E),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatArea(ChooseSeatController controller) {
    if (controller.rows.isEmpty) {
      return const Center(
        child: Text(
          '暂无座位布局',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            transformationController: _viewerController,
            constrained: false,
            minScale: _minZoom,
            maxScale: _maxZoom,
            boundaryMargin: const EdgeInsets.all(260),
            clipBehavior: Clip.none,
            onInteractionUpdate: (_) => _syncZoomFromViewer(),
            onInteractionEnd: (_) => _syncZoomFromViewer(),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: _buildSeatBoard(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatBoard(ChooseSeatController controller) {
    final double boardWidth = _seatBoardWidth(controller);
    final double boardHeight = _seatBoardHeight(controller);

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int row = 0; row < controller.rows.length; row += 1)
            _buildSeatRow(controller, row),
          const SizedBox(height: 12),
          _buildColumnRail(controller),
        ],
      ),
    );
  }

  Widget _buildSeatRow(ChooseSeatController controller, int rowIndex) {
    final List<SeatSlot> row = controller.rows[rowIndex];

    return SizedBox(
      height: _cellHeight,
      child: Row(
        children: <Widget>[
          _buildRowLabel(controller.rowLabel(rowIndex)),
          for (final SeatSlot slot in row) _buildSeatCell(controller, slot),
        ],
      ),
    );
  }

  Widget _buildColumnRail(ChooseSeatController controller) {
    return SizedBox(
      height: _cellHeight,
      child: Row(
        children: <Widget>[
          const SizedBox(width: _rowLabelWidth),
          for (int column = 0; column < controller.maxColumnCount; column += 1)
            SizedBox(
              width: _cellWidth,
              child: Center(
                child: Text(
                  controller.columnLabel(column),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRowLabel(String label) {
    return SizedBox(
      width: _rowLabelWidth,
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatCell(ChooseSeatController controller, SeatSlot slot) {
    return SizedBox(
      width: _cellWidth,
      height: _cellHeight,
      child: Center(child: _buildSeatSlot(controller, slot)),
    );
  }

  Widget _buildSeatSlot(ChooseSeatController controller, SeatSlot slot) {
    switch (slot.type) {
      case SeatSlotType.empty:
        return const SizedBox.shrink();
      case SeatSlotType.aisle:
        return Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      case SeatSlotType.blocked:
      case SeatSlotType.seat:
        final SeatStatus status = controller.statusOf(slot);
        final bool selected = status == SeatStatus.selected;
        final bool enabled = status == SeatStatus.available || selected;

        return GestureDetector(
          onTap: enabled ? () => controller.toggleSeat(slot) : null,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            scale: selected ? 1.12 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              width: _seatWidth,
              height: _seatHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _seatColor(status),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.10),
                  width: selected ? 2 : 1,
                ),
                boxShadow: <BoxShadow>[
                  if (selected)
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.42),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
        );
    }
  }

  Widget _buildLegend(ChooseSeatController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildLegendItem('可选', SeatStatus.available),
          _buildLegendItem('已选', SeatStatus.selected),
          _buildLegendItem('已售', SeatStatus.occupied),
          _buildLegendItem('禁用', SeatStatus.disabled),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, SeatStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _seatColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _seatColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.available:
        return const Color(0xFF60A5FA);
      case SeatStatus.selected:
        return const Color(0xFF22C55E);
      case SeatStatus.occupied:
        return const Color(0xFFCBD5E1);
      case SeatStatus.disabled:
        return const Color(0xFF64748B);
    }
  }

  void _setZoom(double value) {
    final double nextZoom = value.clamp(_minZoom, _maxZoom);
    final Matrix4 current = _viewerController.value;
    final double currentZoom = current.getMaxScaleOnAxis();
    final double factor = nextZoom / currentZoom;

    _viewerController.value = current.clone()..scale(factor);
    setState(() => _zoom = nextZoom);
  }

  void _syncZoomFromViewer() {
    final double nextZoom =
        _viewerController.value.getMaxScaleOnAxis().clamp(_minZoom, _maxZoom);
    if ((nextZoom - _zoom).abs() < 0.01) {
      return;
    }
    setState(() => _zoom = nextZoom);
  }

  double _seatBoardWidth(ChooseSeatController controller) {
    return _rowLabelWidth + (controller.maxColumnCount * _cellWidth);
  }

  double _seatBoardHeight(ChooseSeatController controller) {
    return (controller.rows.length * _cellHeight) + 12 + _cellHeight;
  }
}

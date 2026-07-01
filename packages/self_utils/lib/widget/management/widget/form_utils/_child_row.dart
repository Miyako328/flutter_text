part of '../common_form.dart';

class _ChildWidget<T> extends StatefulWidget {
  List<FormChildColumn<T>> children;
  List<T> values;

  _ChildWidget({Key? key, required this.children, required this.values})
      : super(key: key);

  @override
  State<_ChildWidget<T>> createState() => _ChildWidgetState<T>();
}

class _ChildWidgetState<T> extends State<_ChildWidget<T>> {
  List<Widget> columns = [];
  List<Widget> titles = [];
  int onSelectHash = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _ChildWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    columns.clear();
    titles.clear();
    titles.add(_topCell());
    columns.addAll(widget.values.map((element) => _buildRow(element)).toList());
    titles.addAll(widget.children
        .map((e) => _warpWidget(child: e.title, color: Setting.tableBarColor))
        .toList());
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            children: titles,
          ),
          Column(
            children: columns,
          )
        ],
      ),
    );
  }

  Widget _topCell() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 0.1, color: const Color(0xE6797979)),
          color: Setting.tableBarColor),
      height: 26,
      width: 50,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: Container(),
    );
  }

  Widget _buildRow(T value) {
    List<Widget> row = [];
    row.add(_topCell());
    row.addAll(widget.children
        .map((e) => _warpWidget(
              child: e.builder(context, value),
              color:
                  value.hashCode == onSelectHash ? Colors.blue.shade50 : null,
            ))
        .toList());
    return GestureDetector(
      key: Key(value.hashCode.toString()),
      child: Row(
        children: row,
      ),
      onTap: () {
        if (onSelectHash != value.hashCode) {
          onSelectHash = value.hashCode ?? -1;
        } else {
          onSelectHash = -1;
        }
        setState(() {});
      },
    );
  }

  Widget _warpWidget({required Widget child, Color? color, double? width}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 0.1, color: const Color(0xE6797979)),
          color: color),
      height: 26,
      width: width ??
          (MediaQuery.of(context).size.width - 50) / 7,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }
}

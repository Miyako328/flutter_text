part of '../common_form.dart';

class WrapWidget extends StatelessWidget {
  final Color? color;
  final double? width;
  final Widget child;

  const WrapWidget({Key? key, this.color, this.width, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 0.1, color: const Color(0xE6797979)),
          color: color),
      height: 26,
      width: width ?? FormSetting.width,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }
}


class ExtraRow<T> extends StatelessWidget {
  final Color? color;
  final List<FormColumn<T>> columns;
  const ExtraRow({Key? key, this.color, required this.columns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Row(
        children: columns
            .map((e) => WrapWidget(
            width: e.width,
            child: e.extraBuilder ?? Container()))
            .toList(growable: false),
      ),
    );
  }
}


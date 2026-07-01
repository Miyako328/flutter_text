part of 'toast_utils.dart';

class _TextToast extends StatefulWidget {
  final String text;

  final Color? contentBackgroundColor;
  final Alignment? align;
  final Widget? preIcon;
  final Widget? suffixIcon;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadiusGeometry? borderRadius;

  const _TextToast(
      {Key? key,
        required this.text,
        this.contentBackgroundColor,
        this.align,
        this.preIcon,
        this.suffixIcon,
        this.textStyle,
        this.contentPadding,
        this.borderRadius})
      : super(key: key);

  @override
  _TextToastState createState() => _TextToastState();
}

class _TextToastState extends State<_TextToast> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.align ?? Alignment.center,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            constraints: constraints.copyWith(
                maxWidth: constraints.biggest.width * 0.75),
            padding: widget.contentPadding,
            decoration: BoxDecoration(
              color: widget.contentBackgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: IntrinsicWidth(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.text,
                      style: widget.textStyle,
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

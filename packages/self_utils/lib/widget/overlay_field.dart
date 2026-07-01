import 'package:flutter/material.dart';

typedef OverlayItem<T> = Widget Function(T value);
typedef OnChange<T> = void Function(T value);

@immutable
class OverlayField<T> extends StatefulWidget {
  List<T> lists;
  OverlayItem<T> child;
  String initValue;
  OnChange<T>? onChange;
  double maxHeight;
  Decoration? decoration;
  TextStyle? textStyle;

  OverlayField({
    required this.lists,
    required this.child,
    required this.initValue,
    Key? key,
    this.maxHeight = 60,
    this.decoration,
    this.textStyle,
    this.onChange,
  }) : super(key: key);

  @override
  _OverlayFieldState<T> createState() => _OverlayFieldState<T>();
}

class _OverlayFieldState<T> extends State<OverlayField<T>> {
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;

  final LayerLink _layerLink = LayerLink();
  bool _hasOverlay = false;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlay();
        Overlay.of(context)?.insert(_overlayEntry!);
        _hasOverlay = true;
      } else {
        closeOverlay();
      }
      setState(() {});
    });
    _setText();
  }

  void _setText() {
    _controller = TextEditingController(text: widget.initValue);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant OverlayField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initValue != oldWidget.initValue) {
      _setText();
    }
  }

  OverlayEntry _createOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(
      builder: (BuildContext context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4,
            child: RepaintBoundary(
              child: Scrollbar(
                child: Container(
                  height: widget.maxHeight,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: widget.lists
                        .map(
                          (T e) => InkWell(
                        onTap: () {
                          widget.onChange?.call(e);
                          closeOverlay();
                        },
                        child: widget.child.call(e),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void closeOverlay() {
    if (_hasOverlay) {
      _overlayEntry?.remove();
      _focusNode.unfocus();
      setState(() {
        _hasOverlay = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: widget.decoration,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller,
                readOnly: true,
                focusNode: _focusNode,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 3),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00ffffff),
                      width: 0.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x00ffffff),
                      width: 0.0,
                    ),
                  ),
                ),
                style: widget.textStyle,
                onChanged: (String value) {},
              ),
            ),
            InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
              child: const Icon(Icons.keyboard_arrow_down_outlined, size: 18,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.dispose();
    }

    _focusNode.removeListener(() {
      if (_focusNode.hasFocus)
        _createOverlay();
      else
        closeOverlay();
    });
    _focusNode.dispose();
    _controller?.dispose();
    super.dispose();
  }
}

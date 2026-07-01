import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// popup window 位于 targetView 的方向
enum PopupToastDirection {
  /// 箭头朝上
  top,

  /// 箭头朝下
  bottom
}

/// 通用 Popup Window 提示，带三角号
class PopupToastWindow extends StatefulWidget {
  /// 依附的组件的Context
  final BuildContext? context;

  /// 箭头的高度
  final double? arrowHeight;

  /// 要显示的文本
  final String? text;

  /// 依附的组件和PopupToastWindow组件共同持有的GlobalKey
  final GlobalKey popKey;

  /// 要显示文本的样式
  final TextStyle? textStyle;

  /// popUpWindow的背景颜色
  final Color? backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 是否有关闭图标
  final bool? isShowCloseIcon;

  /// 距离targetView偏移量
  final double? offset;

  /// popUpWindow位于targetView的方向
  final PopupToastDirection? popDirection;

  /// 自定义widget
  final Widget? widget;

  /// 容器内边距
  final EdgeInsets? paddingInsets;

  /// 容器圆角
  final double? borderRadius;

  /// 是否能多行显示  默认false:单行显示
  final bool canWrap;

  /// 默认距离TargetView边线的距离,默认：20
  final double? spaceMargin;

  /// 箭头偏移量
  final double? arrowOffset;

  /// popUpWindow消失回调
  final VoidCallback? onDismiss;

  /// popWindow距离底部的距离小于此值的时候，
  /// 自动将popWindow在targetView上面弹出
  final double? turnOverFromBottom;

  ///宽度
  final double? width;

  const PopupToastWindow(this.context,
      {this.text,
      required this.popKey,
      this.arrowHeight,
      this.textStyle,
      this.backgroundColor,
      this.isShowCloseIcon,
      this.offset,
      this.popDirection,
      this.widget,
      this.paddingInsets,
      this.borderRadius,
      this.borderColor,
      this.canWrap = false,
      this.spaceMargin,
      this.arrowOffset,
      this.width,
      this.onDismiss,
      this.turnOverFromBottom = 50.0});

  // 显示popUpWindow
  static void showPopWindow(context, String text, GlobalKey popKey,
      {PopupToastDirection popDirection = PopupToastDirection.bottom,
      double arrowHeight = 6.0,
      TextStyle textStyle =
          const TextStyle(fontSize: 16, color: Color(0xFFFFFFFF)),
      Color backgroundColor = const Color(0xFF1A1A1A),
      bool hasCloseIcon = false,
      double offset = 5,
      Widget? widget,
      EdgeInsets paddingInsets =
          const EdgeInsets.only(left: 18, top: 14, right: 18, bottom: 14),
      double borderRadius = 8,
      Color borderColor = Colors.transparent,
      double borderWidth = 1,
      bool canWrap = false,
      double spaceMargin = 0,
      double? arrowOffset,
      double? width,
      VoidCallback? dismissCallback,
      double turnOverFromBottom = 50.0}) {
    Navigator.push(
      context,
      PopupToastRoute(
        child: PopupToastWindow(
          context,
          arrowHeight: arrowHeight,
          text: text,
          popKey: popKey,
          textStyle: textStyle,
          backgroundColor: backgroundColor,
          isShowCloseIcon: hasCloseIcon,
          offset: offset,
          popDirection: popDirection,
          widget: widget,
          paddingInsets: paddingInsets,
          borderRadius: borderRadius,
          borderColor: borderColor,
          canWrap: canWrap,
          width: width,
          spaceMargin: spaceMargin,
          arrowOffset: arrowOffset,
          onDismiss: dismissCallback,
          turnOverFromBottom: turnOverFromBottom,
        ),
      ),
    );
  }

  @override
  _PopupToastWindowState createState() => _PopupToastWindowState();
}

class _PopupToastWindowState extends State<PopupToastWindow> {
  /// targetView的位置
  Rect? _showRect;

  /// 屏幕的尺寸
  late Size _screenSize;

  /// 箭头和左右侧边线间距
  final double _arrowSpacing = 18;

  /// 是否向右侧延伸，true：向右侧延伸，false：向左侧延伸
  bool _expandedRight = true;

  /// popUpWindow在中线两侧的具体位置
  late double _left, _right, _top, _bottom;

  /// 箭头展示方向
  PopupToastDirection? _popDirection;

  /// 去除透明度的边框色
  Color? _borderColor;

  /// 去除透明度的背景颜色
  Color? _backgroundColor;

  @override
  void initState() {
    super.initState();
    _showRect = _getWidgetGlobalRect(widget.popKey);
    _screenSize = window.physicalSize / window.devicePixelRatio;
    _borderColor = widget.borderColor?.withAlpha(255);
    _backgroundColor = widget.backgroundColor?.withAlpha(255);
    _popDirection = widget.popDirection;
    _calculateOffset();
  }

  // 获取targetView的位置
  Rect? _getWidgetGlobalRect(GlobalKey key) {
    if (key == null) {
      return null;
    }
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  // 计算popUpWindow显示的位置
  void _calculateOffset() {
    if ((_showRect?.center.dx ?? 0) < _screenSize.width / 2) {
      // popUpWindow向右侧延伸
      _expandedRight = true;
      _left = (_showRect?.left ?? 0) + (widget.spaceMargin ?? 0);
    } else {
      // popUpWindow向左侧延伸
      _expandedRight = false;
      _right = _screenSize.width -
          (_showRect?.right ?? 0) +
          (widget.spaceMargin ?? 0);
    }
    if (_popDirection == PopupToastDirection.bottom) {
      // 在targetView下方
      _top = (_showRect?.height ?? 0) +
          (_showRect?.top ?? 0) +
          (widget.offset ?? 0);
      if ((_screenSize.height - _top) < (widget.turnOverFromBottom ?? 0)) {
        _popDirection = PopupToastDirection.top;
        _bottom =
            _screenSize.height - (_showRect?.top ?? 0) + (widget.offset ?? 0);
      }
    } else if (_popDirection == PopupToastDirection.top) {
      // 在targetView上方
      _bottom =
          _screenSize.height - (_showRect?.top ?? 0) + (widget.offset ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: true,
      child: WillPopScope(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pop(context);
              if (widget.onDismiss != null) {
                widget.onDismiss!();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: <Widget>[
                  _buildPopWidget(),
                  // triangle arrow
                  _buildArrowWidget(),
                ],
              ),
            ),
          ),
          onWillPop: () {
            if (widget.onDismiss != null) {
              widget.onDismiss!();
            }
            return Future.value(true);
          }),
    );
  }

  // 绘制箭头
  Widget _buildArrowWidget() {
    return _expandedRight
        ? Positioned(
            left: widget.arrowOffset ??
                _left +
                    ((_showRect?.width ?? 0) - _arrowSpacing) / 2 -
                    (widget.spaceMargin ?? 0),
            top: _popDirection == PopupToastDirection.bottom
                ? _top - (widget.arrowHeight ?? 0)
                : null,
            bottom: _popDirection == PopupToastDirection.top
                ? _bottom - (widget.arrowHeight ?? 0)
                : null,
            child: CustomPaint(
              size: Size(15.0, (widget.arrowHeight ?? 0)),
              painter: _TrianglePainter(
                  isDownArrow: _popDirection == PopupToastDirection.top,
                  color: _backgroundColor!,
                  borderColor: _borderColor!),
            ),
          )
        : Positioned(
            right: widget.arrowOffset ??
                _right +
                    ((_showRect?.width ?? 0) - _arrowSpacing) / 2 -
                    (widget.spaceMargin ?? 0),
            top: _popDirection == PopupToastDirection.bottom
                ? _top - (widget.arrowHeight ?? 0)
                : null,
            bottom: _popDirection == PopupToastDirection.top
                ? _bottom - (widget.arrowHeight ?? 0)
                : null,
            child: CustomPaint(
              size: Size(15.0, widget.arrowHeight??0),
              painter: _TrianglePainter(
                  isDownArrow: _popDirection == PopupToastDirection.top,
                  color: _backgroundColor!,
                  borderColor: _borderColor!),
            ),
          );
  }

  // popWindow的弹出样式
  Widget _buildPopWidget() {
    // 状态栏高度
    final double statusBarHeight =
        MediaQueryData.fromWindow(window).padding.top;
    return Positioned(
        left: _expandedRight ? _left : null,
        right: _expandedRight ? null : _right,
        top: _popDirection == PopupToastDirection.bottom ? _top : null,
        bottom: _popDirection == PopupToastDirection.top ? _bottom : null,
        child: Container(
            width: widget.width,
            padding: widget.paddingInsets,
            decoration: BoxDecoration(
                color: _backgroundColor,
                border: Border.all(color: _borderColor!, width: 0.5),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 4)),
            constraints: BoxConstraints(
                maxWidth: _expandedRight
                    ? _screenSize.width - _left
                    : _screenSize.width - _right,
                maxHeight: _popDirection == PopupToastDirection.bottom
                    ? _screenSize.height - _top
                    : _screenSize.height - _bottom - statusBarHeight),
            child: widget.widget == null
                ? SingleChildScrollView(
                    child: widget.canWrap
                        ? RichText(
                            text: TextSpan(children: <InlineSpan>[
                            TextSpan(
                                text: widget.text, style: widget.textStyle),
                            widget.isShowCloseIcon == true
                                ? const WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ))
                                : const TextSpan(text: '')
                          ]))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  widget.text??'',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.textStyle,
                                ),
                              ),
                              widget.isShowCloseIcon == true
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('')
                            ],
                          ))
                : widget.widget));
  }
}

// 绘制箭头
class _TrianglePainter extends CustomPainter {
  bool? isDownArrow;
  Color? color;
  Color? borderColor;

  _TrianglePainter({
    this.isDownArrow,
    this.color,
    this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    paint.strokeWidth = 2.0;
    paint.color = color!;
    paint.style = PaintingStyle.fill;

    if (isDownArrow == true) {
      path.moveTo(0.0, -1.5);
      path.lineTo(size.width / 2.0, size.height);
      path.lineTo(size.width, -1.5);
    } else {
      path.moveTo(0.0, size.height + 1.5);
      path.lineTo(size.width / 2.0, 0.0);
      path.lineTo(size.width, size.height + 1.5);
    }

    canvas.drawPath(path, paint);
    Paint paintBorder = Paint();
    Path pathBorder = Path();
    paintBorder.strokeWidth = 0.5;
    paintBorder.color = borderColor!;
    paintBorder.style = PaintingStyle.stroke;

    if (isDownArrow == true) {
      pathBorder.moveTo(0.0, -0.5);
      pathBorder.lineTo(size.width / 2.0, size.height);
      pathBorder.lineTo(size.width, -0.5);
    } else {
      pathBorder.moveTo(0.5, size.height + 0.5);
      pathBorder.lineTo(size.width / 2.0, 0);
      pathBorder.lineTo(size.width - 0.5, size.height + 0.5);
    }

    canvas.drawPath(pathBorder, paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PopupToastRoute<T> extends PopupRoute<T> {
  final Duration _duration = const Duration(milliseconds: 100);
  Widget child;

  PopupToastRoute({required this.child});

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0)
          //fastOutSlowIn快出慢进
          .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
      child: child,
    );
  }

  @override
  Duration get transitionDuration => _duration;
}


class PopupTextAndExText extends StatefulWidget {
  final String showText;
  final Widget builderWidget;

  const PopupTextAndExText({
    required this.showText,
    required this.builderWidget,
    super.key,
  });

  @override
  State<PopupTextAndExText> createState() => _PopupTextAndExTextState();
}

class _PopupTextAndExTextState extends State<PopupTextAndExText> {
  late GlobalKey _textKey ;

  @override
  void initState() {
    super.initState();
    _textKey = GlobalKey<_PopupTextAndExTextState>();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: GestureDetector(
        key: _textKey,
        onTap: () {
          PopupToastWindow.showPopWindow(
            context,
            widget.showText,
            _textKey,
            spaceMargin: 0,
            canWrap: true,
            width: 300,
          );
        },
        child: widget.builderWidget,
      ),
    );
  }
}
import 'package:flutter/material.dart';

//显示网络图片组件
class CustomNetWorkImage extends StatefulWidget {
  String url;
  BoxFit? fit;
  double? width;
  double? height;

  Widget? errorWidget;
  Widget? frameWidget;
  Widget? loadingWidget;

  CustomNetWorkImage(this.url,
      {this.width,
      this.height,
      this.errorWidget,
      this.fit,
      this.frameWidget,
      this.loadingWidget})
      : assert(url != null);

  @override
  _CustomNetWorkImageState createState() => _CustomNetWorkImageState();
}

class _CustomNetWorkImageState extends State<CustomNetWorkImage> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return widget.errorWidget ??
            Container(
              width: 375,
              height: 375,
              alignment: Alignment.center,
              child: const Icon(
                Icons.error,
                color: Colors.red,
              ),
            );
      },
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        return widget.loadingWidget ?? Container(
          width: 375,
          height: 375,
          alignment: Alignment.center,
          // 设置下载进度
          child: CircularProgressIndicator(
              value: loadingProgress.cumulativeBytesLoaded /
                  (loadingProgress.expectedTotalBytes ?? 0)),
        );
      },
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return widget.frameWidget ?? AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          child: child,
        );
      },
    );
  }
}

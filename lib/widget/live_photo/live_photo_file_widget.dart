import 'dart:io';

import 'package:flutter/material.dart';

import 'live_photo_widget.dart';

/// Convenience wrapper for a local still image + local video pair.
class LivePhotoFileWidget extends StatelessWidget {
  final File imageFile;
  final File? videoFile;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool enableTapToPlay;
  final bool enableLongPressToPlay;
  final bool autoPlayOnce;
  final bool showLiveBadge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? liveBadge;

  const LivePhotoFileWidget({
    required this.imageFile,
    required this.videoFile,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.enableTapToPlay = true,
    this.enableLongPressToPlay = true,
    this.autoPlayOnce = false,
    this.showLiveBadge = true,
    this.onTap,
    this.onLongPress,
    this.loadingWidget,
    this.errorWidget,
    this.liveBadge,
  });

  @override
  Widget build(BuildContext context) {
    return LivePhotoWidget(
      imageProvider: FileImage(imageFile),
      videoFile: videoFile,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      enableTapToPlay: enableTapToPlay,
      enableLongPressToPlay: enableLongPressToPlay,
      autoPlayOnce: autoPlayOnce,
      showLiveBadge: showLiveBadge,
      onTap: onTap,
      onLongPress: onLongPress,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      liveBadge: liveBadge,
    );
  }
}

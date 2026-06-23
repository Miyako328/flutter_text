import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'live_photo_controller.dart';

/// A reusable Live Photo style widget.
///
/// It displays a still image by default, then overlays and plays [videoFile]
/// on tap or long press. When playback completes, it returns to the still image.
class LivePhotoWidget extends StatefulWidget {
  final ImageProvider imageProvider;
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

  const LivePhotoWidget({
    required this.imageProvider,
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
  State<LivePhotoWidget> createState() => _LivePhotoWidgetState();
}

class _LivePhotoWidgetState extends State<LivePhotoWidget> {
  late final LivePhotoController _controller;
  Timer? _playbackMonitorTimer;
  bool _isVideoReady = false;
  bool _isLoadingVideo = false;
  bool _isLongPressing = false;
  bool _shouldShowVideo = false;
  bool _autoPlayConsumed = false;

  bool get _hasVideo => widget.videoFile != null;

  @override
  void initState() {
    super.initState();
    _controller = LivePhotoController();
    _controller.setOnPlayCompleted(_hideVideoLayer);
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadVideoIfNeeded();
      }
    });
  }

  @override
  void didUpdateWidget(covariant LivePhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile?.path != widget.videoFile?.path) {
      _resetVideoState();
      _loadVideoIfNeeded();
    }
    if (widget.autoPlayOnce && !oldWidget.autoPlayOnce && _isVideoReady) {
      _tryAutoPlayOnce();
    }
  }

  @override
  void dispose() {
    _playbackMonitorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _resetVideoState() {
    _isVideoReady = false;
    _isLoadingVideo = false;
    _isLongPressing = false;
    _shouldShowVideo = false;
    _autoPlayConsumed = false;
    _playbackMonitorTimer?.cancel();
    if (_controller.isInitialized) {
      _controller.stop();
    }
  }

  Future<void> _loadVideoIfNeeded() async {
    if (!_hasVideo || _isVideoReady || _isLoadingVideo) {
      return;
    }

    setState(() {
      _isLoadingVideo = true;
    });

    await _controller.initializeVideo(
      widget.videoFile!,
      onInitialized: () {
        if (!mounted) {
          return;
        }
        setState(() {
          _isVideoReady = true;
          _isLoadingVideo = false;
        });
        _tryAutoPlayOnce();
      },
      onError: (Object error) {
        debugPrint('LivePhotoWidget load video failed: $error');
        if (!mounted) {
          return;
        }
        setState(() {
          _isVideoReady = false;
          _isLoadingVideo = false;
        });
      },
    );
  }

  void _tryAutoPlayOnce() {
    if (_autoPlayConsumed ||
        !widget.autoPlayOnce ||
        !_isVideoReady ||
        _isLoadingVideo ||
        !_controller.isInitialized) {
      return;
    }

    _autoPlayConsumed = true;
    _shouldShowVideo = true;
    _controller.play();
    _startPlaybackMonitor();
    if (mounted) {
      setState(() {});
    }
  }

  void _startPlaybackMonitor() {
    _playbackMonitorTimer?.cancel();
    _playbackMonitorTimer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final VideoPlayerController? videoController =
          _controller.videoController;
      if (videoController != null &&
          videoController.value.isInitialized &&
          _shouldShowVideo) {
        final Duration duration = videoController.value.duration;
        final Duration position = videoController.value.position;
        if (videoController.value.isCompleted ||
            (duration.inMilliseconds > 0 && position >= duration)) {
          _hideVideoLayer();
          timer.cancel();
        }
      } else if (!_shouldShowVideo) {
        timer.cancel();
      }
    });
  }

  void _hideVideoLayer() {
    if (!mounted) {
      return;
    }
    setState(() {
      _shouldShowVideo = false;
      _isLongPressing = false;
    });
  }

  void _handleTap() {
    if (!widget.enableTapToPlay) {
      widget.onTap?.call();
      return;
    }

    if (_isVideoReady) {
      if (_controller.isPlaying) {
        _controller.pause();
        _shouldShowVideo = false;
        _playbackMonitorTimer?.cancel();
      } else {
        _shouldShowVideo = true;
        _controller.play();
        _startPlaybackMonitor();
      }
      setState(() {});
    } else if (!_isLoadingVideo) {
      _loadVideoIfNeeded();
    }
  }

  void _handleLongPressStart() {
    if (!widget.enableLongPressToPlay) {
      widget.onLongPress?.call();
      return;
    }

    if (_isVideoReady) {
      setState(() {
        _isLongPressing = true;
        _shouldShowVideo = true;
      });
      _controller.play();
      _startPlaybackMonitor();
    } else if (!_isLoadingVideo) {
      _loadVideoIfNeeded();
    }
  }

  void _handleLongPressEnd() {
    if (!_isLongPressing) {
      return;
    }
    if (_controller.isInitialized) {
      _controller.stop();
    }
    _playbackMonitorTimer?.cancel();
    setState(() {
      _isLongPressing = false;
      _shouldShowVideo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? videoController = _controller.videoController;
    final bool shouldShowVideoLayer = _shouldShowVideo &&
        _isVideoReady &&
        videoController != null &&
        videoController.value.isInitialized;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPressStart: (_) => _handleLongPressStart(),
        onLongPressEnd: (_) => _handleLongPressEnd(),
        onLongPressUp: _handleLongPressEnd,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image(
                image: widget.imageProvider,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return widget.errorWidget ?? const _LivePhotoError();
                },
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? progress,
                ) {
                  if (progress == null) {
                    return child;
                  }
                  return widget.loadingWidget ?? const _LivePhotoLoading();
                },
              ),
              if (shouldShowVideoLayer) _buildVideoLayer(videoController),
              if (_hasVideo && _isLoadingVideo) const _VideoLoadingOverlay(),
              if (_hasVideo &&
                  _isVideoReady &&
                  widget.showLiveBadge &&
                  !shouldShowVideoLayer)
                widget.liveBadge ?? const _LivePhotoBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLayer(VideoPlayerController controller) {
    return Positioned.fill(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _LivePhotoBadge extends StatelessWidget {
  const _LivePhotoBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Live',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoLoadingOverlay extends StatelessWidget {
  const _VideoLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.18),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LivePhotoLoading extends StatelessWidget {
  const _LivePhotoLoading();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _LivePhotoError extends StatelessWidget {
  const _LivePhotoError();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Controller for a Live Photo style image + short video pair.
class LivePhotoController {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isInitialized = false;
  File? _videoFile;
  VoidCallback? _onPlayCompleted;

  VideoPlayerController? get videoController => _videoController;

  bool get isPlaying => _isPlaying;

  bool get isInitialized => _isInitialized;

  File? get videoFile => _videoFile;

  void setOnPlayCompleted(VoidCallback? callback) {
    _onPlayCompleted = callback;
  }

  Future<void> initializeVideo(
    File videoFile, {
    VoidCallback? onInitialized,
    ValueChanged<Object>? onError,
  }) async {
    try {
      if (_videoFile?.path == videoFile.path && _isInitialized) {
        return;
      }

      await dispose();
      _videoFile = videoFile;

      final bool isReady = await _waitForFileReady(videoFile);
      if (!isReady) {
        onError?.call(Exception('Live photo video file is not ready'));
        return;
      }

      _videoController = VideoPlayerController.file(videoFile);
      await _videoController!.initialize();
      await _videoController!.setLooping(false);
      _videoController!.addListener(_onVideoStatusChanged);

      _isInitialized = true;
      _isPlaying = false;
      onInitialized?.call();
    } catch (error) {
      debugPrint('LivePhotoController initializeVideo failed: $error');
      _isInitialized = false;
      onError?.call(error);
    }
  }

  Future<bool> _waitForFileReady(
    File file, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 200),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        if (!await file.exists()) {
          await Future<void>.delayed(retryDelay);
          continue;
        }

        final int firstLength = await file.length();
        if (firstLength <= 0) {
          await Future<void>.delayed(retryDelay);
          continue;
        }

        await Future<void>.delayed(retryDelay);
        final int secondLength = await file.length();
        if (firstLength != secondLength) {
          continue;
        }

        final RandomAccessFile accessFile =
            await file.open(mode: FileMode.read);
        await accessFile.close();
        return true;
      } catch (error) {
        debugPrint('LivePhotoController file check failed: $error');
        await Future<void>.delayed(retryDelay);
      }
    }
    return false;
  }

  void play() {
    if (_videoController == null || !_isInitialized) {
      return;
    }
    _videoController!.play();
    _isPlaying = true;
  }

  void pause() {
    if (_videoController == null || !_isInitialized) {
      return;
    }
    _videoController!.pause();
    _isPlaying = false;
  }

  void stop() {
    if (_videoController == null || !_isInitialized) {
      return;
    }
    _videoController!.pause();
    _videoController!.seekTo(Duration.zero);
    _isPlaying = false;
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void _onVideoStatusChanged() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null) {
      return;
    }

    final bool wasPlaying = _isPlaying;
    _isPlaying = controller.value.isPlaying;

    if (controller.value.isCompleted && wasPlaying) {
      _isPlaying = false;
      _onPlayCompleted?.call();
      controller.seekTo(Duration.zero);
      controller.pause();
    }
  }

  Future<void> dispose() async {
    if (_videoController != null) {
      _videoController!.removeListener(_onVideoStatusChanged);
      await _videoController!.dispose();
      _videoController = null;
    }
    _isInitialized = false;
    _isPlaying = false;
    _videoFile = null;
    _onPlayCompleted = null;
  }
}

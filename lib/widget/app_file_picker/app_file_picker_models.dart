import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

enum AppPickerMimeType {
  image,
  video,
  all,
  custom,
}

enum AppPickerSource {
  camera,
  gallery,
  fileSystem,
}

class AppPickedFile {
  final String path;
  final String name;
  final int? size;
  final String? extension;
  final AppPickerSource source;

  const AppPickedFile({
    required this.path,
    required this.name,
    required this.source,
    this.size,
    this.extension,
  });

  File get file => File(path);

  bool get isImage {
    final String ext = (extension ?? _extensionFromPath(path)).toLowerCase();
    return <String>{
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    }.contains(ext);
  }

  bool get isVideo {
    final String ext = (extension ?? _extensionFromPath(path)).toLowerCase();
    return <String>{
      'mp4',
      'mov',
      'm4v',
      'avi',
      'mkv',
      '3gp',
      '3g2',
      'webm',
    }.contains(ext);
  }

  static String _extensionFromPath(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) {
      return '';
    }
    return path.substring(dotIndex + 1);
  }
}

class AppPickerPath {
  final String id;
  final String name;
  final int? count;
  final Uint8List? thumbnailBytes;
  final IconData fallbackIcon;

  const AppPickerPath({
    required this.id,
    required this.name,
    this.count,
    this.thumbnailBytes,
    this.fallbackIcon = Icons.photo_library_outlined,
  });

  AppPickerPath copyWith({
    String? id,
    String? name,
    int? count,
    Uint8List? thumbnailBytes,
    IconData? fallbackIcon,
  }) {
    return AppPickerPath(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      fallbackIcon: fallbackIcon ?? this.fallbackIcon,
    );
  }
}

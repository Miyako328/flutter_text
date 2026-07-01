import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_text/assembly_pack/music_play/music_model.dart';
import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/file_utils.dart';

enum PlayMode {
  random, //随机
  singleLoop, //单曲循环
  loop, //列表循环
  normal, //普通
}

extension PlayModeTxt on PlayMode {
  String get enumToString {
    switch (this) {
      case PlayMode.random:
        return '随机播放';
        break;
      case PlayMode.singleLoop:
        return '单曲循环';
        break;
      case PlayMode.loop:
        return '列表循环';
        break;
      case PlayMode.normal:
        return '列表播放';
        break;
    }
  }
}

class MusicHelper {
  static const List<PlayMode> _mode = <PlayMode>[
    PlayMode.normal,
    PlayMode.loop,
    PlayMode.singleLoop,
    PlayMode.random
  ];

  // 本地文件
  static Future<MusicModel> setAppLocateFile(FilePickerResult files) async {
    final PlatformFile _file = ArrayHelper.get(files.files, 0)!;
    final Uint8List unit8 = await File(_file.path!).readAsBytes();
    final File tempFile = await FileUtils.generateRandomTempFile(
        fileType: 'mp3', name: _file.name);
    final File newFile = await tempFile.writeAsBytes(unit8);

    //缓存文件
    final MusicModel _model = MusicModel()
      ..path = newFile.path
      ..id = _file.hashCode
      ..name = _file.name.split('.mp3')[0];
    await MusicCache.setCache(_model);

    return _model;
  }

  // 修改播放方式
  static PlayMode changeMode(PlayMode current) {
    int index = _mode.indexOf(current);
    if (index == _mode.length - 1) {
      index = 0;
    } else {
      index = index + 1;
    }
    return ArrayHelper.get(_mode, index)!;
  }
}

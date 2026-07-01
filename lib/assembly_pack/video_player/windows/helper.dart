import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_text/init.dart';

class WinVideoModel {
  String? name;
  String? path;
  int? id;

  WinVideoModel({this.name, this.id, this.path});

  factory WinVideoModel.fromJson(Map<String, dynamic> json) => WinVideoModel(
        id: json['id'] as int,
        name: json['name'] as String,
        path: json['path'] as String,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['path'] = path;
    return data;
  }

  static List<WinVideoModel> listFromJson(List<dynamic>? json) {
    return json == null
        ? <WinVideoModel>[]
        : json.map((e) => WinVideoModel.fromJson(e)).toList();
  }
}

class WinVideoHelper {
  //缓存进应用内部
  static Future<File> setLocalVideoPath(
      {required File file, String? extension, String? name}) async {
    try {
      final Uint8List unit8 = await file.readAsBytes();
      final File tempFile = await FileUtils.generateRandomTempFile(
        fileType: extension,
        name: name,
      );
      final File newFile = await tempFile.writeAsBytes(unit8);
      return newFile;
    } catch (err) {
      rethrow;
    }
  }
}

class WinVideoCache {
  static const String _key = 'windows_video_play';

  static List<WinVideoModel> getLocalVideos() {
    List<WinVideoModel> result = [];
    final String? res = LocateStorage.getString(_key);
    if (res != null) {
      result = WinVideoModel.listFromJson(jsonDecode(res));
    }
    return result;
  }

  static void setLocalVideos(WinVideoModel val) {
    final List<WinVideoModel> res = getLocalVideos();
    if (!res.any((WinVideoModel el) => el.id == val.id)) {
      res.add(val);
      LocateStorage.setString(_key, jsonEncode(res));
    }
  }

  static void delete(WinVideoModel val) {
    final List<WinVideoModel> res = getLocalVideos();
    if (res.any((WinVideoModel el) => el.id == val.id)) {
      res.remove(val);
      final File file = File(val.path!);
      file.delete();
      LocateStorage.setString(_key, jsonEncode(res));
    }
  }

  static void clear() {
    LocateStorage.clean(key: _key);
  }
}

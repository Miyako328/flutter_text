import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_utils/utils/file_utils.dart';
import 'package:self_utils/utils/network_file_util/network_file_util.dart';
import 'package:self_utils/utils/permission/check_permission.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:ios_share/ios_share.dart';
import 'package:path_provider/path_provider.dart';

class FileToLocateHelper {
  //下载保存到本地文件
  // getApplicationDocumentsDirectory result = await ImageGallerySaver.saveFile(filePath);
  //netWorkUrl 网络url, fire 本地文件，byteUrl 大部分是asset文件
  static void saveFileToLocated(String fileName,
      {String? netWorkUrl,
        String? fileUrl,
        List<int>? byteUrl,
        void Function(String)? onSuccessToast}) async {
    assert(netWorkUrl != null || fileUrl != null || byteUrl != null);
    final bool check = Platform.isAndroid ? await _checkPermission() : true;
    if (!check) {
      return;
    }

    try {
      List<int> bytes = [];
      final File file = await _createFile(fileName);
      if (netWorkUrl != null) {
        bytes = await NetworkFileUtil.download(netWorkUrl);
      } else if (fileUrl != null) {
        bytes = await File(fileUrl).readAsBytes();
      } else if (byteUrl != null) {
        bytes = byteUrl;
      }

      final File file1 = await file.writeAsBytes(bytes);
      if (file1.existsSync()) {
        onSuccessToast?.call(file1.path);
      }
    } catch (e, s) {
      rethrow;
    }
  }

  // 点开大图保存文件专用
  static void saveFileImgToLocatedWithType(
      {String? fileUrl, Uint8List? byte, void Function()? onSuccessToast}) async {
    assert(fileUrl != null || byte != null);
    final bool check = Platform.isAndroid ? await _checkPermission() : true;
    if (!check) {
      return;
    }

    try {
      if (Platform.isAndroid) {
        dynamic result;
        if (fileUrl != null) {
          result = await ImageGallerySaver.saveFile(fileUrl);
        } else {
          result = await ImageGallerySaver.saveImage(byte!);
        }
        onSuccessToast?.call();
      } else {
        //ios
        final File file = await _createFileWithType('webp');
        byte ??= await File(fileUrl!).readAsBytes();
        final File file1 = await file.writeAsBytes(byte);
        if (file1.existsSync()) {
          onSuccessToast?.call();
        }
      }
    } catch (e, s) {
      rethrow;
    }
  }

  //生成临时文件
  static Future<File> _createFile(String fileName) async {
    String filePath;
    if (Platform.isAndroid) {
      final Directory? dir = await getExternalStorageDirectory();
      filePath = '${dir?.path ?? ''}$fileName';
    } else {
      final Directory tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}$fileName';
    }

    final File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  //按类型分
  //生成临时文件
  static Future<File> _createFileWithType(String fileType) async {
    String filePath;
    if (Platform.isAndroid) {
      final Directory? dir = await getExternalStorageDirectory();
      filePath = '${dir?.path ?? ''}${Random().nextInt(4294967000)}.$fileType';
    } else {
      filePath = await FileUtils.generateRandomTempFilePath(fileType: fileType);
    }

    final File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  //权限判断
  static Future<bool> _checkPermission() async {
    //判断权限
    final bool check = await PermissionHelper.checkStoragePermission();
    return check;
  }

  //将asset里的文件转为bytes
  static Future<List<int>> getAssetFileBytes(
      {required String assetPath}) async {
    List<int> bytes = <int>[];
    final ByteData load = await rootBundle.load(assetPath);
    final ByteBuffer buffer = load.buffer;
    bytes = buffer.asUint8List(load.offsetInBytes, load.lengthInBytes);
    return bytes;
  }
}
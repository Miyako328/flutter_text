import 'dart:io';
import 'dart:typed_data';

import 'package:self_utils/utils/array_helper.dart';
import 'package:self_utils/utils/file_utils.dart';

class BookHelper {
  static Future<List<File>> setAppLocateFile(List<File> files) async {
    final List<File> news = <File>[];
    for (int i = 0; i < files.length; i++) {
      final Uint8List? unit8 = await ArrayHelper.get(files, i)?.readAsBytes();
      final File tempFile =
          await FileUtils.generateRandomTempFile(fileType: 'epub');
      final File newFile = await tempFile.writeAsBytes(unit8!);
      news.add(newFile);
    }
    return news;
  }

  static Future<String> getCoverImageWithFile(List<int>? content) async {
    final File tempFile =
        await FileUtils.generateRandomTempFile(fileType: 'webp');
    final File newFile = await tempFile.writeAsBytes(content!);
    return newFile.path;
  }
}

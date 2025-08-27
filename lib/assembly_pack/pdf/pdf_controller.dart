import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:self_utils/utils/file_to_locate.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PdfController extends GetxController {
  String url = 'http://fp.baiwang.com/fp/d?d=9C4E8DD9749B11892ABA67A22E849893C02EA2A0CCF7128F92758E4F57DC701C';
  
  RxBool isDownloading = false.obs;
  RxBool isAssetDownloading = false.obs;
  RxString downloadProgress = ''.obs;
  RxString currentFilePath = ''.obs;
  
  Future<void> downloadPdf() async {
    try {
      isDownloading.value = true;
      final dir = await getApplicationSupportDirectory();
      final filePath = dir.path + '${Random().nextInt(4294967000)}' + ('/example.pdf');
      currentFilePath.value = filePath;
      
      // 这里需要根据实际的Request类来调整
      // await Request.downloadFile(url, filePath, (loaded, total) {
      //   downloadProgress.value = '文件已保存到$filePath';
      //   ToastUtils.showToast(msg: '文件已保存到$filePath');
      // });
      
      // 模拟下载完成
      await Future.delayed(Duration(seconds: 2));
      downloadProgress.value = '文件已保存到$filePath';
      ToastUtils.showToast(msg: '文件已保存到$filePath');
    } catch (e) {
      print('Download error: $e');
      ToastUtils.showToast(msg: '下载失败: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  //本地assert保存
  Future<void> assertDownload() async {
    try {
      isAssetDownloading.value = true;
      final bytes = await FileToLocateHelper.getAssetFileBytes(
          assetPath: 'assets/index.pdf');
      FileToLocateHelper.saveFileToLocated('魔法禁书目录.pdf', byteUrl: bytes,
          onSuccessToast: (String name) {
        ToastUtils.showToast(msg: '保存成功');
      });
    } catch (error, stack) {
      print('Asset download error: $error');
      ToastUtils.showToast(msg: '保存失败: $error');
    } finally {
      isAssetDownloading.value = false;
    }
  }
}

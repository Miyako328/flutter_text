import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:self_utils/init.dart';
import 'package:self_utils/utils/file_to_locate.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class pdfView extends StatefulWidget {
  @override
  pdfViewState createState() => pdfViewState();
}

class pdfViewState extends State<pdfView> {
  String url =
      'http://fp.baiwang.com/fp/d?d=9C4E8DD9749B11892ABA67A22E849893C02EA2A0CCF7128F92758E4F57DC701C';

  Future<void> _downLoad() async {
    final dir = await getApplicationSupportDirectory();
    final filePath =
        dir.path + '${Random().nextInt(4294967000)}' + ('/example.pdf');
    try {
      await Request.downloadFile(url, filePath, (loaded, total) {
        ToastUtils.showToast(msg: '文件已保存到$filePath');
      });
    } catch (e) {
      rethrow;
    }
  }

  //本地assert保存
  Future<void> _assertDownLoad() async {
    try {
      final bytes = await FileToLocateHelper.getAssetFileBytes(
          assetPath: 'assets/index.pdf');
      FileToLocateHelper.saveFileToLocated('魔法禁书目录.pdf', byteUrl: bytes,
          onSuccessToast: (String name) {
        ToastUtils.showToast(msg: '保存成功');
      });
    } catch (error, stack) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 128),
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                _downLoad();
              },
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xe6ff7e50), Color(0xe6fa8078)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '下载到本地',
                  style: TextStyle(
                    fontSize: screenUtil.adaptive(46),
                    color: const Color(0xffffffff),
                  ),
                ),
              ),
            ),
            Container(
              height: screenUtil.adaptive(20),
            ),
            FloatingActionButton(
              onPressed: () async {
                await _assertDownLoad();
              },
              child: Container(
                width: 300,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xe6ff7e50), Color(0xe6fa8078)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'assert文件下载',
                  style: TextStyle(
                    fontSize: screenUtil.adaptive(46),
                    color: const Color(0xffffffff),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:self_utils/utils/toast_utils.dart';
import 'package:self_utils/widget/api_call_back.dart';
import 'package:self_utils/widget/video_widget.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:video_compress_ds/video_compress_ds.dart';

class VideoCompressPage extends StatefulWidget {
  @override
  _VideoCompressState createState() => _VideoCompressState();
}

class _VideoCompressState extends State<VideoCompressPage> {
  File? _file;
  File? _videoFile;
  String _fileSize = '0 KB';
  String _videoFileSize = '0 KB';

  @override
  void initState() {
    super.initState();
  }

  //选择视频
  void _getVideo() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      final File file = File(result.files.first.path!);
      final String fileSize = await _formatFileSize(file);
      setState(() {
        _file = file;
        _fileSize = fileSize;
        _videoFile = null;
        _videoFileSize = '0 KB';
      });
    }
  }

  //压缩
  void _compress() async {
    if (_file == null) {
      return;
    }
    final MediaInfo? result = await loadingCallback(
      () => VideoCompress.compressVideo(
        _file!.path,
        quality: VideoQuality.DefaultQuality,
      ),
    );

    if (result != null) {
      final File file = result.file!;
      final String videoFileSize = await _formatFileSize(file);
      setState(() {
        _videoFile = file;
        _videoFileSize = videoFileSize;
      });
    }
  }

  void saveToLocal() async {
    if (_videoFile == null) {
      return;
    }
    try {
      await ImageGallerySaver.saveFile(_videoFile!.path);
      ToastUtils.showToast(msg: '文件已保存到$_videoFile');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _formatFileSize(File file) async {
    final int bytes = await file.length();
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  }

  @override
  void dispose() {
    VideoCompress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    if (_file != null)
                      Container(
                        child: VideoPlayerPage(
                          file: _file,
                          autoPlay: false,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text('视频大小：$_fileSize')
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _getVideo();
                      },
                      child: const Text('选择视频'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _compress();
                      },
                      child: const Text('压缩视频'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        saveToLocal();
                      },
                      child: const Text('保存到本地'),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: Column(
                  children: [
                    if (_videoFile != null)
                      Container(
                        child: VideoPlayerPage(
                          file: _videoFile,
                          autoPlay: false,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text('压缩后视频大小：$_videoFileSize')
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

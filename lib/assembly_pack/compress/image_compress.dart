import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_text/init.dart';
import 'package:image_picker/image_picker.dart';
import 'package:self_utils/utils/compress.dart';

class ImageCompressPage extends StatefulWidget {
  @override
  _ImageCompressState createState() => _ImageCompressState();
}

class _ImageCompressState extends State<ImageCompressPage> {
  File? _file;
  File? _compressImage;
  String _fileSize = '0 KB';
  String _compressImageSize = '0 KB';

  int? width;
  int? height;

  final ImagePicker _picker = ImagePicker();

  //获取图片
  Future<void> _getImage() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1024.0, maxHeight: 1024.0);
    if (image != null) {
      final File imageFile = File(image.path);
      final String fileSize = await _formatFileSize(imageFile);
      final Image pimage = Image.file(imageFile);

      //获取图片file格式的长宽
      pimage.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        Log.info(info.image.height);
        Log.info(info.image.width);
        setState(() {
          width = info.image.width;
          height = info.image.height;
        });
      }));

      //没有选择图片或者没有拍照
      setState(() {
        _file = imageFile;
        _fileSize = fileSize;
        _compressImage = null;
        _compressImageSize = '0 KB';
      });
    }
  }

  Future<void> _compress() async {
    if (_file == null) {
      return;
    }
    final File? result =
        await ImageCompressUtil.imageCompressAndGetFile(_file!);

    if (result != null) {
      final String compressImageSize = await _formatFileSize(result);
      setState(() {
        _compressImage = result;
        _compressImageSize = compressImageSize;
      });
    }
  }

  Future<String> _formatFileSize(File file) async {
    final int bytes = await file.length();
    return '${(bytes / 1024).toStringAsFixed(2)} KB';
  }

  @override
  void initState() {
    super.initState();
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
                        child: Image.file(
                          _file!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text('图片尺寸：width ${width ?? 0} height ${height ?? 0}'),
                    Text('图片大小：$_fileSize')
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
                        _getImage();
                      },
                      child: const Text('选择图片'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _compress();
                      },
                      child: const Text('压缩图片'),
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
                    if (_compressImage != null)
                      Container(
                        child: Image.file(
                          _compressImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text('压缩后图片大小：$_compressImageSize')
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

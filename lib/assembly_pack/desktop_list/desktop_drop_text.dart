import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter_text/init.dart';
import 'package:image_compression/image_compression.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:shell/shell.dart';

class DesktopDropText extends StatefulWidget {
  const DesktopDropText({Key? key}) : super(key: key);

  @override
  _DesktopDropTextState createState() => _DesktopDropTextState();
}

class _DesktopDropTextState extends State<DesktopDropText> {
  XFile? _file;
  String _fileSize = '0 MB';

  void _dragDone(DropDoneDetails details) async {
    _file = details.files.last;
    _fileSize = await _formatFileSize(_file!);
    Log.info('_file.path: ${_file?.path}');
    Log.info('_file.name: ${_file?.name}');
    Log.info('_file.mimeType: ${_file?.mimeType}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalStore.isMobile
          ? AppBar(
              title: const Text('拖拽进程序'),
            )
          : null,
      body: DropTarget(
        onDragDone: _dragDone,
        child: _file == null ? _upload() : _view(_file!),
      ),
    );
  }

  Widget _upload() {
    return Center(
      child: Container(
        child: const Text('拖拽图片打开'),
      ),
    );
  }

  // 显示数据
  Widget _view(XFile file) {
    final File f = File(file.path);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: Image.file(f),
          ),
          Container(
            child: Text('图片大小：$_fileSize'),
          ),
          ElevatedButton(
            onPressed: () {
              _compress();
            },
            child: const Text('压缩图片'),
          )
        ],
      ),
    );
  }

  Future<void> _compress() async {
    final shell = Shell();
    if (_file == null) {
      return;
    }
    final File f = File(_file!.path);
    final ImageFile input =
        ImageFile(rawBytes: await f.readAsBytes(), filePath: f.path);
    final ImageFile result =
        await compressInQueue(ImageFileConfiguration(input: input));

    final Directory dir = await path_provider.getTemporaryDirectory();
    final String filePath = path.join(dir.path, '${_file!.name}');
    Log.info(filePath);
    final File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    await file.writeAsBytes(result.rawBytes).whenComplete(
          () => shell.start('open ${dir.path}'),
        );
  }

  Future<String> _formatFileSize(XFile file) async {
    final int bytes = await file.length();
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)}MB';
  }
}

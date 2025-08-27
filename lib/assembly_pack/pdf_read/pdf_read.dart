import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer_null_safe/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class PdfRead extends StatefulWidget {
  @override
  _PdfReadState createState() => new _PdfReadState();
}

class _PdfReadState extends State<PdfRead> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    printFile();
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        print(pathPDF);
      });
    });
  }

  void printFile() async {
    print('assets/data/test.pdf:');
    final ByteData filebd = await rootBundle.load("assets/data/test.pdf");
    print(filebd.runtimeType);
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<File> createFileOfPdfUrl() async {
    //final url = "http://africau.edu/images/default/sample.pdf";
    final filename = 'index.pdf';
    //var request = await HttpClient().getUrl(Uri.parse(url));
    //var response = await request.close();
    var bytes = await rootBundle.load("assets/index.pdf");

    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    File file = new File('$dir/$filename');
    //await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton(
          child: Text("Open PDF"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
          ),
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";

  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PDFViewerScaffold(path: pathPDF),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ProgressRate {
  int get position => data.length;
  int total;
  List<int> data;

  bool get isDone => total == position;

  double get value => position / total;

  ProgressRate(this.data, this.total);
}

class NetworkFileUtil {
  static final HttpClient _httpClient = HttpClient();

  static Future<List<int>> download(String url) async {
    final request = await _httpClient.getUrl(Uri.parse(url));
    final HttpClientResponse response = await request.close();
    final List<int> bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }

  static Future<Stream<ProgressRate>> listenDownload(String url) async {
    final request = await _httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    int total = response.contentLength;
    List<int> bytes = [];
    return response.map<ProgressRate>((data) {
      bytes.addAll(data);
      return ProgressRate(bytes, total);
    });
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_text/api/retrofit_clients.dart';
import 'package:flutter_text/model/translate.dart';

class translateApi {
  final BaseOptions baseOptions = BaseOptions(responseType: ResponseType.plain);
  late final TranslateRestClient _client =
      TranslateRestClient(Dio(baseOptions));

  Future getTrans(String form, String to, String word) async {
    Content content;
    ContentE contentE;
    try {
      final dynamic data =
          await _client.getTrans({'a': 'fy', 'f': form, 't': to, 'w': word});
      var json_s = data is String ? json.decode(data) : data;
      if (json_s['status'] == 1) {
        content = Content.formJson(json_s['content']);
        return {'Content': content, 'status': 1};
      } else if (json_s['status'] == 0) {
        contentE = ContentE.formJson(json_s['content']);
        return {'Content': contentE, 'status': 0};
      }
    } catch (e) {
      print('error ==========> $e');
      rethrow;
    }
  }
}

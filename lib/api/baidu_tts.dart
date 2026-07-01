import 'package:dio/dio.dart';
import 'package:flutter_text/api/retrofit_clients.dart';
import 'package:flutter_text/model/baidu_tts.dart';

class BaiduTtsApi {
  final String TokenUrl = 'https://openapi.baidu.com/oauth/2.0/token';
  final String TtsUrl = 'https://tsn.baidu.com/text2audio?tex='; //仅支持中英文
  final String TTs_text = '&lan=zh&cuid=mytextapp&per=0&ctp=1&tok=';
  final apiKey = 'evzV0Wh5trnqcuQGFP0lTONq';
  final appSecret = 'fNw9TvO7ZoiRm9Lyy1aszAyYjVIRHV68';
  final BaseOptions baseOptions = BaseOptions();
  late final BaiduTtsRestClient _client = BaiduTtsRestClient(Dio(baseOptions));
  late Token _token;

  Future<Token> getBaiduToken() async {
    try {
      final dynamic data = await _client.getBaiduToken({
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': appSecret,
      });
      _token = Token.formJson(data);
      return _token;
    } catch (e) {
      print('error ============> $e');
      rethrow;
    }
  }
}

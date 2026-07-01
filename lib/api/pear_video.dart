import 'package:dio/dio.dart';
import 'package:flutter_text/api/retrofit_clients.dart';
import 'package:flutter_text/model/pear_video.dart';
import 'package:self_utils/init.dart';

class PearVideoApi {
  final Dio _dio = Dio();
  late final PearVideoRestClient _client = PearVideoRestClient(_dio);

  Future getPearVideoList() async {
    final headers = await getHeaders();
    try {
      List<ContList> _contList = [];
      ContList cont;
      final dynamic data = await _getPearVideoList(headers);
      List list = data['dataList'][0]['contList'];
      _contList = list.map((e) {
        cont = ContList.fromJson(e);
        cont.nodeInfo =
            NodeInfo.fromJson(cont.mNodeInfo as Map<String, dynamic>);
        return cont;
      }).toList();
      return _contList;
    } catch (e) {
      print('error ============> $e');
      rethrow;
    }
  }

  Future getCategoryList() async {
    final headers = await getHeaders();
    try {
      List<Category> categoryList = [];
      final dynamic data = await _getCategoryList(headers);
      print(data['categoryList']);
      List list = data['categoryList'];
      categoryList = list.map((e) => Category.fromJson(e)).toList();
      return categoryList;
    } catch (e) {
      print('error ============> $e');
      rethrow;
    }
  }

  Future getCategoryDataList(int page, String categoryId) async {
    final headers = await getHeaders();
    try {
      List<HotList> _hotList = [];
      HotList hot;
      final dynamic data = await _getCategoryDataList(headers, {
        'hotPageidx': page,
        'categoryId': categoryId,
      });
      final List list = data['hotList'];
      _hotList = list.map((e) {
        hot = HotList.fromJson(e);
        hot.nodeInfo = NodeInfo.fromJson(hot.mNodeInfo as Map<String, dynamic>);
        return hot;
      }).toList();

      List<Future<Function?>> updateList = []; //强制等待
      _hotList
          .map((el) async => updateList.add((e) async {
                e.videos = await getContentDataList(el.contId!);
              }(el)))
          .toList();
      await Future.wait(updateList);

      return _hotList;
    } catch (e) {
      print('error ============> $e');
      rethrow;
    }
  }

  Future getContentDataList(String contId) async {
    final headers = await getHeaders();
    try {
      Videos _videos;
      final dynamic data = await _getContentDataList(
        headers,
        {'contId': contId},
      );
      _videos = Videos.fromJson(data['content']['videos'][0]);
      return _videos;
    } catch (e) {
      print('error ============> $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getHeaders() async {
    final Map<String, dynamic> headers = <String, dynamic>{};
    headers['X-Channel-Code'] = 'official';
    headers['X-Client-Agent'] = 'Xiaomi';
    headers['X-Client-Hash'] = '2f3d6ffkda95dlz2fhju8d3s6dfges3t';
    headers['X-Client-ID'] = '123456789123456';
    headers['X-Client-Version'] = '2.3.2';
    headers['X-Long-Token'] = '';
    headers['X-Platform-Type'] = '0';
    headers['X-Platform-Version'] = '5.0';
    headers['X-Serial-Num'] =
        '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
    headers['X-User-ID'] = '';
    return headers;
  }

  Future<dynamic> _getPearVideoList(Map<String, dynamic> headers) {
    return _client.getPearVideoList(
      headers['X-Channel-Code'] as String,
      headers['X-Client-Agent'] as String,
      headers['X-Client-Hash'] as String,
      headers['X-Client-ID'] as String,
      headers['X-Client-Version'] as String,
      headers['X-Long-Token'] as String,
      headers['X-Platform-Type'] as String,
      headers['X-Platform-Version'] as String,
      headers['X-Serial-Num'] as String,
      headers['X-User-ID'] as String,
    );
  }

  Future<dynamic> _getCategoryList(Map<String, dynamic> headers) {
    return _client.getCategoryList(
      headers['X-Channel-Code'] as String,
      headers['X-Client-Agent'] as String,
      headers['X-Client-Hash'] as String,
      headers['X-Client-ID'] as String,
      headers['X-Client-Version'] as String,
      headers['X-Long-Token'] as String,
      headers['X-Platform-Type'] as String,
      headers['X-Platform-Version'] as String,
      headers['X-Serial-Num'] as String,
      headers['X-User-ID'] as String,
    );
  }

  Future<dynamic> _getCategoryDataList(
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
  ) {
    return _client.getCategoryDataList(
      headers['X-Channel-Code'] as String,
      headers['X-Client-Agent'] as String,
      headers['X-Client-Hash'] as String,
      headers['X-Client-ID'] as String,
      headers['X-Client-Version'] as String,
      headers['X-Long-Token'] as String,
      headers['X-Platform-Type'] as String,
      headers['X-Platform-Version'] as String,
      headers['X-Serial-Num'] as String,
      headers['X-User-ID'] as String,
      body,
    );
  }

  Future<dynamic> _getContentDataList(
    Map<String, dynamic> headers,
    Map<String, dynamic> queries,
  ) {
    return _client.getContentDataList(
      headers['X-Channel-Code'] as String,
      headers['X-Client-Agent'] as String,
      headers['X-Client-Hash'] as String,
      headers['X-Client-ID'] as String,
      headers['X-Client-Version'] as String,
      headers['X-Long-Token'] as String,
      headers['X-Platform-Type'] as String,
      headers['X-Platform-Version'] as String,
      headers['X-Serial-Num'] as String,
      headers['X-User-ID'] as String,
      queries,
    );
  }
}

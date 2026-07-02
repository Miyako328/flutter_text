import 'dart:convert';

import 'package:http/http.dart' as http;

import 'idle_models.dart';

const String idleApiBase = 'http://192.168.1.108:18980/moonlit/api';

class MoonlitIdleApi {
  const MoonlitIdleApi._();

  static Future<MoonlitIdleState> fetchState() async {
    final Map<String, dynamic> json =
        await _request('$idleApiBase/idle_state.php');
    return MoonlitIdleState.fromJson(json);
  }

  static Future<String> start(String routeKey) async {
    await _request(
      '$idleApiBase/start_idle.php',
      method: 'POST',
      body: <String, String>{'route_key': routeKey},
    );
    return '探索已开始';
  }

  static Future<String> claim() async {
    final Map<String, dynamic> json = await _request(
      '$idleApiBase/claim_idle.php',
      method: 'POST',
    );
    final List<dynamic> rewards =
        (json['rewards'] as List<dynamic>?) ?? <dynamic>[];
    if (rewards.isEmpty) {
      return '探索完成';
    }
    final String text = rewards.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      return '${map['name']} +${map['amount']}';
    }).join('，');
    return '获得：$text';
  }

  static Future<String> upgrade(String upgradeKey) async {
    final Map<String, dynamic> json = await _request(
      '$idleApiBase/upgrade_idle.php',
      method: 'POST',
      body: <String, String>{'upgrade_key': upgradeKey},
    );
    final Map<String, dynamic> upgrade =
        json['upgrade'] as Map<String, dynamic>;
    return '${upgrade['name']} 升至 Lv.${upgrade['level']}';
  }

  static Future<Map<String, dynamic>> _request(
    String url, {
    String method = 'GET',
    Map<String, String>? body,
  }) async {
    final Uri uri = Uri.parse(url);
    final http.Response response;
    if (method == 'POST') {
      response = await http
          .post(uri, body: body ?? <String, String>{})
          .timeout(const Duration(seconds: 12));
    } else {
      response = await http.get(uri).timeout(const Duration(seconds: 12));
    }

    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? '接口请求失败');
    }

    return json;
  }
}

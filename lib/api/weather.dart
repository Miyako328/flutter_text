import 'package:dio/dio.dart';
import 'package:flutter_text/api/retrofit_clients.dart';
import 'package:flutter_text/model/weather.dart';

class WeatherApi {
//  final String key = "4bd90d9b0ddc48d98ad38f8eb5d810f4"; //2466953681@qq.com的key  访问量为1000/1000
  final String key = '43cc143519724d739fb0e717ddf6ab25'; //690575679@qq.com的key
  final BaseOptions baseOptions =
      BaseOptions(connectTimeout: const Duration(seconds: 10));
  late final Dio _dio = Dio(baseOptions);
  late final WeatherRestClient _weatherClient = WeatherRestClient(_dio);
  late final WeatherSearchRestClient _searchClient =
      WeatherSearchRestClient(_dio);

  //获取实时天气
  Future<RealTimeWeather> getRealTimeWeather(String cid) async {
    RealTimeWeather _realTimeWeather;
    try {
      final dynamic data = await _weatherClient.getRealTimeWeather({
        'location': cid,
        'key': key,
      });

      _realTimeWeather = RealTimeWeather.fromJson(data['HeWeather6'].first);
      _realTimeWeather.basic =
          Basic.fromJson(_realTimeWeather.mBasic as Map<String, dynamic>);
      _realTimeWeather.update =
          Update.fromJson(_realTimeWeather.mUpdate as Map<String, dynamic>);
      _realTimeWeather.now =
          Now.fromJson(_realTimeWeather.mNow as Map<String, dynamic>);

      return _realTimeWeather;
    } catch (e) {
      print('getRealTimeWeather error = $e');
      rethrow;
    }
  }

  //获取三天预测天气
  Future<ThreeDaysForecast> getThreeDayWeather(String cid) async {
    ThreeDaysForecast _threeDaysForecast;
    try {
      final dynamic data = await _weatherClient.getThreeDayWeather({
        'location': cid,
        'key': key,
      });
      _threeDaysForecast = ThreeDaysForecast.fromJson(data['HeWeather6'].first);

      _threeDaysForecast.basic =
          Basic.fromJson(_threeDaysForecast.mBasic as Map<String, dynamic>);
      _threeDaysForecast.update =
          Update.fromJson(_threeDaysForecast.mUpdate as Map<String, dynamic>);
      for (Map<String, dynamic> d
          in (_threeDaysForecast.mDailyForecasts as List<dynamic>)) {
        _threeDaysForecast.dailyForecasts?.add(DailyForecast.fromJson(d));
      }
      return _threeDaysForecast;
    } catch (e) {
      print('getThreeDayWeather error = $e');
      rethrow;
    }
  }

  //搜索城市
  Future<List<Basic>> searchCity(String keyword) async {
    try {
      final dynamic data = await _searchClient
          .searchCity({'location': keyword, 'key': key, 'group': 'cn'});

      final List<Basic> cityList = [];
      if (data['HeWeather6'] != null) {
        for (var c in data['HeWeather6'].first['basic']) {
          cityList.add(Basic.fromJson(c));
        }
      }
      print(data);
      return cityList;
    } catch (e) {
      rethrow;
    }
  }
}

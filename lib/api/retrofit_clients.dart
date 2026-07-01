import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'retrofit_clients.g.dart';

@RestApi(baseUrl: 'https://free-api.heweather.net/s6/weather')
abstract class WeatherRestClient {
  factory WeatherRestClient(Dio dio, {String baseUrl}) = _WeatherRestClient;

  @GET('/now')
  Future<dynamic> getRealTimeWeather(@Queries() Map<String, dynamic> queries);

  @GET('/forecast')
  Future<dynamic> getThreeDayWeather(@Queries() Map<String, dynamic> queries);
}

@RestApi(baseUrl: 'https://search.heweather.net')
abstract class WeatherSearchRestClient {
  factory WeatherSearchRestClient(Dio dio, {String baseUrl}) =
      _WeatherSearchRestClient;

  @GET('/find')
  Future<dynamic> searchCity(@Queries() Map<String, dynamic> queries);
}

@RestApi(baseUrl: 'https://app.pearvideo.com/clt/jsp/v2')
abstract class PearVideoRestClient {
  factory PearVideoRestClient(Dio dio, {String baseUrl}) = _PearVideoRestClient;

  @GET('/home.jsp')
  Future<dynamic> getPearVideoList(
    @Header('X-Channel-Code') String channelCode,
    @Header('X-Client-Agent') String clientAgent,
    @Header('X-Client-Hash') String clientHash,
    @Header('X-Client-ID') String clientId,
    @Header('X-Client-Version') String clientVersion,
    @Header('X-Long-Token') String longToken,
    @Header('X-Platform-Type') String platformType,
    @Header('X-Platform-Version') String platformVersion,
    @Header('X-Serial-Num') String serialNum,
    @Header('X-User-ID') String userId,
  );

  @GET('/getCategorys.jsp')
  Future<dynamic> getCategoryList(
    @Header('X-Channel-Code') String channelCode,
    @Header('X-Client-Agent') String clientAgent,
    @Header('X-Client-Hash') String clientHash,
    @Header('X-Client-ID') String clientId,
    @Header('X-Client-Version') String clientVersion,
    @Header('X-Long-Token') String longToken,
    @Header('X-Platform-Type') String platformType,
    @Header('X-Platform-Version') String platformVersion,
    @Header('X-Serial-Num') String serialNum,
    @Header('X-User-ID') String userId,
  );

  @POST('/getCategoryConts.jsp')
  Future<dynamic> getCategoryDataList(
    @Header('X-Channel-Code') String channelCode,
    @Header('X-Client-Agent') String clientAgent,
    @Header('X-Client-Hash') String clientHash,
    @Header('X-Client-ID') String clientId,
    @Header('X-Client-Version') String clientVersion,
    @Header('X-Long-Token') String longToken,
    @Header('X-Platform-Type') String platformType,
    @Header('X-Platform-Version') String platformVersion,
    @Header('X-Serial-Num') String serialNum,
    @Header('X-User-ID') String userId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/content.jsp')
  Future<dynamic> getContentDataList(
    @Header('X-Channel-Code') String channelCode,
    @Header('X-Client-Agent') String clientAgent,
    @Header('X-Client-Hash') String clientHash,
    @Header('X-Client-ID') String clientId,
    @Header('X-Client-Version') String clientVersion,
    @Header('X-Long-Token') String longToken,
    @Header('X-Platform-Type') String platformType,
    @Header('X-Platform-Version') String platformVersion,
    @Header('X-Serial-Num') String serialNum,
    @Header('X-User-ID') String userId,
    @Queries() Map<String, dynamic> queries,
  );
}

@RestApi(baseUrl: 'http://49.234.70.238:9001/book/worm')
abstract class ScanBookPrivateRestClient {
  factory ScanBookPrivateRestClient(Dio dio, {String baseUrl}) =
      _ScanBookPrivateRestClient;

  @GET('/isbn')
  Future<dynamic> isbnGetBookDetail(@Queries() Map<String, dynamic> queries);
}

@RestApi(baseUrl: 'http://jisuisbn.market.alicloudapi.com')
abstract class ScanBookAliRestClient {
  factory ScanBookAliRestClient(Dio dio, {String baseUrl}) =
      _ScanBookAliRestClient;

  @GET('/isbn/query')
  Future<dynamic> isbnGetBookDetail(
    @Header('Authorization') String authorization,
    @Queries() Map<String, dynamic> queries,
  );
}

@RestApi(baseUrl: 'http://fy.iciba.com')
abstract class TranslateRestClient {
  factory TranslateRestClient(Dio dio, {String baseUrl}) = _TranslateRestClient;

  @GET('/ajax.php')
  Future<dynamic> getTrans(@Queries() Map<String, dynamic> queries);
}

@RestApi(baseUrl: 'https://openapi.baidu.com/oauth/2.0')
abstract class BaiduTtsRestClient {
  factory BaiduTtsRestClient(Dio dio, {String baseUrl}) = _BaiduTtsRestClient;

  @POST('/token')
  Future<dynamic> getBaiduToken(@Queries() Map<String, dynamic> queries);
}

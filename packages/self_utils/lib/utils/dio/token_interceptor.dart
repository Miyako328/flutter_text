import 'package:dio/dio.dart';

import '../log_utils.dart';
import 'dio_helper.dart';

class Test {
  String? accessToken;
  String? refreshToken;
}

class TokenInterceptor extends Interceptor {
  TokenInterceptor();

  // 请求前
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Test().accessToken != null || Test().accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = Test().accessToken;
    }
    super.onRequest(options, handler);
  }

  // 请求回调后
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // _checkToken(response);
    super.onResponse(response, handler);
  }

  // 重新请求
  Response<dynamic> _retry(Response<dynamic> response) {
    Log.info(response.toString());
    return response;
  }

  bool _checkToken(Response response) {
    // 判断是否需要刷新Token
    if (response.data != null) {
      return true;
    } else {
      return false;
    }
  }

  // 请求报错后
  @override
  void onError(err, handler) {
    Log.info('onError $err');
    super.onError(err, handler);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:removeit_app/core/config/env_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvConfig.instance.enableLogging && kDebugMode) {
      debugPrint('--> ${options.method} ${options.uri}');
      if (options.data != null && options.data is! FormData) {
        debugPrint('Headers: ${options.headers}');
        debugPrint('Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (EnvConfig.instance.enableLogging && kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('Response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvConfig.instance.enableLogging && kDebugMode) {
      debugPrint('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      debugPrint('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

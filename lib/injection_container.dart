import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:removeit_app/core/network/api_client.dart';
import 'package:removeit_app/core/network/auth_interceptor.dart';
import 'package:removeit_app/core/network/logging_interceptor.dart';
import 'package:removeit_app/core/network/network_info.dart';
import 'package:removeit_app/core/network/retry_interceptor.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // 1. External Third-Party Drivers
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // 2. Core Network & Services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(
        dio: Dio(),
        secureStorage: sl(),
      ));
  sl.registerLazySingleton<LoggingInterceptor>(() => LoggingInterceptor());
  sl.registerLazySingleton<RetryInterceptor>(() => RetryInterceptor());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        authInterceptor: sl(),
        loggingInterceptor: sl(),
        retryInterceptor: sl(),
      ));
}

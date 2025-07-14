import 'package:dio/dio.dart';
import 'package:flutter_kit/src/core/environment.dart';
import 'package:flutter_kit/src/datasource/http/auth_interceptor.dart';
import 'package:get_it/get_it.dart';

class DioConfig {
  late final Dio dio;

  DioConfig({required GetIt locator}) {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in development
    if (Environment.environment == 'dev') {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
    
    // Add auth interceptor
    dio.interceptors.add(AuthInterceptor(dio: dio, locator: locator));
  }
}
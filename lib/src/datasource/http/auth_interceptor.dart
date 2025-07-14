import 'package:dio/dio.dart';
import 'package:flutter_kit/src/datasource/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

class AuthInterceptor extends Interceptor {
  final GetIt _locator;
  final Dio _dio;
  
  AuthInterceptor({
    required GetIt locator,
    required Dio dio,
  }) : 
    _locator = locator,
    _dio = dio;

  AuthRepository get _authRepository => _locator<AuthRepository>();

  @override
  Future<void> onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authRepository.getSavedToken();
    
    if (token != null && !token.isExpired) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err, 
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final token = await _authRepository.getSavedToken();
      
      if (token != null) {
        // Try to refresh the token
        final refreshResponse = await _authRepository.refreshToken();
        
        return refreshResponse.when(
          success: (_) async {
            // Retry the original request with new token
            final opts = err.requestOptions;
            final newToken = await _authRepository.getSavedToken();
            
            if (newToken != null) {
              opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
              
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } on DioException catch (e) {
                return handler.next(e);
              }
            }
            return handler.next(err);
          },
          error: (_) => handler.next(err),
        );
      }
    }
    
    return handler.next(err);
  }
}
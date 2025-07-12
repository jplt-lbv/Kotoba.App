import 'package:dio/dio.dart';
import 'package:flutter_kit/src/datasource/repositories/auth_repository.dart';
import 'package:flutter_kit/src/shared/locator.dart';

class AuthInterceptor extends Interceptor {
  final AuthRepository _authRepository;
  final Dio _dio;
  
  AuthInterceptor({
    AuthRepository? authRepository,
    required Dio dio,
  }) : 
    _authRepository = authRepository ?? locator<AuthRepository>(),
    _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authRepository.getSavedToken();
    
    if (token != null) {
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
      
      if (token != null && !token.isExpired) {
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
          },
          error: (_) => handler.next(err),
        );
      }
    }
    
    return handler.next(err);
  }
}
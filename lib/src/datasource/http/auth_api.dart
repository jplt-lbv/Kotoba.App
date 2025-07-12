import 'package:dio/dio.dart';
import 'package:flutter_kit/src/features/auth/models/auth_models.dart';

class AuthApi {
  final Dio dio;

  AuthApi({required this.dio});

  Future<Map<String, dynamic>> login(AuthCredentials credentials) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': credentials.email,
        'password': credentials.password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await dio.get('/auth/profile');
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }
}
import 'package:flutter_kit/src/datasource/http/auth_api.dart';
import 'package:flutter_kit/src/datasource/models/api_response/api_response.dart';
import 'package:flutter_kit/src/datasource/repositories/base_repository.dart';
import 'package:flutter_kit/src/features/auth/models/auth_models.dart';
import 'package:flutter_kit/src/shared/locator.dart';
import 'package:flutter_kit/src/shared/services/storage/storage.dart';

class AuthRepository extends BaseRepository {
  final AuthApi _authApi;
  final Storage _storage;

  static const String tokenKey = 'auth_token';
  
  AuthRepository({
    AuthApi? authApi,
    Storage? storage,
  }) : 
    _authApi = authApi ?? locator<AuthApi>(),
    _storage = storage ?? locator<Storage>();

  Future<ApiResponse<AuthToken, ApiError>> login(AuthCredentials credentials) async {
    return runApiCall(
      call: () async {
        final response = await _authApi.login(credentials);
        final token = AuthToken(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          expiresAt: DateTime.fromMillisecondsSinceEpoch(response['expires_at']),
        );
        
        // Save token to storage
        await _storage.writeString(key: tokenKey, value: token.accessToken);
        await _storage.writeString(key: '${tokenKey}_refresh', value: token.refreshToken);
        await _storage.writeInt(key: '${tokenKey}_expires', value: token.expiresAt.millisecondsSinceEpoch);
        
        return ApiResponse.success(token);
      },
    );
  }

  Future<ApiResponse<User, ApiError>> getUserProfile() async {
    return runApiCall(
      call: () async {
        final response = await _authApi.getUserProfile();
        final user = User(
          id: response['id'],
          email: response['email'],
          name: response['name'],
        );
        return ApiResponse.success(user);
      },
    );
  }

  Future<ApiResponse<AuthToken, ApiError>> refreshToken() async {
    return runApiCall(
      call: () async {
        final refreshToken = await _storage.read<String>(key: '${tokenKey}_refresh');
        if (refreshToken == null) {
          return ApiResponse.error(ApiError(
            type: ApiErrorType.user,
            error: 'No refresh token found',
            statusCode: 401,
          ));
        }
        
        final response = await _authApi.refreshToken(refreshToken);
        final token = AuthToken(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
          expiresAt: DateTime.fromMillisecondsSinceEpoch(response['expires_at']),
        );
        
        // Update token in storage
        await _storage.writeString(key: tokenKey, value: token.accessToken);
        await _storage.writeString(key: '${tokenKey}_refresh', value: token.refreshToken);
        await _storage.writeInt(key: '${tokenKey}_expires', value: token.expiresAt.millisecondsSinceEpoch);
        
        return ApiResponse.success(token);
      },
    );
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } finally {
      // Clear tokens regardless of API success
      await _storage.remove(key: tokenKey);
      await _storage.remove(key: '${tokenKey}_refresh');
      await _storage.remove(key: '${tokenKey}_expires');
    }
  }

  Future<AuthToken?> getSavedToken() async {
    final accessToken = await _storage.read<String>(key: tokenKey);
    final refreshToken = await _storage.read<String>(key: '${tokenKey}_refresh');
    final expiresAt = await _storage.read<int>(key: '${tokenKey}_expires');
    
    if (accessToken == null || refreshToken == null || expiresAt == null) {
      return null;
    }
    
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt),
    );
  }

  Future<bool> isLoggedIn() async {
    final token = await getSavedToken();
    return token != null && !token.isExpired;
  }
}
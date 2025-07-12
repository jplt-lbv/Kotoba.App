import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit/src/datasource/models/api_response/api_response.dart';
import 'package:flutter_kit/src/datasource/repositories/auth_repository.dart';
import 'package:flutter_kit/src/features/auth/models/auth_models.dart';
import 'package:flutter_kit/src/shared/locator.dart';

part 'auth_state.dart';

class AuthController extends ValueNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController({
    AuthRepository? authRepository,
  })  : _authRepository = authRepository ?? locator<AuthRepository>(),
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    value = AuthLoading();
    
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (!isLoggedIn) {
      value = AuthUnauthenticated();
      return;
    }
    
    final userResponse = await _authRepository.getUserProfile();
    userResponse.when(
      success: (user) => value = AuthAuthenticated(user: user),
      error: (error) => value = AuthUnauthenticated(),
    );
  }

  Future<void> login(String email, String password) async {
    value = AuthLoading();
    
    final credentials = AuthCredentials(email: email, password: password);
    final response = await _authRepository.login(credentials);
    
    response.when(
      success: (_) async {
        final userResponse = await _authRepository.getUserProfile();
        userResponse.when(
          success: (user) => value = AuthAuthenticated(user: user),
          error: (error) => value = AuthError(error: error),
        );
      },
      error: (error) => value = AuthError(error: error),
    );
  }

  Future<void> logout() async {
    value = AuthLoading();
    await _authRepository.logout();
    value = AuthUnauthenticated();
  }

  Future<void> refreshToken() async {
    if (value is AuthAuthenticated) {
      final response = await _authRepository.refreshToken();
      response.when(
        success: (_) {}, // Keep the current authenticated state
        error: (_) => value = AuthUnauthenticated(),
      );
    }
  }
}
import 'package:auto_route/auto_route.dart';
import 'package:flutter_kit/src/core/routing/app_router.dart';
import 'package:flutter_kit/src/datasource/repositories/auth_repository.dart';
import 'package:flutter_kit/src/shared/locator.dart';

class AuthGuard extends AutoRouteGuard {
  final AuthRepository _authRepository;

  AuthGuard({AuthRepository? authRepository})
      : _authRepository = authRepository ?? locator<AuthRepository>();

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      resolver.next(true);
    } else {
      router.replace(const LoginRoute());
    }
  }
}
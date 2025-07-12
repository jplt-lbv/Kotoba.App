import 'package:auto_route/auto_route.dart';
import 'package:flutter_kit/src/core/routing/auth_guard.dart';
import 'package:flutter_kit/src/features/login/ui/login_screen.dart';
import 'package:flutter_kit/src/features/auth/ui/profile_screen.dart';
import 'package:flutter_kit/src/features/home/ui/home_screen.dart';
import 'package:flutter_kit/src/features/splash/ui/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> routes = [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(
      page: HomeRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ProfileRoute.page,
      guards: [AuthGuard()],
    ),
  ];
}

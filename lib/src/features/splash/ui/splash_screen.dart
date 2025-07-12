import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/src/core/routing/app_router.dart';
import 'package:flutter_kit/src/features/auth/logic/auth_controller.dart';
import 'package:flutter_kit/src/shared/components/business/listenable_consumer.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController()..checkAuthStatus(),
      child: Builder(
        builder: (context) {
          final controller = Provider.of<AuthController>(context, listen: false);
          return ListenableConsumer<AuthController>(
            listenable: controller,
            listener: (context, controller) {
              final state = controller.value;
              if (state is AuthAuthenticated) {
                context.router.replace(const HomeRoute());
              } else if (state is AuthUnauthenticated) {
                context.router.replace(const LoginRoute());
              }
            },
            builder: (context, controller) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
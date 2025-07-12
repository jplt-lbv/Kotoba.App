import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/src/core/routing/app_router.dart';
import 'package:flutter_kit/src/core/theme/dimens.dart';
import 'package:flutter_kit/src/features/auth/logic/auth_controller.dart';
import 'package:flutter_kit/src/shared/components/business/listenable_consumer.dart';
import 'package:flutter_kit/src/shared/components/buttons/button.dart';
import 'package:flutter_kit/src/shared/extensions/context_extensions.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              if (state is AuthUnauthenticated) {
                context.router.replace(const LoginRoute());
              }
            },
            builder: (context, controller) {
              final state = controller.value;
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is AuthAuthenticated) {
                final user = state.user;

                return Scaffold(
                  appBar: AppBar(
                    title: Text('Profile'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(Dimens.spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: Dimens.spacing),
                        Text(
                          user.name,
                          style: context.textTheme.headlineMedium,
                        ),
                        Text(
                          user.email,
                          style: context.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: Dimens.tripleSpacing),
                        Button.primary(
                          title: 'Logout',
                          onPressed: () => context.read<AuthController>().logout(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
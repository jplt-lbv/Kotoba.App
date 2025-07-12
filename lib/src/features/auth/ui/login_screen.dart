import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/gen/assets.gen.dart';
import 'package:flutter_kit/src/core/i18n/l10n.dart';
import 'package:flutter_kit/src/core/routing/app_router.dart';
import 'package:flutter_kit/src/core/theme/dimens.dart';
import 'package:flutter_kit/src/datasource/models/api_response/api_response.dart';
import 'package:flutter_kit/src/features/auth/logic/auth_controller.dart';
import 'package:flutter_kit/src/shared/components/app_snackbar.dart';
import 'package:flutter_kit/src/shared/components/atoms/dividers/labeled_divider.dart';
import 'package:flutter_kit/src/shared/components/business/listenable_consumer.dart';
import 'package:flutter_kit/src/shared/components/buttons/button.dart';
import 'package:flutter_kit/src/shared/components/dialogs/loading_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter_kit/src/shared/components/forms/input.dart';
import 'package:flutter_kit/src/shared/extensions/context_extensions.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Builder(
        builder: (context) {
          final controller = Provider.of<AuthController>(context, listen: false);
          return ListenableConsumer<AuthController>(
            listenable: controller,
            listener: (context, controller) {
          final state = controller.value;
          if (state is AuthLoading) {
            LoadingDialog.show(context: context);
          } else {
            LoadingDialog.hide(context: context);

            if (state is AuthAuthenticated) {
              context.router.replace(const HomeRoute());
            } else if (state is AuthError) {
              AppSnackbar.show(
                context: context,
                title: _getErrorMessage(state.error),
                type: AppSnackbarType.danger,
              );
            }
          }
        },
        builder: (context, controller) {
          return Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(Dimens.spacing),
                children: [
                  const SizedBox(height: Dimens.doubleSpacing),
                  Text(
                    I18n.of(context).login_title,
                    style: context.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Text(
                    I18n.of(context).login_subtitle,
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Dimens.tripleSpacing),
                  Input(
                    controller: _emailController,
                    labelText: I18n.of(context).login_emailLabel,
                    hintText: I18n.of(context).login_emailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Input(
                    controller: _passwordController,
                    labelText: I18n.of(context).login_passwordLabel,
                    hintText: I18n.of(context).login_passwordHint,
                    isPassword: true,
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(I18n.of(context).login_forgotPasswordLabel),
                    ),
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Button.primary(
                    title: I18n.of(context).login_submitBtnLabel,
                    onPressed: _onLogin,
                  ),
                  const SizedBox(height: Dimens.doubleSpacing),
                  LabeledDivider(
                    label: I18n.of(context).or,
                  ),
                  const SizedBox(height: Dimens.doubleSpacing),
                  Button.outline(
                    icon: SvgPicture.asset(
                      Assets.images.googleLogo,
                      width: Dimens.iconSize,
                      height: Dimens.iconSize,
                    ),
                    title: I18n.of(context).login_googleBtnLabel,
                    onPressed: () {},
                  ),
                  const SizedBox(height: Dimens.spacing),
                  Button.outline(
                    icon: SvgPicture.asset(
                      Assets.images.appleLogo,
                      colorFilter: ColorFilter.mode(context.colorScheme.onSurface, BlendMode.srcIn),
                      width: Dimens.iconSize,
                      height: Dimens.iconSize,
                    ),
                    title: I18n.of(context).login_appleBtnLabel,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
            },
          );
        },
      ),
    );
  }

  void _onLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;
    context.read<AuthController>().login(email, password);
  }

  String _getErrorMessage(ApiError error) {
    // Extract meaningful error message from ApiError
    if (error.error is String) {
      return error.error as String;
    } else if (error.error is Map) {
      final errorMap = error.error as Map;
      if (errorMap.containsKey('message')) {
        return errorMap['message'] as String;
      }
    }

    // Fallback error messages based on status code
    switch (error.statusCode) {
      case 401:
        return 'Invalid email or password';
      case 422:
        return 'Please check your input and try again';
      case 500:
        return 'Server error. Please try again later';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
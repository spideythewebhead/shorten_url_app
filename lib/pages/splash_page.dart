import 'package:app/app_theme.dart';
import 'package:app/extensions/extensions.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/pages/sign_in/sign_in_page.dart';
import 'package:app/state/app_state.dart';
import 'package:app/widgets/gradient_border.dart';
import 'package:app/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yar/yar.dart';

class SplashPage extends ConsumerWidget {
  static const path = '/splash';

  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          onEnd: () {
            ref.read(appStateProvider.notifier).tryLogin();

            final isLogged = ref //
                .watch(appStateProvider.select((state) => state.isLogged));

            if (isLogged) {
              context.router.replace(HomePage.path);
            } else {
              context.router.replace(SignInPage.path);
            }
          },
          duration: const Duration(seconds: 1),
          curve: Curves.easeInQuad,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (BuildContext context, double value, Widget? child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: RepaintBoundary(
            child: AnimatedGradientBorder(
              duration: const Duration(seconds: 2),
              border: GradientBorderData(
                colors: [
                  context.theme.colorScheme.primary,
                  context.theme.colorScheme.secondary,
                  Colors.grey.shade200,
                  context.theme.colorScheme.primary,
                ],
                radius: AppTheme.radius,
                width: 2.0,
              ),
              child: const AppLogo(),
            ),
          ),
        ),
      ),
    );
  }
}

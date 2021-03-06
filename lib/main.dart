import 'package:app/firebase_config.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/pages/register/register_page.dart';
import 'package:app/pages/sign_in/sign_in_page.dart';
import 'package:app/pages/splash_page.dart';
import 'package:app/app_theme.dart';
import 'package:app/pages/url_created_ad_page.dart';
import 'package:app/state/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yar/yar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  if (kEmulatorsIp.isNotEmpty) {
    await FirebaseAuth.instance.useAuthEmulator(kEmulatorsIp, 9099);
  }

  runApp(
    const ProviderScope(
      child: ShortUrlApp(),
    ),
  );
}

class ShortUrlApp extends ConsumerStatefulWidget {
  const ShortUrlApp({Key? key}) : super(key: key);

  @override
  _ShortUrlAppState createState() => _ShortUrlAppState();
}

class _ShortUrlAppState extends ConsumerState<ShortUrlApp> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: YarRouter(
        builder: (parser, delegate) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routeInformationParser: parser,
            routerDelegate: delegate,
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.dark,
          );
        },
        routes: [
          YarRoute(
            path: SplashPage.path,
            builder: (BuildContext context, YarRouteState state) {
              return const SplashPage();
            },
          ),
          YarRoute(
            path: RegisterPage.path,
            builder: (BuildContext context, YarRouteState state) {
              return const RegisterPage();
            },
          ),
          YarRoute(
            path: SignInPage.path,
            builder: (BuildContext context, YarRouteState state) {
              return const SignInPage();
            },
          ),
          YarRoute(
            path: HomePage.path,
            builder: (BuildContext context, YarRouteState state) {
              return const HomePage();
            },
            redirect: (String path) {
              if (!ref.read(appStateProvider).isLogged) {
                return SplashPage.path;
              }

              return null;
            },
          ),
          YarRoute(
            path: UrlCreatedAdPage.path,
            builder: (BuildContext context, YarRouteState state) {
              return const UrlCreatedAdPage();
            },
          ),
        ],
      ),
    );
  }
}

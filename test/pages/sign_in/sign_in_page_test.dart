import 'package:app/app_input_validators.dart';
import 'package:app/app_theme.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:app/pages/register/register_page.dart';
import 'package:app/pages/sign_in/sign_in_page.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/models/auth_login_result.dart';
import 'package:app/repos/repo_result.dart';
import 'package:app/repos/urls/models/fetch_my_urls.dart';
import 'package:app/state/app_state.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:yar/yar.dart';

import '../../all.mocks.dart';

Finder _findEmailTextfield() => find.byKey(const Key('textfield-email'));
Finder _findPasswordTextfield() => find.byKey(const Key('textfield-password'));
Finder _findSignInButton() => find.byKey(const Key('button-sign-in'));
Finder _findSignUpButton() => find.byKey(const Key('button-sign-up'));
// Finder _findContinueAsGuestButton() =>
//     find.byKey(const Key('button-continue-as-guest'));

Future<void> _pumpBase(
  WidgetTester tester, {
  required List<Override> overrides,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: Consumer(
        builder: (context, ref, child) {
          return YarRouter(
            routes: [
              YarRoute(
                path: SignInPage.path,
                builder: (context, state) {
                  return const SignInPage();
                },
              ),
              YarRoute(
                path: RegisterPage.path,
                builder: (context, state) {
                  return const RegisterPage();
                },
              ),
              YarRoute(
                path: HomePage.path,
                builder: (context, state) {
                  return const HomePage();
                },
                redirect: (path) {
                  if (!ref.read(appStateProvider).isLogged) {
                    return SignInPage.path;
                  }

                  return null;
                },
              ),
            ],
            builder: (parser, delegate) {
              return MaterialApp.router(
                routeInformationParser: parser,
                routerDelegate: delegate,
                themeMode: ThemeMode.dark,
                darkTheme: AppTheme.dark,
              );
            },
          );
        },
      ),
    ),
  );
}

void main() {
  late MockAuthRepo mockAuthRepo;
  late MockUrlsRepo mockUrlsRepo;
  late Repos repos;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockUrlsRepo = MockUrlsRepo();

    repos = Repos(
      auth: mockAuthRepo,
      urls: mockUrlsRepo,
    );
  });

  group('enters credentials', () {
    testWidgets('no errors', (tester) async {
      await _pumpBase(
        tester,
        overrides: [
          reposProvider.overrideWithValue(repos),
        ],
      );

      await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
      await tester.enterText(_findPasswordTextfield(), '123456');
      await tester.pump();

      expect(
        find.byWidgetPredicate(
            (widget) => widget is ElevatedButton && widget.onPressed != null),
        findsOneWidget,
      );
    });

    testWidgets('password length is not at least 6', (tester) async {
      await _pumpBase(
        tester,
        overrides: [
          reposProvider.overrideWithValue(repos),
        ],
      );

      await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
      await tester.enterText(_findPasswordTextfield(), '123');
      await tester.pump();

      expect(
        find.byWidgetPredicate(
            (widget) => widget is ElevatedButton && widget.onPressed == null),
        findsOneWidget,
      );

      expect(
        find.text(
          const AppInputValidationError.atLeastNLengthRequired(6)
              .translatedError(),
        ),
        findsOneWidget,
      );
    });
  });

  group('signs in', () {
    testWidgets('successfully', (tester) async {
      await _pumpBase(
        tester,
        overrides: [
          reposProvider.overrideWithValue(repos),
        ],
      );

      when(mockAuthRepo.login(
        email: 'p.tsakoulis@gmail.com',
        password: '123456',
      )).thenAnswer(
        (_) async {
          return const AuthLoginResult.logged(
            User(uid: '123123', email: 'p.tsakoulis@gmail.com'),
          );
        },
      );

      when(mockUrlsRepo.fetchMyUrls(any)).thenAnswer(
        (_) async => const RepoResult.data(FetchMyUrlsData(
          hasMore: false,
          lastCursorId: null,
          rows: [],
        )),
      );

      await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
      await tester.enterText(_findPasswordTextfield(), '123456');
      await tester.pump();

      await tester.tap(_findSignInButton());
      await tester.pumpAndSettle();

      expect(
        find.text('p.tsakoulis@gmail.com'),
        findsOneWidget,
      );

      expect(
        find.byIcon(Icons.exit_to_app),
        findsOneWidget,
      );
    });

    testWidgets('invalid email', (tester) async {
      await _pumpBase(
        tester,
        overrides: [
          reposProvider.overrideWithValue(repos),
        ],
      );

      when(mockAuthRepo.login(
        email: 'p.tsakoulis@gmail.com',
        password: '123456',
      )).thenAnswer(
        (_) async => const AuthLoginResult.invalidEmail(),
      );

      await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
      await tester.enterText(_findPasswordTextfield(), '123456');
      await tester.pump();

      await tester.tap(_findSignInButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          const AppInputValidationError.invalidEmail().translatedError(),
        ),
        findsOneWidget,
      );
    });

    testWidgets('wrong credentials', (tester) async {
      await _pumpBase(
        tester,
        overrides: [
          reposProvider.overrideWithValue(repos),
        ],
      );

      when(mockAuthRepo.login(
        email: 'p.tsakoulis@gmail.com',
        password: '123456',
      )).thenAnswer(
        (_) async => const AuthLoginResult.wrongPassword(),
      );

      await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
      await tester.enterText(_findPasswordTextfield(), '123456');
      await tester.pump();

      await tester.tap(_findSignInButton());
      await tester.pumpAndSettle();

      expect(
        find.text(
          const AppInputValidationError.invalidCredentials().translatedError(),
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('navigates to register page', (tester) async {
    await _pumpBase(
      tester,
      overrides: [
        reposProvider.overrideWithValue(repos),
      ],
    );

    await tester.tap(_findSignUpButton());
    await tester.pumpAndSettle();

    expect(_findSignUpButton(), findsOneWidget);
  });
}

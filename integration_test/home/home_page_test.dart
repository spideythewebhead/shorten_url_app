import 'package:app/ad_manager.dart';
import 'package:app/main.dart';
import 'package:app/models/app_models.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/auth_repo.dart';
import 'package:app/repos/auth/models/auth_login_result.dart';
import 'package:app/repos/repo_result.dart';
import 'package:app/repos/urls/models/fetch_my_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:yar/yar.dart';

import '../../test/all.mocks.dart';

Finder _findEmailTextfield() => find.byKey(const Key('textfield-email'));
Finder _findPasswordTextfield() => find.byKey(const Key('textfield-password'));
Finder _findSignInButton() => find.byKey(const Key('button-sign-in'));

Finder _findCreateUrlTextfield() =>
    find.byKey(const Key('textfield-create-url'));

void _runAapp({
  required List<Override> providerOverrides,
}) {
  runApp(
    ProviderScope(
      overrides: providerOverrides,
      child: const ShortUrlApp(),
    ),
  );
}

class _FakeAuthRepo extends Fake implements AuthRepo {
  _FakeAuthRepo({
    required this.user,
    required this.loginResult,
  });

  @override
  final User user;

  final AuthLoginResult loginResult;

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) {
    return Future.value(loginResult);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockUrlsRepo mockUrlsRepo;

  setUp(() {
    mockUrlsRepo = MockUrlsRepo();
  });

  group('logins', () {
    group('creates url', () {
      testWidgets('sees an ad', (tester) async {
        final fakeAuthRepo = _FakeAuthRepo(
          user: User.visitor,
          loginResult: const AuthLoginResult.logged(
            User(uid: '123456', email: 'p.tsakoulis@gmail.com'),
          ),
        );

        when(mockUrlsRepo.fetchMyUrls(any)).thenAnswer((_) async {
          return const RepoResult.data(
            FetchMyUrlsData(
              hasMore: false,
              rows: [],
            ),
          );
        });

        when(mockUrlsRepo.createUrl('https://youtube.com')).thenAnswer(
          (_) async {
            return const RepoResult.data(
              ShortenUrl(value: 'abcdef', longUrl: 'https://youtube.com'),
            );
          },
        );

        _runAapp(
          providerOverrides: [
            reposProvider.overrideWithValue(
              Repos(auth: fakeAuthRepo, urls: mockUrlsRepo),
            ),
            adManagerProvider.overrideWithProvider(
              (argument) => adManagerProvider.create(true),
            )
          ],
        );

        await tester.pumpAndSettle();

        await tester.enterText(_findEmailTextfield(), 'p.tsakoulis@gmail.com');
        await tester.enterText(_findPasswordTextfield(), '123123');
        await tester.pump();

        await tester.tap(_findSignInButton());
        await tester.pumpAndSettle();

        await tester.enterText(
          _findCreateUrlTextfield(),
          'https://youtube.com',
        );
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // views an ad
        tester.state<YarRouterState>(find.byType(YarRouter)).pop();
        await tester.pumpAndSettle();

        expect(find.text('abcdef'), findsOneWidget);
        expect(find.text('https://youtube.com'), findsOneWidget);
      });
    });
  });
}

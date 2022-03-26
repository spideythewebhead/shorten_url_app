import 'package:app/app_input_validators.dart';
import 'package:app/models/app_models.dart';
import 'package:app/pages/sign_in/sign_in_page.dart';
import 'package:app/pages/sign_in/sign_in_page_state.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/models/auth_login_result.dart';
import 'package:app/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../all.mocks.dart';
import '../../helper.dart';

void main() {
  late MockAuthRepo mockAuthRepo;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    container = ProviderContainer(
      overrides: [
        reposProvider.overrideWithValue(
          Repos(auth: mockAuthRepo, urls: MockUrlsRepo()),
        )
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  SignInPageState state() => container.read<SignInPageState>(pageStateProvider);
  SignInPageStateNotifier notifier() =>
      container.read<SignInPageStateNotifier>(pageStateProvider.notifier);

  group('emailChanged', () {
    test('without error', () {
      expect(state().email, equals(''));
      expect(state().emailError, isNull);

      notifier().emailChanged('p.tsakoulis@gmail.com');

      expect(state().email, equals('p.tsakoulis@gmail.com'));
      expect(state().emailError, isNull);
    });
  });

  group('passwordChanged', () {
    test('without error', () {
      expect(state().password, equals(''));
      expect(state().passwordError, isNull);

      notifier().passwordChanged('123456');

      expect(state().password, equals('123456'));
      expect(state().passwordError, isNull);
    });

    test('with length error', () {
      expect(state().password, equals(''));
      expect(state().passwordError, isNull);

      notifier().passwordChanged('1234');

      expect(state().password, '1234');
      expect(
        state().passwordError,
        AppInputValidators.validatePassword('1234'),
      );
    });
  });

  group('canSignIn', () {
    test('email & password no errors', () {
      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123456');

      expect(notifier().canSignIn, isTrue);
    });

    test('email has error', () {
      notifier()
        ..emailChanged('')
        ..passwordChanged('123456');

      expect(notifier().canSignIn, isFalse);
    });

    test('password has error', () {
      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('abc');

      expect(notifier().canSignIn, isFalse);
    });

    test('both email & password have errors', () {
      notifier()
        ..emailChanged('')
        ..passwordChanged('abc');

      expect(notifier().canSignIn, isFalse);
    });
  });

  group('signIn', () {
    test('successfully signs in', () async {
      const user = User(uid: '123456', email: 'p.tsakoulis@gmail.com');

      when(mockAuthRepo.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthLoginResult.logged(user));

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      expect(
        notifier().eventStream,
        emitsInOrder([
          const SignInPageEvent.signed(),
        ]),
      );

      notifier().signIn();
      await nextTick();

      expect(container.read(appStateProvider).user, equals(user));
    });

    test('wrong credentials', () async {
      when(mockAuthRepo.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthLoginResult.wrongPassword());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      notifier().signIn();

      expect(state().isLoading, isTrue);

      await nextTick();

      expect(
        state().passwordError,
        equals(const AppInputValidationError.invalidCredentials()),
      );

      expect(state().isLoading, isFalse);
    });

    test('invalid email', () async {
      when(mockAuthRepo.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthLoginResult.invalidEmail());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      notifier().signIn();

      expect(state().isLoading, isTrue);

      await nextTick();

      expect(
        state().emailError,
        equals(const AppInputValidationError.invalidEmail()),
      );

      expect(state().isLoading, isFalse);
    });

    test('fail', () async {
      when(mockAuthRepo.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthLoginResult.failed());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      expect(
        notifier().eventStream,
        emitsInOrder([
          const SignInPageEvent.error(),
        ]),
      );

      notifier().signIn();

      expect(state().isLoading, isTrue);

      await nextTick();

      expect(state().isLoading, isFalse);
    });
  });
}

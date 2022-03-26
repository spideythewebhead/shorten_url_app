import 'package:app/app_input_validators.dart';
import 'package:app/pages/register/register_page.dart';
import 'package:app/pages/register/register_page_state.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/models/create_user_result.dart';
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

    container = ProviderContainer(overrides: [
      reposProvider.overrideWithValue(
        Repos(
          auth: mockAuthRepo,
          urls: MockUrlsRepo(),
        ),
      )
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  RegisterPageState state() =>
      container.read<RegisterPageState>(registerPageStateProvider);
  RegisterPageStateNotifier notifier() => container
      .read<RegisterPageStateNotifier>(registerPageStateProvider.notifier);

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
        equals(AppInputValidators.validatePassword('1234')),
      );
    });
  });

  group('canSignUp', () {
    test('email & password no errors', () {
      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123456');

      expect(notifier().canSignUp, isTrue);
    });

    test('email has error', () {
      notifier()
        ..emailChanged('')
        ..passwordChanged('123456');

      expect(notifier().canSignUp, isFalse);
    });

    test('password has error', () {
      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('abc');

      expect(notifier().canSignUp, isFalse);
    });

    test('both email & password have errors', () {
      notifier()
        ..emailChanged('')
        ..passwordChanged('abc');

      expect(notifier().canSignUp, isFalse);
    });
  });

  group('signUp', () {
    test('successfully', () async {
      when(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthCreateUserResult.created());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      expect(
        notifier().eventStream,
        emitsInOrder([
          const RegisterPageEvent.registered(),
        ]),
      );

      notifier().signUp();
      await nextTick();

      verify(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('email in use', () async {
      when(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthCreateUserResult.emailInUse());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      notifier().signUp();
      await nextTick();

      expect(
        state().emailError,
        equals(const AppInputValidationError.emailInUse()),
      );

      verify(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('invalid email', () async {
      when(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthCreateUserResult.invalidEmail());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123123');

      notifier().signUp();
      await nextTick();

      expect(
        state().emailError,
        equals(const AppInputValidationError.invalidEmail()),
      );

      verify(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('weak password', () async {
      when(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthCreateUserResult.weakPassword());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123456');

      notifier().signUp();
      await nextTick();

      expect(
        state().passwordError,
        equals(const AppInputValidationError.weakPassword()),
      );

      verify(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('unknown', () async {
      when(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const AuthCreateUserResult.unknown());

      notifier()
        ..emailChanged('p.tsakoulis@gmail.com')
        ..passwordChanged('123456');

      expect(
        notifier().eventStream,
        emitsInOrder([
          const RegisterPageEvent.error(),
        ]),
      );

      notifier().signUp();
      await nextTick();

      verify(mockAuthRepo.createUser(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });
  });
}

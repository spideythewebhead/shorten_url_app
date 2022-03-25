import 'package:app/models/app_models.dart' as app_models;
import 'package:app/repos/auth/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../all.mocks.dart';
import '../fakes.dart';

const _email = 'p.tsakoulis@gmail.com';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  group('login', () {
    test('sucessfully logins', () async {
      final fakeUser = FakeFirebaseUser(
        uid: '12345',
        email: _email,
      );

      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockUserCredential.user).thenReturn(fakeUser);

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: '123456',
      )).thenAnswer((_) async => mockUserCredential);

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result = await authRepo.login(
        email: _email,
        password: '123456',
      );

      result.maybeWhen(
        logged: (user) {
          expect(
            user,
            equals(const app_models.User(uid: '12345', email: _email)),
          );
        },
        orElse: () => fail('should be logged'),
      );

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('invalid email', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'p.tsakoulis',
        password: '123456',
      )).thenThrow(FirebaseAuthException(code: 'invalid-email'));

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result = await authRepo.login(
        email: 'p.tsakoulis',
        password: '123456',
      );

      result.maybeWhen(
        invalidEmail: () {},
        orElse: () {
          fail('result should be "invalid email"');
        },
      );
    });

    test('wrong password', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: '123',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result = await authRepo.login(
        email: _email,
        password: '123',
      );

      result.maybeWhen(
        wrongPassword: () {},
        orElse: () {
          fail('result should be "wrong password"');
        },
      );

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });
  });

  group('register', () {
    test('sucessfully registers', () async {
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result =
          await authRepo.createUser(email: _email, password: '123456');

      result.maybeWhen(
        created: () {},
        orElse: () => fail('should be registered'),
      );

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('email in use', () async {
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result =
          await authRepo.createUser(email: _email, password: '123456');

      result.maybeWhen(
        emailInUse: () {},
        orElse: () => fail('should be registered'),
      );

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });

    test('weak password', () async {
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => const Stream.empty());

      when(mockFirebaseAuth.currentUser).thenReturn(null);

      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      final authRepo = AuthRepo(mockFirebaseAuth);

      final result = await authRepo.createUser(email: _email, password: '123');

      result.maybeWhen(
        weakPassword: () {},
        orElse: () => fail('should be registered'),
      );

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).called(1);
    });
  });

  test('is already logged', () {
    final fakeUser = FakeFirebaseUser(uid: '123456', email: _email);

    when(mockFirebaseAuth.authStateChanges())
        .thenAnswer((_) => const Stream.empty());

    when(mockFirebaseAuth.currentUser).thenReturn(fakeUser);

    final authRepo = AuthRepo(mockFirebaseAuth);

    expect(authRepo.user, isNotNull);
  });
}

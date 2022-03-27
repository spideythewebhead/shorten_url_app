import 'dart:async';

import 'package:app/dispose_container.dart';
import 'package:app/models/user.dart';
import 'package:app/repos/auth/models/auth_login_result.dart';
import 'package:app/repos/auth/models/create_user_result.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';

class AuthRepo {
  AuthRepo(this._auth) {
    if (_auth.currentUser != null) {
      _user = User.fromFirebaseUser(_auth.currentUser!);
    }

    _disposableContainer
        .addSubscription(_auth.authStateChanges().listen(_onUserChanged));
  }

  final _disposableContainer = DisposableContainer();
  final FirebaseAuth _auth;

  User _user = User.visitor;
  User get user => _user;

  /// Creates a user with the given [email] and [password]
  ///
  /// On sucess returns:
  ///
  /// - [AuthCreateUserResult.created]
  ///
  /// On failure returns one of the following:
  ///
  /// - [AuthCreateUserResult.emailInUse]
  /// - [AuthCreateUserResult.invalidEmail]
  /// - [AuthCreateUserResult.weakPassword]
  /// - [AuthCreateUserResult.unknown]
  ///
  Future<AuthCreateUserResult> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return const AuthCreateUserResult.created();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return const AuthCreateUserResult.emailInUse();
        case 'invalid-email':
          return const AuthCreateUserResult.invalidEmail();
        case 'weak-password':
          return const AuthCreateUserResult.weakPassword();
      }
    }

    return const AuthCreateUserResult.unknown();
  }

  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credentials.user != null) {
        return AuthLoginResult.logged(
          User.fromFirebaseUser(credentials.user!),
        );
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return const AuthLoginResult.invalidEmail();
        case 'wrong-password':
          return const AuthLoginResult.wrongPassword();
      }
    }

    return const AuthLoginResult.failed();
  }

  Future<bool> logout() async {
    try {
      await _auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('$e');
    }

    return false;
  }

  void dispose() {
    _disposableContainer.dispose();
  }

  void _onUserChanged(user) {
    if (user != null) {
      _user = User.fromFirebaseUser(user);
    } else {
      _user = User.visitor;
    }
  }
}

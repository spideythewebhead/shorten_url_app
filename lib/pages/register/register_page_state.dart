import 'dart:async';

import 'package:app/app_input_validators.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_page_state.freezed.dart';

@freezed
class RegisterPageState with _$RegisterPageState {
  const RegisterPageState._();

  const factory RegisterPageState({
    @Default('') String email,
    @Default('') String password,
    AppInputValidationError? emailError,
    AppInputValidationError? passwordError,
    @Default(false) bool isLoading,
  }) = _RegisterPageState;

  static const initial = RegisterPageState();
}

class RegisterPageStateNotifier extends StateNotifier<RegisterPageState> {
  RegisterPageStateNotifier(this._ref) : super(RegisterPageState.initial);

  final Ref _ref;

  AuthRepo get _authRepo => _ref.read(reposProvider).auth;

  final _eventController = StreamController<RegisterPageEvent>();
  Stream<RegisterPageEvent> get eventStream => _eventController.stream;

  void emailChanged(String email) {
    state = state.copyWith(
      email: email,
      emailError: AppInputValidators.validateEmail(email),
    );
  }

  void passwordChanged(String password) {
    state = state.copyWith(
      password: password,
      passwordError: AppInputValidators.validatePassword(password),
    );
  }

  bool get canSignUp {
    return state.email.trim().isNotEmpty &&
        state.password.trim().isNotEmpty &&
        state.emailError == null &&
        state.passwordError == null;
  }

  void signUp() async {
    if (canSignUp && !state.isLoading) {
      state = state.copyWith(isLoading: true);

      final email = state.email.trim();
      final password = state.password.trim();

      final result = await _authRepo.createUser(
        email: email,
        password: password,
      );

      state = result.when<RegisterPageState>(
        created: () {
          _eventController.add(const RegisterPageEvent.registered());
          return state.copyWith(isLoading: false);
        },
        emailInUse: () {
          return state.copyWith(
            isLoading: false,
            emailError: const AppInputValidationError.emailInUse(),
          );
        },
        invalidEmail: () {
          return state.copyWith(
            isLoading: false,
            emailError: const AppInputValidationError.invalidEmail(),
          );
        },
        weakPassword: () {
          return state.copyWith(
            isLoading: false,
            passwordError: const AppInputValidationError.weakPassword(),
          );
        },
        unknown: () {
          _eventController.add(const RegisterPageEvent.error());
          return state.copyWith(isLoading: false);
        },
      );
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}

@freezed
class RegisterPageEvent with _$RegisterPageEvent {
  const factory RegisterPageEvent.registered() = _$RegisterPageEventRegistered;
  const factory RegisterPageEvent.error() = _$RegisterPageEventError;
}

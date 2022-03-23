import 'dart:async';

import 'package:app/app_input_validators.dart';
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

  bool get canSignUp {
    return emailError == null && passwordError == null;
  }

  static const initial = RegisterPageState();
}

class RegisterPageStateNotifier extends StateNotifier<RegisterPageState> {
  RegisterPageStateNotifier({
    required AuthRepo authRepo,
  })  : _authRepo = authRepo,
        super(RegisterPageState.initial);

  final AuthRepo _authRepo;

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

  void signUp() async {
    if (state.canSignUp && !state.isLoading) {
      state = state.copyWith(isLoading: true);

      final email = state.email.trim();
      final password = state.password.trim();

      final result = await _authRepo.createUser(
        email: email,
        password: password,
      );

      result.when<void>(
        created: () {
          _eventController.add(const RegisterPageEvent.registered());
        },
        emailInUse: () {
          state = state.copyWith(
            isLoading: false,
            emailError: const AppInputValidationError.emailInUse(),
          );
        },
        invalidEmail: () {
          state = state.copyWith(
            isLoading: false,
            emailError: const AppInputValidationError.invalidEmail(),
          );
        },
        weakPassword: () {
          state = state.copyWith(
            isLoading: false,
            passwordError: const AppInputValidationError.weakPassword(),
          );
        },
        unknown: () {
          state = state.copyWith(isLoading: false);
          _eventController.add(const RegisterPageEvent.error());
        },
      );

      state = state.copyWith(isLoading: false);
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

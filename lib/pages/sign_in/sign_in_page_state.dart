import 'dart:async';

import 'package:app/app_input_validators.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/auth_repo.dart';
import 'package:app/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_page_state.freezed.dart';

@freezed
class SignInPageState with _$SignInPageState {
  const factory SignInPageState({
    @Default('') String email,
    @Default('') String password,
    AppInputValidationError? emailError,
    AppInputValidationError? passwordError,
    @Default(false) bool isLoading,
  }) = _SignInPageState;

  static const initial = SignInPageState();
}

@freezed
class SignInPageEvent with _$SignInPageEvent {
  const factory SignInPageEvent.signed() = _$SignInPageEventSigned;
  const factory SignInPageEvent.error() = _$SignInPageEventError;
}

class SignInPageStateNotifier extends StateNotifier<SignInPageState> {
  SignInPageStateNotifier({
    required Ref ref,
  }) : super(SignInPageState.initial) {
    _ref = ref;
    _authRepo = ref.watch(reposProvider).auth;
  }

  late final AuthRepo _authRepo;
  late final Ref _ref;

  final _eventController = StreamController<SignInPageEvent>();
  Stream<SignInPageEvent> get eventStream => _eventController.stream;

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

  bool get canSignIn {
    return state.emailError == null && state.passwordError == null;
  }

  void signIn() async {
    if (canSignIn && !state.isLoading) {
      state = state.copyWith(isLoading: true);

      final result = await _authRepo.login(
        email: state.email.trim(),
        password: state.password.trim(),
      );

      state = result.when<SignInPageState>(
        logged: (user) {
          _ref.read(appStateProvider.notifier).user = user;
          _eventController.add(const SignInPageEvent.signed());

          return state.copyWith(isLoading: false);
        },
        invalidEmail: () {
          return state.copyWith(
            emailError: const AppInputValidationError.invalidEmail(),
            isLoading: false,
          );
        },
        wrongPassword: () {
          return state.copyWith(
            passwordError: const AppInputValidationError.invalidCredentials(),
            isLoading: false,
          );
        },
        failed: () {
          _eventController.add(const SignInPageEvent.error());
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

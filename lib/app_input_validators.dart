import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_input_validators.freezed.dart';

class AppInputValidators {
  static AppInputValidationError? validateEmail(String email) {
    email = email.trim();

    return email.isEmpty ? const AppInputValidationError.required() : null;
  }

  static AppInputValidationError? validatePassword(String password) {
    password = password.trim();

    if (password.length < 6) {
      return const AppInputValidationError.atLeastNLengthRequired(6);
    }

    return null;
  }
}

@freezed
class AppInputValidationError with _$AppInputValidationError {
  const AppInputValidationError._();

  const factory AppInputValidationError.required() = _Required;
  const factory AppInputValidationError.atLeastNLengthRequired(int n) =
      _AtLeastNLengthRequired;
  const factory AppInputValidationError.invalidEmail() = _InvalidEmail;
  const factory AppInputValidationError.invalidCredentials() =
      _InvalidCredentials;
  const factory AppInputValidationError.weakPassword() = _WeakPassword;
  const factory AppInputValidationError.emailInUse() = _EmailInUse;

  String translatedError() {
    return when<String>(
      required: () => 'Required',
      atLeastNLengthRequired: (int length) =>
          'At least $length characters required',
      invalidEmail: () => 'Invalid email',
      invalidCredentials: () => 'Invalid credentials',
      emailInUse: () => 'Email in use',
      weakPassword: () => 'Weak password',
    );
  }
}

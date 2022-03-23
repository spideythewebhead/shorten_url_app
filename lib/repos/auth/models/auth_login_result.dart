import 'package:app/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_login_result.freezed.dart';

@freezed
class AuthLoginResult with _$AuthLoginResult {
  const factory AuthLoginResult.logged(User user) = _AuthLoginResultCreated;

  const factory AuthLoginResult.invalidEmail() = _AuthLoginResultInvalidEmail;

  const factory AuthLoginResult.wrongPassword() =
      _AuthLoginResultInvalidPassword;

  const factory AuthLoginResult.failed() = _AuthLoginResultFailed;
}

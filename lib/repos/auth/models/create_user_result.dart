import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_result.freezed.dart';

@freezed
class AuthCreateUserResult with _$AuthCreateUserResult {
  const factory AuthCreateUserResult.created() = _AuthCreateUserResultCreated;

  const factory AuthCreateUserResult.emailInUse() =
      _AuthCreateUserResultEmailInUse;

  const factory AuthCreateUserResult.invalidEmail() =
      _AuthCreateUserResultInvalidEmail;

  const factory AuthCreateUserResult.weakPassword() =
      _AuthCreateUserResultWeakPassword;

  const factory AuthCreateUserResult.unknown() = _AuthCreateUserResultUnknown;
}

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum ResponseCode {
  @JsonValue('ok')
  ok,
  @JsonValue('unauthorized')
  unauthorized,
  @JsonValue('error')
  error,
  @JsonValue('validationError')
  validationError,
}

abstract class FunctionsBaseResponse {
  ResponseCode get code;
  String? get message;
}

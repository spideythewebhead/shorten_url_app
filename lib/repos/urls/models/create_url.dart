import 'package:app/models/functions_response.dart';
import 'package:app/models/shorten_url.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_url.freezed.dart';
part 'create_url.g.dart';

@freezed
class CreateUrlResponse
    with _$CreateUrlResponse
    implements FunctionsBaseResponse {
  const factory CreateUrlResponse({
    required ResponseCode code,
    String? message,
    ShortenUrl? data,
  }) = _CreateUrlResponse;

  factory CreateUrlResponse.fromJson(Map<String, Object?> json) =>
      _$CreateUrlResponseFromJson(json);
}

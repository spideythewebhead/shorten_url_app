import 'package:freezed_annotation/freezed_annotation.dart';

part 'shorten_url.freezed.dart';
part 'shorten_url.g.dart';

@freezed
class ShortenUrl with _$ShortenUrl {
  const factory ShortenUrl({
    required String value,
    required String longUrl,
  }) = _ShortenUrl;

  factory ShortenUrl.fromJson(Map<String, dynamic> json) =>
      _$ShortenUrlFromJson(json);
}

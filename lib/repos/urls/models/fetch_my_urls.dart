import 'package:app/models/functions_response.dart';
import 'package:app/models/shorten_url.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_my_urls.freezed.dart';
part 'fetch_my_urls.g.dart';

@freezed
class FetchMyUrlsData with _$FetchMyUrlsData {
  const factory FetchMyUrlsData({
    required bool hasMore,
    required List<ShortenUrl> rows,
    String? lastCursorId,
  }) = _Data;

  factory FetchMyUrlsData.fromJson(Map<String, dynamic> json) =>
      _$FetchMyUrlsDataFromJson(json);
}

@freezed
class FetchMyUrlsResponse
    with _$FetchMyUrlsResponse
    implements FunctionsBaseResponse {
  const factory FetchMyUrlsResponse({
    required ResponseCode code,
    String? message,
    FetchMyUrlsData? data,
  }) = _FetchMyUrlsResponse;

  factory FetchMyUrlsResponse.fromJson(Map<String, Object?> json) =>
      _$FetchMyUrlsResponseFromJson(json);
}

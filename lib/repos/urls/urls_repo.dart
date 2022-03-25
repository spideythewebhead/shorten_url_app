import 'dart:convert';

import 'package:app/models/functions_response.dart';
import 'package:app/models/shorten_url.dart';
import 'package:app/repos/repo_result.dart';
import 'package:app/repos/urls/models/create_url.dart';
import 'package:app/repos/urls/models/fetch_my_urls.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UrlsRepo {
  UrlsRepo(this._functions);

  final FirebaseFunctions _functions;

  Future<RepoResult<ShortenUrl>> createUrl(String url) async {
    try {
      final response = await _functions
          .httpsCallable('shortenUrl')({
            'url': url,
          })
          .then((result) => json.decode(result.data))
          .then((data) => CreateUrlResponse.fromJson(data));

      if (response.code == ResponseCode.ok && response.data != null) {
        return RepoResult.data(response.data!);
      }

      return RepoResult.error(response);
    } on FirebaseFunctionsException catch (e) {
      return RepoResult.exception(e);
    } on Exception catch (e) {
      return RepoResult.exception(e);
    }
  }

  Future<RepoResult<FetchMyUrlsData>> fetchMyUrls(String? lastCursorId) async {
    try {
      final response = await _functions
          .httpsCallable('fetchMyUrls')(<String, dynamic>{
            if (lastCursorId != null) 'lastCursorId': lastCursorId,
          })
          .then((result) => json.decode(result.data))
          .then((data) => FetchMyUrlsResponse.fromJson(data));

      if (response.code == ResponseCode.ok && response.data != null) {
        return RepoResult.data(response.data!);
      }

      return RepoResult.error(response);
    } on FirebaseFunctionsException catch (e) {
      return RepoResult.exception(e);
    } on Exception catch (e) {
      return RepoResult.exception(e);
    }
  }
}

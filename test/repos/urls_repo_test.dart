import 'dart:convert';

import 'package:app/models/app_models.dart';
import 'package:app/models/functions_response.dart';
import 'package:app/repos/urls/urls_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../all.mocks.dart';
import '../fakes.dart';

const _longUrl = 'https://youtube.com';

void main() {
  late MockFirebaseFunctions mockFunctions;
  late MockHttpsCallable mockHttpsCallable;

  setUp(() {
    mockFunctions = MockFirebaseFunctions();
    mockHttpsCallable = MockHttpsCallable();
  });

  group('create shorten url', () {
    test('successfully creates', () async {
      final fakeCallableResult = FakeHttpsCallableResult(
        jsonEncode({
          'code': 'ok',
          'data': {
            'value': 'abcdef',
            'longUrl': _longUrl,
          },
        }),
      );

      when(mockHttpsCallable.call(any))
          .thenAnswer((_) async => fakeCallableResult);

      when(mockFunctions.httpsCallable('shortenUrl'))
          .thenReturn(mockHttpsCallable);

      final urlsRepo = UrlsRepo(mockFunctions);

      final result = await urlsRepo.createUrl(_longUrl);

      result.maybeWhen(
        data: (url) {
          expect(
            url,
            isA<ShortenUrl>()
                .having((url) => url.value, 'url.value', 'abcdef')
                .having((url) => url.longUrl, 'url.longUrl', _longUrl),
          );
        },
        orElse: () => fail('should return shorten url'),
      );
    });

    test('fails creation', () async {
      final fakeCallableResult = FakeHttpsCallableResult(
        jsonEncode({
          'code': 'validation_error',
        }),
      );

      when(mockHttpsCallable.call(any))
          .thenAnswer((_) async => fakeCallableResult);

      when(mockFunctions.httpsCallable('shortenUrl'))
          .thenReturn(mockHttpsCallable);

      final urlsRepo = UrlsRepo(mockFunctions);

      final result = await urlsRepo.createUrl(_longUrl);

      result.maybeWhen(
        error: (response) {
          expect(response.code, equals(ResponseCode.validationError));
        },
        orElse: () => fail('should fail with validation error'),
      );
    });
  });

  group('fetch urls', () {
    test('sucessfully fetches', () async {
      final fakeCallableResult1 = FakeHttpsCallableResult(
        jsonEncode({
          'code': 'ok',
          'data': {
            'hasMore': true,
            'lastCursorId': 'url3',
            'rows': [
              const ShortenUrl(value: 'url1', longUrl: 'lurl1'),
              const ShortenUrl(value: 'url2', longUrl: 'lurl2'),
              const ShortenUrl(value: 'url3', longUrl: 'lurl3'),
            ],
          }
        }),
      );

      when(mockHttpsCallable.call({}))
          .thenAnswer((_) async => fakeCallableResult1);

      when(mockFunctions.httpsCallable('fetchMyUrls'))
          .thenReturn(mockHttpsCallable);

      final urlsRepo = UrlsRepo(mockFunctions);

      final result1 = await urlsRepo.fetchMyUrls(null);

      result1.maybeWhen(
        data: (data) {
          expect(data.hasMore, isTrue);
          expect(data.lastCursorId, isNotNull);
          expect(data.rows.length, 3);
        },
        orElse: () => fail('should return data'),
      );

      verify(mockHttpsCallable.call({})).called(1);

      final fakeCallableResult2 = FakeHttpsCallableResult(
        jsonEncode({
          'code': 'ok',
          'data': {
            'hasMore': false,
            'lastCursorId': null,
            'rows': [
              const ShortenUrl(value: 'url4', longUrl: 'lurl4'),
              const ShortenUrl(value: 'url5', longUrl: 'lurl5'),
              const ShortenUrl(value: 'url6', longUrl: 'lurl6'),
            ],
          }
        }),
      );

      when(mockHttpsCallable.call({
        'lastCursorId': 'url3',
      })).thenAnswer((_) async => fakeCallableResult2);

      when(mockFunctions.httpsCallable('fetchMyUrls'))
          .thenReturn(mockHttpsCallable);

      final result2 = await urlsRepo.fetchMyUrls('url3');

      result2.maybeWhen(
        data: (data) {
          expect(data.hasMore, isFalse);
          expect(data.lastCursorId, isNull);
          expect(data.rows.length, 3);
        },
        orElse: () => fail('should return data'),
      );

      verify(
        mockHttpsCallable.call({'lastCursorId': 'url3'}),
      ).called(1);
    });
  });
}

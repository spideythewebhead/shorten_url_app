import 'dart:developer';

import 'package:app/models/shorten_url.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/state/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'home_page_state.freezed.dart';

@freezed
class HomePageState with _$HomePageState {
  const factory HomePageState({
    @Default(false) bool isLoading,
    @Default(UrlsState.initial) UrlsState urlsState,
    @Default(false) bool hasErrorLoading,
    @Default([]) List<String> pendingCreationUrls,
  }) = _HomePageState;

  static const empty = HomePageState(
    urlsState: UrlsState.initial,
  );
}

@freezed
class UrlsState with _$UrlsState {
  const factory UrlsState({
    required List<ShortenUrl> urls,
    required bool hasMore,
    String? lastCursorId,
  }) = _UrlsState;

  static const initial = UrlsState(
    urls: [],
    hasMore: true,
  );
}

class HomePageNotifier extends StateNotifier<HomePageState> {
  HomePageNotifier(this._ref) : super(HomePageState.empty) {
    _loadUrls();
  }

  final Ref _ref;

  Repos get _repos => _ref.read(reposProvider);

  void retryFetchingUrls() {
    _loadUrls();
  }

  void createUrl(String url) async {
    state = state.copyWith(
      pendingCreationUrls: [url, ...state.pendingCreationUrls],
    );

    final response = await _repos.urls.createUrl(url);

    state = response.maybeWhen(
      data: (shortenUrl) {
        _ref.read(appStateProvider.notifier).urlCreated();

        return state.copyWith(
          pendingCreationUrls:
              state.pendingCreationUrls.removeItem((item) => item == url),
          urlsState: state.urlsState.copyWith(
            urls: [
              shortenUrl,
              ...state.urlsState.urls,
            ],
          ),
        );
      },
      orElse: () {
        return state.copyWith(
          pendingCreationUrls:
              state.pendingCreationUrls.removeItem((item) => item == url),
        );
      },
    );
  }

  void _loadUrls() async {
    if (!state.urlsState.hasMore || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    final response =
        await _repos.urls.fetchMyUrls(state.urlsState.lastCursorId);

    state = response.maybeWhen<HomePageState>(
      data: (data) {
        return state.copyWith(
          isLoading: false,
          urlsState: state.urlsState.copyWith(
            urls: [
              ...state.urlsState.urls,
              ...data.rows,
            ],
            lastCursorId: data.lastCursorId,
            hasMore: data.hasMore,
          ),
        );
      },
      orElse: () {
        return state.copyWith(
          isLoading: false,
          hasErrorLoading: true,
        );
      },
    );
  }

  void shareUrl(String shortUrl) async {
    try {
      await Share.share('https://mini-url.web.app/$shortUrl');
    } on PlatformException catch (e) {
      log('$e');
    }
  }
}

extension ListX<T> on List<T> {
  List<T> removeItem(bool Function(T item) match) {
    final index = indexWhere(match);

    if (index == -1) {
      return this;
    }

    return [
      ...sublist(0, index),
      ...sublist(1 + index),
    ];
  }
}

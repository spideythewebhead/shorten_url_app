import 'dart:async';

import 'package:app/models/user.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/repos/auth/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    @Default(User.visitor) User user,
  }) = _AppState;

  bool get isLogged => user != User.visitor;
}

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.urlCreated() = _UrlCreated;
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(
    this._ref,
  ) : super(const AppState());

  late final Ref _ref;

  final _eventEmitter = StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get eventStream => _eventEmitter.stream;

  AuthRepo get _authRepo => _ref.watch(reposProvider).auth;

  set user(User user) {
    state = state.copyWith(user: user);
  }

  void tryLogin() {
    user = _authRepo.user;
  }

  void logout() async {
    if (await _authRepo.logout()) {
      user = User.visitor;
    }
  }

  void urlCreated() {
    _eventEmitter.add(const AppEvent.urlCreated());
  }

  @override
  void dispose() {
    _eventEmitter.close();
    super.dispose();
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(ref),
);

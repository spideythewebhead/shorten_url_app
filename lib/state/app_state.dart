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

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(
    Ref ref,
  ) : super(const AppState()) {
    _ref = ref;
    _authRepo = _ref.watch(reposProvider).auth;
  }

  late final AuthRepo _authRepo;
  late final Ref _ref;

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
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(ref),
);

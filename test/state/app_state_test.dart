import 'package:app/models/user.dart';
import 'package:app/providers/repos_provider.dart';

import 'package:app/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../all.mocks.dart';

const _loggedUser = User(
  uid: '123456',
  email: 'p.tsakoulis@gmail.com',
);

void main() {
  late MockAuthRepo mockAuthRepo;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepo = MockAuthRepo();

    container = ProviderContainer(overrides: [
      reposProvider.overrideWithValue(
        Repos(auth: mockAuthRepo, urls: MockUrlsRepo()),
      ),
    ]);
  });

  test('tryLogin', () {
    when(mockAuthRepo.user).thenReturn(_loggedUser);

    final appStateNotifier = container.read(appStateProvider.notifier);

    expect(container.read(appStateProvider).user, equals(User.visitor));

    appStateNotifier.tryLogin();

    expect(container.read(appStateProvider).user, equals(_loggedUser));

    verify(mockAuthRepo.user).called(1);
  });

  test('logout', () async {
    when(mockAuthRepo.user).thenReturn(_loggedUser);
    when(mockAuthRepo.logout()).thenAnswer((_) async => true);

    final appStateNotifier = container.read(appStateProvider.notifier);

    appStateNotifier.tryLogin();

    expect(container.read(appStateProvider).user, equals(_loggedUser));

    appStateNotifier.logout();
    await container.pump();

    expect(container.read(appStateProvider).user, equals(User.visitor));
  });

  test('urlCreated', () async {
    final appStateNotifier = container.read(appStateProvider.notifier);

    expect(
      appStateNotifier.eventStream,
      emitsInOrder([
        const AppEvent.urlCreated(),
      ]),
    );

    appStateNotifier.urlCreated();
  });
}

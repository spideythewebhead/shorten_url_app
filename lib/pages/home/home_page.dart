import 'package:app/app_theme.dart';
import 'package:app/pages/home/home_page_state.dart';
import 'package:app/pages/home/widgets/pending_urls_list.dart';
import 'package:app/pages/home/widgets/urls_history_list.dart';
import 'package:app/pages/sign_in/sign_in_page.dart';
import 'package:app/providers/repos_provider.dart';
import 'package:app/state/app_state.dart';
import 'package:app/widgets/app_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yar/yar.dart';

import 'widgets/short_url_textfield.dart';

final homePageStateProvider =
    StateNotifierProvider<HomePageNotifier, HomePageState>((ref) {
  return HomePageNotifier(ref.read(reposProvider));
});

class HomePage extends ConsumerStatefulWidget {
  static const path = '/';

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _onLogStateChanged(bool? wasLogged, bool isLogged) {
    if ((wasLogged ?? false) && !isLogged) {
      context.router.popUntilAndPush('', SignInPage.path);
    }
  }

  void setStateChangedListeners() {
    ref.listen(
      appStateProvider.select((state) => state.isLogged),
      _onLogStateChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    setStateChangedListeners();

    final user = ref.watch(appStateProvider.select((state) => state.user));

    return Scaffold(
      appBar: AppBar(
        title: Text(user.email),
        actions: [
          AppIconButton(
            onPressed: () {
              ref.watch(appStateProvider.notifier).logout();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
            padding: AppSpacing.paddingAll12,
            child: CreateShortUrlTextField(),
          ),
          Flexible(
            child: Padding(
              padding: AppSpacing.paddingHorizontal12,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: AppSpacing.paddingVertical12,
                    sliver: PendingUrlsTitle(),
                  ),
                  PendingUrlsList(),
                  SliverPadding(
                    padding: AppSpacing.paddingVertical12,
                    sliver: UrlsHistoryTitle(),
                  ),
                  UrlsHistoryList(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

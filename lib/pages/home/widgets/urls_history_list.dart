import 'package:app/app_theme.dart';
import 'package:app/extensions/extensions.dart';
import 'package:app/models/shorten_url.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrlsHistoryList extends ConsumerWidget {
  const UrlsHistoryList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homePageStateProvider);
    final urlsState = state.urlsState;

    final notifier = ref.watch(homePageStateProvider.notifier);

    if (state.hasErrorLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('An error occured'),
              AppSpacing.verticalMargin8,
              ElevatedButton(
                child: const Text('Try again..'),
                onPressed: notifier.retryFetchingUrls,
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (urlsState.urls.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('No urls found.. Time to add one 😊'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index.isOdd) {
            return AppSpacing.verticalMargin8;
          }

          index ~/= 2;

          if (index == urlsState.urls.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final item = urlsState.urls[index];
          return _ShortUrlView(
            key: ValueKey(item.value),
            shortUrl: item,
          );
        },
        childCount: 2 * urlsState.urls.length + (state.isLoading ? 1 : 0),
      ),
    );
  }
}

class UrlsHistoryTitle extends StatelessWidget {
  const UrlsHistoryTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(
        'Short URLs',
        style: context.theme.textTheme.titleMedium,
      ),
    );
  }
}

class _ShortUrlView extends ConsumerWidget {
  const _ShortUrlView({
    Key? key,
    required this.shortUrl,
  }) : super(key: key);

  final ShortenUrl shortUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () {
          ref.read(homePageStateProvider.notifier).shareUrl(shortUrl.value);
        },
        child: Padding(
          padding: AppSpacing.paddingAll8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.short_text),
                  AppSpacing.horizontalMargin4,
                  Text(shortUrl.value),
                ],
              ),
              const Divider(),
              Flexible(
                child: Row(
                  children: [
                    const Icon(Icons.link),
                    AppSpacing.horizontalMargin4,
                    Flexible(child: Text(shortUrl.longUrl)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

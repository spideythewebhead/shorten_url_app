import 'package:app/app_theme.dart';
import 'package:app/extensions/extensions.dart';
import 'package:app/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingUrlsList extends ConsumerWidget {
  const PendingUrlsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = ref.watch(
      homePageStateProvider.select((state) => state.pendingCreationUrls),
    );

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final url in urls) ...[
            _PendingUrlView(
              key: ValueKey(url),
              url: url,
            ),
            AppSpacing.verticalMargin8,
          ]
        ],
      ),
    );
  }
}

class PendingUrlsTitle extends StatelessWidget {
  const PendingUrlsTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text(
        'Pending URLs',
        style: context.theme.textTheme.titleMedium,
      ),
    );
  }
}

class _PendingUrlView extends StatelessWidget {
  const _PendingUrlView({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.paddingAll12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: Text(url)),
            const SizedBox.square(
              dimension: 20.0,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

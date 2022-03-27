import 'package:app/ad_manager.dart';
import 'package:app/widgets/empty_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yar/yar.dart';

class UrlCreatedAdPage extends ConsumerStatefulWidget {
  static const path = '/url_created_ad';

  const UrlCreatedAdPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UrlCreatedAdPage> createState() => _UrlCreatedAdPageState();
}

class _UrlCreatedAdPageState extends ConsumerState<UrlCreatedAdPage> {
  late final AppAdManager _adManager =
      ref.read<AppAdManager>(adManagerProvider(kDebugMode));

  InterstitialAd? _interstitialAd;
  late InterstitialAdLoadCallback _adLoadCallback;
  late FullScreenContentCallback<InterstitialAd> _fullScreenContentCallback;

  var _adLoaded = false;

  @override
  void initState() {
    super.initState();

    _adLoadCallback = _createCallback();
    _fullScreenContentCallback = _createFullScreenContentCallback();

    _adManager.shortenUrlCreated(callback: _adLoadCallback);
  }

  FullScreenContentCallback<InterstitialAd> _createFullScreenContentCallback() {
    return FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        context.router.pop();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        context.router.pop();
      },
    );
  }

  InterstitialAdLoadCallback _createCallback() {
    return InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitialAd = ad;
        ad.fullScreenContentCallback = _fullScreenContentCallback;

        setState(() {
          _adLoaded = true;
          ad.show();
        });
      },
      onAdFailedToLoad: (ad) {
        context.router.pop();
      },
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => SynchronousFuture(false),
        child: _adLoaded ? emptyWidget : const _LoadingStateView(),
      ),
    );
  }
}

class _LoadingStateView extends StatelessWidget {
  const _LoadingStateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

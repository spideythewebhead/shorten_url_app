import 'package:app/ad_manager.dart';
import 'package:app/widgets/empty_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeBottomBanner extends ConsumerStatefulWidget {
  const HomeBottomBanner({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeBottomBanner> createState() => _HomeBottomBannerState();
}

class _HomeBottomBannerState extends ConsumerState<HomeBottomBanner> {
  late final AppAdManager _adManager =
      ref.read<AppAdManager>(adManagerProvider(kDebugMode));

  BannerAd? _bannerAd;
  late final BannerAdListener _adListener;

  var _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _adListener = _createListener();
    _bannerAd = _adManager.homePageBanner(listener: _adListener)..load();
  }

  @override
  void reassemble() {
    super.reassemble();
    _bannerAd?.dispose();

    _bannerAd = _adManager.homePageBanner(listener: _adListener)..load();
  }

  BannerAdListener _createListener() {
    return BannerAdListener(
      onAdLoaded: (ad) {
        setState(() {
          _isAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) async {
        debugPrint('add failed to load $error');
        await ad.dispose();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _isAdLoaded
          ? SizedBox(
              key: const Key('home-banner-ad'),
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : emptyWidget,
    );
  }
}

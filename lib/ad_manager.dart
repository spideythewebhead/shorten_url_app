import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

R runOnPlatform<R>({
  required R Function() android,
  required R Function() iOS,
}) {
  if (Platform.isAndroid) {
    return android();
  }

  if (Platform.isIOS) {
    return iOS();
  }

  throw 'should never reach here';
}

late final _testIds = <String, ValueGetter<String>>{
  'home-bottom-banner': () => 'ca-app-pub-3940256099942544/6300978111',
  'shorten-url-created': () => 'ca-app-pub-3940256099942544/1033173712',
};

late final _prodIds = <String, ValueGetter<String>>{
  'home-bottom-banner': () {
    return runOnPlatform(
      android: () => 'ca-app-pub-7487177115263550/2515146804',
      iOS: () => '',
    );
  },
  'shorten-url-created': () {
    return runOnPlatform(
      android: () => 'ca-app-pub-7487177115263550/9128656610',
      iOS: () => '',
    );
  }
};

class AppAdManager {
  AppAdManager(this.useTestIds);

  final bool useTestIds;

  String _getAdId(String key) {
    final lookup = useTestIds ? _testIds : _prodIds;

    return lookup[key]?.call() ?? '';
  }

  BannerAd homePageBanner({
    required BannerAdListener listener,
    AdRequest request = const AdRequest(),
    AdSize? size,
  }) {
    return BannerAd(
      size: size ?? AdSize.banner,
      adUnitId: _getAdId('home-bottom-banner'),
      listener: listener,
      request: request,
    );
  }

  Future<void> shortenUrlCreated({
    required InterstitialAdLoadCallback callback,
    AdRequest request = const AdRequest(),
  }) {
    return InterstitialAd.load(
      adLoadCallback: callback,
      adUnitId: _getAdId('shorten-url-created'),
      request: request,
    );
  }
}

final adManagerProvider =
    Provider.family<AppAdManager, bool>((ref, v) => AppAdManager(v));

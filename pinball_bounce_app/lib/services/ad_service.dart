import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants.dart';

/// Abstract base so we can mock in tests.
abstract class AdServiceBase {
  Future<void> initialize();
  Future<void> showInterstitialIfReady(int gamesCompleted);
  Future<bool> showRewardedAd();
  void setAdsRemoved(bool removed);
  void dispose();
}

class AdService implements AdServiceBase {
  bool _adsRemoved = false;
  int _gamesSinceLastAd = 0;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Test ad unit IDs (official Google test IDs).
  String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  String get _rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  @override
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    if (!_adsRemoved) {
      _loadInterstitial();
      _loadRewarded();
    }
  }

  @override
  Future<void> showInterstitialIfReady(int gamesCompleted) async {
    if (_adsRemoved) return;

    _gamesSinceLastAd++;
    if (_gamesSinceLastAd < GameConstants.adFrequencyGames) return;

    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );

    await _interstitialAd!.show();
    _gamesSinceLastAd = 0;
  }

  @override
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
      },
    );

    return rewarded;
  }

  @override
  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _rewardedAd?.dispose();
      _rewardedAd = null;
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  void _loadInterstitial() {
    if (_adsRemoved || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void _loadRewarded() {
    if (_isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
        },
      ),
    );
  }
}

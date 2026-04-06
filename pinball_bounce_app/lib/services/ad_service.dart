/// Stub – ads removed. All methods are no-ops.
abstract class AdServiceBase {
  Future<void> initialize();
  Future<void> showInterstitialIfReady(int gamesCompleted);
  Future<bool> showRewardedAd();
  void setAdsRemoved(bool removed);
  void dispose();
}

class AdService implements AdServiceBase {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showInterstitialIfReady(int gamesCompleted) async {}

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  void setAdsRemoved(bool removed) {}

  @override
  void dispose() {}
}

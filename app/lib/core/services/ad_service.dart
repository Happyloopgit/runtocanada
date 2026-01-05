import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:run_to_canada/app/env.dart';

/// Service for managing AdMob ads
/// Handles banner ads and interstitial ads for free tier users
class AdService {
  AdService._();
  static final AdService _instance = AdService._();
  factory AdService() => _instance;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _interstitialAdCounter = 0;

  /// Frequency: show interstitial ad every N run completions
  static const int interstitialFrequency = 3;

  /// Initialize Google Mobile Ads SDK
  /// Call this once during app initialization
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Get the appropriate banner ad unit ID for current platform
  String get _bannerAdUnitId {
    if (Platform.isIOS) {
      return Env.admobBannerAdUnitIdIos;
    } else if (Platform.isAndroid) {
      return Env.admobBannerAdUnitIdAndroid;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get the appropriate interstitial ad unit ID for current platform
  String get _interstitialAdUnitId {
    if (Platform.isIOS) {
      return Env.admobInterstitialAdUnitIdIos;
    } else if (Platform.isAndroid) {
      return Env.admobInterstitialAdUnitIdAndroid;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Load banner ad for home screen
  /// Returns the loaded banner ad or null if loading fails
  Future<BannerAd?> loadBannerAd({
    required Function() onAdLoaded,
    required Function(LoadAdError error) onAdFailedToLoad,
  }) async {
    // Dispose existing banner ad if any
    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          onAdFailedToLoad(error);
        },
        onAdOpened: (ad) {
          // Ad opened (user clicked)
        },
        onAdClosed: (ad) {
          // Ad closed
        },
      ),
    );

    await _bannerAd!.load();
    return _bannerAd;
  }

  /// Get current banner ad
  BannerAd? get bannerAd => _bannerAd;

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  /// Load interstitial ad
  /// Preload the ad so it's ready to show when needed
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              // Ad showed
            },
            onAdDismissedFullScreenContent: (ad) {
              // Ad dismissed, dispose and load next one
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Ad failed to show
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              // Preload next interstitial ad
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Check if interstitial ad should be shown (based on frequency)
  /// Call this after each run completion
  /// Returns true if ad should be shown
  bool shouldShowInterstitialAd() {
    _interstitialAdCounter++;
    return _interstitialAdCounter % interstitialFrequency == 0;
  }

  /// Show interstitial ad if ready
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      return false;
    }

    await _interstitialAd!.show();
    return true;
  }

  /// Check if interstitial ad is ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  /// Dispose all ads and clean up resources
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}

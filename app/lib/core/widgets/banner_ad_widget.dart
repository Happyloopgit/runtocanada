import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:run_to_canada/core/services/ad_service_provider.dart';
import 'package:run_to_canada/features/premium/presentation/providers/premium_providers.dart';

/// Banner Ad Widget
/// Displays a banner ad for free tier users
/// Automatically hidden for premium users
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasFailedToLoad = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  /// Load banner ad
  Future<void> _loadAd() async {
    final adService = ref.read(adServiceProvider);

    await adService.loadBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _bannerAd = adService.bannerAd;
            _isAdLoaded = true;
            _hasFailedToLoad = false;
          });
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _hasFailedToLoad = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // Don't dispose here - AdService manages lifecycle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is premium
    final isPremium = ref.watch(isPremiumProvider);

    // Don't show ad to premium users
    if (isPremium.value == true) {
      return const SizedBox.shrink();
    }

    // Don't show anything if ad failed to load
    if (_hasFailedToLoad || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Show banner ad
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

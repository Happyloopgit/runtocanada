/// Environment configuration for different build flavors
enum Environment {
  dev,
  staging,
  production,
}

class Env {
  /// Get current environment based on dart-define
  static Environment get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.dev,
    );
  }

  /// Get environment name as string
  static String get environmentName => current.name;

  /// Check if current environment is development
  static bool get isDevelopment => current == Environment.dev;

  /// Check if current environment is staging
  static bool get isStaging => current == Environment.staging;

  /// Check if current environment is production
  static bool get isProduction => current == Environment.production;

  /// API base URL based on environment
  static String get apiBaseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.staging:
        return 'https://staging-api.runtocanada.app';
      case Environment.production:
        return 'https://api.runtocanada.app';
    }
  }

  /// Mapbox access token (load from environment variable)
  /// For production, set MAPBOX_TOKEN environment variable
  /// Development default token provided for convenience
  /// IMPORTANT: This must be a PUBLIC token (starts with 'pk.'), not a SECRET token
  static String get mapboxToken => const String.fromEnvironment(
        'MAPBOX_TOKEN',
        defaultValue: 'pk.eyJ1IjoiaGFwcHlsb29wIiwiYSI6ImNtazJsMjN5MjBkOXozZHM3aWRlN2lnc2IifQ.3g0WEGWP4VAANr_POgm58Q',
      );

  /// Unsplash API key (load from environment variable)
  static String get unsplashKey => const String.fromEnvironment(
        'UNSPLASH_KEY',
        defaultValue: '',
      );

  /// Sentry DSN for error tracking (load from environment variable)
  static String get sentryDsn => const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      );

  /// RevenueCat API Keys (load from environment variable)
  /// Get these from RevenueCat Dashboard after creating your project
  /// iOS uses the Apple App Store API key
  /// Android uses the Google Play Store API key
  static String get revenueCatAppleApiKey => const String.fromEnvironment(
        'REVENUECAT_APPLE_API_KEY',
        defaultValue: '',
      );

  static String get revenueCatGoogleApiKey => const String.fromEnvironment(
        'REVENUECAT_GOOGLE_API_KEY',
        defaultValue: '',
      );

  /// RevenueCat Product IDs
  /// These match the product IDs configured in App Store Connect and Google Play Console
  static const String monthlyProductId = 'premium_monthly';
  static const String annualProductId = 'premium_annual';

  /// AdMob App IDs (load from environment variable)
  /// Get these from AdMob Console after creating your app
  /// iOS uses ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY format
  /// Android uses ca-app-pub-XXXXXXXXXXXXXXXX~ZZZZZZZZZZ format
  /// For testing, use test IDs provided by Google
  static String get admobAppIdIos => const String.fromEnvironment(
        'ADMOB_APP_ID_IOS',
        defaultValue:
            'ca-app-pub-3940256099942544~1458002511', // Test ID for development
      );

  static String get admobAppIdAndroid => const String.fromEnvironment(
        'ADMOB_APP_ID_ANDROID',
        defaultValue:
            'ca-app-pub-3940256099942544~3347511713', // Test ID for development
      );

  /// AdMob Ad Unit IDs
  /// These are test IDs - replace with real IDs in production
  static String get admobBannerAdUnitIdIos => const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID_IOS',
        defaultValue: 'ca-app-pub-3940256099942544/2934735716', // Test banner
      );

  static String get admobBannerAdUnitIdAndroid => const String.fromEnvironment(
        'ADMOB_BANNER_AD_UNIT_ID_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111', // Test banner
      );

  static String get admobInterstitialAdUnitIdIos =>
      const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS',
        defaultValue:
            'ca-app-pub-3940256099942544/4411468910', // Test interstitial
      );

  static String get admobInterstitialAdUnitIdAndroid =>
      const String.fromEnvironment(
        'ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID',
        defaultValue:
            'ca-app-pub-3940256099942544/1033173712', // Test interstitial
      );

  /// Enable debug logs
  static bool get enableDebugLogs => !isProduction;

  /// Enable analytics
  static bool get enableAnalytics => isProduction || isStaging;
}

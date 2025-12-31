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
  static String get mapboxToken => const String.fromEnvironment(
        'MAPBOX_TOKEN',
        defaultValue: 'pk.eyJ1IjoiaGFwcHlsb29wIiwiYSI6ImNtanNqaXhwdTJnc2Uya3Nkd2ZuaWdmcHYifQ.GRxjzAh8Fwc9--MvJvjLSg',
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

  /// Enable debug logs
  static bool get enableDebugLogs => !isProduction;

  /// Enable analytics
  static bool get enableAnalytics => isProduction || isStaging;
}

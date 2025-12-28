/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Run to Canada';
  static const String appTagline = 'Transform your daily runs into virtual journeys';

  // Free Tier Limit
  static const double freeTierDistanceLimitKm = 100.0; // 100km limit for free users
  static const double freeTierDistanceMeters = freeTierDistanceLimitKm * 1000;

  // GPS Tracking
  static const double gpsDistanceFilter = 10.0; // meters
  static const int gpsAccuracyHigh = 10; // meters
  static const int autoSaveInterval = 10; // Save every 10 GPS points

  // Milestones
  static const double milestoneIntervalKm = 50.0; // Generate milestone every 50km
  static const double milestoneIntervalMeters = milestoneIntervalKm * 1000;

  // Cache Duration
  static const int photoCacheDays = 30;
  static const int apiCacheDays = 7;

  // Sync
  static const int syncIntervalSeconds = 30;
  static const int maxRetryAttempts = 3;

  // Units
  static const String metricUnit = 'metric';
  static const String imperialUnit = 'imperial';

  // Map Styles
  static const String mapStyleStreets = 'streets';
  static const String mapStyleSatellite = 'satellite';
  static const String mapStyleOutdoors = 'outdoors';

  // Default Values
  static const String defaultMapStyle = mapStyleStreets;
  static const String defaultUnit = metricUnit;

  // Conversion Factors
  static const double metersToKm = 0.001;
  static const double metersToMiles = 0.000621371;
  static const double kmToMiles = 0.621371;
  static const double milesToKm = 1.60934;

  // Time Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';

  // Premium Pricing
  static const double monthlyPrice = 2.99;
  static const double annualPrice = 19.99;
  static const String currency = 'USD';

  // API Limits
  static const int unsplashRequestsPerHour = 50;
  static const int mapboxRequestsPerMonth = 200000;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxRunNotesLength = 500;
  static const int maxGoalNameLength = 100;
}

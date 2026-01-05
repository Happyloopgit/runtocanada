import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/services/ad_service.dart';

/// Provider for AdService singleton instance
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:run_to_canada/features/auth/domain/models/user_model.dart';
import 'package:run_to_canada/features/goals/data/datasources/goal_local_datasource.dart';

/// Service to manage premium features and limitations
class PremiumService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoalLocalDataSource _goalLocalDataSource;

  static const double freeTierLimitKm = 100.0;

  PremiumService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required GoalLocalDataSource goalLocalDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _goalLocalDataSource = goalLocalDataSource;

  /// Check if the current user has premium access
  Future<bool> isPremiumUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;

      final userData = doc.data();
      return userData?['isPremium'] as bool? ?? false;
    } catch (e) {
      // In case of error, assume not premium
      return false;
    }
  }

  /// Get the premium status from a UserModel
  bool isPremiumFromUserModel(UserModel user) {
    return user.isPremium;
  }

  /// Check if user has reached the free tier limit
  Future<bool> hasReachedFreeLimit() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return false; // Premium users have no limit

    return await _checkDistanceLimit();
  }

  /// Check if user can create a new goal (based on free tier limit)
  Future<bool> canCreateGoal() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true; // Premium users can always create goals

    return !(await _checkDistanceLimit());
  }

  /// Check if user can start a new run (based on active goal progress)
  Future<bool> canStartRun() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return true; // Premium users can always run

    final user = _auth.currentUser;
    if (user == null) return false;

    final activeGoal = _goalLocalDataSource.getActiveGoalSafe(user.uid);
    if (activeGoal == null) return true; // No goal, can run freely

    return activeGoal.currentProgress < freeTierLimitKm * 1000; // Convert km to meters
  }

  /// Get remaining distance before hitting free tier limit
  Future<double> getRemainingFreeDistance() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return double.infinity; // No limit for premium

    final user = _auth.currentUser;
    if (user == null) return freeTierLimitKm;

    final activeGoal = _goalLocalDataSource.getActiveGoalSafe(user.uid);
    if (activeGoal == null) return freeTierLimitKm; // Full limit available

    final currentDistanceKm = activeGoal.currentProgress / 1000;
    final remaining = freeTierLimitKm - currentDistanceKm;
    return remaining > 0 ? remaining : 0;
  }

  /// Get current progress toward free tier limit (0.0 to 1.0)
  Future<double> getFreeLimitProgress() async {
    final isPremium = await isPremiumUser();
    if (isPremium) return 0.0; // No progress bar for premium

    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final activeGoal = _goalLocalDataSource.getActiveGoalSafe(user.uid);
    if (activeGoal == null) return 0.0;

    final currentDistanceKm = activeGoal.currentProgress / 1000;
    final progress = currentDistanceKm / freeTierLimitKm;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Update user's premium status in Firestore
  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isPremium': isPremium,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update premium status: $e');
    }
  }

  /// Check if user's active goal has reached the distance limit
  Future<bool> _checkDistanceLimit() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final activeGoal = _goalLocalDataSource.getActiveGoalSafe(user.uid);
    if (activeGoal == null) return false; // No goal, no limit reached

    final currentDistanceKm = activeGoal.currentProgress / 1000;
    return currentDistanceKm >= freeTierLimitKm;
  }

  /// Get premium benefits as a list of strings for display
  static List<String> getPremiumBenefits() {
    return [
      'Unlimited journey distance',
      'Create unlimited goals',
      'No advertisements',
      'Priority support',
      'Early access to new features',
    ];
  }

  /// Get pricing information
  static Map<String, dynamic> getPricingInfo() {
    return {
      'monthly': {
        'price': 2.99,
        'currency': 'USD',
        'period': 'month',
        'displayPrice': '\$2.99/month',
      },
      'annual': {
        'price': 19.99,
        'currency': 'USD',
        'period': 'year',
        'displayPrice': '\$19.99/year',
        'savings': '44%', // vs monthly ($35.88/year)
        'monthlyCost': '\$1.67/month',
      },
    };
  }
}

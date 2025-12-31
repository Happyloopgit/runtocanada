import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/runs/domain/models/run_model.dart';
import '../../../features/goals/domain/models/goal_model.dart';

/// Firestore data source for cloud storage operations
class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collections
  static const String runsCollection = 'runs';
  static const String goalsCollection = 'goals';
  static const String usersCollection = 'users';

  // RUNS

  /// Save a run to Firestore
  Future<void> saveRun(RunModel run) async {
    await _firestore
        .collection(usersCollection)
        .doc(run.userId)
        .collection(runsCollection)
        .doc(run.id)
        .set(run.toFirestore(), SetOptions(merge: true));
  }

  /// Fetch all runs for a user from Firestore
  Future<List<RunModel>> fetchRuns(String userId) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(runsCollection)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RunModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Fetch a single run by ID
  Future<RunModel?> fetchRunById(String userId, String runId) async {
    final doc = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(runsCollection)
        .doc(runId)
        .get();

    if (!doc.exists) return null;
    return RunModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Delete a run from Firestore
  Future<void> deleteRun(String userId, String runId) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(runsCollection)
        .doc(runId)
        .delete();
  }

  /// Update run notes
  Future<void> updateRunNotes(String userId, String runId, String notes) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(runsCollection)
        .doc(runId)
        .update({'notes': notes});
  }

  // GOALS

  /// Save a goal to Firestore
  Future<void> saveGoal(GoalModel goal) async {
    await _firestore
        .collection(usersCollection)
        .doc(goal.userId)
        .collection(goalsCollection)
        .doc(goal.id)
        .set(goal.toFirestore(), SetOptions(merge: true));
  }

  /// Fetch all goals for a user from Firestore
  Future<List<GoalModel>> fetchGoals(String userId) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(goalsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GoalModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Fetch a single goal by ID
  Future<GoalModel?> fetchGoalById(String userId, String goalId) async {
    final doc = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(goalsCollection)
        .doc(goalId)
        .get();

    if (!doc.exists) return null;
    return GoalModel.fromFirestore(doc.data()!, doc.id);
  }

  /// Fetch the active goal for a user
  Future<GoalModel?> fetchActiveGoal(String userId) async {
    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(goalsCollection)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return GoalModel.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  /// Delete a goal from Firestore
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(goalsCollection)
        .doc(goalId)
        .delete();
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String userId, String goalId, Map<String, dynamic> updates) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(goalsCollection)
        .doc(goalId)
        .update(updates);
  }

  // BATCH OPERATIONS

  /// Batch save multiple runs
  Future<void> batchSaveRuns(String userId, List<RunModel> runs) async {
    final batch = _firestore.batch();

    for (final run in runs) {
      final docRef = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(runsCollection)
          .doc(run.id);
      batch.set(docRef, run.toFirestore(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Batch save multiple goals
  Future<void> batchSaveGoals(String userId, List<GoalModel> goals) async {
    final batch = _firestore.batch();

    for (final goal in goals) {
      final docRef = _firestore
          .collection(usersCollection)
          .doc(userId)
          .collection(goalsCollection)
          .doc(goal.id);
      batch.set(docRef, goal.toFirestore(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  // USER SYNC METADATA

  /// Get the last sync timestamp for a user
  Future<DateTime?> getLastSyncTime(String userId) async {
    final doc = await _firestore
        .collection(usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data();
    if (data == null || !data.containsKey('lastSyncTime')) return null;

    final timestamp = data['lastSyncTime'] as Timestamp?;
    return timestamp?.toDate();
  }

  /// Update the last sync timestamp for a user
  Future<void> updateLastSyncTime(String userId) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .set({
      'lastSyncTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

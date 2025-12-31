import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/directions_service.dart';
import '../../../../core/services/unsplash_service.dart';
import '../../../../core/services/wikipedia_service.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../data/services/milestone_generation_service.dart';
import '../../domain/models/goal_model.dart';
import '../../domain/models/location_model.dart';
import '../../domain/models/milestone_model.dart';

/// State for goal creation process
class GoalCreationState {
  final LocationModel? startLocation;
  final LocationModel? destinationLocation;
  final DirectionsRoute? route;
  final List<MilestoneModel> milestones;
  final String goalName;
  final bool isCalculatingRoute;
  final bool isGeneratingMilestones;
  final bool isSaving;
  final String? errorMessage;

  GoalCreationState({
    this.startLocation,
    this.destinationLocation,
    this.route,
    this.milestones = const [],
    this.goalName = '',
    this.isCalculatingRoute = false,
    this.isGeneratingMilestones = false,
    this.isSaving = false,
    this.errorMessage,
  });

  GoalCreationState copyWith({
    LocationModel? startLocation,
    LocationModel? destinationLocation,
    DirectionsRoute? route,
    List<MilestoneModel>? milestones,
    String? goalName,
    bool? isCalculatingRoute,
    bool? isGeneratingMilestones,
    bool? isSaving,
    String? errorMessage,
  }) {
    return GoalCreationState(
      startLocation: startLocation ?? this.startLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      route: route ?? this.route,
      milestones: milestones ?? this.milestones,
      goalName: goalName ?? this.goalName,
      isCalculatingRoute: isCalculatingRoute ?? this.isCalculatingRoute,
      isGeneratingMilestones: isGeneratingMilestones ?? this.isGeneratingMilestones,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  bool get isStep1Complete => startLocation != null;
  bool get isStep2Complete => destinationLocation != null;
  bool get isStep3Complete => route != null && milestones.isNotEmpty;
  bool get canCreateGoal => isStep1Complete && isStep2Complete && isStep3Complete && goalName.isNotEmpty;
}

/// Notifier for goal creation
class GoalCreationNotifier extends StateNotifier<GoalCreationState> {
  final DirectionsService _directionsService;
  final MilestoneGenerationService _milestoneService;
  final UnsplashService _unsplashService;
  final WikipediaService _wikipediaService;
  final GoalLocalDataSource _goalLocalDataSource;

  GoalCreationNotifier({
    DirectionsService? directionsService,
    MilestoneGenerationService? milestoneService,
    UnsplashService? unsplashService,
    WikipediaService? wikipediaService,
    GoalLocalDataSource? goalLocalDataSource,
  })  : _directionsService = directionsService ?? DirectionsService(),
        _milestoneService = milestoneService ?? MilestoneGenerationService(),
        _unsplashService = unsplashService ?? UnsplashService(),
        _wikipediaService = wikipediaService ?? WikipediaService(),
        _goalLocalDataSource = goalLocalDataSource ?? GoalLocalDataSource(),
        super(GoalCreationState());

  /// Set start location
  void setStartLocation(LocationModel location) {
    state = state.copyWith(startLocation: location);
  }

  /// Set destination location
  void setDestinationLocation(LocationModel location) {
    state = state.copyWith(destinationLocation: location);
  }

  /// Calculate route between start and destination
  Future<void> calculateRoute() async {
    if (state.startLocation == null || state.destinationLocation == null) {
      return;
    }

    state = state.copyWith(
      isCalculatingRoute: true,
      errorMessage: null,
    );

    try {
      final route = await _directionsService.getRoute(
        startLng: state.startLocation!.longitude,
        startLat: state.startLocation!.latitude,
        endLng: state.destinationLocation!.longitude,
        endLat: state.destinationLocation!.latitude,
      );

      if (route != null) {
        state = state.copyWith(
          route: route,
          isCalculatingRoute: false,
        );

        // Automatically generate milestones after route calculation
        await generateMilestones();
      } else {
        state = state.copyWith(
          isCalculatingRoute: false,
          errorMessage: 'Failed to calculate route between locations',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isCalculatingRoute: false,
        errorMessage: 'Error calculating route: $e',
      );
    }
  }

  /// Generate milestones along the route
  Future<void> generateMilestones() async {
    if (state.route == null) {
      return;
    }

    state = state.copyWith(
      isGeneratingMilestones: true,
      errorMessage: null,
    );

    try {
      final milestones = await _milestoneService.generateMilestones(
        route: state.route!,
      );

      // Fetch photos and descriptions for milestones
      final enrichedMilestones = await _enrichMilestones(milestones);

      state = state.copyWith(
        milestones: enrichedMilestones,
        isGeneratingMilestones: false,
      );

      // Auto-populate goal name if empty
      if (state.goalName.isEmpty && state.destinationLocation != null) {
        final destName = state.destinationLocation!.city ??
            state.destinationLocation!.placeName;
        setGoalName('Run to $destName');
      }
    } catch (e) {
      state = state.copyWith(
        isGeneratingMilestones: false,
        errorMessage: 'Error generating milestones: $e',
      );
    }
  }

  /// Enrich milestones with photos and descriptions
  Future<List<MilestoneModel>> _enrichMilestones(List<MilestoneModel> milestones) async {
    final enriched = <MilestoneModel>[];

    for (final milestone in milestones) {
      try {
        // Fetch city photo from Unsplash (non-blocking)
        final photo = await _unsplashService.getCityPhoto(
          cityName: milestone.location.city ?? milestone.location.placeName,
          country: milestone.location.country,
        );

        // Fetch city description from Wikipedia (non-blocking)
        final summary = await _wikipediaService.getCitySummary(
          cityName: milestone.location.city ?? milestone.location.placeName,
          country: milestone.location.country,
        );

        enriched.add(milestone.copyWith(
          photoUrl: photo?.smallUrl,
          description: summary?.shortExtract,
        ));
      } catch (e) {
        // If fetching fails, add milestone without enrichment
        enriched.add(milestone);
      }
    }

    return enriched;
  }

  /// Set goal name
  void setGoalName(String name) {
    state = state.copyWith(goalName: name);
  }

  /// Create and save the goal
  Future<bool> createGoal() async {
    if (!state.canCreateGoal) {
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
    );

    try {
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'local';

      // Convert route coordinates to polyline (flat list of lat/lng)
      final polyline = <double>[];
      for (final coord in state.route!.coordinates) {
        polyline.add(coord.latitude);
        polyline.add(coord.longitude);
      }

      final now = DateTime.now();
      final goal = GoalModel(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        name: state.goalName,
        startLocation: state.startLocation!,
        destinationLocation: state.destinationLocation!,
        milestones: state.milestones,
        totalDistance: state.route!.distance,
        currentProgress: 0.0,
        routePolyline: polyline,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _goalLocalDataSource.saveGoal(goal);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to create goal: $e',
      );
      return false;
    }
  }

  /// Reset the goal creation state
  void reset() {
    state = GoalCreationState();
  }
}

/// Provider for goal creation state
final goalCreationProvider = StateNotifierProvider<GoalCreationNotifier, GoalCreationState>((ref) {
  return GoalCreationNotifier();
});

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets; // For Visibility widget (avoids conflict with Mapbox)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/mapbox_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_message.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/models/location_model.dart';
import '../providers/goal_creation_provider.dart';
import '../providers/goals_list_provider.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../../home/presentation/providers/home_providers.dart' hide activeGoalProvider;
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider for GeocodingService
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Provider for GoalLocalDataSource (local to this screen)
final _goalLocalDataSourceProvider = Provider<GoalLocalDataSource>((ref) {
  return GoalLocalDataSource();
});

/// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Goal Creation Screen with step-by-step wizard
/// Step 1: Select Start Location
/// Step 2: Select Destination Location
/// Step 3: Preview and Continue (will be in Sprint 10)
class GoalCreationScreen extends ConsumerStatefulWidget {
  const GoalCreationScreen({super.key});

  @override
  ConsumerState<GoalCreationScreen> createState() => _GoalCreationScreenState();
}

class _GoalCreationScreenState extends ConsumerState<GoalCreationScreen> {
  int _currentStep = 0;

  // Location data
  LocationModel? _startLocation;
  LocationModel? _destinationLocation;

  // UI state
  bool _isLoadingCurrentLocation = false;
  bool _isSearching = false;
  List<GeocodingResult> _searchResults = [];
  String? _errorMessage;
  bool _isSearchFieldFocused = false; // Track search field focus

  // PERSISTENT MAP CONTROLLER - Single instance across all steps (Issue #41 fix)
  MapboxMap? _persistentMapController;
  CircleAnnotationManager? _circleManager;
  PolylineAnnotationManager? _polylineManager;
  bool _mapInitialized = false;

  // Mapbox service instance
  final _mapboxService = MapboxService();

  // Text controllers
  final _goalNameController = TextEditingController();
  final _searchFocusNode = FocusNode(); // Focus node for search field

  // Debounce timer for search
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Listen to search field focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFieldFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _searchFocusNode.dispose();
    _searchDebounceTimer?.cancel();
    _circleManager = null;
    _polylineManager = null;
    _persistentMapController = null;
    super.dispose();
  }

  /// Get user's current location
  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final geocodingService = ref.read(geocodingServiceProvider);

      // Check permissions
      final permission = await locationService.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Get current position
      final position = await locationService.getCurrentPosition();

      // Reverse geocode to get place name
      final result = await geocodingService.reverseGeocode(
        latitude: position?.latitude ?? 0,
        longitude: position?.longitude ?? 0,
      );

      if (result != null) {
        setState(() {
          if (_currentStep == 0) {
            _startLocation = LocationModel(
              latitude: result.latitude,
              longitude: result.longitude,
              placeName: result.placeName,
              address: result.address,
              city: result.region,
              country: result.country,
            );
          }
          _isLoadingCurrentLocation = false;
        });

        _updateMapForCurrentStep();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _isLoadingCurrentLocation = false;
      });
    }
  }

  /// Search for locations
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final geocodingService = ref.read(geocodingServiceProvider);

      // Get proximity bias if start location is set
      List<double>? proximity;
      if (_startLocation != null) {
        proximity = [_startLocation?.longitude ?? 0, _startLocation?.latitude ?? 0];
      }

      final results = await geocodingService.searchLocation(
        query: query,
        limit: 5,
        proximity: proximity,
        types: ['place', 'region', 'country'],
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
        // Show message if no results found
        if (results.isEmpty) {
          _errorMessage = 'No locations found for "$query". Try a different search.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search failed: $e';
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  /// Select a location from search results
  void _selectLocation(GeocodingResult result) {
    // Unfocus search field to dismiss keyboard and show map
    _searchFocusNode.unfocus();

    setState(() {
      final location = LocationModel(
        latitude: result.latitude,
        longitude: result.longitude,
        placeName: result.placeName,
        address: result.address,
        city: result.region,
        country: result.country,
      );

      if (_currentStep == 0) {
        _startLocation = location;
      } else if (_currentStep == 1) {
        _destinationLocation = location;
      }

      _searchResults = [];
      _isSearchFieldFocused = false; // Show map after selection
    });

    _updateMapForCurrentStep();
  }

  /// Update map state for current step (Issue #41 fix)
  /// Instead of recreating maps, we update the single persistent instance
  void _updateMapForCurrentStep() async {
    print('🗺️ DEBUG: _updateMapForCurrentStep CALLED - Step: $_currentStep, MapInit: $_mapInitialized, Controller: ${_persistentMapController != null}, CircleMgr: ${_circleManager != null}, PolylineMgr: ${_polylineManager != null}');

    if (!_mapInitialized || _persistentMapController == null) {
      print('❌ DEBUG: RETURNING EARLY - Map not initialized or controller null');
      return;
    }

    final goalState = ref.read(goalCreationProvider);
    print('🛣️ DEBUG: Route data - Exists: ${goalState.route != null}, Coordinates: ${goalState.route?.coordinates.length ?? 0}, IsCalculating: ${goalState.isCalculatingRoute}');

    // Clear existing annotations
    await _circleManager?.deleteAll();
    await _polylineManager?.deleteAll();

    // Add markers for selected locations
    final annotations = <CircleAnnotationOptions>[];

    if (_startLocation != null) {
      annotations.add(
        _mapboxService.createStartMarker(
          latitude: _startLocation!.latitude,
          longitude: _startLocation!.longitude,
        ),
      );
    }

    if (_destinationLocation != null) {
      annotations.add(
        _mapboxService.createEndMarker(
          latitude: _destinationLocation!.latitude,
          longitude: _destinationLocation!.longitude,
        ),
      );
    }

    if (annotations.isNotEmpty) {
      await _circleManager?.createMulti(annotations);
      print('📍 DEBUG: Created ${annotations.length} markers (start: ${_startLocation != null}, dest: ${_destinationLocation != null})');
    }

    // Steps 2 & 3: Show route polyline if available
    if (_currentStep >= 2 && goalState.route != null && goalState.route!.coordinates.isNotEmpty) {
      print('DEBUG: Drawing route with ${goalState.route!.coordinates.length} coordinates on persistent map');

      final positions = goalState.route!.coordinates
          .map((coord) => Position(coord.longitude, coord.latitude))
          .toList();

      final lineString = LineString(coordinates: positions);
      final lineColor = Colors.blue.toARGB32();

      final polylineOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: lineColor,
        lineWidth: 8.0,
      );

      final annotation = await _polylineManager?.create(polylineOptions);
      print('DEBUG: Polyline created on persistent map: $annotation');

      // FIT CAMERA TO SHOW ENTIRE ROUTE using Mapbox's built-in API
      print('📸 DEBUG: Fitting camera to show entire route with ${positions.length} points');

      // Calculate bounds from all route coordinates
      double minLat = positions.first.lat.toDouble();
      double maxLat = positions.first.lat.toDouble();
      double minLng = positions.first.lng.toDouble();
      double maxLng = positions.first.lng.toDouble();

      for (final pos in positions) {
        final lat = pos.lat.toDouble();
        final lng = pos.lng.toDouble();
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
      }

      // TEST: Use Mapbox's official cameraForCoordinateBounds API
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(minLng, minLat)),
        northeast: Point(coordinates: Position(maxLng, maxLat)),
        infiniteBounds: false,
      );

      print('📸 DEBUG: Calling cameraForCoordinateBounds with bounds: SW($minLng, $minLat) NE($maxLng, $maxLat)');

      final cameraOptions = await _persistentMapController?.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 100, left: 100, bottom: 100, right: 100),
        null, // bearing
        null, // pitch
        null, // maxZoom
        null, // offset
      );

      if (cameraOptions != null) {
        print('📸 DEBUG: Mapbox calculated zoom: ${cameraOptions.zoom}, center: (${cameraOptions.center?.coordinates.lng}, ${cameraOptions.center?.coordinates.lat})');
        await _persistentMapController?.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
        print('✅ DEBUG: Camera positioned using Mapbox cameraForCoordinateBounds');
      } else {
        print('❌ DEBUG: cameraForCoordinateBounds returned null!');
      }
      return; // Exit early - we've already positioned the camera
    }

    // Update camera based on step (fallback if no route available)
    if (_startLocation != null && _destinationLocation != null) {
      // Show both locations using Mapbox's built-in API
      print('📸 DEBUG: Flying camera to show both start (${_startLocation!.latitude}, ${_startLocation!.longitude}) and destination (${_destinationLocation!.latitude}, ${_destinationLocation!.longitude})');

      // Calculate bounds from start and destination
      final startLat = _startLocation!.latitude;
      final startLng = _startLocation!.longitude;
      final destLat = _destinationLocation!.latitude;
      final destLng = _destinationLocation!.longitude;

      final minLat = startLat < destLat ? startLat : destLat;
      final maxLat = startLat > destLat ? startLat : destLat;
      final minLng = startLng < destLng ? startLng : destLng;
      final maxLng = startLng > destLng ? startLng : destLng;

      // TEST: Use Mapbox's official cameraForCoordinateBounds API
      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(minLng, minLat)),
        northeast: Point(coordinates: Position(maxLng, maxLat)),
        infiniteBounds: false,
      );

      print('📸 DEBUG: Calling cameraForCoordinateBounds for start/dest: SW($minLng, $minLat) NE($maxLng, $maxLat)');

      final cameraOptions = await _persistentMapController?.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 100, left: 100, bottom: 100, right: 100),
        null, // bearing
        null, // pitch
        null, // maxZoom
        null, // offset
      );

      if (cameraOptions != null) {
        print('📸 DEBUG: Mapbox calculated zoom: ${cameraOptions.zoom}, center: (${cameraOptions.center?.coordinates.lng}, ${cameraOptions.center?.coordinates.lat})');
        await _persistentMapController?.flyTo(cameraOptions, MapAnimationOptions(duration: 800));
        print('✅ DEBUG: Camera positioned using Mapbox cameraForCoordinateBounds for start/dest');
      } else {
        print('❌ DEBUG: cameraForCoordinateBounds returned null for start/dest!');
      }
    } else if (_startLocation != null) {
      // Show start location
      print('📸 DEBUG: Flying camera to show start location');
      final cameraOptions = CameraOptions(
        center: Point(coordinates: Position(_startLocation!.longitude, _startLocation!.latitude)),
        zoom: 12.0,
      );
      await _persistentMapController?.flyTo(cameraOptions, MapAnimationOptions(duration: 500));
    } else if (_destinationLocation != null) {
      // Show destination
      print('📸 DEBUG: Flying camera to show destination');
      final cameraOptions = CameraOptions(
        center: Point(coordinates: Position(_destinationLocation!.longitude, _destinationLocation!.latitude)),
        zoom: 12.0,
      );
      await _persistentMapController?.flyTo(cameraOptions, MapAnimationOptions(duration: 500));
    }
  }

  /// Go to next step
  void _nextStep() async {
    if (_currentStep == 0 && _startLocation != null) {
      // Update provider with start location
      ref.read(goalCreationProvider.notifier).setStartLocation(_startLocation!);
      setState(() {
        _currentStep = 1;
        _searchResults = [];
      });
    } else if (_currentStep == 1 && _destinationLocation != null) {
      // Update provider with destination location
      ref.read(goalCreationProvider.notifier).setDestinationLocation(_destinationLocation!);

      // Move to step 2 and calculate route
      setState(() {
        _currentStep = 2;
        _searchResults = [];
      });

      // Calculate route and generate milestones
      print('📍 DEBUG: About to calculate route - Step: $_currentStep');
      await ref.read(goalCreationProvider.notifier).calculateRoute();
      print('✅ DEBUG: Route calculation completed');

      // Update map to show the calculated route
      print('🎯 DEBUG: Calling _updateMapForCurrentStep after route calculation');
      _updateMapForCurrentStep();
    } else if (_currentStep == 2) {
      // Move to final confirmation step and populate goal name
      final goalState = ref.read(goalCreationProvider);
      if (goalState.goalName.isEmpty) {
        // Auto-populate goal name
        final destName = _destinationLocation?.placeName ?? 'Destination';
        ref.read(goalCreationProvider.notifier).setGoalName('Run to $destName');
        _goalNameController.text = 'Run to $destName';
      } else {
        _goalNameController.text = goalState.goalName;
      }

      setState(() {
        _currentStep = 3;
      });

      // Update map to keep showing the route on confirmation screen
      _updateMapForCurrentStep();
    } else if (_currentStep == 3) {
      // Check if user has an active goal
      final hasActiveGoal = await ref.read(hasActiveGoalProvider.future);

      // If they have an active goal, ask what to do
      if (hasActiveGoal && mounted) {
        final choice = await _showGoalActivationDialog();

        if (choice == null) {
          // User cancelled
          return;
        }

        // Create the goal with the chosen activation status
        await _createGoalWithActivation(activateGoal: choice == 'activate');
      } else {
        // No active goal, create and activate by default
        await _createGoalWithActivation(activateGoal: true);
      }
    }
  }

  /// Show dialog asking user whether to activate new goal or add to bucket list
  Future<String?> _showGoalActivationDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Activate This Goal?',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        content: Text(
          'You already have an active goal. Would you like to activate this new goal (your current goal will be paused) or save it for later?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(
              'Save for Later',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'activate'),
            child: Text(
              'Activate Now',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Create goal with specified activation status
  Future<void> _createGoalWithActivation({required bool activateGoal}) async {
    final goalName = ref.read(goalCreationProvider).goalName; // Save before reset

    // If activating, deactivate current goal first
    if (activateGoal) {
      final userAsync = await ref.read(currentUserProvider.future);
      if (userAsync != null) {
        final goalLocalDataSource = ref.read(_goalLocalDataSourceProvider);
        await goalLocalDataSource.deactivateAllGoals(userAsync.uid);
      }
    }

    // Create the goal (it will be created as active)
    final success = await ref.read(goalCreationProvider.notifier).createGoal();

    // If user chose "save for later", deactivate the newly created goal
    if (success && !activateGoal && mounted) {
      final userAsync = await ref.read(currentUserProvider.future);
      if (userAsync != null) {
        final goalLocalDataSource = ref.read(_goalLocalDataSourceProvider);
        final activeGoal = goalLocalDataSource.getActiveGoalSafe(userAsync.uid);
        if (activeGoal != null) {
          final updatedGoal = activeGoal.copyWith(isActive: false);
          await goalLocalDataSource.updateGoal(updatedGoal);
        }
      }
    }

    if (success && mounted) {
      final userAsync = await ref.read(currentUserProvider.future);
      final userId = userAsync?.uid;

      // Invalidate all goal-related providers to force refresh from Hive
      ref.invalidate(homeScreenDataProvider);
      ref.invalidate(activeGoalProvider);
      ref.invalidate(hasActiveGoalProvider);

      // Invalidate Goals list screen provider so saved goals appear
      if (userId != null) {
        ref.invalidate(userGoalsProvider(userId));
      }

      // Reset the provider for next goal creation
      ref.read(goalCreationProvider.notifier).reset();

      // Navigate back to home
      Navigator.pop(context);

      // Show success message
      if (mounted) {
        final message = activateGoal
            ? '🎉 Goal "$goalName" created and activated! Start running to reach your destination.'
            : '✅ Goal "$goalName" saved for later! You can activate it from the Goals screen.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else if (mounted) {
      // Show error if creation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(goalCreationProvider).errorMessage ?? 'Failed to create goal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _searchResults = [];

        // Restore local state from provider when going back
        final goalState = ref.read(goalCreationProvider);
        if (_currentStep == 0 && goalState.startLocation != null) {
          _startLocation = goalState.startLocation;
        } else if (_currentStep == 1 && goalState.destinationLocation != null) {
          _destinationLocation = goalState.destinationLocation;
        }
      });

      _updateMapForCurrentStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Goal'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Stepper indicator
          _buildStepIndicator(),

          // PERSISTENT MAP - Single instance maintained across all steps (Issue #41 fix)
          // Uses widgets.Visibility instead of AnimatedContainer to avoid opacity animations
          // Visible on all steps (0-3) when search is not active
          widgets.Visibility(
            visible: !_isSearchFieldFocused && _searchResults.isEmpty,
            maintainState: true, // Keep map alive when hidden
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: _buildPersistentMap(),
            ),
          ),

          // Content area - expand to fill space when map is hidden
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final goalState = ref.watch(goalCreationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border, // Removed alpha to avoid opacity issues (Issue #41)
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStepCircle(0, 'Start', isActive: _currentStep >= 0, isCompleted: _startLocation != null),
          Expanded(child: _buildStepLine(isCompleted: _startLocation != null)),
          _buildStepCircle(1, 'Dest', isActive: _currentStep >= 1, isCompleted: _destinationLocation != null),
          Expanded(child: _buildStepLine(isCompleted: _destinationLocation != null)),
          _buildStepCircle(2, 'Route', isActive: _currentStep >= 2, isCompleted: goalState.route != null),
          Expanded(child: _buildStepLine(isCompleted: goalState.route != null)),
          _buildStepCircle(3, 'Confirm', isActive: _currentStep >= 3, isCompleted: false),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, {required bool isActive, required bool isCompleted}) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isCompleted || isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isCompleted || isActive ? null : AppColors.surfaceLight,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : AppColors.border,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight, // Use solid color instead of alpha (Issue #41)
                ],
              )
            : null,
        color: isCompleted ? null : AppColors.border, // Removed alpha (Issue #41)
      ),
    );
  }

  /// Build persistent map widget that survives step changes (Issue #41 fix)
  /// This single map instance is reused across all steps, avoiding disposal/recreation
  Widget _buildPersistentMap() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border, // NO alpha - solid color only (Issue #41)
          width: 1,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: MapWidget(
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(78.4867, 17.3850)), // Default to Hyderabad
          zoom: 10.0,
        ),
        styleUri: MapStyle.outdoors.styleUri,
        onMapCreated: (controller) async {
          print('🎨 DEBUG: onMapCreated CALLED - Creating persistent map');
          _persistentMapController = controller;
          print('🔵 DEBUG: Creating CircleAnnotationManager...');
          _circleManager = await controller.annotations.createCircleAnnotationManager();
          print('📏 DEBUG: Creating PolylineAnnotationManager...');
          _polylineManager = await controller.annotations.createPolylineAnnotationManager();
          _mapInitialized = true;
          print('✅ DEBUG: Map fully initialized - managers ready');

          // Update map for current step
          _updateMapForCurrentStep();

          // Fetch user's location to show on map (but don't auto-select)
          _fetchUserLocationForMap();
        },
      ),
    );
  }

  /// Fetch user's location to display on map (without auto-selecting)
  Future<void> _fetchUserLocationForMap() async {
    try {
      final locationService = ref.read(locationServiceProvider);

      // Check permissions first
      final permission = await locationService.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        // Don't auto-fetch if permission not granted yet
        return;
      }

      // Get current position
      final position = await locationService.getCurrentPosition();

      if (position != null && mounted && _persistentMapController != null) {
        // Update map to show user's location (but don't select it)
        final cameraOptions = CameraOptions(
          center: Point(coordinates: Position(position.longitude, position.latitude)),
          zoom: 12.0,
        );

        _persistentMapController?.flyTo(cameraOptions, null);
      }
    } catch (e) {
      // Silently fail - user can still use search or manual location selection
    }
  }

  Widget _buildContentArea() {
    if (_currentStep == 2) {
      return _buildRoutePreviewStep();
    } else if (_currentStep == 3) {
      return _buildConfirmationStep();
    }

    // Steps 0 and 1: Location selection
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Step title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _currentStep == 0
                  ? (_startLocation != null ? 'Start Location' : 'Select Start Location')
                  : (_destinationLocation != null ? 'Destination' : 'Select Destination'),
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ErrorMessage(message: _errorMessage!),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected location display
                  _buildSelectedLocation(),

                  // Only show search UI if no location is selected
                  if ((_currentStep == 0 && _startLocation == null) ||
                      (_currentStep == 1 && _destinationLocation == null)) ...[
                    const SizedBox(height: 16),

                    // Use current location button (only for start location)
                    if (_currentStep == 0)
                      CustomButton(
                        text: 'Use Current Location',
                        onPressed: _isLoadingCurrentLocation ? null : _useCurrentLocation,
                        isLoading: _isLoadingCurrentLocation,
                        icon: Icons.my_location,
                        isOutlined: true,
                      ),

                    if (_currentStep == 0) const SizedBox(height: 16),

                    // Search field
                    CustomTextField(
                      label: 'Search for a location',
                      hint: 'e.g., Toronto, Canada',
                      prefixIcon: Icons.search,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        // Cancel previous timer if user is still typing
                        _searchDebounceTimer?.cancel();

                        // Start new timer - only fires if user stops typing for 500ms
                        _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
                          _searchLocation(value);
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    // Loading indicator
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: LoadingIndicator()),
                      ),

                    // Search results
                    if (_searchResults.isNotEmpty)
                      _buildSearchResults(),
                  ],
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSelectedLocation() {
    // Only show location that was explicitly selected by user in THIS step
    // Don't read from provider here - that causes confusion with stale data
    final location = _currentStep == 0 ? _startLocation : _destinationLocation;

    if (location == null) return const SizedBox.shrink();

    return SolidCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.placeName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                if (location.country != null)
                  Text(
                    location.country!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.textSecondary,
            onPressed: () {
              setState(() {
                if (_currentStep == 0) {
                  _startLocation = null;
                } else {
                  _destinationLocation = null;
                }
              });
              _updateMapForCurrentStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final result = _searchResults[index];

          return SolidCard(
            padding: const EdgeInsets.all(12),
            onTap: () => _selectLocation(result),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.place,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.shortName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Back',
                onPressed: _previousStep,
                isOutlined: true,
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: CustomButton(
              text: _currentStep == 0
                  ? 'Next: Destination'
                  : _currentStep == 1
                      ? 'Calculate Route'
                      : _currentStep == 2
                          ? 'Next: Confirm'
                          : 'Create Goal',
              onPressed: (_currentStep == 0 && _startLocation == null) ||
                      (_currentStep == 1 && _destinationLocation == null)
                  ? null
                  : _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Step 2: Route & Milestones Preview
  Widget _buildRoutePreviewStep() {
    final goalState = ref.watch(goalCreationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Step title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Route & Milestones',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Error message
          if (goalState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ErrorMessage(message: goalState.errorMessage!),
            ),

          Expanded(
            child: goalState.isCalculatingRoute || goalState.isGeneratingMilestones
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LoadingIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Calculating route and generating milestones...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // NOTE: Route map is displayed in the persistent map at top of screen (Issue #41 fix)
                        // No need for separate map instance here - using single persistent map across all steps

                        const SizedBox(height: 4), // Small spacing

                        // Route Info Card
                        if (goalState.route != null)
                          PrimaryCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: const Icon(
                                        Icons.route,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Route Summary',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.straighten,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${goalState.route!.distanceInKm.toStringAsFixed(1)} km',
                                            style: AppTextStyles.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Distance',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 60,
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${goalState.route!.durationInHours.toStringAsFixed(1)} hrs',
                                            style: AppTextStyles.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Est. Duration',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Milestones
                        if (goalState.milestones.isNotEmpty) ...[
                          Text(
                            'Milestones Along Your Journey',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${goalState.milestones.length} milestone cities to discover',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: goalState.milestones.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final milestone = goalState.milestones[index];
                              return SolidCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary.withValues(alpha: 0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTextStyles.bodyLarge.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            milestone.cityName,
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${milestone.distanceInKm.toStringAsFixed(1)} km from start',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Build Step 3: Confirmation
  Widget _buildConfirmationStep() {
    final goalState = ref.watch(goalCreationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Step title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Confirm Your Goal',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NOTE: Route map displayed in persistent map at top (Issue #41 fix)
                  // No separate map instance needed here

                  const SizedBox(height: 4), // Small spacing

                  // Goal name input
                  Text(
                    'Goal Name',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Name your goal',
                    hint: 'Run to ${_destinationLocation?.placeName ?? "Destination"}',
                    controller: _goalNameController,
                    onChanged: (value) {
                      ref.read(goalCreationProvider.notifier).setGoalName(value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Summary Card
                  SolidCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.summarize,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Journey Summary',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: AppColors.border, // Removed alpha (Issue #41)
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryRow('Start Location', _startLocation?.placeName ?? '-'),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Destination', _destinationLocation?.placeName ?? '-'),
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Total Distance',
                          goalState.route != null
                              ? '${goalState.route!.distanceInKm.toStringAsFixed(1)} km'
                              : '-',
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Milestone Cities', '${goalState.milestones.length}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Your virtual progress will be tracked as you complete runs. Each run brings you closer to your destination!',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // NOTE: _buildRouteMapPreview() method removed (Issue #41 fix)
  // Now using single persistent map at top of screen instead of creating separate instances
}

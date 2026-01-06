import 'package:flutter/material.dart';
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

/// Provider for GeocodingService
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
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
  String _searchQuery = '';
  List<GeocodingResult> _searchResults = [];
  String? _errorMessage;

  // Map controller
  MapboxMap? _mapController;
  CircleAnnotationManager? _circleManager;

  // Mapbox service instance
  final _mapboxService = MapboxService();

  // Text controllers
  final _goalNameController = TextEditingController();

  @override
  void dispose() {
    _goalNameController.dispose();
    _circleManager = null;
    _mapController = null;
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

        _updateMap();
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
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
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
        types: ['place', 'region', 'country', 'locality'],
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
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
      _searchQuery = '';
    });

    _updateMap();
  }

  /// Update map with selected locations
  void _updateMap() {
    if (_mapController == null) return;

    // Clear existing annotations
    _circleManager?.deleteAll();

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
      _circleManager?.createMulti(annotations);
    }

    // Fit camera to show both locations
    if (_startLocation != null && _destinationLocation != null) {
      final cameraOptions = _mapboxService.getBoundsCameraOptions(
        coordinates: [
          Position(_startLocation!.longitude, _startLocation!.latitude),
          Position(_destinationLocation!.longitude, _destinationLocation!.latitude),
        ],
        padding: MbxEdgeInsets(
          top: 80.0,
          left: 80.0,
          bottom: 80.0,
          right: 80.0,
        ),
      );

      _mapController?.flyTo(cameraOptions, null);
    } else if (_startLocation != null) {
      final cameraOptions = CameraOptions(
        center: Point(coordinates: Position(_startLocation!.longitude, _startLocation!.latitude)),
        zoom: 12.0,
      );

      _mapController?.flyTo(cameraOptions, null);
    } else if (_destinationLocation != null) {
      final cameraOptions = CameraOptions(
        center: Point(coordinates: Position(_destinationLocation!.longitude, _destinationLocation!.latitude)),
        zoom: 12.0,
      );

      _mapController?.flyTo(cameraOptions, null);
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
        _searchQuery = '';
      });
    } else if (_currentStep == 1 && _destinationLocation != null) {
      // Update provider with destination location
      ref.read(goalCreationProvider.notifier).setDestinationLocation(_destinationLocation!);

      // Move to step 2 and calculate route
      setState(() {
        _currentStep = 2;
        _searchResults = [];
        _searchQuery = '';
      });

      // Calculate route and generate milestones
      await ref.read(goalCreationProvider.notifier).calculateRoute();
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
    } else if (_currentStep == 3) {
      // Create the goal
      final success = await ref.read(goalCreationProvider.notifier).createGoal();
      if (success && mounted) {
        // Navigate back to home
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// Go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _searchResults = [];
        _searchQuery = '';
      });
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

          // Map view
          Expanded(
            flex: 2,
            child: _buildMapView(),
          ),

          // Content area
          Expanded(
            flex: 3,
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
            color: AppColors.border.withValues(alpha: 0.3),
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
                  AppColors.primary.withValues(alpha: 0.5),
                ],
              )
            : null,
        color: isCompleted ? null : AppColors.border.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildMapView() {
    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(-79.3832, 43.6532)), // Default to Toronto
        zoom: 10.0,
      ),
      styleUri: MapStyle.outdoors.styleUri,
      onMapCreated: (controller) async {
        _mapController = controller;
        _circleManager = await controller.annotations.createCircleAnnotationManager();
        _updateMap();
      },
    );
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
              _currentStep == 0 ? 'Select Start Location' : 'Select Destination',
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
                  if ((_currentStep == 0 && _startLocation != null) ||
                      (_currentStep == 1 && _destinationLocation != null))
                    _buildSelectedLocation(),

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
                    onChanged: (value) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (value == _searchQuery) {
                          _searchLocation(value);
                        }
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
              _updateMap();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
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
                          color: AppColors.border.withValues(alpha: 0.3),
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
}

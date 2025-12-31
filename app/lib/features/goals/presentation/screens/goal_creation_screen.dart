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
      padding: const EdgeInsets.all(16),
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
            color: isCompleted
                ? AppColors.success
                : isActive
                    ? AppColors.primary
                    : AppColors.surface,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
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
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isCompleted}) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? AppColors.success : AppColors.border,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.placeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          CustomIconButton(
            icon: Icons.edit,
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
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];

          return ListTile(
            leading: const Icon(Icons.place, color: AppColors.primary),
            title: Text(result.shortName),
            subtitle: Text(
              result.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _selectLocation(result),
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
            padding: const EdgeInsets.all(16),
            child: Text(
              'Route & Milestones',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Error message
          if (goalState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ErrorMessage(message: goalState.errorMessage!),
            ),

          Expanded(
            child: goalState.isCalculatingRoute || goalState.isGeneratingMilestones
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingIndicator(),
                        SizedBox(height: 16),
                        Text('Calculating route and generating milestones...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Route Info Card
                        if (goalState.route != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Route Summary',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.straighten, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Distance: ${goalState.route!.distanceInKm.toStringAsFixed(1)} km',
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Est. Duration: ${goalState.route!.durationInHours.toStringAsFixed(1)} hrs (driving)',
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Milestones
                        if (goalState.milestones.isNotEmpty) ...[
                          Text(
                            'Milestones Along Your Journey',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${goalState.milestones.length} milestone cities to discover',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: goalState.milestones.length,
                            itemBuilder: (context, index) {
                              final milestone = goalState.milestones[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    milestone.cityName,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${milestone.distanceInKm.toStringAsFixed(1)} km from start',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  trailing: const Icon(Icons.location_on, color: AppColors.primary),
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
            padding: const EdgeInsets.all(16),
            child: Text(
              'Confirm Your Goal',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Goal name input
                  Text(
                    'Goal Name',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Name your goal',
                    hint: 'Run to ${_destinationLocation?.placeName ?? "Destination"}',
                    controller: _goalNameController,
                    onChanged: (value) {
                      ref.read(goalCreationProvider.notifier).setGoalName(value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow('Start:', _startLocation?.placeName ?? '-'),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Destination:', _destinationLocation?.placeName ?? '-'),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Distance:',
                            goalState.route != null
                                ? '${goalState.route!.distanceInKm.toStringAsFixed(1)} km'
                                : '-',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Milestones:', '${goalState.milestones.length} cities'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your virtual progress will be tracked as you complete runs!',
                            style: AppTextStyles.bodySmall,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

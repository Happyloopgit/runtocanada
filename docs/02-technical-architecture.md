# Run to Canada - Technical Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [Tech Stack](#tech-stack)
3. [Architecture Layers](#architecture-layers)
4. [Data Models & Schemas](#data-models--schemas)
5. [API Integration](#api-integration)
6. [Data Flow & Synchronization](#data-flow--synchronization)
7. [User Flows](#user-flows)
8. [Modular Architecture](#modular-architecture)
9. [Security & Privacy](#security--privacy)
10. [Performance Optimization](#performance-optimization)
11. [Deployment Strategy](#deployment-strategy)

---

## System Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Mobile Application                       │
│                      (Flutter/Dart)                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Presentation │  │   Business   │  │     Data     │     │
│  │    Layer     │  │    Logic     │  │    Layer     │     │
│  │              │  │    Layer     │  │              │     │
│  │  (Widgets)   │  │ (Providers)  │  │(Repositories)│     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
      ┌─────────▼─────────┐    ┌─────────▼──────────┐
      │  Local Storage    │    │  Cloud Backend     │
      │     (Hive)        │◄──►│    (Firebase)      │
      │                   │    │                    │
      │  - Runs           │    │  - Authentication  │
      │  - Goals          │    │  - Firestore DB    │
      │  - Settings       │    │  - Analytics       │
      │  - Cache          │    │  - Storage         │
      └───────────────────┘    └────────────────────┘
                │                         │
                │                         │
      ┌─────────▼──────────────────┐     │
      │   Third-Party Services     │     │
      ├────────────────────────────┤     │
      │  - Mapbox (Maps)           │◄────┘
      │  - Mapbox Geocoding        │
      │  - Mapbox Directions       │
      │  - Unsplash (Photos)       │
      │  - Wikipedia (Data)        │
      │  - AdMob (Ads)             │
      │  - RevenueCat (Payments)   │
      └────────────────────────────┘
```

### Architecture Principles

1. **Offline-First:** All core features work without internet
2. **Clean Architecture:** Separation of concerns (UI, Business Logic, Data)
3. **Reactive Programming:** State management with Riverpod
4. **Type Safety:** Strongly typed with Dart
5. **Modular Design:** Feature-based modules
6. **Scalable:** Ready for growth to millions of users

---

## Tech Stack

### Mobile Framework
```yaml
Framework: Flutter 3.x
Language: Dart 3.x
Minimum Versions:
  - iOS: 12.0+
  - Android: 5.0+ (API 21+)
```

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Firebase Backend
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_analytics: ^10.7.0
  firebase_storage: ^11.5.0

  # Maps & Location
  mapbox_gl: ^0.16.0
  geolocator: ^11.0.0
  permission_handler: ^11.0.0
  flutter_polyline_points: ^2.0.0
  latlong2: ^0.9.0

  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.0
  json_annotation: ^4.8.0

  # UI Components
  cached_network_image: ^3.3.0
  lottie: ^3.0.0
  flutter_svg: ^2.0.0
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.0.0
  connectivity_plus: ^5.0.0
  package_info_plus: ^5.0.0
  shared_preferences: ^2.2.0

  # Monitoring & Analytics
  firebase_crashlytics: ^3.4.0
  sentry_flutter: ^7.13.0

  # Monetization (Phase 2)
  google_mobile_ads: ^5.0.0
  purchases_flutter: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

  # Code Generation
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0
  retrofit_generator: ^7.0.0
```

### Third-Party Services

| Service | Purpose | Cost | Free Tier |
|---------|---------|------|-----------|
| **Mapbox** | Maps, geocoding, directions | $5-7/1k requests | 200k map loads/mo |
| **Firebase Auth** | User authentication | Free | Unlimited |
| **Cloud Firestore** | NoSQL database | $0.06/100k reads | 50k reads/day |
| **Firebase Storage** | File storage | $0.026/GB | 5GB total |
| **Firebase Analytics** | User analytics | Free | Unlimited |
| **Unsplash API** | City photos | Free | 50 requests/hour |
| **Wikipedia API** | City/landmark data | Free | Unlimited |
| **AdMob** | Advertisement | Revenue share | Free integration |
| **RevenueCat** | Subscription management | 1% of revenue | Up to $2.5k/mo |

---

## Architecture Layers

### 1. Presentation Layer (UI)

**Responsibility:** Display data and handle user interactions

**Components:**
```
lib/presentation/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── tracking/
│   │   ├── run_tracking_screen.dart
│   │   ├── run_summary_screen.dart
│   │   └── widgets/
│   ├── journey/
│   │   ├── journey_map_screen.dart
│   │   ├── goal_creation_screen.dart
│   │   ├── milestone_detail_screen.dart
│   │   └── widgets/
│   ├── history/
│   │   ├── run_history_screen.dart
│   │   ├── run_detail_screen.dart
│   │   └── widgets/
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── settings_screen.dart
│   │   └── widgets/
│   └── premium/
│       ├── paywall_screen.dart
│       └── widgets/
├── widgets/
│   ├── common/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   ├── loading_indicator.dart
│   │   └── error_widget.dart
│   └── map/
│       ├── journey_map_widget.dart
│       ├── route_polyline_widget.dart
│       └── milestone_marker_widget.dart
└── theme/
    ├── app_theme.dart
    ├── app_colors.dart
    └── app_text_styles.dart
```

**Design Pattern:** BLoC-like pattern using Riverpod providers

---

### 2. Business Logic Layer

**Responsibility:** Application logic, state management, use cases

**Components:**
```
lib/application/
├── providers/
│   ├── auth_provider.dart
│   ├── run_tracking_provider.dart
│   ├── journey_provider.dart
│   ├── goal_provider.dart
│   └── settings_provider.dart
├── services/
│   ├── gps_service.dart
│   ├── location_service.dart
│   ├── calculation_service.dart
│   ├── sync_service.dart
│   └── notification_service.dart
└── use_cases/
    ├── track_run_use_case.dart
    ├── calculate_journey_progress_use_case.dart
    ├── fetch_milestones_use_case.dart
    └── sync_data_use_case.dart
```

**State Management:** Riverpod with code generation

Example:
```dart
@riverpod
class RunTracking extends _$RunTracking {
  @override
  FutureOr<RunTrackingState> build() async {
    return const RunTrackingState.idle();
  }

  Future<void> startRun() async {
    state = const AsyncValue.loading();
    // Business logic here
  }
}
```

---

### 3. Data Layer

**Responsibility:** Data access, persistence, API calls

**Components:**
```
lib/data/
├── repositories/
│   ├── run_repository.dart
│   ├── goal_repository.dart
│   ├── user_repository.dart
│   └── milestone_repository.dart
├── datasources/
│   ├── local/
│   │   ├── hive_datasource.dart
│   │   ├── run_local_datasource.dart
│   │   └── goal_local_datasource.dart
│   └── remote/
│       ├── firebase_datasource.dart
│       ├── mapbox_datasource.dart
│       └── unsplash_datasource.dart
├── models/
│   ├── run_model.dart
│   ├── goal_model.dart
│   ├── user_model.dart
│   ├── route_point_model.dart
│   └── milestone_model.dart
└── api/
    ├── mapbox_api.dart
    ├── geocoding_api.dart
    └── wikipedia_api.dart
```

**Repository Pattern:** Single source of truth, handles local + remote data

Example:
```dart
class RunRepository {
  final RunLocalDataSource _localDataSource;
  final FirebaseDataSource _remoteDataSource;
  final SyncService _syncService;

  Future<Run> saveRun(Run run) async {
    // 1. Save locally (offline-first)
    await _localDataSource.saveRun(run);

    // 2. Sync to cloud when online
    await _syncService.syncRun(run);

    return run;
  }
}
```

---

## Data Models & Schemas

### 1. User Model

```dart
@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;                    // Firebase UID

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoUrl;

  @HiveField(4)
  final bool isPremium;

  @HiveField(5)
  final DateTime? premiumExpiresAt;

  @HiveField(6)
  final UserSettings settings;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;
}

@HiveType(typeId: 1)
class UserSettings {
  @HiveField(0)
  final String units;                 // 'metric' or 'imperial'

  @HiveField(1)
  final String mapStyle;              // 'streets', 'satellite', 'outdoors'

  @HiveField(2)
  final bool showMilestones;

  @HiveField(3)
  final bool enableNotifications;

  @HiveField(4)
  final String language;
}
```

**Firestore Schema:**
```
users/
  └─ {userId}/
      ├─ email: string
      ├─ displayName: string
      ├─ photoUrl: string
      ├─ isPremium: boolean
      ├─ premiumExpiresAt: timestamp
      ├─ settings: map
      ├─ createdAt: timestamp
      └─ updatedAt: timestamp
```

---

### 2. Run Model

```dart
@HiveType(typeId: 2)
class Run {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime endTime;

  @HiveField(4)
  final double distance;              // meters

  @HiveField(5)
  final int duration;                 // seconds

  @HiveField(6)
  final List<RoutePoint> routePoints;

  @HiveField(7)
  final String? goalId;               // Associated goal

  @HiveField(8)
  final List<String> milestonesReached;

  @HiveField(9)
  final double? elevationGain;        // meters

  @HiveField(10)
  final double averagePace;           // min/km

  @HiveField(11)
  final double? calories;             // estimated

  @HiveField(12)
  final String? notes;

  @HiveField(13)
  final bool isSynced;

  @HiveField(14)
  final DateTime createdAt;

  // Computed properties
  double get averageSpeed => distance / duration; // m/s
  String get formattedDuration => _formatDuration(duration);
  String get formattedDistance => _formatDistance(distance);
}

@HiveType(typeId: 3)
class RoutePoint {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double? altitude;             // meters

  @HiveField(3)
  final double? accuracy;             // meters

  @HiveField(4)
  final double? speed;                // m/s

  @HiveField(5)
  final DateTime timestamp;
}
```

**Firestore Schema:**
```
users/{userId}/runs/
  └─ {runId}/
      ├─ startTime: timestamp
      ├─ endTime: timestamp
      ├─ distance: number
      ├─ duration: number
      ├─ routePoints: array<geopoint>  (simplified for storage)
      ├─ goalId: string
      ├─ milestonesReached: array<string>
      ├─ elevationGain: number
      ├─ averagePace: number
      ├─ calories: number
      ├─ notes: string
      └─ createdAt: timestamp

Note: Full routePoints stored in Firebase Storage as compressed JSON
Path: users/{userId}/runs/{runId}/route.json.gz
```

---

### 3. Goal Model

```dart
@HiveType(typeId: 4)
class Goal {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;                  // "Run to Canada"

  @HiveField(3)
  final Location startPoint;

  @HiveField(4)
  final Location endPoint;

  @HiveField(5)
  final double totalDistance;         // meters (straight line or route)

  @HiveField(6)
  final double currentProgress;       // meters (accumulated from runs)

  @HiveField(7)
  final List<Milestone> milestones;

  @HiveField(8)
  final List<RoutePoint> routePath;   // Polyline from start to end

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? completedAt;

  @HiveField(12)
  final bool isSynced;

  // Computed properties
  double get progressPercentage => (currentProgress / totalDistance) * 100;
  bool get isCompleted => currentProgress >= totalDistance;
  Location get currentVirtualLocation => _calculateCurrentLocation();
}

@HiveType(typeId: 5)
class Location {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final String name;                  // "San Francisco, CA"

  @HiveField(3)
  final String? country;

  @HiveField(4)
  final String? state;

  @HiveField(5)
  final String? city;
}

@HiveType(typeId: 6)
class Milestone {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;                  // "Sacramento"

  @HiveField(2)
  final Location location;

  @HiveField(3)
  final double distanceFromStart;     // meters

  @HiveField(4)
  final bool isReached;

  @HiveField(5)
  final DateTime? reachedAt;

  @HiveField(6)
  final String? description;          // Fun fact about the city

  @HiveField(7)
  final String? photoUrl;             // From Unsplash

  @HiveField(8)
  final MilestoneType type;           // city, landmark, state_border
}

enum MilestoneType {
  city,
  landmark,
  stateBorder,
  countryBorder,
  custom,
}
```

**Firestore Schema:**
```
users/{userId}/goals/
  └─ {goalId}/
      ├─ name: string
      ├─ startPoint: map
      ├─ endPoint: map
      ├─ totalDistance: number
      ├─ currentProgress: number
      ├─ milestones: array<map>
      ├─ routePath: reference to Storage
      ├─ isActive: boolean
      ├─ createdAt: timestamp
      └─ completedAt: timestamp
```

---

### 4. Hive Box Structure

```dart
// Initialize Hive boxes
Future<void> initHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(RunAdapter());
  Hive.registerAdapter(RoutePointAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(LocationAdapter());
  Hive.registerAdapter(MilestoneAdapter());

  // Open boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Run>('runs');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<String>('syncQueue');
  await Hive.openBox<Map>('cache');
}
```

**Box Usage:**
```
users: Box<User>          - Single user object
runs: Box<Run>            - All runs (key: runId)
goals: Box<Goal>          - All goals (key: goalId)
syncQueue: Box<String>    - IDs of items pending sync
cache: Box<Map>           - API response cache (Mapbox, Unsplash, etc.)
```

---

## API Integration

### 1. Mapbox APIs

**Maps Display:**
```dart
class MapboxApi {
  static const String accessToken = 'YOUR_MAPBOX_TOKEN';
  static const String styleUrl = 'mapbox://styles/mapbox/streets-v12';

  MapboxMapController? controller;

  Future<void> initializeMap() async {
    // Initialize Mapbox GL
  }

  Future<void> drawRoute(List<LatLng> points) async {
    // Draw polyline on map
  }

  Future<void> addMarker(LatLng position, String label) async {
    // Add milestone marker
  }
}
```

**Geocoding API:**
```dart
@RestApi(baseUrl: 'https://api.mapbox.com/geocoding/v5/')
abstract class GeocodingApi {
  factory GeocodingApi(Dio dio) = _GeocodingApi;

  @GET('/mapbox.places/{query}.json')
  Future<GeocodingResponse> searchPlaces(
    @Path() String query,
    @Query('access_token') String accessToken,
    @Query('limit') int limit,
  );

  @GET('/mapbox.places/{longitude},{latitude}.json')
  Future<GeocodingResponse> reverseGeocode(
    @Path() double longitude,
    @Path() double latitude,
    @Query('access_token') String accessToken,
  );
}
```

**Directions API:**
```dart
@RestApi(baseUrl: 'https://api.mapbox.com/directions/v5/')
abstract class DirectionsApi {
  factory DirectionsApi(Dio dio) = _DirectionsApi;

  @GET('/mapbox/walking/{coordinates}')
  Future<DirectionsResponse> getRoute(
    @Path() String coordinates,  // 'lon1,lat1;lon2,lat2'
    @Query('access_token') String accessToken,
    @Query('geometries') String geometries,  // 'geojson'
    @Query('overview') String overview,      // 'full'
  );
}
```

---

### 2. Unsplash API (City Photos)

```dart
@RestApi(baseUrl: 'https://api.unsplash.com/')
abstract class UnsplashApi {
  factory UnsplashApi(Dio dio) = _UnsplashApi;

  @GET('/search/photos')
  Future<UnsplashResponse> searchPhotos(
    @Query('query') String query,           // 'San Francisco skyline'
    @Query('client_id') String accessKey,
    @Query('per_page') int perPage,
    @Query('orientation') String orientation, // 'landscape'
  );
}

// Usage
final photos = await unsplashApi.searchPhotos(
  '${cityName} skyline',
  UNSPLASH_ACCESS_KEY,
  1,
  'landscape',
);
```

**Caching Strategy:**
```dart
class PhotoCache {
  final Box<Map> _cacheBox = Hive.box<Map>('cache');

  Future<String?> getCityPhoto(String cityName) async {
    // Check cache first
    final cached = _cacheBox.get('photo_$cityName');
    if (cached != null && !_isExpired(cached['timestamp'])) {
      return cached['url'];
    }

    // Fetch from API
    final photos = await _unsplashApi.searchPhotos(cityName);
    if (photos.results.isNotEmpty) {
      final photoUrl = photos.results.first.urls.regular;

      // Cache for 30 days
      await _cacheBox.put('photo_$cityName', {
        'url': photoUrl,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return photoUrl;
    }

    return null;
  }
}
```

---

### 3. Wikipedia API (City Info)

```dart
@RestApi(baseUrl: 'https://en.wikipedia.org/api/rest_v1/')
abstract class WikipediaApi {
  factory WikipediaApi(Dio dio) = _WikipediaApi;

  @GET('/page/summary/{title}')
  Future<WikipediaSummary> getPageSummary(
    @Path() String title,  // 'San_Francisco'
  );
}

// Response model
class WikipediaSummary {
  final String title;
  final String extract;        // Short description
  final String? thumbnail;     // Image URL
  final String? description;   // One-liner

  WikipediaSummary({
    required this.title,
    required this.extract,
    this.thumbnail,
    this.description,
  });
}
```

---

### 4. Firebase APIs

**Authentication:**
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user);
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credential.user);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges =>
    _auth.authStateChanges().map(_mapFirebaseUser);
}
```

**Firestore Operations:**
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save run to cloud
  Future<void> saveRun(String userId, Run run) async {
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('runs')
      .doc(run.id)
      .set(run.toFirestore());

    // Save route points to Storage (large data)
    await _saveRouteToStorage(userId, run.id, run.routePoints);
  }

  // Fetch user's runs
  Stream<List<Run>> watchRuns(String userId) {
    return _firestore
      .collection('users')
      .doc(userId)
      .collection('runs')
      .orderBy('startTime', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Run.fromFirestore(doc.data()))
        .toList());
  }

  // Sync local to cloud
  Future<void> syncRun(Run run) async {
    if (run.isSynced) return;

    await saveRun(run.userId, run);

    // Update local to mark as synced
    final runBox = Hive.box<Run>('runs');
    await runBox.put(run.id, run.copyWith(isSynced: true));
  }
}
```

---

## Data Flow & Synchronization

### 1. Offline-First Architecture

**Principle:** Write to local database first, sync to cloud in background

```
User Action
    ↓
Save to Hive (instant)
    ↓
Update UI (immediate feedback)
    ↓
Add to Sync Queue
    ↓
Check Network Status
    ↓
If Online → Sync to Firebase
If Offline → Queue for later
    ↓
On Success → Remove from Queue
On Failure → Retry with exponential backoff
```

---

### 2. Run Tracking Flow

```dart
class RunTrackingService {
  StreamSubscription<Position>? _positionStream;
  Run? _currentRun;
  final List<RoutePoint> _routePoints = [];

  Future<void> startRun(Goal? activeGoal) async {
    // 1. Initialize run
    _currentRun = Run(
      id: const Uuid().v4(),
      userId: _currentUser.id,
      startTime: DateTime.now(),
      goalId: activeGoal?.id,
      routePoints: [],
    );

    // 2. Start GPS tracking
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((position) {
      _onPositionUpdate(position);
    });

    // 3. Save initial state to Hive
    await _saveRunToHive();
  }

  void _onPositionUpdate(Position position) {
    // Add point to route
    final point = RoutePoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
      timestamp: DateTime.now(),
    );

    _routePoints.add(point);

    // Calculate distance increment
    if (_routePoints.length > 1) {
      final prevPoint = _routePoints[_routePoints.length - 2];
      final increment = _calculateDistance(prevPoint, point);

      _currentRun = _currentRun!.copyWith(
        distance: _currentRun!.distance + increment,
        routePoints: List.from(_routePoints),
      );
    }

    // Save to Hive every 10 points (or 30 seconds)
    if (_routePoints.length % 10 == 0) {
      _saveRunToHive();
    }

    // Update UI via state notifier
    _notifyListeners();
  }

  Future<void> stopRun() async {
    // 1. Stop GPS tracking
    await _positionStream?.cancel();

    // 2. Finalize run
    _currentRun = _currentRun!.copyWith(
      endTime: DateTime.now(),
      duration: DateTime.now().difference(_currentRun!.startTime).inSeconds,
      routePoints: List.from(_routePoints),
    );

    // 3. Calculate final statistics
    _currentRun = _calculateStatistics(_currentRun!);

    // 4. Save to Hive
    await _saveRunToHive();

    // 5. Update goal progress
    if (_currentRun!.goalId != null) {
      await _updateGoalProgress(_currentRun!);
    }

    // 6. Add to sync queue
    await _syncService.queueForSync(_currentRun!);

    // 7. Return run for summary screen
    return _currentRun!;
  }

  Future<void> _saveRunToHive() async {
    final runBox = Hive.box<Run>('runs');
    await runBox.put(_currentRun!.id, _currentRun!);
  }
}
```

---

### 3. Sync Service

```dart
class SyncService {
  final Box<String> _syncQueue = Hive.box<String>('syncQueue');
  final FirestoreService _firestoreService;
  Timer? _syncTimer;

  void startSyncService() {
    // Sync every 30 seconds when online
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _processSyncQueue();
    });

    // Also sync when network becomes available
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _processSyncQueue();
      }
    });
  }

  Future<void> queueForSync(Run run) async {
    await _syncQueue.put(run.id, run.id);
    _processSyncQueue(); // Try immediate sync
  }

  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    final isOnline = await _checkConnectivity();
    if (!isOnline) return;

    final runBox = Hive.box<Run>('runs');
    final goalBox = Hive.box<Goal>('goals');

    for (final id in List.from(_syncQueue.values)) {
      try {
        // Try to sync run
        final run = runBox.get(id);
        if (run != null && !run.isSynced) {
          await _firestoreService.saveRun(run.userId, run);

          // Mark as synced locally
          await runBox.put(id, run.copyWith(isSynced: true));

          // Remove from queue
          await _syncQueue.delete(id);
        }

        // Try to sync associated goal
        if (run?.goalId != null) {
          final goal = goalBox.get(run!.goalId);
          if (goal != null && !goal.isSynced) {
            await _firestoreService.saveGoal(goal.userId, goal);
            await goalBox.put(goal.id, goal.copyWith(isSynced: true));
          }
        }
      } catch (e) {
        // Log error, will retry in next cycle
        print('Sync failed for $id: $e');
      }
    }
  }
}
```

---

### 4. Goal Progress Calculation

```dart
class GoalService {
  Future<void> updateGoalProgress(Run run) async {
    if (run.goalId == null) return;

    final goalBox = Hive.box<Goal>('goals');
    final goal = goalBox.get(run.goalId);
    if (goal == null) return;

    // Update progress
    final updatedGoal = goal.copyWith(
      currentProgress: goal.currentProgress + run.distance,
      isSynced: false, // Mark for sync
    );

    // Check for new milestones
    final newMilestones = _checkForMilestones(updatedGoal, run.distance);

    if (newMilestones.isNotEmpty) {
      final milestonesWithReached = updatedGoal.milestones.map((m) {
        if (newMilestones.contains(m.id)) {
          return m.copyWith(isReached: true, reachedAt: DateTime.now());
        }
        return m;
      }).toList();

      final finalGoal = updatedGoal.copyWith(
        milestones: milestonesWithReached,
      );

      await goalBox.put(goal.id, finalGoal);

      // Show milestone celebration
      _notificationService.showMilestoneNotification(newMilestones);
    } else {
      await goalBox.put(goal.id, updatedGoal);
    }

    // Queue for sync
    await _syncService.queueForSync(updatedGoal);
  }

  List<String> _checkForMilestones(Goal goal, double distanceAdded) {
    final previousProgress = goal.currentProgress - distanceAdded;
    final currentProgress = goal.currentProgress;

    return goal.milestones
      .where((m) =>
        !m.isReached &&
        m.distanceFromStart <= currentProgress &&
        m.distanceFromStart > previousProgress
      )
      .map((m) => m.id)
      .toList();
  }
}
```

---

## User Flows

### Flow 1: New User Onboarding

```
1. App Launch
   ↓
2. Check Auth State
   ├─ Not Authenticated → Show Login/Signup
   │   ↓
   │  3a. User chooses Sign Up
   │   ├─ Email/Password → Create Firebase account
   │   ├─ Verify email (optional)
   │   └─ Create user profile in Firestore
   │       ↓
   │  4a. Request Location Permission
   │       ↓
   │  5a. Show Onboarding Tutorial
   │       ├─ "Track your runs"
   │       ├─ "Set a destination goal"
   │       └─ "Watch your journey progress"
   │           ↓
   │  6a. Prompt: "Create your first goal"
   │       ↓
   │  7a. Goal Creation Screen
   │       ├─ Select starting point (current location or search)
   │       ├─ Select destination (search)
   │       ├─ Preview route on map
   │       └─ Confirm goal creation
   │           ↓
   │  8a. Home Screen (goal active, ready to track)
   │
   └─ Authenticated → Load user data
       ↓
      3b. Fetch from Firestore + sync to Hive
       ↓
      4b. Home Screen
```

---

### Flow 2: Tracking a Run

```
1. Home Screen
   ↓
2. User taps "Start Run" button
   ↓
3. Check Permissions
   ├─ Location Permission Denied → Request permission
   │   ├─ Granted → Continue
   │   └─ Denied → Show error, explain why needed
   │
   └─ Location Permission Granted
       ↓
      4. Initialize GPS
       ↓
      5. Show "Run Tracking" Screen
          ├─ Live map with current location
          ├─ Real-time stats (distance, time, pace)
          ├─ Pause/Resume button
          └─ Stop button
              ↓
      6. User runs (GPS tracking active)
          ├─ Save GPS points every 10m
          ├─ Update stats in real-time
          ├─ Save to Hive every 10 points
          └─ Update UI continuously
              ↓
      7. User taps "Stop"
       ↓
      8. Finalize run data
          ├─ Calculate total distance
          ├─ Calculate duration
          ├─ Calculate average pace
          └─ Save to Hive
              ↓
      9. Update goal progress (if goal active)
          ├─ Add run distance to goal
          ├─ Check for milestones reached
          └─ Update virtual location
              ↓
     10. Show "Run Summary" Screen
          ├─ Map with full route
          ├─ Statistics
          ├─ Milestones reached (if any)
          ├─ Option to add notes
          └─ Share button
              ↓
     11. Queue for sync to Firebase
       ↓
     12. Return to Home Screen
          └─ Updated goal progress visible
```

---

### Flow 3: Creating a Goal

```
1. Home Screen or Goals Tab
   ↓
2. User taps "Create Goal" or "+" button
   ↓
3. Goal Creation Screen
   ↓
4. Step 1: Choose Starting Point
   ├─ Option A: Use current location (GPS)
   ├─ Option B: Search for a place (Mapbox Geocoding)
   │   ├─ User types city name
   │   ├─ Show search results
   │   └─ User selects result
   └─ Selected starting point shown on map
       ↓
5. Step 2: Choose Destination
   ├─ Search for a place (same as above)
   ├─ User types destination
   ├─ Show search results
   └─ User selects destination
       ↓
6. Fetch route from Mapbox Directions API
   ├─ Request walking route from start to end
   ├─ Get polyline geometry
   ├─ Calculate total distance
   └─ Display route on map
       ↓
7. Generate milestones along route
   ├─ Reverse geocode points along route (every 50-100km)
   ├─ Identify cities/landmarks
   ├─ Fetch photos from Unsplash (cache)
   └─ Fetch descriptions from Wikipedia (cache)
       ↓
8. Step 3: Preview & Confirm
   ├─ Show full route on map
   ├─ Display total distance
   ├─ Show major milestones (cities)
   ├─ Name the goal (auto: "Run to [Destination]")
   └─ User confirms
       ↓
9. Create goal in Hive
   ↓
10. Queue for sync to Firebase
   ↓
11. Set as active goal (if user wants)
   ↓
12. Return to Home Screen
    └─ New goal visible
```

---

### Flow 4: Reaching a Milestone

```
1. User completes run
   ↓
2. Goal progress updated
   ↓
3. Check if milestone reached
   ├─ No milestone → Normal flow
   │
   └─ Milestone reached!
       ↓
      4. Show celebration animation (Lottie)
       ↓
      5. Display "Milestone Reached" Screen
          ├─ City/landmark name
          ├─ Photo (from Unsplash)
          ├─ Fun fact/description (Wikipedia)
          ├─ Distance traveled so far
          ├─ Distance remaining to goal
          └─ Share button
              ↓
      6. User can:
          ├─ Share on social media
          ├─ View more details
          └─ Continue to run summary
              ↓
      7. Mark milestone as reached in Hive
       ↓
      8. Queue for sync to Firebase
       ↓
      9. Send push notification (if enabled)
          └─ "You've reached Sacramento! 🎉"
```

---

### Flow 5: Upgrading to Premium

```
1. Free user hits 100km limit
   ↓
2. Try to continue journey
   ↓
3. Show "Upgrade to Premium" Screen
   ├─ Current progress visualization
   ├─ "You've run 100km to reach [City]!"
   ├─ "Unlock unlimited distance to complete your journey"
   ├─ Benefits list
   ├─ Pricing: $2.99/mo or $19.99/year
   └─ "Upgrade Now" button
       ↓
4. User taps "Upgrade Now"
   ↓
5. Show payment options (RevenueCat)
   ├─ Monthly: $2.99/month
   └─ Annual: $19.99/year (Save 44%)
       ↓
6. User selects option
   ↓
7. Platform payment sheet (App Store / Google Play)
   ↓
8. User confirms purchase
   ↓
9. Purchase processed
   ├─ Success → Continue
   │   ↓
   │  10a. RevenueCat webhook updates backend
   │   ↓
   │  11a. Update user.isPremium = true in Firestore
   │   ↓
   │  12a. Sync to Hive
   │   ↓
   │  13a. Show "Welcome to Premium!" screen
   │   ↓
   │  14a. Remove ads
   │   ↓
   │  15a. Unlock unlimited distance
   │   ↓
   │  16a. Return to app
   │
   └─ Failure → Show error message
       └─ User can retry or cancel
```

---

## Modular Architecture

### Feature Modules

```
lib/
├─ core/                          # Shared utilities
│  ├─ constants/
│  │  ├─ api_constants.dart
│  │  ├─ app_constants.dart
│  │  └─ route_constants.dart
│  ├─ utils/
│  │  ├─ date_utils.dart
│  │  ├─ distance_utils.dart
│  │  └─ validation_utils.dart
│  ├─ extensions/
│  │  ├─ context_extension.dart
│  │  ├─ string_extension.dart
│  │  └─ datetime_extension.dart
│  └─ errors/
│     ├─ exceptions.dart
│     └─ failures.dart
│
├─ features/
│  ├─ auth/                       # Authentication feature
│  │  ├─ data/
│  │  │  ├─ models/
│  │  │  ├─ datasources/
│  │  │  └─ repositories/
│  │  ├─ domain/
│  │  │  ├─ entities/
│  │  │  └─ usecases/
│  │  └─ presentation/
│  │     ├─ providers/
│  │     ├─ screens/
│  │     └─ widgets/
│  │
│  ├─ tracking/                   # Run tracking feature
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  │
│  ├─ journey/                    # Journey/Goal feature
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  │
│  ├─ history/                    # Run history feature
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  │
│  └─ profile/                    # User profile feature
│     ├─ data/
│     ├─ domain/
│     └─ presentation/
│
└─ app/
   ├─ app.dart                    # Root app widget
   ├─ router.dart                 # Navigation
   └─ theme.dart                  # App theme
```

### Dependency Injection

```dart
// Using Riverpod for DI

// Providers
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.interceptors.add(LogInterceptor());
  return dio;
});

final mapboxApiProvider = Provider<MapboxApi>((ref) {
  return MapboxApi(ref.watch(dioProvider));
});

final runLocalDataSourceProvider = Provider<RunLocalDataSource>((ref) {
  return RunLocalDataSource(Hive.box<Run>('runs'));
});

final runRepositoryProvider = Provider<RunRepository>((ref) {
  return RunRepository(
    localDataSource: ref.watch(runLocalDataSourceProvider),
    remoteDataSource: ref.watch(firebaseDataSourceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

// Usage in widgets
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runs = ref.watch(runHistoryProvider);

    return runs.when(
      data: (runs) => RunsList(runs: runs),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## Security & Privacy

### 1. Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // User data - only owner can read/write
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // User's runs - only owner can read/write
      match /runs/{runId} {
        allow read, write: if isOwner(userId);
      }

      // User's goals - only owner can read/write
      match /goals/{goalId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User files - only owner can read/write
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null &&
                           request.auth.uid == userId;
    }
  }
}
```

---

### 2. Data Privacy

**Personal Data Handling:**
- GPS coordinates stored locally and encrypted in Hive
- Firebase data encrypted in transit (HTTPS) and at rest
- No sharing of location data with third parties
- User can delete all data (GDPR compliance)

**Privacy Policy Requirements:**
- Location data usage explanation
- Data retention policy
- Third-party services disclosure (Mapbox, Unsplash)
- User rights (access, deletion, export)

---

### 3. API Key Security

```dart
// NEVER commit API keys to git
// Use environment variables or Firebase Remote Config

class ApiKeys {
  // Load from environment or secure storage
  static String get mapboxToken =>
    const String.fromEnvironment('MAPBOX_TOKEN');

  static String get unsplashKey =>
    const String.fromEnvironment('UNSPLASH_KEY');
}

// In CI/CD, inject via secrets
// flutter build apk --dart-define=MAPBOX_TOKEN=xxx
```

---

## Performance Optimization

### 1. GPS Tracking Optimization

```dart
// Use distance filter to reduce battery drain
const locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 10,  // Only update every 10 meters
);

// Pause GPS when app in background (optional)
// Resume when app returns to foreground
```

---

### 2. Map Rendering Optimization

```dart
// Load only visible map tiles
// Use lower zoom for far-away sections
// Cache tiles locally (Mapbox SDK does this automatically)

// Simplify polylines for long routes
List<LatLng> simplifyRoute(List<LatLng> points) {
  // Douglas-Peucker algorithm
  // Reduce 1000 points to 100 without losing shape
  return DouglasPeuckerSimplifier.simplify(points, tolerance: 0.0001);
}
```

---

### 3. Image Caching

```dart
// Use cached_network_image for all photos
CachedNetworkImage(
  imageUrl: milestone.photoUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => DefaultCityImage(),
  cacheManager: CustomCacheManager(
    stalePeriod: const Duration(days: 30),  // Cache for 30 days
  ),
);
```

---

### 4. Database Optimization

```dart
// Lazy box for large data (don't load all runs into memory)
await Hive.openLazyBox<Run>('runs');

// Compact boxes periodically (removes deleted entries)
await Hive.box('runs').compact();

// Limit query results
final recentRuns = runBox.values
  .where((run) => run.startTime.isAfter(lastMonth))
  .take(50)  // Only load 50 most recent
  .toList();
```

---

## Deployment Strategy

### 1. Development Environment Setup

```bash
# Install Flutter
# See: https://docs.flutter.dev/get-started/install

# Clone repository
git clone <repo-url>
cd run-to-canada

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

---

### 2. Build Configurations

**Flavors (Dev, Staging, Production):**

```dart
// lib/app/env.dart
enum Environment {
  dev,
  staging,
  production,
}

class Env {
  static Environment get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return Environment.values.byName(env);
  }

  static String get apiBaseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.staging:
        return 'https://staging-api.runto canada.app';
      case Environment.production:
        return 'https://api.runtocanada.app';
    }
  }
}
```

**Build commands:**
```bash
# Development
flutter run --dart-define=ENV=dev

# Staging
flutter build apk --dart-define=ENV=staging

# Production
flutter build apk --dart-define=ENV=production --release
flutter build ios --dart-define=ENV=production --release
```

---

### 3. CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/build.yml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build ios --release --no-codesign
```

---

### 4. App Store Submission

**iOS (App Store):**
1. Create app in App Store Connect
2. Configure app metadata, screenshots, description
3. Build release: `flutter build ios --release`
4. Archive in Xcode
5. Upload to App Store Connect
6. Submit for review

**Android (Google Play):**
1. Create app in Google Play Console
2. Configure store listing, screenshots
3. Build release: `flutter build appbundle --release`
4. Upload to Google Play Console (Internal Testing → Closed Testing → Open Testing → Production)
5. Submit for review

---

### 5. Version Management

```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER

# Increment for:
# - MAJOR: Breaking changes
# - MINOR: New features
# - PATCH: Bug fixes
# - BUILD_NUMBER: Every release
```

---

### 6. Monitoring & Analytics

**Firebase Analytics:**
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logRunCompleted(Run run) async {
    await _analytics.logEvent(
      name: 'run_completed',
      parameters: {
        'distance': run.distance,
        'duration': run.duration,
        'has_goal': run.goalId != null,
      },
    );
  }

  Future<void> logMilestoneReached(Milestone milestone) async {
    await _analytics.logEvent(
      name: 'milestone_reached',
      parameters: {
        'milestone_name': milestone.name,
        'milestone_type': milestone.type.name,
      },
    );
  }

  Future<void> logPremiumUpgrade() async {
    await _analytics.logEvent(name: 'premium_upgrade');
  }
}
```

**Crashlytics:**
```dart
// Initialize in main()
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

// Log errors
try {
  // Some operation
} catch (error, stackTrace) {
  await FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
```

---

**Document Version:** 1.0
**Last Updated:** December 28, 2025
**Author:** Technical Team
**Status:** Ready for Implementation

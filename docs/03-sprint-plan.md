# Run to Canada - Sprint Plan

## Overview

This sprint plan divides the entire implementation into logical, atomic, and sequential sprints. Each sprint is modular and builds upon previous sprints. Every sprint contains checkable individual tasks that can be used as a tracker.

**Total Sprints:** 15
**Estimated Timeline:** 12-14 weeks (assuming 1-1.5 weeks per sprint on average)

---

## Sprint 0: Project Setup & Environment Configuration

**Goal:** Set up development environment, project structure, and foundational configuration

**Dependencies:** None (Starting sprint)

### Tasks:
- [x] Install Flutter SDK (latest stable version)
- [x] Install Android Studio and configure Android SDK
- [x] Install Xcode (macOS only) and configure iOS development
- [x] Set up IDE (VS Code or Android Studio) with Flutter/Dart plugins
- [x] Install Git and configure version control
- [x] Create GitHub repository for project
- [x] Create Flutter project: `flutter create run_to_canada`
- [x] Configure project structure with feature-based architecture
- [x] Set up `.gitignore` for Flutter project
- [x] Create initial README.md with project description
- [x] Add all dependencies to `pubspec.yaml`
- [x] Run `flutter pub get` to install dependencies
- [x] Configure build flavors (dev, staging, production)
- [x] Create environment configuration files
- [x] Set up folder structure for modular architecture
- [x] Create core utilities (constants, extensions, utils)
- [x] Run `flutter analyze` to ensure no issues
- [x] Test app runs on emulator/simulator
- [x] Test app runs on physical device
- [x] Create initial commit and push to GitHub

**Acceptance Criteria:**
- [x] Flutter app runs successfully on both iOS and Android
- [x] Project structure follows clean architecture
- [x] All dependencies installed without conflicts
- [x] Version control configured and working

**Status:** ✅ COMPLETED (2025-12-28)

---

## Sprint 1: Firebase Setup & Authentication UI

**Goal:** Set up Firebase project and implement authentication screens

**Dependencies:** Sprint 0

### Tasks:
- [x] Create Firebase project in Firebase Console
- [x] Add iOS app to Firebase project
- [x] Download and add `GoogleService-Info.plist` to iOS project
- [x] Add Android app to Firebase project
- [x] Download and add `google-services.json` to Android project
- [x] Configure Firebase in Flutter app (`firebase_core`)
- [x] Initialize Firebase in `main.dart`
- [x] Enable Email/Password authentication in Firebase Console
- [x] Create app theme (colors, text styles, button styles)
- [x] Design and implement Login screen UI
- [x] Design and implement Signup screen UI
- [x] Design and implement Forgot Password screen UI
- [x] Create reusable form widgets (text fields, buttons)
- [x] Add form validation (email, password strength)
- [x] Implement loading indicators for auth actions
- [x] Create error message display widgets
- [x] Set up navigation structure (routing)
- [x] Test UI on different screen sizes
- [x] Test UI in dark mode (if supporting)
- [x] Create auth state provider (Riverpod)

**Acceptance Criteria:**
- [x] Firebase configured for both iOS and Android
- [x] Authentication UI screens complete and visually polished
- [x] Form validation works correctly
- [x] Navigation between auth screens functional

**Status:** ✅ COMPLETED (2025-12-28)

---

## Sprint 2: Firebase Authentication Logic

**Goal:** Implement authentication business logic and user management

**Dependencies:** Sprint 1

### Tasks:
- [x] Create `AuthService` class for Firebase Auth operations
- [x] Implement email/password sign up functionality
- [x] Implement email/password sign in functionality
- [x] Implement sign out functionality
- [x] Implement password reset functionality
- [x] Create `User` model class
- [x] Create `UserSettings` model class
- [x] Set up Firestore collection for user profiles
- [x] Create user profile on signup
- [x] Implement auth state stream (listen to auth changes)
- [x] Create auth providers using Riverpod
- [x] Connect login screen to authentication logic
- [x] Connect signup screen to authentication logic
- [x] Connect forgot password screen to logic
- [x] Handle authentication errors gracefully
- [x] Display error messages to user
- [x] Implement loading states during auth operations
- [x] Test successful signup flow
- [x] Test successful login flow
- [x] Test logout flow
- [x] Test error scenarios (wrong password, email in use, etc.)
- [x] Set up Firebase Security Rules for user data
- [x] Test security rules in Firebase Console

**Acceptance Criteria:**
- [x] Users can successfully sign up with email/password
- [x] Users can log in and log out
- [x] Password reset emails are sent
- [x] User profiles created in Firestore
- [x] Auth state persists across app restarts
- [x] Errors handled and displayed appropriately

**Status:** ✅ COMPLETED (2025-12-28)

---

## Sprint 3: Local Database Setup (Hive)

**Goal:** Set up Hive local database and data models

**Dependencies:** Sprint 0

### Tasks:
- [x] Initialize Hive in Flutter app
- [x] Create Hive type adapters for models
- [x] Create `Run` model with Hive annotations
- [x] Create `RoutePoint` model with Hive annotations
- [x] Create `Goal` model with Hive annotations
- [x] Create `Location` model with Hive annotations
- [x] Create `Milestone` model with Hive annotations
- [x] Create `UserSettings` model with Hive annotations
- [x] Create `SyncQueueItem` model with Hive annotations
- [x] Generate Hive type adapters with `build_runner`
- [x] Create Hive boxes initialization function (HiveService)
- [x] Open boxes: `runs`, `goals`, `userSettings`, `syncQueue`, `cache`
- [x] Create `RunLocalDataSource` class
- [x] Create `GoalLocalDataSource` class
- [x] Create `UserLocalDataSource` class
- [x] Implement CRUD operations for runs in local datasource
- [x] Implement CRUD operations for goals in local datasource
- [x] Implement CRUD operations for user settings
- [x] Create `RunRepository` interface
- [x] Create `GoalRepository` interface
- [x] Create `RunRepositoryImpl` class
- [x] Create `GoalRepositoryImpl` class
- [x] Integrate Hive initialization in main.dart
- [x] Run flutter analyze (all checks passed)
- [x] Test build (successfully builds)
- [x] Implement box compaction for performance

**Acceptance Criteria:**
- [x] All data models created with proper Hive annotations
- [x] Hive boxes open successfully
- [x] Data can be written to and read from Hive
- [x] Data persists across app restarts
- [x] Repository pattern established

**Status:** ✅ COMPLETED (2025-12-30)

---

## Sprint 4: GPS Tracking Core Functionality

**Goal:** Implement GPS location tracking during runs

**Dependencies:** Sprint 3

### Tasks:
- [x] Add location permissions to iOS `Info.plist`
- [x] Add location permissions to Android `AndroidManifest.xml`
- [x] Create `LocationService` class using `geolocator` package
- [x] Request location permissions from user
- [x] Handle permission denied scenarios
- [x] Implement foreground location tracking
- [x] Configure location settings (accuracy, distance filter)
- [x] Create `RunTrackingService` class
- [x] Implement `startRun()` method
- [x] Implement `pauseRun()` method
- [x] Implement `resumeRun()` method
- [x] Implement `stopRun()` method
- [x] Implement `cancelRun()` method
- [x] Create GPS position stream subscription
- [x] Store GPS points in `RoutePoint` list
- [x] Calculate distance between consecutive GPS points
- [x] Calculate cumulative distance during run
- [x] Calculate run duration (elapsed time, excluding paused time)
- [x] Calculate average pace (min/km)
- [x] Calculate elevation gain
- [x] Calculate max speed
- [x] Estimate calories burned
- [x] Save run data to Hive when stopped
- [x] Create `RunTrackingProvider` using Riverpod
- [x] Create real-time status and stats streams
- [x] Create RunStats class for live metrics
- [x] Run flutter analyze (all checks passed)
- [x] Test build (successfully builds)

**Acceptance Criteria:**
- [x] App requests and receives location permissions
- [x] GPS tracking starts and stops correctly
- [x] GPS points captured and stored
- [x] Distance calculated accurately
- [x] Pace and duration calculated correctly
- [x] Run data saved to Hive
- [x] Real-time statistics available via streams
- [x] Pause/resume functionality implemented

**Status:** ✅ COMPLETED (2025-12-30)

---

## Sprint 5: Run Tracking UI

**Goal:** Create user interface for tracking runs in real-time

**Dependencies:** Sprint 4

### Tasks:
- [x] Design Run Tracking screen layout
- [x] Create Run Tracking screen widget
- [x] Add "Start Run" button to home screen
- [x] Implement navigation to Run Tracking screen
- [x] Display real-time distance during run
- [x] Display real-time duration (timer) during run
- [x] Display real-time pace during run
- [x] Display current speed
- [x] Create pause/resume button UI
- [x] Create stop button UI
- [x] Add confirmation dialog for stopping run
- [x] Display route points indicator (replacing GPS accuracy)
- [x] Add visual feedback for run status
- [x] Create loading state while initializing GPS
- [x] Display permission request UI if needed
- [x] Connect UI to `RunTrackingProvider`
- [x] Update UI in real-time as GPS data comes in
- [x] Format distance display (km or miles based on settings)
- [x] Format duration display (HH:MM:SS)
- [x] Format pace display (min/km or min/mile)
- [x] Test UI state changes (running, paused, stopped)
- [x] Created Riverpod providers for run tracking state
- [x] Run flutter analyze (all checks passed)
- [x] Test build (successfully builds)

**Acceptance Criteria:**
- [x] Run tracking UI displays all real-time metrics
- [x] Start, pause, resume, stop actions work correctly
- [x] UI updates smoothly via stream providers
- [x] UI handles permission states appropriately
- [x] Visual design is clean and readable

**Status:** ✅ COMPLETED (2025-12-30)

---

## Sprint 6: Run Summary & History

**Goal:** Implement run summary screen and run history list

**Dependencies:** Sprint 5

### Tasks:
- [x] Design Run Summary screen layout
- [x] Create Run Summary screen widget
- [x] Navigate to Run Summary after run stops
- [x] Display total distance in summary
- [x] Display total duration in summary
- [x] Display average pace in summary
- [x] Display elevation gain (if available)
- [x] Display calories burned (estimated)
- [x] Add text field for run notes
- [x] Save run notes to Hive (prepared for Sprint 13)
- [x] Create "Save Run" button
- [x] Create "Discard Run" button
- [x] Add confirmation dialog for discarding run
- [x] Design Run History screen layout
- [x] Create Run History screen widget
- [x] Fetch all runs from Hive
- [x] Display runs in chronological order (newest first)
- [x] Create run list item widget
- [x] Display run date, distance, duration in list
- [x] Implement pull-to-refresh for run history
- [x] Implement navigation to run detail from list
- [x] Create Run Detail screen
- [x] Display full run statistics in detail screen
- [x] Add delete run functionality
- [x] Add confirmation dialog for deleting run
- [x] Test run history with multiple runs
- [x] Test empty state (no runs yet)
- [ ] Add filtering options (by date range) (Deferred to future sprint)

**Acceptance Criteria:**
- [x] Run summary displays all relevant statistics
- [x] Users can add notes to runs
- [x] Run history shows all completed runs
- [x] Users can view details of any run
- [x] Users can delete runs
- [x] Empty states handled gracefully

**Status:** ✅ COMPLETED (2025-12-30)

---

## Sprint 7: Mapbox Integration & Basic Map Display

**Goal:** Integrate Mapbox and display basic map functionality

**Dependencies:** Sprint 0

### Tasks:
- [ ] Create Mapbox account
- [ ] Generate Mapbox access token
- [ ] Add Mapbox token to environment configuration
- [ ] Configure Mapbox for iOS (update `Info.plist`)
- [ ] Configure Mapbox for Android (update `build.gradle`)
- [ ] Install and configure `mapbox_gl` Flutter package
- [ ] Create `MapboxService` class
- [ ] Initialize Mapbox map controller
- [ ] Create basic map widget
- [ ] Display map with user's current location
- [ ] Implement map camera controls (zoom, pan)
- [ ] Add user location marker on map
- [ ] Test map rendering on iOS
- [ ] Test map rendering on Android
- [ ] Implement map style selection (streets, satellite, outdoors)
- [ ] Create map style switcher UI
- [ ] Store preferred map style in user settings
- [ ] Test different map styles
- [ ] Handle map initialization errors
- [ ] Add loading indicator while map initializes
- [ ] Test map performance with different zoom levels
- [ ] Optimize map tile caching

**Acceptance Criteria:**
- Mapbox displays correctly on both platforms
- User's current location shown on map
- Map is interactive (zoom, pan)
- Different map styles can be selected
- Map loads and performs well

---

## Sprint 8: Route Visualization on Map

**Goal:** Display run routes and journey progress on map

**Dependencies:** Sprint 6, Sprint 7

### Tasks:
- [ ] Create function to draw polyline on map
- [ ] Draw run route on Run Summary screen map
- [ ] Display all route points as polyline
- [ ] Style polyline (color, width, opacity)
- [ ] Add start marker to route
- [ ] Add end marker to route
- [ ] Center map camera on full route
- [ ] Calculate map bounds to fit entire route
- [ ] Implement animated camera movement to route
- [ ] Display route in Run Detail screen
- [ ] Create live route tracking in Run Tracking screen
- [ ] Update polyline in real-time during run
- [ ] Add current position marker (moving along route)
- [ ] Simplify long routes to improve performance
- [ ] Implement Douglas-Peucker algorithm for simplification
- [ ] Test route rendering with short runs
- [ ] Test route rendering with long runs (100+ points)
- [ ] Test route rendering with complex paths
- [ ] Optimize polyline rendering performance
- [ ] Add route distance overlay on map

**Acceptance Criteria:**
- Run routes displayed accurately on map
- Routes are visually clear and styled appropriately
- Map camera automatically fits routes
- Performance is good even with long routes
- Real-time tracking shows route as it's being created

---

## Sprint 9: Goal Creation - Part 1 (Search & Selection)

**Goal:** Implement goal creation flow - location search and selection

**Dependencies:** Sprint 7

### Tasks:
- [ ] Design Goal Creation screen layout
- [ ] Create Goal Creation screen widget
- [ ] Add "Create Goal" button to home screen
- [ ] Implement navigation to Goal Creation screen
- [ ] Create step-by-step wizard UI (Step 1: Start, Step 2: Destination)
- [ ] Create location search text field
- [ ] Integrate Mapbox Geocoding API
- [ ] Create `GeocodingService` class
- [ ] Implement location search functionality
- [ ] Display search results in dropdown/list
- [ ] Handle no results scenario
- [ ] Display search results on map
- [ ] Allow user to select from search results
- [ ] Implement "Use Current Location" button for start point
- [ ] Get user's current GPS location
- [ ] Display selected start location on map
- [ ] Create location selection confirmation UI
- [ ] Move to Step 2: Destination selection
- [ ] Implement same search flow for destination
- [ ] Display both start and destination on map
- [ ] Test location search with various queries
- [ ] Test search with international locations
- [ ] Handle API errors gracefully
- [ ] Add debouncing to search input (avoid too many API calls)
- [ ] Cache search results locally

**Acceptance Criteria:**
- Users can search for any location in the world
- Search results are accurate and relevant
- Selected locations displayed clearly on map
- "Use Current Location" works correctly
- UI guides user through selection process smoothly

---

## Sprint 10: Goal Creation - Part 2 (Route & Milestones)

**Goal:** Complete goal creation with route calculation and milestone generation

**Dependencies:** Sprint 9

### Tasks:
- [ ] Integrate Mapbox Directions API
- [ ] Create `DirectionsService` class
- [ ] Fetch walking route from start to destination
- [ ] Parse route geometry (polyline)
- [ ] Calculate total route distance
- [ ] Display route on map
- [ ] Create `MilestoneService` class
- [ ] Generate milestone points along route (every 50-100km)
- [ ] Reverse geocode milestone points to get city names
- [ ] Create `Milestone` objects for each city
- [ ] Display milestones as markers on map
- [ ] Fetch city photos from Unsplash API
- [ ] Create `UnsplashService` class
- [ ] Search for city photos (e.g., "{city name} skyline")
- [ ] Cache photos in Hive cache box
- [ ] Fetch city information from Wikipedia API
- [ ] Create `WikipediaService` class
- [ ] Get short description of each milestone city
- [ ] Cache descriptions in Hive
- [ ] Display milestone preview in goal creation
- [ ] Show major cities along route
- [ ] Create goal name input field
- [ ] Auto-populate goal name: "Run to {destination}"
- [ ] Allow user to edit goal name
- [ ] Add "Create Goal" confirmation button
- [ ] Validate all required fields
- [ ] Save goal to Hive
- [ ] Test route calculation for various distances
- [ ] Test milestone generation for short routes (<100km)
- [ ] Test milestone generation for long routes (>1000km)
- [ ] Handle API rate limits
- [ ] Handle routes with no major cities (use distance markers)

**Acceptance Criteria:**
- Route calculated accurately between start and destination
- Milestones generated along route
- City photos and descriptions fetched and cached
- Goal created successfully and saved to Hive
- UI shows preview of goal before creation

---

## Sprint 11: Journey Visualization & Progress Tracking

**Goal:** Display goal progress and journey visualization on map

**Dependencies:** Sprint 10, Sprint 8

### Tasks:
- [ ] Design Journey Map screen layout
- [ ] Create Journey Map screen widget
- [ ] Add navigation to Journey Map from home screen
- [ ] Fetch active goal from Hive
- [ ] Display goal route on map
- [ ] Display start point marker
- [ ] Display destination marker
- [ ] Calculate current virtual location based on progress
- [ ] Add virtual location marker (current position on journey)
- [ ] Style different segments of route (completed vs remaining)
- [ ] Draw completed segment in different color
- [ ] Draw remaining segment in different color
- [ ] Display all milestones as markers
- [ ] Style reached milestones differently (e.g., green)
- [ ] Style unreached milestones differently (e.g., gray)
- [ ] Display progress percentage
- [ ] Display distance completed
- [ ] Display distance remaining
- [ ] Create milestone detail bottom sheet
- [ ] Tap milestone marker to show details
- [ ] Display milestone city name, photo, description
- [ ] Display distance from start to milestone
- [ ] Display whether milestone is reached
- [ ] Implement animated camera to virtual location
- [ ] Add "Center on Progress" button
- [ ] Test with different progress percentages
- [ ] Test with multiple milestones reached
- [ ] Create empty state (no active goal)
- [ ] Add "Create Your First Goal" CTA

**Acceptance Criteria:**
- Journey map clearly shows progress toward destination
- Completed and remaining segments visually distinct
- Current virtual location accurately displayed
- Milestones interactive and informative
- UI handles all progress states (0%, 50%, 100%)

---

## Sprint 12: Goal Progress Update Logic

**Goal:** Update goal progress when runs are completed

**Dependencies:** Sprint 11, Sprint 6

### Tasks:
- [ ] Create `GoalService` class
- [ ] Implement `updateGoalProgress()` method
- [ ] Fetch active goal when run completes
- [ ] Add run distance to goal's current progress
- [ ] Check if any new milestones reached
- [ ] Compare previous progress vs new progress
- [ ] Identify milestones crossed
- [ ] Mark milestones as reached
- [ ] Set `reachedAt` timestamp for milestones
- [ ] Save updated goal to Hive
- [ ] Display milestone celebration if reached
- [ ] Create Milestone Reached screen
- [ ] Design celebration animation (use Lottie)
- [ ] Display milestone city name and photo
- [ ] Display fun fact about the city
- [ ] Display progress stats (distance so far, distance remaining)
- [ ] Add "Share" button for milestone achievement
- [ ] Create milestone notification
- [ ] Send local push notification when milestone reached
- [ ] Test progress update with active goal
- [ ] Test with no active goal (should skip update)
- [ ] Test milestone detection near boundaries
- [ ] Test multiple milestones reached in one run (edge case)
- [ ] Update Journey Map after run completes
- [ ] Refresh map to show new progress

**Acceptance Criteria:**
- Goal progress updates correctly after each run
- Milestones detected and marked as reached
- Celebration screen shown for new milestones
- Progress persists in Hive
- Journey map reflects updated progress

---

## Sprint 13: Firebase Sync & Cloud Backup

**Goal:** Implement data synchronization between local (Hive) and cloud (Firebase)

**Dependencies:** Sprint 2, Sprint 3, Sprint 6, Sprint 10

### Tasks:
- [ ] Create `SyncService` class
- [ ] Create `FirestoreDataSource` class
- [ ] Implement `saveRun()` to Firestore
- [ ] Convert `Run` model to Firestore format
- [ ] Save run document to Firestore collection
- [ ] Compress and upload route points to Firebase Storage
- [ ] Implement `saveGoal()` to Firestore
- [ ] Convert `Goal` model to Firestore format
- [ ] Save goal document to Firestore
- [ ] Implement `fetchRuns()` from Firestore
- [ ] Implement `fetchGoals()` from Firestore
- [ ] Create sync queue in Hive (`syncQueue` box)
- [ ] Add items to sync queue when saved locally
- [ ] Implement `processSyncQueue()` method
- [ ] Check network connectivity before syncing
- [ ] Use `connectivity_plus` package
- [ ] Sync items from queue when online
- [ ] Mark items as synced after successful upload
- [ ] Remove from sync queue after sync
- [ ] Handle sync errors (retry with exponential backoff)
- [ ] Implement periodic sync (every 30 seconds)
- [ ] Listen to connectivity changes
- [ ] Trigger sync when network becomes available
- [ ] Sync user settings to Firestore
- [ ] Test sync with new run
- [ ] Test sync when offline (should queue)
- [ ] Test sync when coming back online (should process queue)
- [ ] Test sync errors and retries
- [ ] Add sync status indicator in UI
- [ ] Display "Syncing..." indicator when sync in progress
- [ ] Display "Synced" status when complete
- [ ] Test multi-device sync (same user on 2 devices)

**Acceptance Criteria:**
- Data syncs from local to cloud automatically
- Sync works seamlessly in background
- Offline changes queued and synced when online
- Sync errors handled gracefully
- User can see sync status

---

## Sprint 14: User Profile & Settings

**Goal:** Implement user profile screen and app settings

**Dependencies:** Sprint 2, Sprint 13

### Tasks:
- [ ] Design Profile screen layout
- [ ] Create Profile screen widget
- [ ] Add navigation to Profile from home screen
- [ ] Display user email
- [ ] Display user name (if set)
- [ ] Add profile photo (optional feature)
- [ ] Allow user to upload profile photo to Firebase Storage
- [ ] Display total runs count
- [ ] Display total distance run
- [ ] Display total goals created
- [ ] Display premium status
- [ ] Create Settings screen
- [ ] Add navigation to Settings from Profile
- [ ] Create unit preference setting (metric/imperial)
- [ ] Toggle between kilometers and miles
- [ ] Save preference to user settings
- [ ] Update all distance displays based on preference
- [ ] Create map style preference setting
- [ ] Allow user to choose default map style
- [ ] Create notification settings
- [ ] Toggle milestone notifications
- [ ] Toggle run reminders (future feature)
- [ ] Implement logout functionality
- [ ] Add logout button
- [ ] Confirm logout with dialog
- [ ] Clear local data on logout (optional)
- [ ] Implement delete account functionality
- [ ] Add delete account button in settings
- [ ] Show warning dialog before deletion
- [ ] Delete user data from Firestore
- [ ] Delete user authentication account
- [ ] Clear local Hive data
- [ ] Test settings persistence
- [ ] Test unit conversion throughout app
- [ ] Test logout flow
- [ ] Test account deletion flow

**Acceptance Criteria:**
- Profile displays user information and statistics
- Settings allow customization of units and preferences
- Settings persist across app restarts
- Logout works correctly
- Account deletion removes all data

---

## Sprint 15: Premium Features & Paywall

**Goal:** Implement freemium model with 100km limit and premium upgrade

**Dependencies:** Sprint 11, Sprint 12

### Tasks:
- [ ] Create premium status check utility
- [ ] Implement 100km limit check for free users
- [ ] Check goal progress before allowing new runs
- [ ] Show paywall when free user hits 100km
- [ ] Design Paywall screen layout
- [ ] Create Paywall screen widget
- [ ] Display benefits of premium
- [ ] Show pricing: $2.99/month or $19.99/year
- [ ] Highlight annual savings (44% off)
- [ ] Set up RevenueCat account
- [ ] Configure products in RevenueCat dashboard
- [ ] Add RevenueCat SDK to Flutter app
- [ ] Initialize RevenueCat with API key
- [ ] Configure iOS products in App Store Connect
- [ ] Configure Android products in Google Play Console
- [ ] Implement purchase flow
- [ ] Fetch available products from RevenueCat
- [ ] Display products in paywall
- [ ] Handle purchase initiation
- [ ] Process purchase with platform (App Store/Play Store)
- [ ] Listen for purchase updates
- [ ] Update user's premium status in Firestore
- [ ] Update local premium status in Hive
- [ ] Remove ads for premium users (when ads implemented)
- [ ] Unlock unlimited distance for premium users
- [ ] Implement restore purchases functionality
- [ ] Test purchase flow on iOS TestFlight
- [ ] Test purchase flow on Android Internal Testing
- [ ] Test restore purchases
- [ ] Handle purchase errors
- [ ] Handle cancelled purchases
- [ ] Test free user flow (hitting 100km limit)
- [ ] Test premium user flow (no limits)
- [ ] Add "Upgrade to Premium" CTA in appropriate places

**Acceptance Criteria:**
- Free users limited to 100km journey distance
- Paywall appears when limit reached
- Premium purchase flow works on both platforms
- Premium status synced to cloud and local
- Premium users have unlimited distance
- Restore purchases works correctly

---

## Sprint 16: Ad Integration (AdMob)

**Goal:** Integrate AdMob ads for free tier users

**Dependencies:** Sprint 15

### Tasks:
- [ ] Create AdMob account
- [ ] Create ad units in AdMob console
- [ ] Create banner ad unit for home screen
- [ ] Create interstitial ad unit for post-run
- [ ] Add AdMob app ID to iOS `Info.plist`
- [ ] Add AdMob app ID to Android `AndroidManifest.xml`
- [ ] Initialize Google Mobile Ads SDK
- [ ] Create `AdService` class
- [ ] Load banner ad for home screen
- [ ] Display banner ad for free users only
- [ ] Hide banner ad for premium users
- [ ] Load interstitial ad
- [ ] Show interstitial ad after run completion (occasionally)
- [ ] Limit interstitial frequency (e.g., once per 3 runs)
- [ ] Handle ad load failures gracefully
- [ ] Don't block app functionality if ads fail
- [ ] Test banner ad display on home screen
- [ ] Test interstitial ad after run
- [ ] Test ad hiding for premium users
- [ ] Test ad behavior with poor network
- [ ] Configure ad mediation (optional, for better CPM)
- [ ] Test ads in staging mode first
- [ ] Switch to production ads before launch
- [ ] Monitor ad performance in AdMob console

**Acceptance Criteria:**
- Banner ads display on home screen for free users
- Interstitial ads show occasionally after runs
- Ads never shown to premium users
- Ads don't interfere with core functionality
- Ad failures handled gracefully

---

## Sprint 17: Onboarding & Tutorial

**Goal:** Create first-time user onboarding experience

**Dependencies:** Sprint 14

### Tasks:
- [ ] Design onboarding flow (3-4 screens)
- [ ] Create Onboarding screen widget
- [ ] Screen 1: Welcome & app introduction
- [ ] Screen 2: GPS tracking explanation
- [ ] Screen 3: Journey concept explanation
- [ ] Screen 4: Goal creation preview
- [ ] Add illustrations or animations to onboarding
- [ ] Use Lottie animations for visual appeal
- [ ] Implement page indicator (dots)
- [ ] Add "Next" button for each screen
- [ ] Add "Skip" button to skip onboarding
- [ ] Add "Get Started" button on final screen
- [ ] Request location permission during onboarding
- [ ] Explain why location permission is needed
- [ ] Store onboarding completion status
- [ ] Don't show onboarding again after first time
- [ ] Create interactive tutorial for goal creation
- [ ] Highlight important UI elements
- [ ] Use tooltips or overlays
- [ ] Create tutorial for starting first run
- [ ] Test onboarding flow from fresh install
- [ ] Test skip functionality
- [ ] Test permission request flow
- [ ] Ensure onboarding only shows once

**Acceptance Criteria:**
- Onboarding appears on first app launch
- Onboarding explains core app concepts clearly
- Users can skip or complete onboarding
- Location permission requested at appropriate time
- Onboarding only shown once per user

---

## Sprint 18: Polish, Testing & Bug Fixes

**Goal:** Polish UI, fix bugs, and prepare for beta testing

**Dependencies:** All previous sprints

### Tasks:
- [ ] Conduct thorough app testing on iOS
- [ ] Conduct thorough app testing on Android
- [ ] Test all user flows end-to-end
- [ ] Test authentication flows
- [ ] Test run tracking flows
- [ ] Test goal creation flows
- [ ] Test journey visualization
- [ ] Test premium upgrade flow
- [ ] Test all edge cases
- [ ] Test with no internet connection
- [ ] Test with poor GPS signal
- [ ] Test with app in background
- [ ] Test with app killed and reopened
- [ ] Test with very long runs (100+ km)
- [ ] Test with multiple goals
- [ ] Fix all critical bugs
- [ ] Fix all high-priority bugs
- [ ] Fix UI inconsistencies
- [ ] Improve error messages (make them user-friendly)
- [ ] Add loading states to all async operations
- [ ] Optimize app performance
- [ ] Reduce app startup time
- [ ] Optimize map rendering
- [ ] Reduce battery consumption during tracking
- [ ] Implement app analytics
- [ ] Track key user events (signup, run completed, goal created, etc.)
- [ ] Set up crash reporting (Crashlytics)
- [ ] Test on different device sizes
- [ ] Test on older devices (minimum supported versions)
- [ ] Accessibility improvements
- [ ] Add semantic labels for screen readers
- [ ] Ensure sufficient color contrast
- [ ] Test with accessibility features enabled
- [ ] Update app icons and splash screen
- [ ] Ensure branding is consistent throughout
- [ ] Proofread all text in the app
- [ ] Fix typos and improve copy

**Acceptance Criteria:**
- App is stable with no critical bugs
- All features work as expected
- App performs well on target devices
- UI is polished and consistent
- Analytics and crash reporting working

---

## Sprint 19: App Store Assets & Metadata

**Goal:** Create app store listings and marketing materials

**Dependencies:** Sprint 18

### Tasks:
- [ ] Design app icon (1024x1024 for both stores)
- [ ] Export app icon in all required sizes
- [ ] Design splash screen
- [ ] Create App Store screenshots (iOS)
- [ ] Screenshot: Home screen with goal
- [ ] Screenshot: Run tracking in progress
- [ ] Screenshot: Journey map visualization
- [ ] Screenshot: Milestone celebration
- [ ] Screenshot: Run history
- [ ] Add captions/highlights to screenshots
- [ ] Create Google Play screenshots (Android)
- [ ] Create feature graphic for Google Play (1024x500)
- [ ] Write app description for App Store
- [ ] Write short description for App Store
- [ ] Write app description for Google Play
- [ ] Write short description for Google Play
- [ ] Create promotional text
- [ ] Define app keywords for ASO (App Store Optimization)
- [ ] Prepare privacy policy URL
- [ ] Prepare terms of service URL
- [ ] Create support email address
- [ ] Set up app website or landing page (optional)
- [ ] Create demo video (optional but recommended)
- [ ] Get age rating for app
- [ ] Determine content rating category
- [ ] Review App Store guidelines
- [ ] Review Google Play policies
- [ ] Ensure app complies with all policies

**Acceptance Criteria:**
- App icon designed and exported
- Screenshots created for both platforms
- App descriptions written and compelling
- All required metadata prepared
- App complies with store policies

---

## Sprint 20: iOS App Store Submission

**Goal:** Submit app to Apple App Store

**Dependencies:** Sprint 19

### Tasks:
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Create App Store Connect account
- [ ] Create app record in App Store Connect
- [ ] Fill in app information (name, category, etc.)
- [ ] Upload app icon
- [ ] Upload screenshots for all required device sizes
- [ ] iPhone 6.7" (Pro Max)
- [ ] iPhone 6.5" (Plus)
- [ ] iPhone 5.5" (older devices)
- [ ] iPad Pro 12.9" (if supporting iPad)
- [ ] Write app description and metadata
- [ ] Set app pricing (free with in-app purchases)
- [ ] Configure in-app purchases in App Store Connect
- [ ] Monthly subscription ($2.99)
- [ ] Annual subscription ($19.99)
- [ ] Add privacy policy URL
- [ ] Add support URL
- [ ] Fill in age rating questionnaire
- [ ] Configure App Store distribution certificate
- [ ] Configure provisioning profile for production
- [ ] Update app version in `pubspec.yaml` (1.0.0)
- [ ] Build release version: `flutter build ios --release`
- [ ] Archive app in Xcode
- [ ] Upload build to App Store Connect
- [ ] Select build for version
- [ ] Submit app for review
- [ ] Fill in review notes (test account credentials)
- [ ] Wait for Apple review (typically 1-3 days)
- [ ] Respond to any rejection feedback
- [ ] Fix issues if rejected
- [ ] Resubmit if necessary
- [ ] Monitor review status in App Store Connect

**Acceptance Criteria:**
- App submitted to App Store successfully
- All required information provided
- In-app purchases configured
- Build uploaded without errors

---

## Sprint 21: Android Play Store Submission

**Goal:** Submit app to Google Play Store

**Dependencies:** Sprint 19

### Tasks:
- [ ] Create Google Play Console account ($25 one-time fee)
- [ ] Create app in Play Console
- [ ] Select app name
- [ ] Choose default language
- [ ] Choose app or game category
- [ ] Fill in app details
- [ ] Short description (80 characters)
- [ ] Full description (4000 characters)
- [ ] Upload app icon (512x512)
- [ ] Upload feature graphic (1024x500)
- [ ] Upload screenshots (at least 2, up to 8)
- [ ] Phone screenshots
- [ ] Tablet screenshots (if supporting)
- [ ] Add privacy policy URL
- [ ] Configure app content rating
- [ ] Fill out content rating questionnaire
- [ ] Set up pricing & distribution
- [ ] Select countries for distribution
- [ ] Set app as free with in-app purchases
- [ ] Configure in-app products
- [ ] Monthly subscription ($2.99)
- [ ] Annual subscription ($19.99)
- [ ] Activate subscriptions in Play Console
- [ ] Generate upload keystore for signing
- [ ] Configure app signing in `android/app/build.gradle`
- [ ] Update app version in `pubspec.yaml` (1.0.0)
- [ ] Build release bundle: `flutter build appbundle --release`
- [ ] Upload app bundle to Play Console (Internal Testing first)
- [ ] Create internal testing release
- [ ] Add internal testers (your email)
- [ ] Test app via internal testing
- [ ] Promote to Closed Testing (optional beta)
- [ ] Add beta testers
- [ ] Promote to Production
- [ ] Submit for review
- [ ] Wait for Google review (typically 1-7 days)
- [ ] Respond to any policy violations
- [ ] Fix issues if rejected
- [ ] Resubmit if necessary

**Acceptance Criteria:**
- App submitted to Google Play successfully
- All required information provided
- In-app products configured and active
- App bundle uploaded without errors

---

## Sprint 22: Beta Testing & Feedback

**Goal:** Conduct beta testing with real users and gather feedback

**Dependencies:** Sprint 20, Sprint 21

### Tasks:
- [ ] Recruit beta testers (aim for 20-50 users)
- [ ] Friends and family
- [ ] Running community members
- [ ] Social media posts
- [ ] Set up TestFlight for iOS beta
- [ ] Add beta testers to TestFlight
- [ ] Distribute TestFlight link
- [ ] Set up Google Play Closed Testing
- [ ] Add beta testers to Play Console
- [ ] Distribute Play Store beta link
- [ ] Create beta testing feedback form
- [ ] Google Form or Typeform
- [ ] Ask about user experience
- [ ] Ask about bugs encountered
- [ ] Ask about feature requests
- [ ] Send beta testing instructions to testers
- [ ] How to use the app
- [ ] What to test
- [ ] How to report bugs
- [ ] Monitor beta tester activity
- [ ] Track analytics events
- [ ] Monitor crash reports
- [ ] Review Crashlytics for errors
- [ ] Collect feedback from testers
- [ ] Read feedback form responses
- [ ] Respond to tester emails
- [ ] Prioritize feedback and bugs
- [ ] Create bug list
- [ ] Create feature request list
- [ ] Fix critical bugs
- [ ] Fix high-priority bugs
- [ ] Consider feature requests for next version
- [ ] Release beta updates
- [ ] Test bug fixes with beta users
- [ ] Iterate based on feedback (1-2 weeks)
- [ ] Prepare for public launch

**Acceptance Criteria:**
- At least 20 beta testers actively using app
- Feedback collected and analyzed
- Critical bugs identified and fixed
- App is stable and ready for public release

---

## Sprint 23: Launch Preparation & Marketing

**Goal:** Prepare for public launch and initial marketing

**Dependencies:** Sprint 22

### Tasks:
- [ ] Finalize app based on beta feedback
- [ ] Update app version to 1.0.0 (if not already)
- [ ] Create launch plan and timeline
- [ ] Set launch date
- [ ] Prepare social media accounts
- [ ] Create Twitter/X account
- [ ] Create Instagram account
- [ ] Create Facebook page (optional)
- [ ] Create LinkedIn page (optional)
- [ ] Design social media graphics
- [ ] App announcement post
- [ ] Feature highlights
- [ ] Screenshots and demo video
- [ ] Write launch blog post (if you have a blog)
- [ ] Prepare Product Hunt launch
- [ ] Create Product Hunt account
- [ ] Prepare product description
- [ ] Upload app screenshots and demo
- [ ] Schedule launch on Product Hunt
- [ ] Create press release (optional)
- [ ] Reach out to tech blogs/journalists
- [ ] TechCrunch, The Verge (long shot)
- [ ] Niche running/fitness blogs (more likely)
- [ ] Prepare App Store Optimization (ASO)
- [ ] Update app keywords
- [ ] A/B test app descriptions (if possible)
- [ ] Encourage early reviews
- [ ] Set up analytics tracking for launch
- [ ] Monitor download numbers
- [ ] Monitor user acquisition channels
- [ ] Create email newsletter (optional)
- [ ] Collect emails from interested users
- [ ] Send launch announcement
- [ ] Prepare customer support
- [ ] Set up support email
- [ ] Create FAQ document
- [ ] Prepare canned responses for common questions
- [ ] Launch app on App Store
- [ ] Release from TestFlight to production
- [ ] Launch app on Google Play
- [ ] Release from closed testing to production
- [ ] Announce launch on social media
- [ ] Post on Product Hunt
- [ ] Share in running communities (Reddit, Facebook groups)
- [ ] Monitor launch day metrics

**Acceptance Criteria:**
- App live on both App Store and Google Play
- Social media accounts created and active
- Launch announcement published
- Initial marketing activities executed
- Support infrastructure in place

---

## Sprint 24: Post-Launch Monitoring & Iteration

**Goal:** Monitor app performance post-launch and iterate based on user feedback

**Dependencies:** Sprint 23

### Tasks:
- [ ] Monitor app analytics daily
- [ ] Daily active users (DAU)
- [ ] Weekly active users (WAU)
- [ ] Monthly active users (MAU)
- [ ] User retention rates
- [ ] Feature usage stats
- [ ] Monitor crash reports
- [ ] Fix crashes immediately
- [ ] Prioritize by number of users affected
- [ ] Monitor app store reviews
- [ ] Respond to reviews (both positive and negative)
- [ ] Address common complaints
- [ ] Track conversion metrics
- [ ] Free to premium conversion rate
- [ ] Target: 2-5%
- [ ] Revenue per user
- [ ] Subscription retention
- [ ] Monitor API costs
- [ ] Mapbox usage
- [ ] Firebase usage
- [ ] Ensure costs are within budget
- [ ] Collect user feedback
- [ ] In-app feedback form
- [ ] Email surveys
- [ ] User interviews (for engaged users)
- [ ] Identify top user requests
- [ ] Create feature roadmap for v1.1
- [ ] Prioritize features by impact/effort
- [ ] Fix bugs reported by users
- [ ] Plan next update (v1.0.1 - bug fixes)
- [ ] Plan next feature release (v1.1.0)
- [ ] Implement highest-priority features
- [ ] Improve app based on data
- [ ] Optimize onboarding if drop-off is high
- [ ] Improve paywall if conversion is low
- [ ] Continue marketing efforts
- [ ] Content marketing (blog posts)
- [ ] Community engagement (respond to comments)
- [ ] Consider paid acquisition (ads) if ROI positive
- [ ] Celebrate wins!
- [ ] Reached 1,000 users
- [ ] First 100 premium subscribers
- [ ] Featured by Apple or Google (if it happens)

**Acceptance Criteria:**
- App is stable and performing well
- User feedback being actively collected
- Bugs being fixed promptly
- Roadmap for future versions established
- Marketing and user acquisition ongoing

---

## Summary

### Sprint Sequence & Dependencies

```
Sprint 0: Project Setup
  ↓
Sprint 1: Firebase Setup & Auth UI → Sprint 2: Auth Logic
  ↓                                      ↓
Sprint 3: Hive Setup ←──────────────────┘
  ↓
Sprint 4: GPS Tracking Core → Sprint 5: Run Tracking UI
  ↓                             ↓
Sprint 6: Run Summary & History
  ↓
Sprint 7: Mapbox Integration → Sprint 8: Route Visualization
  ↓                              ↓
Sprint 9: Goal Creation Part 1 → Sprint 10: Goal Creation Part 2
  ↓                                ↓
Sprint 11: Journey Visualization ← Sprint 8
  ↓
Sprint 12: Goal Progress Logic
  ↓
Sprint 13: Firebase Sync ← Sprint 2, 3, 6, 10
  ↓
Sprint 14: Profile & Settings
  ↓
Sprint 15: Premium & Paywall
  ↓
Sprint 16: Ad Integration
  ↓
Sprint 17: Onboarding
  ↓
Sprint 18: Polish & Testing
  ↓
Sprint 19: App Store Assets
  ↓
Sprint 20: iOS Submission → Sprint 21: Android Submission
  ↓                           ↓
Sprint 22: Beta Testing ←────┘
  ↓
Sprint 23: Launch Preparation
  ↓
Sprint 24: Post-Launch Monitoring
```

### Total Timeline Estimate

- **Development Sprints (0-18):** ~10-12 weeks
- **Store Submission & Beta (19-22):** ~2-3 weeks
- **Launch & Post-Launch (23-24):** Ongoing

**Total to Launch:** ~12-15 weeks (3-4 months)

---

## Sprint Tracking

Use this document as your implementation tracker. Check off tasks as you complete them. Each sprint should be completed before moving to the next dependent sprint.

**Status Key:**
- [ ] Not started
- [x] Completed
- [~] In progress
- [!] Blocked

---

**Document Version:** 1.0
**Last Updated:** December 28, 2025
**Author:** Development Team
**Status:** Ready for Implementation

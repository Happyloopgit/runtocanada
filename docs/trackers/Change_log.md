# Change Log

This document tracks all changes made to the Run to Canada project, organized by session, sprint, and type.

## Changes by Session

| Session | Date | Sprint | Files Changed | Type | Description | Reference |
|---------|------|--------|---------------|------|-------------|-----------|
| 001 | 2025-12-28 | Sprint 0 | docs/* | Documentation | Created comprehensive documentation | [Session 001](Session_log.md#session-001---2025-12-28) |
| 001 | 2025-12-28 | Sprint 0 | docs/trackers/* | Setup | Created tracker system | [Session 001](Session_log.md#session-001---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | app/* | Setup | Flutter project created with modular architecture | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | app/pubspec.yaml | Configuration | Added all project dependencies | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | app/lib/app/* | Configuration | Environment config for build flavors | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | app/lib/core/* | Setup | Core utilities and constants | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | README.md, .gitignore | Setup | Root project files | [Session 002](Session_log.md#session-002---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Firebase config | Configuration | Firebase project setup for iOS/Android | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | app/lib/core/theme/* | Setup | App theme with colors, text styles, Material 3 theme | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | app/lib/core/widgets/* | Setup | Reusable UI components (buttons, fields, loaders, errors) | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | app/lib/features/auth/* | Feature | Authentication screens (Login, Signup, Forgot Password) | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | app/lib/main.dart | Setup | Firebase initialization, routing, theme setup | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | app/assets/images/* | Setup | App logo added | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Android build config | Bug Fix | Fixed Kotlin compatibility and MainActivity package issues | [Session 003](Session_log.md#session-003---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/features/auth/domain/models/* | Feature | User and UserSettings models with Firestore integration | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/features/auth/data/services/* | Feature | AuthService with email/password and Google Sign-In | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/features/auth/presentation/providers/* | Feature | Riverpod auth providers and state management | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/features/auth/presentation/screens/* | Feature | Connected auth screens to Firebase with Google Sign-In | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/features/home/presentation/screens/* | Feature | Created placeholder HomeScreen | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/firestore.rules, app/firestore.indexes.json | Configuration | Firestore security rules and indexes | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/core/widgets/* | Enhancement | Added enabled and onSubmitted to text fields | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/lib/core/theme/app_colors.dart | Enhancement | Added border color constant | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Sprint 2 | app/pubspec.yaml | Configuration | Added google_sign_in and font_awesome_flutter packages | [Session 004](Session_log.md#session-004---2025-12-28) |

---

## Changes by Sprint

### Sprint 0 - Project Setup & Environment Configuration

| Session | Date | Component | Files Changed | Type | Description | Reference |
|---------|------|-----------|---------------|------|-------------|-----------|
| 001 | 2025-12-28 | Documentation | 5 docs | Documentation | Product concept, architecture, sprint plan, wireframes | [Session 001](Session_log.md#session-001---2025-12-28) |
| 001 | 2025-12-28 | Trackers | 4 trackers | Setup | Session log, change log, bug tracker, backlog | [Session 001](Session_log.md#session-001---2025-12-28) |
| 002 | 2025-12-28 | Flutter Project | 149 files | Setup | Created Flutter project with feature-based architecture | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Dependencies | pubspec.yaml | Configuration | Added Riverpod, Hive, Firebase, Mapbox, etc. | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Core Utilities | 5 files | Setup | Environment config, constants, utils | [Session 002](Session_log.md#session-002---2025-12-28) |

### Sprint 1 - Firebase Setup & Authentication UI

| Session | Date | Component | Files Changed | Type | Description | Reference |
|---------|------|-----------|---------------|------|-------------|-----------|
| 003 | 2025-12-28 | Firebase | 4 files | Configuration | Firebase project created, iOS/Android config files added | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Theme System | 3 files | Setup | AppColors, AppTextStyles, AppTheme with Material 3 | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | UI Components | 4 files | Setup | Reusable buttons, text fields, loaders, error messages | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Auth Screens | 3 files | Feature | Login, Signup, Forgot Password screens | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Navigation | 2 files | Setup | AppRouter and route constants | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Main App | 2 files | Setup | Firebase init in main.dart, firebase_options.dart | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Assets | 1 file | Setup | App logo (1024x1024) | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Build Config | 4 files | Bug Fix | Fixed Kotlin version (2.2.20→1.9.24), MainActivity package, JVM settings | [Session 003](Session_log.md#session-003---2025-12-28) |

### Sprint 2 - Firebase Authentication Logic

| Session | Date | Component | Files Changed | Type | Description | Reference |
|---------|------|-----------|---------------|------|-------------|-----------|
| 004 | 2025-12-28 | Data Models | 1 file | Feature | User and UserSettings models with Firestore serialization | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Auth Service | 1 file | Feature | Complete authentication service with email/password and Google Sign-In | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | State Management | 1 file | Feature | Riverpod providers for auth state, user profile, and controller | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Auth Screens | 3 files | Feature | Connected login, signup, forgot password to Firebase | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Home Screen | 1 file | Feature | Placeholder home screen with logout functionality | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Firestore | 2 files | Configuration | Security rules and database indexes | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | UI Components | 1 file | Enhancement | Enhanced text fields with enabled and onSubmitted | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Theme | 1 file | Enhancement | Added border color constant | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Navigation | 1 file | Enhancement | Added home route | [Session 004](Session_log.md#session-004---2025-12-28) |
| 004 | 2025-12-28 | Dependencies | 1 file | Configuration | Added google_sign_in and font_awesome_flutter | [Session 004](Session_log.md#session-004---2025-12-28) |

---

## Changes by Type

### Documentation

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| 001 | 2025-12-28 | Sprint 0 | Created comprehensive project documentation | 5 markdown files | [Session 001](Session_log.md#session-001---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | Updated session log and sprint plan | 2 markdown files | [Session 002](Session_log.md#session-002---2025-12-28) |

### Setup

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| 001 | 2025-12-28 | Sprint 0 | Created tracking system | 4 tracker files | [Session 001](Session_log.md#session-001---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | Flutter project with modular architecture | 149 files | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | Core utilities and constants | 5 files | [Session 002](Session_log.md#session-002---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | App theme system (colors, text styles, Material 3 theme) | 3 files | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Reusable UI components (buttons, text fields, loaders) | 4 files | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Navigation router and app initialization | 3 files | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | App logo asset | 1 file | [Session 003](Session_log.md#session-003---2025-12-28) |

### Configuration

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| 002 | 2025-12-28 | Sprint 0 | Added all project dependencies | pubspec.yaml | [Session 002](Session_log.md#session-002---2025-12-28) |
| 002 | 2025-12-28 | Sprint 0 | Environment config for dev/staging/production | env.dart | [Session 002](Session_log.md#session-002---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Firebase project setup for iOS/Android | 4 files | [Session 003](Session_log.md#session-003---2025-12-28) |

### Feature

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| 003 | 2025-12-28 | Sprint 1 | Authentication screens (Login, Signup, Forgot Password) | 3 files | [Session 003](Session_log.md#session-003---2025-12-28) |

### Bug Fix

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| 003 | 2025-12-28 | Sprint 1 | Fixed Kotlin 2.2.20 incompatibility, downgraded to 1.9.24 | 4 files | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Fixed MainActivity package mismatch (run_to_canada → app) | 1 file | [Session 003](Session_log.md#session-003---2025-12-28) |
| 003 | 2025-12-28 | Sprint 1 | Fixed Kotlin language version and JVM target settings | 3 files | [Session 003](Session_log.md#session-003---2025-12-28) |

### Refactor

| Session | Date | Sprint | Description | Files | Reference |
|---------|------|--------|-------------|-------|-----------|
| - | - | - | No refactoring done yet | - | - |

---

## Detailed Changes

### Session 001 - Documentation & Setup

**Date:** 2025-12-28
**Sprint:** Sprint 0

#### Documentation Created (5 files)

1. **docs/README.md**
   - Documentation index and navigation
   - Quick start guide for different roles
   - Project overview and tech stack summary
   - Resources and links

2. **docs/01-product-concept.md**
   - Executive summary and product vision
   - Target audience and user personas
   - Core features (Free vs Premium)
   - Pricing strategy ($2.99/mo or $19.99/year)
   - Competitive analysis
   - Go-to-market strategy
   - Revenue projections

3. **docs/02-technical-architecture.md**
   - System architecture overview
   - Complete tech stack (Flutter, Firebase, Mapbox, Hive)
   - Data models and schemas
   - API integration details
   - Data flow and synchronization
   - Security and performance optimization
   - Deployment strategy

4. **docs/03-sprint-plan.md**
   - 24 sequential sprints
   - Sprint 0 - Sprint 24 (Setup to Post-Launch)
   - Checkable tasks for each sprint
   - Dependencies mapped
   - 12-15 week timeline to launch

5. **docs/04-wireframes-and-flows.md**
   - ASCII wireframes for all screens
   - User flow diagrams
   - Component library
   - Color palette and typography

#### Trackers Created (4 files)

1. **docs/trackers/Session_log.md**
   - Session tracking template
   - Session 001 entry
   - Guidelines for session logging

2. **docs/trackers/Change_log.md** (this file)
   - Change tracking by session
   - Change tracking by sprint
   - Change tracking by type

3. **docs/trackers/Bug_tracker.md**
   - Bug status summary
   - Bug tracking by priority
   - Bug tracking by sprint
   - Bug templates

4. **docs/trackers/Backlog_tracker.md**
   - Technical debt tracking
   - Future enhancements
   - Nice-to-have features
   - Priority and effort estimates

---

## Change Type Definitions

### Documentation
- Creation or updates to markdown documentation
- README files
- Architecture documents
- User guides

### Setup
- Initial project setup
- Environment configuration
- Tool installation
- Tracker initialization

### Configuration
- Config file changes (pubspec.yaml, AndroidManifest.xml, Info.plist)
- Build configuration
- Environment variables
- Firebase configuration

### Feature
- New feature implementation
- UI screens
- Business logic
- Data models
- API integrations

### Bug Fix
- Fixes to existing bugs
- Corrections to incorrect behavior
- Error handling improvements

### Refactor
- Code restructuring without changing functionality
- Performance improvements
- Code cleanup
- Architectural changes

### Test
- Unit tests
- Widget tests
- Integration tests
- Test infrastructure

---

## Guidelines for Tracking Changes

### When to Add an Entry

Add a change log entry when:
- Completing a sprint task
- Implementing a feature
- Fixing a bug
- Refactoring code
- Updating documentation
- Modifying configuration

### How to Document Changes

1. **Be Specific:** Clearly state what changed and why
2. **Reference Session:** Link to the session log entry with full details
3. **Categorize Correctly:** Use the appropriate change type
4. **Count Files:** Provide accurate file count for scope understanding
5. **Brief Description:** Keep it concise; details go in session log

### Change Entry Format

```markdown
| Session | Date | Sprint | Files Changed | Type | Description | Reference |
|---------|------|--------|---------------|------|-------------|-----------|
| XXX | YYYY-MM-DD | Sprint X | N files | Type | Brief description | [Session XXX](Session_log.md#session-xxx) |
```

---

### Session 002 - Flutter Project Setup

**Date:** 2025-12-28
**Sprint:** Sprint 0

#### Flutter Project Created (149 files)

**Project Structure:**
- Created `app/` directory for Flutter application
- Created `docs/` directory for documentation (existing)
- Root-level README.md and .gitignore

**Modular Architecture (lib/ structure):**
- `app/` - Application-level configuration
  - `env.dart` - Environment management (dev/staging/production)
- `core/` - Shared utilities
  - `constants/` - App constants and route constants
  - `utils/` - Distance and date utilities
  - `extensions/` - Extension methods (empty, ready for future)
  - `errors/` - Error handling (empty, ready for future)
- `features/` - Feature modules (clean architecture)
  - `auth/` - Authentication feature
  - `tracking/` - Run tracking feature
  - `journey/` - Journey/Goal feature
  - `history/` - Run history feature
  - `profile/` - User profile feature
  - Each feature has: `data/`, `domain/`, `presentation/` layers

**Dependencies Added:**
1. **State Management:** flutter_riverpod, riverpod_annotation
2. **Local Database:** hive, hive_flutter
3. **Firebase:** firebase_core, firebase_auth, cloud_firestore, firebase_analytics, firebase_storage, firebase_crashlytics
4. **Maps & Location:** mapbox_gl, geolocator, permission_handler, flutter_polyline_points, latlong2
5. **HTTP & API:** dio, retrofit, json_annotation
6. **UI Components:** cached_network_image, lottie, flutter_svg, shimmer
7. **Utilities:** intl, uuid, connectivity_plus, package_info_plus, shared_preferences
8. **Monitoring:** sentry_flutter
9. **Dev Dependencies:** build_runner, hive_generator, riverpod_generator, json_serializable, retrofit_generator

**Core Utilities Created:**

1. **app/lib/app/env.dart**
   - Environment enum (dev, staging, production)
   - Environment detection from dart-define
   - API base URL configuration
   - API key management (Mapbox, Unsplash, Sentry)

2. **app/lib/core/constants/app_constants.dart**
   - App information
   - Free tier limits (100km)
   - GPS tracking settings
   - Milestone intervals
   - Cache durations
   - Unit conversion factors
   - Premium pricing

3. **app/lib/core/constants/route_constants.dart**
   - Navigation route names for all screens

4. **app/lib/core/utils/distance_utils.dart**
   - Haversine distance calculation
   - Distance formatting (metric/imperial)
   - Pace calculation (min/km or min/mile)
   - Speed calculation
   - Calorie estimation

5. **app/lib/core/utils/date_utils.dart**
   - Date/time formatting
   - Duration formatting (HH:MM:SS)
   - Human-readable durations
   - Time ago strings ("2 hours ago")
   - Date helpers (isToday, isYesterday)

**Quality Checks:**
- `flutter analyze` - All checks passed
- Fixed linting warnings in date_utils.dart
- All dependencies installed successfully

**Git:**
- Initial commit created
- Pushed to GitHub (https://github.com/Happyloopgit/runtocanada.git)

---

### Session 003 - Firebase & Authentication UI

**Date:** 2025-12-28
**Sprint:** Sprint 1

#### Firebase Configuration (4 files)

1. **app/ios/Runner/GoogleService-Info.plist**
   - iOS Firebase configuration
   - Project ID: runtocanada
   - Bundle ID: com.runtocanada.app

2. **app/android/app/google-services.json**
   - Android Firebase configuration
   - Package: com.runtocanada.app

3. **app/android/build.gradle.kts**
   - Added Google Services buildscript plugin

4. **app/android/app/build.gradle.kts**
   - Applied Google Services plugin
   - Set minSdk to 21
   - Added multidex support

#### Theme System Created (3 files)

1. **app/lib/core/theme/app_colors.dart**
   - Canadian red primary color
   - Nature-inspired green secondary
   - Complete color palette including status, map, chart, and premium colors

2. **app/lib/core/theme/app_text_styles.dart**
   - Display, headline, title, body, label styles
   - Special stats display styles
   - Button, link, error text styles

3. **app/lib/core/theme/app_theme.dart**
   - Material 3 light theme
   - Dark theme (basic setup)
   - Complete component themes (buttons, cards, inputs, etc.)

#### UI Components Created (4 files)

1. **app/lib/core/widgets/custom_button.dart**
   - CustomButton, CustomTextButton, CustomIconButton
   - Loading state support
   - Outlined variant support

2. **app/lib/core/widgets/custom_text_field.dart**
   - CustomTextField with validation
   - EmailTextField with email validation
   - PasswordTextField with strength validation
   - Show/hide password toggle

3. **app/lib/core/widgets/loading_indicator.dart**
   - LoadingIndicator, LoadingOverlay, InlineLoader
   - Customizable size and color

4. **app/lib/core/widgets/error_message.dart**
   - ErrorMessage, InlineError
   - SuccessMessage
   - Retry functionality

#### Authentication Screens (3 files)

1. **app/lib/features/auth/presentation/screens/login_screen.dart**
   - Email and password fields
   - Navigation to signup and forgot password
   - App logo display
   - Form validation

2. **app/lib/features/auth/presentation/screens/signup_screen.dart**
   - Full name, email, password, confirm password
   - Terms and conditions checkbox
   - Password strength validation
   - Match validation for confirm password

3. **app/lib/features/auth/presentation/screens/forgot_password_screen.dart**
   - Email field for password reset
   - Success message display
   - Resend functionality

#### Navigation & App Setup (3 files)

1. **app/lib/core/navigation/app_router.dart**
   - Route generation
   - Navigation helper methods
   - Route configuration for auth screens

2. **app/lib/firebase_options.dart**
   - Platform-specific Firebase options
   - iOS and Android configurations

3. **app/lib/main.dart**
   - Firebase initialization
   - Riverpod ProviderScope
   - Theme configuration
   - Navigation setup
   - System UI configuration

#### Assets (1 file)

1. **app/assets/images/logo.png**
   - 1024x1024 Run to Canada logo
   - Purple text with runner silhouette

**Quality Checks:**
- `flutter pub get` - All dependencies installed
- `flutter analyze` - All checks passed (0 issues)
- Fixed type errors (CardTheme → CardThemeData, DialogTheme → DialogThemeData)
- Fixed deprecation warnings (withOpacity → withValues)

**Build Configuration Fixes:**
- Fixed Kotlin version incompatibility:
  - Downgraded from 2.2.20 to 1.9.24 in settings.gradle.kts
  - Added kotlin.jvmToolchain.version=17 to gradle.properties
  - Updated kotlinOptions to use JVM target 17
- Fixed MainActivity package issue:
  - Moved from com.runtocanada.run_to_canada to com.runtocanada.app
  - Created correct package directory structure
- `flutter build apk --debug` - Build successful
- App runs successfully on Android device

**Sprint 1 Status:**
- ✓ Firebase project created and configured
- ✓ App theme system complete
- ✓ Reusable UI components created
- ✓ Authentication screens implemented (UI only)
- ✓ Navigation structure set up
- ✓ Firebase initialized in app
- ✓ Android build configuration fixed
- ✓ App builds and runs on Android device
- Next: Sprint 2 - Implement authentication logic

---

**Last Updated:** 2025-12-28
**Total Changes:** 16
**Last Session:** 003

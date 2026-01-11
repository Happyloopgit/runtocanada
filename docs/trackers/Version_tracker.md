# Version Tracker

This document tracks all versions and releases of Run to Canada.

---

## Current Version

**Version:** 1.0.0
**Build:** 1
**Release Date:** 2026-01-11 (Beta)
**Status:** Beta Testing

---

## Version History

### Version 1.0.0 (Build 1) - January 11, 2026

**Release Type:** Beta Release
**Git Tag:** `v1.0.0-build.1` (pending)
**Sprint:** Sprint 20-21

#### What's New
- 🎉 **Initial Release** - First public beta of Run to Canada
- 🏃 **GPS Run Tracking** - Track your runs with real-time distance, pace, and duration
- 🗺️ **Virtual Journey** - Transform your runs into journeys to anywhere in the world
- 🎯 **Goal System** - Create goals with automatic route and milestone generation
- 📍 **Milestone Celebrations** - Unlock cities along your route with photos and facts
- 💎 **Premium Features** - Freemium model with 100km free journey distance
- 📱 **Cross-Device Sync** - Firebase cloud backup for all your data
- 🌙 **Modern Dark UI** - Beautiful Lexend typography and glassmorphic cards
- 📚 **Onboarding** - 4-screen guided introduction to the app

#### Core Features
- **Authentication**
  - Email/Password sign up and login
  - Google Sign-In integration
  - Password reset functionality
  - Secure Firebase authentication

- **Run Tracking**
  - GPS-based location tracking
  - Real-time distance, pace, speed, duration
  - Pause/resume/stop controls
  - Route visualization on map
  - Run history with detailed statistics
  - Run notes and summary

- **Goal & Journey System**
  - Search any location worldwide
  - Automatic route calculation (Mapbox Directions)
  - Intelligent milestone generation
  - Milestone enrichment (photos from Unsplash, facts from Wikipedia)
  - Journey map with progress visualization
  - Completed vs remaining route segments

- **Premium & Monetization**
  - Free tier: 100km journey distance limit
  - Premium: Unlimited journey distance
  - Pricing: $2.99/month or $19.99/year
  - RevenueCat integration (configured, not yet tested)
  - AdMob banner and interstitial ads (test IDs)

- **Data & Sync**
  - Local storage with Hive
  - Firebase Firestore cloud sync
  - Offline-first architecture
  - Automatic sync queue

- **Design System**
  - Lexend font family throughout
  - Bright blue primary color (#0D7FF2)
  - Dark theme optimized
  - 5 card component variants
  - 5 button component types
  - Custom page transitions
  - Shimmer loading states

#### Platforms
- **iOS:** 14.0+ (TestFlight)
- **Android:** Android 5.0+ / API 21+ (Play Console setup in progress)

#### Known Limitations
- AdMob using test ad IDs (production IDs in Sprint 22)
- RevenueCat not yet tested on stores
- Health data integration not included (Sprint 17.5 - future)
- No social features (future enhancement)

#### Dependencies
- Flutter 3.10.3+
- Firebase (Auth, Firestore)
- Mapbox (Maps, Geocoding, Directions)
- Google Sign-In
- RevenueCat
- AdMob

#### File Sizes
- iOS IPA: 75.4 MB
- Android AAB: TBD

#### Distribution
- **iOS:** TestFlight (Internal + External testing)
- **Android:** Google Play Closed Testing (pending)

---

## Version Numbering

**Format:** `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR:** Breaking changes, major features (e.g., 1.0.0 → 2.0.0)
- **MINOR:** New features, non-breaking changes (e.g., 1.0.0 → 1.1.0)
- **PATCH:** Bug fixes, minor improvements (e.g., 1.0.0 → 1.0.1)
- **BUILD:** Incremental build number (e.g., +1, +2, +3)

### Examples
- `1.0.0+1` - First production build
- `1.0.1+2` - Bug fix release (second build)
- `1.1.0+3` - Feature update (third build)
- `2.0.0+1` - Major version (first build of v2)

---

## Release Channels

### Beta (Current)
- **Purpose:** Testing with limited audience
- **Distribution:** TestFlight (iOS), Closed Testing (Android)
- **Audience:** Internal team + beta testers
- **Frequency:** As needed for testing
- **Version:** 1.0.0+1

### Production (Planned)
- **Purpose:** Public release
- **Distribution:** App Store (iOS), Google Play (Android)
- **Audience:** All users
- **Frequency:** Based on sprint completion
- **Next Version:** TBD after Sprint 22

---

## Planned Versions

### Version 1.0.1 (Patch) - TBD
**Target:** After Sprint 22 (Beta Testing)
**Focus:** Bug fixes from beta feedback

**Expected Changes:**
- Critical bug fixes identified during testing
- Performance improvements
- UI polish based on feedback
- AdMob production ad IDs
- RevenueCat testing completed

### Version 1.1.0 (Minor) - TBD
**Target:** Post-Launch (Sprint 24+)
**Focus:** Feature enhancements

**Potential Features:**
- Health data integration (Apple Health, Health Connect)
- Social features (friends, leaderboards)
- Achievement system expansion
- Additional map styles
- Route sharing
- Run challenges

### Version 2.0.0 (Major) - TBD
**Target:** 6-12 months post-launch
**Focus:** Major feature additions

**Potential Features:**
- Team/group goals
- Real-world race events integration
- Advanced analytics and insights
- Coaching features
- Wearable device direct integration

---

## Version Release Checklist

Before releasing a new version:

- [ ] All sprint tasks completed
- [ ] All critical bugs fixed
- [ ] Code reviewed and analyzed (0 issues)
- [ ] Testing completed on iOS and Android
- [ ] Version number updated in `pubspec.yaml`
- [ ] CHANGELOG.md updated with changes
- [ ] Build_tracker.md updated
- [ ] Version_tracker.md updated (this file)
- [ ] Git commit with version message
- [ ] Git tag created: `vX.Y.Z-build.N`
- [ ] Builds created for both platforms
- [ ] Builds uploaded to distribution channels
- [ ] Release notes written for stores
- [ ] TestFlight/Play Console release notes updated

---

## Changelog Summary

### 1.0.0 (2026-01-11)
- Initial beta release
- Core features: Run tracking, Goal system, Journey visualization
- Premium freemium model
- Modern dark UI with design system
- See full details in CHANGELOG.md (to be created)

---

## Version Statistics

| Version | Release Date | Days Since Last | Builds | Status |
|---------|-------------|-----------------|--------|--------|
| 1.0.0 | 2026-01-11 | - | 1 | Beta Testing |

---

## Support

**Supported Versions:**
- 1.0.x - Current (Full support)

**End of Life:**
- None yet (first release)

---

**Last Updated:** 2026-01-11
**Maintained By:** Development Team
**Next Review:** After Sprint 22 (Beta Testing complete)

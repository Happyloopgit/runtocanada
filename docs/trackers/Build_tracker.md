# Build Tracker

This document tracks all production builds of Run to Canada for iOS and Android.

---

## Current Production Builds

| Platform | Version | Build # | Date | Size | Distribution | Status | Notes |
|----------|---------|---------|------|------|--------------|--------|-------|
| iOS | 1.0.0 | 1 | 2026-01-11 | 75.4 MB | TestFlight | ✅ Uploaded | First production build - Internal & External testing |
| Android | 1.0.0 | 1 | 2026-01-11 | TBD | Not Uploaded | 🔄 Built | AAB built, pending Play Console setup |

---

## Build History

### Build 1.0.0+1 - January 11, 2026

**Version:** 1.0.0 (Build 1)
**Date:** 2026-01-11
**Git Tag:** `v1.0.0-build.1` (pending)
**Sprint:** Sprint 20 (iOS), Sprint 21 (Android)

#### iOS Build
- **Bundle ID:** `com.run2canada.app`
- **Development Team:** 54GVRK4V8H (Karthik Sunny Buddula)
- **IPA Size:** 75.4 MB
- **Build Command:** `flutter build ipa`
- **Distribution:** TestFlight
- **Status:** ✅ Uploaded to App Store Connect
- **TestFlight Groups:**
  - Internal: HL_internal (ready immediately)
  - External: HL_external (waiting for Apple review - 24-48 hours)
- **Export Compliance:** Declared "No encryption" (standard HTTPS only)

#### Android Build
- **Package Name:** `com.runtocanada.app`
- **AAB Size:** TBD
- **Build Command:** `flutter build appbundle`
- **Distribution:** Google Play Console
- **Status:** 🔄 Built, pending upload
- **Testing Track:** Closed Testing (planned)

#### Features in This Build
- Complete authentication system (Google Sign-In, Email/Password)
- GPS-based run tracking with live metrics
- Goal creation with route visualization
- Journey map showing progress toward destination
- Milestone system with celebration screens
- Premium paywall ($2.99/month, $19.99/year)
- AdMob integration for free users
- Firebase sync for cross-device support
- Modern dark UI with Lexend typography
- Onboarding flow (4 screens)

#### Known Issues
- None critical - app is stable for beta testing

#### Build Notes
- First production build for beta testing
- RevenueCat configured (not yet tested in stores)
- AdMob using test IDs (will switch to production in Sprint 22)
- Privacy policy: https://runtocanada.happyloop.pro/privacy
- Terms of service: https://runtocanada.happyloop.pro/terms

---

## Build Conventions

### Version Format
- **Version Name:** `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- **Build Number:** Incremental integer (e.g., 1, 2, 3)
- **Full Version:** `1.0.0+1` (in pubspec.yaml)

### Git Tags
- **Format:** `vMAJOR.MINOR.PATCH-build.BUILD_NUMBER`
- **Example:** `v1.0.0-build.1`
- **Command:** `git tag -a v1.0.0-build.1 -m "Build 1.0.0+1 - First production build"`

### Distribution Channels

**iOS:**
- **TestFlight Internal:** No review, immediate availability
- **TestFlight External:** Apple review required (24-48 hours)
- **App Store:** Full review process (1-3 days)

**Android:**
- **Internal Testing:** No review, immediate availability
- **Closed Testing:** No review, immediate availability
- **Open Testing:** Optional public beta
- **Production:** Google review required (1-7 days)

---

## Build Checklist

Before creating a production build:

- [ ] Update version in `pubspec.yaml`
- [ ] Run `flutter analyze` (0 issues)
- [ ] Run tests (if available)
- [ ] Update CHANGELOG.md
- [ ] Verify all API keys are production-ready
- [ ] Test on physical devices (iOS and Android)
- [ ] Commit all changes
- [ ] Build iOS: `cd app && flutter build ipa`
- [ ] Build Android: `cd app && flutter build appbundle`
- [ ] Upload iOS to App Store Connect
- [ ] Upload Android to Play Console
- [ ] Create git tag: `git tag -a vX.Y.Z-build.N -m "Description"`
- [ ] Push tag: `git push origin vX.Y.Z-build.N`
- [ ] Update this tracker with build details
- [ ] Update Version_tracker.md

---

## Next Build

**Target Version:** 1.0.1 or 1.1.0 (TBD based on feedback)
**Planned Date:** After Sprint 22 (Beta Testing)
**Expected Changes:** Bug fixes from beta testing feedback

---

**Last Updated:** 2026-01-11
**Maintained By:** Development Team

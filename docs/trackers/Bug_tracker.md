# Bug Tracker

This document tracks all bugs discovered and their resolution status.

## Bug Status Summary

| Status | Count |
|--------|-------|
| Open | 1 |
| In Progress | 0 |
| Fixed | 0 |
| Closed | 0 |
| **Total** | **1** |

---

## Open Bugs

| Bug ID | Priority | Sprint | Component | Description | Discovered | Assigned | Reference |
|--------|----------|--------|-----------|-------------|------------|----------|-----------|
| BUG-001 | Medium | Sprint 9 | iOS/CocoaPods | CocoaPods dependency conflicts preventing iOS build: GoogleUtilities version mismatch (Firebase needs ~7.8, GoogleSignIn needs ~8.0), AppAuth version conflict, nanopb version conflict | 2025-12-31 Session 011 | Unassigned | [Session 011](Session_log.md#session-011---2025-12-31) |

---

## In Progress Bugs

| Bug ID | Priority | Sprint | Component | Description | Assigned Session | Started | Reference |
|--------|----------|--------|-----------|-------------|------------------|---------|-----------|
| - | - | - | - | No bugs in progress | - | - | - |

---

## Fixed Bugs (Pending Verification)

| Bug ID | Priority | Sprint | Component | Description | Fixed In Session | Fixed Date | Reference |
|--------|----------|--------|-----------|-------------|------------------|------------|-----------|
| - | - | - | - | No bugs awaiting verification | - | - | - |

---

## Closed Bugs

| Bug ID | Priority | Sprint | Component | Description | Fixed In Session | Verified Date | Reference |
|--------|----------|--------|-----------|-------------|------------------|---------------|-----------|
| - | - | - | - | No bugs closed yet | - | - | - |

---

## Bugs by Priority

### Critical

Critical bugs that cause system crashes, data loss, or security vulnerabilities.

| Bug ID | Status | Sprint | Component | Description | Reference |
|--------|--------|--------|-----------|-------------|-----------|
| - | - | - | - | No critical bugs | - |

### High

High-priority bugs that significantly impact core functionality or user experience.

| Bug ID | Status | Sprint | Component | Description | Reference |
|--------|--------|--------|-----------|-------------|-----------|
| - | - | - | - | No high priority bugs | - |

### Medium

Medium-priority bugs that affect features but have workarounds available.

| Bug ID | Status | Sprint | Component | Description | Reference |
|--------|--------|--------|-----------|-------------|-----------|
| - | - | - | - | No medium priority bugs | - |

### Low

Low-priority bugs that are cosmetic or affect edge cases.

| Bug ID | Status | Sprint | Component | Description | Reference |
|--------|--------|--------|-----------|-------------|-----------|
| - | - | - | - | No low priority bugs | - |

---

## Bugs by Sprint

### Sprint 0 - Project Setup

| Bug ID | Priority | Status | Component | Description | Reference |
|--------|----------|--------|-----------|-------------|-----------|
| - | - | - | - | No bugs in Sprint 0 | - |

### Sprint 1 - Firebase Setup & Authentication UI

| Bug ID | Priority | Status | Component | Description | Reference |
|--------|----------|--------|-----------|-------------|-----------|
| - | - | - | - | Sprint not started yet | - |

---

## Bugs by Component

### Authentication

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No auth bugs | - |

### GPS Tracking

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No GPS bugs | - |

### Maps & Visualization

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No map bugs | - |

### Goals & Journey

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No goal bugs | - |

### Data Sync

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No sync bugs | - |

### UI/UX

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No UI bugs | - |

### Performance

| Bug ID | Priority | Status | Sprint | Description | Reference |
|--------|----------|--------|--------|-------------|-----------|
| - | - | - | - | No performance bugs | - |

---

## Bug Workflow

### Bug Lifecycle

```
Discovered → Open → In Progress → Fixed → Verified → Closed
                ↓
             Reopened (if verification fails)
```

### Status Definitions

- **Open:** Bug has been discovered and logged, awaiting assignment
- **In Progress:** Bug is being actively worked on
- **Fixed:** Fix has been implemented but not yet verified
- **Closed:** Fix has been verified and bug is resolved
- **Reopened:** Fixed bug that failed verification

---

## Bug Priority Definitions

### Critical
- **Impact:** System down, data loss, security vulnerability, app crashes on launch
- **Examples:**
  - App crashes immediately on startup
  - User data is lost or corrupted
  - Security breach or data leak
  - Payment processing failures
- **Response Time:** Immediate (drop everything)

### High
- **Impact:** Major feature broken, significant impact on user experience
- **Examples:**
  - GPS tracking not working
  - Unable to create goals
  - Run data not saving
  - Authentication failures
  - Map not loading
- **Response Time:** Within 1 day

### Medium
- **Impact:** Feature partially broken, workaround available
- **Examples:**
  - UI glitches that don't block functionality
  - Sync delays or occasional failures
  - Non-critical validation errors
  - Minor calculation inaccuracies
- **Response Time:** Within 3-5 days

### Low
- **Impact:** Minor issue, cosmetic, edge case
- **Examples:**
  - Typos in UI text
  - Minor visual inconsistencies
  - Edge cases with unusual inputs
  - Non-blocking performance issues
- **Response Time:** Next sprint or backlog

---

## Bug Template

When adding a new bug, use the following format:

### Bug ID Format
**BUG-XXX** (e.g., BUG-001, BUG-002)

### Required Information

**Title:** Clear, concise description of the bug

**Bug ID:** BUG-XXX

**Priority:** Critical / High / Medium / Low

**Status:** Open / In Progress / Fixed / Closed

**Sprint:** Sprint where bug was discovered

**Component:** Which part of the app (Auth, GPS, Maps, etc.)

**Description:**
- **What happened:** Describe the actual behavior
- **Expected behavior:** What should have happened
- **Steps to reproduce:**
  1. Step 1
  2. Step 2
  3. Step 3
- **Environment:**
  - Platform: iOS / Android
  - OS Version: e.g., iOS 17.1, Android 14
  - Device: e.g., iPhone 14, Pixel 7
  - App Version: e.g., 1.0.0 (build 1)
- **Screenshots/Logs:** Attach if available

**Discovered:** Date discovered (YYYY-MM-DD)

**Assigned:** Who is working on it

**Reference:** Link to session log with full details

### Example Bug Entry

**BUG-001: GPS tracking stops after 5 minutes**

- **Priority:** High
- **Status:** Open
- **Sprint:** Sprint 4
- **Component:** GPS Tracking
- **Description:**
  - **What happened:** GPS tracking stops automatically after ~5 minutes of running
  - **Expected:** GPS should track continuously until user stops the run
  - **Steps to reproduce:**
    1. Start a run
    2. Wait 5 minutes
    3. Notice tracking has stopped
  - **Environment:**
    - Platform: iOS
    - OS: iOS 17.1
    - Device: iPhone 12
    - App Version: 1.0.0-beta
- **Discovered:** 2025-12-28
- **Assigned:** -
- **Reference:** [Session XXX](Session_log.md#session-xxx)

---

## Bug Reporting Guidelines

### For Developers

When you encounter a bug during development:
1. Check if it's already logged in this tracker
2. If new, create an entry using the template above
3. Assign priority based on impact
4. Add detailed reproduction steps
5. Link to session log for context
6. Update status as you work on it

### For Testers

When reporting bugs from testing:
1. Provide clear reproduction steps
2. Include screenshots or screen recordings
3. Specify exact environment (device, OS, app version)
4. Note if it's reproducible every time or intermittent
5. Check if it happens on multiple devices/platforms

### For Users (Beta Testers)

When reporting bugs via feedback:
1. Describe what you were trying to do
2. Explain what went wrong
3. Include device type and OS version if possible
4. Screenshots are very helpful

---

## Detailed Bug Reports

### BUG-001: iOS CocoaPods Dependency Conflicts Preventing Build

**Priority:** Medium

**Status:** Open

**Sprint:** Sprint 9 - Goal Creation Part 1

**Component:** iOS Build / CocoaPods Dependencies

**Description:**

- **What happened:** Running `flutter run` on iOS fails during pod install with dependency version conflicts

- **Expected behavior:** Pod install should complete successfully and app should build for iOS

- **Error Details:**
  ```
  CocoaPods could not find compatible versions for pod "AppAuth":
  - google_sign_in_ios requires AppAuth (>= 1.7.4)
  - GoogleSignIn (~> 8.0) requires AppAuth (< 2.0, >= 1.7.3)

  CocoaPods could not find compatible versions for pod "GoogleUtilities/Environment":
  - firebase_auth (Firebase 10.22.0) requires GoogleUtilities/Environment (~> 7.8)
  - firebase_core (Firebase 10.22.0) requires GoogleUtilities/Environment (~> 7.12)
  - GoogleUtilities/Logger (7.13.3) requires GoogleUtilities/Environment (= 7.13.3)
  - google_sign_in_ios (GoogleSignIn 8.0.0) requires GoogleUtilities/Environment (~> 8.0)

  CocoaPods could not find compatible versions for pod "nanopb":
  - cloud_firestore requires nanopb (< 2.30910.0, >= 2.30908.0)
  - firebase_analytics requires nanopb (< 2.30911.0, >= 2.30908.0)
  ```

- **Root Cause:** Version incompatibility between Firebase packages (10.22.0) and GoogleSignIn (8.0.0)
  - Firebase 10.22.0 depends on GoogleUtilities ~> 7.x
  - GoogleSignIn 8.0.0 (via google_sign_in_ios) depends on GoogleUtilities ~> 8.0
  - This creates an unresolvable dependency conflict

- **Steps to reproduce:**
  1. Run `flutter run` on iOS device
  2. Observe pod install failure during build process
  3. Check CocoaPods error logs

- **Environment:**
  - Platform: iOS
  - Xcode: Latest
  - iOS Deployment Target: 14.0
  - CocoaPods: 1.16.2
  - Flutter SDK: 3.38.4
  - Device: iPhone (iOS 18.6.2)

- **Impact:**
  - iOS builds are currently blocked
  - App can only be tested on Android
  - Sprint 9 functionality (Goal Creation) cannot be tested on iOS

- **Possible Solutions:**
  1. Upgrade Firebase packages to latest versions (may require newer GoogleUtilities)
  2. Downgrade google_sign_in package to older version compatible with Firebase 10.22.0
  3. Wait for package maintainers to release compatible versions
  4. Use dependency overrides in Podfile (risky, may cause runtime issues)

- **Workaround:**
  - Test on Android device instead of iOS
  - Sprint 9 code is platform-agnostic and will work on iOS once dependencies are resolved

**Discovered:** 2025-12-31 (Session 011)

**Assigned:** Unassigned

**Reference:** [Session 011](Session_log.md#session-011---2025-12-31)

**Notes:**
- This issue does not affect the quality or completeness of Sprint 9 code
- The Goal Creation feature implementation is complete and passes all static analysis (flutter analyze: 0 issues)
- Android builds work successfully
- Issue is purely related to iOS native dependency management

---

**Last Updated:** 2025-12-31
**Total Bugs Logged:** 1
**Bugs Fixed:** 0
**Open Bugs:** 1

# User Workflow Testing Guide

**Date:** 2026-01-06
**Purpose:** Systematic testing of all user workflows and screens to identify inconsistencies before Sprint 17.5 (Wearables Integration)

---

## Testing Methodology

For each workflow/screen, check:
- ✅ **Visual Consistency:** Matches design system (colors, typography, spacing)
- ✅ **Functionality:** All features work as expected
- ✅ **Navigation:** Proper transitions and back button behavior
- ✅ **Error Handling:** Graceful error messages and states
- ✅ **Loading States:** Proper loading indicators
- ✅ **Empty States:** Handled appropriately
- ✅ **Edge Cases:** Extreme values, poor connectivity, etc.

**Status Key:**
- [ ] Not tested
- [✓] Passed
- [⚠] Minor issues
- [❌] Critical issues
- [📝] Notes

---

## 1. Authentication Flow

### 1.1 Welcome/Splash Screen
- [ ] App logo displays correctly
- [ ] Transition to login/onboarding smooth
- [ ] No flickering or delays
- [ ] **Notes:**

### 1.2 Login Screen
- [✓] Email/password fields styled correctly (SolidCard)
- [✓] Logo with glow effect present
- [✓] Gradient text "Run to Canada" visible
- [✓] "Forgot Password" link works
- [✓] Navigation to Signup works
- [✓] Login with valid credentials succeeds
- [✓] Login with invalid credentials shows error
- [✓] Error messages user-friendly
- [✓] Loading indicator during login
- [✓] Remember me functionality (if implemented)
- [✓] **Notes:** Tested in Sessions 3-29. Google Sign-In Android pending (BUG-004)

### 1.3 Signup Screen
- [✓] Email/password/confirm fields styled correctly
- [✓] Password strength indicator visible
- [✓] Terms & Privacy links work
- [✓] Signup with valid data succeeds
- [✓] Signup with existing email shows error
- [✓] Password mismatch validation works
- [✓] Navigates to onboarding after signup
- [✓] **Notes:** Tested in Sessions 3-29. Password strength indicator added in Session 021. Terms & Privacy links working (deployed to runtocanada.happyloop.pro)

### 1.4 Forgot Password Screen
- [ ] Email field styled correctly
- [ ] Reset email sent successfully
- [ ] User feedback message shown
- [ ] Navigation back to login works
- [ ] **Notes:**

---

## 2. Onboarding Flow (First-Time Users)

### 2.1 Onboarding Screens (4 screens)
- [✓] Screen 1: Welcome message clear
- [✓] Screen 2: GPS tracking explained
- [✓] Screen 3: Journey concept explained
- [✓] Screen 4: Goal creation preview
- [✓] Page indicator dots work correctly
- [✓] "Next" button navigates forward
- [✓] "Skip" button navigates to home
- [✓] "Get Started" button on final screen works
- [✓] Gradient icons with shadows visible
- [✓] Animations smooth
- [✓] Only shows once per user
- [✓] **Notes:** Tested in Session 029 (Sprint 17 complete). All 4 screens implemented with gradient icons, smooth animations, and Hive-based completion tracking. Location permission deferred to first run (DEC-005)

---

## 3. Home Dashboard

### 3.1 Main Components
- [✓] User avatar with level badge displays
- [✓] Time-based greeting correct ("Good morning", etc.)
- [✓] Notification bell icon present
- [✓] Immersive map card (4:3 aspect ratio) visible
- [✓] Map shows current location or journey progress
- [✓] "Live Tracking" pulsing badge visible (if active goal)
- [✓] **Notes:** Tested in Sessions 13-14 (Sprint 16.5 - Design System Overhaul). Top bar clutter noted (Issue #10) - minor priority

### 3.2 Stats Grid (2-column)
- [✓] Total distance stat correct
- [✓] Active goal stat correct
- [✓] Stats styled with decorative circles
- [✓] Trend indicators visible
- [✓] **Notes:** Tested in Sessions 13-14

### 3.3 Next Milestone Card
- [✓] Milestone name displayed
- [✓] Milestone photo loads correctly
- [✓] Distance to milestone shown
- [✓] Orange gradient styling visible
- [✓] Tapping opens journey map (if implemented)
- [✓] Shows empty state if no active goal
- [✓] **Notes:** Tested in Sessions 13-14

### 3.4 Achievement Carousel
- [✓] Achievements scroll horizontally
- [✓] Achievement cards styled correctly
- [✓] Shows placeholder if no achievements
- [✓] **Notes:** Tested in Sessions 13-14

### 3.5 Actions
- [⚠] Glowing FAB "Start Run" button (64px) visible
- [⚠] FAB positioned bottom-right
- [⚠] FAB has blue glow effect
- [⚠] Tapping FAB starts run tracking
- [⚠] Premium upgrade button (gold pill) visible
- [⚠] Premium button navigates to paywall
- [⚠] **Notes:** Tested in Sessions 13-14. **MINOR ISSUE:** Issue #10 - Top bar cluttered (notification bell, premium button, FAB all competing for attention). Priority: High, Status: Open

### 3.6 Bottom Navigation
- [✓] Home tab selected by default
- [✓] History tab navigates correctly
- [✓] Goals tab navigates correctly
- [✓] Profile tab navigates correctly
- [✓] Icons and labels clear
- [✓] **Notes:** Tested in Sessions 13-14

---

## 4. Run Tracking Flow

### 4.1 Run Tracking Screen
- [✓] Pulsing "TRACKING" header visible
- [✓] Circular user avatar with gradient ring
- [✓] Huge distance display (84px) clear
- [✓] Distance increments in real-time
- [✓] Duration timer updates (HH:MM:SS)
- [✓] Pace display updates (min/km or min/mile)
- [✓] Current speed displayed
- [✓] Route points indicator shows count
- [✓] Glassmorphic metrics cards visible
- [✓] Map shows current location
- [✓] Route polyline draws in real-time
- [✓] **Notes:** Tested in Sessions 4, 13-14. Redesigned in Sprint 16.5 with new glassmorphic design system

### 4.2 Run Controls (Circular Button Dock)
- [✓] Three circular buttons visible
- [✓] Pause button works (changes to Resume)
- [✓] Resume button works (changes to Pause)
- [✓] Stop button works
- [✓] Cancel button works (with confirmation dialog)
- [✓] Button icons clear and intuitive
- [✓] Buttons positioned at bottom center
- [✓] **Notes:** Tested in Sessions 4, 13-14

### 4.3 GPS & Location
- [✓] Location permission requested
- [✓] GPS initializes successfully
- [✓] GPS accuracy acceptable (< 20m)
- [✓] Location updates smooth
- [✓] Poor GPS signal handled gracefully
- [✓] **Notes:** Tested in Sessions 4, 13-14

### 4.4 Background Tracking
- [✓] App continues tracking in background
- [✓] Notification shown during tracking (if implemented)
- [✓] Tracking survives app minimization
- [✓] **Notes:** Tested in Sessions 4, 13-14

---

## 5. Run Summary & History

### 5.1 Run Summary Screen
- [⚠] Appears after stopping run
- [✓] Total distance displayed correctly
- [✓] Total duration displayed correctly
- [✓] Average pace displayed correctly
- [✓] Elevation gain displayed (if available)
- [✓] Calories burned displayed
- [✓] Map shows complete route
- [✓] Route polyline styled correctly
- [✓] Start/end markers visible
- [✓] Notes text field present
- [✓] "Save Run" button works
- [⚠] "Discard Run" button works (with confirmation)
- [✓] Saving navigates to history or home
- [⚠] **Notes:** Tested in Session 032 (Code Review). **BUG-005:** Discard button shows confirmation but doesn't delete run from Hive (TODO comment at line 194). Save functionality works perfectly - saves to Hive, queues for sync, updates goal progress, detects milestones. Excellent UI with gradient cards, proper stats display, interstitial ads for free users.

### 5.2 Run History Screen
- [✓] Timeline view with 48px gradient circular icons
- [✓] Runs listed chronologically (newest first)
- [✓] Each run shows: date, distance, duration, pace
- [✓] PrimaryCard summary at top (total stats)
- [✓] Pull-to-refresh works
- [✓] Tapping run navigates to detail
- [✓] Empty state shown if no runs
- [✓] "Create Your First Goal" CTA visible (if empty)
- [✓] **Notes:** Tested in Session 032 (Code Review). All features implemented correctly. Beautiful timeline design with gradient icons and connector lines. Overall statistics card shows total runs, distance, and time. Notes preview shown in cards. Empty state has "Start Running" CTA (better UX than "Create Your First Goal"). Pull-to-refresh, error handling, and loading states all working properly.

### 5.3 Run Detail Screen
- [✓] All run statistics displayed
- [✓] Map shows route
- [✓] Route polyline visible
- [✓] Notes displayed (if added)
- [✓] Delete button works (with confirmation)
- [✓] Deleting navigates back to history
- [❌] Share button works (if implemented)
- [⚠] **Notes:** Tested in Session 032 (Code Review). **ENH-001:** Share functionality not implemented (Medium priority, v1.1 target). All other features working correctly. Delete button in app bar with confirmation dialog. Editable notes with save/cancel. Sync status indicator. Date/time card with start/end times. Beautiful performance metrics grid. Excellent implementation quality overall.

---

## 6. Goal Creation Flow (4-Step Wizard)

### 6.1 Step 1: Start Location
- [✓] Modern step indicator (gradient circles) visible
- [✓] "Step 1 of 4" text clear
- [✓] Location search field works
- [✓] Search results appear in dropdown
- [✓] "Use Current Location" button works
- [✓] Selected location shows on map
- [✓] "Next" button enabled after selection
- [✓] **Notes:** Tested in Session 4. Fixed and working

### 6.2 Step 2: Destination Location
- [✓] Step indicator shows step 2
- [✓] Same search functionality as step 1
- [✓] Destination selected on map
- [✓] Both start and destination visible on map
- [✓] "Next" button enabled after selection
- [✓] **Notes:** Tested in Session 4. Fixed and working

### 6.3 Step 3: Route Preview
- [✓] Step indicator shows step 3
- [✓] Route polyline visible on map
- [✓] Milestone list displayed
- [✓] Major cities along route shown
- [✓] Total distance displayed
- [✓] Loading state while calculating route
- [✓] "Next" button enabled after route loads
- [✓] **Notes:** Tested in Session 4. Fixed and working

### 6.4 Step 4: Goal Name & Confirmation
- [✓] Step indicator shows step 4
- [✓] Auto-populated goal name: "Run to {destination}"
- [✓] Goal name editable
- [✓] Route summary displayed
- [✓] Milestone count shown
- [✓] "Create Goal" button works
- [✓] Loading indicator during creation
- [✓] Success message shown
- [✓] Navigates to journey map after creation
- [✓] **Notes:** Tested in Session 4. Fixed keyboard obscuring goal name input (Issue #30) in Session 22

### 6.5 Error Handling
- [✓] No search results handled gracefully
- [✓] API errors shown with user-friendly message
- [✓] Route calculation failure handled
- [✓] "Back" button works on all steps
- [✓] **Notes:** Tested in Session 4. Fixed and working

---

## 7. Journey Map & Progress

### 7.1 Journey Map Screen
- [ ] Full-screen map visible
- [ ] Goal route displayed as polyline
- [ ] Start marker visible
- [ ] Destination marker visible
- [ ] Current virtual location marker visible
- [ ] Completed segment styled differently (green)
- [ ] Remaining segment styled differently (gray)
- [ ] All milestones shown as markers
- [ ] Reached milestones styled differently (green)
- [ ] Unreached milestones styled differently (gray)
- [ ] **Notes:**

### 7.2 Progress Stats
- [ ] Progress percentage displayed
- [ ] Distance completed displayed
- [ ] Distance remaining displayed
- [ ] Stats update after runs
- [ ] **Notes:**

### 7.3 Milestone Interaction
- [ ] Tapping milestone shows details (if implemented)
- [ ] Milestone name displayed
- [ ] Milestone photo displayed
- [ ] City description shown
- [ ] Distance from start shown
- [ ] Reached status clear
- [ ] **Notes:**

### 7.4 Empty State
- [ ] Empty state shown if no active goal
- [ ] "Create Your First Goal" CTA visible
- [ ] CTA navigates to goal creation
- [ ] **Notes:**

---

## 8. Milestone Celebration

### 8.1 Celebration Screen
- [ ] Appears after reaching milestone
- [ ] Custom confetti animation plays
- [ ] Milestone city name displayed
- [ ] Milestone photo displayed
- [ ] Fun fact about city shown
- [ ] Progress stats displayed (distance so far, remaining)
- [ ] "Continue" button works
- [ ] Celebration only shows once per milestone
- [ ] **Notes:**

---

## 9. Premium & Paywall

### 9.1 Premium Paywall Screen
- [ ] Gold gradient header visible
- [ ] "Upgrade to Premium" title clear
- [ ] Premium benefits listed with icons
- [ ] Feature cards styled correctly
- [ ] Pricing cards visible (monthly & annual)
- [ ] Monthly: $2.99/month shown
- [ ] Annual: $19.99/year shown
- [ ] Annual savings (44% off) highlighted
- [ ] "Subscribe" buttons work
- [ ] "Restore Purchases" button visible
- [ ] "Continue with Free" option visible
- [ ] RevenueCat purchase flow initiates
- [ ] **Notes:**

### 9.2 Free User Limit (100km)
- [ ] Free users blocked at 100km journey distance
- [ ] Paywall appears when limit reached
- [ ] Paywall triggered before run start (if over limit)
- [ ] Error message explains limit
- [ ] **Notes:**

### 9.3 Premium Features
- [ ] Premium users have unlimited journey distance
- [ ] Premium badge shows in profile (if implemented)
- [ ] Ads hidden for premium users
- [ ] **Notes:**

### 9.4 Purchase Flow
- [ ] Purchase flow completes successfully (requires real testing)
- [ ] Entitlements granted after purchase
- [ ] Premium features unlock immediately
- [ ] Purchase errors handled gracefully
- [ ] Cancelled purchases handled gracefully
- [ ] **Notes:**

---

## 10. Ads (Free Users Only)

### 10.1 Banner Ad (Home Screen)
- [⚠] Banner ad visible at bottom of home screen (free users)
- [⚠] Banner ad hidden for premium users
- [⚠] Ad loads without blocking UI
- [⚠] Ad failure handled gracefully (no crash)
- [⚠] **Notes:** Tested in Sessions 3-29. **MINOR ISSUES:** Issue #17 - iOS ads not showing (Priority: High, Status: Open). Issue #18 - Android ads safe area not respecting navigation buttons (Priority: High, Status: Open)

### 10.2 Interstitial Ad (Post-Run)
- [ ] Interstitial ad shows after run (occasionally, every 3 runs)
- [ ] Ad doesn't block saving run data
- [ ] User can close ad after countdown
- [ ] Ad failure doesn't block app flow
- [ ] **Notes:**

---

## 11. Settings Screen

### 11.1 Layout & Design
- [ ] Gradient icons with shadows visible
- [ ] Settings grouped in modern cards
- [ ] Section headers clear
- [ ] **Notes:**

### 11.2 Unit Preferences
- [ ] "Units" setting shows current value (Metric/Imperial)
- [ ] Toggling units updates immediately
- [ ] Distance displays update app-wide
- [ ] Preference persists after restart
- [ ] **Notes:**

### 11.3 Map Style
- [ ] "Map Style" setting shows current style
- [ ] All 6 styles available (streets, satellite, outdoors, light, dark, navigation)
- [ ] Changing style updates maps immediately
- [ ] Preference persists
- [ ] **Notes:**

### 11.4 Notifications
- [ ] "Milestone Notifications" toggle visible
- [ ] Toggle works
- [ ] Preference persists
- [ ] **Notes:**

### 11.5 Account Actions
- [ ] "Logout" button works
- [ ] Logout confirmation dialog shown
- [ ] Logout clears auth state
- [ ] Navigates to login screen
- [ ] "Delete Account" button visible (red/warning color)
- [ ] Delete confirmation dialog shown with warning
- [ ] Delete account removes data from Firestore
- [ ] Delete account removes auth account
- [ ] Delete account clears Hive data
- [ ] **Notes:**

---

## 12. Profile Screen

### 12.1 Layout & Design
- [ ] SliverAppBar with gradient header
- [ ] User avatar visible in header
- [ ] User name displayed
- [ ] User email displayed
- [ ] Premium badge visible (if premium)
- [ ] **Notes:**

### 12.2 Statistics
- [ ] Total runs count correct
- [ ] Total distance correct
- [ ] Total goals created correct
- [ ] Active goals count correct
- [ ] Stats styled with modern cards
- [ ] **Notes:**

### 12.3 Navigation
- [ ] "Settings" button navigates to settings
- [ ] Back button works
- [ ] **Notes:**

---

## 13. Cross-Screen Issues

### 13.1 Navigation Consistency
- [ ] Back button behavior consistent across all screens
- [ ] Page transitions smooth (fade, slide, modal, scale)
- [ ] Hero animations work (e.g., premium icon)
- [ ] Bottom navigation persists where appropriate
- [ ] **Notes:**

### 13.2 Design System Consistency
- [ ] Lexend font used throughout
- [ ] Primary blue (#0D7FF2) consistent
- [ ] Dark theme consistent
- [ ] Card components (Glass, Solid, Primary, Milestone, Premium) used correctly
- [ ] Button components (Custom, Text, Icon, Social, FAB) styled correctly
- [ ] Spacing and padding consistent
- [ ] **Notes:**

### 13.3 Loading & Error States
- [ ] Shimmer/skeleton loaders used appropriately
- [ ] Loading indicators present during async operations
- [ ] Error messages user-friendly (no technical jargon)
- [ ] Retry options available on errors
- [ ] **Notes:**

### 13.4 Empty States
- [ ] Empty states have clear messaging
- [ ] Empty states have actionable CTAs
- [ ] Empty state illustrations/icons present
- [ ] **Notes:**

---

## 14. Offline Behavior & Sync

### 14.1 Offline Mode
- [ ] App doesn't crash when offline
- [ ] Runs can be completed offline
- [ ] Runs queued for sync when offline
- [ ] Goals can be viewed offline (cached data)
- [ ] User-friendly message shown when network required
- [ ] **Notes:**

### 14.2 Sync Functionality
- [ ] Sync queue processes when online
- [ ] Sync happens automatically in background
- [ ] Sync errors handled gracefully
- [ ] Retry logic works (exponential backoff)
- [ ] Sync status indicator (if implemented)
- [ ] **Notes:**

---

## 15. Performance & Polish

### 15.1 App Performance
- [ ] App launches quickly (< 3 seconds)
- [ ] No lag during navigation
- [ ] Maps render smoothly
- [ ] Animations smooth (60fps)
- [ ] No memory leaks or crashes
- [ ] Battery consumption reasonable during tracking
- [ ] **Notes:**

### 15.2 Accessibility
- [ ] Text readable (sufficient contrast)
- [ ] Buttons large enough to tap
- [ ] Semantic labels for screen readers (if implemented)
- [ ] **Notes:**

### 15.3 Edge Cases
- [ ] Very long runs (100+ km) handled
- [ ] Multiple goals managed correctly
- [ ] Goal completion (100% progress) handled
- [ ] App killed during run handled gracefully
- [ ] Poor GPS signal handled
- [ ] **Notes:**

---

## 16. Critical Issues Checklist

Before proceeding to Sprint 17.5, ensure these critical items work:

- [ ] **Authentication:** Users can sign up, log in, log out
- [ ] **Run Tracking:** GPS tracking works, runs save correctly
- [ ] **Run History:** All runs displayed, can view details and delete
- [ ] **Goal Creation:** Complete 4-step wizard works, route and milestones generated
- [ ] **Journey Progress:** Virtual location updates after runs, milestones detected
- [ ] **Milestone Celebration:** Celebration shows when milestone reached
- [ ] **Premium Paywall:** 100km limit enforced, paywall appears, purchase flow initiates
- [ ] **Ads:** Banner and interstitial ads load (free users only)
- [ ] **Settings:** All preferences work and persist
- [ ] **Profile:** Stats accurate, logout and delete account work
- [ ] **Sync:** Runs and goals sync to Firebase
- [ ] **Offline:** App doesn't crash, data queued for sync

---

## 17. Known Issues Log

Document all issues found during testing:

| #  | Screen/Flow | Issue Description | Severity | Status |
|----|-------------|-------------------|----------|--------|
| 1  | Home Dashboard (Section 3.5) | Issue #10: Top bar cluttered - notification bell, premium button, FAB competing for attention | High | Open |
| 2  | Ads (Section 10.1) | Issue #17: iOS banner ads not showing | High | Open |
| 3  | Ads (Section 10.1) | Issue #18: Android banner ads safe area not respecting navigation buttons | High | Open |
| 4  | Settings (Section 11) | Issue #8: Documentation incorrect for map styles | Low | Open |
| 5  | Forgot Password (Section 1.4) | Issue #5: Password reset email verification flow not implemented | High | On Hold |
| 6  | Run Summary (Section 5.1) | BUG-005: Discard run doesn't delete from Hive storage | High | Open |
| 7  | Run Detail (Section 5.3) | ENH-001: Share run functionality not implemented | Medium | Open |

**Severity Key:**
- **Critical:** Blocks core functionality
- **High:** Major usability issue
- **Medium:** Minor issue, but noticeable
- **Low:** Cosmetic or edge case

---

## Testing Notes

- **Device:** (iPhone 15, Pixel 8, etc.)
- **OS Version:** (iOS 17, Android 14, etc.)
- **App Version:** 1.0.0
- **Test Date:** 2026-01-06
- **Tester:**

---

## Next Steps After Testing

1. **Document all issues** in the Known Issues Log
2. **Prioritize fixes** (Critical → High → Medium → Low)
3. **Fix critical issues** before Sprint 17.5
4. **Fix high/medium issues** in Sprint 18 (Polish & Testing)
5. **Proceed to Sprint 17.5** (Wearables Integration) once app is stable

---

**End of Testing Guide**

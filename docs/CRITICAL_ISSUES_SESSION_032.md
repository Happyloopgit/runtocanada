# Critical Issues & Enhancements - Session 032 User Testing

**Created:** 2026-01-10
**Purpose:** Temporary tracker for 20 issues discovered during user testing
**Status:** 🔴 ACTIVE - Working Document
**Final Task:** Update Bug_tracker.md, Backlog_tracker.md, and other docs when all fixes complete

---

## 📋 Issue Summary

| Category | Count | Status |
|----------|-------|--------|
| 🔴 Critical Bugs | 4 | Open |
| 🟡 High Priority UX | 7 | Open |
| 🟠 Medium Priority | 5 | Open |
| 🎨 Design System V2 | 4 | Open |
| **TOTAL** | **20** | **All Open** |

---

## 🔴 CRITICAL BUGS (Must Fix First)

### BUG-006: New Goal Not Appearing on Home Screen
**Priority:** Critical
**Status:** 🔴 Open
**Component:** Home Dashboard / Data Sync

**Description:**
- User creates first goal and makes it active
- Goal appears in Goals screen as active
- Goal does NOT appear on Home screen
- After deactivating and reactivating in Goals screen, it appears on Home

**Impact:**
- Blocks core user flow
- Confusing UX - users think goal creation failed
- Critical for first-time user experience

**Root Cause Analysis Needed:**
- Provider state management issue?
- Home screen not listening to goal state changes?
- Async data loading timing issue?

**Files to Investigate:**
- `home_screen.dart` - Active goal display logic
- `goal_providers.dart` - State management
- `goal_service.dart` - Goal activation logic

**Fix Priority:** 1 (First bug to fix)

---

### BUG-007: Runs Not Showing in Activity Screen
**Priority:** Critical
**Status:** 🔴 Open
**Component:** Run History / Data Display

**Description:**
- User completes run without active goal
- Clicks "Save Run" on Run Summary screen
- Shows "Run saved successfully" message
- Run does NOT appear in Activity/History screen

**Questions:**
- Are runs without goals saved to Hive?
- Is Activity screen filtering only goal-attached runs?
- Is this intentional behavior or bug?

**Impact:**
- Users lose confidence in app
- Data appears to be lost (even if saved)
- Breaks run tracking core functionality

**Root Cause Analysis Needed:**
- Check Run History screen filtering logic
- Verify runs are actually saved to Hive
- Check if goalId is required for display

**Files to Investigate:**
- `run_history_screen.dart` - Display/filter logic
- `run_local_datasource.dart` - Save logic
- `run_model.dart` - Data model (goalId required?)

**Fix Priority:** 2

---

### BUG-008: "Already Tracking" Error After Saving Run
**Priority:** Critical
**Status:** 🔴 Open
**Component:** Run Tracking / State Management

**Description:**
- User starts run (without goal)
- User stops run
- User saves run successfully
- Immediately after, user taps "Start Run" again
- Error: "Exception: cannot start run, already tracking"

**Impact:**
- Blocks users from starting new runs
- Requires app restart to continue
- Critical state management bug

**Root Cause Analysis Needed:**
- isTracking flag not being reset after save?
- State cleanup issue in tracking service?
- Race condition between save and state reset?

**Files to Investigate:**
- `run_tracking_screen.dart` - State management
- `tracking_providers.dart` - isTracking state
- `run_summary_screen.dart` - State cleanup on save

**Fix Priority:** 3

---

### BUG-009: Timer Not Progressing Smoothly
**Priority:** High (Originally listed as critical)
**Status:** 🔴 Open
**Component:** Run Tracking / UI Performance

**Description:**
- During run tracking, timer display doesn't progress smoothly
- May update in large jumps or freeze temporarily
- Affects user confidence in tracking accuracy

**Impact:**
- Users think tracking is broken
- Affects perceived app quality
- May indicate performance issue

**Root Cause Analysis Needed:**
- Timer update frequency (should be every second)
- UI rebuild optimization needed?
- Background tracking affecting UI thread?

**Files to Investigate:**
- `run_tracking_screen.dart` - Timer display logic
- Timer implementation (Timer.periodic?)
- State update frequency

**Fix Priority:** 4

---

## 🟡 HIGH PRIORITY UX ISSUES

### ENH-002: Edit Goal Name Functionality Missing
**Priority:** High
**Status:** 🔴 Open
**Component:** Goals / UX

**Description:**
- No way to edit goal name after creation
- Need pen/edit icon beside goal name
- Common user request for flexibility

**User Story:**
- As a user, I want to edit my goal name so I can personalize or fix typos

**Acceptance Criteria:**
- Pen icon beside goal name
- Tapping opens edit dialog
- Can update goal name
- Changes persist to Hive and Firebase

**Estimated Effort:** Small (2-3 hours)

---

### BUG-010: FAB Button Misconfigured on Goals Screen
**Priority:** High
**Status:** 🔴 Open
**Component:** Goals Screen / UI

**Description:**
- FAB button shows as blue circle BEHIND text "+ New Goal"
- Should be properly styled elevated button
- Looks broken/unprofessional

**Impact:**
- Poor first impression
- Looks like CSS/styling bug
- Affects app credibility

**Files to Fix:**
- `goals_screen.dart` - FAB configuration
- Check FloatingActionButton widget usage

**Estimated Effort:** Small (30min - 1 hour)

---

### ENH-003: No Goal Details / Milestone View
**Priority:** High
**Status:** 🔴 Open
**Component:** Goals / Information Architecture

**Description:**
- No way to see goal details (route, milestones, stats)
- Journey summary shows minimal details
- Users can't review their goal plan

**User Story:**
- As a user, I want to view my goal details so I can see the full route and all milestones

**Acceptance Criteria:**
- New Goal Details screen
- Shows: Route map, all milestones, total distance, progress, estimated completion
- Accessible from Goals screen and Journey screen

**Estimated Effort:** Medium (4-6 hours)

---

### ENH-004: Active Goal Tap Navigation Missing
**Priority:** High
**Status:** 🔴 Open
**Component:** Goals Screen / Navigation

**Description:**
- Tapping active goal in Goals screen does nothing
- Should navigate to Goal Details/Summary screen
- Natural user expectation

**Acceptance Criteria:**
- Tapping active goal card navigates to Goal Details
- Tapping inactive goal shows "Set Active" option
- Smooth navigation transition

**Estimated Effort:** Small (1-2 hours, depends on ENH-003)

---

### ENH-005: Milestone Algorithm Needs Complete Redesign
**Priority:** High
**Status:** 🔴 Open
**Component:** Goals / Milestone Generation

**Description:**
Current milestone system is hardcoded and doesn't work with:
- User psychology (milestones as adrenaline boosts)
- Reality (milestone spacing based on distance AND cities)
- Engagement (milestones should encourage, not frustrate)

**Requirements:**
- **Adaptive algorithm** - adjusts to goal distance
- **City-aware** - prioritizes major cities along route
- **Psychology-driven** - milestones are "small wins" to keep users motivated
- **Not rigid** - no fixed "every X km" rule
- **Human-centered** - milestones shouldn't take forever to reach

**Algorithm Considerations:**
- Short goals (<100km): More frequent milestones (every 10-20km)
- Medium goals (100-500km): Mix of distance and city-based
- Long goals (>500km): Major cities + distance checkpoints
- Always include interesting/notable stops (not just any city)

**Examples:**
- Toronto to Vancouver (4,400km): ~20-30 milestones (major cities + scenic points)
- Toronto to Montreal (540km): ~8-12 milestones (cities + landmarks)
- Local goal (50km): ~3-5 milestones (neighborhoods + parks)

**Estimated Effort:** Large (8-12 hours - needs research + implementation)

---

### ENH-006: Journey Map Centering & Legend Issues
**Priority:** High
**Status:** 🔴 Open
**Component:** Journey Map / UX

**Description:**
- Map should center on user's current position AND next milestone
- Map legend shows something different than actual markers
- Confusing for users

**Acceptance Criteria:**
- Map auto-centers to show both current position and next milestone
- Legend accurately matches map markers
- Consider zoom level to show context

**Estimated Effort:** Medium (3-4 hours)

---

### BUG-011: Journey Map Fixed Position Limits Scrolling
**Priority:** High
**Status:** 🔴 Open
**Component:** Journey Progress Screen / Layout

**Description:**
- Big map has fixed position
- Leaves limited room to scroll details below
- Poor UX on mobile devices

**Solutions to Consider:**
- Make map collapsible
- Use SliverAppBar with flexible space
- Allow resizing map
- Better scrolling behavior

**Estimated Effort:** Medium (2-3 hours)

---

## 🟠 MEDIUM PRIORITY ENHANCEMENTS

### ENH-007: Goal Background Images
**Priority:** Medium
**Status:** 🔴 Open
**Component:** Goals / Design System

**Description:**
- Add AI-generated background images for goals
- Must be configurable via Firebase Remote Config (no code changes/resubmission)
- Reference: `/stitch_welcome_to_run_to_canada` wireframes

**Implementation Plan:**
1. Design pattern for goal card backgrounds
2. Firebase Remote Config setup for image URLs
3. Image caching strategy
4. Fallback images
5. AI image generation prompts (later)

**Acceptance Criteria:**
- Goal cards show beautiful background images
- Images loaded from Remote Config
- Can update images without app resubmission
- Graceful fallback if image fails to load
- Optional: Custom images per goal later

**Estimated Effort:** Medium (4-6 hours)

---

### ENH-008: Wikipedia Integration for Milestone Context
**Priority:** Medium
**Status:** 🔴 Open
**Component:** Milestones / Content

**Description:**
- Use free Wikipedia API to add context to milestones
- Photos of cities/landmarks
- Fun facts about locations
- Make app more engaging

**Implementation Plan:**
1. Research Wikipedia API endpoints
2. Fetch city photos (Wikimedia Commons)
3. Extract interesting facts (intro paragraph)
4. Cache content locally
5. Fallback for API failures

**Acceptance Criteria:**
- Milestone cards show Wikipedia photos
- Fun facts about each city
- Offline support (cached data)
- Engaging presentation

**Estimated Effort:** Medium (6-8 hours)

---

### ENH-009: Verify/Fix Virtual Travel Logic
**Priority:** Medium
**Status:** 🔴 Open
**Component:** Goals / Progress Calculation

**Description:**
- Verify logic exists for converting actual runs into virtual travel along goal route
- User runs 5km → virtual position advances 5km along route
- Milestone detection based on virtual position

**Tasks:**
1. Verify virtual travel logic exists and works
2. Test with multiple scenarios
3. Ensure milestone detection triggers correctly
4. Progress percentage calculation accurate

**Files to Check:**
- `goal_service.dart` - updateGoalProgress()
- `goal_model.dart` - virtual position tracking

**Estimated Effort:** Small (2-3 hours investigation + fixes)

---

### ENH-010: Reorganize Profile Screen
**Priority:** Medium
**Status:** 🔴 Open
**Component:** Profile / Information Architecture

**Description:**
- Profile screen has redundant info
- Stats should be in Activity screen
- Run history should be in Activity
- Achievements should be in Activity or Goals
- What are achievements anyway?

**Proposed Changes:**
- Profile: User info, settings, premium status
- Activity: Run history, stats, achievements
- Goals: Goal-specific achievements

**Estimated Effort:** Medium (4-5 hours)

---

### ENH-011: Smart Goal Estimation
**Priority:** Medium
**Status:** 🔴 Open
**Component:** Goals / UX / Psychology

**Description:**
Current goal estimation shows "driving time" which is useless.

**Should Show:**
- Walking/running time estimate
- Number of runs needed (at user's average pace)
- Days to completion (at different run frequencies)
- Use as psychological trigger for premium conversion

**Example Display:**
```
"Toronto to Vancouver - 4,400 km"
At your current pace:
- 880 runs of 5km each
- OR 440 runs of 10km each
- Complete in: 2.4 years (running 5km weekly)
- Complete in: 1.2 years (with Premium - unlimited runs!)
```

**Estimated Effort:** Medium (4-6 hours)

---

## 🎨 DESIGN SYSTEM V2 OVERHAUL

### DES-001: Goal Card Background Images & Design Pattern
**Priority:** High
**Status:** 🔴 Open
**Component:** Design System

**Description:**
- Finalize design pattern for goal cards with backgrounds
- AI image generation prompts
- Remote config integration
- Visual hierarchy and readability

**Decisions Needed:**
- Image style: Realistic photos vs Illustrated vs Abstract
- Overlay gradient for text readability
- Card layout with background
- Animation/transitions

**Estimated Effort:** Large (planning + implementation)

---

### DES-002: App Overall "Active" Feel
**Priority:** High
**Status:** 🔴 Open
**Component:** Design System / UX

**Description:**
Current app feels "dull" and "boring" - just boxes with info.

**Issues:**
- Lacks micro-interactions
- No animations or transitions
- Static feel - nothing "happening"
- Doesn't feel premium
- Looks basic compared to competitors (Nike Run Club, Strava)

**Solutions Needed:**
- Micro-animations (button presses, card reveals)
- Progress animations (distance filling, stats counting up)
- Smooth transitions between screens
- Loading states that feel active
- Hero animations
- Skeleton loaders
- Pulse/glow effects where appropriate

**Examples to Study:**
- Nike Run Club: Active stats display
- Strava: Social feed energy
- Apple Fitness: Ring animations

**Estimated Effort:** Very Large (ongoing - 12+ hours initial)

---

### DES-003: Premium Visual Polish
**Priority:** High
**Status:** 🔴 Open
**Component:** Design System

**Description:**
App needs to feel premium, not just functional.

**Current Issues:**
- "Bunch of boxes" appearance
- Zero design elements
- Doesn't feel like premium app worth $2.99/month

**Improvements Needed:**
- Depth/shadows (not flat)
- Gradient accents
- Icon system refinement
- Typography hierarchy
- White space optimization
- Visual rhythm
- Consistent spacing system

**Estimated Effort:** Large (8-10 hours)

---

### ENH-012: User Profile Pictures
**Priority:** Low (Future)
**Status:** 🔴 Open
**Component:** Profile / Social

**Description:**
- Add user profile picture support
- Upload from device
- Crop/resize functionality
- Display in profile and throughout app

**Estimated Effort:** Medium (4-6 hours)

---

## 💰 MONETIZATION

### ENH-013: Paywall Implementation & 100km Tracker
**Priority:** High
**Status:** 🔴 Open
**Component:** Premium / Monetization

**Description:**
Current plan: 100km free limit.

**User Flow:**
1. User creates goal and starts running
2. Show km tracker on screen (e.g., "85km / 100km free remaining")
3. When approaching limit, show warning
4. At 100km, show paywall
5. Prevent abuse (can't delete goal to reset)

**Implementation Needed:**
- Total distance tracker (across ALL runs, not per goal)
- Warning at 90km, 95km, 100km
- Visual indicator on tracking screen
- Paywall screen at limit
- Premium unlock

**Estimated Effort:** Medium (5-6 hours)

---

## 📝 DOCUMENTATION TASKS

### FINAL: Update Official Trackers
**Priority:** N/A
**Status:** ⏳ Pending (Do Last)
**Component:** Documentation

**When all above issues are fixed, update:**

1. **Bug_tracker.md**
   - Add BUG-006, BUG-007, BUG-008, BUG-009, BUG-010, BUG-011
   - Mark as Fixed/Closed as completed
   - Update bug counts

2. **Backlog_tracker.md**
   - Add ENH-002 through ENH-013
   - Add DES-001, DES-002, DES-003
   - Categorize by v1.0 vs v1.1
   - Update enhancement counts

3. **USER_WORKFLOW_TESTING.md**
   - Update sections as bugs fixed
   - Add notes about fixes

4. **CONSOLIDATION_TRACKER.md**
   - Update with session notes
   - Track time spent

5. **Archive this document**
   - Move to `docs/archive/CRITICAL_ISSUES_SESSION_032.md`
   - Add reference in main tracker

---

## 🎯 Fix Priority Order

### Phase 1: Critical Bugs (Session 033)
1. BUG-006: New goal not appearing on home
2. BUG-007: Runs not showing in activity
3. BUG-008: "Already tracking" error
4. BUG-009: Timer not progressing

**Estimated Time:** 3-4 hours

---

### Phase 2: High Priority UX (Sessions 034-035)
5. BUG-010: FAB button misconfigured
6. ENH-002: Edit goal name
7. ENH-003: Goal details screen
8. ENH-004: Active goal navigation
9. ENH-006: Journey map centering
10. BUG-011: Journey map scrolling

**Estimated Time:** 8-10 hours

---

### Phase 3: Milestone Algorithm (Session 036)
11. ENH-005: Milestone algorithm redesign

**Estimated Time:** 8-12 hours

---

### Phase 4: Design System V2 (Sessions 037-039)
12. DES-001: Background images
13. DES-002: Active feel
14. DES-003: Premium polish

**Estimated Time:** 12-15 hours

---

### Phase 5: Medium Priority (Sessions 040-041)
15. ENH-007: Goal backgrounds implementation
16. ENH-008: Wikipedia integration
17. ENH-009: Virtual travel verification
18. ENH-010: Profile reorganization
19. ENH-011: Smart goal estimation

**Estimated Time:** 10-12 hours

---

### Phase 6: Monetization (Session 042)
20. ENH-013: Paywall & km tracker

**Estimated Time:** 5-6 hours

---

## 📊 Progress Tracking

| Phase | Issues | Status | Time Est. | Time Actual | Notes |
|-------|--------|--------|-----------|-------------|-------|
| Phase 1 | 4 bugs | 🔴 Not Started | 3-4 hours | - | Critical |
| Phase 2 | 6 items | 🔴 Not Started | 8-10 hours | - | UX Priority |
| Phase 3 | 1 item | 🔴 Not Started | 8-12 hours | - | Algorithm |
| Phase 4 | 3 items | 🔴 Not Started | 12-15 hours | - | Design |
| Phase 5 | 5 items | 🔴 Not Started | 10-12 hours | - | Medium |
| Phase 6 | 1 item | 🔴 Not Started | 5-6 hours | - | Monetization |
| **TOTAL** | **20** | **0% Done** | **46-59 hours** | **0 hours** | - |

---

## 🔗 Related Documents

- [Bug Tracker](trackers/Bug_tracker.md)
- [Backlog Tracker](trackers/Backlog_tracker.md)
- [User Workflow Testing](USER_WORKFLOW_TESTING.md)
- [Consolidation Tracker](CONSOLIDATION_TRACKER.md)

---

**Last Updated:** 2026-01-10 (Created)
**Next Review:** After Phase 1 completion
**Status:** Active working document - will be archived when complete

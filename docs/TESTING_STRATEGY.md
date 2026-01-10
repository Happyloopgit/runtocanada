# Testing Strategy

**Created:** 2026-01-10 (Session 031)
**Purpose:** Define systematic approach for testing all remaining untested features before Sprint 18 (Polish & Testing)
**Status:** Active

---

## 📋 Document Overview

This document establishes a systematic testing strategy to ensure all features are thoroughly tested before moving to Sprint 18 (Polish & Testing). After completing Sprints 0-17 and extensive testing/fixing in Sessions 3-29, we have several untested sections remaining.

**Current Testing Status:**
- **Tested & Passing:** Login, Signup, Onboarding, Home Dashboard, Run Tracking, Goal Creation
- **Tested with Minor Issues:** Home Actions (Issue #10), Banner Ads (Issues #17, #18)
- **Not Yet Tested:** Run Summary & History, Journey Map, Milestone Celebration, Premium Paywall, Settings, Profile, Cross-Screen Issues, Offline/Sync, Performance

---

## 🎯 Testing Philosophy

### Core Principles

1. **Systematic Over Ad-Hoc**
   - Test one section at a time following USER_WORKFLOW_TESTING.md
   - Document findings immediately in proper trackers
   - No temporary documents after consolidation is complete

2. **Quality Over Speed**
   - Thorough testing of each section
   - Test happy paths AND edge cases
   - Verify error handling and loading states

3. **Fix Critical Issues Immediately**
   - Critical bugs block further testing
   - High-priority bugs should be fixed within 1-2 sessions
   - Medium/Low priority can be backlogged

4. **Document Everything**
   - Use Bug_tracker.md for bugs (never temp docs)
   - Use Backlog_tracker.md for enhancements/features
   - Update USER_WORKFLOW_TESTING.md as you test

---

## 📊 Testing Approach

### One Section Per Session

Each testing session should focus on ONE section from USER_WORKFLOW_TESTING.md:

1. **Pre-Testing Setup (5 min)**
   - Review the section checklist in USER_WORKFLOW_TESTING.md
   - Ensure test environment is ready (device charged, network available)
   - Have Bug_tracker.md and Backlog_tracker.md open

2. **Testing Execution (45-90 min)**
   - Go through each checklist item systematically
   - Test on both iOS and Android if possible
   - Try edge cases and error scenarios
   - Take screenshots of any issues
   - Note observations in real-time

3. **Documentation (15-30 min)**
   - Mark tested items in USER_WORKFLOW_TESTING.md as [✓] or [⚠] or [❌]
   - Add bugs to Bug_tracker.md immediately (use proper format)
   - Add enhancement requests to Backlog_tracker.md
   - Update session notes in CONSOLIDATION_TRACKER.md

4. **Fix Critical Issues (if found)**
   - If critical bugs are found, fix them immediately
   - Re-test the section after fixes
   - Update bug status to "Fixed" then "Closed" after verification

### Issue Discovery Workflow

```
┌─────────────────────────────────┐
│ Discover Issue During Testing  │
└────────────┬────────────────────┘
             │
             ▼
      ┌──────────────┐
      │  Categorize  │
      └──────┬───────┘
             │
     ┌───────┴────────┐
     │                │
     ▼                ▼
┌─────────┐     ┌──────────────┐
│   Bug   │     │ Enhancement  │
│         │     │  /Feature    │
└────┬────┘     └──────┬───────┘
     │                 │
     ▼                 ▼
┌─────────────┐  ┌─────────────────┐
│ Bug_tracker │  │ Backlog_tracker │
│    .md      │  │      .md        │
└─────────────┘  └─────────────────┘
     │                 │
     └────────┬────────┘
              │
              ▼
    ┌──────────────────┐
    │ Assign Priority  │
    └────────┬─────────┘
             │
             ▼
┌────────────────────────┐
│ Critical/High → Fix    │
│ Medium/Low → Backlog   │
└────────────────────────┘
```

---

## 🎯 Testing Priority Order

### Priority 1: Critical Path (Must Work Before Sprint 18)

These features are core to the app's value proposition and must be fully functional:

#### Session 1: Run Summary & History (Section 5)
- **Why Priority 1:** Users need to see their completed runs
- **Components:** Run summary screen, run history list, run detail view
- **Focus Areas:**
  - Run data saves correctly after tracking
  - All metrics displayed accurately (distance, duration, pace)
  - Map shows route correctly
  - History screen shows all runs
  - Delete functionality works
- **Estimated Time:** 2-3 hours

#### Session 2: Journey Map & Progress (Section 7)
- **Why Priority 1:** Core feature showing virtual journey progress
- **Components:** Journey map visualization, progress tracking, milestone markers
- **Focus Areas:**
  - Map displays route correctly
  - Current position marker shows correctly
  - Milestones appear at correct distances
  - Progress percentage calculates correctly
  - Virtual travel conversion logic works
- **Estimated Time:** 2-3 hours

#### Session 3: Premium & Paywall (Section 9)
- **Why Priority 1:** Monetization is critical for business viability
- **Components:** Paywall screen, 100km limit, purchase flow, premium features
- **Focus Areas:**
  - 100km free limit enforced correctly
  - Paywall appears at correct time
  - Purchase flow initiates (RevenueCat)
  - Premium features unlock after purchase
  - Free vs Premium differentiation clear
- **Estimated Time:** 2-3 hours

---

### Priority 2: Important Features (Should Work Before Sprint 18)

These features enhance user experience significantly:

#### Session 4: Milestone Celebration (Section 8)
- **Why Priority 2:** Key engagement moment for users
- **Components:** Celebration screen, confetti animation, milestone info
- **Focus Areas:**
  - Celebration triggers when milestone reached
  - Animation plays smoothly
  - City name and photo display correctly
  - Fun facts about city shown
  - Celebration only shows once per milestone
- **Estimated Time:** 1-2 hours

#### Session 5: Settings Screen (Section 11)
- **Why Priority 2:** Users need to customize preferences
- **Components:** Unit settings, map style, notifications, account actions
- **Focus Areas:**
  - All settings toggles work
  - Changes persist after restart
  - Logout works correctly
  - Delete account works correctly (with confirmation)
- **Estimated Time:** 2-3 hours

#### Session 6: Profile Screen (Section 12)
- **Why Priority 2:** Users need to see their stats and achievements
- **Components:** User profile, statistics, achievements
- **Focus Areas:**
  - Profile displays correctly
  - Stats are accurate
  - Premium badge shows for premium users
  - Navigation to settings works
- **Estimated Time:** 2-3 hours

---

### Priority 3: Edge Cases & Polish (Can Be Done During Sprint 18)

These are important but not blockers:

#### Session 7: Cross-Screen Issues (Section 13)
- **Why Priority 3:** Ensures consistency across the app
- **Components:** Navigation, design system, loading/error states
- **Focus Areas:**
  - Back button behavior consistent
  - Transitions smooth
  - Design system applied consistently
  - Loading states present
  - Error messages user-friendly
- **Estimated Time:** 2-3 hours

#### Session 8: Offline Behavior & Sync (Section 14)
- **Why Priority 3:** Edge case for most users
- **Components:** Offline mode, sync queue, network error handling
- **Focus Areas:**
  - App doesn't crash offline
  - Runs can be completed offline
  - Data syncs when online
  - User-friendly messages when network required
- **Estimated Time:** 2-3 hours

#### Session 9: Performance & Polish (Section 15)
- **Why Priority 3:** Final polish before release
- **Components:** Launch time, navigation performance, memory usage
- **Focus Areas:**
  - App launches quickly
  - No lag during navigation
  - Maps render smoothly
  - Animations 60fps
  - No memory leaks
- **Estimated Time:** 2-3 hours

---

## 🐛 Issue Management Workflow

### How to Handle Discovered Issues

When you discover an issue during testing:

1. **Immediately Categorize:**
   - **Bug:** Something broken that should work
   - **Enhancement:** Improvement to existing feature
   - **Feature Request:** New functionality not yet implemented

2. **Document in Proper Tracker:**
   - **Bugs → Bug_tracker.md**
     - Use BUG-XXX format (e.g., BUG-005, BUG-006)
     - Include full template (description, steps, environment, priority)
     - Assign severity: Critical / High / Medium / Low

   - **Enhancements/Features → Backlog_tracker.md**
     - Add to appropriate section (Features, Enhancements, Tech Debt)
     - Use proper ID format (FEAT-XXX, ENH-XXX, TD-XXX)
     - Include user story, acceptance criteria, estimated effort

3. **Assign Priority:**
   - **Critical:** App crashes, data loss, security issue → Fix immediately
   - **High:** Major feature broken, significant UX impact → Fix within 1-2 sessions
   - **Medium:** Partial functionality, workaround exists → Backlog for Sprint 18
   - **Low:** Cosmetic, edge case → Backlog for future sprints

4. **Update Testing Document:**
   - Mark item in USER_WORKFLOW_TESTING.md:
     - [✓] Passed
     - [⚠] Minor issues (document issue numbers)
     - [❌] Critical issues (must fix before continuing)
   - Add notes with issue numbers and brief description

### Example Issue Documentation

**Discovering a Bug:**
```
During testing Run History (Section 5.2):
→ Runs not displaying after saving

Actions:
1. Open Bug_tracker.md
2. Add BUG-005: Runs not displaying in history after save
   - Priority: High
   - Steps to reproduce: Start run → Stop → Save → Navigate to History → Empty
3. Update USER_WORKFLOW_TESTING.md Section 5.2:
   - [❌] Runs listed chronologically (newest first) - BUG-005
4. Fix bug immediately (High priority)
5. Re-test Section 5.2
6. Update BUG-005 status to Fixed → Closed
7. Update USER_WORKFLOW_TESTING.md Section 5.2:
   - [✓] Runs listed chronologically (newest first) - Fixed BUG-005
```

**Discovering an Enhancement:**
```
During testing Profile (Section 12):
→ Would be nice to show user's longest run stat

Actions:
1. Open Backlog_tracker.md
2. Add ENH-XXX: Add "Longest Run" stat to Profile
   - Priority: Medium
   - User Story: As a user, I want to see my longest run so I can track my personal best
   - Acceptance Criteria: Display longest run distance on Profile screen
3. Continue testing (don't implement enhancements during testing phase)
4. Update USER_WORKFLOW_TESTING.md Section 12:
   - [✓] Statistics displayed - Note: Enhancement request ENH-XXX for "Longest Run" stat
```

---

## 🎨 Handling New Feature Discoveries

During testing, you may discover features that would significantly improve the app. Here's how to handle them:

### Quick Evaluation Questions

1. **Is this a bug or enhancement?**
   - Bug: Something broken
   - Enhancement: Improvement to existing feature
   - New Feature: Entirely new capability

2. **Does it block current functionality?**
   - Yes → Must fix before proceeding (Bug)
   - No → Document and backlog (Enhancement/Feature)

3. **What's the user impact?**
   - Critical: Blocks core workflows
   - High: Major UX improvement
   - Medium: Nice to have
   - Low: Edge case or polish

### Documentation Process

**For Major Feature Ideas (Like your 20 discoveries):**

1. **Create a Feature Proposal Document** (if 5+ related items)
   - Example: `docs/proposals/DESIGN_SYSTEM_V2_PROPOSAL.md`
   - Group related enhancements
   - Include mockups or references
   - Estimate effort

2. **Or Add Individual Items to Backlog**
   - For 1-4 related items
   - Use Backlog_tracker.md
   - Link related items together

3. **Review and Prioritize Later**
   - Don't implement during testing phase
   - Review all discoveries after testing complete
   - Prioritize for Sprint 19+ roadmap

---

## ✅ Sprint 18 Readiness Criteria

Before proceeding to Sprint 18 (Polish & Testing), ensure:

### Critical Requirements (Must Have)

- [ ] **Authentication:** Users can sign up, log in, log out
- [ ] **Run Tracking:** GPS tracking works, runs save correctly, no "already tracking" errors
- [ ] **Run History:** All runs displayed, can view details and delete
- [ ] **Goal Creation:** Complete 4-step wizard works, route and milestones generated
- [ ] **Journey Progress:** Virtual location updates after runs, milestones detected correctly
- [ ] **Milestone Celebration:** Celebration shows when milestone reached
- [ ] **Premium Paywall:** 100km limit enforced, paywall appears correctly, purchase flow initiates
- [ ] **Ads:** Banner and interstitial ads load (free users only), safe area respected on Android
- [ ] **Settings:** All preferences work and persist
- [ ] **Profile:** Stats accurate, logout and delete account work
- [ ] **Sync:** Runs and goals sync to Firebase
- [ ] **Offline:** App doesn't crash, data queued for sync

### High Priority (Should Have)

- [ ] **Home Dashboard:** Active goals display correctly after creation
- [ ] **Run Timer:** Timer progresses smoothly during tracking
- [ ] **Journey Map:** Map centers on user position and next milestone, markers match legend
- [ ] **Goal Details:** Users can view goal summary with milestones
- [ ] **No Critical Bugs:** All critical bugs closed (app doesn't crash, no data loss)

### Medium Priority (Nice to Have)

- [ ] **Performance:** App launches quickly (< 3 seconds), navigation smooth
- [ ] **Design Consistency:** All screens follow design system
- [ ] **Error Handling:** User-friendly error messages throughout
- [ ] **Loading States:** Proper loading indicators during async operations

### Bug Count Targets

- **Critical Bugs:** 0 open
- **High Priority Bugs:** ≤ 2 open
- **Medium Priority Bugs:** ≤ 5 open
- **Low Priority Bugs:** Unlimited (can be addressed in Sprint 18+)

---

## 📅 Testing Timeline

Estimated timeline to complete all testing:

| Session | Focus Area | Priority | Est. Time | Cumulative |
|---------|------------|----------|-----------|------------|
| **Session X** | Run Summary & History (Section 5) | Priority 1 | 2-3 hours | 2-3 hours |
| **Session Y** | Journey Map & Progress (Section 7) | Priority 1 | 2-3 hours | 4-6 hours |
| **Session Z** | Premium & Paywall (Section 9) | Priority 1 | 2-3 hours | 6-9 hours |
| **Session W** | Milestone Celebration (Section 8) | Priority 2 | 1-2 hours | 7-11 hours |
| **Session V** | Settings Screen (Section 11) | Priority 2 | 2-3 hours | 9-14 hours |
| **Session U** | Profile Screen (Section 12) | Priority 2 | 2-3 hours | 11-17 hours |
| **Session T** | Cross-Screen Issues (Section 13) | Priority 3 | 2-3 hours | 13-20 hours |
| **Session S** | Offline & Sync (Section 14) | Priority 3 | 2-3 hours | 15-23 hours |
| **Session R** | Performance & Polish (Section 15) | Priority 3 | 2-3 hours | 17-26 hours |

**Total Estimated Testing Time:** 17-26 hours (spread across 9-12 sessions)

---

## 🔄 Continuous Improvement

### After Each Testing Session

1. **Reflect on Process:**
   - Was the testing systematic?
   - Were issues documented immediately?
   - Did we use proper trackers (no temp docs)?

2. **Update This Document:**
   - If you discover better testing approaches, update this doc
   - Add new sections if needed
   - Refine priorities based on findings

3. **Track Progress:**
   - Update CONSOLIDATION_TRACKER.md with session notes
   - Update Overall Progress in tracker
   - Celebrate completed sections

---

## 📚 Reference Documents

### Testing Documents
- [USER_WORKFLOW_TESTING.md](USER_WORKFLOW_TESTING.md) - Main testing checklist
- [Bug_tracker.md](trackers/Bug_tracker.md) - Bug documentation
- [Backlog_tracker.md](trackers/Backlog_tracker.md) - Features & enhancements

### Consolidation Tracking
- [CONSOLIDATION_TRACKER.md](CONSOLIDATION_TRACKER.md) - Overall consolidation progress
- [Session_log.md](trackers/Session_log.md) - Session history

### Project Documentation
- [Sprint Plan](03-sprint-plan.md) - Sprint roadmap
- [Technical Architecture](02-technical-architecture.md) - System design
- [Product Concept](01-product-concept.md) - Product vision

---

## 🎯 Success Metrics

We'll know we're successful when:

1. **All Priority 1 & 2 sections tested** (Sections 5, 7, 8, 9, 11, 12)
2. **Zero critical bugs open**
3. **≤ 2 high-priority bugs open**
4. **All discovered issues properly documented** (in Bug_tracker.md or Backlog_tracker.md)
5. **USER_WORKFLOW_TESTING.md 90%+ complete**
6. **Sprint 18 readiness criteria met**

---

**Last Updated:** 2026-01-10 (Session 031 - Phase 3)
**Next Review:** After completing Priority 1 testing (Sessions X-Z)
**Status:** Active - Ready to guide testing for Sessions 032+

# Decisions Log

This document tracks significant architectural and technical decisions made during the development of Run to Canada.

## Decision Summary

| Decision ID | Title | Date | Session | Status | Impact |
|-------------|-------|------|---------|--------|--------|
| DEC-001 | User-scoped Hive boxes architecture | 2026-01-06 | Session 022 | ✅ Implemented | High |
| DEC-002 | Lazy datasource initialization pattern | 2026-01-09 | Session 023 | ✅ Implemented | High |
| DEC-003 | Terms & Privacy website deployment | 2026-01-06 | Session 021 | ✅ Implemented | Medium |
| DEC-004 | Design system overhaul timing | 2026-01-06 | Sessions 022-028 | ✅ Implemented | High |
| DEC-005 | Onboarding without location permission | 2026-01-06 | Session 029 | ✅ Implemented | Low |

---

## Decisions by Category

### Architecture & Data Management
- [DEC-001: User-scoped Hive boxes architecture](#dec-001-user-scoped-hive-boxes-architecture)
- [DEC-002: Lazy datasource initialization pattern](#dec-002-lazy-datasource-initialization-pattern)

### User Experience & Design
- [DEC-004: Design system overhaul timing](#dec-004-design-system-overhaul-timing)
- [DEC-005: Onboarding without location permission](#dec-005-onboarding-without-location-permission)

### Legal & Compliance
- [DEC-003: Terms & Privacy website deployment](#dec-003-terms--privacy-website-deployment)

---

## Detailed Decision Records

### DEC-001: User-scoped Hive boxes architecture

**Date:** 2026-01-06 (Session 022)

**Status:** ✅ Implemented

**Category:** Architecture & Data Management

**Priority:** High

**Context:**

During testing in Session 022, a critical multi-user data leakage issue was discovered (Issue #62). When multiple users logged in on the same device:
- User A's goals would appear in User B's account
- Goals were not properly isolated per user
- Data contamination occurred across user sessions

The root cause was that all users shared the same Hive boxes (`goals`, `settings`, etc.), leading to data mixing between different user accounts.

**Decision:**

Implement user-scoped Hive boxes with the naming pattern: `user_{userId}_boxName`

Examples:
- `user_abc123_goals` - Goals box for user with ID "abc123"
- `user_abc123_settings` - Settings box for user with ID "abc123"
- `user_xyz789_goals` - Goals box for different user with ID "xyz789"

Each user gets their own isolated Hive boxes, physically separated on the device.

**Rationale:**

1. **Physical Data Isolation:** Separate boxes prevent any possibility of cross-user data contamination
2. **Security:** User data cannot leak to other users even if there's a bug in filtering logic
3. **Simplicity:** No need for complex filtering logic - each user's box only contains their data
4. **Performance:** Smaller boxes per user are faster to access than one large shared box
5. **Clean Logout:** When user logs out, their boxes can be closed without affecting other users

**Implementation Details:**

- Modified all datasource classes (`GoalLocalDataSource`, `RunLocalDataSource`, etc.)
- Changed from static box names to user-specific box names
- Box lifecycle tied to user authentication state
- Boxes opened on login, closed on logout
- Old shared boxes migrated/cleaned up

**Alternatives Considered:**

1. **Filter at query level:** Query shared box but filter by userId
   - Rejected: Risk of bugs leading to data leakage
   - More complex code, harder to maintain

2. **Single box with user prefix on keys:** Store all data in one box with keys like `user_abc123_goal_001`
   - Rejected: Still requires careful key management
   - Performance degradation with large shared box

**Impact:**

- ✅ Fixed critical data leakage issue (Issue #62)
- ✅ Improved security and data isolation
- ✅ Simplified data access logic
- ⚠️ Required code changes in all datasource classes
- ✅ No breaking changes for existing users (migration handled)

**References:**
- Issue #62: Multi-user data leakage
- Session 022: [Session_log.md](Session_log.md#session-022---2026-01-06)
- Sprint Plan: [Pre-Sprint 18 Testing Phase](../03-sprint-plan.md#pre-sprint-18-testing--fixing-phase-sessions-3-29)

---

### DEC-002: Lazy datasource initialization pattern

**Date:** 2026-01-09 (Session 023)

**Status:** ✅ Implemented

**Category:** Architecture & Data Management

**Priority:** High

**Context:**

After implementing DEC-001 (user-scoped Hive boxes), a new critical issue emerged (Issue #63):
- App crashed on startup with error: "No user logged in"
- Crash occurred before user had a chance to log in
- Root cause: Datasources tried to access user-scoped boxes during initialization
- Boxes couldn't be created because no user was authenticated yet

The problem was **eager initialization** - datasources tried to open Hive boxes immediately when created, but user ID was not available until after login.

**Decision:**

Change from **eager** to **lazy** initialization pattern for all datasources.

**Before (Eager):**
```dart
class GoalLocalDataSource {
  final Box<Goal> _goalsBox;

  GoalLocalDataSource(String userId)
    : _goalsBox = Hive.box<Goal>('user_${userId}_goals'); // ❌ Opens box immediately
}
```

**After (Lazy):**
```dart
class GoalLocalDataSource {
  final String userId;
  Box<Goal>? _goalsBox;

  GoalLocalDataSource(this.userId);

  Future<Box<Goal>> _getBox() async {
    if (_goalsBox == null || !_goalsBox!.isOpen) {
      _goalsBox = await Hive.openBox<Goal>('user_${userId}_goals');
    }
    return _goalsBox!;
  }

  Future<void> saveGoal(Goal goal) async {
    final box = await _getBox(); // ✅ Opens box only when needed
    await box.put(goal.id, goal);
  }
}
```

**Rationale:**

1. **Deferred Execution:** Boxes accessed only when actually needed (when user is logged in)
2. **Graceful Handling:** No crash if datasource created before login
3. **Flexibility:** Datasources can be injected at app startup without issues
4. **Resource Efficiency:** Boxes only opened when required, not kept open unnecessarily
5. **Error Recovery:** If box fails to open, error occurs at usage time with proper context

**Implementation Details:**

- Added `_getBox()` method to all datasource classes
- Changed all public methods to `async` to await box access
- Added null checks and `isOpen` checks before box access
- Graceful error handling with user-friendly messages
- Box opened on first access, reused for subsequent operations

**Alternatives Considered:**

1. **Initialize datasources after login:** Only create datasources once user is logged in
   - Rejected: Makes dependency injection complex
   - Breaks provider architecture

2. **Use default box until login:** Start with shared box, switch to user box after login
   - Rejected: Risk of data being written to wrong box
   - Migration complexity

3. **Check auth state in datasource constructor:** Throw error if no user
   - Rejected: Still causes app crash
   - Doesn't solve the timing issue

**Impact:**

- ✅ Fixed critical app startup crash (Issue #63)
- ✅ App can start successfully before user logs in
- ✅ Datasources safely injectable at app initialization
- ⚠️ All datasource methods became async (minor API change)
- ✅ Better error messages when operations fail
- ✅ Improved resource management (boxes closed when not needed)

**References:**
- Issue #63: App startup crash - "No user logged in"
- Session 023: [Session_log.md](Session_log.md#session-023---2026-01-09)
- Related: DEC-001 (User-scoped Hive boxes)
- Technical Debt: TD-003 in [Backlog_tracker.md](Backlog_tracker.md)

---

### DEC-003: Terms & Privacy website deployment

**Date:** 2026-01-06 (Session 021)

**Status:** ✅ Implemented

**Category:** Legal & Compliance

**Priority:** Medium

**Context:**

App Store and Google Play Store require apps to provide:
1. Terms of Service URL
2. Privacy Policy URL

These documents must be:
- Publicly accessible (no login required)
- Hosted on a stable URL
- Available before app submission

The team needed to decide how to deploy these legal documents quickly and reliably without setting up complex infrastructure.

**Decision:**

Deploy Terms of Service and Privacy Policy as simple HTML pages to **runtocanada.happyloop.pro** using basic web hosting.

**Implementation:**
- Static HTML pages (no backend, no framework)
- Clean, readable design with proper typography
- Mobile-responsive layout
- Fast loading (minimal CSS, no JavaScript)
- Stable subdomain under existing infrastructure

**Rationale:**

1. **Speed:** Can be deployed in minutes, no complex setup
2. **Simplicity:** Static HTML is reliable, no moving parts to break
3. **Cost:** Minimal hosting costs, no server-side processing needed
4. **Maintenance:** Easy to update - just edit HTML files
5. **Performance:** Extremely fast loading times
6. **Compliance:** Meets all App Store and Play Store requirements
7. **No Dependencies:** Doesn't require app to be published first

**Alternatives Considered:**

1. **Host on Firebase Hosting:**
   - Considered but unnecessary complexity for static pages
   - Would require Firebase CLI setup and deployment pipeline

2. **Use Google Sites or similar service:**
   - Less control over URL structure
   - Potential for service discontinuation

3. **Include in app as screens:**
   - Rejected: Stores require external URLs
   - Can't be accessed before app download

4. **WordPress or CMS:**
   - Massive overkill for two static pages
   - Adds maintenance burden and security concerns

**Implementation Details:**

- URL structure:
  - Terms: `https://runtocanada.happyloop.pro/terms`
  - Privacy: `https://runtocanada.happyloop.pro/privacy`
- Simple HTML5 with semantic markup
- Mobile-first responsive design
- Links added to app's Login and Signup screens
- Links added to App Store and Play Store listings

**Impact:**

- ✅ Legal compliance requirement met
- ✅ Ready for app store submission
- ✅ Professional appearance
- ✅ Fast deployment (completed in Session 021)
- ✅ Easy to update if legal requirements change
- ✅ No ongoing maintenance burden

**References:**
- Session 021: [Session_log.md](Session_log.md#session-021---2026-01-06)
- Sprint Plan: [Session 21 Legal & Compliance](../03-sprint-plan.md#legal--compliance-session-021)

---

### DEC-004: Design system overhaul timing

**Date:** 2026-01-06 (Sessions 022-028)

**Status:** ✅ Implemented (Sprint 16.5)

**Category:** User Experience & Design

**Priority:** High

**Context:**

After Sprint 16 (Ad Integration), the designer provided professional mockups with a completely new visual design:
- Dark theme as primary theme
- Bright blue primary color (#0D7FF2)
- Lexend typography system
- Glassmorphic card components
- Modern gradient buttons
- Polished animations and transitions

The team faced a critical decision: When to implement this new design?

**Options:**
1. **Wait until later** (Sprint 18 Polish & Testing)
2. **Implement now** (before Sprint 17 Onboarding)

**Decision:**

Implement the complete design system overhaul **immediately** as Sprint 16.5, before continuing to Sprint 17 (Onboarding).

This meant pausing feature development to rebuild the entire UI with the new design system.

**Rationale:**

1. **Avoid Rework:** Building Sprint 17+ with old design would require rebuilding later
2. **Cost Efficiency:** Implementing design once is cheaper than building twice
3. **Consistency:** All new features automatically use correct design from start
4. **Professional Appearance:** Beta testing and launch will have polished UI
5. **Designer Alignment:** Shows respect for designer's work, implemented while fresh
6. **Momentum:** Design inspiration is highest right after receiving mockups
7. **Sprint 18 Efficiency:** Polish sprint can focus on refinement, not redesign

**Counter-Arguments Considered:**

- "It will delay Sprint 17 (Onboarding)"
  - Response: 1-2 week delay is better than weeks of rework later

- "We should test functionality first, polish later"
  - Response: True for MVP, but we're past MVP stage with 16 sprints complete

- "Design is subjective, functionality matters more"
  - Response: Both matter; professional appearance is critical for user adoption

**Implementation as Sprint 16.5:**

**Phase 1: Foundation**
- Lexend font via google_fonts
- New color system (AppColors)
- Dark theme as primary
- Typography system (AppTextStyles)

**Phase 2: Component Library**
- 5 card variants (Glass, Solid, Primary, Milestone, Premium)
- 5 button types (Custom, Text, Icon, Social, GlowingFAB)
- Input components
- Progress indicators

**Phase 3-6: Screen Rebuilds**
- Authentication screens (Login, Signup)
- Home Dashboard (complete rebuild)
- Run Tracking & History
- Goal Creation flow
- Premium Paywall
- Settings & Profile

**Phase 6: Animations**
- 5 transition types
- Micro-interactions
- Hero animations
- Shimmer/skeleton loaders

**Impact:**

- ✅ Professional, polished appearance from Sprint 17 onwards
- ✅ No rework needed for future sprints
- ✅ Consistent design system across entire app
- ✅ All 8 designer mockups implemented pixel-perfect
- ⚠️ 1.5-2 week delay to Sprint 17 (acceptable tradeoff)
- ✅ Sprint 18 (Polish) can focus on testing and refinement
- ✅ App ready for high-quality screenshots for App Store
- ✅ Better first impression for beta testers

**Lessons Learned:**

1. Investing in design early pays off in reduced rework
2. Pausing feature development for UX improvements is sometimes the right call
3. Designer collaboration works best when mockups implemented quickly
4. Component library approach makes design changes manageable

**References:**
- Sprint 16.5: [SPRINT_16_5_DESIGN_SYSTEM.md](../SPRINT_16_5_DESIGN_SYSTEM.md)
- Design System Specs: [DESIGN_SYSTEM.md](../DESIGN_SYSTEM.md)
- Sessions 022-028: Complete implementation
- Sprint Plan: [Sprint 16.5 section](../03-sprint-plan.md#sprint-165-design-system-overhaul-)

---

### DEC-005: Onboarding without location permission

**Date:** 2026-01-06 (Session 029)

**Status:** ✅ Implemented

**Category:** User Experience & Design

**Priority:** Low

**Context:**

Sprint 17 (Onboarding & Tutorial) originally planned to request location permission during the onboarding flow:
- Step 1: Welcome
- Step 2: GPS tracking explanation → **Request location permission**
- Step 3: Journey concept
- Step 4: Goal creation preview

However, during implementation in Session 029, the team reconsidered this approach.

**Decision:**

**Defer location permission request** until first run attempt, rather than requesting it during onboarding.

Onboarding now focuses purely on education:
- Screen 1: Welcome & app introduction
- Screen 2: GPS tracking explanation (educational)
- Screen 3: Journey concept explanation
- Screen 4: Goal creation preview
- **No permission requests during onboarding**

Permission requested when user taps "Start Run" for the first time.

**Rationale:**

1. **Simpler Onboarding:** Fewer steps, less cognitive load on new users
2. **Context-Aware Permissions:** Permission requested when user understands why they need it
3. **Higher Grant Rate:** Users more likely to grant permission when they're about to use the feature
4. **Platform Guidelines:** iOS and Android both recommend "ask when needed" approach
5. **Graceful Degradation:** App usable without permission (can create goals, view profile, etc.)
6. **Less Friction:** New users can complete onboarding faster

**Permission Request Flow After This Decision:**

1. User completes onboarding
2. User explores app (home screen, create goal, view profile)
3. User taps "Start Run" button
4. App checks location permission status
5. If not granted, show permission request with explanation
6. If denied, show settings prompt
7. If granted, start run immediately

**Alternatives Considered:**

1. **Request during onboarding (original plan):**
   - Would make onboarding longer and more complex
   - Users might deny without understanding benefit

2. **Request on app launch:**
   - Bad UX - user hasn't even seen the app yet
   - Violates platform best practices

3. **Never request, rely on user to grant manually:**
   - Too technical for average user
   - Would result in support requests

**Implementation Details:**

- Removed permission request code from onboarding screens
- Added permission check to Run Tracking screen
- Created permission explanation dialog
- Added "Open Settings" helper if permission denied
- Updated onboarding screen 2 to be purely educational (no action required)

**Impact:**

- ✅ Faster, simpler onboarding flow
- ✅ Better user experience (permission in context)
- ✅ Aligned with platform best practices
- ✅ Reduced onboarding abandonment risk
- ⚠️ Tutorial overlays deferred to future sprint (optional enhancement)
- ✅ App still guides users through first-time experience

**Future Enhancements (Deferred):**

- Tutorial overlays for first run
- Tooltips highlighting important features
- In-app guided tour
- (These were optional features, not critical for MVP)

**References:**
- Session 029: [Session_log.md](Session_log.md#session-029---2026-01-06)
- Sprint 17: [Sprint Plan](../03-sprint-plan.md#sprint-17-onboarding--tutorial)
- Onboarding screens: `app/lib/features/onboarding/presentation/screens/`

---

## Decision Template

Use this template when adding new decisions:

### DEC-XXX: Decision Title

**Date:** YYYY-MM-DD (Session XXX)

**Status:** 🟡 Proposed / ✅ Implemented / ❌ Rejected / ⏸️ On Hold

**Category:** Architecture / User Experience / Performance / Legal / etc.

**Priority:** Critical / High / Medium / Low

**Context:**

Describe the situation and problem that led to this decision. Include:
- What was happening?
- What problem needed solving?
- What constraints existed?

**Decision:**

State the decision clearly and concisely.

**Rationale:**

Explain why this decision was made:
1. Reason 1
2. Reason 2
3. Reason 3

**Alternatives Considered:**

1. **Alternative 1:** Description
   - Why rejected: Reason

2. **Alternative 2:** Description
   - Why rejected: Reason

**Implementation Details:**

- Technical details
- Code changes
- Configuration changes
- Migration steps

**Impact:**

- ✅ Positive impact 1
- ✅ Positive impact 2
- ⚠️ Tradeoff 1
- ❌ Negative impact (if any)

**References:**
- Link to session log
- Link to related issues
- Link to related code

---

## Metadata

**Document Created:** 2026-01-10 (Session 030)
**Last Updated:** 2026-01-10 (Session 030)
**Total Decisions:** 5
**Active Decisions:** 5
**Rejected Decisions:** 0

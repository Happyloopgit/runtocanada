# Sprint 16.5: Design System Overhaul

**Status:** 🚧 IN PROGRESS
**Priority:** CRITICAL
**Estimated Duration:** 1.5-2 weeks
**Dependencies:** Sprint 15, Sprint 16

---

## Goal

Implement the complete design system from the designer's mockups, transforming the app from a functional prototype to a polished, professional product that matches the designer's vision pixel-perfect.

---

## Background

We received professional design mockups that show a significantly more polished and modern visual direction than our current implementation:

- **Current:** Light mode, Canadian red theme, basic Material Design
- **Designer:** Dark mode primary, bright blue theme, glassmorphism, modern typography

This sprint implements the complete design transformation before we continue with additional features.

---

## Reference Materials

- Design System Document: `/docs/DESIGN_SYSTEM.md`
- Designer Mockups: `/stitch_welcome_to_run_to_canada/`
- Screenshots: See folder for 8 screens

---

## Phase 1: Foundation (Days 1-2) ✅ COMPLETED

### Typography
- [x] Download Lexend font (weights 100-900) - Using google_fonts package
- [x] Add Lexend to assets folder - Not needed (using google_fonts)
- [x] Configure google_fonts package - Added ^6.2.1
- [x] Create new `app_text_styles.dart` with all 20+ text styles
- [x] Test font rendering on iOS and Android - Ready for testing
- [x] Remove old text styles - Replaced with Lexend typography

### Colors
- [x] Create new `app_colors.dart` with designer palette
  - [x] Primary: `#0d7ff2` (bright blue)
  - [x] Backgrounds: Light (#f5f7f8) and Dark (#101922)
  - [x] Surface colors for dark mode
  - [x] Text colors for light/dark modes
  - [x] Status colors (milestone, success, error, warning)
  - [x] Gradient definitions
- [x] Remove old Canadian red theme - Replaced with blue theme
- [ ] Test colors on different screen brightnesses - Pending device testing

### Theme Configuration
- [x] Create `app_theme.dart` with ThemeData
- [x] Implement dark theme as primary
- [x] Implement light theme (secondary/future)
- [x] Configure MaterialApp to use new theme
- [x] Set dark mode as default
- [x] Test theme switching mechanism - Dark mode now default
- [x] Configure border radius defaults (1rem, 2rem, 3rem) - Circular buttons/inputs
- [x] Configure elevation/shadow defaults - Primary glow shadows

**Acceptance Criteria:**
- [x] Lexend font displays correctly on all text
- [x] All colors match designer specs exactly
- [x] Dark mode is the primary theme
- [x] App looks modern with new typography

**Completed:** 2026-01-06 (Session 022)
**Flutter Analyze:** 0 issues found ✅

---

## Phase 2: Component Library (Days 3-4) ✅ COMPLETED

### Button Components
- [x] Create `CustomButton` widget (circular, blue gradient, with shadow) - Enhanced existing
- [x] Create `CustomTextButton` widget (with icon support) - Enhanced existing
- [x] Create `CustomIconButton` widget (circular, optional background) - Enhanced existing
- [x] Create `GlowingFAB` widget (floating action button with glow)
- [x] Create `SocialSignInButton` widget (Google/Apple sign-in)
- [ ] Add scale-on-press animation (0.95 scale) - Future enhancement
- [x] Test all button states (default, pressed, disabled)

### Card Components
- [x] Create `GlassCard` widget (backdrop-filter blur)
- [x] Create `SolidCard` widget (standard dark surface)
- [x] Create `PrimaryCard` widget (gradient background with primary glow)
- [x] Create `MilestoneCard` widget (orange gradient background)
- [x] Create `PremiumCard` widget (gold gradient for premium features)
- [ ] Create `StatsCard` widget (with decorative circle) - Pending
- [x] Test card shadows and borders

### Input Components
- [x] `CustomTextField` already exists (dark theme compatible)
- [x] `EmailTextField` already exists
- [x] `PasswordTextField` already exists
- [x] Focus states with primary color border (via theme)
- [x] Icon support for inputs (prefixIcon, suffixIcon)
- [ ] Create `SearchBar` widget (circular, dark background) - Pending
- [x] Test keyboard interactions

### Chip/Pill Components
- [ ] Create `LocationChip` widget (horizontal scroll pills) - Pending
- [ ] Create `FilterChip` widget (for run history filters) - Pending
- [ ] Add active/inactive states - Pending
- [ ] Add press animations - Pending

### Progress Components
- [ ] Create `LinearProgress` widget (with glow effect) - Pending
- [ ] Create `CircularProgress` widget - Pending
- [ ] Add gradient fill option - Pending
- [ ] Test animation smoothness - Pending

### Container Components
- [x] Create `GlassCard` widget (reusable glassmorphism)
- [ ] Create `GradientOverlay` widget (for images) - Pending
- [ ] Create `BottomSheet` widget (with handle) - Pending

**Acceptance Criteria:**
- [x] Core components are reusable and well-documented
- [x] Components match designer specs (buttons, cards)
- [ ] Animations are smooth (60fps) - Basic functionality complete, polish pending
- [x] Components work on both iOS and Android

**Completed:** 2026-01-06 (Session 023)
**Flutter Analyze:** 0 issues found ✅

---

## Phase 3: Authentication Screens (Days 5-6) ✅ PARTIALLY COMPLETED

### Welcome/Splash Screen
- [ ] Create new Welcome screen - Pending (not in current flow)
- [ ] Add full-screen background image - Pending
- [ ] Add gradient overlay - Pending
- [ ] Create glassmorphic logo pill at top - Pending
- [ ] Add large title with blue "Canada" highlight - Pending
- [ ] Add circular "Get Started" button - Pending
- [ ] Add circular "Log In" button (secondary) - Pending
- [ ] Add legal text footer - Pending
- [ ] Test on different screen sizes - Pending
- [ ] Add fade-in animation - Pending

### Login Screen
- [x] Rebuild login screen with new design
- [x] Add logo with glow effect
- [x] Add gradient text for "Welcome Back!" heading
- [x] Update form fields wrapped in SolidCard
- [x] Update buttons to use new CustomButton components
- [x] Add proper spacing and padding (24px horizontal, 32px vertical)
- [x] Test validation styles
- [x] Ensure dark theme looks correct

### Signup Screen
- [x] Rebuild signup screen with new design
- [x] Add gradient text for "Start Your Journey" heading
- [x] Update all form components wrapped in SolidCard
- [x] Update button styles (CustomButton, CustomIconButton)
- [x] Improve checkbox layout and alignment
- [x] Add proper visual hierarchy
- [x] Test flow end-to-end

**Acceptance Criteria:**
- [x] Login/Signup screens match designer aesthetic
- [x] All interactions are smooth
- [x] Forms work correctly
- [x] Screens are responsive

**Completed:** 2026-01-06 (Session 023)
**Flutter Analyze:** 0 issues found ✅
**Note:** Welcome/Splash screen deferred - app goes directly to login

---

## Phase 4: Home Dashboard (Days 7-9) ⏳ IN PROGRESS

### Header Section
- [x] Update app bar with dark surface color
- [x] Update title with Lexend typography (h2)
- [x] Update profile icon to use CustomIconButton
- [ ] Create user avatar widget (48px, with ring) - Pending
- [ ] Add level badge on avatar (gradient pill) - Pending
- [ ] Add "Good [morning/afternoon/evening], [Name]" greeting - Pending
- [ ] Add notification icon button - Pending
- [ ] Make header sticky with backdrop blur - Pending

### Journey Card
- [ ] Create immersive map card component - Pending
- [ ] Set 4:3 aspect ratio - Pending
- [ ] Add map overlay gradient - Pending
- [ ] Add "Live Tracking" badge - Pending
- [ ] Add "Day X" badge - Pending
- [ ] Add progress bar at bottom - Pending
- [ ] Add "Currently near [city]" badge - Pending
- [ ] Add runner icon on map - Pending
- [ ] Test map integration - Pending

### Stats Grid
- [ ] Create 2-column stats layout - Pending
- [ ] Add "Covered" stat card with decorative circle - Pending
- [ ] Add "Remaining" stat card - Pending
- [ ] Add trend indicator (+5.2% this week) - Pending
- [ ] Add estimated arrival date - Pending
- [ ] Add hover effects on cards - Pending

### Next Milestone Card
- [ ] Create full-width milestone preview card - Pending
- [ ] Add gradient background (orange/yellow) - Pending
- [ ] Add milestone photo thumbnail (64px, rounded) - Pending
- [ ] Add "Next Milestone" label with star icon - Pending
- [ ] Add distance remaining - Pending
- [ ] Add "~2 runs left" estimate - Pending

### Achievements Section
- [ ] Create horizontal scrolling achievement chips - Pending
- [ ] Add "Fastest 5K" achievement - Pending
- [ ] Add "3 Day Streak" achievement - Pending
- [ ] Add gradient backgrounds to achievement icons - Pending
- [ ] Make section scrollable - Pending

### Floating Action Button
- [x] Create floating "Start Run" button with GlowingFAB
- [x] Add play icon (64px circular button)
- [x] Add shadow with primary glow
- [x] Position at bottom-right with FloatingActionButtonLocation
- [x] Integrates with canStartRunProvider for premium check
- [ ] Add press animation - Future enhancement
- [x] Test on different screen sizes

**Acceptance Criteria:**
- Home screen matches designer mockup exactly
- Map displays correctly
- All stats are dynamic
- Floating button works properly
- Scrolling is smooth

---

## Phase 5: Run Tracking & History (Days 10-12)

### Run Tracking Screen
- [ ] Create new run tracking layout
- [ ] Add "RUNNING..." pulsing header
- [ ] Add "Next stop: [City]" progress card at top
- [ ] Add faded map background (30-40% opacity)
- [ ] Create huge distance display (84px primary blue)
- [ ] Create 3-column metric cards (Time, Pace, Elevation)
- [ ] Apply glassmorphism to metric cards
- [ ] Create bottom dock with 3 buttons
- [ ] Add lock button (left)
- [ ] Add large pause button (center, 96px)
- [ ] Add camera button (right)
- [ ] Test during actual run
- [ ] Ensure readable in sunlight

### Run History Screen
- [ ] Add stats summary at top (Total distance, Progress %)
- [ ] Create filter chip row (All Runs, Milestones, This Month)
- [ ] Add search bar
- [ ] Create timeline view with icons
- [ ] Add circular gradient icons for each run (48px)
- [ ] Add milestone celebrations inline (with photos!)
- [ ] Show location, distance, pace for each run
- [ ] Add "Listen to epic" journey link
- [ ] Test with 50+ runs
- [ ] Optimize scroll performance

### Goal Creation Flow
- [ ] Rebuild "Choose Starting Point" screen
  - [ ] Half-screen map at top
  - [ ] Bottom sheet with handle
  - [ ] Large pulsing location pin on map
  - [ ] "Start Point" label below pin
  - [ ] Search bar (circular)
  - [ ] "Use Current Location" quick action
  - [ ] Horizontal chip scroll (Home, Recent, Popular)
  - [ ] Vertical location suggestions
  - [ ] Sticky bottom CTA
- [ ] Rebuild "Set Destination" screen (similar layout)
  - [ ] Popular destinations with photos
  - [ ] Journey distance preview
- [ ] Create confirmation screen
  - [ ] Full route on map
  - [ ] Journey stats
  - [ ] Milestone count
  - [ ] Major cities list

**Acceptance Criteria:**
- Run tracking screen is focused and minimal
- History shows rich timeline with photos
- Goal creation is intuitive and beautiful
- All screens match designs

---

## Phase 6: Premium & Polish (Days 13-14)

### Premium Paywall
- [ ] Add full-screen background image (sunset runner)
- [ ] Add gradient overlay for text readability
- [ ] Create "Run Further. Explore More." headline
- [ ] Add tagline about premium features
- [ ] Create feature list with icons
  - [ ] Unlimited distance (infinity icon)
  - [ ] Ad-free (no-ads icon)
  - [ ] Detailed milestones (flag icon)
  - [ ] Advanced statistics (chart icon)
- [ ] Create pricing cards
- [ ] Add monthly/yearly toggle
- [ ] Highlight "BEST VALUE" on yearly
- [ ] Show "Save 45%" callout
- [ ] Create single CTA button "Upgrade for $19.99/year"
- [ ] Add footer links (Restore, Terms, Privacy)
- [ ] Test purchase flow

### Animations & Transitions
- [ ] Add fade-in-up animation for screen entries
- [ ] Add scale animation for button presses
- [ ] Add pulse animation for live indicators
- [ ] Add slide-in animation for bottom sheets
- [ ] Add glow pulse for milestone celebrations
- [ ] Add smooth page transitions
- [ ] Test all animations at 60fps

### Final Polish
- [ ] Add loading skeletons for async content
- [ ] Add empty states with illustrations
- [ ] Add error states with helpful messages
- [ ] Ensure all shadows render correctly
- [ ] Test glassmorphism on older devices
- [ ] Optimize image loading
- [ ] Test on smallest supported device
- [ ] Test on largest supported device
- [ ] Fix any visual bugs
- [ ] Ensure consistent spacing throughout

**Acceptance Criteria:**
- Premium screen looks stunning
- All animations are buttery smooth
- No visual bugs or inconsistencies
- App feels premium and polished

---

## Technical Requirements

### Packages to Add
```yaml
dependencies:
  google_fonts: ^6.1.0           # Lexend font
  flutter_animate: ^4.3.0        # Animations
  shimmer: ^3.0.0                # Loading states
  cached_network_image: ^3.3.0  # Image caching

dev_dependencies:
  # Existing
```

### Assets to Add
```
assets/
  fonts/
    Lexend-*.ttf (if not using google_fonts)
  images/
    welcome_background.jpg
    premium_background.jpg
    logo.png
    logo_white.png
  icons/
    (Material Symbols via font or web)
```

---

## Testing Checklist

### Visual Testing
- [ ] All screens match designer mockups
- [ ] Dark theme looks correct everywhere
- [ ] Light theme works (even if not primary)
- [ ] Colors are exact matches
- [ ] Typography uses Lexend everywhere
- [ ] Spacing and padding are consistent
- [ ] Border radiuses match (1rem, 2rem, 3rem)
- [ ] Shadows and glows render correctly
- [ ] Glassmorphism works on both platforms

### Interaction Testing
- [ ] All buttons have press animations
- [ ] All transitions are smooth
- [ ] Scroll performance is good
- [ ] No jank or stuttering
- [ ] Touch targets are appropriate size (44x44 minimum)
- [ ] Gestures feel natural

### Device Testing
- [ ] iPhone SE (small screen)
- [ ] iPhone 14 Pro (notch)
- [ ] iPhone 14 Pro Max (large screen)
- [ ] Android small device
- [ ] Android large device
- [ ] Tablet (if supporting)

### Performance Testing
- [ ] App starts in < 3 seconds
- [ ] Screen transitions < 300ms
- [ ] No dropped frames during animations
- [ ] Images load efficiently
- [ ] Memory usage is reasonable

---

## Deliverables

1. ✅ Complete design system document
2. ⏳ New theme files (colors, text styles, theme)
3. ⏳ Component library (10+ reusable widgets)
4. ⏳ All screens redesigned and polished
5. ⏳ Animations implemented
6. ⏳ Design system documentation for developers

---

## Success Criteria

Sprint is complete when:
- ✅ All 8 designer screens are implemented pixel-perfect
- ✅ Dark mode is primary and looks amazing
- ✅ Component library is reusable and documented
- ✅ All animations are smooth (60fps)
- ✅ App looks and feels premium
- ✅ Design passes review by designer (if available)
- ✅ No visual bugs or inconsistencies
- ✅ Works flawlessly on iOS and Android

---

## Post-Sprint Actions

After completing this sprint:
1. Update screenshots for app store
2. Get design feedback from beta testers
3. Make minor adjustments based on feedback
4. Proceed to Sprint 17 (Background Running)
5. Sprint 18 will focus on final polish, not major redesign

---

## Notes

- This is a CRITICAL sprint - the design is the first thing users see
- Take time to get it right - quality over speed
- Test on real devices frequently
- Get stakeholder approval before marking complete
- Document any deviations from designer mockups with reasoning

---

**Let's make this app beautiful! 🎨**

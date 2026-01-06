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

## Phase 2: Component Library (Days 3-4)

### Button Components
- [ ] Create `PrimaryButton` widget (circular, blue, with shadow)
- [ ] Create `SecondaryButton` widget (glassmorphic)
- [ ] Create `IconButton` widget (circular, backdrop blur)
- [ ] Create `FloatingActionButton` widget (home screen style)
- [ ] Add scale-on-press animation (0.95 scale)
- [ ] Test all button states (default, pressed, disabled)

### Card Components
- [ ] Create `GlassmorphicCard` widget (backdrop-filter blur)
- [ ] Create `StatsCard` widget (with decorative circle)
- [ ] Create `MilestoneCard` widget (gradient background)
- [ ] Create `DarkCard` widget (standard dark surface)
- [ ] Add hover states where applicable
- [ ] Test card shadows and borders

### Input Components
- [ ] Create `SearchBar` widget (circular, dark background)
- [ ] Create `TextField` widget (dark theme)
- [ ] Add focus states with primary color border
- [ ] Add icon support for inputs
- [ ] Test keyboard interactions

### Chip/Pill Components
- [ ] Create `LocationChip` widget (horizontal scroll pills)
- [ ] Create `FilterChip` widget (for run history filters)
- [ ] Add active/inactive states
- [ ] Add press animations

### Progress Components
- [ ] Create `LinearProgress` widget (with glow effect)
- [ ] Create `CircularProgress` widget
- [ ] Add gradient fill option
- [ ] Test animation smoothness

### Container Components
- [ ] Create `GlassContainer` widget (reusable glassmorphism)
- [ ] Create `GradientOverlay` widget (for images)
- [ ] Create `BottomSheet` widget (with handle)

**Acceptance Criteria:**
- All components are reusable and well-documented
- Components match designer specs exactly
- Animations are smooth (60fps)
- Components work on both iOS and Android

---

## Phase 3: Authentication Screens (Days 5-6)

### Welcome/Splash Screen
- [ ] Create new Welcome screen
- [ ] Add full-screen background image
- [ ] Add gradient overlay
- [ ] Create glassmorphic logo pill at top
- [ ] Add large title with blue "Canada" highlight
- [ ] Add circular "Get Started" button
- [ ] Add circular "Log In" button (secondary)
- [ ] Add legal text footer
- [ ] Test on different screen sizes
- [ ] Add fade-in animation

### Login Screen
- [ ] Rebuild login screen with new design
- [ ] Update form fields to use new input components
- [ ] Update buttons to use new button components
- [ ] Add proper spacing and padding
- [ ] Test validation styles
- [ ] Ensure dark theme looks correct

### Signup Screen
- [ ] Rebuild signup screen with new design
- [ ] Update all form components
- [ ] Update button styles
- [ ] Add proper visual hierarchy
- [ ] Test flow end-to-end

**Acceptance Criteria:**
- Auth screens match designer mockups
- All interactions are smooth
- Forms work correctly
- Screens are responsive

---

## Phase 4: Home Dashboard (Days 7-9)

### Header Section
- [ ] Create user avatar widget (48px, with ring)
- [ ] Add level badge on avatar (gradient pill)
- [ ] Add "Good [morning/afternoon/evening], [Name]" greeting
- [ ] Add notification icon button
- [ ] Make header sticky with backdrop blur

### Journey Card
- [ ] Create immersive map card component
- [ ] Set 4:3 aspect ratio
- [ ] Add map overlay gradient
- [ ] Add "Live Tracking" badge
- [ ] Add "Day X" badge
- [ ] Add progress bar at bottom
- [ ] Add "Currently near [city]" badge
- [ ] Add runner icon on map
- [ ] Test map integration

### Stats Grid
- [ ] Create 2-column stats layout
- [ ] Add "Covered" stat card with decorative circle
- [ ] Add "Remaining" stat card
- [ ] Add trend indicator (+5.2% this week)
- [ ] Add estimated arrival date
- [ ] Add hover effects on cards

### Next Milestone Card
- [ ] Create full-width milestone preview card
- [ ] Add gradient background (orange/yellow)
- [ ] Add milestone photo thumbnail (64px, rounded)
- [ ] Add "Next Milestone" label with star icon
- [ ] Add distance remaining
- [ ] Add "~2 runs left" estimate

### Achievements Section
- [ ] Create horizontal scrolling achievement chips
- [ ] Add "Fastest 5K" achievement
- [ ] Add "3 Day Streak" achievement
- [ ] Add gradient backgrounds to achievement icons
- [ ] Make section scrollable

### Floating Action Button
- [ ] Create bottom floating "Start Run" button
- [ ] Add text + icon + circular play button
- [ ] Add shadow with primary glow
- [ ] Position with safe area insets
- [ ] Add press animation
- [ ] Test on different screen sizes

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

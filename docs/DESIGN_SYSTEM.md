# Run to Canada - Complete Design System
## Extracted from Designer's Mockups

**Last Updated:** January 5, 2026
**Source:** stitch_welcome_to_run_to_canada folder
**Status:** Master Design Reference

---

## 🎨 Color Palette

### Primary Colors
```dart
primary: #0d7ff2              // Bright Blue - main brand color
primaryDark: #0a66c2          // Darker blue for hover states
primaryLight: #3d99ff         // Lighter blue for accents
```

### Background Colors
```dart
backgroundLight: #f5f7f8      // Light mode background
backgroundDark: #101922       // Dark mode primary background
surfaceDark: #1c2a38          // Dark mode secondary surface
cardDark: #182430             // Dark mode card background
surfaceInput: #223649         // Dark mode input fields
```

### Text Colors
```dart
// Light Mode
textPrimary: #111418
textSecondary: #637588
textHint: #90adcb

// Dark Mode
textPrimaryDark: #ffffff
textSecondaryDark: #90adcb
textHintDark: #637588
```

### Status/Accent Colors
```dart
milestone: #FFA500            // Warm orange for milestones
milestoneGradientStart: #ff6b35
milestoneGradientEnd: #ffa500

success: #4CAF50
error: #F44336
warning: #FFC107

// Gradients
userLevelGradient: from-yellow-400 to-orange-600
achievementPurple: from-purple-500 to-indigo-600
achievementOrange: from-orange-400 to-red-500
```

### Shadow Colors
```dart
glow: 0 0 20px -5px rgba(13, 127, 242, 0.5)        // Primary glow
glowOrange: 0 0 20px -5px rgba(255, 165, 0, 0.5)   // Milestone glow
shadowPrimary: 0 8px 30px rgba(13, 127, 242, 0.4)  // Button shadow
shadowXL: 0 20px 25px -5px rgba(0, 0, 0, 0.1)
```

---

## 📝 Typography

### Font Family
```
Primary Font: Lexend (weights: 100-900)
Fallback: sans-serif
```

**Import:**
```html
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@100..900&display=swap" rel="stylesheet"/>
```

### Font Scales

#### Display (Large Headings)
- **Display XL**: 84px, Bold, -0.04em tracking
- **Display Large**: 48px, Bold, -0.02em tracking
- **Display Medium**: 32px, Bold, -0.015em tracking
- **Display Small**: 26px, Bold, -0.015em tracking

#### Headings
- **H1**: 24px, Bold
- **H2**: 22px, SemiBold (600)
- **H3**: 20px, SemiBold (600)
- **H4**: 18px, SemiBold (600)

#### Body Text
- **Body Large**: 16px, Regular (400)
- **Body Medium**: 14px, Regular (400)
- **Body Small**: 12px, Regular (400)

#### Labels & UI
- **Label Large**: 14px, Medium (500)
- **Label Medium**: 12px, Medium (500)
- **Label Small**: 10px, Medium (500)
- **Caption**: 12px, Regular
- **Overline**: 10px, Medium, UPPERCASE, 1.5px letter-spacing

#### Special Purpose
- **Button Text**: 16-18px, Bold (700), 0.5px tracking
- **Stats Large**: 84px, Bold, tabular-nums
- **Stats Medium**: 32px, Bold, tabular-nums
- **Stats Small**: 20px, Bold, tabular-nums

---

## 🔲 Border Radius

```dart
DEFAULT: 1rem (16px)
lg: 2rem (32px)
xl: 3rem (48px)
full: 9999px (circular)
```

**Usage Examples:**
- Cards: 1-2rem
- Buttons: full (circular)
- Input fields: full (circular)
- Bottom sheets: 1-1.5rem top corners only

---

## 🎯 Icons

### Icon System
**Material Symbols Outlined**
```html
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
```

### Icon Sizes
- Small: 18px
- Medium: 20-24px
- Large: 28px
- XLarge: 48px

### Common Icons Used
```
directions_run    - Running/activity
flag             - Milestones/goals
location_on      - Location marker
my_location      - Current location
search           - Search functionality
notifications    - Notifications
timer            - Time tracking
speed            - Pace/speed
landscape        - Elevation
pause            - Pause action
play_arrow       - Start/resume
lock_open        - Screen lock
photo_camera     - Camera/screenshot
arrow_forward    - Next/continue
arrow_back_ios_new - Back navigation
trending_up      - Progress/statistics
local_fire_department - Streaks
bolt             - Achievements
hotel_class      - Stars/premium
near_me          - GPS/location
chevron_right    - List item navigation
```

---

## 🎴 Components

### 1. Buttons

#### Primary Button (Floating Action)
```dart
Height: 56px (14rem)
Width: Full width or max-width: 360px
Background: primary (#0d7ff2)
Hover: #0a66c2
Text: White, 18px, Bold
Border Radius: full (circular)
Shadow: 0 8px 30px rgba(13, 127, 242, 0.4)
Active State: scale(0.95)
```

#### Secondary Button
```dart
Height: 56px
Background: white/10 with backdrop-blur
Border: 1px solid white/10
Text: White, 16px, SemiBold
Hover: white/20
```

#### Icon Button
```dart
Size: 48-56px square
Background: surface-dark/90 with backdrop-blur
Border: 1px solid white/10
Icon: 24px
Border Radius: full
Active: scale(0.95)
```

### 2. Cards

#### Standard Card (Dark Mode)
```dart
Background: #182430 (cardDark)
Border: 1px solid white/5
Border Radius: 2rem (32px)
Padding: 1.25rem (20px)
Shadow: subtle (0 2px 8px rgba(0,0,0,0.1))
```

#### Glassmorphic Card
```dart
Background: white/80 or #223649/80 (dark)
Backdrop Filter: blur(12px)
Border: 1px solid white/20
Border Radius: 2rem
```

#### Stats Card
```dart
Width: Half grid (2 columns)
Height: 144px (36rem)
Background: cardDark with decorative circle
Padding: 1.25rem
Border Radius: 2rem
Hover: Decorative circle expands (opacity change)
```

#### Milestone Card (Highlighted)
```dart
Background: Gradient from orange/yellow
Border: 1px solid orange/20
Border Radius: 2rem
Contains: Image thumbnail (64px), title, distance info
```

### 3. Inputs

#### Search Bar
```dart
Height: 56px
Background: #223649 (surfaceInput)
Border: 1px solid white/5
Focus Border: primary/50
Border Radius: full (circular)
Placeholder: #90adcb
Text: White, 16px
Icon: Left side, 20px
```

#### Text Field
```dart
Similar to search but rectangular
Border Radius: 1rem
```

### 4. Navigation

#### Top Header
```dart
Background: Gradient from-black/60 to-transparent
Height: Auto (safe area + content)
Items: Back button, Title (center), Action buttons
Back Button: 48px, circular, black/20 backdrop-blur
```

#### Bottom Navigation
```dart
Height: 64px + safe-area-bottom
Background: backgroundDark
Border Top: 1px solid white/5
Icons: 24px
Labels: 10px, Medium
Active Color: primary
```

#### Floating Action Button (Home Screen)
```dart
Width: Full width (max 360px)
Height: 64px
Background: primary with gradient
Border Radius: full
Shadow: shadow-xl shadow-primary/40
Position: Fixed bottom with safe area
Contains: Text + Icon + Circular play button (48px white bg)
```

### 5. Map Components

#### Map Container
```dart
Aspect Ratio: 4:3 or 50vh
Border Radius: 2rem
Overflow: hidden
Ring: 1px white/10
Filter: brightness(0.6) contrast(1.2) hue-rotate(200deg) for dark theme
```

#### Map Overlay Badges
```dart
Background: black/40 backdrop-blur-md
Border: 1px solid white/10
Border Radius: 0.5rem (8px)
Padding: 6px 12px
Text: 12px, Medium, White
```

#### Location Marker
```dart
Icon: location_on, 40-48px
Color: primary
Glow Effect: Pulsing background circle (primary/30)
Label: White background, primary text, rounded-full
```

### 6. Progress Bars

#### Linear Progress (Journey)
```dart
Height: 6px (1.5rem)
Background: white/20 or #314d68
Fill: Gradient from primary to cyan-400
Border Radius: full
Glow: 0 0 10px rgba(13, 127, 242, 0.8)
```

#### Circular Progress
```dart
Size: Variable
Stroke Width: 6-8px
Color: primary
Background: white/10
```

### 7. Chips/Pills

#### Location Chip
```dart
Height: Auto (2.5rem padding)
Background: #223649 (surfaceInput)
Border: 1px solid white/5 (or primary/30 for active)
Border Radius: full
Padding: 10px 16px (pl-12px pr-16px)
Icon: 18px on left
Text: 14px, Medium
Active: scale(0.95)
```

### 8. Lists

#### Timeline Item (Run History)
```dart
Icon: Circle (48px) with activity icon
Background: Gradient background for icon
Content: Title + subtitle + metadata
Distance Info: Right side
Border Bottom: 1px solid white/5
Padding: 16px
```

#### Milestone Item
```dart
Photo: 64-80px rounded-xl
Badge: Orange star icon
Text: Bold white title
Metadata: Distance, date
Background: Gradient from milestone color
```

---

## 🎭 Special Effects

### Glassmorphism
```css
background: rgba(255, 255, 255, 0.1);
backdrop-filter: blur(12px);
border: 1px solid rgba(255, 255, 255, 0.2);
```

### Glow Effects
```css
/* Primary Glow */
box-shadow: 0 0 20px -5px rgba(13, 127, 242, 0.5);

/* Milestone Glow */
box-shadow: 0 0 20px -5px rgba(255, 165, 0, 0.5);

/* Button Shadow */
box-shadow: 0 8px 30px rgba(13, 127, 242, 0.4);
```

### Pulsing Animation
```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
```

### Scale on Active
```css
transition: transform 0.2s;
active:scale-95  /* 95% on press */
```

### Backdrop Blur
```css
backdrop-filter: blur(12px);
-webkit-backdrop-filter: blur(12px);
```

---

## 📐 Layout Patterns

### Screen Structure (Standard)
```
┌─────────────────────────────┐
│ Header (SafeArea + Nav)     │ ← Gradient or transparent
├─────────────────────────────┤
│                             │
│ Scrollable Content          │ ← Padding: 1.5rem (24px)
│ (Cards, Lists, etc)         │
│                             │
│                             │
├─────────────────────────────┤
│ Floating Button / Nav       │ ← Fixed bottom with safe area
└─────────────────────────────┘
```

### Grid System
- **2-Column Stats**: Equal width cards with gap-4 (16px)
- **3-Column Metrics**: Equal thirds with gap-3 (12px)
- **Horizontal Scroll**: Flex with gap-3, overflow-x-auto, no-scrollbar

### Spacing Scale
```
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
2xl: 48px
```

### Safe Areas
Always account for:
- Top notch/status bar
- Bottom home indicator
- Use: `pt-safe`, `pb-safe`

---

## 🖼️ Image Styling

### Profile Pictures
```dart
Size: 48px
Border Radius: full (circular)
Ring: 2px solid primary
Ring Offset: 2px (background color)
```

### Milestone Photos
```dart
Size: 64px
Border Radius: xl (1rem or 0.75rem)
Ring: 2px solid milestone/20
Object Fit: cover
```

### Background Images
```dart
Overlay: Gradient from-background-dark via-background-dark/60 to-transparent
Opacity: 0.6-0.8
Filter: brightness(0.6) contrast(1.2) for maps
```

---

## 🎬 Animations

### Transitions
```
Default Duration: 200ms
Easing: cubic-bezier(0.4, 0, 0.2, 1)
```

### Common Animations
1. **Fade In Up**: Content entry (translate-y + opacity)
2. **Scale Active**: Button press (scale 0.95)
3. **Pulse**: Live indicators (opacity cycle)
4. **Slide In**: Bottom sheet entry
5. **Glow Pulse**: Milestone celebrations

---

## 📱 Screen-Specific Components

### Welcome Screen
- Full-screen background image with gradient overlay
- Logo in glassmorphic pill (bg-white/10, backdrop-blur)
- Large title with `<span class="text-primary">Canada</span>`
- Full-width circular buttons
- Legal text: 10px, slate-400

### Home Dashboard
- Header: Avatar (48px) + greeting + notification icon
- Journey header: Icon + "Current Journey" + Title
- Map card: 4:3 aspect ratio, rounded-2xl, with overlay badges
- Stats grid: 2 columns
- Milestone card: Full width, gradient background
- Achievement carousel: Horizontal scroll
- Floating "Start Run" button

### Run Tracking
- Status header: Signal icon + "RUNNING..." (pulsing)
- Next milestone card with progress bar
- Background: Faded map (opacity 30-40%)
- Huge distance number: 84px primary color
- 3-column metric cards (glassmorphic)
- Bottom dock: 3 buttons (secondary, primary large, secondary)

### Run History
- Stats summary cards at top
- Filter chips: All/Milestones/This Month
- Search bar
- Timeline with icons (48px circles with gradients)
- Milestone celebrations mixed in with photos
- Bottom nav bar

### Goal Creation
- Half-screen map at top
- Bottom sheet with handle
- Search bar (circular)
- "Use Current Location" quick action
- Horizontal chip scroll for recent/popular
- Sticky bottom CTA button

### Premium Paywall
- Full-screen background image (sunset runner)
- Gradient overlay for readability
- Title: "Run Further. Explore More."
- Feature list with icons (infinity, ad-free, flag, chart icons)
- Pricing cards with toggle highlight
- Single CTA: "Upgrade for $19.99/year"
- Footer links: Restore, Terms, Privacy

---

## 🎨 Dark Mode Implementation

**Default Mode:** Dark
**Light Mode:** Optional/future

### Dark Mode Colors
```dart
background: #101922
surface: #182430
input: #223649
text: #ffffff
textSecondary: #90adcb
border: white/5
divider: white/5
overlay: black/60
```

### Dark Mode Adjustments
- All cards: Semi-transparent with backdrop-blur
- Borders: Use white/5 or white/10
- Icons: Lighter shades in dark mode
- Shadows: Darker, more subtle
- Images: May need brightness/contrast filters

---

## 📦 Asset Requirements

### Images Needed
1. **Welcome Screen Background**: Scenic mountain road runner (high-res)
2. **Premium Background**: Sunset runner silhouette (high-res)
3. **Milestone Photos**: City landmarks (Ottawa, Montreal, Vancouver, etc.)
4. **App Logo**: Simple icon + wordmark
5. **Achievement Icons**: Badge graphics for gamification

### Icon Font
Material Symbols Outlined (already specified)

### Fonts to Download
Lexend (Variable font or weights 100-900)

---

## 🚀 Implementation Priority

### Phase 1: Foundation (Week 1)
1. ✅ Add Lexend font to Flutter project
2. ✅ Create new color constants file
3. ✅ Create new text styles file
4. ✅ Implement dark theme
5. ✅ Create base component widgets (buttons, cards, inputs)

### Phase 2: Core Screens (Week 2-3)
1. ✅ Welcome/Onboarding screen
2. ✅ Home Dashboard (with map)
3. ✅ Run Tracking screen
4. ✅ Goal Creation flow

### Phase 3: Secondary Screens (Week 4)
1. ✅ Run History
2. ✅ Premium Paywall
3. ✅ Profile/Settings
4. ✅ Milestone celebrations

### Phase 4: Polish (Week 5)
1. ✅ Animations and transitions
2. ✅ Glassmorphism effects
3. ✅ Micro-interactions
4. ✅ Loading states

---

## 📋 Flutter Package Requirements

```yaml
dependencies:
  # Existing
  flutter_riverpod: ^2.4.0

  # New for design system
  google_fonts: ^6.1.0          # For Lexend font
  flutter_svg: ^2.0.9           # For SVG icons if needed
  shimmer: ^3.0.0               # Loading skeletons
  flutter_animate: ^4.3.0       # Smooth animations
  glassmorphism: ^3.0.0         # Glassmorphic effects

  # Icons (if not using Material Symbols via font)
  # We'll use Material Symbols via web font or create custom IconData
```

---

## 🎯 Success Criteria

Design implementation is complete when:
- ✅ All screens match designer mockups pixel-perfect
- ✅ Dark mode is primary mode
- ✅ All colors from design system are used
- ✅ Lexend font is applied throughout
- ✅ All animations are smooth (60fps)
- ✅ Glassmorphism effects work correctly
- ✅ Map integration looks polished
- ✅ Component library is reusable
- ✅ Responsive on all iOS/Android devices

---

**End of Design System Document**

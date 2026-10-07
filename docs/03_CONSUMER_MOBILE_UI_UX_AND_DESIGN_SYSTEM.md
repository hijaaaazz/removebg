# 03. Consumer Mobile UI/UX & Studio Design System

## 1. Visual Identity & Creative Studio Theme

The **RemoveIt** visual aesthetic is engineered to deliver a state-of-the-art, professional creative studio environment. It eschews generic light-mode utility aesthetics in favor of a sleek, dark-first obsidian workspace with luminous neon accents that make cutout photos pop with vibrant contrast.

### Curated Color Palette Tokens

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ Obsidian Dark Core: #090C10 (Background)   │ Slate Surface: #131822 (Cards) │
│ Cosmic Violet:      #7C3AED (Primary Glow)  │ Electric Cyan: #06B6D4 (Accent)│
│ Pure White:         #FFFFFF (Text High)     │ Slate Gray:    #94A3B8 (Muted) │
│ Success Emerald:    #10B981 (Complete)      │ Warning Amber: #F59E0B (Quota) │
└─────────────────────────────────────────────────────────────────────────────┘
```

| Token Name | Hex Code | Purpose in RemoveIt UI |
| :--- | :--- | :--- |
| `backgroundDark` | `#090C10` | Root scaffold background, infinite studio backdrop |
| `surfaceDark` | `#131822` | Card backgrounds, elevated sheets, toolbars |
| `surfaceBorder` | `#1E293B` | Subtle 1px borders with 50% opacity |
| `primaryViolet` | `#7C3AED` | Primary call-to-action buttons, glow halos |
| `accentCyan` | `#06B6D4` | Slider indicators, tool active indicators, selection rings |
| `proGold` | `#F59E0B` | Pro badges, crown icons, upgrade banners |
| `checkerboardLight` | `#2D3748` | Checkerboard transparency indicator light square |
| `checkerboardDark` | `#1A202C` | Checkerboard transparency indicator dark square |

---

## 2. Ergonomics & The "Thumb Zone" Architecture

Mobile photo editors require intense single-handed interaction. Placing critical controls (like "Remove Background", "Compare", "Export", or "Change Backdrop") at the top of a modern 6.7" smartphone causes acute thumb strain.

RemoveIt strictly implements **Bottom-Up Thumb-Zone Ergonomics**:

```
+---------------------------------------------+
| [ Top Bar: Minimal ]                        |
|  - Back arrow / Close                       |
|  - Quota indicator pill (Tap to view info)  |
|  - Undo / Redo / Reset                      |
+---------------------------------------------+
|                                             |
|                                             |
|              STUDIO CANVAS                  |
|        (Full-Screen Pinch & Pan)            |
|                                             |
|                                             |
+---------------------------------------------+
| [ Floating Action Strip (Easy Reach) ]      |
|   ( 🌓 Split Slider | 🎨 Backdrop | 🔍 Zoom )|
+---------------------------------------------+
| [ Bottom Control Hub ]                      |
|  - Primary Action: [ Save Clean PNG (HD) ]  |
|  - Tool Selectors (Color / Blur / Image)    |
|  - Sticky Banner Ad (Collapsible)           |
+---------------------------------------------+
```

### Ergonomic Guidelines:
1. **Never use center dialogs for primary flows.** Use modal bottom sheets (`StudioBottomSheet`) that slide up smoothly from the bottom thumb zone.
2. **Action Prominence:** The primary action button (`GlowButton`) spans the full width of the bottom safe area with a minimum tap target height of `56px`.
3. **Floating Toolbar Pill:** Floating tool strips sit `24px` above the bottom bar, anchored within natural thumb radius.

---

## 3. Tactile Haptic Feedback Matrix

Haptic feedback is integral to modern premium mobile apps. It transforms static touchscreens into responsive physical tools:

| User Action | Haptic Intensity | Platform API Call |
| :--- | :--- | :--- |
| **Slider drags across center (50%)** | Subtle tick | `HapticFeedback.selectionClick()` |
| **Tapping tool selector / backdrop chip** | Light impact | `HapticFeedback.lightImpact()` |
| **AI Processing Completed** | Medium impact | `HapticFeedback.mediumImpact()` |
| **File successfully saved to Gallery** | Success vibration | `HapticFeedback.heavyImpact()` |
| **Quota exhausted / limit alert** | Warning vibration | Double subtle pulse |

```dart
// lib/core/services/haptic_service.dart
import 'package:flutter/services.dart';

class HapticService {
  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void heavy() => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();
  
  static Future<void> successPattern() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
}
```

---

## 4. Interactive Before/After Split Slider Canvas

The centerpiece of the RemoveIt experience is the interactive **Split Comparison Canvas**:

```
┌──────────────────────────────────────────────┐
│                  Original                    │
│                 Background                   │
│                      │                       │
│                      │   Isolated Subject    │
│                      │    (Transparent /     │
│                      │     New Backdrop)     │
│                      │                       │
│                    [ ◄► ] ◄── Interactive    │
│                      │        Divider Thumb  │
│                      │                       │
└──────────────────────┴───────────────────────┘
```

### Canvas Technical Requirements:
1. **Zero-Latency Dragging:** The slider position (`0.0` to `1.0`) is driven by a localized `ValueNotifier<double>` or gesture detector to achieve a silky 120Hz refresh without triggering full-screen widget rebuilds.
2. **Double-Tap Reset:** Double-tapping anywhere on the canvas automatically animates the slider back to the exact center (`0.5`) using an elastic spring curve (`Curves.easeOutBack`).
3. **Pinch-to-Zoom & Pan:** Wrapped in an `InteractiveViewer` with `minScale: 1.0` and `maxScale: 5.0` so users can inspect edge segmentation accuracy around hair strands and complex silhouettes.

---

## 5. Micro-Animations & Motion Design

Static interfaces feel robotic; spring physics create delight:
- **Hero Image Transitions:** When a photo is selected from the camera roll, it smoothly transitions into the Studio Canvas via a custom `Hero` animation.
- **AI Processing Pulse:** While waiting for BiRefNet inference (1.5s–3s), the original image displays an animated ambient neon scanline sweeping from top to bottom, paired with a glowing radial shimmer.
- **Quota Counter Dial:** The daily quota badge animates smoothly with an eased sweep animation when decremented.

---

## 6. Responsive Breakpoints: Foldables & Tablets

While optimized for handheld phones, RemoveIt natively adapts to foldables (e.g. Galaxy Z Fold) and iPads:

```
+---------------------------------------------------------------------------------+
|                                Tablet / Desktop Mode                            |
+---------------------------------------+-----------------------------------------+
|                                       | [ Right Studio Control Panel ]          |
|                                       |  - Mode: Transparent / Solid / Blur    |
|            STUDIO CANVAS              |  - Backdrop Color Grid (Hex + Swatches) |
|         (Large Viewport)              |  - Export Resolution: 1080p vs 4K Native|
|                                       |  - Quota & Pro Status Card              |
|                                       |  - Primary [ Save to Camera Roll ]      |
+---------------------------------------+-----------------------------------------+
```

- **Width < 600px (Phones):** Single-column vertical layout with bottom tool sheets.
- **Width >= 600px (Foldables & Tablets):** Two-column split layout. The canvas occupies 65% of the viewport on the left, while the tool drawer sits pinned on the right.

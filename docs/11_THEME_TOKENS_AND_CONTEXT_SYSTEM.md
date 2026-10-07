# 11. Centralized Theme, Design Tokens & Context Extensions

To ensure visual harmony, accessible contrast ratios, and developer velocity, **RemoveIt** enforces a **Layered Context-Driven Design System**.

---

## 1. The Architectural Hierarchy

```
+-----------------------------------------------------------------------------------------+
| Layer 1: Single Source of Truth (Root ThemeData & StudioThemeExtension)                |
|          - AppColors, AppTypography, ColorScheme, StudioThemeExtension                  |
+-----------------------------------------------------------------------------------------+
                                          ▼
+-----------------------------------------------------------------------------------------+
| Layer 2: Ergonomic Access Layer (BuildContext Extensions)                               |
|          - context.colors, context.studioTheme, context.textTheme, context.isPro       |
+-----------------------------------------------------------------------------------------+
                                          ▼
+-----------------------------------------------------------------------------------------+
| Layer 3: Reusable Studio Components (StudioScaffold, GlowButton, ComparisonSlider)       |
+-----------------------------------------------------------------------------------------+
```

---

## 2. Comparative Evaluation Matrix

| Pattern | Verdict | Why / Best Practices | Common Anti-Patterns to Avoid |
| :--- | :--- | :--- | :--- |
| **Root Styles (`ThemeData`)** | **MANDATORY** | Single source of truth. System dialogs, context menus, and scrollbars inherit themes automatically. | Defining styles only at widget level, causing unstyled system dialogs. |
| **`ThemeExtension`** | **MANDATORY** | Allows declaring custom studio tokens (neon glow colors, checkerboard tiles) with full lerp support. | Hardcoding raw hex values inside feature screen files. |
| **`BuildContext` Extensions** | **RECOMMENDED** | Type-safe, ergonomic access. Replaces verbose `Theme.of(context).extension<StudioThemeExtension>()` with `context.studioTheme`. | Placing business logic or network calls inside context extensions. |
| **Common Composed Widgets** | **RECOMMENDED** | Enforces consistent haptics, border radii, and visual hierarchies across all features. | Creating monolithic widgets with 30 boolean flags. |
| **Generic `AppText` Wrapper** | **ANTI-PATTERN** | Obscures native Flutter `Text` parameters (`overflow`, `maxLines`, `semanticsLabel`) and breaks `SelectableText`. | Wrapping Flutter `Text` in custom classes instead of using `Text('...', style: context.textTheme.headlineMedium)`. |

---

## 3. Concrete Implementation

### 3.1 Custom `StudioThemeExtension`
```dart
// lib/core/theme/studio_theme_extension.dart
import 'package:flutter/material.dart';

@immutable
class StudioThemeExtension extends ThemeExtension<StudioThemeExtension> {
  final Color backgroundDark;
  final Color surfaceDark;
  final Color surfaceBorder;
  final Color primaryViolet;
  final Color accentCyan;
  final Color proGold;
  final Color checkerboardLight;
  final Color checkerboardDark;

  const StudioThemeExtension({
    required this.backgroundDark,
    required this.surfaceDark,
    required this.surfaceBorder,
    required this.primaryViolet,
    required this.accentCyan,
    required this.proGold,
    required this.checkerboardLight,
    required this.checkerboardDark,
  });

  @override
  StudioThemeExtension copyWith({
    Color? backgroundDark,
    Color? surfaceDark,
    Color? surfaceBorder,
    Color? primaryViolet,
    Color? accentCyan,
    Color? proGold,
    Color? checkerboardLight,
    Color? checkerboardDark,
  }) {
    return StudioThemeExtension(
      backgroundDark: backgroundDark ?? this.backgroundDark,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      primaryViolet: primaryViolet ?? this.primaryViolet,
      accentCyan: accentCyan ?? this.accentCyan,
      proGold: proGold ?? this.proGold,
      checkerboardLight: checkerboardLight ?? this.checkerboardLight,
      checkerboardDark: checkerboardDark ?? this.checkerboardDark,
    );
  }

  @override
  StudioThemeExtension lerp(ThemeExtension<StudioThemeExtension>? other, double t) {
    if (other is! StudioThemeExtension) return this;
    return StudioThemeExtension(
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      primaryViolet: Color.lerp(primaryViolet, other.primaryViolet, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      proGold: Color.lerp(proGold, other.proGold, t)!,
      checkerboardLight: Color.lerp(checkerboardLight, other.checkerboardLight, t)!,
      checkerboardDark: Color.lerp(checkerboardDark, other.checkerboardDark, t)!,
    );
  }
}
```

---

### 3.2 Ergonomic `BuildContext` Extensions
```dart
// lib/core/utils/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/studio_theme_extension.dart';

extension StudioContextExtensions on BuildContext {
  /// Fast access to Studio Theme Extension
  StudioThemeExtension get studioTheme =>
      Theme.of(this).extension<StudioThemeExtension>()!;

  /// Fast access to standard ColorScheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Fast access to TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Responsive layout helpers
  bool get isTablet => MediaQuery.of(this).size.width >= 600;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
```

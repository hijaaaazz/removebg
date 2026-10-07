# 10. Global Common Widgets & Studio Design Catalog

To maintain visual excellence, avoid UI code duplication, and ensure strict dark theme consistency, **RemoveIt strictly forbids writing ad-hoc, unstyled raw Flutter primitives in feature screens**.

Developers must never instantiate raw unstyled `ElevatedButton`, raw `Container` dialogs, or un-padded scaffolds inside feature presentation code. All screens must be assembled using the centralized **Common Component Library** located in `lib/core/widgets/`.

---

## 1. Directory Structure of Common Widgets

```
lib/core/widgets/
├── buttons/                          # Action controls & tactile buttons
│   ├── glow_button.dart              # Radiant violet/cyan primary CTA button with loading state
│   ├── glass_button.dart             # Frosted glass secondary button with subtle border
│   └── studio_icon_button.dart       # Circular icon button with haptic feedback
│
├── canvas/                           # Studio editor & comparison components
│   ├── comparison_slider.dart        # Interactive before/after split wipe slider
│   ├── zoomable_canvas.dart          # Matrix4 pinch-to-zoom & pan canvas wrapper
│   └── backdrop_selector_bar.dart    # Horizontal scrollable palette & backdrop preset picker
│
├── feedback/                         # Alerts, loaders & dialogs
│   ├── studio_loading_overlay.dart   # Ambient neon scanning line for AI inference
│   ├── studio_toast.dart             # Custom floating notification pill (Success/Warning)
│   └── studio_shimmer.dart           # Skeleton shimmer for loading states
│
├── layout/                           # Screen scaffolding & containers
│   ├── studio_scaffold.dart          # Root scaffold with obsidian gradient & safe area
│   ├── studio_glass_card.dart        # Frosted glass container with 1px border
│   └── studio_app_bar.dart           # Minimal header with quota pill & back action
│
└── monetization/                     # Ad & subscription components
    ├── ad_banner_container.dart      # Adaptive AdMob banner slot with smooth collapse
    ├── quota_pill_badge.dart         # Floating header pill displaying remaining quota
    └── pro_crown_badge.dart          # Radiant gold metallic badge for Pro features
```

---

## 2. Widget Specifications & Code Contracts

### 2.1 `StudioScaffold` (Root Screen Foundation)
Provides a consistent obsidian background gradient, handles safe area padding, and manages floating bottom bars:

```dart
// lib/core/widgets/layout/studio_scaffold.dart
import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class StudioScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  const StudioScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F141C),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          top: !extendBodyBehindAppBar,
          bottom: bottomNavigationBar == null,
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
```

---

### 2.2 `GlowButton` (Primary Call-to-Action)
The high-conversion button for "Remove Background", "Save Clean PNG", and "Upgrade to Pro":

```dart
// lib/core/widgets/buttons/glow_button.dart
import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

enum GlowButtonVariant { primaryViolet, accentCyan, proGold }

class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final GlowButtonVariant variant;

  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = GlowButtonVariant.primaryViolet,
  });

  @override
  Widget build(BuildContext context) {
    final (baseColor, glowColor) = switch (variant) {
      GlowButtonVariant.primaryViolet => (AppColors.primaryViolet, const Color(0x667C3AED)),
      GlowButtonVariant.accentCyan => (AppColors.accentCyan, const Color(0x6606B6D4)),
      GlowButtonVariant.proGold => (AppColors.proGold, const Color(0x66F59E0B)),
    };

    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null || isLoading
            ? []
            : [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseColor,
          disabledBackgroundColor: baseColor.withOpacity(0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: isLoading || onPressed == null
            ? null
            : () {
                HapticService.light();
                onPressed!();
              },
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                ],
              ),
      ),
    );
  }
}
```

---

### 2.3 `QuotaPillBadge` (Header Balance Pill)
Displays daily quota balance in the top app bar and triggers the quota bottom sheet on tap:

```dart
// lib/core/widgets/monetization/quota_pill_badge.dart
import 'package:flutter/material.dart';
import 'package:removeit_app/core/services/haptic_service.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

class QuotaPillBadge extends StatelessWidget {
  final int remaining;
  final bool isPro;
  final VoidCallback onTap;

  const QuotaPillBadge({
    super.key,
    required this.remaining,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPro ? AppColors.proGold.withOpacity(0.15) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.Border.all(
            color: isPro ? AppColors.proGold.withOpacity(0.4) : AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPro ? Icons.workspace_premium_rounded : Icons.flash_on_rounded,
              color: isPro ? AppColors.proGold : (remaining > 0 ? AppColors.accentCyan : AppColors.warningAmber),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isPro ? "PRO" : "$remaining Left",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPro ? AppColors.proGold : (remaining > 0 ? Colors.white : AppColors.warningAmber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 2.4 `AdBannerContainer` (Collapsible Adaptive Banner)
Ensures smooth banner rendering without layout shift. Automatically hides if ads are disabled or user is Pro:

```dart
// lib/core/widgets/monetization/ad_banner_container.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerContainer extends StatelessWidget {
  final BannerAd? bannerAd;
  final bool isVisible;

  const AdBannerContainer({
    super.key,
    required this.bannerAd,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: AdWidget(ad: bannerAd!),
    );
  }
}
```

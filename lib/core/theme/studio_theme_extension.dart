import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';

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

  static const defaultDark = StudioThemeExtension(
    backgroundDark: AppColors.backgroundDark,
    surfaceDark: AppColors.surfaceDark,
    surfaceBorder: AppColors.surfaceBorder,
    primaryViolet: AppColors.primaryViolet,
    accentCyan: AppColors.accentCyan,
    proGold: AppColors.proGold,
    checkerboardLight: AppColors.checkerboardLight,
    checkerboardDark: AppColors.checkerboardDark,
  );

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

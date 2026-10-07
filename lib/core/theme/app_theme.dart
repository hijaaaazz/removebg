import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/app_colors.dart';
import 'package:removeit_app/core/theme/app_typography.dart';
import 'package:removeit_app/core/theme/studio_theme_extension.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryViolet,
      secondary: AppColors.accentCyan,
      surface: AppColors.surfaceDark,
      error: AppColors.errorRose,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
    ),
    textTheme: AppTypography.textThemeDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
      ),
    ),
    extensions: const [
      StudioThemeExtension.defaultDark,
    ],
  );
}

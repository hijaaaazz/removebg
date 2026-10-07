import 'package:flutter/material.dart';
import 'package:removeit_app/core/theme/studio_theme_extension.dart';

extension StudioContextExtensions on BuildContext {
  /// Fast access to Studio Theme Extension
  StudioThemeExtension get studioTheme =>
      Theme.of(this).extension<StudioThemeExtension>() ?? StudioThemeExtension.defaultDark;

  /// Fast access to standard ColorScheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Fast access to TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Responsive helpers
  bool get isTablet => MediaQuery.of(this).size.width >= 600;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

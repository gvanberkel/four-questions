import 'package:flutter/material.dart';

TextTheme buildActionTextTheme(
  ColorScheme scheme, {
  String? fontFamily,
  String? headingFontFamily,
}) {
  TextStyle style(
    double size,
    FontWeight weight, {
    double height = 1.4,
    bool heading = false,
  }) {
    return TextStyle(
      fontFamily: heading ? (headingFontFamily ?? fontFamily) : fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: scheme.onSurface,
    );
  }

  return TextTheme(
    displaySmall: style(36, FontWeight.w700, height: 1.2, heading: true),
    headlineLarge: style(32, FontWeight.w700, height: 1.25, heading: true),
    headlineMedium: style(28, FontWeight.w700, height: 1.25, heading: true),
    headlineSmall: style(24, FontWeight.w700, height: 1.3, heading: true),
    titleLarge: style(20, FontWeight.w700, height: 1.3, heading: true),
    titleMedium: style(16, FontWeight.w600, heading: true),
    titleSmall: style(14, FontWeight.w600, heading: true),
    bodyLarge: style(16, FontWeight.w400, height: 1.6),
    bodyMedium: style(15, FontWeight.w400, height: 1.6),
    bodySmall: style(13, FontWeight.w400, height: 1.5).copyWith(
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: style(14, FontWeight.w600, height: 1.2),
    labelMedium: style(13, FontWeight.w500, height: 1.2),
    labelSmall: style(12, FontWeight.w500, height: 1.2).copyWith(
      color: scheme.onSurfaceVariant,
    ),
  );
}

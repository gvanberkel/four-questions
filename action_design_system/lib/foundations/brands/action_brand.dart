import 'package:flutter/material.dart';

abstract class ActionBrand {
  const ActionBrand();

  String get name;

  ColorScheme get colorScheme;

  ColorScheme? get darkColorScheme => null;

  String? get fontFamily => null;

  String? get headingFontFamily => null;

  ActionSurfaceStyles get surfaceStyles => const ActionSurfaceStyles();

  Widget? buildLogo(BuildContext context, {required double size}) => null;
}

@immutable
class ActionSurfaceStyles extends ThemeExtension<ActionSurfaceStyles> {
  const ActionSurfaceStyles({
    this.cardBorderWidth = 1.0,
    this.cardElevation = 0.0,
    this.dividerOpacity = 0.4,
  });

  final double cardBorderWidth;
  final double cardElevation;
  final double dividerOpacity;

  @override
  ActionSurfaceStyles copyWith({
    double? cardBorderWidth,
    double? cardElevation,
    double? dividerOpacity,
  }) {
    return ActionSurfaceStyles(
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      cardElevation: cardElevation ?? this.cardElevation,
      dividerOpacity: dividerOpacity ?? this.dividerOpacity,
    );
  }

  @override
  ActionSurfaceStyles lerp(
      ThemeExtension<ActionSurfaceStyles>? other, double t) {
    if (other is! ActionSurfaceStyles) return this;
    return ActionSurfaceStyles(
      cardBorderWidth: lerpDouble(cardBorderWidth, other.cardBorderWidth, t),
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t),
      dividerOpacity: lerpDouble(dividerOpacity, other.dividerOpacity, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

@immutable
class ActionBrandAssets extends ThemeExtension<ActionBrandAssets> {
  const ActionBrandAssets({required this.name, this.logoBuilder});

  final String name;

  final Widget? Function(BuildContext context, {required double size})?
      logoBuilder;

  @override
  ActionBrandAssets copyWith({
    String? name,
    Widget? Function(BuildContext context, {required double size})? logoBuilder,
  }) {
    return ActionBrandAssets(
      name: name ?? this.name,
      logoBuilder: logoBuilder ?? this.logoBuilder,
    );
  }

  @override
  ActionBrandAssets lerp(
      ThemeExtension<ActionBrandAssets>? other, double t) {
    return t < 0.5 ? this : (other as ActionBrandAssets? ?? this);
  }
}

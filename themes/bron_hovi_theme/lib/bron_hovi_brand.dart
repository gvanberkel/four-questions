import 'package:action_design_system/action_design_system.dart';
import 'package:bron_hovi_theme/bron_hovi_mark.dart';
import 'package:flutter/material.dart';

class BronHoviBrand extends ActionBrand {
  const BronHoviBrand();

  @override
  String get name => 'Bron Hovi';

  static const Color _plum = Color(0xFF553C6E);
  static const Color _sage = Color(0xFF5E9474);

  @override
  Widget buildLogo(BuildContext context, {required double size}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BronHoviMark(
      size: size,
      selfColor: dark ? const Color(0xFFCDB6E6) : _plum,
      partnerColor: dark ? const Color(0xFF8CC4A2) : _sage,
    );
  }

  @override
  String get fontFamily => 'Inter';

  @override
  ColorScheme get colorScheme => const ColorScheme.light(
        primary: _plum,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFEDE3F5),
        onPrimaryContainer: Color(0xFF2C1A3D),
        secondary: Color(0xFF7A6A62),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFEFE7E1),
        onSecondaryContainer: Color(0xFF3A2E28),
        tertiary: Color(0xFF3E7A5A),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFDDEFE3),
        onTertiaryContainer: Color(0xFF1D4430),
        error: Color(0xFFB0503A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFF8E2DA),
        onErrorContainer: Color(0xFF5A2216),
        surface: Color(0xFFFAF7F4),
        onSurface: Color(0xFF221C24),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFFFFFFF),
        surfaceContainer: Color(0xFFF2EDEA),
        surfaceContainerHigh: Color(0xFFEAE4E1),
        surfaceContainerHighest: Color(0xFFE2DBD8),
        onSurfaceVariant: Color(0xFF675D66),
        outline: Color(0xFFB3A8AE),
        outlineVariant: Color(0xFFE6DEE0),
        inverseSurface: Color(0xFF362D38),
        onInverseSurface: Color(0xFFF5EFF2),
        inversePrimary: Color(0xFFCDB6E6),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      );

  @override
  ColorScheme get darkColorScheme => const ColorScheme.dark(
        primary: Color(0xFFCDB6E6),
        onPrimary: Color(0xFF34204A),
        primaryContainer: Color(0xFF4A3462),
        onPrimaryContainer: Color(0xFFEDE3F5),
        secondary: Color(0xFFD6C6BC),
        onSecondary: Color(0xFF3A2E28),
        secondaryContainer: Color(0xFF4A3F3A),
        onSecondaryContainer: Color(0xFFEFE3DB),
        tertiary: Color(0xFFA3D7B8),
        onTertiary: Color(0xFF0F3320),
        tertiaryContainer: Color(0xFF234733),
        onTertiaryContainer: Color(0xFFC3EBD2),
        error: Color(0xFFF2B2A2),
        onError: Color(0xFF4F170C),
        errorContainer: Color(0xFF5A2216),
        onErrorContainer: Color(0xFFF9D5CB),
        surface: Color(0xFF17131A),
        onSurface: Color(0xFFECE5EC),
        surfaceContainerLowest: Color(0xFF110E13),
        surfaceContainerLow: Color(0xFF1E1922),
        surfaceContainer: Color(0xFF251F29),
        surfaceContainerHigh: Color(0xFF2D2631),
        surfaceContainerHighest: Color(0xFF362E3A),
        onSurfaceVariant: Color(0xFFB9AEB8),
        outline: Color(0xFF6B6070),
        outlineVariant: Color(0xFF362E3A),
        inverseSurface: Color(0xFFECE5EC),
        onInverseSurface: Color(0xFF221C24),
        inversePrimary: _plum,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      );

  @override
  ActionSurfaceStyles get surfaceStyles => const ActionSurfaceStyles(
        cardBorderWidth: 1,
        cardElevation: 0,
        dividerOpacity: 0.4,
      );
}

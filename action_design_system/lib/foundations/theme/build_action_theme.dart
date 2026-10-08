import 'package:flutter/material.dart';
import 'package:action_design_system/foundations/brands/action_brand.dart';
import 'package:action_design_system/foundations/theme/action_typography.dart';
import 'package:action_design_system/foundations/tokens/action_radii.dart';
import 'package:action_design_system/foundations/tokens/action_spacing.dart';

ThemeData buildActionTheme(
  ActionBrand brand, {
  Brightness brightness = Brightness.light,
}) {
  final scheme = brightness == Brightness.dark
      ? (brand.darkColorScheme ?? brand.colorScheme)
      : brand.colorScheme;

  final textTheme = buildActionTextTheme(
    scheme,
    fontFamily: brand.fontFamily,
    headingFontFamily: brand.headingFontFamily,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: brand.fontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: <ThemeExtension<dynamic>>[
      brand.surfaceStyles,
      ActionBrandAssets(
        name: brand.name,
        logoBuilder: brand.buildLogo,
      ),
    ],
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      space: ActionSpacing.md,
      thickness: 1,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: brand.surfaceStyles.cardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: ActionRadii.lgAll,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: brand.surfaceStyles.cardBorderWidth,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: ActionSpacing.lg,
          vertical: ActionSpacing.sm,
        ),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: ActionSpacing.lg,
          vertical: ActionSpacing.sm,
        ),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: ActionSpacing.md,
          vertical: ActionSpacing.sm,
        ),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ActionSpacing.md,
        vertical: ActionSpacing.md,
      ),
      border: const OutlineInputBorder(borderRadius: ActionRadii.mdAll),
      enabledBorder: OutlineInputBorder(
        borderRadius: ActionRadii.mdAll,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ActionRadii.mdAll,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: ActionRadii.mdAll,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: ActionRadii.mdAll,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.outline),
      labelStyle: textTheme.labelMedium,
      helperStyle: textTheme.labelSmall,
      errorStyle: textTheme.labelSmall?.copyWith(color: scheme.error),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: ActionRadii.lgAll),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      actionTextColor: scheme.inversePrimary,
      shape: const RoundedRectangleBorder(borderRadius: ActionRadii.lgAll),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.secondaryContainer,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surfaceContainerLowest,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:action_design_system/action_design_system.dart';

class _TestBrand extends ActionBrand {
  const _TestBrand();

  @override
  String get name => 'Test';

  @override
  String? get fontFamily => 'Body';

  @override
  String? get headingFontFamily => 'Heading';

  @override
  ColorScheme get colorScheme => const ColorScheme.light(primary: Colors.teal);

  @override
  ColorScheme get darkColorScheme =>
      const ColorScheme.dark(primary: Colors.tealAccent);
}

void main() {
  test('buildActionTheme carries the brand into ThemeData', () {
    final theme = buildActionTheme(const _TestBrand());

    expect(theme.colorScheme.primary, Colors.teal);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Body');
    expect(theme.textTheme.headlineMedium?.fontFamily, 'Heading');
    expect(theme.extension<ActionBrandAssets>()?.name, 'Test');
    expect(theme.extension<ActionSurfaceStyles>(), isNotNull);
  });

  test('dark mode uses the dark scheme', () {
    final theme =
        buildActionTheme(const _TestBrand(), brightness: Brightness.dark);
    expect(theme.colorScheme.primary, Colors.tealAccent);
  });

  test('a brand with one typeface uses it for headings too', () {
    const scheme = ColorScheme.light();
    final text = buildActionTextTheme(scheme, fontFamily: 'Only');
    expect(text.headlineMedium?.fontFamily, 'Only');
  });
}

import 'package:action_design_system/action_design_system.dart';
import 'package:bron_hovi_theme/bron_hovi_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brand = BronHoviBrand();

  test('the brand builds a light and a dark theme', () {
    final light = buildActionTheme(brand);
    final dark = buildActionTheme(brand, brightness: Brightness.dark);

    expect(light.colorScheme.primary, const Color(0xFF553C6E));
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(light.textTheme.headlineMedium?.fontFamily, 'Inter');
    expect(light.extension<ActionBrandAssets>()?.name, 'Bron Hovi');
  });

  testWidgets('the logo paints without an asset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildActionTheme(brand),
        home: const Center(child: ActionWordmark()),
      ),
    );
    expect(find.byType(BronHoviMark), findsOneWidget);
    expect(find.text('Bron Hovi'), findsOneWidget);
  });
}

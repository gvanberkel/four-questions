import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const forbiddenPackages = [
    'firebase_core',
    'firebase_auth',
    'firebase_data_connect',
    'cloud_functions',
    'firebase_storage',
    'google_sign_in',
    'http',
    'dio',
    'get_it',
    'provider',
    'go_router',
    'shared_preferences',
    'flutter_secure_storage',
    'hive',
    'path_provider',
    'four_questions',
    'bron_hovi_theme',
  ];

  const forbiddenFlutterSlickPrefixes = [
    'package:flutter_slick/navigation/',
    'package:flutter_slick/services/',
  ];

  List<File> libDartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  Iterable<String> importsOf(File file) sync* {
    final pattern = RegExp('''^\\s*(?:import|export)\\s+['"]([^'"]+)['"]''');
    for (final line in file.readAsLinesSync()) {
      final match = pattern.firstMatch(line);
      if (match != null) yield match.group(1)!;
    }
  }

  test('lib/ imports no forbidden package', () {
    final violations = <String>[];

    for (final file in libDartFiles()) {
      for (final import in importsOf(file)) {
        for (final package in forbiddenPackages) {
          if (import.startsWith('package:$package/')) {
            violations.add('${file.path} imports $import');
          }
        }
        for (final prefix in forbiddenFlutterSlickPrefixes) {
          if (import.startsWith(prefix)) {
            violations.add('${file.path} imports $import');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'The design system must stay pure UI. Invert the coupling: take '
          'data as values and behaviour as callbacks.\n${violations.join('\n')}',
    );
  });

  test('pubspec declares no forbidden dependency', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final depsBlock =
        pubspec.split(RegExp(r'^dev_dependencies:', multiLine: true)).first;

    final declared = forbiddenPackages
        .where((p) => RegExp('^\\s{2}$p:', multiLine: true).hasMatch(depsBlock))
        .toList();

    expect(
      declared,
      isEmpty,
      reason: 'Forbidden runtime dependencies declared: ${declared.join(', ')}',
    );
  });
}

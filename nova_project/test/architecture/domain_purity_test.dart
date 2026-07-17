import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Cheap guard against the one mistake that quietly destroys the layering:
/// a `features/*/domain/` file reaching for Flutter, a data source, or
/// `dart:ui`. `domain` must be pure Dart.
void main() {
  test('no features/*/domain file imports Flutter, Hive, dart:ui, or IO', () {
    final featuresDir = Directory('lib/features');
    expect(
      featuresDir.existsSync(),
      isTrue,
      reason: 'run from the nova_project root',
    );

    // Packages/libraries a pure domain layer must never import.
    final forbidden = <RegExp>[
      RegExp(r'''import\s+['"]package:flutter/'''),
      RegExp(r'''import\s+['"]dart:ui'''),
      RegExp(r'''import\s+['"]dart:io'''),
      RegExp(r'''import\s+['"]package:hive'''),
      RegExp(r'''import\s+['"]package:firebase'''),
      RegExp(r'''import\s+['"]package:cloud_firestore'''),
      RegExp(r'''import\s+['"]package:http'''),
      RegExp(r'''import\s+['"]package:fl_chart'''),
      RegExp(r'''import\s+['"]package:intl'''),
      RegExp(r'''import\s+['"]package:flutter_riverpod'''),
    ];

    final domainFiles = featuresDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/domain/'))
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];
    for (final file in domainFiles) {
      final contents = file.readAsStringSync();
      for (final pattern in forbidden) {
        if (pattern.hasMatch(contents)) {
          violations.add('${file.path} matches ${pattern.pattern}');
        }
      }
    }

    expect(domainFiles, isNotEmpty, reason: 'expected domain files to scan');
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/main.dart';

void main() {
  testWidgets('boots to a blank Inter-themed scaffold', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NovaApp()));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
  });

  testWidgets('Inter is bundled as an asset, not fetched over the network', (
    tester,
  ) async {
    for (final weight in ['Regular', 'Medium', 'SemiBold']) {
      final font = await rootBundle.load('assets/fonts/Inter-$weight.ttf');
      expect(font.lengthInBytes, greaterThan(0));
    }
  });
}

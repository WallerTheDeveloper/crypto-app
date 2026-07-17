import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/theme/theme_controller.dart';
import 'package:nova_project/main.dart';

import 'support/fake_theme_store.dart';

void main() {
  testWidgets('boots to a blank Inter-themed scaffold', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeStoreProvider.overrideWithValue(FakeThemeStore())],
        child: const NovaApp(),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);

    final theme = Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
  });

  testWidgets('starts on the persisted theme and rebuilds on switch', (
    tester,
  ) async {
    final store = FakeThemeStore(AppTheme.playful);
    late WidgetRef ref;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeStoreProvider.overrideWithValue(store)],
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            return const NovaApp();
          },
        ),
      ),
    );

    // Started on the persisted theme B (warm) with no flash of A.
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().theme?.brightness, Brightness.light);

    // A switch rebuilds the whole app with no restart.
    await ref.read(themeControllerProvider.notifier).setTheme(AppTheme.dark);
    await tester.pump();
    expect(app().theme?.brightness, Brightness.dark);
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

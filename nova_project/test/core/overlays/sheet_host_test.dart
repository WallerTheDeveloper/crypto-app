import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/overlays/sheet_controller.dart';
import 'package:nova_project/core/overlays/sheet_host.dart';
import 'package:nova_project/core/theme/app_theme.dart';

Future<ProviderContainer> pumpSheetHost(
  WidgetTester tester, {
  AppTheme theme = AppTheme.dark,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.of(theme),
        home: const Scaffold(body: SheetHost()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('renders nothing until a sheet is requested', (tester) async {
    final container = await pumpSheetHost(tester);
    expect(find.text('Add holding'), findsNothing);

    container.read(sheetControllerProvider.notifier).open(SheetKind.addHolding);
    await tester.pumpAndSettle();
    expect(find.text('Add holding'), findsOneWidget);
  });

  testWidgets('the panel fades and rises in over 300ms', (tester) async {
    final container = await pumpSheetHost(tester);
    container.read(sheetControllerProvider.notifier).open(SheetKind.addHolding);

    await tester.pump(); // build the panel; enter animation begins at 0
    final opacityFinder = find.ancestor(
      of: find.text('Add holding'),
      matching: find.byType(Opacity),
    );
    expect(tester.widget<Opacity>(opacityFinder).opacity, lessThan(1.0));

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widget<Opacity>(opacityFinder).opacity, 1.0);
  });

  testWidgets('tapping the scrim dismisses the sheet', (tester) async {
    final container = await pumpSheetHost(tester);
    container
        .read(sheetControllerProvider.notifier)
        .open(SheetKind.createAlert);
    await tester.pumpAndSettle();
    expect(find.text('Set price alert'), findsOneWidget);

    // Tap the scrim well above the bottom panel.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Set price alert'), findsNothing);
    expect(container.read(sheetControllerProvider), SheetKind.none);
  });

  testWidgets('opens in both themes without error', (tester) async {
    for (final theme in AppTheme.values) {
      final container = await pumpSheetHost(tester, theme: theme);
      container
          .read(sheetControllerProvider.notifier)
          .open(SheetKind.addHolding);
      await tester.pumpAndSettle();
      expect(find.text('Add holding'), findsOneWidget);
      expect(tester.takeException(), isNull);
      container.dispose();
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/navigation/nav_bar.dart';
import 'package:nova_project/core/navigation/nav_controller.dart';
import 'package:nova_project/core/navigation/nav_shell.dart';
import 'package:nova_project/core/theme/app_theme.dart';

/// Pumps the shell inside a real Riverpod container so tests can drive the nav
/// controller directly and read tokens off [theme].
Future<ProviderContainer> pumpShell(
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
        home: const NavShell(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// The color of a nav item's label, scoped to the [BottomNavBar] so it isn't
/// confused with a screen title of the same name.
Color navLabelColor(WidgetTester tester, String label) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byType(BottomNavBar),
      matching: find.text(label),
    ),
  );
  return text.style!.color!;
}

int stackIndex(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

void main() {
  const tabs = {
    NavTab.market: 'Market',
    NavTab.portfolio: 'Portfolio',
    NavTab.alerts: 'Alerts',
    NavTab.settings: 'Settings',
  };

  testWidgets('tapping each nav item switches to that screen', (tester) async {
    await pumpShell(tester);

    for (final entry in tabs.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.text(entry.value),
        ),
      );
      await tester.pumpAndSettle();
      expect(stackIndex(tester), entry.key.index);
    }
  });

  testWidgets('the tapped item is the only accent one', (tester) async {
    final container = await pumpShell(tester);
    final colors = AppThemes.darkColors;

    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavBar),
        matching: find.text('Portfolio'),
      ),
    );
    await tester.pumpAndSettle();

    expect(navLabelColor(tester, 'Portfolio'), colors.accent);
    for (final label in ['Market', 'Alerts', 'Settings']) {
      expect(navLabelColor(tester, label), colors.muted, reason: label);
    }
    container.dispose();
  });

  testWidgets('opening detail keeps the Market tab lit', (tester) async {
    final container = await pumpShell(tester);
    final colors = AppThemes.darkColors;

    container.read(navControllerProvider.notifier).openDetail('bitcoin');
    await tester.pumpAndSettle();

    // Detail is showing (its header carries the coin id)...
    expect(find.text('bitcoin'), findsOneWidget);
    // ...and Market is the only lit tab.
    expect(navLabelColor(tester, 'Market'), colors.accent);
    for (final label in ['Portfolio', 'Alerts', 'Settings']) {
      expect(navLabelColor(tester, label), colors.muted, reason: label);
    }
  });

  testWidgets('back from detail returns to Market with scroll intact', (
    tester,
  ) async {
    // A short viewport so the Market placeholder overflows and can scroll.
    tester.view.physicalSize = const Size(360, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await pumpShell(tester);

    // Scroll the visible Market screen (offstage tabs aren't hit-testable).
    final marketScroll = find.byType(Scrollable).hitTestable();
    await tester.drag(marketScroll, const Offset(0, -80));
    await tester.pumpAndSettle();
    final scrolled = tester.state<ScrollableState>(marketScroll).position.pixels;
    expect(scrolled, greaterThan(0));

    // Open, then close, coin detail.
    container.read(navControllerProvider.notifier).openDetail('bitcoin');
    await tester.pumpAndSettle();
    container.read(navControllerProvider.notifier).closeDetail();
    await tester.pumpAndSettle();

    // Back on Market with the same scroll offset (the tab was kept alive).
    expect(stackIndex(tester), NavTab.market.index);
    final after = tester
        .state<ScrollableState>(find.byType(Scrollable).hitTestable())
        .position
        .pixels;
    expect(after, scrolled);
  });

  testWidgets('nav renders in both themes with correct active colors', (
    tester,
  ) async {
    for (final theme in AppTheme.values) {
      await pumpShell(tester, theme: theme);
      final colors = AppThemes.colorsOf(theme);

      // Default tab is Market: lit accent, the rest muted.
      expect(navLabelColor(tester, 'Market'), colors.accent);
      expect(navLabelColor(tester, 'Alerts'), colors.muted);
      expect(tester.takeException(), isNull);
    }
  });
}

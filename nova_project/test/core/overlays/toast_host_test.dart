import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/overlays/toast_controller.dart';
import 'package:nova_project/core/overlays/toast_host.dart';
import 'package:nova_project/core/theme/app_theme.dart';

Future<ProviderContainer> pumpToastHost(
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
        home: const Scaffold(body: ToastHost()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('shows a toast then auto-dismisses at 2200ms', (tester) async {
    final container = await pumpToastHost(tester);
    container.read(toastControllerProvider.notifier).show('Added to portfolio');

    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 300)); // enter done
    expect(find.text('Added to portfolio'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2000)); // cross the dwell
    await tester.pump(const Duration(milliseconds: 400)); // exit animation
    await tester.pump();

    expect(find.text('Added to portfolio'), findsNothing);
    expect(container.read(toastControllerProvider), isNull);
  });

  testWidgets('a second toast replaces the first and resets the timer', (
    tester,
  ) async {
    final container = await pumpToastHost(tester);
    final controller = container.read(toastControllerProvider.notifier);

    controller.show('First');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First'), findsOneWidget);

    // Most of the way through First's dwell, replace it.
    await tester.pump(const Duration(milliseconds: 1500));
    controller.show('Second');
    await tester.pump(); // rebuild with the new key
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    // Past when First would have expired — Second is still up (timer reset).
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Second'), findsOneWidget);

    // Let Second run out its own full dwell.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('disposing before the dwell cancels the timer cleanly', (
    tester,
  ) async {
    final container = await pumpToastHost(tester);
    container.read(toastControllerProvider.notifier).show('Leaky');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Leaky'), findsOneWidget);

    // Tear the host down mid-dwell, then advance past when the timer would fire.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 2500));

    // No "setState() called after dispose()" surfaced.
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders in both themes', (tester) async {
    for (final theme in AppTheme.values) {
      final container = await pumpToastHost(tester, theme: theme);
      container.read(toastControllerProvider.notifier).show('Saved');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsOneWidget);
      expect(tester.takeException(), isNull);
      container.dispose();
    }
  });
}

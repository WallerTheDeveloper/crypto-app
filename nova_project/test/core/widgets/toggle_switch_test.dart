import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/widgets/toggle_switch.dart';

import '../../support/widget_harness.dart';

void main() {
  Finder knob() => find.descendant(
    of: find.byType(AnimatedPositioned),
    matching: find.byType(Container),
  );

  Color trackColor(WidgetTester tester) {
    final track = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ToggleSwitch),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return (track.decoration as BoxDecoration).color!;
  }

  forEachTheme((theme) {
    final colors = AppThemes.colorsOf(theme);

    testWidgets(
      'off and on map to the two positions and colours (${theme.name})',
      (tester) async {
        await tester.pumpWidget(
          themed(ToggleSwitch(value: false, onChanged: (_) {}), theme: theme),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
              .left,
          3,
        );
        expect(trackColor(tester), colors.borderStrong);

        await tester.pumpWidget(
          themed(ToggleSwitch(value: true, onChanged: (_) {}), theme: theme),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<AnimatedPositioned>(find.byType(AnimatedPositioned))
              .left,
          22,
        );
        expect(trackColor(tester), colors.accent);
      },
    );
  });

  testWidgets('animates the knob rightward and reports the change', (
    tester,
  ) async {
    bool value = false;
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (context, setState) => ToggleSwitch(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );

    final start = tester.getTopLeft(knob()).dx;
    await tester.tap(find.byType(ToggleSwitch));
    expect(value, isTrue); // change reported immediately

    await tester.pump(); // start animation
    await tester.pump(const Duration(milliseconds: 100)); // mid-flight
    final mid = tester.getTopLeft(knob()).dx;
    expect(mid, greaterThan(start));

    await tester.pumpAndSettle();
    final end = tester.getTopLeft(knob()).dx;
    expect(end, greaterThan(mid));
  });
}

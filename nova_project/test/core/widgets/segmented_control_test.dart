import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/widgets/segmented_control.dart';

import '../../support/widget_harness.dart';

void main() {
  const segments = [
    SegmentData(value: 'a', label: 'Dark'),
    SegmentData(value: 'b', label: 'Warm'),
    SegmentData(value: 'c', label: 'System'),
  ];

  int activeCount(WidgetTester tester, Color accent) {
    final containers = tester.widgetList<AnimatedContainer>(
      find.descendant(
        of: find.byType(SegmentedControl<String>),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return containers
        .where((c) => (c.decoration as BoxDecoration).color == accent)
        .length;
  }

  forEachTheme((theme) {
    final colors = AppThemes.colorsOf(theme);

    testWidgets('exactly one segment paints active (${theme.name})',
        (tester) async {
      await tester.pumpWidget(
        themed(
          SegmentedControl<String>(
            segments: segments,
            value: 'b',
            onChanged: (_) {},
          ),
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();
      expect(activeCount(tester, colors.accent), 1);
    });
  });

  testWidgets('reports the tapped item', (tester) async {
    String selected = 'a';
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (context, setState) => SegmentedControl<String>(
            segments: segments,
            value: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      ),
    );

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(selected, 'c');
    expect(activeCount(tester, AppThemes.colorsOf(AppTheme.dark).accent), 1);
  });

  testWidgets('inset style stretches segments to fill', (tester) async {
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 320,
          child: SegmentedControl<String>(
            segments: segments,
            value: 'a',
            onChanged: (_) {},
            style: SegmentedStyle.inset,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Expanded), findsNWidgets(segments.length));
  });
}

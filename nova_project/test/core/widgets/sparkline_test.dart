import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/sparkline.dart';

import '../../support/widget_harness.dart';

void main() {
  const List<double> values = [3, 4, 3.5, 5, 4.5, 6, 5.5, 7, 6.5, 8, 7.5, 9];

  forEachTheme((theme) {
    testWidgets('renders in both directions (${theme.name})', (tester) async {
      await tester.pumpWidget(
        themed(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Sparkline(values: values, positive: true),
              Sparkline(values: values, positive: false),
            ],
          ),
          theme: theme,
        ),
      );
      expect(find.byType(Sparkline), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a single point renders nothing but does not throw',
      (tester) async {
    await tester.pumpWidget(
      themed(const Sparkline(values: [5], positive: true)),
    );
    expect(tester.takeException(), isNull);
  });
}

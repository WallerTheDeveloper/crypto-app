import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/skeleton.dart';

import '../../support/widget_harness.dart';

void main() {
  double shimmerOffset(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(Container),
      ),
    );
    final gradient =
        (container.decoration as BoxDecoration).gradient! as LinearGradient;
    return (gradient.begin as Alignment).x;
  }

  testWidgets('the shimmer gradient offset moves over time', (tester) async {
    await tester.pumpWidget(
      themed(const Skeleton(width: 120, height: 20)),
    );

    final first = shimmerOffset(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final second = shimmerOffset(tester);

    expect(second, isNot(first));
  });

  testWidgets('loops without ever settling', (tester) async {
    await tester.pumpWidget(themed(const Skeleton(width: 120, height: 20)));
    // A static block would settle; an infinite shimmer keeps scheduling frames.
    expect(tester.hasRunningAnimations, isTrue);
  });
}

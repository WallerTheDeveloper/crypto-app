import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/icons/app_icon.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('every icon type paints without error', (tester) async {
    for (final type in AppIconType.values) {
      await tester.pumpWidget(
        themed(AppIcon(type, color: const Color(0xFF000000), size: 24)),
      );
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('each type carries its design stroke width', (tester) async {
    expect(AppIconType.plus.strokeWidth, 2);
    expect(AppIconType.check.strokeWidth, 3);
    expect(AppIconType.warning.strokeWidth, 1.7);
  });
}

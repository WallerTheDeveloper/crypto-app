import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/widgets/grouped_list_card.dart';
import 'package:nova_project/core/widgets/surface_card.dart';

import '../../support/widget_harness.dart';

void main() {
  forEachTheme((theme) {
    final colors = AppThemes.colorsOf(theme);

    testWidgets('surface card uses s1 fill and fires onTap (${theme.name})',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        themed(
          SurfaceCard(
            onTap: () => tapped = true,
            child: const Text('Portfolio value'),
          ),
          theme: theme,
        ),
      );

      final decorated = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(SurfaceCard),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((decorated.decoration as BoxDecoration).color, colors.s1);

      await tester.tap(find.text('Portfolio value'));
      expect(tapped, isTrue);
    });
  });

  testWidgets('grouped list card puts a divider between rows only',
      (tester) async {
    await tester.pumpWidget(
      themed(
        const GroupedListCard(
          children: [
            Padding(padding: EdgeInsets.all(16), child: Text('Currency')),
            Padding(padding: EdgeInsets.all(16), child: Text('Notifications')),
            Padding(padding: EdgeInsets.all(16), child: Text('About')),
          ],
        ),
      ),
    );
    // Three rows → two dividers, none trailing.
    expect(find.byType(Divider), findsNWidgets(2));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/coin_avatar.dart';

import '../../support/widget_harness.dart';

void main() {
  // Bitcoin brand orange — not a theme token; passed in.
  const brand = Color(0xFFF7931A);

  forEachTheme((theme) {
    testWidgets('paints the brand fill and glyph (${theme.name})', (
      tester,
    ) async {
      await tester.pumpWidget(
        themed(
          const CoinAvatar(color: brand, glyph: '₿'),
          theme: theme,
        ),
      );

      expect(find.text('₿'), findsOneWidget);
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CoinAvatar),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration as BoxDecoration).color, brand);
      expect((container.decoration as BoxDecoration).shape, BoxShape.circle);
    });
  });

  testWidgets('glyph size defaults from the avatar size', (tester) async {
    await tester.pumpWidget(
      themed(const CoinAvatar(color: brand, glyph: '₿', size: 40)),
    );
    expect(tester.widget<Text>(find.text('₿')).style!.fontSize, 15);
  });
}

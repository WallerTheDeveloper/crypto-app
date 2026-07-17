import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/widgets/price_change_badge.dart';

import '../../support/widget_harness.dart';

void main() {
  Color badgeBackground(WidgetTester tester) {
    final decorated = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(PriceChangeBadge),
        matching: find.byType(DecoratedBox),
      ),
    );
    return (decorated.decoration as BoxDecoration).color!;
  }

  Color textColor(WidgetTester tester, String label) {
    return tester.widget<Text>(find.text(label)).style!.color!;
  }

  group('sign, colour and format', () {
    forEachTheme((theme) {
      final colors = AppThemes.colorsOf(theme);

      testWidgets('positive → gain / gainSoft / +2.4% (${theme.name})',
          (tester) async {
        await tester.pumpWidget(themed(const PriceChangeBadge(2.4), theme: theme));
        expect(find.text('+2.4%'), findsOneWidget);
        expect(textColor(tester, '+2.4%'), colors.gain);
        expect(badgeBackground(tester), colors.gainSoft);
      });

      testWidgets('negative → loss / lossSoft / -1.2% (${theme.name})',
          (tester) async {
        await tester.pumpWidget(themed(const PriceChangeBadge(-1.2), theme: theme));
        expect(find.text('-1.2%'), findsOneWidget);
        expect(textColor(tester, '-1.2%'), colors.loss);
        expect(badgeBackground(tester), colors.lossSoft);
      });

      testWidgets('exactly zero → muted / mutedSoft / 0.0% (${theme.name})',
          (tester) async {
        await tester.pumpWidget(themed(const PriceChangeBadge(0), theme: theme));
        expect(find.text('0.0%'), findsOneWidget);
        expect(textColor(tester, '0.0%'), colors.muted);
        expect(badgeBackground(tester), colors.mutedSoft);
      });
    });
  });

  testWidgets('label overrides text but colour still follows the sign',
      (tester) async {
    final colors = AppThemes.colorsOf(AppTheme.dark);
    await tester.pumpWidget(
      themed(const PriceChangeBadge(1234, label: r'+$1,234')),
    );
    expect(find.text(r'+$1,234'), findsOneWidget);
    expect(find.text('+1234.0%'), findsNothing);
    expect(textColor(tester, r'+$1,234'), colors.gain);
  });

  testWidgets('size selects the font size', (tester) async {
    await tester.pumpWidget(themed(const PriceChangeBadge(2.4)));
    expect(tester.widget<Text>(find.text('+2.4%')).style!.fontSize, 12);

    await tester.pumpWidget(
      themed(const PriceChangeBadge(2.4, size: BadgeSize.large)),
    );
    expect(tester.widget<Text>(find.text('+2.4%')).style!.fontSize, 14);
  });
}

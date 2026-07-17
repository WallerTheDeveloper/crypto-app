import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/widgets/app_icon_button.dart';
import 'package:nova_project/core/widgets/icons/app_icon.dart';
import 'package:nova_project/core/widgets/primary_button.dart';
import 'package:nova_project/core/widgets/secondary_button.dart';
import 'package:nova_project/core/widgets/text_action_button.dart';

import '../../support/widget_harness.dart';

void main() {
  forEachTheme((theme) {
    testWidgets(
      'primary and secondary buttons fire onPressed (${theme.name})',
      (tester) async {
        var primary = 0;
        var secondary = 0;
        await tester.pumpWidget(
          themed(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(label: 'Add', onPressed: () => primary++),
                SecondaryButton(
                  label: 'Set alert',
                  onPressed: () => secondary++,
                ),
              ],
            ),
            theme: theme,
          ),
        );

        await tester.tap(find.text('Add'));
        await tester.tap(find.text('Set alert'));
        expect(primary, 1);
        expect(secondary, 1);
      },
    );
  });

  testWidgets('a null onPressed disables the primary button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      themed(const PrimaryButton(label: 'Add', onPressed: null)),
    );
    // Rebuild with a live handler would tap; here it must stay inert.
    await tester.tap(find.text('Add'));
    expect(taps, 0);

    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Add'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('accent icon button uses the accent fill', (tester) async {
    final colors = AppThemes.colorsOf(AppTheme.dark);
    await tester.pumpWidget(
      themed(
        AppIconButton(icon: AppIconType.plus, onPressed: () {}, accent: true),
      ),
    );
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppIconButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, colors.accent);
  });

  testWidgets('text action button fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      themed(
        TextActionButton(
          label: 'Add',
          icon: AppIconType.plus,
          onPressed: () => tapped = true,
        ),
      ),
    );
    await tester.tap(find.text('Add'));
    expect(tapped, isTrue);
  });
}

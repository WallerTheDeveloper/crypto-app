import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/empty_state.dart';
import 'package:nova_project/core/widgets/icons/app_icon.dart';
import 'package:nova_project/core/widgets/primary_button.dart';

import '../../support/widget_harness.dart';

void main() {
  forEachTheme((theme) {
    testWidgets('renders title, body and fires the CTA (${theme.name})',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        themed(
          EmptyState(
            icon: AppIconType.portfolio,
            title: 'Start your portfolio',
            body: 'Add your first holding to track value and profit over time.',
            actionLabel: 'Add your first holding',
            onAction: () => tapped = true,
          ),
          theme: theme,
        ),
      );

      expect(find.text('Start your portfolio'), findsOneWidget);
      expect(
        find.text('Add your first holding to track value and profit over time.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  testWidgets('compact variant shows no CTA', (tester) async {
    await tester.pumpWidget(
      themed(
        const EmptyState(
          icon: AppIconType.search,
          title: 'No results',
          body: 'Try a different coin name or ticker to see live prices.',
          compact: true,
        ),
      ),
    );

    expect(find.text('No results'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
  });
}

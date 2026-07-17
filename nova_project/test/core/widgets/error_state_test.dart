import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/error_state.dart';
import 'package:nova_project/core/widgets/primary_button.dart';

import '../../support/widget_harness.dart';

void main() {
  forEachTheme((theme) {
    testWidgets('renders title, message and fires Retry (${theme.name})', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        themed(
          ErrorState(
            title: "Couldn't load market",
            message: 'Check your connection and try again.',
            onRetry: () => retried = true,
          ),
          theme: theme,
        ),
      );

      expect(find.text("Couldn't load market"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}

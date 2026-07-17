import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/widgets/app_toast.dart';

import '../../support/widget_harness.dart';

void main() {
  testWidgets('shows the message then auto-dismisses at 2200ms',
      (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      themed(
        AppToast(message: 'Added to portfolio', onDismissed: () => dismissed = true),
      ),
    );

    // Enter animation done — still on screen well before the dwell elapses.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Added to portfolio'), findsOneWidget);
    expect(dismissed, isFalse);

    // Cross the 2200ms dwell; the exit animation (~300ms) then removes it.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Added to portfolio'), findsNothing);
    expect(dismissed, isTrue);
  });

  testWidgets('a shorter dwell can be configured', (tester) async {
    await tester.pumpWidget(
      themed(
        const AppToast(
          message: 'Signed out',
          visibleDuration: Duration(milliseconds: 500),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Signed out'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Signed out'), findsNothing);
  });
}

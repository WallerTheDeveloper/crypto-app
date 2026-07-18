import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/navigation/nav_controller.dart';

void main() {
  late ProviderContainer container;
  NavController controller() => container.read(navControllerProvider.notifier);
  NavState state() => container.read(navControllerProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('starts on Market with no detail', () {
    expect(state().tab, NavTab.market);
    expect(state().isDetailOpen, isFalse);
  });

  test('selectTab switches the active tab', () {
    controller().selectTab(NavTab.alerts);
    expect(state().tab, NavTab.alerts);
    expect(state().isTabActive(NavTab.alerts), isTrue);
    expect(state().isTabActive(NavTab.market), isFalse);
  });

  test('re-selecting the active tab is a no-op (same instance)', () {
    controller().selectTab(NavTab.portfolio);
    final before = state();
    controller().selectTab(NavTab.portfolio);
    expect(identical(state(), before), isTrue);
  });

  test('openDetail keeps Market the active tab', () {
    controller().openDetail('bitcoin');
    expect(state().detailCoinId, 'bitcoin');
    expect(state().isDetailOpen, isTrue);
    // Detail is a Market sub-screen: Market stays lit, nothing else does.
    expect(state().isTabActive(NavTab.market), isTrue);
    expect(state().isTabActive(NavTab.portfolio), isFalse);
  });

  test('closeDetail returns to Market', () {
    controller().openDetail('ethereum');
    controller().closeDetail();
    expect(state().isDetailOpen, isFalse);
    expect(state().tab, NavTab.market);
  });

  test('closeDetail with nothing open is a no-op', () {
    final before = state();
    controller().closeDetail();
    expect(identical(state(), before), isTrue);
  });

  test('selecting another tab closes an open detail', () {
    controller().openDetail('solana');
    controller().selectTab(NavTab.settings);
    expect(state().tab, NavTab.settings);
    expect(state().isDetailOpen, isFalse);
  });

  test('tapping Market while detail is open closes the detail', () {
    controller().openDetail('bitcoin');
    controller().selectTab(NavTab.market);
    expect(state().tab, NavTab.market);
    expect(state().isDetailOpen, isFalse);
  });

  test('NavState value equality', () {
    expect(
      const NavState(tab: NavTab.market),
      const NavState(tab: NavTab.market),
    );
    expect(
      const NavState(tab: NavTab.market, detailCoinId: 'x'),
      isNot(const NavState(tab: NavTab.market)),
    );
  });
}

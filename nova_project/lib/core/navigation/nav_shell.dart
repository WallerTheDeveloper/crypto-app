import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/market/presentation/market_screen.dart';
import '../overlays/sheet_host.dart';
import '../overlays/toast_host.dart';
import 'nav_bar.dart';
import 'nav_controller.dart';
import 'placeholder_screen.dart';

/// The frame every screen lives in.
///
/// A single [Scaffold] (giving one Material + `bg` for the whole app) holds a
/// [Stack], back-to-front: the tab content, the bottom nav, then the sheet and
/// toast hosts. Content scrolls *under* the translucent nav; the sheet scrim
/// covers the nav; the toast sits above everything.
///
/// Navigation is an inner [Navigator] over an [IndexedStack] of the four tabs
/// (per `CLAUDE.md`'s "no router" note — no `go_router` for five screens). The
/// stack keeps each tab's scroll position; coin detail is a second page pushed
/// above it. [NavState] is the single source of truth, so a system back, the
/// detail back button, and a nav tap all resolve through [NavController].
class NavShell extends ConsumerWidget {
  const NavShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailCoinId = ref.watch(
      navControllerProvider.select((s) => s.detailCoinId),
    );
    final notifier = ref.read(navControllerProvider.notifier);

    return Scaffold(
      // The sheet handles the keyboard itself; don't resize the whole shell.
      resizeToAvoidBottomInset: false,
      body: PopScope(
        // While detail is open, intercept the system back to close it instead
        // of popping the app.
        canPop: detailCoinId == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) notifier.closeDetail();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Navigator(
                onDidRemovePage: (_) => notifier.closeDetail(),
                pages: [
                  const MaterialPage(key: ValueKey('tabs'), child: _TabStack()),
                  if (detailCoinId != null)
                    MaterialPage(
                      key: const ValueKey('detail'),
                      child: CoinDetailPlaceholderScreen(coinId: detailCoinId),
                    ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(),
            ),
            const SheetHost(),
            const ToastHost(),
          ],
        ),
      ),
    );
  }
}

/// The four tabs, kept alive in an [IndexedStack] so switching preserves scroll
/// position. Rebuilds only when the active tab changes.
class _TabStack extends ConsumerWidget {
  const _TabStack();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(navControllerProvider.select((s) => s.tab));
    return IndexedStack(
      index: tab.index,
      children: const [
        // TODO(06-10): swap each remaining placeholder for its feature screen.
        MarketScreen(),
        PlaceholderScreen(title: 'Portfolio'),
        PlaceholderScreen(title: 'Alerts'),
        PlaceholderScreen(title: 'Settings'),
      ],
    );
  }
}

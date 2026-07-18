import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four bottom-nav destinations. Coin detail is *not* a tab — it's a
/// sub-screen of [market] (see [NavState.isTabActive]).
enum NavTab { market, portfolio, alerts, settings }

/// The shell's navigation state: which tab is selected and whether a coin
/// detail is pushed on top.
///
/// Detail is modelled as an optional [detailCoinId] rather than a fifth tab so
/// the design's rule — "the Market tab stays lit while a coin is open" — falls
/// out of [isTabActive]. Detail is only ever reached from Market, so [tab] is
/// always [NavTab.market] while [isDetailOpen].
@immutable
class NavState {
  const NavState({required this.tab, this.detailCoinId});

  final NavTab tab;

  /// The coin whose detail is pushed above the tab stack, or null.
  final String? detailCoinId;

  bool get isDetailOpen => detailCoinId != null;

  /// Whether [tab]'s nav item should render as active. Market stays active
  /// while a coin detail is open (`on = screen == k || (k == market && detail)`).
  bool isTabActive(NavTab candidate) =>
      candidate == tab || (candidate == NavTab.market && isDetailOpen);

  @override
  bool operator ==(Object other) =>
      other is NavState &&
      other.tab == tab &&
      other.detailCoinId == detailCoinId;

  @override
  int get hashCode => Object.hash(tab, detailCoinId);
}

/// Drives screen switching. Shared by the nav bar (reads the active tab), the
/// shell (renders the tab stack + detail route), and detail's back button — so
/// it lives in Riverpod, never local `setState`.
class NavController extends Notifier<NavState> {
  @override
  NavState build() => const NavState(tab: NavTab.market);

  /// Switches to [tab], closing any open detail. Tapping the already-active tab
  /// with no detail open is a no-op.
  void selectTab(NavTab tab) {
    if (state.tab == tab && !state.isDetailOpen) return;
    state = NavState(tab: tab);
  }

  /// Opens coin detail above Market.
  void openDetail(String coinId) {
    state = NavState(tab: NavTab.market, detailCoinId: coinId);
  }

  /// Closes coin detail, returning to Market. No-op if none is open.
  void closeDetail() {
    if (!state.isDetailOpen) return;
    state = NavState(tab: state.tab);
  }
}

final navControllerProvider = NotifierProvider<NavController, NavState>(
  NavController.new,
);

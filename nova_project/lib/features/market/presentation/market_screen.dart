import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../domain/entities/coin.dart';
import 'providers/market_list_providers.dart';
import 'providers/market_search_notifier.dart';
import 'widgets/market_coin_row.dart';
import 'widgets/market_header.dart';
import 'widgets/market_list_skeleton.dart';
import 'widgets/market_sort_chips.dart';
import 'widgets/portfolio_snapshot_strip.dart';

/// The market list — the app's default screen.
///
/// The four states come from [visibleCoinsProvider]'s `AsyncValue`, never
/// hand-rolled flags: loading → whole-screen skeleton, error → retry, data →
/// the list (or the search "No results" empty state). Retry re-runs the fetch by
/// invalidating the source stream, not by flipping local state.
class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(visibleCoinsProvider);
    final searching = ref.watch(marketSearchProvider.select((s) => s.active));
    final query = ref.watch(marketSearchProvider.select((s) => s.query));

    return AppScaffold(
      header: const MarketHeader(),
      children: visible.when(
        loading: () => const [MarketListSkeleton()],
        error: (_, _) => [
          ErrorState(
            title: "Couldn't load market",
            message: 'Check your connection and try again.',
            onRetry: () => ref.invalidate(marketCoinsProvider),
          ),
        ],
        data: (coins) =>
            _body(coins: coins, searching: searching, query: query),
      ),
    );
  }

  /// Populated content. While searching, the strip and chips step aside so the
  /// filtered list (or the empty state) has the screen to itself.
  List<Widget> _body({
    required List<Coin> coins,
    required bool searching,
    required String query,
  }) {
    if (searching) {
      if (query.isNotEmpty && coins.isEmpty) {
        return const [
          EmptyState(
            icon: AppIconType.search,
            title: 'No results',
            body: 'Try a different coin name or ticker to see live prices.',
            compact: true,
          ),
        ];
      }
      return [_CoinList(coins: coins)];
    }

    return [
      const PortfolioSnapshotStrip(),
      const SizedBox(height: 18),
      const MarketSortChips(),
      const SizedBox(height: 14),
      _CoinList(coins: coins),
    ];
  }
}

class _CoinList extends StatelessWidget {
  const _CoinList({required this.coins});

  final List<Coin> coins;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final coin in coins) MarketCoinRow(coin: coin)],
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../market/presentation/providers/market_list_providers.dart';
import '../../data/portfolio_providers.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/portfolio_position.dart';
import '../../domain/entities/portfolio_summary.dart';

/// Composed portfolio state: the user's holdings valued at live coin prices.
///
/// This joins two feature streams — holdings (portfolio) and coins (market) —
/// into a single [PortfolioSummary] with all-time value and P/L. The market
/// snapshot strip reads it now; the portfolio screen (task 07) builds its hero
/// and donut on the same source, so both always agree.
///
/// A holding whose coin isn't in the current market list is skipped rather than
/// valued at zero, so a transient/partial coin list can't fabricate a loss.

final holdingsProvider = StreamProvider<List<Holding>>((ref) {
  return ref.watch(portfolioRepositoryProvider).watchHoldings();
});

final portfolioSummaryProvider = Provider<AsyncValue<PortfolioSummary>>((ref) {
  final coins = ref.watch(marketCoinsProvider);
  final holdings = ref.watch(holdingsProvider);

  return coins.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (coinList) {
      final priceById = {for (final coin in coinList) coin.id: coin.price};
      return holdings.whenData((holdingList) {
        final positions = <PortfolioPosition>[
          for (final holding in holdingList)
            if (priceById[holding.coinId] case final price?)
              PortfolioPosition(holding: holding, currentPrice: price),
        ];
        return PortfolioSummary.from(positions);
      });
    },
  );
});

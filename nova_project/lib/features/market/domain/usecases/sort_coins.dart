import '../entities/coin.dart';
import '../entities/market_sort.dart';

/// Orders the market list by the selected [MarketSort].
///
/// Pure and non-mutating: it always returns a **new** list and never sorts the
/// caller's list in place, so the source (the cached/streamed coins) is never
/// disturbed. Ordering is a business rule, so it lives here rather than as an
/// ad-hoc `.sort()` in a widget.
class SortCoins {
  const SortCoins();

  List<Coin> call(List<Coin> coins, MarketSort sort) {
    final ordered = List<Coin>.of(coins);
    switch (sort) {
      case MarketSort.marketCap:
        ordered.sort((a, b) => b.marketCap.compareTo(a.marketCap));
      case MarketSort.gainers:
        ordered.sort((a, b) => b.change24hPct.compareTo(a.change24hPct));
      case MarketSort.watchlist:
        // Deferred (README#mvp-definition): render the chip, change nothing.
        break;
    }
    return ordered;
  }
}

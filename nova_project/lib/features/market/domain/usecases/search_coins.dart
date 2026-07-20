import '../entities/coin.dart';

/// Filters the market list by a free-text query.
///
/// Matches on coin **name or ticker**, case-insensitively (the empty-state copy
/// promises "coin name or ticker"). A blank query returns every coin. Pure and
/// non-mutating: the result is always a new list.
class SearchCoins {
  const SearchCoins();

  List<Coin> call(List<Coin> coins, String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return List<Coin>.of(coins);
    return [
      for (final coin in coins)
        if (coin.name.toLowerCase().contains(needle) ||
            coin.ticker.toLowerCase().contains(needle))
          coin,
    ];
  }
}

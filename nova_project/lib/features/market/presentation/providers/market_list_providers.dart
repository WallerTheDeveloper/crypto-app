import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/market_providers.dart';
import '../../domain/entities/coin.dart';
import '../../domain/usecases/search_coins.dart';
import '../../domain/usecases/sort_coins.dart';
import 'market_search_notifier.dart';
import 'market_sort_notifier.dart';

/// The raw market list: cache-then-network, straight off the repository stream.
/// Its `AsyncValue` is the source of the screen's loading/error/data states.
///
/// Auto-retry is disabled: the design shows an explicit error state with a
/// manual Retry, and the repository already degrades to cached data on failure.
/// Riverpod 3's default backoff retry would otherwise silently re-run the
/// stream and skip past the error state entirely.
final marketCoinsProvider = StreamProvider<List<Coin>>(
  (ref) => ref.watch(marketRepositoryProvider).watchCoins(),
  retry: (_, _) => null,
);

/// Use cases exposed as providers so tests can override the business logic and
/// the composition stays inversion-of-control (per CLAUDE.md).
final sortCoinsProvider = Provider<SortCoins>((ref) => const SortCoins());
final searchCoinsProvider = Provider<SearchCoins>((ref) => const SearchCoins());

/// What the list actually renders: coins sorted by the active chip, then
/// filtered by the (debounced) search query. Preserves the source
/// loading/error state so the screen's state machine reads from one place.
final visibleCoinsProvider = Provider<AsyncValue<List<Coin>>>((ref) {
  final sort = ref.watch(activeSortProvider);
  final query = ref.watch(marketSearchProvider.select((s) => s.query));
  final sortCoins = ref.watch(sortCoinsProvider);
  final searchCoins = ref.watch(searchCoinsProvider);

  return ref
      .watch(marketCoinsProvider)
      .whenData((coins) => searchCoins(sortCoins(coins, sort), query));
});

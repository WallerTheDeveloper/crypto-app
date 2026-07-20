import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/market_sort.dart';

/// Holds which market sort chip is active. Defaults to [MarketSort.marketCap]
/// (the design's default-active chip).
class ActiveSort extends Notifier<MarketSort> {
  @override
  MarketSort build() => MarketSort.marketCap;

  /// Selects [sort]. A no-op if it is already active.
  void select(MarketSort sort) {
    if (sort == state) return;
    state = sort;
  }
}

final activeSortProvider = NotifierProvider<ActiveSort, MarketSort>(
  ActiveSort.new,
);

/// The three market-list sort chips.
///
/// A pure domain value: the ordering logic lives in `SortCoins`, the chip
/// labels live in presentation. [watchlist] is deferred for the MVP
/// (`tasks/README.md#mvp-definition`) — it exists so the third chip can render,
/// but it applies no ordering and never filters.
enum MarketSort {
  /// Highest market capitalisation first (`price × circulatingSupply`).
  marketCap,

  /// Largest 24-hour gainers first.
  gainers,

  /// Deferred: renders but does not reorder or filter the list.
  watchlist,
}

import '../entities/chart_range.dart';
import '../entities/coin.dart';
import '../entities/price_point.dart';

/// Market data access, as the presentation layer sees it.
///
/// [watchCoins] is a stream because live prices become a websocket later;
/// getting the shape right now is the point — a `Future`-only interface would
/// have to be rewritten. The concrete implementation lives in `data` and is
/// supplied via a provider, so callers depend only on this interface.
abstract interface class MarketRepository {
  /// Emits the coin list, updating over time (cache first, then fresh).
  Stream<List<Coin>> watchCoins();

  /// One-shot fetch of the current coin list.
  Future<List<Coin>> getCoins();

  /// The coin with [id]. Fails with a `NotFoundFailure` if there is none.
  Future<Coin> getCoin(String id);

  /// The chart series for coin [id] over [range].
  Future<List<PricePoint>> getPriceSeries(String id, ChartRange range);
}

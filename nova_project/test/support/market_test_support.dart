import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 exposes `Override` only through this entry point.
import 'package:riverpod/misc.dart' show Override;
import 'package:nova_project/core/utils/currency.dart';
import 'package:nova_project/features/market/data/market_providers.dart';
import 'package:nova_project/features/market/data/mock/coin_fixtures.dart';
import 'package:nova_project/features/market/domain/entities/chart_range.dart';
import 'package:nova_project/features/market/domain/entities/coin.dart';
import 'package:nova_project/features/market/domain/entities/price_point.dart';
import 'package:nova_project/features/market/domain/repositories/market_repository.dart';
import 'package:nova_project/features/portfolio/data/mock/holding_fixtures.dart';
import 'package:nova_project/features/portfolio/domain/entities/holding.dart';
import 'package:nova_project/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:nova_project/features/portfolio/domain/entities/portfolio_summary.dart';
import 'package:nova_project/features/portfolio/presentation/providers/portfolio_summary_provider.dart';
import 'package:nova_project/features/settings/presentation/currency_providers.dart';

/// The eight design coins as domain entities.
final List<Coin> sampleCoins = CoinFixtures.coins
    .map((model) => model.toEntity())
    .toList(growable: false);

/// A [MarketRepository] whose `watchCoins` behaviour is scripted per call, so a
/// test can drive loading, error, then a working retry. It counts subscriptions
/// so "reprices without a reload" can prove the list wasn't re-fetched.
class FakeMarketRepository implements MarketRepository {
  FakeMarketRepository(this._onWatch);

  /// Emits [coins] on every subscription.
  factory FakeMarketRepository.always(List<Coin> coins) =>
      FakeMarketRepository((_) => Stream<List<Coin>>.value(coins));

  final Stream<List<Coin>> Function(int call) _onWatch;

  int watchCount = 0;

  @override
  Stream<List<Coin>> watchCoins() => _onWatch(watchCount++);

  @override
  Future<List<Coin>> getCoins() => throw UnimplementedError();

  @override
  Future<Coin> getCoin(String id) => throw UnimplementedError();

  @override
  Future<List<PricePoint>> getPriceSeries(String id, ChartRange range) =>
      throw UnimplementedError();
}

/// A [PortfolioSummary] over the seed holdings valued at [coins]' prices.
PortfolioSummary sampleSummary([List<Coin>? coins]) {
  final list = coins ?? sampleCoins;
  final priceById = {for (final coin in list) coin.id: coin.price};
  final positions = <PortfolioPosition>[
    for (final holding in HoldingFixtures.holdings)
      if (priceById[holding.coinId] case final price?)
        PortfolioPosition(
          holding: Holding(
            coinId: holding.coinId,
            amount: holding.amount,
            averageBuyPrice: holding.averageBuyPrice,
          ),
          currentPrice: price,
        ),
  ];
  return PortfolioSummary.from(positions);
}

/// The overrides that let [MarketScreen] build with fixed data and no Hive:
/// a market repo that streams [coins], a resolved portfolio summary, and USD.
/// Later overrides passed to a container win, so callers can specialise.
List<Override> marketScreenOverrides({List<Coin>? coins}) {
  final list = coins ?? sampleCoins;
  return [
    marketRepositoryProvider.overrideWithValue(
      FakeMarketRepository.always(list),
    ),
    portfolioSummaryProvider.overrideWithValue(
      AsyncValue.data(sampleSummary(list)),
    ),
    currencyStreamProvider.overrideWith((ref) => Stream.value(Currency.usd)),
  ];
}

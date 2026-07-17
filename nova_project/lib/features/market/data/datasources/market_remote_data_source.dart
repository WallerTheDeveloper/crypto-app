import 'dart:math';

import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/utils/price_series.dart';
import '../../domain/entities/chart_range.dart';
import '../models/coin_model.dart';
import '../mock/coin_fixtures.dart';

/// The "network" for market data. The real implementation (CoinGecko) will
/// implement this same interface, so swapping it out is a data-source change
/// only.
abstract interface class MarketRemoteDataSource {
  /// Fetches every coin. Throws [NetworkException] on failure.
  Future<List<CoinModel>> fetchCoins();

  /// Fetches one coin. Throws [NotFoundException] if [id] is unknown,
  /// [NetworkException] on failure.
  Future<CoinModel> fetchCoin(String id);

  /// Fetches the raw series values for [id] over [range].
  Future<List<double>> fetchSeries(String id, ChartRange range);
}

/// Fixture-backed [MarketRemoteDataSource].
///
/// Applies [MockConfig]'s artificial latency and failure injection so loading
/// skeletons are visible and the error state is reachable/testable. Series data
/// is generated deterministically via [PriceSeries] — stable across rebuilds.
class MockMarketRemoteDataSource implements MarketRemoteDataSource {
  MockMarketRemoteDataSource({required this._config, Random? random})
    : _random = random ?? Random();

  final MockConfig _config;
  final Random _random;

  Future<void> _simulate() async {
    await Future<void>.delayed(_config.latency);
    if (_config.shouldFail(_random)) {
      throw const NetworkException('mock forced failure');
    }
  }

  @override
  Future<List<CoinModel>> fetchCoins() async {
    await _simulate();
    return CoinFixtures.coins;
  }

  @override
  Future<CoinModel> fetchCoin(String id) async {
    await _simulate();
    for (final coin in CoinFixtures.coins) {
      if (coin.id == id) return coin;
    }
    throw NotFoundException('no coin with id "$id"');
  }

  @override
  Future<List<double>> fetchSeries(String id, ChartRange range) async {
    await _simulate();
    final trendPct = _changeFor(id);
    return PriceSeries.generate(
      seed: '$id${range.label}',
      points: range.points,
      trendPct: trendPct,
    );
  }

  /// The 24h change used as the series trend; `0` for an unknown id, mirroring
  /// the prototype's `c?c.change:0`.
  double _changeFor(String id) {
    for (final coin in CoinFixtures.coins) {
      if (coin.id == id) return coin.change24hPct;
    }
    return 0;
  }
}

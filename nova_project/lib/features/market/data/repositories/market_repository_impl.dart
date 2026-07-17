import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chart_range.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/price_point.dart';
import '../../domain/repositories/market_repository.dart';
import '../datasources/market_cache_data_source.dart';
import '../datasources/market_remote_data_source.dart';

/// [MarketRepository] over a remote source and a Hive cache.
///
/// Maps DTOs to entities and low-level [DataException]s to user-facing
/// [Failure]s, so nothing raw escapes `data/`.
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({required this._remote, required this._cache});

  final MarketRemoteDataSource _remote;
  final MarketCacheDataSource _cache;

  /// Cache-then-network: emit the cached list immediately (if any), then
  /// refresh from the remote source and emit again. If the refresh fails and
  /// there was a cache, the stale-but-valid cache stands; if there was no
  /// cache, the failure surfaces so the UI can show its error state.
  @override
  Stream<List<Coin>> watchCoins() async* {
    List<Coin> cached = const [];
    try {
      cached = _cache.read().map((m) => m.toEntity()).toList();
    } on CacheException {
      cached = const [];
    }
    if (cached.isNotEmpty) yield cached;

    try {
      final fresh = await _remote.fetchCoins();
      await _cache.write(fresh);
      yield fresh.map((m) => m.toEntity()).toList();
    } on DataException catch (e) {
      if (cached.isEmpty) throw _mapMarket(e);
    }
  }

  @override
  Future<List<Coin>> getCoins() async {
    try {
      final models = await _remote.fetchCoins();
      await _cache.write(models);
      return models.map((m) => m.toEntity()).toList();
    } on DataException catch (e) {
      throw _mapMarket(e);
    }
  }

  @override
  Future<Coin> getCoin(String id) async {
    try {
      final model = await _remote.fetchCoin(id);
      return model.toEntity();
    } on DataException catch (e) {
      throw _mapMarket(e);
    }
  }

  @override
  Future<List<PricePoint>> getPriceSeries(String id, ChartRange range) async {
    try {
      final values = await _remote.fetchSeries(id, range);
      return [
        for (var i = 0; i < values.length; i++)
          PricePoint(index: i, value: values[i]),
      ];
    } on DataException catch (e) {
      throw _mapMarket(e);
    }
  }

  Failure _mapMarket(DataException e) => switch (e) {
    NotFoundException() => const NotFoundFailure("Couldn't find that coin"),
    NetworkException() => const NetworkFailure("Couldn't load market"),
    CacheException() => const CacheFailure(),
  };
}

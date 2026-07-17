import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/error/exceptions.dart';
import 'package:nova_project/core/error/failures.dart';
import 'package:nova_project/core/mock/mock_config.dart';
import 'package:nova_project/features/market/data/datasources/market_cache_data_source.dart';
import 'package:nova_project/features/market/data/datasources/market_remote_data_source.dart';
import 'package:nova_project/features/market/data/mock/coin_fixtures.dart';
import 'package:nova_project/features/market/data/models/coin_model.dart';
import 'package:nova_project/features/market/data/repositories/market_repository_impl.dart';
import 'package:nova_project/features/market/domain/entities/chart_range.dart';

/// A remote whose behaviour is fully controllable, for deterministic tests.
class _FakeRemote implements MarketRemoteDataSource {
  _FakeRemote({this.error});

  final List<CoinModel> coins = CoinFixtures.coins;
  final DataException? error;

  @override
  Future<List<CoinModel>> fetchCoins() async {
    if (error != null) throw error!;
    return coins;
  }

  @override
  Future<CoinModel> fetchCoin(String id) async {
    if (error != null) throw error!;
    return coins.firstWhere(
      (c) => c.id == id,
      orElse: () => throw const NotFoundException(),
    );
  }

  @override
  Future<List<double>> fetchSeries(String id, ChartRange range) async {
    if (error != null) throw error!;
    return List<double>.filled(range.points, 0.5);
  }
}

/// An in-memory cache so the cache-then-network ordering can be observed.
class _FakeCache implements MarketCacheDataSource {
  _FakeCache([List<CoinModel>? initial]) : _stored = initial ?? const [];

  List<CoinModel> _stored;
  bool throwOnRead = false;

  @override
  List<CoinModel> read() {
    if (throwOnRead) throw const CacheException();
    return _stored;
  }

  @override
  Future<void> write(List<CoinModel> coins) async => _stored = coins;
}

const _sentinel = CoinModel(
  id: 'cached',
  name: 'Cached',
  ticker: 'CCH',
  glyph: 'C',
  brandColor: 0xFF000000,
  price: 1,
  change24hPct: 0,
  circulatingSupply: 1,
  allTimeHigh: 1,
  volume24h: 1,
  spark: [1, 2, 3],
);

void main() {
  group('mapping DTO -> entity', () {
    test('getCoins maps every field of a coin', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(),
        cache: _FakeCache(),
      );
      final coins = await repo.getCoins();
      expect(coins, hasLength(8));
      final btc = coins.firstWhere((c) => c.id == 'btc');
      expect(btc.name, 'Bitcoin');
      expect(btc.price, 64210.33);
      expect(btc.change24hPct, 2.4);
      expect(btc.brandColor, 0xFFF7931A);
      expect(btc.spark, hasLength(12));
      expect(btc.marketCap, closeTo(64210.33 * 19.72e6, 1));
    });

    test('getPriceSeries returns indexed points', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(),
        cache: _FakeCache(),
      );
      final series = await repo.getPriceSeries('btc', ChartRange.d7);
      expect(series, hasLength(ChartRange.d7.points));
      expect(series.first.index, 0);
      expect(series[5].index, 5);
    });
  });

  group('exception -> typed failure', () {
    test('a network error becomes NetworkFailure', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(error: const NetworkException()),
        cache: _FakeCache(),
      );
      await expectLater(repo.getCoins(), throwsA(isA<NetworkFailure>()));
    });

    test('an unknown coin becomes NotFoundFailure', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(),
        cache: _FakeCache(),
      );
      await expectLater(
        repo.getCoin('does-not-exist'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('a series fetch error becomes NetworkFailure', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(error: const NetworkException()),
        cache: _FakeCache(),
      );
      await expectLater(
        repo.getPriceSeries('btc', ChartRange.h24),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('cache-then-network', () {
    test('emits the cached list first, then the fresh one', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(), // 8 fixture coins
        cache: _FakeCache([_sentinel]), // 1 cached coin
      );
      final emitted = await repo.watchCoins().take(2).toList();
      expect(emitted.first, hasLength(1));
      expect(emitted.first.single.id, 'cached');
      expect(emitted.last, hasLength(8));
    });

    test('refreshes the cache with the fresh response', () async {
      final cache = _FakeCache();
      final repo = MarketRepositoryImpl(remote: _FakeRemote(), cache: cache);
      await repo.watchCoins().take(1).toList();
      expect(cache.read(), hasLength(8));
    });

    test('surfaces a failure when the fetch fails and nothing is cached', () {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(error: const NetworkException()),
        cache: _FakeCache(),
      );
      expect(repo.watchCoins(), emitsError(isA<NetworkFailure>()));
    });

    test(
      'a failing cache read is swallowed; the fresh fetch still emits',
      () async {
        final cache = _FakeCache()..throwOnRead = true;
        final repo = MarketRepositoryImpl(remote: _FakeRemote(), cache: cache);
        final emitted = await repo.watchCoins().toList();
        expect(emitted, hasLength(1)); // no cached emission, just the fresh one
        expect(emitted.single, hasLength(8));
      },
    );

    test('keeps showing the cache when the fetch fails', () async {
      final repo = MarketRepositoryImpl(
        remote: _FakeRemote(error: const NetworkException()),
        cache: _FakeCache([_sentinel]),
      );
      // Only the cached emission — the failed refresh does not error out.
      final emitted = await repo.watchCoins().toList();
      expect(emitted, hasLength(1));
      expect(emitted.single.single.id, 'cached');
    });
  });

  group('MockConfig seam', () {
    test('forceFailure produces a NetworkFailure, not a crash', () async {
      final repo = MarketRepositoryImpl(
        remote: MockMarketRemoteDataSource(
          config: const MockConfig(forceFailure: true, latency: Duration.zero),
        ),
        cache: _FakeCache(),
      );
      await expectLater(repo.getCoins(), throwsA(isA<NetworkFailure>()));
    });

    test(
      'with no failure, the real mock source returns the fixtures',
      () async {
        final repo = MarketRepositoryImpl(
          remote: MockMarketRemoteDataSource(
            config: const MockConfig(latency: Duration.zero),
          ),
          cache: _FakeCache(),
        );
        final coins = await repo.getCoins();
        expect(coins, hasLength(8));
        expect(coins.first.id, 'btc');
      },
    );
  });
}

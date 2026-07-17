import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/error/exceptions.dart';
import 'package:nova_project/core/mock/mock_config.dart';
import 'package:nova_project/features/market/data/datasources/market_remote_data_source.dart';
import 'package:nova_project/features/market/domain/entities/chart_range.dart';

MockMarketRemoteDataSource _source({bool fail = false}) =>
    MockMarketRemoteDataSource(
      config: MockConfig(latency: Duration.zero, forceFailure: fail),
    );

void main() {
  test('fetchCoins returns the eight fixtures', () async {
    final coins = await _source().fetchCoins();
    expect(coins, hasLength(8));
  });

  test('fetchCoin returns the requested coin', () async {
    final coin = await _source().fetchCoin('sol');
    expect(coin.ticker, 'SOL');
  });

  test('fetchCoin throws NotFoundException for an unknown id', () async {
    await expectLater(
      _source().fetchCoin('nope'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('fetchSeries length matches the range point count', () async {
    for (final range in ChartRange.values) {
      final series = await _source().fetchSeries('btc', range);
      expect(series, hasLength(range.points));
    }
  });

  test(
    'fetchSeries for an unknown id still produces a flat-trend series',
    () async {
      // Unknown id -> trend 0, but the generator still yields the right count.
      final series = await _source().fetchSeries('unknown', ChartRange.h24);
      expect(series, hasLength(ChartRange.h24.points));
    },
  );

  test('forceFailure makes reads throw NetworkException', () async {
    await expectLater(
      _source(fail: true).fetchCoins(),
      throwsA(isA<NetworkException>()),
    );
    await expectLater(
      _source(fail: true).fetchSeries('btc', ChartRange.d7),
      throwsA(isA<NetworkException>()),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nova_project/features/market/data/datasources/market_cache_data_source.dart';
import 'package:nova_project/features/market/data/mock/coin_fixtures.dart';

import '../../../support/hive_test_env.dart';

void main() {
  late HiveTestEnv env;
  late Box<dynamic> box;
  late HiveMarketCacheDataSource cache;

  setUp(() async {
    env = await HiveTestEnv.start();
    box = await env.openBox('market_cache');
    cache = HiveMarketCacheDataSource(box);
  });

  tearDown(() => env.dispose());

  test('reads empty before anything is written', () {
    expect(cache.read(), isEmpty);
  });

  test('write then read round-trips the coins as models', () async {
    await cache.write(CoinFixtures.coins);
    final read = cache.read();
    expect(read, hasLength(8));
    expect(read.first.id, 'btc');
    expect(read.first.toEntity(), CoinFixtures.coins.first.toEntity());
  });

  test('a later write replaces the earlier one', () async {
    await cache.write(CoinFixtures.coins);
    await cache.write([CoinFixtures.coins.last]);
    expect(cache.read(), hasLength(1));
    expect(cache.read().single.id, 'link');
  });
}

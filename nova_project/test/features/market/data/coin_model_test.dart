import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/market/data/mock/coin_fixtures.dart';
import 'package:nova_project/features/market/data/models/coin_model.dart';

void main() {
  test('every fixture coin survives a JSON round-trip', () {
    for (final coin in CoinFixtures.coins) {
      final restored = CoinModel.fromJson(coin.toJson());
      final a = coin.toEntity();
      final b = restored.toEntity();
      expect(b, a, reason: 'round-trip changed ${coin.id}');
    }
  });

  test('fixtures match the design exactly, including spark arrays', () {
    expect(CoinFixtures.coins, hasLength(8));
    final btc = CoinFixtures.coins.first.toEntity();
    expect(btc.spark, const [3, 4, 3.5, 5, 4.5, 6, 5.5, 7, 6.5, 8, 7.5, 9]);
    final sol = CoinFixtures.coins[2].toEntity();
    expect(sol.spark, const [2, 3, 2.5, 4, 5, 4.5, 6, 7, 6.5, 8, 9, 10]);
    // ids, in design order.
    expect(CoinFixtures.coins.map((c) => c.id), [
      'btc',
      'eth',
      'sol',
      'xrp',
      'ada',
      'doge',
      'avax',
      'link',
    ]);
  });

  test('fromEntity is the inverse of toEntity', () {
    final entity = CoinFixtures.coins.first.toEntity();
    final model = CoinModel.fromEntity(entity);
    expect(model.toEntity(), entity);
  });
}

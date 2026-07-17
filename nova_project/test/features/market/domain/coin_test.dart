import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/market/domain/entities/coin.dart';

Coin _coin({double price = 100, List<double> spark = const [1, 2, 3]}) => Coin(
  id: 'x',
  name: 'X',
  ticker: 'X',
  glyph: 'X',
  brandColor: 0xFF000000,
  price: price,
  change24hPct: 1,
  circulatingSupply: 10,
  allTimeHigh: 200,
  volume24h: 1000,
  spark: spark,
);

void main() {
  test('marketCap is price times supply', () {
    expect(_coin(price: 100).marketCap, 1000);
  });

  test('value equality includes the spark list', () {
    expect(_coin(), _coin());
    expect(
      _coin(spark: const [1, 2, 3]) == _coin(spark: const [1, 2, 4]),
      isFalse,
    );
    expect(_coin().hashCode, _coin().hashCode);
  });

  test('copyWith replaces only the named field', () {
    final updated = _coin().copyWith(price: 250);
    expect(updated.price, 250);
    expect(updated.id, 'x');
    expect(updated.spark, _coin().spark);
  });
}

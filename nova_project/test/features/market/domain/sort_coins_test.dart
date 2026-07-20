import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/market/domain/entities/coin.dart';
import 'package:nova_project/features/market/domain/entities/market_sort.dart';
import 'package:nova_project/features/market/domain/usecases/sort_coins.dart';

Coin _coin(
  String id, {
  required double price,
  required double supply,
  required double change,
}) => Coin(
  id: id,
  name: id.toUpperCase(),
  ticker: id.toUpperCase(),
  glyph: id[0],
  brandColor: 0xFF000000,
  price: price,
  change24hPct: change,
  circulatingSupply: supply,
  allTimeHigh: price,
  volume24h: 0,
  spark: const [1, 2],
);

void main() {
  const sort = SortCoins();

  // Crafted so market cap and gainers give *different* orders.
  final a = _coin('a', price: 10, supply: 100, change: 1); //  cap 1_000, +1%
  final b = _coin('b', price: 5, supply: 1000, change: 9); //  cap 5_000, +9%
  final c = _coin('c', price: 2, supply: 100, change: 20); //  cap   200, +20%
  final coins = [a, b, c];

  List<String> ids(List<Coin> list) => list.map((coin) => coin.id).toList();

  test('market cap orders by price × supply, descending', () {
    expect(ids(sort(coins, MarketSort.marketCap)), ['b', 'a', 'c']);
  });

  test('gainers orders by 24h change, descending', () {
    expect(ids(sort(coins, MarketSort.gainers)), ['c', 'b', 'a']);
  });

  test('watchlist is deferred — the order is unchanged', () {
    expect(ids(sort(coins, MarketSort.watchlist)), ['a', 'b', 'c']);
  });

  test('never mutates the caller\'s list', () {
    final input = [a, b, c];
    sort(input, MarketSort.marketCap);
    expect(ids(input), ['a', 'b', 'c']);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/market/domain/entities/coin.dart';
import 'package:nova_project/features/market/domain/usecases/search_coins.dart';

Coin _coin(String id, String name, String ticker) => Coin(
  id: id,
  name: name,
  ticker: ticker,
  glyph: name[0],
  brandColor: 0xFF000000,
  price: 1,
  change24hPct: 0,
  circulatingSupply: 1,
  allTimeHigh: 1,
  volume24h: 0,
  spark: const [1, 2],
);

void main() {
  const search = SearchCoins();
  final btc = _coin('btc', 'Bitcoin', 'BTC');
  final eth = _coin('eth', 'Ethereum', 'ETH');
  final coins = [btc, eth];

  test('an empty query returns every coin', () {
    expect(search(coins, ''), coins);
  });

  test('a whitespace-only query returns every coin', () {
    expect(search(coins, '   '), coins);
  });

  test('matches by name, case-insensitively', () {
    expect(search(coins, 'bitcoin').single.id, 'btc');
    expect(search(coins, 'BITCOIN').single.id, 'btc');
  });

  test('matches by ticker, case-insensitively', () {
    expect(search(coins, 'eth').single.id, 'eth');
    expect(search(coins, 'ETH').single.id, 'eth');
  });

  test('matches a partial substring', () {
    expect(search(coins, 'bit').single.id, 'btc');
  });

  test('no match returns an empty list', () {
    expect(search(coins, 'zzz'), isEmpty);
  });

  test('never mutates the caller\'s list', () {
    final input = [btc, eth];
    search(input, 'btc');
    expect(input, [btc, eth]);
  });
}

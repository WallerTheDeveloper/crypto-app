import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nova_project/features/portfolio/data/datasources/holdings_local_data_source.dart';
import 'package:nova_project/features/portfolio/data/repositories/portfolio_repository_impl.dart';

import '../../../support/hive_test_env.dart';

void main() {
  late HiveTestEnv env;
  late Box<dynamic> box;
  late PortfolioRepositoryImpl repo;

  setUp(() async {
    env = await HiveTestEnv.start();
    box = await env.openBox('holdings');
    repo = PortfolioRepositoryImpl(HoldingsLocalDataSource(box));
  });

  tearDown(() => env.dispose());

  test('seeds the four design holdings on first run', () async {
    final holdings = await repo.watchHoldings().first;
    expect(holdings.map((h) => h.coinId).toSet(), {
      'btc',
      'eth',
      'sol',
      'link',
    });
    final btc = holdings.firstWhere((h) => h.coinId == 'btc');
    expect(btc.amount, 0.42);
    expect(btc.averageBuyPrice, 52000);
  });

  test('add is a copy-on-write round-trip through Hive', () async {
    await repo.watchHoldings().first; // trigger seeding
    await repo.addHolding(coinId: 'ada', amount: 100, averageBuyPrice: 0.4);

    final holdings = await repo.watchHoldings().first;
    final ada = holdings.firstWhere((h) => h.coinId == 'ada');
    expect(ada.amount, 100);
    expect(ada.averageBuyPrice, 0.4);
  });

  test('remove deletes the holding', () async {
    await repo.watchHoldings().first;
    await repo.removeHolding('btc');

    final holdings = await repo.watchHoldings().first;
    expect(holdings.any((h) => h.coinId == 'btc'), isFalse);
  });

  test('watch emits again after a write', () async {
    final emissions = <int>[];
    final sub = repo.watchHoldings().listen((h) => emissions.add(h.length));
    addTearDown(sub.cancel);

    await pumpUntil(() => emissions.isNotEmpty);
    expect(emissions.last, 4); // 4 seeds

    await repo.addHolding(coinId: 'doge', amount: 1000, averageBuyPrice: 0.1);
    await pumpUntil(() => emissions.length >= 2);

    expect(emissions.last, 5); // 4 seeds + doge
  });

  test('does not re-seed after the user empties the portfolio', () async {
    // First run seeds; user then removes everything.
    var holdings = await repo.watchHoldings().first;
    for (final h in holdings) {
      await repo.removeHolding(h.coinId);
    }
    expect((await repo.watchHoldings().first), isEmpty);

    // Reopen the same box (simulates a restart) — seeds must not return.
    final reopened = PortfolioRepositoryImpl(HoldingsLocalDataSource(box));
    expect((await reopened.watchHoldings().first), isEmpty);
  });

  test('survives a restart (data persists in the box)', () async {
    await repo.watchHoldings().first;
    await repo.addHolding(coinId: 'ada', amount: 5, averageBuyPrice: 1);

    final reopened = PortfolioRepositoryImpl(HoldingsLocalDataSource(box));
    final holdings = await reopened.watchHoldings().first;
    expect(holdings.any((h) => h.coinId == 'ada'), isTrue);
  });
}

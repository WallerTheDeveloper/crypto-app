import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/coin_model.dart';

/// Local cache of the last successful market response, in the `market_cache`
/// Hive box. Backs the cache-then-network read: the repository shows this
/// instantly, then refreshes from the remote source.
abstract interface class MarketCacheDataSource {
  /// The cached coins, or an empty list if nothing is cached.
  List<CoinModel> read();

  /// Replaces the cached coins with [coins].
  Future<void> write(List<CoinModel> coins);
}

/// Hive-backed [MarketCacheDataSource]. Stores the list as JSON maps under a
/// single key — no adapters, no codegen.
class HiveMarketCacheDataSource implements MarketCacheDataSource {
  HiveMarketCacheDataSource(this._box);

  final Box<dynamic> _box;

  static const String _key = 'coins';

  @override
  List<CoinModel> read() {
    try {
      final raw = _box.get(_key);
      if (raw is! List) return const [];
      return [
        for (final item in raw)
          CoinModel.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (e) {
      throw CacheException('failed to read market cache: $e');
    }
  }

  @override
  Future<void> write(List<CoinModel> coins) async {
    try {
      await _box.put(_key, [for (final c in coins) c.toJson()]);
    } catch (e) {
      throw CacheException('failed to write market cache: $e');
    }
  }
}

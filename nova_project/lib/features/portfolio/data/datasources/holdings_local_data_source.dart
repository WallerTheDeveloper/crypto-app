import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/persistence/box_stream.dart';
import '../mock/holding_fixtures.dart';
import '../models/holding_model.dart';

/// Local store for holdings, in the `holdings` Hive box.
///
/// Each holding is stored under its `coinId`; a reserved [_seededKey] flag marks
/// that first-run seeding has happened, so seeds are written exactly once and an
/// empty portfolio (the user deleted everything) is never re-seeded over.
///
/// [watch] emits the current list immediately and again on every box change.
class HoldingsLocalDataSource {
  HoldingsLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const String _seededKey = '__seeded__';

  /// Emits the holdings now, then on every change to the box.
  Stream<List<HoldingModel>> watch() =>
      watchBox(box: _box, ensureSeeded: _ensureSeeded, read: _readAll);

  /// Adds or replaces the holding for its coin id (copy-on-write: Hive `put`
  /// swaps the stored map, never mutating one in place).
  Future<void> put(HoldingModel holding) async {
    try {
      await _box.put(holding.coinId, holding.toJson());
    } catch (e) {
      throw CacheException('failed to write holding: $e');
    }
  }

  /// Removes the holding for [coinId], if present.
  Future<void> delete(String coinId) async {
    try {
      await _box.delete(coinId);
    } catch (e) {
      throw CacheException('failed to delete holding: $e');
    }
  }

  List<HoldingModel> _readAll() {
    try {
      return [
        for (final entry in _box.toMap().entries)
          if (entry.key != _seededKey)
            HoldingModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      ];
    } catch (e) {
      throw CacheException('failed to read holdings: $e');
    }
  }

  Future<void> _ensureSeeded() async {
    if (_box.get(_seededKey) == true) return;
    try {
      await _box.putAll({
        for (final h in HoldingFixtures.holdings) h.coinId: h.toJson(),
        _seededKey: true,
      });
    } catch (e) {
      throw CacheException('failed to seed holdings: $e');
    }
  }
}

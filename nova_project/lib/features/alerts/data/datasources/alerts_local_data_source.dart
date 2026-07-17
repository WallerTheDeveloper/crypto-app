import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/persistence/box_stream.dart';
import '../mock/alert_fixtures.dart';
import '../models/alert_model.dart';

/// Local store for alerts, in the `alerts` Hive box.
///
/// Each alert is stored under its `id`; a reserved [_seededKey] flag marks that
/// first-run seeding has happened. [watch] emits the current list immediately
/// and again on every box change.
class AlertsLocalDataSource {
  AlertsLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const String _seededKey = '__seeded__';

  /// Emits the alerts now, then on every change to the box.
  Stream<List<AlertModel>> watch() =>
      watchBox(box: _box, ensureSeeded: _ensureSeeded, read: _readAll);

  /// The alert with [id], or null if there is none.
  AlertModel? readOne(String id) {
    final raw = _box.get(id);
    if (raw is! Map) return null;
    try {
      return AlertModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      throw CacheException('failed to read alert: $e');
    }
  }

  /// Adds or replaces [alert] (copy-on-write).
  Future<void> put(AlertModel alert) async {
    try {
      await _box.put(alert.id, alert.toJson());
    } catch (e) {
      throw CacheException('failed to write alert: $e');
    }
  }

  /// Removes the alert with [id], if present.
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('failed to delete alert: $e');
    }
  }

  List<AlertModel> _readAll() {
    try {
      return [
        for (final entry in _box.toMap().entries)
          if (entry.key != _seededKey)
            AlertModel.fromJson(Map<String, dynamic>.from(entry.value as Map)),
      ];
    } catch (e) {
      throw CacheException('failed to read alerts: $e');
    }
  }

  Future<void> _ensureSeeded() async {
    if (_box.get(_seededKey) == true) return;
    try {
      await _box.putAll({
        for (final a in AlertFixtures.alerts) a.id: a.toJson(),
        _seededKey: true,
      });
    } catch (e) {
      throw CacheException('failed to seed alerts: $e');
    }
  }
}

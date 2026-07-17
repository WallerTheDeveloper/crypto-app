import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/persistence/box_stream.dart';
import '../mock/prefs_fixtures.dart';
import '../models/user_prefs_model.dart';

/// Local store for the single [UserPrefsModel] record, in the `prefs` Hive box
/// (under its own key, alongside the theme controller's key).
///
/// On first run the record is absent; [_ensureSeeded] writes the defaults once.
/// [watch] emits the current prefs immediately and again on every change.
class PrefsLocalDataSource {
  PrefsLocalDataSource(this._box);

  final Box<dynamic> _box;

  static const String _key = 'user_prefs';

  /// Emits the prefs now, then on every change to that record.
  Stream<UserPrefsModel> watch() =>
      watchBox(box: _box, ensureSeeded: _ensureSeeded, read: _read, key: _key);

  /// The current prefs, or the defaults if somehow absent.
  UserPrefsModel read() {
    return _read();
  }

  /// Replaces the stored prefs (copy-on-write).
  Future<void> write(UserPrefsModel prefs) async {
    try {
      await _box.put(_key, prefs.toJson());
    } catch (e) {
      throw CacheException('failed to write prefs: $e');
    }
  }

  UserPrefsModel _read() {
    final raw = _box.get(_key);
    if (raw is! Map) return PrefsFixtures.defaults;
    try {
      return UserPrefsModel.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      throw CacheException('failed to read prefs: $e');
    }
  }

  Future<void> _ensureSeeded() async {
    if (_box.containsKey(_key)) return;
    try {
      await _box.put(_key, PrefsFixtures.defaults.toJson());
    } catch (e) {
      throw CacheException('failed to seed prefs: $e');
    }
  }
}

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/currency.dart';
import '../../domain/entities/user_prefs.dart';
import '../../domain/repositories/prefs_repository.dart';
import '../datasources/prefs_local_data_source.dart';
import '../models/user_prefs_model.dart';

/// [PrefsRepository] over the local Hive store. Each setter reads the current
/// record, writes a copy with the one field changed (copy-on-write), and lets
/// the box stream re-emit.
class PrefsRepositoryImpl implements PrefsRepository {
  PrefsRepositoryImpl(this._local);

  final PrefsLocalDataSource _local;

  @override
  Stream<UserPrefs> watchPrefs() async* {
    try {
      yield* _local.watch().map((m) => m.toEntity());
    } on CacheException catch (e) {
      throw CacheFailure(e.message ?? "Couldn't load your settings");
    }
  }

  @override
  Future<void> setTheme(String themeId) => _update(
    (m) => UserPrefsModel(
      themeId: themeId,
      currency: m.currency,
      notificationsEnabled: m.notificationsEnabled,
    ),
  );

  @override
  Future<void> setCurrency(Currency currency) => _update(
    (m) => UserPrefsModel(
      themeId: m.themeId,
      currency: currency.name,
      notificationsEnabled: m.notificationsEnabled,
    ),
  );

  @override
  Future<void> setNotifications(bool enabled) => _update(
    (m) => UserPrefsModel(
      themeId: m.themeId,
      currency: m.currency,
      notificationsEnabled: enabled,
    ),
  );

  Future<void> _update(
    UserPrefsModel Function(UserPrefsModel current) change,
  ) async {
    try {
      await _local.write(change(_local.read()));
    } on CacheException {
      throw const CacheFailure("Couldn't save your settings");
    }
  }
}

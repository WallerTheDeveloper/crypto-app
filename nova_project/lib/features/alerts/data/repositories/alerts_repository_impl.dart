import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alerts_repository.dart';
import '../datasources/alerts_local_data_source.dart';
import '../models/alert_model.dart';

/// Generates ids for new alerts. Injectable so tests get deterministic ids.
typedef AlertIdGenerator = String Function();

/// [AlertsRepository] over the local Hive store.
class AlertsRepositoryImpl implements AlertsRepository {
  AlertsRepositoryImpl(this._local, {AlertIdGenerator? idGenerator})
    : _newId = idGenerator ?? _timeBasedId;

  final AlertsLocalDataSource _local;
  final AlertIdGenerator _newId;

  static String _timeBasedId() => 'a${DateTime.now().microsecondsSinceEpoch}';

  @override
  Stream<List<Alert>> watchAlerts() async* {
    try {
      yield* _local.watch().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );
    } on CacheException catch (e) {
      throw CacheFailure(e.message ?? "Couldn't load alerts");
    }
  }

  @override
  Future<void> addAlert({
    required String coinId,
    required AlertDirection direction,
    required double targetPrice,
  }) async {
    try {
      await _local.put(
        AlertModel(
          id: _newId(),
          coinId: coinId,
          direction: direction.name,
          targetPrice: targetPrice,
          isEnabled: true,
        ),
      );
    } on CacheException {
      throw const CacheFailure("Couldn't save your alert");
    }
  }

  @override
  Future<void> setAlertEnabled(String id, bool isEnabled) async {
    try {
      final existing = _local.readOne(id);
      if (existing == null) return; // nothing to toggle
      await _local.put(
        AlertModel(
          id: existing.id,
          coinId: existing.coinId,
          direction: existing.direction,
          targetPrice: existing.targetPrice,
          isEnabled: isEnabled,
        ),
      );
    } on CacheException {
      throw const CacheFailure("Couldn't update your alert");
    }
  }

  @override
  Future<void> removeAlert(String id) async {
    try {
      await _local.delete(id);
    } on CacheException {
      throw const CacheFailure("Couldn't remove your alert");
    }
  }
}

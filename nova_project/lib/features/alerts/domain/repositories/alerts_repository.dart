import '../entities/alert.dart';

/// Read/write access to the user's price alerts.
///
/// [watchAlerts] is a stream because alerts live in Firestore later; today the
/// implementation streams them from local storage.
abstract interface class AlertsRepository {
  /// Emits the current alerts, and again on every change.
  Stream<List<Alert>> watchAlerts();

  /// Creates a new, enabled alert.
  Future<void> addAlert({
    required String coinId,
    required AlertDirection direction,
    required double targetPrice,
  });

  /// Arms or disarms the alert with [id].
  Future<void> setAlertEnabled(String id, bool isEnabled);

  /// Removes the alert with [id]. A no-op if there is none.
  Future<void> removeAlert(String id);
}

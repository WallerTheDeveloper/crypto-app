import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nova_project/features/alerts/data/datasources/alerts_local_data_source.dart';
import 'package:nova_project/features/alerts/data/repositories/alerts_repository_impl.dart';
import 'package:nova_project/features/alerts/domain/entities/alert.dart';

import '../../../support/hive_test_env.dart';

void main() {
  late HiveTestEnv env;
  late Box<dynamic> box;
  late AlertsRepositoryImpl repo;
  var idCounter = 0;

  setUp(() async {
    env = await HiveTestEnv.start();
    box = await env.openBox('alerts');
    idCounter = 0;
    repo = AlertsRepositoryImpl(
      AlertsLocalDataSource(box),
      idGenerator: () => 'gen${idCounter++}',
    );
  });

  tearDown(() => env.dispose());

  test('seeds the three design alerts with their on/off state', () async {
    final alerts = await repo.watchAlerts().first;
    expect(alerts, hasLength(3));
    final btc = alerts.firstWhere((a) => a.coinId == 'btc');
    expect(btc.direction, AlertDirection.above);
    expect(btc.targetPrice, 70000);
    expect(btc.isEnabled, isTrue);
    expect(alerts.firstWhere((a) => a.coinId == 'eth').isEnabled, isFalse);
    expect(alerts.firstWhere((a) => a.coinId == 'sol').isEnabled, isTrue);
  });

  test('addAlert stores a new, enabled alert', () async {
    await repo.watchAlerts().first;
    await repo.addAlert(
      coinId: 'ada',
      direction: AlertDirection.below,
      targetPrice: 0.4,
    );
    final alerts = await repo.watchAlerts().first;
    final ada = alerts.firstWhere((a) => a.coinId == 'ada');
    expect(ada.id, 'gen0');
    expect(ada.direction, AlertDirection.below);
    expect(ada.isEnabled, isTrue);
  });

  test('setAlertEnabled flips a single alert', () async {
    await repo.watchAlerts().first;
    await repo.setAlertEnabled('a1', false);
    final alerts = await repo.watchAlerts().first;
    expect(alerts.firstWhere((a) => a.id == 'a1').isEnabled, isFalse);
    // Others untouched.
    expect(alerts.firstWhere((a) => a.id == 'a3').isEnabled, isTrue);
  });

  test('setAlertEnabled on an unknown id is a no-op', () async {
    await repo.watchAlerts().first;
    await repo.setAlertEnabled('nope', true);
    expect(await repo.watchAlerts().first, hasLength(3));
  });

  test('removeAlert deletes it', () async {
    await repo.watchAlerts().first;
    await repo.removeAlert('a2');
    final alerts = await repo.watchAlerts().first;
    expect(alerts.any((a) => a.id == 'a2'), isFalse);
  });

  test('persists across a restart and does not re-seed edits', () async {
    await repo.watchAlerts().first;
    await repo.removeAlert('a1');
    await repo.removeAlert('a2');
    await repo.removeAlert('a3');

    final reopened = AlertsRepositoryImpl(AlertsLocalDataSource(box));
    expect(await reopened.watchAlerts().first, isEmpty);
  });
}

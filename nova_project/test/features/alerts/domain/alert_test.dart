import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/alerts/data/models/alert_model.dart';
import 'package:nova_project/features/alerts/domain/entities/alert.dart';

void main() {
  const alert = Alert(
    id: 'a1',
    coinId: 'btc',
    direction: AlertDirection.above,
    targetPrice: 70000,
    isEnabled: true,
  );

  test('copyWith flips enabled without touching the rest', () {
    final off = alert.copyWith(isEnabled: false);
    expect(off.isEnabled, isFalse);
    expect(off.id, 'a1');
    expect(off.targetPrice, 70000);
    expect(off.direction, AlertDirection.above);
  });

  test('value equality', () {
    expect(alert, alert.copyWith());
    expect(alert == alert.copyWith(targetPrice: 1), isFalse);
    expect(alert.hashCode, alert.copyWith().hashCode);
  });

  test(
    'AlertModel round-trips through JSON and entity, preserving direction',
    () {
      final model = AlertModel.fromEntity(alert);
      final restored = AlertModel.fromJson(model.toJson()).toEntity();
      expect(restored, alert);
      expect(restored.direction, AlertDirection.above);
    },
  );
}

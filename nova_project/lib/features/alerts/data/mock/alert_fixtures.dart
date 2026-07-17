import '../models/alert_model.dart';

/// First-run seed alerts, copied from `ALERTS` in the design (with the
/// prototype's default on/off state): btc above 70000 **on**, eth below 2800
/// **off**, sol above 160 **on**.
///
/// Seeded into the `alerts` box once, on first launch only.
abstract final class AlertFixtures {
  static const List<AlertModel> alerts = [
    AlertModel(
      id: 'a1',
      coinId: 'btc',
      direction: 'above',
      targetPrice: 70000,
      isEnabled: true,
    ),
    AlertModel(
      id: 'a2',
      coinId: 'eth',
      direction: 'below',
      targetPrice: 2800,
      isEnabled: false,
    ),
    AlertModel(
      id: 'a3',
      coinId: 'sol',
      direction: 'above',
      targetPrice: 160,
      isEnabled: true,
    ),
  ];
}

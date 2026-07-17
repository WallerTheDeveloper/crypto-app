import '../models/holding_model.dart';

/// First-run seed holdings, copied from `HOLD` in the design.
///
/// Seeded into the `holdings` box once, on first launch only. After the user
/// edits their portfolio, their data wins — these are never written again.
abstract final class HoldingFixtures {
  static const List<HoldingModel> holdings = [
    HoldingModel(coinId: 'btc', amount: 0.42, averageBuyPrice: 52000),
    HoldingModel(coinId: 'eth', amount: 3.1, averageBuyPrice: 2760),
    HoldingModel(coinId: 'sol', amount: 24, averageBuyPrice: 96),
    HoldingModel(coinId: 'link', amount: 120, averageBuyPrice: 11.4),
  ];
}

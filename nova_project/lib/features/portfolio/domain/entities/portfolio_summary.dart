import 'portfolio_position.dart';

/// Portfolio-wide totals derived from a set of [PortfolioPosition]s.
///
/// Pure aggregation, kept out of the UI so the hero card and donut read the
/// same numbers. Build it with [PortfolioSummary.from]; the totals are computed
/// once at construction.
class PortfolioSummary {
  const PortfolioSummary({
    required this.positions,
    required this.totalValue,
    required this.totalCost,
  });

  /// Builds a summary by summing [positions].
  factory PortfolioSummary.from(List<PortfolioPosition> positions) {
    var value = 0.0;
    var cost = 0.0;
    for (final p in positions) {
      value += p.value;
      cost += p.costBasis;
    }
    return PortfolioSummary(
      positions: List.unmodifiable(positions),
      totalValue: value,
      totalCost: cost,
    );
  }

  /// The positions this summary aggregates.
  final List<PortfolioPosition> positions;

  /// Sum of every position's current value.
  final double totalValue;

  /// Sum of every position's cost basis.
  final double totalCost;

  /// Absolute profit or loss across the portfolio.
  double get totalProfitLoss => totalValue - totalCost;

  /// Portfolio profit or loss as a percentage of cost; `0` when cost is `0`.
  double get totalProfitLossPct =>
      totalCost == 0 ? 0 : totalProfitLoss / totalCost * 100;

  /// Fraction of total value in [position], in `[0, 1]`; `0` when empty.
  double allocationOf(PortfolioPosition position) =>
      totalValue == 0 ? 0 : position.value / totalValue;
}

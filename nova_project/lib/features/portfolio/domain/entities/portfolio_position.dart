import 'holding.dart';

/// A [Holding] valued at a coin's current price.
///
/// This is where holding data meets the live price. All money figures are
/// derived getters so they can never drift; [profitLossPct] guards against a
/// zero cost basis (a holding recorded at price 0) instead of dividing by zero.
class PortfolioPosition {
  const PortfolioPosition({required this.holding, required this.currentPrice});

  /// The underlying holding.
  final Holding holding;

  /// The coin's current USD price.
  final double currentPrice;

  /// Units held (mirrors [Holding.amount]).
  double get amount => holding.amount;

  /// Current market value of the position.
  double get value => holding.amount * currentPrice;

  /// Total amount paid (mirrors [Holding.costBasis]).
  double get costBasis => holding.costBasis;

  /// Absolute profit or loss versus cost.
  double get profitLoss => value - costBasis;

  /// Profit or loss as a percentage of cost; `0` when cost is `0`.
  double get profitLossPct => costBasis == 0 ? 0 : profitLoss / costBasis * 100;

  @override
  bool operator ==(Object other) =>
      other is PortfolioPosition &&
      other.holding == holding &&
      other.currentPrice == currentPrice;

  @override
  int get hashCode => Object.hash(holding, currentPrice);
}

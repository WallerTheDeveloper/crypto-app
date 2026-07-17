/// A position the user holds in one coin.
///
/// Immutable and price-free: a holding knows only what the user bought
/// ([amount] units at [averageBuyPrice]). Anything that depends on the live
/// price ([PortfolioPosition.value], profit/loss) is computed elsewhere, so a
/// holding never carries a stale valuation.
class Holding {
  const Holding({
    required this.coinId,
    required this.amount,
    required this.averageBuyPrice,
  });

  /// The [Coin.id] this position is in.
  final String coinId;

  /// Units held.
  final double amount;

  /// Average USD price paid per unit.
  final double averageBuyPrice;

  /// Total amount paid — derived, never stored.
  double get costBasis => amount * averageBuyPrice;

  Holding copyWith({String? coinId, double? amount, double? averageBuyPrice}) {
    return Holding(
      coinId: coinId ?? this.coinId,
      amount: amount ?? this.amount,
      averageBuyPrice: averageBuyPrice ?? this.averageBuyPrice,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Holding &&
      other.coinId == coinId &&
      other.amount == amount &&
      other.averageBuyPrice == averageBuyPrice;

  @override
  int get hashCode => Object.hash(coinId, amount, averageBuyPrice);
}

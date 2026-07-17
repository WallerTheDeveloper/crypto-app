import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/portfolio/domain/entities/holding.dart';
import 'package:nova_project/features/portfolio/domain/entities/portfolio_position.dart';

void main() {
  const holding = Holding(coinId: 'btc', amount: 0.42, averageBuyPrice: 52000);

  test('Holding copyWith and value equality', () {
    expect(holding, holding.copyWith());
    expect(holding.copyWith(amount: 1).amount, 1);
    expect(holding == holding.copyWith(amount: 1), isFalse);
    expect(holding.hashCode, holding.copyWith().hashCode);
  });

  test('PortfolioPosition exposes amount and has value equality', () {
    const position = PortfolioPosition(
      holding: holding,
      currentPrice: 64210.33,
    );
    expect(position.amount, 0.42);
    expect(
      position,
      const PortfolioPosition(holding: holding, currentPrice: 64210.33),
    );
    expect(
      position == const PortfolioPosition(holding: holding, currentPrice: 100),
      isFalse,
    );
    expect(
      position.hashCode,
      const PortfolioPosition(
        holding: holding,
        currentPrice: 64210.33,
      ).hashCode,
    );
  });
}

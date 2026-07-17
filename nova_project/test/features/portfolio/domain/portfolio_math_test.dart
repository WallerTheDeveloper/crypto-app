import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/portfolio/domain/entities/holding.dart';
import 'package:nova_project/features/portfolio/domain/entities/portfolio_position.dart';
import 'package:nova_project/features/portfolio/domain/entities/portfolio_summary.dart';

void main() {
  group('Holding.costBasis', () {
    test('is amount times average buy price', () {
      const h = Holding(coinId: 'btc', amount: 0.42, averageBuyPrice: 52000);
      expect(h.costBasis, closeTo(21840, 1e-9));
    });
  });

  group('PortfolioPosition', () {
    test('computes value, cost, profit and percent for a gain', () {
      // btc: 0.42 @ 52000, now 64210.33.
      const position = PortfolioPosition(
        holding: Holding(coinId: 'btc', amount: 0.42, averageBuyPrice: 52000),
        currentPrice: 64210.33,
      );
      expect(position.value, closeTo(0.42 * 64210.33, 1e-9));
      expect(position.costBasis, closeTo(21840, 1e-9));
      expect(position.profitLoss, closeTo(0.42 * 64210.33 - 21840, 1e-9));
      expect(
        position.profitLossPct,
        closeTo((0.42 * 64210.33 - 21840) / 21840 * 100, 1e-9),
      );
    });

    test('reports a loss as negative', () {
      const position = PortfolioPosition(
        holding: Holding(coinId: 'eth', amount: 2, averageBuyPrice: 4000),
        currentPrice: 3000,
      );
      expect(position.value, closeTo(6000, 1e-9));
      expect(position.profitLoss, closeTo(-2000, 1e-9));
      expect(position.profitLossPct, closeTo(-25, 1e-9));
    });

    test('guards against a zero cost basis instead of dividing by zero', () {
      const position = PortfolioPosition(
        holding: Holding(coinId: 'free', amount: 10, averageBuyPrice: 0),
        currentPrice: 5,
      );
      expect(position.costBasis, 0);
      expect(position.profitLoss, closeTo(50, 1e-9));
      expect(position.profitLossPct, 0);
    });
  });

  group('PortfolioSummary', () {
    test('sums value and cost, and derives total P/L', () {
      final summary = PortfolioSummary.from(const [
        PortfolioPosition(
          holding: Holding(coinId: 'a', amount: 2, averageBuyPrice: 100),
          currentPrice: 150,
        ),
        PortfolioPosition(
          holding: Holding(coinId: 'b', amount: 1, averageBuyPrice: 400),
          currentPrice: 300,
        ),
      ]);
      // value = 300 + 300 = 600 ; cost = 200 + 400 = 600.
      expect(summary.totalValue, closeTo(600, 1e-9));
      expect(summary.totalCost, closeTo(600, 1e-9));
      expect(summary.totalProfitLoss, closeTo(0, 1e-9));
      expect(summary.totalProfitLossPct, closeTo(0, 1e-9));
    });

    test('allocation is each position value over the total', () {
      final positions = const [
        PortfolioPosition(
          holding: Holding(coinId: 'a', amount: 1, averageBuyPrice: 1),
          currentPrice: 300,
        ),
        PortfolioPosition(
          holding: Holding(coinId: 'b', amount: 1, averageBuyPrice: 1),
          currentPrice: 100,
        ),
      ];
      final summary = PortfolioSummary.from(positions);
      expect(summary.allocationOf(positions[0]), closeTo(0.75, 1e-9));
      expect(summary.allocationOf(positions[1]), closeTo(0.25, 1e-9));
    });

    test('empty portfolio has zero totals and zero allocation', () {
      final summary = PortfolioSummary.from(const []);
      expect(summary.totalValue, 0);
      expect(summary.totalCost, 0);
      expect(summary.totalProfitLossPct, 0);
      expect(
        summary.allocationOf(
          const PortfolioPosition(
            holding: Holding(coinId: 'x', amount: 1, averageBuyPrice: 1),
            currentPrice: 1,
          ),
        ),
        0,
      );
    });
  });
}

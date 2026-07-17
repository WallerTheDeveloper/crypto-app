import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/utils/currency.dart';
import 'package:nova_project/core/utils/formatters.dart';

void main() {
  group('Formatters.fmt', () {
    test('grouped 2dp at and above 1000', () {
      expect(Formatters.fmt(1000, Currency.usd), r'$1,000.00');
      expect(Formatters.fmt(64210.33, Currency.usd), r'$64,210.33');
    });

    test('2dp between 1 and 1000, boundary at 999.99 / 1', () {
      expect(Formatters.fmt(999.99, Currency.usd), r'$999.99');
      expect(Formatters.fmt(1, Currency.usd), r'$1.00');
      expect(Formatters.fmt(36.74, Currency.usd), r'$36.74');
    });

    test('4dp below 1, including 0.99 and zero', () {
      expect(Formatters.fmt(0.99, Currency.usd), r'$0.9900');
      expect(Formatters.fmt(0.5821, Currency.usd), r'$0.5821');
      expect(Formatters.fmt(0, Currency.usd), r'$0.0000');
    });

    test('negatives keep the sign after the symbol', () {
      expect(Formatters.fmt(-64210.33, Currency.usd), r'$-64,210.33');
      expect(Formatters.fmt(-5, Currency.usd), r'$-5.00');
    });

    test('EUR converts and re-buckets on the converted value', () {
      // 2000 * 0.92 = 1840 -> grouped branch.
      expect(Formatters.fmt(2000, Currency.eur), '€1,840.00');
      // 100 * 0.92 = 92 -> 2dp branch.
      expect(Formatters.fmt(100, Currency.eur), '€92.00');
      expect(Formatters.fmt(-2000, Currency.eur), '€-1,840.00');
    });
  });

  group('Formatters.big', () {
    test('B / M / K buckets', () {
      expect(Formatters.big(28.4e9, Currency.usd), r'$28.40B');
      expect(Formatters.big(1e9, Currency.usd), r'$1.00B');
      expect(Formatters.big(1.26e6, Currency.usd), r'$1.26M');
      expect(Formatters.big(1e6, Currency.usd), r'$1.00M');
      expect(Formatters.big(1260, Currency.usd), r'$1.26K');
    });

    test('below 1000 is plain 2dp', () {
      expect(Formatters.big(500, Currency.usd), r'$500.00');
    });

    test('negatives fall through to the 2dp branch (no abs)', () {
      expect(Formatters.big(-5, Currency.usd), r'$-5.00');
      expect(Formatters.big(-2e9, Currency.usd), r'$-2000000000.00');
    });

    test('EUR converts before bucketing', () {
      // 1e9 * 0.92 = 920,000,000 -> M bucket.
      expect(Formatters.big(1e9, Currency.eur), '€920.00M');
    });
  });

  group('Formatters.compact', () {
    test('B / M buckets, symbol-less', () {
      expect(Formatters.compact(19.72e6), '19.72M');
      expect(Formatters.compact(55.1e9), '55.10B');
      expect(Formatters.compact(1e9), '1.00B');
      expect(Formatters.compact(1e6), '1.00M');
    });

    test('below 1e6 groups without forced decimals', () {
      expect(Formatters.compact(999999), '999,999');
      expect(Formatters.compact(1234), '1,234');
      expect(Formatters.compact(1234.5), '1,234.5');
    });
  });

  group('Formatters.changePct', () {
    test('signed to one decimal, plus for non-negative', () {
      expect(Formatters.changePct(2.4), '+2.4%');
      expect(Formatters.changePct(8.3), '+8.3%');
      expect(Formatters.changePct(0), '+0.0%');
    });

    test('negatives carry their own minus', () {
      expect(Formatters.changePct(-1.2), '-1.2%');
      expect(Formatters.changePct(-0.4), '-0.4%');
    });
  });
}

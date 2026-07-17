import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/features/market/domain/entities/chart_range.dart';
import 'package:nova_project/features/market/domain/entities/price_point.dart';

void main() {
  test('PricePoint value equality and hashCode', () {
    const a = PricePoint(index: 3, value: 0.5);
    expect(a, const PricePoint(index: 3, value: 0.5));
    expect(a == const PricePoint(index: 3, value: 0.6), isFalse);
    expect(a == const PricePoint(index: 4, value: 0.5), isFalse);
    expect(a.hashCode, const PricePoint(index: 3, value: 0.5).hashCode);
  });

  test('ChartRange carries the design labels and point counts', () {
    expect(ChartRange.h24.label, '24h');
    expect(ChartRange.h24.points, 30);
    expect(ChartRange.d7.points, 40);
    expect(ChartRange.d30.points, 44);
    expect(ChartRange.y1.points, 48);
  });
}

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/utils/smooth_path.dart';

void main() {
  const size = Size(64, 24);
  const List<double> values = [3, 4, 3.5, 5, 4.5, 6];

  test('line stays within the padded bounds', () {
    const pad = 3.0;
    final bounds = SmoothPath.line(values, size, pad: pad).getBounds();
    // Control points can overshoot slightly; allow a small margin.
    expect(bounds.left, greaterThanOrEqualTo(pad - 1));
    expect(bounds.right, lessThanOrEqualTo(size.width - pad + 1));
    expect(bounds.top, greaterThanOrEqualTo(pad - 2));
    expect(bounds.bottom, lessThanOrEqualTo(size.height - pad + 2));
  });

  test('area closes down to the bottom edge', () {
    final bounds = SmoothPath.area(values, size, pad: 3).getBounds();
    expect(bounds.bottom, size.height);
  });

  test('fewer than two points yields an empty path', () {
    expect(SmoothPath.line(const [], size).computeMetrics().isEmpty, isTrue);
    expect(SmoothPath.line(const [5], size).computeMetrics().isEmpty, isTrue);
  });

  test('a flat series does not divide by zero', () {
    final path = SmoothPath.line(const [2, 2, 2, 2], size, pad: 3);
    expect(path.computeMetrics().isEmpty, isFalse);
    expect(path.getBounds().height, lessThan(1));
  });
}

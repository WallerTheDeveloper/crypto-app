import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/mock/mock_config.dart';

void main() {
  test('default latency sits in the design 600-900ms window', () {
    const config = MockConfig();
    expect(config.latency.inMilliseconds, inInclusiveRange(600, 900));
    expect(config.failureRate, 0);
    expect(config.forceFailure, isFalse);
  });

  test('forceFailure always fails regardless of the roll', () {
    const config = MockConfig(forceFailure: true);
    expect(config.shouldFail(Random(1)), isTrue);
  });

  test('failureRate 0 never fails', () {
    const config = MockConfig();
    for (var seed = 0; seed < 20; seed++) {
      expect(config.shouldFail(Random(seed)), isFalse);
    }
  });

  test('failureRate 1 always fails', () {
    const config = MockConfig(failureRate: 1);
    expect(config.shouldFail(Random(7)), isTrue);
  });

  test('copyWith changes only the named field', () {
    const config = MockConfig();
    final faster = config.copyWith(latency: Duration.zero);
    expect(faster.latency, Duration.zero);
    expect(faster.failureRate, config.failureRate);
    expect(faster.forceFailure, config.forceFailure);
  });
}

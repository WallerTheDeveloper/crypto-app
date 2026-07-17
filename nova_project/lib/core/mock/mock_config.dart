import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug/test knobs for the mock data sources.
///
/// This is the seam that lets verification (task 11) reach all four screen
/// states and lets tests force the error path deterministically. It replaces
/// the prototype toolbar's state-selector — but as a test seam, **not** as UI.
///
/// It lives in `core` (the shared kernel that `data` depends on), so no layer
/// above `data` ever touches it.
class MockConfig {
  const MockConfig({
    this.latency = const Duration(milliseconds: 750),
    this.failureRate = 0,
    this.forceFailure = false,
  });

  /// Artificial delay applied to reads. Non-zero on purpose: without it,
  /// skeleton loading states never appear and are untestable. The default sits
  /// in the design's 600–900ms window.
  final Duration latency;

  /// Probability in `[0, 1]` that a read fails. `0` disables random failures.
  final double failureRate;

  /// When true, every read fails — the deterministic error-path switch.
  final bool forceFailure;

  /// Whether the next read should fail, given a source of randomness.
  ///
  /// [forceFailure] always wins; otherwise a roll under [failureRate] fails.
  bool shouldFail(Random random) =>
      forceFailure || (failureRate > 0 && random.nextDouble() < failureRate);

  MockConfig copyWith({
    Duration? latency,
    double? failureRate,
    bool? forceFailure,
  }) {
    return MockConfig(
      latency: latency ?? this.latency,
      failureRate: failureRate ?? this.failureRate,
      forceFailure: forceFailure ?? this.forceFailure,
    );
  }
}

/// The active [MockConfig]. Override it in tests (or a debug menu) to shorten
/// latency, inject failures, or force the error state.
final mockConfigProvider = Provider<MockConfig>((ref) => const MockConfig());

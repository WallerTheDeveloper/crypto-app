/// Deterministic chart-data generator, ported bit-for-bit from the design's
/// `hash` / `rng` / `series` helpers so charts are stable across rebuilds.
///
/// Pure Dart. The subtlety is 32-bit arithmetic: JavaScript's bitwise ops and
/// `Math.imul` work on 32-bit integers, but Dart ints are 64-bit. Every
/// multiply is masked back to 32 bits (`& _mask32`) — miss one and the
/// sequence silently diverges from the prototype.
///
/// On the Dart VM (where the app and tests run) integer multiplication wraps
/// modulo 2^64, so masking the low 32 bits after a multiply is exact even when
/// the untruncated product would overflow.
abstract final class PriceSeries {
  static const int _mask32 = 0xFFFFFFFF;

  /// FNV-1a 32-bit hash of [s]. Seeds [_mulberry32].
  ///
  /// `h = 2166136261`; per char `h ^= c; h = (h * 16777619) & 0xFFFFFFFF`.
  static int hash(String s) {
    var h = 2166136261;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 16777619) & _mask32;
    }
    return h & _mask32;
  }

  /// The prototype's mulberry32 PRNG. Returns a function yielding doubles in
  /// `[0, 1)`. Equivalent to the JS `>>> 0` / `Math.imul` version because every
  /// intermediate is kept as an unsigned 32-bit value.
  static double Function() _mulberry32(int seed) {
    var t = seed & _mask32;
    return () {
      t = (t + 0x6D2B79F5) & _mask32;
      var r = ((t ^ (t >>> 15)) * (1 | t)) & _mask32;
      r = (r + (((r ^ (r >>> 7)) * (61 | r)) & _mask32)) ^ r;
      r &= _mask32;
      return ((r ^ (r >>> 14)) & _mask32) / 4294967296.0;
    };
  }

  /// Generates [points] normalised values (starting near 0.5) with a slight
  /// drift set by [trendPct] (a coin's 24h % change).
  ///
  /// [seed] is the prototype's `id + range` string (e.g. `'btc24h'`), hashed to
  /// seed the PRNG. `trend = (trendPct / 100) * 3 / points`; start `v = 0.5`;
  /// each step `v += (r() - 0.5) * 0.11 + trend`.
  static List<double> generate({
    required String seed,
    required int points,
    required double trendPct,
  }) {
    final r = _mulberry32(hash(seed));
    final trend = (trendPct / 100) * 3 / points;
    final out = <double>[];
    var v = 0.5;
    for (var i = 0; i < points; i++) {
      v += (r() - 0.5) * 0.11 + trend;
      out.add(v);
    }
    return out;
  }
}

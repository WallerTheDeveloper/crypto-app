import 'dart:math' as math;
import 'dart:ui';

/// Builds smoothed line/area paths through a series of values.
///
/// This is a direct port of the `path()` helper in the design prototype: a
/// Catmull-Rom spline expressed as cubic béziers, so the sparkline ([Sparkline])
/// and the coin-detail chart curve stroke identically. Reuse this rather than
/// re-deriving the smoothing.
abstract final class SmoothPath {
  /// The smoothed line through [values], mapped into a [size]-sized rect and
  /// inset by [pad] on every edge.
  ///
  /// Values are normalised between their own min and max, so only the shape
  /// matters, not the absolute magnitudes. Returns an empty [Path] when fewer
  /// than two points are supplied.
  static Path line(List<double> values, Size size, {double pad = 0}) {
    final points = _points(values, size, pad);
    final path = Path();
    if (points.length < 2) return path;
    _appendCurve(path, points);
    return path;
  }

  /// The smoothed line plus a baseline back along the bottom edge, closed into
  /// a fillable area — the chart's gradient region.
  static Path area(List<double> values, Size size, {double pad = 0}) {
    final points = _points(values, size, pad);
    final path = Path();
    if (points.length < 2) return path;
    _appendCurve(path, points);
    path
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    return path;
  }

  static List<Offset> _points(List<double> values, Size size, double pad) {
    final n = values.length;
    if (n == 0) return const [];
    final mn = values.reduce(math.min);
    final mx = values.reduce(math.max);
    final span = (mx - mn) == 0 ? 1.0 : (mx - mn);
    final w = size.width;
    final h = size.height;
    return [
      for (var i = 0; i < n; i++)
        Offset(
          pad + (n == 1 ? 0 : i / (n - 1)) * (w - 2 * pad),
          pad + (1 - (values[i] - mn) / span) * (h - 2 * pad),
        ),
    ];
  }

  /// Appends a Catmull-Rom-through-bézier curve across [p] to [path], assuming
  /// the path's current point is already at `p.first`'s x/y is handled here.
  static void _appendCurve(Path path, List<Offset> p) {
    final n = p.length;
    path.moveTo(p[0].dx, p[0].dy);
    for (var i = 0; i < n - 1; i++) {
      final p0 = i > 0 ? p[i - 1] : p[i];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < n ? p[i + 2] : p2;
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
  }
}

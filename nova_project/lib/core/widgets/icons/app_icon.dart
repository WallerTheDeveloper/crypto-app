import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The line-icons used across the app.
///
/// The design draws these as inline SVG at stroke-width ~1.6–1.9 with round
/// caps and joins; Material's icon set has a visibly different weight, so the
/// paths are ported verbatim rather than substituted. Each type carries the
/// design's stroke width as its default.
enum AppIconType {
  market(1.9),
  portfolio(1.9),
  alerts(1.9),
  settings(1.9),
  search(1.8),
  back(1.9),
  plus(2),
  chevronRight(1.8),
  chevronDown(1.8),
  warning(1.7),
  check(3);

  const AppIconType(this.strokeWidth);

  /// Default stroke width, expressed in the 24×24 source coordinate space so it
  /// scales with the icon like the SVG viewBox does.
  final double strokeWidth;
}

/// A stroked line icon, painted from the ported design paths.
///
/// Dumb by design: [color] and [size] are supplied by the caller. Stroke width
/// defaults to the design value for [type] but can be overridden.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.type, {
    required this.color,
    this.size = 24,
    this.strokeWidth,
    super.key,
  });

  final AppIconType type;
  final Color color;
  final double size;

  /// Override for the stroke width, in 24×24 source units. Defaults to
  /// [AppIconType.strokeWidth].
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AppIconPainter(
          type: type,
          color: color,
          strokeWidth: strokeWidth ?? type.strokeWidth,
        ),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  _AppIconPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final AppIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Everything is authored in a 24×24 box; scale to the requested size.
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(_pathFor(type), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter old) =>
      old.type != type || old.color != color || old.strokeWidth != strokeWidth;
}

/// Builds the 24×24 [Path] for [type]. Circles use [Path.addOval]; arcs use
/// [Path.arcTo], matching the SVG arc commands in the design.
Path _pathFor(AppIconType type) {
  switch (type) {
    case AppIconType.market:
      // M3 17l5-5 3.5 3.5L20 7  M15 7h5v5
      return Path()
        ..moveTo(3, 17)
        ..lineTo(8, 12)
        ..lineTo(11.5, 15.5)
        ..lineTo(20, 7)
        ..moveTo(15, 7)
        ..lineTo(20, 7)
        ..lineTo(20, 12);
    case AppIconType.portfolio:
      // Two pie wedges around (12,12), r9 — a 3/4 arc plus the remaining quarter.
      final rect = Rect.fromCircle(center: const Offset(12, 12), radius: 9);
      return Path()
        ..arcTo(rect, 0, 3 * math.pi / 2, true)
        ..lineTo(12, 12)
        ..close()
        ..arcTo(rect, -math.pi / 2, math.pi / 2, true)
        ..lineTo(12, 12)
        ..close();
    case AppIconType.alerts:
      // Bell body + clapper.
      final bell = Path()
        ..moveTo(18, 8)
        ..arcTo(
          Rect.fromCircle(center: const Offset(12, 8), radius: 6),
          0,
          -math.pi,
          false,
        )
        ..cubicTo(6, 15, 3, 17, 3, 17)
        ..lineTo(21, 17)
        ..cubicTo(21, 17, 18, 15, 18, 8);
      final clapper = Path()
        ..moveTo(13.7, 21)
        ..arcTo(
          Rect.fromCircle(center: const Offset(12, 21), radius: 1.7),
          0,
          math.pi,
          false,
        );
      return bell..addPath(clapper, Offset.zero);
    case AppIconType.settings:
      // Sliders: four line stubs + two knob circles.
      return Path()
        ..moveTo(5, 8)
        ..lineTo(14, 8)
        ..moveTo(18, 8)
        ..lineTo(19, 8)
        ..moveTo(5, 16)
        ..lineTo(6, 16)
        ..moveTo(10, 16)
        ..lineTo(19, 16)
        ..addOval(Rect.fromCircle(center: const Offset(16, 8), radius: 2.3))
        ..addOval(Rect.fromCircle(center: const Offset(8, 16), radius: 2.3));
    case AppIconType.search:
      return Path()
        ..addOval(Rect.fromCircle(center: const Offset(11, 11), radius: 7))
        ..moveTo(20, 20)
        ..lineTo(16.5, 16.5);
    case AppIconType.back:
      // Chevron left: M15 6l-6 6 6 6
      return Path()
        ..moveTo(15, 6)
        ..lineTo(9, 12)
        ..lineTo(15, 18);
    case AppIconType.plus:
      return Path()
        ..moveTo(12, 5)
        ..lineTo(12, 19)
        ..moveTo(5, 12)
        ..lineTo(19, 12);
    case AppIconType.chevronRight:
      // M9 6l6 6-6 6
      return Path()
        ..moveTo(9, 6)
        ..lineTo(15, 12)
        ..lineTo(9, 18);
    case AppIconType.chevronDown:
      // M6 9l6 6 6-6
      return Path()
        ..moveTo(6, 9)
        ..lineTo(12, 15)
        ..lineTo(18, 9);
    case AppIconType.warning:
      // Exclamation inside a circle.
      return Path()
        ..moveTo(12, 8)
        ..lineTo(12, 13)
        ..moveTo(12, 16.5)
        ..lineTo(12, 17)
        ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));
    case AppIconType.check:
      // M5 12l5 5L20 6
      return Path()
        ..moveTo(5, 12)
        ..lineTo(10, 17)
        ..lineTo(20, 6);
  }
}

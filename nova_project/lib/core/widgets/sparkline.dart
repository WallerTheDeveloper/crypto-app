import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/smooth_path.dart';

/// A tiny smoothed price line — 60×24 by default, no fill, round caps/joins.
///
/// Stroke colour follows direction only: [positive] → `gain`, otherwise `loss`.
/// The caller never passes a colour, keeping the gain/loss rule intact. At this
/// size a [CustomPainter] is far cheaper than fl_chart, and it shares
/// [SmoothPath] with the coin-detail chart curve.
class Sparkline extends StatelessWidget {
  const Sparkline({
    required this.values,
    required this.positive,
    this.width = 60,
    this.height = 24,
    this.strokeWidth = 1.8,
    super.key,
  });

  final List<double> values;
  final bool positive;
  final double width;
  final double height;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        values: values,
        color: positive ? colors.gain : colors.loss,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(SmoothPath.line(values, size, pad: 3), paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      !identical(old.values, values);
}

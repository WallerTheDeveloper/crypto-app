import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// An animated shimmer placeholder box.
///
/// A horizontal `s1 → s2 → s1` gradient sweeps left-to-right on a 1.3s linear
/// loop — the design's `shimmer` keyframes. Screens shape their own skeletons
/// by sizing this box; leave [width] null to fill the available width.
///
/// This must animate: a static grey block is not this component.
class Skeleton extends StatefulWidget {
  const Skeleton({
    this.width,
    this.height,
    this.radius = 8,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // -1 → 1 shifts the 2-wide highlight window across the box.
        final dx = _controller.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(dx - 1, 0),
              end: Alignment(dx + 1, 0),
              colors: [colors.s1, colors.s2, colors.s1],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

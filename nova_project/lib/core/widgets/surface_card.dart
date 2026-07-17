import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../theme/app_colors.dart';

/// The workhorse card: `s1` fill, 1px `border`, radius 16.
///
/// Backs stat cards, alert rows and settings groups. Pass [onTap] to make it
/// tappable (e.g. the market portfolio-snapshot strip) with a matching ripple.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadii.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.s1,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

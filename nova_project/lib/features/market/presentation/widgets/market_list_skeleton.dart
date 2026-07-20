import 'package:flutter/material.dart';

import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton.dart';

/// The market loading state: it covers the whole screen — the snapshot strip and
/// the sort chips too, not just the rows — so nothing pops in piecemeal.
class MarketListSkeleton extends StatelessWidget {
  const MarketListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Snapshot strip.
        const Skeleton(height: 74, radius: AppRadii.card),
        const SizedBox(height: 18),
        // Two sort-chip pills.
        const Row(
          children: [
            Skeleton(width: 96, height: 32, radius: AppRadii.pill),
            SizedBox(width: 8),
            Skeleton(width: 78, height: 32, radius: AppRadii.pill),
          ],
        ),
        const SizedBox(height: 16),
        // Six row placeholders.
        for (var i = 0; i < 6; i++) const MarketSkeletonRow(),
      ],
    );
  }
}

/// A single 66px placeholder row: avatar circle, two text bars, a right block.
class MarketSkeletonRow extends StatelessWidget {
  const MarketSkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: AppSpacing.marketRow,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: const Row(
        children: [
          Skeleton(
            width: AppSpacing.avatarList,
            height: AppSpacing.avatarList,
            radius: AppRadii.pill,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 13,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.6,
                    child: Skeleton(radius: 6),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  height: 11,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.34,
                    child: Skeleton(radius: 6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 13),
          Skeleton(width: 80, height: 26, radius: 8),
        ],
      ),
    );
  }
}

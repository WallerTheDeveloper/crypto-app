import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/nav_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../portfolio/presentation/providers/portfolio_summary_provider.dart';
import '../../../settings/presentation/currency_providers.dart';

/// The tappable portfolio summary above the market list — total value and P/L,
/// tapping through to the Portfolio tab.
///
/// ⚠️ Design note: the prototype labels the P/L badge "Today" but feeds it the
/// all-time figure. The mock has no intraday history, so — per the owner's
/// call — this is labelled "All time" to match the number it actually shows.
/// Restore a real daily figure once intraday data exists (see task 05).
class PortfolioSnapshotStrip extends ConsumerWidget {
  const PortfolioSnapshotStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Holdings load locally and near-instantly; a brief skeleton covers the gap
    // (and the unlikely local read error) without a bespoke error surface here.
    return ref
        .watch(portfolioSummaryProvider)
        .maybeWhen(
          data: (summary) => _Strip(
            value: Formatters.fmt(
              summary.totalValue,
              ref.watch(currencyProvider),
            ),
            profitLossPct: summary.totalProfitLossPct,
          ),
          orElse: () => const Skeleton(height: 74, radius: AppRadii.card),
        );
  }
}

class _Strip extends ConsumerWidget {
  const _Strip({required this.value, required this.profitLossPct});

  final String value;
  final double profitLossPct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      onTap: () =>
          ref.read(navControllerProvider.notifier).selectTab(NavTab.portfolio),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flexible so a large value shrinks/ellipsizes on narrow screens
          // instead of overflowing; the P/L column keeps its natural width.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio value',
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: AppTypography.s12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: AppTypography.s26,
                    fontWeight: AppTypography.medium,
                    letterSpacing: AppTypography.trackTighter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'All time',
                style: TextStyle(
                  color: colors.muted,
                  fontSize: AppTypography.s12,
                ),
              ),
              const SizedBox(height: 6),
              PriceChangeBadge(profitLossPct, size: BadgeSize.large),
            ],
          ),
        ],
      ),
    );
  }
}

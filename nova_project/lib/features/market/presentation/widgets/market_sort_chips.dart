import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/market_sort.dart';
import '../providers/market_sort_notifier.dart';

/// The three market sort chips. Active chip is an `accent` pill with white text;
/// the rest are `s1` pills with a hairline border.
///
/// Watchlist is deferred (README#mvp-definition): it renders identically to the
/// other inactive chips but its tap is inert — it never becomes active and never
/// filters. It is shown, not hidden, because the design draws three chips.
class MarketSortChips extends ConsumerWidget {
  const MarketSortChips({super.key});

  static const List<(MarketSort, String)> _chips = [
    (MarketSort.marketCap, 'Market cap'),
    (MarketSort.gainers, 'Gainers'),
    (MarketSort.watchlist, 'Watchlist'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSortProvider);

    return Row(
      children: [
        for (var i = 0; i < _chips.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _Chip(
            label: _chips[i].$2,
            active: _chips[i].$1 == active,
            onTap: _chips[i].$1 == MarketSort.watchlist
                ? null
                : () => ref
                      .read(activeSortProvider.notifier)
                      .select(_chips[i].$1),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, this.onTap});

  final String label;
  final bool active;

  /// Null for the inert watchlist chip — it renders but does nothing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: active ? colors.accent : colors.s1,
      shape: StadiumBorder(
        side: active ? BorderSide.none : BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? Theme.of(context).colorScheme.onPrimary
                  : colors.text,
              fontSize: AppTypography.s13,
              fontWeight: active ? AppTypography.medium : AppTypography.regular,
            ),
          ),
        ),
      ),
    );
  }
}

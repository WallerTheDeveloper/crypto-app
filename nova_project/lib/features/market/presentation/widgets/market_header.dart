import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/icons/app_icon.dart';
import '../providers/market_search_notifier.dart';
import 'market_search_field.dart';

/// The market screen's custom header (not the shared screen title).
///
/// Brand mark + name on the left; a search icon and the fixed profile avatar on
/// the right. Tapping search swaps the whole row for an inline
/// [MarketSearchField]; dismissing it restores this header.
class MarketHeader extends ConsumerWidget {
  const MarketHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searching = ref.watch(marketSearchProvider.select((s) => s.active));
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 14),
      child: searching ? const MarketSearchField() : const _BrandRow(),
    );
  }
}

class _BrandRow extends ConsumerWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(AppRadii.logo),
              ),
              child: Text(
                AppConstants.logoGlyph,
                style: TextStyle(
                  color: onAccent,
                  fontSize: AppTypography.s15,
                  fontWeight: AppTypography.semibold,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              AppConstants.appName,
              style: TextStyle(
                color: colors.text,
                fontSize: AppTypography.s22,
                fontWeight: AppTypography.semibold,
                letterSpacing: AppTypography.trackTitle,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: AppIconType.search,
              iconSize: 18,
              onPressed: () => ref.read(marketSearchProvider.notifier).open(),
            ),
            const SizedBox(width: 14),
            const _ProfileAvatar(),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: colors.accentGradient,
        shape: BoxShape.circle,
      ),
      child: Text(
        AppConstants.profileInitials,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: AppTypography.s14,
          fontWeight: AppTypography.semibold,
          height: 1,
        ),
      ),
    );
  }
}

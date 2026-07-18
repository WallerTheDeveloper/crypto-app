import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../overlays/sheet_controller.dart';
import '../overlays/toast_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/icons/app_icon.dart';
import '../widgets/secondary_button.dart';
import 'nav_controller.dart';

// TEMPORARY. Tasks 05–10 replace these with the real feature screens; the shell
// swaps them in per tab. Until then they prove the shell wiring — nav switching,
// detail push, and that the sheet/toast hosts are reachable from any screen via
// their providers.

/// Stand-in for a tab screen: the screen title plus buttons that exercise the
/// overlay hosts from within a screen.
class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return AppScaffold(
      title: title,
      children: [
        Text(
          'Placeholder — replaced by its feature task.',
          style: TextStyle(color: colors.muted, fontSize: AppTypography.s13),
        ),
        const SizedBox(height: AppSpacing.xl),
        SecondaryButton(
          label: 'Open a coin',
          expand: true,
          onPressed: () =>
              ref.read(navControllerProvider.notifier).openDetail('bitcoin'),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Add holding sheet',
          expand: true,
          onPressed: () => ref
              .read(sheetControllerProvider.notifier)
              .open(SheetKind.addHolding),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Create alert sheet',
          expand: true,
          onPressed: () => ref
              .read(sheetControllerProvider.notifier)
              .open(SheetKind.createAlert),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Show toast',
          expand: true,
          onPressed: () =>
              ref.read(toastControllerProvider.notifier).show('$title tapped'),
        ),
      ],
    );
  }
}

/// Stand-in for coin detail (task 06): a back button that returns to Market and
/// the coin id, so the shell's detail route can be driven and tested now.
class CoinDetailPlaceholderScreen extends ConsumerWidget {
  const CoinDetailPlaceholderScreen({required this.coinId, super.key});

  final String coinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return AppScaffold(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 18),
        child: Row(
          children: [
            AppIconButton(
              icon: AppIconType.back,
              onPressed: () =>
                  ref.read(navControllerProvider.notifier).closeDetail(),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              coinId,
              style: TextStyle(
                color: colors.text,
                fontSize: AppTypography.s22,
                fontWeight: AppTypography.semibold,
                letterSpacing: AppTypography.trackTitle,
              ),
            ),
          ],
        ),
      ),
      children: [
        Text(
          'Coin detail placeholder — task 06.',
          style: TextStyle(color: colors.muted, fontSize: AppTypography.s13),
        ),
      ],
    );
  }
}

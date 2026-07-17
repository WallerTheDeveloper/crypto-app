import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';
import 'icons/app_icon.dart';
import 'primary_button.dart';

/// A centred empty state: icon well, title, body and an optional primary CTA.
///
/// Two presets, parameterised rather than forked:
/// - default — 74×74 `accentWell` well with an `accent` icon, 18px title, and
///   usually a CTA (portfolio, alerts).
/// - [compact] — 64×64 `s1` well with a `border` and `muted` icon, 16px title,
///   typically no CTA (market's "no results").
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final AppIconType icon;
  final String title;
  final String body;

  /// CTA label. When null (or [onAction] is null) no button is shown.
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final well = compact ? 64.0 : 74.0;
    final showAction = actionLabel != null && onAction != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 64,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: well,
              height: well,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: compact ? colors.s1 : colors.accentWell,
                borderRadius: BorderRadius.circular(AppRadii.well),
                border: compact ? Border.all(color: colors.border) : null,
              ),
              child: AppIcon(
                icon,
                color: compact ? colors.muted : colors.accent,
                size: compact ? 28 : 34,
                strokeWidth: 1.6,
              ),
            ),
            SizedBox(height: compact ? 18 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.text,
                fontSize: compact ? AppTypography.s16 : AppTypography.s18,
                fontWeight: AppTypography.medium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: AppTypography.s14,
                  height: 1.4,
                ),
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 28,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

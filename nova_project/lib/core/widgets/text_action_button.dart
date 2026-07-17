import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';
import 'icons/app_icon.dart';

/// The bare accent text action — an `accent` label with an optional leading
/// icon and no fill or border. The portfolio header's "+ Add" is the canonical
/// use.
class TextActionButton extends StatelessWidget {
  const TextActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIconType? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, color: colors.accent, size: 17, strokeWidth: 2),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: colors.accent,
                fontSize: AppTypography.s14,
                fontWeight: AppTypography.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

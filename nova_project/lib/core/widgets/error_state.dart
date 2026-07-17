import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';
import 'icons/app_icon.dart';
import 'primary_button.dart';

/// A centred error state: a 64×64 `lossWell` well with a `loss` warning icon, a
/// title, a message and a **Retry** button. Data-bound screens show this for
/// their error branch.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.lossWell,
                borderRadius: BorderRadius.circular(AppRadii.well),
              ),
              child: AppIcon(AppIconType.warning, color: colors.loss, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.text,
                fontSize: AppTypography.s16,
                fontWeight: AppTypography.medium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.muted,
                  fontSize: AppTypography.s14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: retryLabel,
              onPressed: onRetry,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
            ),
          ],
        ),
      ),
    );
  }
}

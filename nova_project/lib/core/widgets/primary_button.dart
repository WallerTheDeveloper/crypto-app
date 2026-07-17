import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';

/// The accent-filled call-to-action: `accent` fill, white label, radius 12.
///
/// [expand] stretches it to the full available width (standalone CTAs); inside
/// a row of equal buttons wrap it in an [Expanded] instead.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    this.fontSize = AppTypography.s15,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadii.control);

    final button = Material(
      color: colors.accent,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: fontSize,
              fontWeight: AppTypography.medium,
            ),
          ),
        ),
      ),
    );

    final sized = expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
    return Opacity(opacity: onPressed == null ? 0.5 : 1, child: sized);
  }
}

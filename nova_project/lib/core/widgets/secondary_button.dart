import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';

/// The outline action: transparent fill, `text` label, 1px `borderStrong`
/// border, radius 12. Shares [PrimaryButton]'s metrics so paired buttons align.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.borderStrong),
      ),
      child: Material(
        color: Colors.transparent,
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
                color: colors.text,
                fontSize: fontSize,
                fontWeight: AppTypography.medium,
              ),
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

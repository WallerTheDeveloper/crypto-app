import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import 'icons/app_icon.dart';

/// The 38×38 square icon button, radius 11.
///
/// Default: `s1` fill, 1px `border`, `text` icon (header search, detail back).
/// [accent] swaps to an `accent` fill with a white icon and no border (the
/// alerts "+" and other primary icon actions).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    this.accent = false,
    this.iconSize = 20,
    super.key,
  });

  final AppIconType icon;
  final VoidCallback? onPressed;
  final bool accent;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadii.iconButton);
    final iconColor = accent
        ? Theme.of(context).colorScheme.onPrimary
        : colors.text;

    return Material(
      color: accent ? colors.accent : colors.s1,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          width: AppSpacing.iconButton,
          height: AppSpacing.iconButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: accent ? null : Border.all(color: colors.border),
          ),
          child: AppIcon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }
}

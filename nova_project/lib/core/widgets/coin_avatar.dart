import 'package:flutter/material.dart';

import '../constants/app_typography.dart';

/// A circular coin badge: the coin's brand colour fill with its white glyph.
///
/// The brand [color] is *not* a theme token — Bitcoin is `#F7931A` in both
/// themes — so it arrives as a parameter (from the coin fixture) and is the one
/// sanctioned non-token colour painted in the app. Glyph weight is 600.
class CoinAvatar extends StatelessWidget {
  const CoinAvatar({
    required this.color,
    required this.glyph,
    this.size = 40,
    this.fontSize,
    super.key,
  });

  /// The coin's brand colour (from the fixture), used as the circle fill.
  final Color color;

  /// The coin glyph, e.g. `₿`, `Ξ`.
  final String glyph;
  final double size;

  /// Glyph size. Defaults to ~0.375× the avatar size (40 → 15).
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        glyph,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: fontSize ?? size * 0.375,
          fontWeight: AppTypography.semibold,
          height: 1,
        ),
      ),
    );
  }
}

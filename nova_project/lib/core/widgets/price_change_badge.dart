import 'package:flutter/widgets.dart';

import '../constants/app_radii.dart';
import '../constants/app_typography.dart';
import '../theme/app_colors.dart';

/// Badge sizes from the design: [small] for market rows and the snapshot strip,
/// [large] for coin detail and the portfolio hero.
enum BadgeSize {
  small(AppTypography.s12, EdgeInsets.symmetric(vertical: 4, horizontal: 9)),
  large(AppTypography.s14, EdgeInsets.symmetric(vertical: 6, horizontal: 12));

  const BadgeSize(this.fontSize, this.padding);

  final double fontSize;
  final EdgeInsets padding;
}

/// A pill that renders a signed change and enforces the gain/loss/neutral
/// colour rule.
///
/// The caller passes the signed [value]; the badge derives sign, colour and —
/// by default — the label. It is deliberately impossible to pass a colour, so
/// price movement can never be painted in `accent`:
///
/// - `value > 0` → `gain` on `gainSoft`, label `+2.4%`
/// - `value < 0` → `loss` on `lossSoft`, label `-1.2%`
/// - `value == 0` → `muted` on `mutedSoft`, label `0.0%`
///
/// [label] overrides only the text (e.g. a currency P/L like `+$1,234`); the
/// colour still follows the sign of [value], so the two can never disagree.
class PriceChangeBadge extends StatelessWidget {
  const PriceChangeBadge(
    this.value, {
    this.size = BadgeSize.small,
    this.label,
    super.key,
  });

  /// Signed change. Its sign selects gain / loss / neutral.
  final double value;
  final BadgeSize size;

  /// Optional text override. When null, the percent form of [value] is shown.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final (Color fg, Color bg) = switch (value.sign) {
      > 0 => (colors.gain, colors.gainSoft),
      < 0 => (colors.loss, colors.lossSoft),
      _ => (colors.muted, colors.mutedSoft),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: size.padding,
        child: Text(
          label ?? _formatPercent(value),
          style: TextStyle(
            color: fg,
            fontSize: size.fontSize,
            fontWeight: AppTypography.medium,
          ),
        ),
      ),
    );
  }

  /// Signed, one-decimal percent: `+2.4%`, `-1.2%`, `0.0%` (no sign at zero).
  static String _formatPercent(double value) {
    final sign = value > 0
        ? '+'
        : value < 0
            ? '-'
            : '';
    return '$sign${value.abs().toStringAsFixed(1)}%';
  }
}

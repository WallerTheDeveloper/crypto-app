import 'package:intl/intl.dart';

import 'currency.dart';

/// Number formatters ported verbatim from the design's `fmt` / `big` /
/// `compact` / `changePct` helpers.
///
/// These are pure functions used at the presentation edge to turn
/// currency-agnostic entity numbers into display strings. Entities hold raw
/// USD-denominated values; conversion to the active [Currency] happens here.
///
/// Grouping matches the prototype's `toLocaleString('en-US')`, so EUR still
/// groups with commas. If that reads wrong to the product owner, changing it is
/// a product call — not a silent fix here.
abstract final class Formatters {
  // Reused so we don't rebuild an ICU pattern on every call.
  static final NumberFormat _grouped2dp = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _grouped = NumberFormat.decimalPattern('en_US');

  /// Price formatting: convert, then pick precision by magnitude.
  ///
  /// `|x| >= 1000` → grouped, 2dp (`$64,210.33`); `|x| >= 1` → 2dp (`$36.74`);
  /// otherwise 4dp (`$0.5821`). Prefixed with the currency symbol.
  static String fmt(double n, Currency currency) {
    final x = n * currency.rate;
    final a = x.abs();
    final String digits;
    if (a >= 1000) {
      digits = _grouped2dp.format(x);
    } else if (a >= 1) {
      digits = x.toStringAsFixed(2);
    } else {
      digits = x.toStringAsFixed(4);
    }
    return '${currency.symbol}$digits';
  }

  /// Compact currency: `>= 1e9` → `$28.40B`; `>= 1e6` → `$1.26M`;
  /// `>= 1e3` → `$1.26K`; else 2dp.
  ///
  /// Unlike [fmt], this deliberately does *not* take an absolute value —
  /// negatives fall through to the 2dp branch, matching the prototype.
  static String big(double n, Currency currency) {
    final x = n * currency.rate;
    final s = currency.symbol;
    if (x >= 1e9) return '$s${(x / 1e9).toStringAsFixed(2)}B';
    if (x >= 1e6) return '$s${(x / 1e6).toStringAsFixed(2)}M';
    if (x >= 1e3) return '$s${(x / 1e3).toStringAsFixed(2)}K';
    return '$s${x.toStringAsFixed(2)}';
  }

  /// Compact, symbol-less magnitude used for supply counts.
  ///
  /// `>= 1e9` → `19.72B`; `>= 1e6` → `19.72M`; else grouped (no forced
  /// decimals). Not currency-converted — supply is a coin count, not money.
  static String compact(double n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
    return _grouped.format(n);
  }

  /// Signed percentage: `+2.4%`, `-1.2%`, `+0.0%`. One decimal place.
  ///
  /// The sign comes from the number itself for negatives; a `+` is prepended
  /// for non-negatives, matching the prototype's `(up?'+':'')` logic.
  static String changePct(double n) =>
      '${n >= 0 ? '+' : ''}${n.toStringAsFixed(1)}%';
}

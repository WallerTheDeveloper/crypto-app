import 'package:flutter/painting.dart';

/// Type scale from the design — Inter, three weights, and the exact sizes and
/// negative tracking used across the screens.
///
/// Weight 600 is reserved for screen titles, sheet titles, section labels and
/// coin glyphs (per `CLAUDE.md`); body and data use 400/500. Features reference
/// these constants instead of inlining `fontSize`/`fontWeight`.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  // --- Weights (three only) ---
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;

  // --- Sizes seen in the design ---
  static const double s11 = 11;
  static const double s12 = 12;
  static const double s13 = 13;
  static const double s14 = 14;
  static const double s15 = 15;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s26 = 26;
  static const double s33 = 33;
  static const double s44 = 44;

  // --- Letter spacing ---
  //
  // Large numerals get negative tracking; it grows with size and matters most
  // on the 44px portfolio hero value.
  static const double trackTight = -0.2;

  /// Screen / sheet titles (22–18px, weight 600).
  static const double trackTitle = -0.4;
  static const double trackTighter = -0.5;
  static const double trackHero = -1;
}

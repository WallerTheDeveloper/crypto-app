import 'package:flutter/material.dart';

import '../constants/app_typography.dart';
import 'app_colors.dart';

/// The two selectable themes. [AppTheme.dark] is the default (theme A in the
/// prototype).
enum AppTheme {
  /// A · Dark vibrant.
  dark,

  /// B · Warm playful.
  playful,
}

/// Builds the [ThemeData] for each [AppTheme] and holds the two token sets.
///
/// The hex literals below are the *only* place color is defined; everything
/// downstream reads [AppColors] off the theme. Values are lifted verbatim from
/// `THEMES` in the design file — do not "improve" them.
abstract final class AppThemes {
  /// A · Dark vibrant.
  static const AppColors darkColors = AppColors(
    bg: Color(0xFF0D0B1A),
    s1: Color(0xFF16122B),
    s2: Color(0xFF1E1838),
    border: Color(0xFF2A2247),
    borderStrong: Color(0xFF3A3157),
    text: Color(0xFFF0EDFF),
    muted: Color(0xFF9B8CE0),
    accent: Color(0xFFB14BFF),
    gain: Color(0xFF00F5A0),
    loss: Color(0xFFFF5C7A),
  );

  /// B · Warm playful.
  static const AppColors playfulColors = AppColors(
    bg: Color(0xFFFFF7F0),
    s1: Color(0xFFFFFFFF),
    s2: Color(0xFFFFFCF8),
    border: Color(0xFFF2E2D4),
    borderStrong: Color(0xFFE8D5C4),
    text: Color(0xFF3A2A1E),
    muted: Color(0xFFB08968),
    accent: Color(0xFFE8724C),
    gain: Color(0xFF1D9E75),
    loss: Color(0xFFE24B4A),
  );

  /// The [AppColors] for [theme].
  static AppColors colorsOf(AppTheme theme) =>
      theme == AppTheme.dark ? darkColors : playfulColors;

  /// The [ThemeData] for [theme].
  static ThemeData of(AppTheme theme) => theme == AppTheme.dark
      ? _build(darkColors, Brightness.dark)
      : _build(playfulColors, Brightness.light);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
    );
    return base.copyWith(
      scaffoldBackgroundColor: colors.bg,
      colorScheme: _scheme(colors, brightness),
      textTheme: base.textTheme.apply(
        bodyColor: colors.text,
        displayColor: colors.text,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  /// A [ColorScheme] wired from tokens so stock Material widgets don't look
  /// alien. Features read [AppColors], not this — text on [AppColors.accent]
  /// is white in both themes.
  static ColorScheme _scheme(AppColors colors, Brightness brightness) {
    const onAccent = Color(0xFFFFFFFF);
    return ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: onAccent,
      secondary: colors.accent,
      onSecondary: onAccent,
      error: colors.loss,
      onError: onAccent,
      surface: colors.s1,
      onSurface: colors.text,
    );
  }
}

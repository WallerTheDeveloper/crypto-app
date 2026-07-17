import 'package:flutter/material.dart';

/// The ten semantic color tokens, carried on [ThemeData] as a
/// [ThemeExtension] so features read colors through the theme rather than
/// hardcoding hex.
///
/// This is the single source of truth for color. The two concrete token sets
/// (dark / playful) live in `app_theme.dart`; nothing outside `core/theme/`
/// writes a hex literal.
///
/// Reach the active tokens from a widget with `context.colors` (see
/// [AppColorsX]).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.s1,
    required this.s2,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.muted,
    required this.accent,
    required this.gain,
    required this.loss,
  });

  /// Page background.
  final Color bg;

  /// Surface 1 — cards, nav.
  final Color s1;

  /// Surface 2 — raised/inner surfaces.
  final Color s2;

  /// Hairline border.
  final Color border;

  /// Stronger border for emphasis.
  final Color borderStrong;

  /// Primary text.
  final Color text;

  /// Secondary / muted text.
  final Color muted;

  /// Interactive accent — buttons, active tabs/chips, selected states.
  /// Never used to encode price movement.
  final Color accent;

  /// Price up / profit.
  final Color gain;

  /// Price down / loss.
  final Color loss;

  // --- Derived colors ---
  //
  // The design derives these with CSS `color-mix`. `color-mix(X n%, transparent)`
  // is simply X at n% alpha; `color-mix(X 40%, #000)` is X scaled toward black.
  // Helpers keep the math in one place instead of scattering alpha values.

  /// Gain badge background — gain at 15% alpha.
  Color get gainSoft => gain.withValues(alpha: 0.15);

  /// Loss badge background — loss at 15% alpha.
  Color get lossSoft => loss.withValues(alpha: 0.15);

  /// Error-state icon well — loss at 14% alpha.
  Color get lossWell => loss.withValues(alpha: 0.14);

  /// Empty-state icon well — accent at 12% alpha.
  Color get accentWell => accent.withValues(alpha: 0.12);

  /// Neutral (0.0%) badge background — muted at 15% alpha.
  Color get mutedSoft => muted.withValues(alpha: 0.15);

  /// Chart area gradient top (gain direction) — gain at 34% alpha.
  Color get gainFill => gain.withValues(alpha: 0.34);

  /// Chart area gradient top (loss direction) — loss at 34% alpha.
  Color get lossFill => loss.withValues(alpha: 0.34);

  /// Bottom nav surface over blur — s1 at 92% alpha.
  Color get navSurface => s1.withValues(alpha: 0.92);

  /// Accent scaled toward black at 40/60 — the dark stop of [accentGradient].
  /// `color-mix(in srgb, accent 40%, #000)` mixes 40% accent with 60% black,
  /// which in sRGB is each channel multiplied by 0.4.
  Color get _accentShade => Color.from(
    alpha: 1,
    red: accent.r * 0.4,
    green: accent.g * 0.4,
    blue: accent.b * 0.4,
  );

  /// Avatar gradient — `linear-gradient(135deg, accent, mix(accent 40%, #000))`.
  /// 135deg runs top-left → bottom-right.
  LinearGradient get accentGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, _accentShade],
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? s1,
    Color? s2,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? muted,
    Color? accent,
    Color? gain,
    Color? loss,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      gain: gain ?? this.gain,
      loss: loss ?? this.loss,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      s1: Color.lerp(s1, other.s1, t)!,
      s2: Color.lerp(s2, other.s2, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppColors &&
        other.bg == bg &&
        other.s1 == s1 &&
        other.s2 == s2 &&
        other.border == border &&
        other.borderStrong == borderStrong &&
        other.text == text &&
        other.muted == muted &&
        other.accent == accent &&
        other.gain == gain &&
        other.loss == loss;
  }

  @override
  int get hashCode => Object.hash(
    bg,
    s1,
    s2,
    border,
    borderStrong,
    text,
    muted,
    accent,
    gain,
    loss,
  );
}

/// Reads the active [AppColors] off the theme: `context.colors.accent`.
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

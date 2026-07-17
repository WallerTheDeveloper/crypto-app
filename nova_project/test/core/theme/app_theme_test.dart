import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_colors.dart';
import 'package:nova_project/core/theme/app_theme.dart';

void main() {
  group('token values match the design byte-for-byte', () {
    test('A · dark vibrant', () {
      const c = AppThemes.darkColors;
      expect(c.bg, const Color(0xFF0D0B1A));
      expect(c.s1, const Color(0xFF16122B));
      expect(c.s2, const Color(0xFF1E1838));
      expect(c.border, const Color(0xFF2A2247));
      expect(c.borderStrong, const Color(0xFF3A3157));
      expect(c.text, const Color(0xFFF0EDFF));
      expect(c.muted, const Color(0xFF9B8CE0));
      expect(c.accent, const Color(0xFFB14BFF));
      expect(c.gain, const Color(0xFF00F5A0));
      expect(c.loss, const Color(0xFFFF5C7A));
    });

    test('B · warm playful', () {
      const c = AppThemes.playfulColors;
      expect(c.bg, const Color(0xFFFFF7F0));
      expect(c.s1, const Color(0xFFFFFFFF));
      expect(c.s2, const Color(0xFFFFFCF8));
      expect(c.border, const Color(0xFFF2E2D4));
      expect(c.borderStrong, const Color(0xFFE8D5C4));
      expect(c.text, const Color(0xFF3A2A1E));
      expect(c.muted, const Color(0xFFB08968));
      expect(c.accent, const Color(0xFFE8724C));
      expect(c.gain, const Color(0xFF1D9E75));
      expect(c.loss, const Color(0xFFE24B4A));
    });
  });

  group('ThemeData exposes AppColors', () {
    for (final theme in AppTheme.values) {
      test('${theme.name}: all ten tokens present via the extension', () {
        final colors = AppThemes.of(theme).extension<AppColors>();
        expect(colors, isNotNull);
        expect(colors, AppThemes.colorsOf(theme));
      });
    }

    test('the two themes are distinct on every token', () {
      const a = AppThemes.darkColors;
      const b = AppThemes.playfulColors;
      final pairs = <List<Color>>[
        [a.bg, b.bg],
        [a.s1, b.s1],
        [a.s2, b.s2],
        [a.border, b.border],
        [a.borderStrong, b.borderStrong],
        [a.text, b.text],
        [a.muted, b.muted],
        [a.accent, b.accent],
        [a.gain, b.gain],
        [a.loss, b.loss],
      ];
      for (final pair in pairs) {
        expect(pair.first, isNot(pair.last));
      }
    });
  });

  group('ThemeData wiring', () {
    test('dark is Brightness.dark, playful is Brightness.light', () {
      expect(AppThemes.of(AppTheme.dark).brightness, Brightness.dark);
      expect(AppThemes.of(AppTheme.playful).brightness, Brightness.light);
    });

    test('scaffold background and Inter font are wired from tokens', () {
      final theme = AppThemes.of(AppTheme.dark);
      expect(theme.scaffoldBackgroundColor, AppThemes.darkColors.bg);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    });
  });
}

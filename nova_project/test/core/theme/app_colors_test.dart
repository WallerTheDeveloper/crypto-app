import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';

void main() {
  const a = AppThemes.darkColors;
  const b = AppThemes.playfulColors;

  group('copyWith', () {
    test('overrides only the given field, keeps the rest', () {
      const red = Color(0xFFFF0000);
      final result = a.copyWith(accent: red);

      expect(result.accent, red);
      expect(result.bg, a.bg);
      expect(result.s1, a.s1);
      expect(result.s2, a.s2);
      expect(result.border, a.border);
      expect(result.borderStrong, a.borderStrong);
      expect(result.text, a.text);
      expect(result.muted, a.muted);
      expect(result.gain, a.gain);
      expect(result.loss, a.loss);
    });

    test('no args returns an equal instance', () {
      expect(a.copyWith(), a);
    });
  });

  group('lerp', () {
    test('t=0 is this, t=1 is other, on every token', () {
      final at0 = a.lerp(b, 0);
      final at1 = a.lerp(b, 1);

      expect(at0, a);
      expect(at1, b);
    });

    test('t=0.5 sits between the two on a sample token', () {
      final mid = a.lerp(b, 0.5);
      expect(mid.bg, Color.lerp(a.bg, b.bg, 0.5));
      expect(mid.accent, Color.lerp(a.accent, b.accent, 0.5));
    });

    test('drops no field — half-way tokens differ from both ends', () {
      final mid = a.lerp(b, 0.5);
      expect(mid, isNot(a));
      expect(mid, isNot(b));
    });

    test('other of wrong type returns this', () {
      expect(a.lerp(null, 0.5), a);
    });
  });

  group('derived colors', () {
    test('soft/well/fill helpers apply the expected alpha', () {
      expect(a.gainSoft, a.gain.withValues(alpha: 0.15));
      expect(a.lossSoft, a.loss.withValues(alpha: 0.15));
      expect(a.lossWell, a.loss.withValues(alpha: 0.14));
      expect(a.accentWell, a.accent.withValues(alpha: 0.12));
      expect(a.mutedSoft, a.muted.withValues(alpha: 0.15));
      expect(a.gainFill, a.gain.withValues(alpha: 0.34));
      expect(a.lossFill, a.loss.withValues(alpha: 0.34));
      expect(a.navSurface, a.s1.withValues(alpha: 0.92));
    });

    test('accentGradient runs from accent to accent scaled toward black', () {
      final gradient = a.accentGradient;

      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
      expect(gradient.colors.first, a.accent);

      final shade = gradient.colors.last;
      expect(shade.r, closeTo(a.accent.r * 0.4, 1e-6));
      expect(shade.g, closeTo(a.accent.g * 0.4, 1e-6));
      expect(shade.b, closeTo(a.accent.b * 0.4, 1e-6));
      expect(shade.a, 1);
    });
  });

  group('equality', () {
    test('same tokens are equal and share a hashCode', () {
      final copy = a.copyWith();
      expect(copy, a);
      expect(copy.hashCode, a.hashCode);
    });

    test('the two themes are not equal', () {
      expect(a, isNot(b));
    });
  });
}

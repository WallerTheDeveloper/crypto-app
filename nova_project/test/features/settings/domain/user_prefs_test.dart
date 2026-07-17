import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/utils/currency.dart';
import 'package:nova_project/features/settings/data/models/user_prefs_model.dart';
import 'package:nova_project/features/settings/domain/entities/user_prefs.dart';

void main() {
  const prefs = UserPrefs(
    themeId: 'dark',
    currency: Currency.usd,
    notificationsEnabled: true,
  );

  test('copyWith changes only the named field', () {
    final playful = prefs.copyWith(themeId: 'playful');
    expect(playful.themeId, 'playful');
    expect(playful.currency, Currency.usd);
    expect(playful.notificationsEnabled, isTrue);
  });

  test('value equality', () {
    expect(prefs, prefs.copyWith());
    expect(prefs == prefs.copyWith(currency: Currency.eur), isFalse);
    expect(prefs.hashCode, prefs.copyWith().hashCode);
  });

  test('model round-trips through JSON and entity, preserving currency', () {
    final model = UserPrefsModel.fromEntity(
      prefs.copyWith(currency: Currency.eur),
    );
    final restored = UserPrefsModel.fromJson(model.toJson()).toEntity();
    expect(restored.currency, Currency.eur);
    expect(restored.themeId, 'dark');
  });

  test('currency enum carries the design rate and symbols', () {
    expect(Currency.usd.rate, 1.0);
    expect(Currency.eur.rate, kEurUsdRate);
    expect(Currency.usd.symbol, r'$');
    expect(Currency.eur.symbol, '€');
  });
}

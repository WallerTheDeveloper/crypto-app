import '../../../../core/utils/currency.dart';
import '../../domain/entities/user_prefs.dart';

/// Data-layer representation of [UserPrefs], with JSON (de)serialisation for the
/// `prefs` Hive box. [Currency] is stored as its name string.
class UserPrefsModel {
  const UserPrefsModel({
    required this.themeId,
    required this.currency,
    required this.notificationsEnabled,
  });

  factory UserPrefsModel.fromEntity(UserPrefs prefs) => UserPrefsModel(
    themeId: prefs.themeId,
    currency: prefs.currency.name,
    notificationsEnabled: prefs.notificationsEnabled,
  );

  factory UserPrefsModel.fromJson(Map<String, dynamic> json) => UserPrefsModel(
    themeId: json['themeId'] as String,
    currency: json['currency'] as String,
    notificationsEnabled: json['notificationsEnabled'] as bool,
  );

  final String themeId;

  /// The [Currency] name — `usd` or `eur`.
  final String currency;
  final bool notificationsEnabled;

  UserPrefs toEntity() => UserPrefs(
    themeId: themeId,
    currency: Currency.values.byName(currency),
    notificationsEnabled: notificationsEnabled,
  );

  Map<String, dynamic> toJson() => {
    'themeId': themeId,
    'currency': currency,
    'notificationsEnabled': notificationsEnabled,
  };
}

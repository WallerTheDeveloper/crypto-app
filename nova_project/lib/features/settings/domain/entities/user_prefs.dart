import '../../../../core/utils/currency.dart';

/// The user's app preferences.
///
/// [themeId] is stored as a string (matching the theme enum's `name`) so
/// `domain` need not depend on the theme type; presentation maps it back.
/// Immutable — changing a preference produces a new instance via [copyWith].
class UserPrefs {
  const UserPrefs({
    required this.themeId,
    required this.currency,
    required this.notificationsEnabled,
  });

  /// The active theme's id (e.g. `dark`, `playful`).
  final String themeId;

  /// The display currency.
  final Currency currency;

  /// Whether push/price notifications are enabled.
  final bool notificationsEnabled;

  UserPrefs copyWith({
    String? themeId,
    Currency? currency,
    bool? notificationsEnabled,
  }) {
    return UserPrefs(
      themeId: themeId ?? this.themeId,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserPrefs &&
      other.themeId == themeId &&
      other.currency == currency &&
      other.notificationsEnabled == notificationsEnabled;

  @override
  int get hashCode => Object.hash(themeId, currency, notificationsEnabled);
}

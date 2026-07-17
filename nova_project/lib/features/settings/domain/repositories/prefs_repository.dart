import '../../../../core/utils/currency.dart';
import '../entities/user_prefs.dart';

/// Read/write access to the user's preferences.
///
/// [watchPrefs] is a stream so the app reacts to preference changes the same
/// way it will when prefs sync from Firestore later.
///
/// Note: theme is *also* persisted by the core `ThemeController` today. Task 10
/// (settings) reconciles the two into a single source of truth; until then this
/// repository owns the full [UserPrefs] record.
abstract interface class PrefsRepository {
  /// Emits the current preferences, and again on every change.
  Stream<UserPrefs> watchPrefs();

  /// Sets the active theme id.
  Future<void> setTheme(String themeId);

  /// Sets the display currency.
  Future<void> setCurrency(Currency currency);

  /// Enables or disables notifications.
  Future<void> setNotifications(bool enabled);
}

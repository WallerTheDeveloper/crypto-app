import '../models/user_prefs_model.dart';

/// First-run default preferences: dark theme (A), USD, notifications on —
/// matching the prototype's initial state.
///
/// Written to the `prefs` box once, on first launch only. After the user
/// changes a preference, their choice wins.
abstract final class PrefsFixtures {
  static const UserPrefsModel defaults = UserPrefsModel(
    themeId: 'dark',
    currency: 'usd',
    notificationsEnabled: true,
  );
}

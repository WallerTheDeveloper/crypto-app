import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'theme_store.dart';

/// Supplies the [ThemeStore]. Overridden in `main` with a [HiveThemeStore]
/// once the `prefs` box is open, and overridden with a fake in tests.
final themeStoreProvider = Provider<ThemeStore>((ref) {
  throw UnimplementedError(
    'themeStoreProvider must be overridden with a ThemeStore in main().',
  );
});

/// Holds the active [AppTheme] and persists changes through the [ThemeStore].
///
/// The initial value is read synchronously from the store, so the first frame
/// already shows the persisted theme.
class ThemeController extends Notifier<AppTheme> {
  @override
  AppTheme build() => ref.read(themeStoreProvider).read();

  /// Switches to [theme] and persists it. No-op if already active.
  Future<void> setTheme(AppTheme theme) async {
    if (theme == state) return;
    state = theme;
    await ref.read(themeStoreProvider).write(theme);
  }

  /// Toggles between the two themes.
  Future<void> toggle() {
    return setTheme(state == AppTheme.dark ? AppTheme.playful : AppTheme.dark);
  }
}

/// The active theme. `MaterialApp` watches this; the Settings screen drives it.
final themeControllerProvider = NotifierProvider<ThemeController, AppTheme>(
  ThemeController.new,
);

import 'package:hive_ce/hive.dart';

import 'app_theme.dart';

/// Reads and writes the persisted theme choice.
///
/// An abstraction so the controller depends on the interface, not Hive, and
/// tests can supply a fake. The concrete [HiveThemeStore] is wired in `main`.
abstract interface class ThemeStore {
  /// The saved theme, or [AppTheme.dark] (default A) when nothing is saved.
  AppTheme read();

  /// Persists [theme].
  Future<void> write(AppTheme theme);
}

/// [ThemeStore] backed by the already-open Hive `prefs` box.
///
/// [read] is synchronous — the box is opened at startup before `runApp`, so
/// the app can pick the right theme on the first frame with no flash.
class HiveThemeStore implements ThemeStore {
  const HiveThemeStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'theme';

  @override
  AppTheme read() {
    final raw = _box.get(_key);
    return AppTheme.values.firstWhere(
      (theme) => theme.name == raw,
      orElse: () => AppTheme.dark,
    );
  }

  @override
  Future<void> write(AppTheme theme) => _box.put(_key, theme.name);
}

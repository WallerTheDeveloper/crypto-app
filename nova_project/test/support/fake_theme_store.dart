import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/theme/theme_store.dart';

/// In-memory [ThemeStore] for tests — no Hive. Starts empty (so [read] returns
/// the default) unless seeded with [initial].
class FakeThemeStore implements ThemeStore {
  FakeThemeStore([this._saved]);

  AppTheme? _saved;

  /// The last value written, or null if nothing has been written.
  AppTheme? get saved => _saved;

  @override
  AppTheme read() => _saved ?? AppTheme.dark;

  @override
  Future<void> write(AppTheme theme) async => _saved = theme;
}

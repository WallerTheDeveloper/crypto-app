import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:nova_project/core/utils/currency.dart';
import 'package:nova_project/features/settings/data/datasources/prefs_local_data_source.dart';
import 'package:nova_project/features/settings/data/repositories/prefs_repository_impl.dart';

import '../../../support/hive_test_env.dart';

void main() {
  late HiveTestEnv env;
  late Box<dynamic> box;
  late PrefsRepositoryImpl repo;

  setUp(() async {
    env = await HiveTestEnv.start();
    box = await env.openBox('prefs');
    repo = PrefsRepositoryImpl(PrefsLocalDataSource(box));
  });

  tearDown(() => env.dispose());

  test(
    'seeds defaults on first run: dark theme, USD, notifications on',
    () async {
      final prefs = await repo.watchPrefs().first;
      expect(prefs.themeId, 'dark');
      expect(prefs.currency, Currency.usd);
      expect(prefs.notificationsEnabled, isTrue);
    },
  );

  test('setTheme updates only the theme', () async {
    await repo.watchPrefs().first;
    await repo.setTheme('playful');
    final prefs = await repo.watchPrefs().first;
    expect(prefs.themeId, 'playful');
    expect(prefs.currency, Currency.usd);
    expect(prefs.notificationsEnabled, isTrue);
  });

  test('setCurrency updates only the currency', () async {
    await repo.watchPrefs().first;
    await repo.setCurrency(Currency.eur);
    final prefs = await repo.watchPrefs().first;
    expect(prefs.currency, Currency.eur);
    expect(prefs.themeId, 'dark');
  });

  test('setNotifications updates only the flag', () async {
    await repo.watchPrefs().first;
    await repo.setNotifications(false);
    final prefs = await repo.watchPrefs().first;
    expect(prefs.notificationsEnabled, isFalse);
    expect(prefs.themeId, 'dark');
  });

  test('watch re-emits after a change', () async {
    final themes = <String>[];
    final sub = repo.watchPrefs().listen((p) => themes.add(p.themeId));
    addTearDown(sub.cancel);

    await pumpUntil(() => themes.isNotEmpty);
    expect(themes, contains('dark'));

    await repo.setTheme('playful');
    await pumpUntil(() => themes.contains('playful'));
    expect(themes.last, 'playful');
  });

  test('choices survive a restart', () async {
    await repo.watchPrefs().first;
    await repo.setTheme('playful');
    await repo.setCurrency(Currency.eur);

    final reopened = PrefsRepositoryImpl(PrefsLocalDataSource(box));
    final prefs = await reopened.watchPrefs().first;
    expect(prefs.themeId, 'playful');
    expect(prefs.currency, Currency.eur);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/theme/app_theme.dart';
import 'package:nova_project/core/theme/theme_controller.dart';

import '../../support/fake_theme_store.dart';

ProviderContainer _container(FakeThemeStore store) {
  final container = ProviderContainer(
    overrides: [themeStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('default theme is A (dark) when nothing is persisted', () {
    final container = _container(FakeThemeStore());
    expect(container.read(themeControllerProvider), AppTheme.dark);
  });

  test('a cold start with a persisted B starts on B', () {
    final container = _container(FakeThemeStore(AppTheme.playful));
    expect(container.read(themeControllerProvider), AppTheme.playful);
  });

  test('setTheme updates state and persists', () async {
    final store = FakeThemeStore();
    final container = _container(store);
    final controller = container.read(themeControllerProvider.notifier);

    await controller.setTheme(AppTheme.playful);

    expect(container.read(themeControllerProvider), AppTheme.playful);
    expect(store.saved, AppTheme.playful);
  });

  test('toggle flips between the two themes and persists each flip', () async {
    final store = FakeThemeStore();
    final container = _container(store);
    final controller = container.read(themeControllerProvider.notifier);

    await controller.toggle();
    expect(container.read(themeControllerProvider), AppTheme.playful);
    expect(store.saved, AppTheme.playful);

    await controller.toggle();
    expect(container.read(themeControllerProvider), AppTheme.dark);
    expect(store.saved, AppTheme.dark);
  });

  test('setTheme to the current theme does not re-persist', () async {
    final store = FakeThemeStore();
    final container = _container(store);
    final controller = container.read(themeControllerProvider.notifier);

    // Already on dark; setting dark again should be a no-op (nothing written).
    await controller.setTheme(AppTheme.dark);
    expect(store.saved, isNull);
  });
}

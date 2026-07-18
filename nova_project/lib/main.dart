import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/constants/hive_boxes.dart';
import 'core/navigation/nav_shell.dart';
import 'core/persistence/box_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  for (final box in HiveBoxes.all) {
    await Hive.openBox<dynamic>(box);
  }

  // Read the persisted theme before the first frame so the app never flashes
  // the wrong theme on launch.
  final themeStore = HiveThemeStore(Hive.box<dynamic>(HiveBoxes.prefs));

  runApp(
    ProviderScope(
      overrides: [
        themeStoreProvider.overrideWithValue(themeStore),
        // Bind each box provider to its already-open box so the data layer can
        // reach Hive without touching global state.
        holdingsBoxProvider.overrideWithValue(
          Hive.box<dynamic>(HiveBoxes.holdings),
        ),
        alertsBoxProvider.overrideWithValue(
          Hive.box<dynamic>(HiveBoxes.alerts),
        ),
        prefsBoxProvider.overrideWithValue(Hive.box<dynamic>(HiveBoxes.prefs)),
        marketCacheBoxProvider.overrideWithValue(
          Hive.box<dynamic>(HiveBoxes.marketCache),
        ),
      ],
      child: const NovaApp(),
    ),
  );
}

class NovaApp extends ConsumerWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Nova',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.of(theme),
      home: const NavShell(),
    );
  }
}

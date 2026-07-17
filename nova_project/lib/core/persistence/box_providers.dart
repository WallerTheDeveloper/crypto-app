import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

/// Providers for the already-open Hive boxes.
///
/// The boxes are opened in `main` before `runApp`; each provider is overridden
/// there with its concrete [Box]. Data sources depend on these providers rather
/// than reaching for `Hive.box(...)` directly, so tests can supply in-memory or
/// temp-dir boxes without touching global Hive state.
///
/// Only the `data` layer reads these. Nothing above `data/` imports this file.

/// Portfolio holdings box.
final holdingsBoxProvider = Provider<Box<dynamic>>(
  (ref) => throw UnimplementedError('override holdingsBoxProvider in main()'),
);

/// Price alerts box.
final alertsBoxProvider = Provider<Box<dynamic>>(
  (ref) => throw UnimplementedError('override alertsBoxProvider in main()'),
);

/// User preferences box (theme, currency, notifications).
final prefsBoxProvider = Provider<Box<dynamic>>(
  (ref) => throw UnimplementedError('override prefsBoxProvider in main()'),
);

/// Last-successful market response, for cache-then-network reads.
final marketCacheBoxProvider = Provider<Box<dynamic>>(
  (ref) =>
      throw UnimplementedError('override marketCacheBoxProvider in main()'),
);

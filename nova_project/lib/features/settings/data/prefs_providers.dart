import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/box_providers.dart';
import '../domain/repositories/prefs_repository.dart';
import 'datasources/prefs_local_data_source.dart';
import 'repositories/prefs_repository_impl.dart';

/// Composition root for the settings feature's data layer.
/// [prefsRepositoryProvider] is typed as the domain interface.

final prefsLocalDataSourceProvider = Provider<PrefsLocalDataSource>((ref) {
  return PrefsLocalDataSource(ref.watch(prefsBoxProvider));
});

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) {
  return PrefsRepositoryImpl(ref.watch(prefsLocalDataSourceProvider));
});

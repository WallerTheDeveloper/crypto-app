import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/box_providers.dart';
import '../domain/repositories/alerts_repository.dart';
import 'datasources/alerts_local_data_source.dart';
import 'repositories/alerts_repository_impl.dart';

/// Composition root for the alerts feature's data layer.
/// [alertsRepositoryProvider] is typed as the domain interface.

final alertsLocalDataSourceProvider = Provider<AlertsLocalDataSource>((ref) {
  return AlertsLocalDataSource(ref.watch(alertsBoxProvider));
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepositoryImpl(ref.watch(alertsLocalDataSourceProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/box_providers.dart';
import '../domain/repositories/portfolio_repository.dart';
import 'datasources/holdings_local_data_source.dart';
import 'repositories/portfolio_repository_impl.dart';

/// Composition root for the portfolio feature's data layer.
/// [portfolioRepositoryProvider] is typed as the domain interface.

final holdingsLocalDataSourceProvider = Provider<HoldingsLocalDataSource>((
  ref,
) {
  return HoldingsLocalDataSource(ref.watch(holdingsBoxProvider));
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepositoryImpl(ref.watch(holdingsLocalDataSourceProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_config.dart';
import '../../../core/persistence/box_providers.dart';
import '../domain/repositories/market_repository.dart';
import 'datasources/market_cache_data_source.dart';
import 'datasources/market_remote_data_source.dart';
import 'repositories/market_repository_impl.dart';

/// Composition root for the market feature's data layer.
///
/// [marketRepositoryProvider] is typed as the domain interface, so presentation
/// can never see the concrete `MockMarketRepositoryImpl`. Every layer is its own
/// provider so tests can override the remote, the cache, or the whole repository.

final marketRemoteDataSourceProvider = Provider<MarketRemoteDataSource>((ref) {
  return MockMarketRemoteDataSource(config: ref.watch(mockConfigProvider));
});

final marketCacheDataSourceProvider = Provider<MarketCacheDataSource>((ref) {
  return HiveMarketCacheDataSource(ref.watch(marketCacheBoxProvider));
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(
    remote: ref.watch(marketRemoteDataSourceProvider),
    cache: ref.watch(marketCacheDataSourceProvider),
  );
});

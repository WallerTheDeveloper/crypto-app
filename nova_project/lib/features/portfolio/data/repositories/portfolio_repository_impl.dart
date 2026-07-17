import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/holding.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/holdings_local_data_source.dart';
import '../models/holding_model.dart';

/// [PortfolioRepository] over the local Hive store.
///
/// Maps [HoldingModel]s to entities and [CacheException]s to [CacheFailure], so
/// the UI only ever sees entities and typed failures.
class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl(this._local);

  final HoldingsLocalDataSource _local;

  @override
  Stream<List<Holding>> watchHoldings() async* {
    try {
      yield* _local.watch().map(
        (models) => models.map((m) => m.toEntity()).toList(),
      );
    } on CacheException catch (e) {
      throw CacheFailure(e.message ?? "Couldn't sync portfolio");
    }
  }

  @override
  Future<void> addHolding({
    required String coinId,
    required double amount,
    required double averageBuyPrice,
  }) async {
    try {
      await _local.put(
        HoldingModel(
          coinId: coinId,
          amount: amount,
          averageBuyPrice: averageBuyPrice,
        ),
      );
    } on CacheException {
      throw const CacheFailure("Couldn't save your holding");
    }
  }

  @override
  Future<void> removeHolding(String coinId) async {
    try {
      await _local.delete(coinId);
    } on CacheException {
      throw const CacheFailure("Couldn't remove your holding");
    }
  }
}

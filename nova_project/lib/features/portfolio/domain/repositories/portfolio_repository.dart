import '../entities/holding.dart';

/// Read/write access to the user's holdings.
///
/// [watchHoldings] is a stream because holdings live in Firestore later; today
/// the implementation streams them from local storage. Writes are copy-on-write
/// in the implementation — callers just describe the change.
abstract interface class PortfolioRepository {
  /// Emits the current holdings, and again on every change.
  Stream<List<Holding>> watchHoldings();

  /// Adds or replaces the holding for [coinId].
  Future<void> addHolding({
    required String coinId,
    required double amount,
    required double averageBuyPrice,
  });

  /// Removes the holding for [coinId]. A no-op if there is none.
  Future<void> removeHolding(String coinId);
}

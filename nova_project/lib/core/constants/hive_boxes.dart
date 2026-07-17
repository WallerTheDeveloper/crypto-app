/// Names of the Hive boxes opened at startup, before `runApp`.
///
/// Boxes are opened untyped: values are JSON maps written by the data layer's
/// `toJson`/`fromJson` (no adapters, no codegen). Only `data/` may read or
/// write them.
abstract final class HiveBoxes {
  /// User's portfolio holdings.
  static const String holdings = 'holdings';

  /// User's price alerts.
  static const String alerts = 'alerts';

  /// Theme, currency, and notification preferences.
  static const String prefs = 'prefs';

  /// Last successful market response, for cache-then-network reads.
  static const String marketCache = 'market_cache';

  /// Every box, in the order they are opened at startup.
  static const List<String> all = [holdings, alerts, prefs, marketCache];
}

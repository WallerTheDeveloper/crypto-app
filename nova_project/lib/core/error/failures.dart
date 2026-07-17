/// Typed, user-facing failures.
///
/// Data sources throw [Exception]s (see `exceptions.dart`); repositories catch
/// them and convert to a [Failure] before anything leaves the `data` layer. A
/// raw exception must never reach the UI — the presentation layer only ever
/// sees a [Failure], and renders its [message] in the error state.
sealed class Failure {
  const Failure(this.message);

  /// A short, user-facing description safe to show in the UI.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is Failure &&
      other.runtimeType == runtimeType &&
      other.message == message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType($message)';
}

/// A "network" call failed (the mock source, or CoinGecko/Binance later).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = "Couldn't reach the network"]);
}

/// A requested resource does not exist (e.g. an unknown coin id).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = "Couldn't find what you asked for"]);
}

/// Reading from or writing to the local cache/store (Hive) failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = "Couldn't reach your saved data"]);
}

/// A failure that doesn't fit the buckets above.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

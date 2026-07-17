import 'failures.dart';

/// Low-level exceptions thrown *inside* the `data` layer.
///
/// Data sources throw these; repository implementations catch them and map
/// each to a user-facing [Failure]. They never escape `data/`.
sealed class DataException implements Exception {
  const DataException([this.message]);

  /// Optional diagnostic detail — for logs, not for the UI.
  final String? message;

  @override
  String toString() => '$runtimeType(${message ?? ''})';
}

/// A remote read failed — bad response, timeout, or a forced mock failure.
class NetworkException extends DataException {
  const NetworkException([super.message]);
}

/// The remote source had no record for the requested id.
class NotFoundException extends DataException {
  const NotFoundException([super.message]);
}

/// A local cache/store (Hive) operation failed.
class CacheException extends DataException {
  const CacheException([super.message]);
}

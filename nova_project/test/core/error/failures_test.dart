import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/error/failures.dart';

void main() {
  test('failures carry a user-facing message with sensible defaults', () {
    expect(const NetworkFailure().message, isNotEmpty);
    expect(const NotFoundFailure().message, isNotEmpty);
    expect(const CacheFailure().message, isNotEmpty);
    expect(const UnknownFailure().message, isNotEmpty);
    expect(const NetworkFailure('boom').message, 'boom');
  });

  test('value equality by type and message', () {
    expect(const NetworkFailure('a'), const NetworkFailure('a'));
    expect(const NetworkFailure('a') == const NetworkFailure('b'), isFalse);
    // Same message, different type -> not equal.
    expect(const NetworkFailure('x') == const CacheFailure('x'), isFalse);
    expect(
      const NetworkFailure('a').hashCode,
      const NetworkFailure('a').hashCode,
    );
  });
}

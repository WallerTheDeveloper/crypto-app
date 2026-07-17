import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/error/exceptions.dart';

void main() {
  test('exceptions keep their diagnostic message and are Exceptions', () {
    const e = NetworkException('boom');
    expect(e, isA<Exception>());
    expect(e.message, 'boom');
    expect(e.toString(), contains('boom'));
  });

  test('message is optional', () {
    expect(const NotFoundException().message, isNull);
    expect(const CacheException().toString(), contains('CacheException'));
  });
}

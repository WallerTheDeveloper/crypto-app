import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nova_project/core/persistence/box_providers.dart';

void main() {
  test('box providers throw until overridden with a real box', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Riverpod wraps the create error, so match on the message it carries.
    Matcher throwsOverrideError() =>
        throwsA(predicate((Object e) => '$e'.contains('in main()')));

    expect(() => container.read(holdingsBoxProvider), throwsOverrideError());
    expect(() => container.read(alertsBoxProvider), throwsOverrideError());
    expect(() => container.read(prefsBoxProvider), throwsOverrideError());
    expect(() => container.read(marketCacheBoxProvider), throwsOverrideError());
  });
}

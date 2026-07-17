import 'dart:async';

import 'package:hive_ce/hive.dart';

/// Builds a broadcast-free stream that emits [read] once on listen (after
/// [ensureSeeded]) and again on every change to [box].
///
/// Using an explicit [StreamController] rather than `async* { ... await for }`
/// is deliberate: it guarantees the underlying `box.watch()` subscription is
/// cancelled cleanly when the consumer unsubscribes. An `await for` over a Hive
/// watch stream inside an `async*` generator can hang on cancellation.
///
/// Errors thrown by [ensureSeeded] or [read] are forwarded as stream errors, so
/// the repository above can map them to a typed failure.
Stream<T> watchBox<T>({
  required Box<dynamic> box,
  required Future<void> Function() ensureSeeded,
  required T Function() read,
  Object? key,
}) {
  late final StreamController<T> controller;
  StreamSubscription<BoxEvent>? boxSub;

  Future<void> onListen() async {
    try {
      await ensureSeeded();
      if (controller.isClosed) return;
      controller.add(read());
      boxSub = box.watch(key: key).listen((_) {
        try {
          controller.add(read());
        } catch (e) {
          controller.addError(e);
        }
      });
    } catch (e) {
      controller.addError(e);
    }
  }

  controller = StreamController<T>(
    onListen: onListen,
    onCancel: () async => boxSub?.cancel(),
  );
  return controller.stream;
}

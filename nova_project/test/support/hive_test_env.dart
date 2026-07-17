import 'dart:io';

import 'package:hive_ce/hive.dart';

/// A throwaway Hive instance backed by a temp directory, for data-layer tests.
///
/// Each [HiveTestEnv.start] gets its own directory so tests stay isolated;
/// [dispose] closes every box and deletes the directory.
class HiveTestEnv {
  HiveTestEnv._(this._dir);

  final Directory _dir;

  static Future<HiveTestEnv> start() async {
    final dir = await Directory.systemTemp.createTemp('nova_hive_test');
    Hive.init(dir.path);
    return HiveTestEnv._(dir);
  }

  /// Opens (or reopens) a fresh, empty box named [name].
  Future<Box<dynamic>> openBox(String name) => Hive.openBox<dynamic>(name);

  Future<void> dispose() async {
    await Hive.close();
    if (_dir.existsSync()) _dir.deleteSync(recursive: true);
  }
}

/// Pumps the event loop in small steps until [condition] holds or [tries] is
/// exhausted. Hive writes and `box.watch()` delivery are genuinely async, so
/// tests that observe re-emission poll rather than guess a fixed delay.
Future<void> pumpUntil(bool Function() condition, {int tries = 300}) async {
  for (var i = 0; i < tries && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

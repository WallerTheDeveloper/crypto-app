import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/constants/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  for (final box in HiveBoxes.all) {
    await Hive.openBox<dynamic>(box);
  }

  runApp(const ProviderScope(child: NovaApp()));
}

class NovaApp extends StatelessWidget {
  const NovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(01-theme-tokens): swap in the Dark and Playful themes and the
    // persisted theme controller from tasks/01-theme-tokens.md, then let
    // tasks/04-app-shell-nav.md supply `home`. Until then this boots to a
    // bare Inter-themed scaffold.
    return MaterialApp(
      title: 'Nova',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: const Scaffold(),
    );
  }
}

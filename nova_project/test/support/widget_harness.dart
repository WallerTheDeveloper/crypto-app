import 'package:flutter/material.dart';
import 'package:nova_project/core/theme/app_theme.dart';

/// Wraps [child] in a themed [MaterialApp] so widgets can reach `context.colors`
/// and Material ancestors (ink, directionality) in tests.
Widget themed(Widget child, {AppTheme theme = AppTheme.dark}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppThemes.of(theme),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Runs [body] once per theme, so every widget is exercised in Dark and Warm.
void forEachTheme(void Function(AppTheme theme) body) {
  for (final theme in AppTheme.values) {
    body(theme);
  }
}

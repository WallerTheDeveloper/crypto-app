import 'package:flutter/painting.dart';

/// Fixed overlay colors that are the *same* in both themes — they dim or shade
/// the page rather than acting as theme surfaces, so they don't belong in the
/// per-theme [AppColors] token set. Kept in `core/theme/` so no hex literal
/// leaks into a feature or widget.
abstract final class OverlayTokens {
  /// Sheet scrim — `rgba(5,3,15,.45)` in the design, identical in dark and warm.
  static const Color scrim = Color.fromARGB(115, 5, 3, 15);
}

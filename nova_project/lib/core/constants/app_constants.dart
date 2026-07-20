/// App-wide fixed strings that are configuration, not styling.
///
/// The app name and the header avatar's initials are referenced from a single
/// place rather than scattered as literals across widgets. The avatar initials
/// are the hardcoded prototype user (there is no auth in the MVP — see
/// `tasks/README.md#mvp-definition`); Settings (task 10) will formalise the
/// profile.
abstract final class AppConstants {
  /// Product name, shown in the market header.
  static const String appName = 'Nova';

  /// Brand mark glyph shown in the header's accent square.
  static const String logoGlyph = '◈';

  /// Initials shown in the header profile avatar (the fixed prototype user).
  static const String profileInitials = 'AR';
}

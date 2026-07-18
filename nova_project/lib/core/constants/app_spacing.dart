/// Spacing scale from the design.
///
/// Named layout measurements (screen padding, row heights, avatar/control
/// sizes) plus a small generic step scale for gaps and padding. Features use
/// these instead of inlining magic numbers.
abstract final class AppSpacing {
  // --- Generic step scale (gaps, padding) ---
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // --- Screen layout ---
  /// Horizontal screen padding.
  static const double screenH = 18;

  /// Bottom screen padding — clears the 84px bottom nav.
  static const double screenBottom = 108;

  // --- Bottom nav ---
  /// Total nav height on the reference device (content + 24px home-indicator
  /// inset). Real height is [navContentHeight] + top padding + the device's
  /// bottom safe-area inset, so it adapts per device.
  static const double navHeight = 84;

  /// Padding above the nav's icon/label row.
  static const double navPaddingTop = 10;

  /// Horizontal padding inside the nav.
  static const double navPaddingH = 8;

  /// Height of the nav's icon+label content row. With [navPaddingTop] and the
  /// reference 24px inset this sums to [navHeight] (10 + 50 + 24 = 84).
  static const double navContentHeight = 50;

  /// How far the toast floats off the bottom edge.
  static const double toastBottomInset = 100;

  // --- List rows ---
  static const double marketRow = 66;
  static const double portfolioRow = 70;

  // --- Controls ---
  static const double iconButton = 38;

  // --- Avatars ---
  static const double avatarList = 40;
  static const double avatarDetail = 26;
  static const double avatarSheet = 36;
  static const double avatarSettings = 52;
}

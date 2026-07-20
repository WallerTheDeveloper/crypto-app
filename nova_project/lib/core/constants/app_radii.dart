/// Corner-radius scale from the design.
///
/// `CLAUDE.md` names three defaults (card 16, control 12, pill fully rounded);
/// the design uses a wider scale, recorded here as named tokens so features
/// never inline a radius. Use [pill] with a large [BorderRadius] value for
/// fully-rounded shapes (Flutter has no "stadium radius" constant).
abstract final class AppRadii {
  /// Fully rounded — pills, badges, circular controls.
  static const double pill = 999;

  /// Cards.
  static const double card = 16;

  /// Controls and buttons.
  static const double control = 12;

  /// Bottom sheets (top corners only).
  static const double sheet = 26;

  /// Inner surfaces — sheet cards, toast.
  static const double inner = 14;

  /// Icon buttons.
  static const double iconButton = 11;

  /// Brand logo mark — the 30×30 accent square in the market header.
  static const double logo = 9;

  /// Chart boxes.
  static const double chartBox = 10;

  /// Empty / error-state icon wells.
  static const double well = 20;
}

/// The display currency. A shared value type in the core kernel because both
/// the domain ([UserPrefs]) and the presentation-edge formatters need it.
///
/// Pure Dart — no Flutter, no data-source imports — so `domain` may depend on
/// it without breaking layer purity.
///
/// The EUR rate is a hardcoded constant for the MVP: real FX is post-MVP. It
/// lives in [kEurUsdRate] rather than as a literal so there is one place to
/// change it.
library;

/// Fixed EUR-per-USD conversion rate used until real FX lands.
const double kEurUsdRate = 0.92;

/// USD is the base currency (rate 1.0); EUR converts at [kEurUsdRate].
enum Currency {
  usd(symbol: r'$', rate: 1),
  eur(symbol: '€', rate: kEurUsdRate);

  const Currency({required this.symbol, required this.rate});

  /// The currency symbol prefixed to formatted amounts.
  final String symbol;

  /// Multiplier applied to a USD-denominated amount to reach this currency.
  final double rate;
}

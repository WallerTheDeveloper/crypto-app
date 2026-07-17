/// A tradable coin as the app understands it.
///
/// Immutable and currency-agnostic: [price], [allTimeHigh] and [volume24h] are
/// raw USD numbers — formatting and FX conversion happen at the presentation
/// edge, never here. [brandColor] is a plain `0xAARRGGBB` int so `domain` stays
/// free of `dart:ui`; presentation wraps it in a `Color`.
///
/// Derived values ([marketCap]) are getters, not stored fields, so they can
/// never drift from their inputs.
class Coin {
  const Coin({
    required this.id,
    required this.name,
    required this.ticker,
    required this.glyph,
    required this.brandColor,
    required this.price,
    required this.change24hPct,
    required this.circulatingSupply,
    required this.allTimeHigh,
    required this.volume24h,
    required this.spark,
  });

  /// Stable lowercase id, e.g. `btc`.
  final String id;

  /// Display name, e.g. `Bitcoin`.
  final String name;

  /// Uppercase symbol, e.g. `BTC`.
  final String ticker;

  /// Single-character glyph shown in the avatar, e.g. `₿`.
  final String glyph;

  /// Brand color as `0xAARRGGBB`.
  final int brandColor;

  /// Current price in USD.
  final double price;

  /// 24-hour change as a percentage, e.g. `2.4` for +2.4%.
  final double change24hPct;

  /// Circulating supply (a coin count, not money).
  final double circulatingSupply;

  /// All-time-high price in USD.
  final double allTimeHigh;

  /// 24-hour trading volume in USD.
  final double volume24h;

  /// Twelve-point sparkline sample used by the market row.
  final List<double> spark;

  /// Market capitalisation — derived, never stored.
  double get marketCap => price * circulatingSupply;

  Coin copyWith({
    String? id,
    String? name,
    String? ticker,
    String? glyph,
    int? brandColor,
    double? price,
    double? change24hPct,
    double? circulatingSupply,
    double? allTimeHigh,
    double? volume24h,
    List<double>? spark,
  }) {
    return Coin(
      id: id ?? this.id,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      glyph: glyph ?? this.glyph,
      brandColor: brandColor ?? this.brandColor,
      price: price ?? this.price,
      change24hPct: change24hPct ?? this.change24hPct,
      circulatingSupply: circulatingSupply ?? this.circulatingSupply,
      allTimeHigh: allTimeHigh ?? this.allTimeHigh,
      volume24h: volume24h ?? this.volume24h,
      spark: spark ?? this.spark,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Coin &&
      other.id == id &&
      other.name == name &&
      other.ticker == ticker &&
      other.glyph == glyph &&
      other.brandColor == brandColor &&
      other.price == price &&
      other.change24hPct == change24hPct &&
      other.circulatingSupply == circulatingSupply &&
      other.allTimeHigh == allTimeHigh &&
      other.volume24h == volume24h &&
      _sparkEquals(other.spark, spark);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ticker,
    glyph,
    brandColor,
    price,
    change24hPct,
    circulatingSupply,
    allTimeHigh,
    volume24h,
    Object.hashAll(spark),
  );

  static bool _sparkEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

import '../../domain/entities/coin.dart';

/// Data-layer representation of a coin.
///
/// Carries JSON (de)serialisation for the Hive market cache — no codegen, no
/// adapters. It is mapped to a [Coin] entity at the repository boundary so a
/// cache-shaped map never reaches a widget.
class CoinModel {
  const CoinModel({
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

  factory CoinModel.fromEntity(Coin coin) => CoinModel(
    id: coin.id,
    name: coin.name,
    ticker: coin.ticker,
    glyph: coin.glyph,
    brandColor: coin.brandColor,
    price: coin.price,
    change24hPct: coin.change24hPct,
    circulatingSupply: coin.circulatingSupply,
    allTimeHigh: coin.allTimeHigh,
    volume24h: coin.volume24h,
    spark: coin.spark,
  );

  factory CoinModel.fromJson(Map<String, dynamic> json) => CoinModel(
    id: json['id'] as String,
    name: json['name'] as String,
    ticker: json['ticker'] as String,
    glyph: json['glyph'] as String,
    brandColor: (json['brandColor'] as num).toInt(),
    price: (json['price'] as num).toDouble(),
    change24hPct: (json['change24hPct'] as num).toDouble(),
    circulatingSupply: (json['circulatingSupply'] as num).toDouble(),
    allTimeHigh: (json['allTimeHigh'] as num).toDouble(),
    volume24h: (json['volume24h'] as num).toDouble(),
    spark: [for (final v in json['spark'] as List) (v as num).toDouble()],
  );

  final String id;
  final String name;
  final String ticker;
  final String glyph;
  final int brandColor;
  final double price;
  final double change24hPct;
  final double circulatingSupply;
  final double allTimeHigh;
  final double volume24h;
  final List<double> spark;

  Coin toEntity() => Coin(
    id: id,
    name: name,
    ticker: ticker,
    glyph: glyph,
    brandColor: brandColor,
    price: price,
    change24hPct: change24hPct,
    circulatingSupply: circulatingSupply,
    allTimeHigh: allTimeHigh,
    volume24h: volume24h,
    spark: spark,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ticker': ticker,
    'glyph': glyph,
    'brandColor': brandColor,
    'price': price,
    'change24hPct': change24hPct,
    'circulatingSupply': circulatingSupply,
    'allTimeHigh': allTimeHigh,
    'volume24h': volume24h,
    'spark': spark,
  };
}

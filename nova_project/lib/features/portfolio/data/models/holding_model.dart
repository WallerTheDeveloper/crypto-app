import '../../domain/entities/holding.dart';

/// Data-layer representation of a [Holding], with JSON (de)serialisation for
/// the `holdings` Hive box. Mapped to an entity at the repository boundary.
class HoldingModel {
  const HoldingModel({
    required this.coinId,
    required this.amount,
    required this.averageBuyPrice,
  });

  factory HoldingModel.fromEntity(Holding holding) => HoldingModel(
    coinId: holding.coinId,
    amount: holding.amount,
    averageBuyPrice: holding.averageBuyPrice,
  );

  factory HoldingModel.fromJson(Map<String, dynamic> json) => HoldingModel(
    coinId: json['coinId'] as String,
    amount: (json['amount'] as num).toDouble(),
    averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
  );

  final String coinId;
  final double amount;
  final double averageBuyPrice;

  Holding toEntity() =>
      Holding(coinId: coinId, amount: amount, averageBuyPrice: averageBuyPrice);

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'amount': amount,
    'averageBuyPrice': averageBuyPrice,
  };
}

import '../../domain/entities/alert.dart';

/// Data-layer representation of an [Alert], with JSON (de)serialisation for the
/// `alerts` Hive box. [AlertDirection] is stored as its name string.
class AlertModel {
  const AlertModel({
    required this.id,
    required this.coinId,
    required this.direction,
    required this.targetPrice,
    required this.isEnabled,
  });

  factory AlertModel.fromEntity(Alert alert) => AlertModel(
    id: alert.id,
    coinId: alert.coinId,
    direction: alert.direction.name,
    targetPrice: alert.targetPrice,
    isEnabled: alert.isEnabled,
  );

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
    id: json['id'] as String,
    coinId: json['coinId'] as String,
    direction: json['direction'] as String,
    targetPrice: (json['targetPrice'] as num).toDouble(),
    isEnabled: json['isEnabled'] as bool,
  );

  final String id;
  final String coinId;

  /// The [AlertDirection] name — `above` or `below`.
  final String direction;
  final double targetPrice;
  final bool isEnabled;

  Alert toEntity() => Alert(
    id: id,
    coinId: coinId,
    direction: AlertDirection.values.byName(direction),
    targetPrice: targetPrice,
    isEnabled: isEnabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'coinId': coinId,
    'direction': direction,
    'targetPrice': targetPrice,
    'isEnabled': isEnabled,
  };
}

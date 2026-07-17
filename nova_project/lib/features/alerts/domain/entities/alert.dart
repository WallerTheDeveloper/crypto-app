/// Which side of [Alert.targetPrice] should trigger the alert.
enum AlertDirection {
  /// Fire when the price rises to or above the target.
  above,

  /// Fire when the price falls to or below the target.
  below,
}

/// A user-configured price alert on one coin.
///
/// Immutable; toggling or editing produces a new instance via [copyWith].
class Alert {
  const Alert({
    required this.id,
    required this.coinId,
    required this.direction,
    required this.targetPrice,
    required this.isEnabled,
  });

  /// Stable unique id for this alert.
  final String id;

  /// The [Coin.id] this alert watches.
  final String coinId;

  /// Whether it triggers above or below [targetPrice].
  final AlertDirection direction;

  /// Threshold price in USD.
  final double targetPrice;

  /// Whether the alert is currently armed.
  final bool isEnabled;

  Alert copyWith({
    String? id,
    String? coinId,
    AlertDirection? direction,
    double? targetPrice,
    bool? isEnabled,
  }) {
    return Alert(
      id: id ?? this.id,
      coinId: coinId ?? this.coinId,
      direction: direction ?? this.direction,
      targetPrice: targetPrice ?? this.targetPrice,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Alert &&
      other.id == id &&
      other.coinId == coinId &&
      other.direction == direction &&
      other.targetPrice == targetPrice &&
      other.isEnabled == isEnabled;

  @override
  int get hashCode =>
      Object.hash(id, coinId, direction, targetPrice, isEnabled);
}

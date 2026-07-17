/// A single sample on a coin's price chart.
///
/// [index] is the sample's position in the series (0-based); [value] is the
/// normalised height the design plots. The generator produces normalised
/// values, so [value] is a shape sample, not an absolute price.
class PricePoint {
  const PricePoint({required this.index, required this.value});

  /// 0-based position within the series.
  final int index;

  /// Normalised value at this point.
  final double value;

  @override
  bool operator ==(Object other) =>
      other is PricePoint && other.index == index && other.value == value;

  @override
  int get hashCode => Object.hash(index, value);
}

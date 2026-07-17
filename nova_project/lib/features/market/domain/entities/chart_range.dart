/// The selectable time ranges for the coin-detail chart.
///
/// Each range carries its prototype [label] (used verbatim to seed the
/// deterministic series generator) and the [points] count the design draws for
/// that range.
enum ChartRange {
  h24(label: '24h', points: 30),
  d7(label: '7d', points: 40),
  d30(label: '30d', points: 44),
  y1(label: '1y', points: 48);

  const ChartRange({required this.label, required this.points});

  /// Prototype label, e.g. `24h`. Part of the series seed — do not restyle.
  final String label;

  /// Number of points sampled for this range.
  final int points;
}

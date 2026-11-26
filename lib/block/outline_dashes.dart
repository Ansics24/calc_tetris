import 'dart:math';

/// The dashes along a closed contour of the given [length], as distances
/// `(start, end)` from its start. Dashes and gaps are equally long, about
/// [spacing] apart and stretched so that they fit the contour without a seam.
/// The [phase] from 0 to 1 moves every dash forward by that share of the
/// distance to the next one.
List<(double, double)> outlineDashes({
  required double length,
  required double spacing,
  required double phase,
}) {
  final count = max(1, (length / spacing).round());
  final period = length / count;
  final dashes = <(double, double)>[];
  for (var i = 0; i < count; i++) {
    final start = (i + phase) * period;
    final end = start + period / 2;
    if (end <= length) {
      dashes.add((start, end));
    } else {
      // passes the end and continues at the start
      dashes.add((start, length));
      dashes.add((0, end - length));
    }
  }
  return dashes;
}

import 'dart:math' as math;

/// Round axis values (steps of 1, 2, 2.5 or 5 × 10ⁿ) covering [min]..[max],
/// about [count] steps; the first and last value enclose the data.
List<double> niceTicks(double min, double max, {int count = 4}) {
  if (max - min < 1) {
    min -= 50;
    max += 50;
  }
  final raw = (max - min) / count;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final step = [1, 2, 2.5, 5, 10].map((f) => f * magnitude).firstWhere((s) => s >= raw * 0.999);
  final first = (min / step).floor();
  final last = (max / step).ceil();
  return [for (var i = first; i <= last; i++) i * step];
}

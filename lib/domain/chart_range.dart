import 'overview_calc.dart';

/// Time windows of the history charts, like in stock apps.
enum ChartRange { all, year, sixMonths, threeMonths, month, week, day }

/// First day of the window, or null for "since the first entry".
DateTime? rangeStart(ChartRange range, DateTime today) {
  final y = today.year, m = today.month, d = today.day;
  return switch (range) {
    ChartRange.all => null,
    ChartRange.year => DateTime(y - 1, m, d),
    ChartRange.sixMonths => DateTime(y, m - 6, d),
    ChartRange.threeMonths => DateTime(y, m - 3, d),
    ChartRange.month => DateTime(y, m - 1, d),
    ChartRange.week => DateTime(y, m, d - 7),
    ChartRange.day => DateTime(y, m, d - 1),
  };
}

/// Points of one line within [range].
///
/// Balances only change with an entry, so the value at the start of the
/// window is the last entry before it, and the line is carried forward to
/// [today] – the window always spans its full width once there is data.
List<(DateTime, double)> rangeSeries(
  List<BalanceRow> rows,
  ChartRange range,
  DateTime today,
  double Function(BalanceRow row) value,
) {
  if (rows.isEmpty) return const [];
  final start = rangeStart(range, today);
  final points = <(DateTime, double)>[];
  if (start == null) {
    points.addAll(rows.map((r) => (r.date, value(r))));
  } else {
    final before = rows.lastWhere((r) => !r.date.isAfter(start), orElse: () => rows.first);
    if (!before.date.isAfter(start)) points.add((start, value(before)));
    for (final r in rows) {
      if (r.date.isAfter(start)) points.add((r.date, value(r)));
    }
  }
  if (points.isEmpty) return points;
  final end = rows.last.date.isAfter(today) ? rows.last.date : today;
  if (points.last.$1.isBefore(end)) points.add((end, points.last.$2));
  return points;
}

/// Change from the first to the last point of a series.
({double absolute, double? relative}) seriesChange(List<(DateTime, double)> points) {
  if (points.length < 2) return (absolute: 0, relative: null);
  final first = points.first.$2;
  final change = points.last.$2 - first;
  return (absolute: change, relative: first == 0 ? null : change / first.abs());
}

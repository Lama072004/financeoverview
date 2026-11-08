import 'package:financeoverview/domain/chart_range.dart';
import 'package:financeoverview/domain/overview_calc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

void main() {
  final rows = balanceHistory(TestData.build());
  final today = DateTime(2026, 2, 15);
  double total(BalanceRow r) => r.total;

  test('window starts', () {
    expect(rangeStart(ChartRange.all, today), isNull);
    expect(rangeStart(ChartRange.year, today), DateTime(2025, 2, 15));
    expect(rangeStart(ChartRange.sixMonths, today), DateTime(2025, 8, 15));
    expect(rangeStart(ChartRange.threeMonths, today), DateTime(2025, 11, 15));
    expect(rangeStart(ChartRange.month, today), DateTime(2026, 1, 15));
    expect(rangeStart(ChartRange.week, today), DateTime(2026, 2, 8));
    expect(rangeStart(ChartRange.day, today), DateTime(2026, 2, 14));
  });

  test('all: every entry, carried forward to today', () {
    final p = rangeSeries(rows, ChartRange.all, today, total);
    expect(p.map((e) => e.$2), [4000, 4500, 5200, 5100, 5100]);
    expect(p.last.$1, today);
  });

  test('month: starts with the balance valid at the window start', () {
    final p = rangeSeries(rows, ChartRange.month, today, total);
    expect(p, [
      (DateTime(2026, 1, 15), 4500.0),
      (DateTime(2026, 1, 31), 5200.0),
      (DateTime(2026, 2, 10), 5100.0),
      (today, 5100.0),
    ]);
    final c = seriesChange(p);
    expect(c.absolute, 600);
    expect(c.relative, closeTo(600 / 4500, 1e-9));
  });

  test('week and day', () {
    final week = rangeSeries(rows, ChartRange.week, today, total);
    expect(week.map((e) => e.$2), [5200, 5100, 5100]);
    expect(seriesChange(week).absolute, -100);

    final day = rangeSeries(rows, ChartRange.day, today, total);
    expect(day, [(DateTime(2026, 2, 14), 5100.0), (today, 5100.0)]);
    expect(seriesChange(day).absolute, 0);
  });

  test('window longer than the history starts at the first entry', () {
    final p = rangeSeries(rows, ChartRange.year, today, total);
    expect(p.first.$1, DateTime(2025, 12, 20));
    expect(p, hasLength(5));
  });

  test('per account and empty history', () {
    final giro = rangeSeries(rows, ChartRange.month, today, (r) => r.balanceOf('a'));
    expect(giro.map((e) => e.$2), [1500, 1500, 1400, 1400]);
    expect(rangeSeries(const [], ChartRange.all, today, total), isEmpty);
  });
}

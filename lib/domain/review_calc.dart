import '../core/dates.dart';
import '../data/models.dart';
import 'overview_calc.dart';
import 'recurring_calc.dart';

/// Monthly / yearly review ("Rückblick").
///
/// Balances are only known at entry dates, so a time span is measured from
/// the last entry before it to the last entry inside it. Consecutive spans
/// therefore add up exactly, and the estimates are the sums of the per-entry
/// values shown in the history.
class PeriodReview {
  const PeriodReview({
    required this.start,
    required this.end,
    required this.from,
    required this.to,
    required this.investmentReturn,
    required this.variableExpenses,
    required this.plannedIncome,
    required this.plannedSavings,
    required this.spending,
    required this.unassigned,
    required this.singleIncome,
  });

  /// Calendar bounds of the span (both inclusive).
  final DateTime start;
  final DateTime end;

  /// Reference entry: the last one before [start], else the first inside.
  final BalanceRow? from;

  /// Last entry inside the span.
  final BalanceRow? to;
  final double investmentReturn;
  final double variableExpenses;

  /// Fixed income and savings of the standing orders over the measured days.
  final double plannedIncome;
  final double plannedSavings;

  /// Fixed costs and single expenses per category, sorted descending.
  final List<CategorySpending> spending;

  /// Estimated spending that was not booked individually.
  final double unassigned;
  final double singleIncome;

  bool get hasData => to != null;

  /// At least two entries – a change can be measured.
  bool get hasFlow => from != null && to != null && to!.date.isAfter(from!.date);

  int get days => hasFlow ? daysBetween(from!.date, to!.date) : 0;

  double get change => hasFlow ? to!.total - from!.total : 0;
  double get liquidChange => hasFlow ? to!.liquid - from!.liquid : 0;
  double get investedChange => hasFlow ? to!.invested - from!.invested : 0;
  double get debtChange => hasFlow ? to!.debt - from!.debt : 0;

  /// Growth that is not market return: what was actually put aside.
  double get saved => change - investmentReturn;

  /// Change relative to the starting net worth; null when the start was so
  /// close to zero that a percentage says nothing (more than ±1000 %).
  double? get relativeChange {
    if (!hasFlow || from!.total == 0) return null;
    final r = change / from!.total.abs();
    return r.abs() > 10 ? null : r;
  }

  /// Actual savings rate: saved ÷ fixed income.
  double? get savingsRate => hasFlow && plannedIncome > 0 ? saved / plannedIncome : null;

  /// Savings rate of the standing orders.
  double? get plannedSavingsRate => plannedIncome > 0 ? plannedSavings / plannedIncome : null;

  double get spendingTotal => spending.fold(0.0, (s, c) => s + c.total) + unassigned;

  double accountChange(String accountId) =>
      hasFlow ? to!.balanceOf(accountId) - from!.balanceOf(accountId) : 0;
}

/// First day with any data (entry or single booking); null without data.
DateTime? dataStart(AppData data) {
  final dates = [
    if (data.snapshots.isNotEmpty) data.snapshots.first.date,
    for (final t in data.transactions) t.date,
  ];
  if (dates.isEmpty) return null;
  return dates.reduce((a, b) => a.isBefore(b) ? a : b);
}

class ReviewInput {
  const ReviewInput({
    required this.data,
    required this.rows,
    required this.estimates,
    required this.recurring,
    required this.today,
  });

  final AppData data;
  final List<BalanceRow> rows;

  /// [periodEstimates] of [rows].
  final List<PeriodEstimate?> estimates;

  /// Standing orders as of today, like the estimates.
  final RecurringSummary recurring;
  final DateTime today;
}

PeriodReview reviewPeriod(ReviewInput input, DateTime start, DateTime end) {
  final rows = input.rows;
  final last = end.isAfter(input.today) ? input.today : end;

  final toIdx = rows.lastIndexWhere((r) => !r.date.isAfter(last));
  var fromIdx = rows.lastIndexWhere((r) => r.date.isBefore(start));
  if (fromIdx < 0 && toIdx >= 0) {
    final first = rows.indexWhere((r) => !r.date.isBefore(start));
    fromIdx = first >= 0 && first <= toIdx ? first : -1;
  }

  var ret = 0.0, variable = 0.0;
  for (var i = fromIdx + 1; fromIdx >= 0 && i <= toIdx; i++) {
    ret += input.estimates[i]?.investmentReturn ?? 0;
    variable += input.estimates[i]?.variableExpenses ?? 0;
  }
  final days = fromIdx >= 0 && toIdx > fromIdx ? daysBetween(rows[fromIdx].date, rows[toIdx].date) : 0;
  final months = days / daysPerMonth;

  // Spending like the dashboard donut, month by month.
  final byCategory = <String?, (double, double)>{};
  var unassigned = 0.0, income = 0.0;
  final begin = dataStart(input.data);
  if (begin != null && !last.isBefore(start)) {
    var m = firstOfMonth(start.isAfter(begin) ? start : begin);
    while (!m.isAfter(last)) {
      final s = monthlySpending(input.data, m, input.today, rows);
      for (final c in s.categories) {
        final (fixed, single) = byCategory[c.categoryId] ?? (0, 0);
        byCategory[c.categoryId] = (fixed + c.fixed, single + c.single);
      }
      unassigned += s.unassigned;
      income += s.singleIncome;
      m = DateTime(m.year, m.month + 1);
    }
  }
  final spending = [
    for (final e in byCategory.entries) CategorySpending(categoryId: e.key, fixed: e.value.$1, single: e.value.$2),
  ]..sort((a, b) => b.total.compareTo(a.total));

  return PeriodReview(
    start: start,
    end: last,
    from: fromIdx >= 0 ? rows[fromIdx] : null,
    // No entry inside the span: nothing to review (the old balance carries on).
    to: toIdx >= 0 && !rows[toIdx].date.isBefore(start) ? rows[toIdx] : null,
    investmentReturn: ret,
    variableExpenses: variable,
    plannedIncome: input.recurring.fixedIncome * months,
    plannedSavings: input.recurring.savingsTotal * months,
    spending: spending,
    unassigned: unassigned,
    singleIncome: income,
  );
}

PeriodReview reviewMonth(ReviewInput input, DateTime month) =>
    reviewPeriod(input, firstOfMonth(month), lastOfMonth(month));

PeriodReview reviewYear(ReviewInput input, int year) =>
    reviewPeriod(input, DateTime(year), DateTime(year, 12, 31));

/// From the first data to today.
PeriodReview reviewAll(ReviewInput input) =>
    reviewPeriod(input, dataStart(input.data) ?? input.today, input.today);

/// The months of [year] up to today.
List<PeriodReview> monthsOfYear(ReviewInput input, int year) => [
      for (var m = 1; m <= 12 && !DateTime(year, m).isAfter(input.today); m++) reviewMonth(input, DateTime(year, m)),
    ];

/// Every year from the first data until today.
List<PeriodReview> allYears(ReviewInput input) {
  final begin = dataStart(input.data);
  if (begin == null) return const [];
  return [for (var y = begin.year; y <= input.today.year; y++) reviewYear(input, y)];
}

/// Years that contain data, newest first.
List<int> reviewYears(ReviewInput input) {
  final begin = dataStart(input.data);
  if (begin == null) return const [];
  return [for (var y = input.today.year; y >= begin.year; y--) y];
}

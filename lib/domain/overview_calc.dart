import 'dart:math' as math;

import '../core/dates.dart';
import '../data/models.dart';
import 'recurring_calc.dart';

/// Average month length used by the spreadsheet's estimates.
const daysPerMonth = 30.4375;

/// One snapshot with every account's effective balance (entered or carried
/// over from the previous snapshot – "übernommen" columns of the sheet).
class BalanceRow {
  const BalanceRow({
    required this.snapshot,
    required this.balances,
    required this.liquid,
    required this.invested,
    required this.debt,
  });

  final Snapshot snapshot;
  final Map<String, double> balances;
  final double liquid;
  final double invested;

  /// Outstanding liabilities, as a positive number.
  final double debt;

  DateTime get date => snapshot.date;

  /// Net worth ("Gesamt").
  double get total => liquid + invested - debt;

  double balanceOf(String accountId) => balances[accountId] ?? 0;
}

List<BalanceRow> balanceHistory(AppData data) {
  final behaviors = {for (final a in data.accounts) a.id: data.behaviorOf(a)};
  final running = <String, double>{};
  final rows = <BalanceRow>[];
  for (final s in data.snapshots) {
    running.addAll(s.values);
    var liquid = 0.0, invested = 0.0, debt = 0.0;
    final balances = <String, double>{};
    for (final a in data.accounts) {
      final v = running[a.id] ?? 0;
      balances[a.id] = v;
      switch (behaviors[a.id]!) {
        case AccountBehavior.liquid:
          liquid += v;
        case AccountBehavior.invested:
          invested += v;
        case AccountBehavior.debt:
          debt += v;
      }
    }
    rows.add(BalanceRow(snapshot: s, balances: balances, liquid: liquid, invested: invested, debt: debt));
  }
  return rows;
}

/// Columns M–P of the "Kontostände" sheet for one snapshot.
class PeriodEstimate {
  const PeriodEstimate({
    required this.from,
    required this.to,
    required this.days,
    required this.deltaTotal,
    required this.variableExpenses,
    required this.investmentReturn,
  });

  final DateTime from;
  final DateTime to;
  final int days;
  final double deltaTotal;

  /// What was spent on top of the standing orders (groceries, leisure …).
  /// Negative = more came in than expected.
  final double variableExpenses;

  /// Change of the invested accounts minus own contributions.
  final double investmentReturn;
}

/// Estimate between [prev] and [cur]; null for the first snapshot.
PeriodEstimate estimatePeriod(BalanceRow prev, BalanceRow cur, RecurringSummary recurring) {
  final days = daysBetween(prev.date, cur.date);
  final months = days / daysPerMonth;
  final expectedLiquidInflow =
      (recurring.fixedIncome - recurring.fixedExpenses - recurring.savingsLeavingLiquid) * months;
  return PeriodEstimate(
    from: prev.date,
    to: cur.date,
    days: days,
    deltaTotal: cur.total - prev.total,
    variableExpenses: expectedLiquidInflow - (cur.liquid - prev.liquid),
    investmentReturn: (cur.invested - prev.invested) - recurring.savingsInvested * months,
  );
}

List<PeriodEstimate?> periodEstimates(List<BalanceRow> rows, RecurringSummary recurring) => [
      for (var i = 0; i < rows.length; i++) i == 0 ? null : estimatePeriod(rows[i - 1], rows[i], recurring),
    ];

class AccountOverview {
  const AccountOverview({
    required this.account,
    required this.behavior,
    required this.balance,
    required this.deltaSincePrevious,
    required this.deltaSinceYearStart,
    required this.share,
  });

  final Account account;
  final AccountBehavior behavior;
  final double balance;
  final double deltaSincePrevious;
  final double deltaSinceYearStart;

  /// Share of the gross assets; null for debt accounts.
  final double? share;
}

/// The "Aktueller Stand" block of the overview sheet.
class Overview {
  const Overview({
    required this.latest,
    required this.previous,
    required this.yearStart,
    required this.accounts,
    required this.lastPeriod,
  });

  final BalanceRow? latest;
  final BalanceRow? previous;
  final BalanceRow? yearStart;
  final List<AccountOverview> accounts;
  final PeriodEstimate? lastPeriod;

  bool get hasData => latest != null;
  double get total => latest?.total ?? 0;
  double get liquid => latest?.liquid ?? 0;
  double get invested => latest?.invested ?? 0;
  double get debt => latest?.debt ?? 0;
  double get deltaSincePrevious => total - (previous?.total ?? total);
  double get deltaSinceYearStart => total - (yearStart?.total ?? total);
  double get deltaLiquidSincePrevious => liquid - (previous?.liquid ?? liquid);
  double get deltaInvestedSincePrevious => invested - (previous?.invested ?? invested);
}

Overview buildOverview(AppData data, List<BalanceRow> rows, RecurringSummary recurring) {
  if (rows.isEmpty) {
    return Overview(
      latest: null,
      previous: null,
      yearStart: null,
      lastPeriod: null,
      accounts: [
        for (final a in data.accounts)
          AccountOverview(
            account: a,
            behavior: data.behaviorOf(a),
            balance: 0,
            deltaSincePrevious: 0,
            deltaSinceYearStart: 0,
            share: data.behaviorOf(a) == AccountBehavior.debt ? null : 0,
          ),
      ],
    );
  }
  final latest = rows.last;
  // Spreadsheet: with only one entry the "previous" row is the same row.
  final previous = rows.length >= 2 ? rows[rows.length - 2] : latest;
  // Last entry on or before 1 January of the latest entry's year, else the first.
  final jan1 = DateTime(latest.date.year);
  final yearStart = rows.lastWhere((r) => !r.date.isAfter(jan1), orElse: () => rows.first);
  final gross = latest.liquid + latest.invested;

  return Overview(
    latest: latest,
    previous: previous,
    yearStart: yearStart,
    lastPeriod: rows.length >= 2 ? estimatePeriod(previous, latest, recurring) : null,
    accounts: [
      for (final a in data.accounts)
        AccountOverview(
          account: a,
          behavior: data.behaviorOf(a),
          balance: latest.balanceOf(a.id),
          deltaSincePrevious: latest.balanceOf(a.id) - previous.balanceOf(a.id),
          deltaSinceYearStart: latest.balanceOf(a.id) - yearStart.balanceOf(a.id),
          share: data.behaviorOf(a) == AccountBehavior.debt
              ? null
              : (gross == 0 ? 0 : latest.balanceOf(a.id) / gross),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Monthly spending (dashboard donut & category list)
// ---------------------------------------------------------------------------

class CategorySpending {
  const CategorySpending({required this.categoryId, required this.fixed, required this.single});

  final String? categoryId;

  /// Monthly amount from standing orders.
  final double fixed;

  /// Single expenses booked in the month.
  final double single;

  double get total => fixed + single;
}

class MonthlySpending {
  const MonthlySpending({
    required this.month,
    required this.categories,
    required this.singleIncome,
    required this.estimatedVariable,
  });

  final DateTime month;

  /// Sorted descending by total, only categories with an amount.
  final List<CategorySpending> categories;
  final double singleIncome;

  /// Estimated variable spending from the balance entries in this month;
  /// null when no balance entries cover the month.
  final double? estimatedVariable;

  double get categorized => categories.fold(0, (s, c) => s + c.total);

  double get singleExpenses => categories.fold(0, (s, c) => s + c.single);

  /// Part of the estimated spending that was not booked individually.
  double get unassigned {
    final est = estimatedVariable;
    if (est == null) return 0;
    return math.max(0, est - (singleExpenses - singleIncome));
  }

  double get total => categorized + unassigned;
}

MonthlySpending monthlySpending(
  AppData data,
  DateTime month,
  DateTime today,
  List<BalanceRow> rows,
) {
  final first = firstOfMonth(month);
  final last = lastOfMonth(month);
  // Standing orders as they apply in that month (today for the current one).
  final reference = last.isAfter(today) ? today : last;
  final recurring = summarizeRecurring(data, reference);

  final single = <String?, double>{};
  var income = 0.0;
  for (final t in data.transactions) {
    if (t.date.isBefore(first) || t.date.isAfter(last)) continue;
    if (t.isIncome) {
      income += t.amount;
    } else {
      single[t.categoryId] = (single[t.categoryId] ?? 0) + t.amount;
    }
  }

  final ids = {...recurring.expensesByCategory.keys, ...single.keys};
  final categories = [
    for (final id in ids)
      CategorySpending(categoryId: id, fixed: recurring.expensesByCategory[id] ?? 0, single: single[id] ?? 0),
  ]..sort((a, b) => b.total.compareTo(a.total));

  // Prorate each balance period (prev, cur] by its overlap with the month.
  double? estimate;
  for (var i = 1; i < rows.length; i++) {
    final from = rows[i - 1].date;
    final to = rows[i].date;
    final days = daysBetween(from, to);
    if (days <= 0) continue;
    final start = from.add(const Duration(days: 1));
    final overlapStart = start.isAfter(first) ? start : first;
    final overlapEnd = to.isBefore(last) ? to : last;
    final overlap = daysBetween(overlapStart, overlapEnd) + 1;
    if (overlap <= 0) continue;
    final period = estimatePeriod(rows[i - 1], rows[i], recurring);
    estimate = (estimate ?? 0) + period.variableExpenses * overlap / days;
  }

  return MonthlySpending(
    month: first,
    categories: categories.where((c) => c.total > 0).toList(),
    singleIncome: income,
    estimatedVariable: estimate,
  );
}

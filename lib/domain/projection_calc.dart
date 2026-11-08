import 'dart:math' as math;

import '../core/dates.dart';
import '../data/models.dart';
import 'overview_calc.dart';
import 'recurring_calc.dart';

/// Where the monthly saving of the projection comes from.
enum ProjectionBasis {
  /// Entered by the user.
  own,

  /// "Sparen gesamt" of the standing orders.
  plan,

  /// No savings planned: the average growth of the last twelve months
  /// (it already contains market moves, so no extra return is added).
  trend,

  /// Nothing known – only the return on what is invested today.
  none,
}

class ProjectionAssumptions {
  const ProjectionAssumptions({
    required this.basis,
    required this.monthlySaving,
    required this.monthlyInvested,
    required this.annualReturn,
  });

  final ProjectionBasis basis;
  final double monthlySaving;

  /// Part of [monthlySaving] that goes into invested accounts and earns the return.
  final double monthlyInvested;
  final double annualReturn;

  double get monthlyReturnRate => math.pow(1 + annualReturn, 1 / 12) - 1;
}

/// Average change per month of [value] over the last year (at least four
/// weeks of entries); null when there is too little history.
double? monthlyTrend(List<BalanceRow> rows, DateTime today, double Function(BalanceRow r) value) {
  if (rows.length < 2) return null;
  final yearAgo = DateTime(today.year - 1, today.month, today.day);
  final first = rows.lastWhere((r) => !r.date.isAfter(yearAgo), orElse: () => rows.first);
  final last = rows.last;
  final days = daysBetween(first.date, last.date);
  if (days < 28) return null;
  return (value(last) - value(first)) / (days / daysPerMonth);
}

ProjectionAssumptions projectionAssumptions(ProjectionSettings s, RecurringSummary r, double? trend) {
  double investedShare(double saving) =>
      r.savingsTotal > 0 ? saving * r.savingsInvested / r.savingsTotal : 0;
  if (s.monthlySaving != null) {
    final saving = s.monthlySaving!;
    return ProjectionAssumptions(
      basis: ProjectionBasis.own,
      monthlySaving: saving,
      monthlyInvested: (s.monthlyInvested ?? investedShare(saving)).clamp(0, math.max(0, saving)).toDouble(),
      annualReturn: s.annualReturn,
    );
  }
  if (r.savingsTotal > 0) {
    return ProjectionAssumptions(
      basis: ProjectionBasis.plan,
      monthlySaving: r.savingsTotal,
      monthlyInvested: (s.monthlyInvested ?? r.savingsInvested).clamp(0, r.savingsTotal).toDouble(),
      annualReturn: s.annualReturn,
    );
  }
  if (trend != null) {
    return ProjectionAssumptions(basis: ProjectionBasis.trend, monthlySaving: trend, monthlyInvested: 0, annualReturn: 0);
  }
  return ProjectionAssumptions(
    basis: ProjectionBasis.none,
    monthlySaving: 0,
    monthlyInvested: 0,
    annualReturn: s.annualReturn,
  );
}

class ProjectionPoint {
  const ProjectionPoint({required this.date, required this.total, required this.contributed, required this.returns});

  final DateTime date;
  final double total;

  /// Sum of the monthly savings so far.
  final double contributed;

  /// Sum of the returns so far (compound interest).
  final double returns;
}

class Projection {
  const Projection({required this.assumptions, required this.points});

  final ProjectionAssumptions assumptions;

  /// Month by month; the first point is today.
  final List<ProjectionPoint> points;

  ProjectionPoint afterMonths(int months) => points[math.min(months, points.length - 1)];
}

/// Month [i] after [today] (the 1st of that month; today itself for 0).
DateTime _monthAfter(DateTime today, int i) => i == 0 ? today : DateTime(today.year, today.month + i);

/// Steps the wealth forward month by month: the invested part grows with
/// the return and receives [ProjectionAssumptions.monthlyInvested], the rest
/// of the saving is added as it is. Debts stay as they are.
Projection project({
  required Overview overview,
  required ProjectionAssumptions assumptions,
  required DateTime today,
  required int months,
}) {
  final rate = assumptions.monthlyReturnRate;
  var invested = overview.invested;
  var other = overview.liquid - overview.debt;
  var contributed = 0.0, returns = 0.0;
  final points = [ProjectionPoint(date: today, total: invested + other, contributed: 0, returns: 0)];
  for (var i = 1; i <= months; i++) {
    final gain = invested * rate;
    invested += gain + assumptions.monthlyInvested;
    other += assumptions.monthlySaving - assumptions.monthlyInvested;
    contributed += assumptions.monthlySaving;
    returns += gain;
    points.add(ProjectionPoint(date: _monthAfter(today, i), total: invested + other, contributed: contributed, returns: returns));
  }
  return Projection(assumptions: assumptions, points: points);
}

/// When a goal is expected to be reached.
class GoalForecast {
  const GoalForecast._(this.date, this.reached);

  const GoalForecast.reached() : this._(null, true);
  const GoalForecast.unreachable() : this._(null, false);
  const GoalForecast.on(DateTime date) : this._(date, false);

  /// Month in which the goal is reached; null when already reached or unreachable.
  final DateTime? date;
  final bool reached;

  bool get unreachable => !reached && date == null;
}

/// Longest look-ahead: 100 years.
const _maxMonths = 1200;

GoalForecast _forecast(double current, double target, DateTime today, double Function(int month) valueAfter) {
  if (current >= target) return const GoalForecast.reached();
  for (var i = 1; i <= _maxMonths; i++) {
    if (valueAfter(i) >= target) return GoalForecast.on(_monthAfter(today, i));
  }
  return const GoalForecast.unreachable();
}

/// Net-worth goal with the projection's assumptions.
GoalForecast netWorthForecast({
  required Overview overview,
  required ProjectionAssumptions assumptions,
  required double target,
  required DateTime today,
}) {
  final p = project(overview: overview, assumptions: assumptions, today: today, months: _maxMonths);
  return _forecast(overview.total, target, today, (i) => p.points[i].total);
}

/// Monthly savings into [account] minus savings out of it (standing orders).
double accountInflow(AppData data, Account account, DateTime today) {
  var inflow = 0.0;
  for (final item in data.recurring) {
    if (item.type != RecurringType.saving) continue;
    final monthly = monthlyAmount(item, today);
    if (item.toAccountId == account.id) inflow += monthly;
    if (item.fromAccountId == account.id) inflow -= monthly;
  }
  return inflow;
}

/// Goal of one account: planned savings into it (plus the return when it is
/// invested), else its trend over the last year.
GoalForecast accountForecast({
  required AppData data,
  required Account account,
  required double balance,
  required double target,
  required List<BalanceRow> rows,
  required double annualReturn,
  required DateTime today,
}) {
  final inflow = accountInflow(data, account, today);
  if (inflow > 0) {
    final invested = data.behaviorOf(account) == AccountBehavior.invested;
    final rate = invested ? math.pow(1 + annualReturn, 1 / 12) - 1 : 0.0;
    var value = balance;
    var month = 0;
    return _forecast(balance, target, today, (i) {
      while (month < i) {
        value = value * (1 + rate) + inflow;
        month++;
      }
      return value;
    });
  }
  final trend = monthlyTrend(rows, today, (r) => r.balanceOf(account.id));
  if (trend == null || trend <= 0) {
    return balance >= target ? const GoalForecast.reached() : const GoalForecast.unreachable();
  }
  return _forecast(balance, target, today, (i) => balance + trend * i);
}

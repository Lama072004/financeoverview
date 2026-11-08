import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dates.dart';
import '../data/models.dart';
import '../domain/backup_reminder.dart';
import '../domain/chart_range.dart';
import '../domain/investment_calc.dart';
import '../domain/overview_calc.dart';
import '../domain/projection_calc.dart';
import '../domain/purchase_calc.dart';
import '../domain/review_calc.dart';
import '../domain/recurring_calc.dart';
import '../domain/savings_goal_calc.dart';
import 'session.dart';

final todayProvider = Provider<DateTime>((ref) => dateOnly(ref.watch(clockProvider)()));

/// Dashboard hint to make a backup.
final backupReminderProvider = Provider<BackupReminder>(
  (ref) => backupReminder(prefs: ref.watch(prefsProvider), data: ref.watch(appDataProvider), now: ref.read(clockProvider)()),
);

final balanceHistoryProvider = Provider<List<BalanceRow>>((ref) => balanceHistory(ref.watch(appDataProvider)));

final recurringSummaryProvider = Provider<RecurringSummary>(
  (ref) => summarizeRecurring(ref.watch(appDataProvider), ref.watch(todayProvider)),
);

final overviewProvider = Provider<Overview>(
  (ref) => buildOverview(
    ref.watch(appDataProvider),
    ref.watch(balanceHistoryProvider),
    ref.watch(recurringSummaryProvider),
  ),
);

final periodEstimatesProvider = Provider<List<PeriodEstimate?>>(
  (ref) => periodEstimates(ref.watch(balanceHistoryProvider), ref.watch(recurringSummaryProvider)),
);

final monthlySpendingProvider = Provider.family<MonthlySpending, DateTime>(
  (ref, month) => monthlySpending(
    ref.watch(appDataProvider),
    month,
    ref.watch(todayProvider),
    ref.watch(balanceHistoryProvider),
  ),
);

final savingsGoalProvider = Provider<SavingsGoalStatus>(
  (ref) => savingsGoalStatus(
    ref.watch(appDataProvider),
    ref.watch(overviewProvider),
    ref.watch(recurringSummaryProvider),
  ),
);

/// Everything the review and the report are computed from.
final reviewInputProvider = Provider<ReviewInput>(
  (ref) => ReviewInput(
    data: ref.watch(appDataProvider),
    rows: ref.watch(balanceHistoryProvider),
    estimates: ref.watch(periodEstimatesProvider),
    recurring: ref.watch(recurringSummaryProvider),
    today: ref.watch(todayProvider),
  ),
);

final projectionAssumptionsProvider = Provider<ProjectionAssumptions>((ref) {
  final rows = ref.watch(balanceHistoryProvider);
  return projectionAssumptions(
    ref.watch(appDataProvider.select((d) => d.projection)),
    ref.watch(recurringSummaryProvider),
    monthlyTrend(rows, ref.watch(todayProvider), (r) => r.total),
  );
});

final projectionProvider = Provider<Projection>(
  (ref) => project(
    overview: ref.watch(overviewProvider),
    assumptions: ref.watch(projectionAssumptionsProvider),
    today: ref.watch(todayProvider),
    months: ref.watch(appDataProvider.select((d) => d.projection.years)) * 12,
  ),
);

/// Expected date of each savings goal: key null = net-worth goal, otherwise
/// the account id. Empty for the savings-rate goal.
final goalForecastsProvider = Provider<Map<String?, GoalForecast>>((ref) {
  final status = ref.watch(savingsGoalProvider);
  final today = ref.watch(todayProvider);
  switch (status.mode) {
    case SavingsGoalMode.savingsRate:
      return const {};
    case SavingsGoalMode.netWorth:
      final goal = status.primary;
      if (goal == null) return const {};
      return {
        null: netWorthForecast(
          overview: ref.watch(overviewProvider),
          assumptions: ref.watch(projectionAssumptionsProvider),
          target: goal.target,
          today: today,
        ),
      };
    case SavingsGoalMode.perAccount:
      final data = ref.watch(appDataProvider);
      final rows = ref.watch(balanceHistoryProvider);
      return {
        for (final g in status.accountGoals)
          g.account!.id: accountForecast(
            data: data,
            account: g.account!,
            balance: g.current,
            target: g.target,
            rows: rows,
            annualReturn: data.projection.annualReturn,
            today: today,
          ),
      };
  }
});

final investmentResultProvider = Provider<InvestmentResult>((ref) {
  final data = ref.watch(appDataProvider);
  return calculateInvestments(data.investments, onlineEnabled: data.onlinePricesEnabled);
});

final financialSituationProvider = Provider<FinancialSituation>((ref) {
  final o = ref.watch(overviewProvider);
  final r = ref.watch(recurringSummaryProvider);
  return FinancialSituation(
    netWorth: o.total,
    liquid: o.liquid,
    monthlyIncome: r.fixedIncome,
    monthlyFixedExpenses: r.fixedExpenses,
    monthlySavings: r.savingsTotal,
    monthlyFree: r.free,
    savingsRate: r.savingsRate,
  );
});

final purchaseResultProvider = Provider<PurchaseResult>(
  (ref) => calculatePurchase(ref.watch(appDataProvider).purchase, ref.watch(financialSituationProvider)),
);

/// Accounts grouped by type, in the user's order.
final accountsByTypeProvider = Provider<List<(AccountType?, List<AccountOverview>)>>((ref) {
  final data = ref.watch(appDataProvider);
  final overview = ref.watch(overviewProvider);
  final groups = <(AccountType?, List<AccountOverview>)>[];
  for (final type in [...data.accountTypes, null]) {
    final members = overview.accounts
        .where((a) => !a.account.archived && (type == null ? data.typeOf(a.account) == null : a.account.typeId == type.id))
        .toList();
    if (members.isNotEmpty) groups.add((type, members));
  }
  return groups;
});

/// Selected time window of the history charts, shared across screens.
class ChartRangeNotifier extends Notifier<ChartRange> {
  @override
  ChartRange build() => ChartRange.all;

  void select(ChartRange range) => state = range;
}

final chartRangeProvider = NotifierProvider<ChartRangeNotifier, ChartRange>(ChartRangeNotifier.new);

import '../data/models.dart';
import 'overview_calc.dart';
import 'recurring_calc.dart';

class GoalProgress {
  const GoalProgress({required this.current, required this.target, this.account});

  final double current;
  final double target;

  /// Set for per-account goals.
  final Account? account;

  /// 0..1 (may exceed 1 when the goal is reached).
  double get progress => target <= 0 ? 0 : current / target;

  double get remaining => target - current;

  bool get reached => target > 0 && current >= target;
}

class SavingsGoalStatus {
  const SavingsGoalStatus({required this.mode, required this.primary, required this.accountGoals});

  final SavingsGoalMode mode;

  /// The goal shown on the dashboard; null when nothing is configured yet.
  final GoalProgress? primary;

  /// All per-account goals (only in [SavingsGoalMode.perAccount]).
  final List<GoalProgress> accountGoals;
}

SavingsGoalStatus savingsGoalStatus(AppData data, Overview overview, RecurringSummary recurring) {
  final settings = data.savingsGoal;
  switch (settings.mode) {
    case SavingsGoalMode.savingsRate:
      return SavingsGoalStatus(
        mode: settings.mode,
        primary: settings.targetRate > 0
            ? GoalProgress(current: recurring.savingsRate, target: settings.targetRate)
            : null,
        accountGoals: const [],
      );
    case SavingsGoalMode.netWorth:
      return SavingsGoalStatus(
        mode: settings.mode,
        primary: settings.netWorthTarget > 0
            ? GoalProgress(current: overview.total, target: settings.netWorthTarget)
            : null,
        accountGoals: const [],
      );
    case SavingsGoalMode.perAccount:
      final goals = [
        for (final a in overview.accounts)
          if ((a.account.savingsGoal ?? 0) > 0 && !a.account.archived)
            GoalProgress(current: a.balance, target: a.account.savingsGoal!, account: a.account),
      ];
      final pinned = goals.where((g) => g.account!.id == settings.pinnedAccountId).firstOrNull;
      return SavingsGoalStatus(
        mode: settings.mode,
        primary: pinned ?? goals.firstOrNull,
        accountGoals: goals,
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/chart_range.dart';
import '../../domain/overview_calc.dart';
import '../../domain/projection_calc.dart';
import '../../domain/savings_goal_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../accounts/account_detail_screen.dart';
import '../history/net_worth_history_screen.dart';
import '../more/recurring_screen.dart';
import '../more/savings_goal_screen.dart';
import '../projection/projection_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/range_selector.dart';

String cardTitle(AppLocalizations l, DashboardCardType type) => switch (type) {
      DashboardCardType.netWorth => l.cardNetWorth,
      DashboardCardType.spendingDonut => l.cardSpending,
      DashboardCardType.savingsGoal => l.cardSavingsGoal,
      DashboardCardType.categories => l.cardCategories,
      DashboardCardType.netWorthChart => l.cardChart,
      DashboardCardType.accounts => l.cardAccounts,
      DashboardCardType.recurringSummary => l.cardRecurring,
      DashboardCardType.lastPeriod => l.cardLastPeriod,
    };

IconData cardIcon(DashboardCardType type) => switch (type) {
      DashboardCardType.netWorth => Icons.account_balance_wallet_rounded,
      DashboardCardType.spendingDonut => Icons.donut_large_rounded,
      DashboardCardType.savingsGoal => Icons.flag_rounded,
      DashboardCardType.categories => Icons.category_rounded,
      DashboardCardType.netWorthChart => Icons.show_chart_rounded,
      DashboardCardType.accounts => Icons.account_balance_rounded,
      DashboardCardType.recurringSummary => Icons.event_repeat_rounded,
      DashboardCardType.lastPeriod => Icons.date_range_rounded,
    };

Widget buildDashboardCard(DashboardCardConfig config) {
  final large = config.size == CardSize.large;
  return switch (config.type) {
    DashboardCardType.netWorth => NetWorthCard(large: large),
    DashboardCardType.spendingDonut => SpendingCard(large: large),
    DashboardCardType.savingsGoal => SavingsGoalCard(large: large),
    DashboardCardType.categories => CategoriesCard(large: large),
    DashboardCardType.netWorthChart => NetWorthChartCard(large: large),
    DashboardCardType.accounts => AccountsCard(large: large),
    DashboardCardType.recurringSummary => RecurringSummaryCard(large: large),
    DashboardCardType.lastPeriod => LastPeriodCard(large: large),
  };
}

// ---------------------------------------------------------------------------

class NetWorthCard extends ConsumerWidget {
  const NetWorthCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final o = ref.watch(overviewProvider);
    final fin = context.fin;
    final hasDebt = o.debt > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            l.cardNetWorth,
            trailing: !large || o.latest == null ? null : Text(fmt.date(o.latest!.date), style: context.text.labelMedium),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Amount(
              fmt.money(o.total),
              style: context.text.displaySmall?.copyWith(fontSize: large ? 36 : 32),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (o.previous != o.latest)
                DeltaChip(text: fmt.signedMoney(o.deltaSincePrevious), value: o.deltaSincePrevious, label: l.sinceLastEntry),
              if (large)
                DeltaChip(
                  text: fmt.signedMoney(o.deltaSinceYearStart),
                  value: o.deltaSinceYearStart,
                  label: l.sinceYearStart,
                ),
            ],
          ),
          if (large && o.hasData) ...[
            const SizedBox(height: 18),
            _SplitBar(
              parts: [
                (o.liquid, fin.liquidLine),
                (o.invested, fin.investedLine),
                if (hasDebt) (o.debt, fin.debtLine),
              ],
            ),
            const SizedBox(height: 12),
            _SplitRow(color: fin.liquidLine, label: l.liquid, value: fmt.money(o.liquid)),
            _SplitRow(color: fin.investedLine, label: l.invested, value: fmt.money(o.invested)),
            if (hasDebt) _SplitRow(color: fin.debtLine, label: l.debts, value: fmt.money(-o.debt)),
          ],
        ],
      ),
    );
  }
}

class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.parts});

  final List<(double, Color)> parts;

  @override
  Widget build(BuildContext context) {
    final positive = parts.where((p) => p.$1 > 0).toList();
    final total = positive.fold<double>(0, (s, p) => s + p.$1);
    if (total <= 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (var i = 0; i < positive.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                flex: (positive[i].$1 / total * 1000).round().clamp(1, 1000),
                child: ColoredBox(color: positive[i].$2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            LegendDot(color: color, label: label),
            const Spacer(),
            Amount(value, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------

/// Colour and label for one spending slice.
({Color color, String label, IconData icon}) spendingStyle(
  BuildContext context,
  AppData data,
  String? categoryId,
) {
  final l = AppLocalizations.of(context);
  final c = data.categoryById(categoryId);
  return (
    color: c == null ? context.fin.muted : context.fin.chartColor(c.colorIndex),
    label: c?.name ?? l.noCategory,
    icon: categoryIcon(c?.icon),
  );
}

class SpendingCard extends ConsumerStatefulWidget {
  const SpendingCard({super.key, required this.large});

  final bool large;

  @override
  ConsumerState<SpendingCard> createState() => _SpendingCardState();
}

class _SpendingCardState extends ConsumerState<SpendingCard> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final today = ref.watch(todayProvider);
    final month = DateTime(today.year, today.month - _offset);
    final spending = ref.watch(monthlySpendingProvider(firstOfMonth(month)));
    final data = ref.watch(appDataProvider);
    final unassignedColor = context.fin.track;

    final segments = [
      for (final c in spending.categories) DonutSegment(c.total, spendingStyle(context, data, c.categoryId).color),
      if (spending.unassigned > 0) DonutSegment(spending.unassigned, unassignedColor),
    ];

    final legend = [
      for (final c in spending.categories)
        (spendingStyle(context, data, c.categoryId).color, spendingStyle(context, data, c.categoryId).label, c.total),
      if (spending.unassigned > 0) (unassignedColor, l.unassigned, spending.unassigned),
    ]..sort((a, b) => b.$3.compareTo(a.$3));

    final center = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          child: Amount(
            fmt.moneyRound(spending.total),
            style: widget.large ? context.text.titleLarge : context.text.titleSmall,
          ),
        ),
        Text(fmt.monthShort(month), style: context.text.labelSmall),
      ],
    );

    final header = CardHeader(
      l.cardSpending,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(icon: Icons.chevron_left_rounded, onTap: () => setState(() => _offset++)),
          Text(fmt.month(month), style: context.text.labelMedium),
          _MiniIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: _offset == 0 ? null : () => setState(() => _offset--),
          ),
        ],
      ),
    );

    if (spending.total <= 0) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 16),
            Row(
              children: [
                const DonutChart(segments: [], size: 64),
                const SizedBox(width: 16),
                Expanded(child: Text(l.noSpendingThisMonth, style: context.text.bodyMedium)),
              ],
            ),
          ],
        ),
      );
    }

    if (!widget.large) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 14),
            Row(
              children: [
                DonutChart(segments: segments, size: 112, center: center),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      for (final item in legend.take(4))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(child: LegendDot(color: item.$1, label: item.$2)),
                              Amount(fmt.moneyRound(item.$3), style: context.text.labelLarge),
                            ],
                          ),
                        ),
                      if (legend.length > 4)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('+${legend.length - 4}', style: context.text.labelMedium),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final fixed = spending.categories.fold<double>(0, (s, c) => s + c.fixed);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 18),
          Center(child: DonutChart(segments: segments, size: 184, center: center)),
          const SizedBox(height: 18),
          for (final item in legend)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: LegendDot(color: item.$1, label: item.$2)),
                  Text(
                    spending.total == 0 ? '' : fmt.percentRound(item.$3 / spending.total),
                    style: context.text.labelMedium,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: Amount(fmt.money(item.$3), style: context.text.labelLarge, textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
          const Divider(height: 24),
          KeyValueRow(label: l.fixedCosts, value: fmt.money(fixed)),
          KeyValueRow(label: l.singleBookings, value: fmt.money(spending.singleExpenses)),
          if (spending.estimatedVariable != null)
            KeyValueRow(label: l.unassigned, value: fmt.money(spending.unassigned), hint: l.unassignedHint),
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 22, color: onTap == null ? context.colors.outline : context.fin.muted),
        ),
      );
}

// ---------------------------------------------------------------------------

class SavingsGoalCard extends ConsumerWidget {
  const SavingsGoalCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final status = ref.watch(savingsGoalProvider);
    final forecasts = ref.watch(goalForecastsProvider);
    final goal = status.primary;

    final title = switch (status.mode) {
      SavingsGoalMode.savingsRate => l.goalRateLabel,
      SavingsGoalMode.netWorth => l.goalNetWorthLabel,
      SavingsGoalMode.perAccount => goal?.account?.name ?? l.goalModeAccount,
    };

    void openSettings() => push(context, const SavingsGoalScreen());

    if (goal == null) {
      return AppCard(
        onTap: openSettings,
        child: Row(
          children: [
            IconBadge(icon: Icons.flag_rounded, color: context.fin.accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.cardSavingsGoal, style: context.text.titleSmall),
                  Text(l.goalNotSet, style: context.text.bodySmall),
                ],
              ),
            ),
            TextButton(onPressed: openSettings, child: Text(l.goalSetUp)),
          ],
        ),
      );
    }

    final goals = large && status.mode == SavingsGoalMode.perAccount ? status.accountGoals : [goal];
    return AppCard(
      onTap: openSettings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardSavingsGoal, trailing: Text(fmt.percentRound(goal.progress), style: context.text.labelLarge)),
          for (final g in goals) ...[
            const SizedBox(height: 12),
            _GoalRow(
              goal: g,
              title: g.account?.name ?? title,
              rate: status.mode == SavingsGoalMode.savingsRate,
              forecast: forecasts[g.account?.id],
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.goal, required this.title, required this.rate, this.forecast});

  final GoalProgress goal;
  final String title;
  final bool rate;

  /// Expected date (not for the savings-rate goal).
  final GoalForecast? forecast;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    String f(double v) => rate ? fmt.percent(v) : fmt.moneyRound(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: context.text.titleSmall)),
            Text(l.goalOf(f(goal.current), f(goal.target)), style: money(context.text.labelMedium)),
          ],
        ),
        const SizedBox(height: 8),
        ProgressBar(value: goal.progress, color: goal.reached ? context.fin.positive : null),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                goal.reached ? l.goalReached : l.goalRemaining(f(goal.remaining)),
                style: context.text.bodySmall?.copyWith(color: goal.reached ? context.fin.positive : null),
              ),
            ),
            if (forecast != null && !goal.reached)
              Text(
                forecast!.unreachable ? l.forecastUnreachable : l.forecastExpected(forecastLabel(l, fmt, forecast!)),
                style: context.text.bodySmall,
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class CategoriesCard extends ConsumerStatefulWidget {
  const CategoriesCard({super.key, required this.large});

  final bool large;

  @override
  ConsumerState<CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends ConsumerState<CategoriesCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final today = ref.watch(todayProvider);
    final spending = ref.watch(monthlySpendingProvider(firstOfMonth(today)));
    final data = ref.watch(appDataProvider);
    final rows = spending.categories;
    final limit = widget.large || _expanded ? rows.length : 4;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardCategories, trailing: Text(fmt.month(today), style: context.text.labelMedium)),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l.noSpendingThisMonth, style: context.text.bodyMedium),
            ),
          for (final c in rows.take(limit))
            Builder(builder: (context) {
              final s = spendingStyle(context, data, c.categoryId);
              final parts = [
                if (c.fixed > 0) '${l.fixedCosts} ${fmt.moneyRound(c.fixed)}',
                if (c.single > 0) '${l.singleBookings} ${fmt.moneyRound(c.single)}',
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    IconBadge(icon: s.icon, color: s.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.label, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(parts.join(' · '), style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Amount(fmt.money(c.total), style: context.text.titleSmall),
                        Text(
                          spending.total == 0 ? '' : fmt.percentRound(c.total / spending.total),
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          if (!widget.large && rows.length > 4)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? l.showLess : l.showAll),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class NetWorthChartCard extends ConsumerWidget {
  const NetWorthChartCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final fin = context.fin;
    final rows = ref.watch(balanceHistoryProvider);
    final today = ref.watch(todayProvider);
    final range = ref.watch(chartRangeProvider);
    final hasDebt = rows.any((r) => r.debt > 0);

    List<(DateTime, double)> pts(double Function(BalanceRow r) v) => rangeSeries(rows, range, today, v);
    final totalPoints = pts((r) => r.total);
    final change = seriesChange(totalPoints);

    final series = [
      ChartSeries(label: l.total, color: fin.totalLine, fill: true, points: totalPoints),
      if (large) ...[
        ChartSeries(label: l.liquid, color: fin.liquidLine, points: pts((r) => r.liquid)),
        ChartSeries(label: l.invested, color: fin.investedLine, points: pts((r) => r.invested)),
        if (hasDebt) ChartSeries(label: l.debts, color: fin.debtLine, points: pts((r) => -r.debt)),
      ],
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      onTap: () => push(context, const NetWorthHistoryScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: CardHeader(
              l.cardChart,
              trailing: Icon(Icons.open_in_full_rounded, size: 18, color: fin.muted, semanticLabel: l.openHistory),
            ),
          ),
          if (rows.length < 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(l.chartNeedTwo, style: context.text.bodyMedium?.copyWith(color: fin.muted)),
            )
          else ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: DeltaChip(
                text: change.relative == null
                    ? fmt.signedMoney(change.absolute)
                    : '${fmt.signedMoney(change.absolute)} · ${fmt.percent(change.relative!.abs())}',
                value: change.absolute,
                label: l.inRange,
              ),
            ),
            const SizedBox(height: 14),
            TimeLineChart(series: series, height: large ? 220 : 160),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: RangeSelector(value: range, onChanged: ref.read(chartRangeProvider.notifier).select),
            ),
            if (large) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [for (final s in series) LegendDot(color: s.color, label: s.label)],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class AccountsCard extends ConsumerWidget {
  const AccountsCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final accounts = ref.watch(overviewProvider).accounts.where((a) => !a.account.archived).toList();
    final shown = large ? accounts : accounts.take(5).toList();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardAccounts),
          const SizedBox(height: 6),
          for (final a in shown)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => push(context, AccountDetailScreen(accountId: a.account.id)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    IconBadge(icon: accountIcon(a.account.icon), color: context.fin.chartColor(a.account.colorIndex)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.account.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(data.typeOf(a.account)?.name ?? '', style: context.text.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Amount(
                          fmt.money(a.behavior == AccountBehavior.debt ? -a.balance : a.balance),
                          style: context.text.titleSmall,
                        ),
                        if (large || a.deltaSincePrevious.abs() >= 0.005)
                          Amount(
                            fmt.signedMoney(a.deltaSincePrevious),
                            value: a.deltaSincePrevious,
                            colored: true,
                            invert: a.behavior == AccountBehavior.debt,
                            style: context.text.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (!large && accounts.length > shown.length)
            Center(
              child: TextButton(
                onPressed: () => ref.read(homeTabProvider.notifier).select(Tabs.accounts),
                child: Text(l.showAll),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class RecurringSummaryCard extends ConsumerWidget {
  const RecurringSummaryCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final r = ref.watch(recurringSummaryProvider);

    Widget row(String label, double monthly, {bool emphasize = false, bool colored = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(child: Text(label, style: emphasize ? context.text.titleSmall : context.text.bodyMedium)),
              Amount(fmt.money(monthly), value: monthly, colored: colored, style: context.text.titleSmall),
              if (large)
                SizedBox(
                  width: 104,
                  child: Amount(
                    fmt.moneyRound(monthly * 12),
                    style: context.text.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        );

    return AppCard(
      onTap: () => push(context, const RecurringScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardRecurring, trailing: large ? null : Text(l.perMonth, style: context.text.labelSmall)),
          if (large)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Spacer(),
                  Text(l.perMonth, style: context.text.labelSmall),
                  SizedBox(
                    width: 104,
                    child: Text(l.perYear, style: context.text.labelSmall, textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          row(l.recurringIncome, r.fixedIncome),
          row(l.recurringExpenses, r.fixedExpenses),
          row(l.recurringSavings, r.savingsTotal),
          if (large) row(l.recurringSavingsInvested, r.savingsInvested),
          const Divider(height: 16),
          row(l.recurringFree, r.free, emphasize: true, colored: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text(l.savingsRate, style: context.text.bodyMedium)),
                Amount(fmt.percent(r.savingsRate), style: context.text.titleSmall),
                if (large) const SizedBox(width: 104),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class LastPeriodCard extends ConsumerWidget {
  const LastPeriodCard({super.key, required this.large});

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final p = ref.watch(overviewProvider).lastPeriod;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardLastPeriod),
          const SizedBox(height: 8),
          if (p == null)
            Text(l.periodNeedTwo, style: context.text.bodyMedium?.copyWith(color: context.fin.muted))
          else ...[
            KeyValueRow(
              label: l.periodDays,
              value: l.daysCount(p.days),
              hint: '${fmt.dateShort(p.from)} – ${fmt.dateShort(p.to)}',
            ),
            KeyValueRow(label: l.periodDelta, value: fmt.signedMoney(p.deltaTotal), amount: p.deltaTotal, colored: true),
            KeyValueRow(label: l.periodVariable, value: fmt.money(p.variableExpenses)),
            KeyValueRow(
              label: l.periodReturn,
              value: fmt.signedMoney(p.investmentReturn),
              amount: p.investmentReturn,
              colored: true,
            ),
            if (large) ...[const SizedBox(height: 10), InfoNote(l.periodHint)],
          ],
        ],
      ),
    );
  }
}

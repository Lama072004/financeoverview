import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/projection_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

/// Wealth forecast for the next years and the expected date of the savings goal.
class ProjectionScreen extends ConsumerStatefulWidget {
  const ProjectionScreen({super.key});

  @override
  ConsumerState<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends ConsumerState<ProjectionScreen> {
  final _saving = TextEditingController();
  final _invested = TextEditingController();
  final _return = TextEditingController();
  late final DataActions _actions = ref.read(actionsProvider);
  Timer? _debounce;
  bool _dirty = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _fill(ref.read(appDataProvider).projection);
  }

  void _fill(ProjectionSettings s) {
    final fmt = Fmt.of(context);
    _saving.text = s.monthlySaving == null ? '' : fmt.plain(s.monthlySaving!);
    _invested.text = s.monthlyInvested == null ? '' : fmt.plain(s.monthlyInvested!);
    _return.text = fmt.plain(s.annualReturn * 100);
  }

  ProjectionSettings Function(ProjectionSettings p) _change() {
    final saving = parseAmount(_saving.text);
    final invested = parseAmount(_invested.text);
    final ret = parseAmount(_return.text);
    return (p) => p.copyWith(
          monthlySaving: () => saving,
          monthlyInvested: () => invested,
          annualReturn: ret == null ? const ProjectionSettings().annualReturn : ret / 100,
        );
  }

  void _saveLater() {
    _debounce?.cancel();
    _dirty = true;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _dirty = false;
      _actions.updateProjection(_change());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_dirty) {
      final change = _change();
      final actions = _actions;
      Future.microtask(() => actions.updateProjection(change));
    }
    _saving.dispose();
    _invested.dispose();
    _return.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final fin = context.fin;
    final settings = ref.watch(appDataProvider.select((d) => d.projection));
    final assumptions = ref.watch(projectionAssumptionsProvider);
    final projection = ref.watch(projectionProvider);
    final rows = ref.watch(balanceHistoryProvider);
    final recurring = ref.watch(recurringSummaryProvider);
    final end = projection.points.last;
    final years = settings.years;

    final basisText = switch (assumptions.basis) {
      ProjectionBasis.own => l.projectionBasisOwn,
      ProjectionBasis.plan => l.projectionBasisPlan,
      ProjectionBasis.trend => l.projectionBasisTrend(fmt.money(assumptions.monthlySaving)),
      ProjectionBasis.none => l.projectionBasisNone,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.projectionTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final y in ProjectionSettings.yearOptions) ButtonSegment(value: y, label: Text(l.yearsShort(y))),
            ],
            selected: {years},
            onSelectionChanged: (s) => _actions.updateProjection((p) => p.copyWith(years: s.first)),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(l.projectionIn(years), trailing: Text(fmt.month(end.date), style: context.text.labelMedium)),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Amount(fmt.money(end.total), style: context.text.displaySmall?.copyWith(fontSize: 32)),
                ),
                const SizedBox(height: 16),
                TimeLineChart(
                  height: 190,
                  series: [
                    if (rows.isNotEmpty)
                      ChartSeries(
                        label: l.projectionHistory,
                        color: fin.totalLine,
                        fill: true,
                        points: [for (final r in rows) (r.date, r.total)],
                      ),
                    ChartSeries(
                      label: l.projectionTitle,
                      color: fin.accent,
                      dashed: true,
                      points: [for (final p in projection.points) (p.date, p.total)],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  children: [
                    if (rows.isNotEmpty) LegendDot(color: fin.totalLine, label: l.projectionHistory),
                    LegendDot(color: fin.accent, label: l.projectionTitle),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 6),
                KeyValueRow(label: l.projectionToday, value: fmt.money(projection.points.first.total)),
                KeyValueRow(label: l.projectionContributed, value: fmt.signedMoney(end.contributed)),
                KeyValueRow(label: l.projectionReturns, value: fmt.signedMoney(end.returns)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(l.projectionMilestones),
                const SizedBox(height: 6),
                for (final y in const [1, 2, 5, 10, 20, 30])
                  if (y <= years)
                    KeyValueRow(
                      label: l.projectionAfterYears(y, projection.afterMonths(y * 12).date.year),
                      value: fmt.money(projection.afterMonths(y * 12).total),
                    ),
              ],
            ),
          ),
          const _GoalForecastCard(),
          SectionTitle(l.projectionAssumptions),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NumberField(
                  controller: _saving,
                  label: l.projectionSaving,
                  hint: fmt.hidden ? null : fmt.plain(recurring.savingsTotal),
                  helper: l.projectionFromPlan(fmt.money(recurring.savingsTotal)),
                  onChanged: (_) => _saveLater(),
                ),
                const SizedBox(height: 14),
                NumberField(
                  controller: _invested,
                  label: l.projectionInvested,
                  hint: fmt.hidden ? null : fmt.plain(assumptions.monthlyInvested),
                  helper: l.projectionInvestedHint,
                  onChanged: (_) => _saveLater(),
                ),
                const SizedBox(height: 14),
                NumberField(
                  controller: _return,
                  label: l.projectionReturn,
                  suffix: '%',
                  helper: l.projectionReturnHint,
                  onChanged: (_) => _saveLater(),
                ),
                const SizedBox(height: 14),
                InfoNote(basisText),
                if (settings.monthlySaving != null || settings.monthlyInvested != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        _debounce?.cancel();
                        _dirty = false;
                        final reset = settings.copyWith(monthlySaving: () => null, monthlyInvested: () => null);
                        _actions.updateProjection((_) => reset);
                        _fill(reset);
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(l.projectionUsePlan),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.projectionDisclaimer, style: context.text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Expected dates of the savings goals, also shown on the dashboard card.
class _GoalForecastCard extends ConsumerWidget {
  const _GoalForecastCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final forecasts = ref.watch(goalForecastsProvider);
    final status = ref.watch(savingsGoalProvider);
    if (forecasts.isEmpty) return const SizedBox.shrink();
    final goals = status.mode == SavingsGoalMode.perAccount ? status.accountGoals : [status.primary!];
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(l.cardSavingsGoal, icon: Icons.flag_rounded),
            const SizedBox(height: 6),
            for (final g in goals)
              KeyValueRow(
                label: g.account?.name ?? l.goalNetWorthLabel,
                hint: l.goalOf(fmt.moneyRound(g.current), fmt.moneyRound(g.target)),
                value: forecastLabel(l, fmt, forecasts[g.account?.id] ?? const GoalForecast.unreachable()),
              ),
          ],
        ),
      ),
    );
  }
}

String forecastLabel(AppLocalizations l, Fmt fmt, GoalForecast f) {
  if (f.reached) return l.goalReached;
  if (f.date == null) return l.forecastUnreachable;
  return fmt.month(f.date!);
}

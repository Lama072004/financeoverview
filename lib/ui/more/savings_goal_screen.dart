import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

/// Choose how the dashboard's savings goal is measured.
class SavingsGoalScreen extends ConsumerStatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  ConsumerState<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends ConsumerState<SavingsGoalScreen> {
  final _rate = TextEditingController();
  final _netWorth = TextEditingController();
  Timer? _debounce;
  SavingsGoalSettings Function(SavingsGoalSettings g)? _pending;
  late final DataActions _actions = ref.read(actionsProvider);
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _actions;
    final fmt = Fmt.of(context);
    final g = ref.read(appDataProvider).savingsGoal;
    if (g.targetRate > 0) _rate.text = fmt.plain(g.targetRate * 100);
    if (g.netWorthTarget > 0) _netWorth.text = fmt.plain(g.netWorthTarget);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final pending = _pending;
    final actions = _actions;
    if (pending != null) Future.microtask(() => actions.updateSavingsGoal(pending));
    _rate.dispose();
    _netWorth.dispose();
    super.dispose();
  }

  void _saveLater(SavingsGoalSettings Function(SavingsGoalSettings g) change) {
    _debounce?.cancel();
    _pending = change;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _pending = null;
      _actions.updateSavingsGoal(change);
    });
  }

  Future<void> _editAccountGoal(Account a) async {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final controller = TextEditingController(text: a.savingsGoal == null ? '' : fmt.plain(a.savingsGoal!));
    final result = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(a.name),
        content: NumberField(controller: controller, label: l.accountGoal, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, parseAmount(controller.text) ?? 0), child: Text(l.save)),
        ],
      ),
    );
    if (result != null) {
      ref.read(actionsProvider).saveAccount(a.copyWith(savingsGoal: () => result <= 0 ? null : result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final goal = data.savingsGoal;
    final actions = ref.read(actionsProvider);
    final accounts = data.activeAccounts;

    Widget mode(SavingsGoalMode m, IconData icon, String title, String subtitle) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            color: goal.mode == m ? context.colors.primaryContainer : null,
            padding: const EdgeInsets.all(16),
            onTap: () => actions.updateSavingsGoal((g) => g.copyWith(mode: m)),
            child: Row(
              children: [
                IconBadge(icon: icon, color: context.colors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      Text(subtitle, style: context.text.bodySmall),
                    ],
                  ),
                ),
                if (goal.mode == m) Icon(Icons.check_circle_rounded, color: context.colors.primary),
              ],
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.cardSavingsGoal)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          mode(SavingsGoalMode.savingsRate, Icons.percent_rounded, l.goalModeRate, l.goalModeRateHint),
          mode(SavingsGoalMode.perAccount, Icons.account_balance_rounded, l.goalModeAccount, l.goalModeAccountHint),
          mode(SavingsGoalMode.netWorth, Icons.emoji_events_rounded, l.goalModeNetWorth, l.goalModeNetWorthHint),
          const SizedBox(height: 10),
          switch (goal.mode) {
            SavingsGoalMode.savingsRate => AppCard(
                child: NumberField(
                  controller: _rate,
                  label: l.goalTargetRate,
                  suffix: '%',
                  onChanged: (v) => _saveLater((g) => g.copyWith(targetRate: (v ?? 0) / 100)),
                ),
              ),
            SavingsGoalMode.netWorth => AppCard(
                child: NumberField(
                  controller: _netWorth,
                  label: l.goalTargetNetWorth,
                  onChanged: (v) => _saveLater((g) => g.copyWith(netWorthTarget: v ?? 0)),
                ),
              ),
            SavingsGoalMode.perAccount => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!accounts.any((a) => (a.savingsGoal ?? 0) > 0)) ...[
                    InfoNote(l.goalNoAccountGoals),
                    const SizedBox(height: 10),
                  ],
                  ListCard(
                    children: [
                      for (final a in accounts)
                        ListTile(
                          leading: IconBadge(icon: accountIcon(a.icon), color: context.fin.chartColor(a.colorIndex)),
                          title: Text(a.name),
                          subtitle: Text(a.savingsGoal == null ? l.notSet : fmt.money(a.savingsGoal!)),
                          trailing: IconButton(
                            tooltip: l.goalPinnedAccount,
                            icon: Icon(
                              goal.pinnedAccountId == a.id ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                              color: goal.pinnedAccountId == a.id ? context.colors.primary : context.fin.muted,
                            ),
                            onPressed: (a.savingsGoal ?? 0) > 0
                                ? () => actions.updateSavingsGoal((g) => g.copyWith(pinnedAccountId: () => a.id))
                                : null,
                          ),
                          onTap: () => _editAccountGoal(a),
                        ),
                    ],
                  ),
                ],
              ),
          },
        ],
      ),
    );
  }
}

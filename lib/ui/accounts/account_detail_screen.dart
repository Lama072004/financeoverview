import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/chart_range.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../entry/snapshot_editor.dart';
import '../history/net_worth_history_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';
import '../widgets/range_selector.dart';
import 'account_edit_screen.dart';

enum _Menu { edit, archive, delete }

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final account = data.accountById(accountId);
    if (account == null) return const Scaffold();
    final item = ref.watch(overviewProvider).accounts.firstWhere((a) => a.account.id == accountId);
    final rows = ref.watch(balanceHistoryProvider);
    final debt = item.behavior == AccountBehavior.debt;
    final sign = debt ? -1.0 : 1.0;
    final color = context.fin.chartColor(account.colorIndex);
    final range = ref.watch(chartRangeProvider);
    final rangePoints = rangeSeries(rows, range, ref.watch(todayProvider), (r) => sign * r.balanceOf(accountId));
    // Change of the balance (for debts: of the amount owed).
    final rangeChange = seriesChange([for (final p in rangePoints) (p.$1, sign * p.$2)]);

    Future<void> onMenu(_Menu m) async {
      final actions = ref.read(actionsProvider);
      switch (m) {
        case _Menu.edit:
          await push(context, AccountEditScreen(account: account));
        case _Menu.archive:
          if (!account.archived) {
            final ok = await confirmDialog(
              context,
              title: l.archiveAccount,
              body: l.archiveHint,
              confirmLabel: l.archiveAccount,
              destructive: false,
            );
            if (!ok) return;
          }
          actions.saveAccount(account.copyWith(archived: !account.archived));
        case _Menu.delete:
          final ok = await confirmDialog(context, title: l.deleteConfirmTitle, body: l.deleteAccountBody);
          if (ok && context.mounted) {
            Navigator.pop(context);
            actions.deleteAccount(account.id);
          }
      }
    }

    final history = [
      for (final r in rows.reversed)
        (
          row: r,
          entered: r.snapshot.values.containsKey(accountId),
          value: r.balanceOf(accountId),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          PopupMenuButton<_Menu>(
            onSelected: onMenu,
            itemBuilder: (_) => [
              PopupMenuItem(value: _Menu.edit, child: Text(l.edit)),
              PopupMenuItem(value: _Menu.archive, child: Text(account.archived ? l.unarchiveAccount : l.archiveAccount)),
              PopupMenuItem(value: _Menu.delete, child: Text(l.delete, style: TextStyle(color: context.fin.negative))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBadge(icon: accountIcon(account.icon), color: color, size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.typeOf(account)?.name ?? '', style: context.text.labelMedium),
                          if (item.share != null)
                            Text('${l.share} ${fmt.percent(item.share!)}', style: context.text.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Amount(fmt.money(sign * item.balance), style: context.text.displaySmall),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    DeltaChip(
                      text: fmt.signedMoney(item.deltaSincePrevious),
                      value: item.deltaSincePrevious,
                      invert: debt,
                      label: l.sinceLastEntry,
                    ),
                    DeltaChip(
                      text: fmt.signedMoney(item.deltaSinceYearStart),
                      value: item.deltaSinceYearStart,
                      invert: debt,
                      label: l.sinceYearStart,
                    ),
                  ],
                ),
                if ((account.savingsGoal ?? 0) > 0) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: Text(l.accountGoal, style: context.text.titleSmall)),
                      Text(
                        l.goalOf(fmt.moneyRound(item.balance), fmt.moneyRound(account.savingsGoal!)),
                        style: money(context.text.labelMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProgressBar(value: item.balance / account.savingsGoal!),
                ],
                if (account.note.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(account.note, style: context.text.bodySmall),
                ],
              ],
            ),
          ),
          if (rows.length >= 2) ...[
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.fromLTRB(12, 18, 20, 14),
              onTap: () => push(context, NetWorthHistoryScreen(initialAccountId: accountId)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        DeltaChip(
                          text: rangeChange.relative == null
                              ? fmt.signedMoney(rangeChange.absolute)
                              : '${fmt.signedMoney(rangeChange.absolute)} · ${fmt.percent(rangeChange.relative!.abs())}',
                          value: rangeChange.absolute,
                          invert: debt,
                          label: l.inRange,
                        ),
                        const Spacer(),
                        Icon(Icons.open_in_full_rounded, size: 18, color: context.fin.muted, semanticLabel: l.openHistory),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TimeLineChart(
                    height: 200,
                    series: [ChartSeries(label: account.name, color: color, fill: true, points: rangePoints)],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: RangeSelector(value: range, onChanged: ref.read(chartRangeProvider.notifier).select),
                  ),
                ],
              ),
            ),
          ],
          if (history.isNotEmpty) ...[
            SectionTitle(l.navHistory),
            ListCard(
              children: [
                for (final h in history)
                  ListTile(
                    onTap: () => push(context, SnapshotEditor(snapshot: h.row.snapshot)),
                    title: Text(fmt.date(h.row.date)),
                    subtitle: h.entered ? null : Text(l.carriedOver),
                    trailing: Amount(
                      fmt.money(sign * h.value),
                      style: context.text.titleSmall?.copyWith(color: h.entered ? null : context.fin.muted),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

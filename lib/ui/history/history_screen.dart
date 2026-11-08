import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../dashboard/dashboard_cards.dart';
import '../entry/snapshot_editor.dart';
import '../entry/transaction_editor.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _bookings = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Text(l.navHistory, style: context.text.headlineSmall),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text(l.historyBalances)),
                  ButtonSegment(value: true, label: Text(l.historyBookings)),
                ],
                selected: {_bookings},
                onSelectionChanged: (s) => setState(() => _bookings = s.first),
              ),
            ),
          ),
          Expanded(child: _bookings ? const _BookingList() : const _SnapshotList()),
        ],
      ),
    );
  }
}

class _SnapshotList extends ConsumerWidget {
  const _SnapshotList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final rows = ref.watch(balanceHistoryProvider);
    final estimates = ref.watch(periodEstimatesProvider);
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(child: EmptyState(icon: Icons.history_rounded, title: l.noSnapshots, body: l.emptyFirstEntryBody)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final index = rows.length - 1 - i;
        final r = rows[index];
        final p = estimates[index];
        return AppCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              title: Text(fmt.date(r.date), style: context.text.titleSmall),
              subtitle: r.snapshot.note.isEmpty ? null : Text(r.snapshot.note, style: context.text.bodySmall),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Amount(fmt.money(r.total), style: context.text.titleSmall),
                  if (p != null)
                    Amount(
                      fmt.signedMoney(p.deltaTotal),
                      value: p.deltaTotal,
                      colored: true,
                      style: context.text.bodySmall,
                    ),
                ],
              ),
              children: [
                for (final a in data.accounts)
                  if (r.snapshot.values.containsKey(a.id) || r.balanceOf(a.id) != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(child: Text(a.name, style: context.text.bodyMedium)),
                          if (!r.snapshot.values.containsKey(a.id))
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(l.carriedOver, style: context.text.bodySmall),
                            ),
                          Amount(
                            fmt.money(data.behaviorOf(a) == AccountBehavior.debt ? -r.balanceOf(a.id) : r.balanceOf(a.id)),
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: r.snapshot.values.containsKey(a.id) ? null : context.fin.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                if (p != null) ...[
                  const Divider(height: 20),
                  KeyValueRow(label: l.periodDays, value: l.daysCount(p.days)),
                  KeyValueRow(label: l.periodVariable, value: fmt.money(p.variableExpenses)),
                  KeyValueRow(
                    label: l.periodReturn,
                    value: fmt.signedMoney(p.investmentReturn),
                    amount: p.investmentReturn,
                    colored: true,
                  ),
                ],
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => push(context, SnapshotEditor(snapshot: r.snapshot)),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: Text(l.edit),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingList extends ConsumerWidget {
  const _BookingList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final list = [...data.transactions]..sort((a, b) {
        final d = b.date.compareTo(a.date);
        return d != 0 ? d : b.createdAt.compareTo(a.createdAt);
      });
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          child: EmptyState(icon: Icons.receipt_long_rounded, title: l.noTransactions, body: l.transactionHint),
        ),
      );
    }

    // Group by month.
    final groups = <DateTime, List<TransactionEntry>>{};
    for (final t in list) {
      groups.putIfAbsent(DateTime(t.date.year, t.date.month), () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        for (final entry in groups.entries) ...[
          SectionTitle(
            fmt.month(entry.key),
            trailing: Text(
              [
                l.monthOut(fmt.moneyRound(entry.value.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount))),
                if (entry.value.any((t) => t.isIncome))
                  l.monthIn(fmt.moneyRound(entry.value.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount))),
              ].join(' · '),
              style: context.text.labelMedium,
            ),
          ),
          ListCard(
            children: [
              for (final t in entry.value)
                Builder(builder: (context) {
                  final s = spendingStyle(context, data, t.categoryId);
                  final account = data.accountById(t.accountId);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () => push(context, TransactionEditor(transaction: t)),
                    leading: IconBadge(icon: s.icon, color: s.color),
                    title: Text(t.note.isNotEmpty ? t.note : s.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [fmt.dayMonth(t.date), if (t.note.isNotEmpty) s.label, ?account?.name].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Amount(
                      fmt.signedMoney(t.isIncome ? t.amount : -t.amount),
                      value: t.isIncome ? t.amount : -t.amount,
                      colored: true,
                      style: context.text.titleSmall,
                    ),
                  );
                }),
            ],
          ),
        ],
      ],
    );
  }
}

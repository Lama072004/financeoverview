import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/overview_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../more/account_types_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'account_detail_screen.dart';
import 'account_edit_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final groups = ref.watch(accountsByTypeProvider);
    final overview = ref.watch(overviewProvider);
    final archived = overview.accounts.where((a) => a.account.archived).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Text(l.navAccounts, style: context.text.headlineSmall),
        actions: [
          IconButton(
            tooltip: l.manageTypes,
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => push(context, const AccountTypesScreen()),
          ),
          IconButton(
            tooltip: l.addAccount,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => push(context, const AccountEditScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          if (groups.isEmpty)
            AppCard(
              child: EmptyState(
                icon: Icons.account_balance_rounded,
                title: l.noAccounts,
                body: l.emptyWelcomeBody,
                action: FilledButton.icon(
                  onPressed: () => push(context, const AccountEditScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.addAccount),
                ),
              ),
            )
          else
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _Total(label: l.liquid, value: fmt.money(overview.liquid), color: context.fin.liquidLine),
                  ),
                  Expanded(
                    child: _Total(label: l.invested, value: fmt.money(overview.invested), color: context.fin.investedLine),
                  ),
                  if (overview.debt > 0)
                    Expanded(
                      child: _Total(label: l.debts, value: fmt.money(-overview.debt), color: context.fin.debtLine),
                    ),
                ],
              ),
            ),
          for (final (type, members) in groups) ...[
            SectionTitle(
              type?.name ?? '—',
              trailing: Amount(
                fmt.money(members.fold<double>(
                  0,
                  (s, a) => s + (a.behavior == AccountBehavior.debt ? -a.balance : a.balance),
                )),
                style: context.text.titleSmall?.copyWith(color: context.fin.muted),
              ),
            ),
            ListCard(children: [for (final a in members) AccountTile(item: a)]),
          ],
          if (archived.isNotEmpty) ...[
            SectionTitle(l.archivedSection),
            ListCard(children: [for (final a in archived) AccountTile(item: a)]),
          ],
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LegendDot(color: color, label: label),
          const SizedBox(height: 6),
          FittedBox(child: Amount(value, style: context.text.titleMedium)),
        ],
      );
}

class AccountTile extends ConsumerWidget {
  const AccountTile({super.key, required this.item});

  final AccountOverview item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final a = item.account;
    final debt = item.behavior == AccountBehavior.debt;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => push(context, AccountDetailScreen(accountId: a.id)),
      leading: IconBadge(icon: accountIcon(a.icon), color: context.fin.chartColor(a.colorIndex)),
      title: Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.share == null ? l.behaviorDebt : '${l.share} ${fmt.percent(item.share!)}',
        style: context.text.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Amount(fmt.money(debt ? -item.balance : item.balance), style: context.text.titleSmall),
          Amount(
            fmt.signedMoney(item.deltaSincePrevious),
            value: item.deltaSincePrevious,
            colored: true,
            invert: debt,
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

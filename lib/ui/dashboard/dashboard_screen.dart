import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/backup_reminder.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../accounts/account_edit_screen.dart';
import '../entry/snapshot_editor.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'backup_banner.dart';
import 'customize_screen.dart';
import 'dashboard_cards.dart';

/// Cards that only make sense once balances were entered.
const _needsEntries = {
  DashboardCardType.netWorth,
  DashboardCardType.netWorthChart,
  DashboardCardType.lastPeriod,
};

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final overview = ref.watch(overviewProvider);
    final cards = data.dashboard.where((c) => c.visible).toList();
    final noAccounts = data.accounts.isEmpty;
    final reminder = ref.watch(backupReminderProvider);

    final children = <Widget>[
      if (reminder != BackupReminder.none) BackupBanner(reminder: reminder),
      if (noAccounts)
        AppCard(
          child: EmptyState(
            icon: Icons.account_balance_rounded,
            title: l.emptyWelcomeTitle,
            body: l.emptyWelcomeBody,
            action: FilledButton.icon(
              onPressed: () => push(context, const AccountEditScreen()),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.emptyAddAccount),
            ),
          ),
        )
      else if (!overview.hasData)
        AppCard(
          child: EmptyState(
            icon: Icons.edit_note_rounded,
            title: l.emptyFirstEntryTitle,
            body: l.emptyFirstEntryBody,
            action: FilledButton.icon(
              onPressed: () => push(context, const SnapshotEditor()),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.emptyFirstEntryButton),
            ),
          ),
        ),
      if (!noAccounts)
        for (final c in cards)
          if (overview.hasData || !_needsEntries.contains(c.type)) buildDashboardCard(c),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            toolbarHeight: 72,
            titleSpacing: 20,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.dashboardTitle, style: context.text.headlineSmall),
                if (overview.latest != null)
                  Text(l.asOf(fmt.date(overview.latest!.date)), style: context.text.bodySmall),
              ],
            ),
            actions: [
              IconButton(
                tooltip: fmt.hidden ? l.discreetOff : l.discreetOn,
                icon: Icon(fmt.hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                onPressed: () =>
                    ref.read(sessionProvider.notifier).updatePrefs((p) => p.copyWith(discreet: !p.discreet)),
              ),
              IconButton(
                tooltip: l.customizeDashboard,
                icon: const Icon(Icons.dashboard_customize_rounded),
                onPressed: () => push(context, const CustomizeDashboardScreen()),
              ),
              IconButton(
                tooltip: l.lockNow,
                icon: const Icon(Icons.lock_outline_rounded),
                onPressed: () => ref.read(sessionProvider.notifier).lock(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            sliver: SliverList.separated(
              itemCount: children.length,
              itemBuilder: (_, i) => children[i],
              separatorBuilder: (_, _) => const SizedBox(height: 14),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../entry/snapshot_editor.dart';
import '../entry/transaction_editor.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

Future<void> showQuickAdd(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final page = await showModalBottomSheet<Widget>(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text(l.quickAddTitle, style: context.text.titleLarge),
            ),
            _QuickTile(
              icon: Icons.account_balance_wallet_rounded,
              color: context.colors.primary,
              title: l.quickAddBalance,
              subtitle: l.quickAddBalanceHint,
              onTap: () => Navigator.pop(context, const SnapshotEditor()),
            ),
            const SizedBox(height: 10),
            _QuickTile(
              icon: Icons.remove_circle_outline_rounded,
              color: context.fin.negative,
              title: l.quickAddExpense,
              subtitle: l.quickAddExpenseHint,
              onTap: () => Navigator.pop(context, const TransactionEditor(isIncome: false)),
            ),
            const SizedBox(height: 10),
            _QuickTile(
              icon: Icons.add_circle_outline_rounded,
              color: context.fin.positive,
              title: l.quickAddIncome,
              subtitle: l.quickAddIncomeHint,
              onTap: () => Navigator.pop(context, const TransactionEditor(isIncome: true)),
            ),
          ],
        ),
      ),
    ),
  );
  if (page != null && context.mounted) await push(context, page);
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: context.colors.surfaceContainerHigh,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, size: 44),
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
          Icon(Icons.chevron_right_rounded, color: context.fin.muted),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/backup_reminder.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/session.dart';
import '../more/backup_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Dashboard hint when the last backup is too old (see [backupReminder]).
class BackupBanner extends ConsumerWidget {
  const BackupBanner({super.key, required this.reminder});

  final BackupReminder reminder;

  static const snooze = Duration(days: 7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final now = ref.read(clockProvider)();
    final (title, body) = switch (reminder) {
      BackupReminder.autoFailed => (l.bannerBackupFailedTitle, l.bannerBackupFailedBody),
      BackupReminder.never => (l.bannerBackupNeverTitle, l.bannerBackupNeverBody),
      _ => (
          l.bannerBackupOutdatedTitle(now.difference(prefs.lastBackupAt ?? now).inDays),
          l.bannerBackupOutdatedBody,
        ),
    };
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon: Icons.shield_moon_rounded, color: context.fin.accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      const SizedBox(height: 2),
                      Text(body, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => ref
                    .read(sessionProvider.notifier)
                    .updatePrefs((p) => p.copyWith(backupReminderSnoozedUntil: () => now.add(snooze))),
                child: Text(l.later),
              ),
              TextButton(
                onPressed: () => push(context, const BackupScreen()),
                child: Text(reminder == BackupReminder.autoFailed ? l.bannerBackupCheck : l.bannerBackupNow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

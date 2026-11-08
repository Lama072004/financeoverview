import '../data/models.dart';
import '../data/prefs.dart';

enum BackupReminder {
  /// Nothing to show.
  none,

  /// No backup was made on this device yet.
  never,

  /// The last backup is older than the chosen number of days.
  outdated,

  /// The automatic backup could not be written.
  autoFailed,
}

/// Whether the dashboard should remind to make a backup.
///
/// A working automatic backup is always as new as the data, so it never
/// needs a reminder. Without any entries there is nothing worth saving yet.
BackupReminder backupReminder({required AppPrefs prefs, required AppData data, required DateTime now}) {
  final snoozed = prefs.backupReminderSnoozedUntil;
  if (snoozed != null && now.isBefore(snoozed)) return BackupReminder.none;
  final auto = prefs.autoBackup.enabled && data.autoBackupPassword != null;
  if (auto && prefs.autoBackup.failed) return BackupReminder.autoFailed;
  if (auto || prefs.backupReminderDays == 0) return BackupReminder.none;

  final created = [
    for (final s in data.snapshots) s.createdAt,
    for (final t in data.transactions) t.createdAt,
  ];
  if (created.isEmpty) return BackupReminder.none;
  final reference = prefs.lastBackupAt ?? created.reduce((a, b) => a.isBefore(b) ? a : b);
  if (now.difference(reference).inDays < prefs.backupReminderDays) return BackupReminder.none;
  return prefs.lastBackupAt == null ? BackupReminder.never : BackupReminder.outdated;
}

/// Name of the automatic backup of [day] – one file per day, a later backup
/// on the same day replaces it.
String autoBackupFileName(DateTime day) =>
    'finanzuebersicht-auto-${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}.backup';

final _autoName = RegExp(r'^finanzuebersicht-auto-\d{4}-\d{2}-\d{2}\.backup$');

/// Automatic backups in [names] beyond the newest [keep] – manual backups and
/// other files in the folder are never touched.
List<String> outdatedAutoBackups(Iterable<String> names, {int keep = AutoBackupPrefs.keep}) {
  final auto = names.where(_autoName.hasMatch).toList()..sort();
  return auto.length <= keep ? const [] : auto.sublist(0, auto.length - keep);
}

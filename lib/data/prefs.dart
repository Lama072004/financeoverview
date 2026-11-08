/// Preferences that must be readable before the vault is unlocked (theme and
/// language of the lock screen, lock behaviour) or that belong to this device
/// only (reminders, backup folder). They contain no financial data and are
/// stored in the unencrypted vault header.
library;

enum ThemePref { system, light, dark }

/// Dark mode flavour: pure black saves power on OLED screens.
enum DarkVariant { black, dim }

enum LocalePref { system, de, en }

enum CredentialType { pin, password }

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Local notification reminding to enter the balances.
class ReminderPrefs {
  const ReminderPrefs({this.enabled = false, this.days = const [1, 15], this.hour = 19, this.minute = 0});

  /// Days of the month that can be picked (29–31 do not exist every month).
  static const maxDay = 28;

  final bool enabled;

  /// Days of the month, sorted, 1..[maxDay].
  final List<int> days;
  final int hour;
  final int minute;

  ReminderPrefs copyWith({bool? enabled, List<int>? days, int? hour, int? minute}) => ReminderPrefs(
        enabled: enabled ?? this.enabled,
        days: days ?? this.days,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  Map<String, Object?> toJson() => {'enabled': enabled, 'days': days, 'hour': hour, 'minute': minute};

  factory ReminderPrefs.fromJson(Map<String, Object?> j) {
    final days = (j['days'] is List ? (j['days'] as List).whereType<num>().map((e) => e.toInt()) : const <int>[])
        .where((d) => d >= 1 && d <= maxDay)
        .toSet()
        .toList()
      ..sort();
    return ReminderPrefs(
      enabled: j['enabled'] == true,
      days: days.isEmpty ? const [1, 15] : days,
      hour: ((j['hour'] as num?)?.toInt() ?? 19).clamp(0, 23),
      minute: ((j['minute'] as num?)?.toInt() ?? 0).clamp(0, 59),
    );
  }
}

/// Folder for automatic backups. The password lives in the encrypted data
/// ([AppData.autoBackupPassword]), only the folder is stored here.
class AutoBackupPrefs {
  const AutoBackupPrefs({this.folderUri, this.folderName, this.lastRunAt, this.failed = false});

  /// Number of automatic backups kept in the folder.
  static const keep = 10;

  /// Android document tree URI; null = automatic backup is off.
  final String? folderUri;
  final String? folderName;
  final DateTime? lastRunAt;

  /// The last attempt failed (folder deleted, access revoked …).
  final bool failed;

  bool get enabled => folderUri != null;

  Map<String, Object?> toJson() => {
        'folderUri': folderUri,
        'folderName': folderName,
        'lastRunAt': lastRunAt?.toIso8601String(),
        'failed': failed,
      };

  factory AutoBackupPrefs.fromJson(Map<String, Object?> j) => AutoBackupPrefs(
        folderUri: j['folderUri'] is String ? j['folderUri'] as String : null,
        folderName: j['folderName'] is String ? j['folderName'] as String : null,
        lastRunAt: _date(j['lastRunAt']),
        failed: j['failed'] == true,
      );
}

class AppPrefs {
  const AppPrefs({
    this.theme = ThemePref.system,
    this.darkVariant = DarkVariant.black,
    this.locale = LocalePref.system,
    this.lockTimeoutSeconds = 0,
    this.biometricsEnabled = false,
    this.discreet = false,
    this.reminder = const ReminderPrefs(),
    this.backupReminderDays = 30,
    this.lastBackupAt,
    this.backupReminderSnoozedUntil,
    this.autoBackup = const AutoBackupPrefs(),
  });

  static const lockTimeoutOptions = [0, 30, 60, 300];

  /// 0 = no backup reminder.
  static const backupReminderOptions = [0, 14, 30, 60, 90];

  final ThemePref theme;
  final DarkVariant darkVariant;
  final LocalePref locale;

  /// 0 = lock immediately when the app is left.
  final int lockTimeoutSeconds;
  final bool biometricsEnabled;

  /// Hides all amounts ("•••• €").
  final bool discreet;
  final ReminderPrefs reminder;

  /// Remind to back up when the last backup is older than this; 0 = never.
  final int backupReminderDays;

  /// Last backup made on this device (manual or automatic).
  final DateTime? lastBackupAt;
  final DateTime? backupReminderSnoozedUntil;
  final AutoBackupPrefs autoBackup;

  AppPrefs copyWith({
    ThemePref? theme,
    DarkVariant? darkVariant,
    LocalePref? locale,
    int? lockTimeoutSeconds,
    bool? biometricsEnabled,
    bool? discreet,
    ReminderPrefs? reminder,
    int? backupReminderDays,
    DateTime? lastBackupAt,
    DateTime? Function()? backupReminderSnoozedUntil,
    AutoBackupPrefs? autoBackup,
  }) =>
      AppPrefs(
        theme: theme ?? this.theme,
        darkVariant: darkVariant ?? this.darkVariant,
        locale: locale ?? this.locale,
        lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
        biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
        discreet: discreet ?? this.discreet,
        reminder: reminder ?? this.reminder,
        backupReminderDays: backupReminderDays ?? this.backupReminderDays,
        lastBackupAt: lastBackupAt ?? this.lastBackupAt,
        backupReminderSnoozedUntil:
            backupReminderSnoozedUntil != null ? backupReminderSnoozedUntil() : this.backupReminderSnoozedUntil,
        autoBackup: autoBackup ?? this.autoBackup,
      );

  Map<String, Object?> toJson() => {
        'theme': theme.name,
        'darkVariant': darkVariant.name,
        'locale': locale.name,
        'lockTimeoutSeconds': lockTimeoutSeconds,
        'biometricsEnabled': biometricsEnabled,
        'discreet': discreet,
        'reminder': reminder.toJson(),
        'backupReminderDays': backupReminderDays,
        'lastBackupAt': lastBackupAt?.toIso8601String(),
        'backupReminderSnoozedUntil': backupReminderSnoozedUntil?.toIso8601String(),
        'autoBackup': autoBackup.toJson(),
      };

  factory AppPrefs.fromJson(Map<String, Object?> j) => AppPrefs(
        theme: ThemePref.values.firstWhere((e) => e.name == j['theme'], orElse: () => ThemePref.system),
        darkVariant: DarkVariant.values
            .firstWhere((e) => e.name == j['darkVariant'], orElse: () => DarkVariant.black),
        locale: LocalePref.values.firstWhere((e) => e.name == j['locale'], orElse: () => LocalePref.system),
        lockTimeoutSeconds: (j['lockTimeoutSeconds'] as num?)?.toInt() ?? 0,
        biometricsEnabled: j['biometricsEnabled'] == true,
        discreet: j['discreet'] == true,
        reminder: j['reminder'] is Map ? ReminderPrefs.fromJson((j['reminder'] as Map).cast()) : const ReminderPrefs(),
        backupReminderDays: (j['backupReminderDays'] as num?)?.toInt() ?? 30,
        lastBackupAt: _date(j['lastBackupAt']),
        backupReminderSnoozedUntil: _date(j['backupReminderSnoozedUntil']),
        autoBackup:
            j['autoBackup'] is Map ? AutoBackupPrefs.fromJson((j['autoBackup'] as Map).cast()) : const AutoBackupPrefs(),
      );
}

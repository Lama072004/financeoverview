import 'dart:typed_data';

import 'package:financeoverview/core/format.dart';
import 'package:financeoverview/data/folder_access.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/data/reminder_service.dart';
import 'package:financeoverview/data/vault/backup_service.dart';
import 'package:financeoverview/data/vault/vault_crypto.dart';
import 'package:financeoverview/domain/backup_reminder.dart';
import 'package:financeoverview/state/auto_backup.dart';
import 'package:financeoverview/state/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../support/demo_data.dart';
import '../support/harness.dart';

/// Folder in memory instead of the Android document tree.
class FakeFolder extends FolderAccess {
  final files = <String, Uint8List>{};
  bool broken = false;

  @override
  Future<void> write(String uri, String name, Uint8List bytes) async {
    if (broken) throw Exception('access revoked');
    files[name] = bytes;
  }

  @override
  Future<List<String>> list(String uri) async => files.keys.toList();

  @override
  Future<void> delete(String uri, String name) async => files.remove(name);
}

void main() {
  const fast = BackupService(crypto: VaultCrypto(iterations: 1000));
  const folderUri = 'content://folder';

  ({ProviderContainer container, FakeFolder folder, DateTime Function() clock, void Function(DateTime) setNow})
      setUpBackup({AppData? data}) {
    var now = DateTime(2026, 10, 18, 9);
    final folder = FakeFolder();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(
          () => FakeSession(unlocked(
            (data ?? demoData()).copyWith(autoBackupPassword: () => 'auto-pass-1'),
            prefs: const AppPrefs(autoBackup: AutoBackupPrefs(folderUri: folderUri, folderName: 'Backups')),
          )),
        ),
        clockProvider.overrideWithValue(() => now),
        backupServiceProvider.overrideWithValue(fast),
        folderAccessProvider.overrideWithValue(folder),
      ],
    );
    addTearDown(container.dispose);
    container.listen(autoBackupProvider, (_, _) {});
    return (container: container, folder: folder, clock: () => now, setNow: (d) => now = d);
  }

  test('a change is backed up after a moment, without this device\'s password', () async {
    final t = setUpBackup();
    t.container.read(sessionProvider.notifier).updateData((d) => d.copyWith(onlinePricesEnabled: true));
    expect(t.folder.files, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    await t.container.read(sessionProvider.notifier).flush();
    while (t.container.read(autoBackupProvider)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    final name = autoBackupFileName(t.clock());
    expect(t.folder.files.keys, [name]);
    final restored = await fast.restore(t.folder.files[name]!, 'auto-pass-1');
    expect(restored.onlinePricesEnabled, isTrue);
    expect(restored.autoBackupPassword, isNull);

    final prefs = t.container.read(prefsProvider);
    expect(prefs.lastBackupAt, t.clock());
    expect(prefs.autoBackup.lastRunAt, t.clock());
    expect(prefs.autoBackup.failed, isFalse);
  });

  test('one file per day, the newest ten are kept', () async {
    final t = setUpBackup();
    final controller = t.container.read(autoBackupProvider.notifier);
    for (var day = 1; day <= 12; day++) {
      t.setNow(DateTime(2026, 10, day, 20));
      expect(await controller.runNow(), isTrue);
      expect(await controller.runNow(), isTrue); // same day: replaced
    }
    expect(t.folder.files, hasLength(AutoBackupPrefs.keep));
    expect(t.folder.files.containsKey(autoBackupFileName(DateTime(2026, 10, 1))), isFalse);
    expect(t.folder.files.containsKey(autoBackupFileName(DateTime(2026, 10, 12))), isTrue);
  });

  test('a failure is remembered and shown, the next success clears it', () async {
    final t = setUpBackup();
    final controller = t.container.read(autoBackupProvider.notifier);
    t.folder.broken = true;
    expect(await controller.runNow(), isFalse);
    expect(t.container.read(prefsProvider).autoBackup.failed, isTrue);
    expect(t.container.read(prefsProvider).lastBackupAt, isNull);

    t.folder.broken = false;
    expect(await controller.runNow(), isTrue);
    expect(t.container.read(prefsProvider).autoBackup.failed, isFalse);
  });

  test('without a folder nothing happens', () async {
    final folder = FakeFolder();
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => FakeSession(unlocked(demoData()))),
        backupServiceProvider.overrideWithValue(fast),
        folderAccessProvider.overrideWithValue(folder),
      ],
    );
    addTearDown(container.dispose);
    container.listen(autoBackupProvider, (_, _) {});
    container.read(sessionProvider.notifier).updateData((d) => d.copyWith(onlinePricesEnabled: true));
    expect(await container.read(autoBackupProvider.notifier).runNow(), isFalse);
    expect(folder.files, isEmpty);
  });

  group('settings', () {
    test('device prefs survive a round trip', () {
      final prefs = AppPrefs(
        discreet: true,
        reminder: const ReminderPrefs(enabled: true, days: [3, 17], hour: 8, minute: 45),
        backupReminderDays: 60,
        lastBackupAt: DateTime(2026, 10, 1, 12),
        backupReminderSnoozedUntil: DateTime(2026, 10, 8),
        autoBackup: AutoBackupPrefs(folderUri: folderUri, folderName: 'Backups', lastRunAt: DateTime(2026, 10, 2), failed: true),
      );
      final back = AppPrefs.fromJson(prefs.toJson());
      expect(back.toJson(), prefs.toJson());
      // Old headers without the new fields get the defaults.
      final old = AppPrefs.fromJson(const {'theme': 'dark'});
      expect(old.discreet, isFalse);
      expect(old.reminder.days, [1, 15]);
      expect(old.backupReminderDays, 30);
      expect(old.autoBackup.enabled, isFalse);
    });

    test('invalid reminder days are dropped', () {
      final r = ReminderPrefs.fromJson(const {'enabled': true, 'days': [31, 0, 5, 5, 2], 'hour': 30});
      expect(r.days, [2, 5]);
      expect(r.hour, 23);
    });

    test('projection settings are stored, the backup password never leaves the vault', () async {
      final data = demoData().copyWith(
        projection: const ProjectionSettings(annualReturn: 0.04, monthlySaving: 700, years: 20),
        autoBackupPassword: () => 'auto-pass-1',
      );
      final back = AppData.fromJson(data.toJson());
      expect(back.projection.annualReturn, 0.04);
      expect(back.projection.monthlySaving, 700);
      expect(back.projection.monthlyInvested, isNull);
      expect(back.projection.years, 20);
      expect(back.autoBackupPassword, 'auto-pass-1');

      final file = await fast.create(data, 'manual-pass');
      expect((await fast.restore(file, 'manual-pass')).autoBackupPassword, isNull);
    });
  });

  group('discreet mode', () {
    setUpAll(initializeDateFormatting);

    test('hides amounts but not percentages or dates', () {
      final open = Fmt('de');
      final hidden = Fmt('de', hidden: true);
      // NumberFormat puts a no-break space before the euro sign.
      String plain(String s) => s.replaceAll('\u00a0', ' ');
      expect(plain(open.money(1234.5)), '1.234,50 €');
      expect(plain(hidden.money(1234.5)), '•••• €');
      expect(plain(hidden.signedMoney(-20)), '•••• €');
      expect(plain(hidden.moneyRound(99)), '•••• €');
      expect(hidden.compact(12000), '••');
      expect(hidden.axis(500, fine: true), '••');
      expect(hidden.percent(0.25), open.percent(0.25));
      expect(hidden.date(DateTime(2026, 10, 18)), open.date(DateTime(2026, 10, 18)));
      expect(plain(Fmt('en', hidden: true).money(5)), '€••••');
    });
  });

  group('reminder', () {
    setUpAll(tzdata.initializeTimeZones);

    test('next occurrence of a day of the month', () {
      final vienna = tz.getLocation('Europe/Vienna');
      final now = tz.TZDateTime(vienna, 2026, 10, 20, 20);
      DateTime next(int day, int hour) => LocalReminderService.nextOccurrence(now, day, hour, 0);
      expect(next(15, 19), tz.TZDateTime(vienna, 2026, 11, 15, 19));
      expect(next(20, 19), tz.TZDateTime(vienna, 2026, 11, 20, 19));
      expect(next(20, 21), tz.TZDateTime(vienna, 2026, 10, 20, 21));
      final december = tz.TZDateTime(vienna, 2026, 12, 20, 8);
      expect(LocalReminderService.nextOccurrence(december, 1, 19, 0), tz.TZDateTime(vienna, 2027, 1, 1, 19));
    });
  });
}

// Screens added in 1.1: review, forecast, PDF report, automatic backup,
// reminders, discreet mode. Update with:
// flutter test test/screenshots --update-goldens
@Tags(['screenshots'])
library;

import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/ui/more/backup_screen.dart';
import 'package:financeoverview/ui/more/settings_screen.dart';
import 'package:financeoverview/ui/projection/projection_screen.dart';
import 'package:financeoverview/ui/report/report_screen.dart';
import 'package:financeoverview/ui/review/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/demo_data.dart';
import '../support/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  final data = demoData();
  final long = longDemoData();
  final de = AppPrefs(locale: LocalePref.de, lastBackupAt: testToday);
  final black = de.copyWith(theme: ThemePref.dark);
  const folder = AutoBackupPrefs(folderUri: 'content://demo/tree/Backups', folderName: 'Finanzen-Backups');

  Future<void> shot(WidgetTester tester, String name, Widget app, {double height = 844}) async {
    await setPhoneSize(tester, height: height);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('dashboard with backup reminder', (t) async {
    await shot(t, 'dashboard_backup_banner', testApp(session: unlocked(data, prefs: const AppPrefs(locale: LocalePref.de))));
  });

  testWidgets('dashboard discreet', (t) async {
    await shot(t, 'dashboard_discreet_full', testApp(session: unlocked(data, prefs: de.copyWith(discreet: true))), height: 2900);
  });

  testWidgets('dashboard goal forecast', (t) async {
    await shot(t, 'dashboard_goal_forecast', testApp(session: unlocked(long, prefs: de)), height: 1500);
  });

  testWidgets('review month', (t) async {
    await shot(t, 'review_month', testApp(session: unlocked(long, prefs: de), home: const ReviewScreen()), height: 1900);
  });

  testWidgets('review year', (t) async {
    await shot(
      t,
      'review_year',
      testApp(session: unlocked(long, prefs: de), home: const ReviewScreen(initialScope: ReviewScope.year)),
      height: 2900,
    );
  });

  testWidgets('review all time dark', (t) async {
    await shot(
      t,
      'dark_review_all',
      testApp(session: unlocked(long, prefs: black), home: const ReviewScreen(initialScope: ReviewScope.all)),
      height: 2500,
    );
  });

  testWidgets('review discreet', (t) async {
    await shot(
      t,
      'review_year_discreet',
      testApp(session: unlocked(long, prefs: de.copyWith(discreet: true)), home: const ReviewScreen(initialScope: ReviewScope.year)),
      height: 1400,
    );
  });

  testWidgets('projection', (t) async {
    await shot(t, 'projection', testApp(session: unlocked(long, prefs: de), home: const ProjectionScreen()), height: 2300);
  });

  testWidgets('projection dark', (t) async {
    await shot(t, 'dark_projection', testApp(session: unlocked(data, prefs: black), home: const ProjectionScreen()), height: 2100);
  });

  testWidgets('report screen', (t) async {
    await shot(t, 'report', testApp(session: unlocked(long, prefs: de), home: const ReportScreen(year: 2026)));
  });

  testWidgets('backup with automatic backup', (t) async {
    final prefs = de.copyWith(autoBackup: AutoBackupPrefs(folderUri: folder.folderUri, folderName: folder.folderName, lastRunAt: testToday));
    await shot(
      t,
      'backup_auto',
      testApp(session: unlocked(data.copyWith(autoBackupPassword: () => 'demo-pass'), prefs: prefs), home: const BackupScreen()),
      height: 1500,
    );
  });

  testWidgets('backup automatic failed dark', (t) async {
    final prefs = black.copyWith(
      autoBackup: AutoBackupPrefs(folderUri: folder.folderUri, folderName: folder.folderName, lastRunAt: testToday, failed: true),
    );
    await shot(
      t,
      'dark_backup_auto_failed',
      testApp(session: unlocked(data.copyWith(autoBackupPassword: () => 'demo-pass'), prefs: prefs), home: const BackupScreen()),
      height: 1600,
    );
  });

  testWidgets('dashboard automatic backup failed', (t) async {
    final prefs = de.copyWith(autoBackup: AutoBackupPrefs(folderUri: folder.folderUri, folderName: folder.folderName, failed: true));
    await shot(t, 'dashboard_backup_failed', testApp(session: unlocked(data.copyWith(autoBackupPassword: () => 'demo-pass'), prefs: prefs)));
  });

  testWidgets('settings with reminder and days sheet', (t) async {
    final prefs = de.copyWith(reminder: const ReminderPrefs(enabled: true));
    await setPhoneSize(t, height: 2300);
    await t.pumpWidget(testApp(session: unlocked(data, prefs: prefs), home: const SettingsScreen()));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/settings_reminder.png'));
    await t.tap(find.text('Tage im Monat'));
    await t.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/reminder_days_sheet.png'));
    await t.pump(const Duration(seconds: 1));
  });
}

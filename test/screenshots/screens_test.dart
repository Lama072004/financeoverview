// Renders the main screens to PNG for visual review.
// Update the images with: flutter test test/screenshots --update-goldens
// (Rendering differs slightly between machines – these are review images.)
@Tags(['screenshots'])
library;

import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/state/session.dart';
import 'package:financeoverview/ui/accounts/account_detail_screen.dart';
import 'package:financeoverview/ui/dashboard/customize_screen.dart';
import 'package:financeoverview/ui/entry/snapshot_editor.dart';
import 'package:financeoverview/ui/entry/transaction_editor.dart';
import 'package:financeoverview/ui/history/net_worth_history_screen.dart';
import 'package:financeoverview/ui/lock/biometrics.dart';
import 'package:financeoverview/ui/more/backup_screen.dart';
import 'package:financeoverview/ui/more/investments_screen.dart';
import 'package:financeoverview/ui/more/purchase_screen.dart';
import 'package:financeoverview/ui/more/recurring_screen.dart';
import 'package:financeoverview/ui/more/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/demo_data.dart';
import '../support/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  final data = demoData();
  // A recent backup keeps the backup reminder out of these screenshots.
  final de = AppPrefs(locale: LocalePref.de, lastBackupAt: testToday);

  Future<void> shot(WidgetTester tester, String name, Widget app, {double height = 844}) async {
    await setPhoneSize(tester, height: height);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    // Let short-lived timers (auto-lock grace period) run out.
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('dashboard light', (t) => shot(t, 'dashboard_light', testApp(session: unlocked(data, prefs: de))));

  testWidgets('dashboard light full', (t) async {
    await shot(t, 'dashboard_light_full', testApp(session: unlocked(data, prefs: de)), height: 2900);
  });

  testWidgets('dashboard dark black full', (t) async {
    await shot(
      t,
      'dashboard_dark_black_full',
      testApp(session: unlocked(data, prefs: de.copyWith(theme: ThemePref.dark))),
      height: 2900,
    );
  });

  testWidgets('dashboard dark dim', (t) async {
    await shot(
      t,
      'dashboard_dark_dim',
      testApp(session: unlocked(data, prefs: de.copyWith(theme: ThemePref.dark, darkVariant: DarkVariant.dim))),
    );
  });

  testWidgets('dashboard large cards', (t) async {
    final large = data.copyWith(
      dashboard: [for (final c in data.dashboard) c.copyWith(size: CardSize.large)],
    );
    await shot(t, 'dashboard_large_full', testApp(session: unlocked(large, prefs: de)), height: 3800);
  });

  testWidgets('dashboard english', (t) async {
    await shot(t, 'dashboard_english', testApp(session: unlocked(data, prefs: de.copyWith(locale: LocalePref.en))));
  });

  testWidgets('dashboard empty', (t) async {
    final empty = data.copyWith(accounts: [], snapshots: [], recurring: [], transactions: []);
    await shot(t, 'dashboard_empty', testApp(session: unlocked(empty, prefs: de)));
  });

  testWidgets('accounts', (t) => shot(t, 'accounts', testApp(session: unlocked(data, prefs: de), tab: 1), height: 1100));

  testWidgets('history', (t) => shot(t, 'history', testApp(session: unlocked(data, prefs: de), tab: 2)));

  testWidgets('more', (t) => shot(t, 'more', testApp(session: unlocked(data, prefs: de), tab: 3)));

  testWidgets('snapshot editor', (t) async {
    await shot(t, 'snapshot_editor', testApp(session: unlocked(data, prefs: de), home: const SnapshotEditor()), height: 1000);
  });

  testWidgets('transaction editor', (t) async {
    await shot(t, 'transaction_editor', testApp(session: unlocked(data, prefs: de), home: const TransactionEditor()));
  });

  testWidgets('recurring', (t) async {
    await shot(t, 'recurring', testApp(session: unlocked(data, prefs: de), home: const RecurringScreen()), height: 1900);
  });

  testWidgets('investments', (t) async {
    await shot(t, 'investments', testApp(session: unlocked(data, prefs: de), home: const InvestmentsScreen()), height: 1500);
  });

  testWidgets('purchase', (t) async {
    await shot(t, 'purchase', testApp(session: unlocked(data, prefs: de), home: const PurchaseScreen()), height: 2900);
  });

  testWidgets('settings dark', (t) async {
    await shot(
      t,
      'settings_dark',
      testApp(
        session: unlocked(data, prefs: de.copyWith(theme: ThemePref.dark)),
        home: const SettingsScreen(),
        biometrics: BiometricKind.fingerprint,
      ),
      height: 1500,
    );
  });

  testWidgets('backup', (t) async {
    await shot(t, 'backup', testApp(session: unlocked(data, prefs: de), home: const BackupScreen()));
  });

  testWidgets('customize', (t) async {
    await shot(t, 'customize', testApp(session: unlocked(data, prefs: de), home: const CustomizeDashboardScreen()), height: 1100);
  });

  testWidgets('unlock', (t) async {
    await shot(
      t,
      'unlock',
      testApp(
        session: SessionState(status: SessionStatus.locked, header: fakeHeader(prefs: de.copyWith(biometricsEnabled: true))),
        biometrics: BiometricKind.fingerprint,
      ),
    );
  });

  testWidgets('setup', (t) async {
    await shot(t, 'setup', testApp(session: const SessionState(status: SessionStatus.needsSetup)));
  });

  group('history', () {
    Future<void> history(WidgetTester t, String name, {String? range, List<String> lines = const [], AppPrefs? prefs}) async {
      await setPhoneSize(t, height: 1250);
      await t.pumpWidget(testApp(session: unlocked(data, prefs: prefs ?? de), home: const NetWorthHistoryScreen()));
      await t.pumpAndSettle();
      if (range != null) await t.tap(find.text(range));
      for (final line in lines) {
        await t.ensureVisible(find.widgetWithText(FilterChip, line));
        await t.tap(find.widgetWithText(FilterChip, line));
      }
      await t.pumpAndSettle();
      await t.drag(find.byType(ListView), const Offset(0, 2000));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
    }

    testWidgets('all', (t) => history(t, 'history_all'));
    testWidgets('six months', (t) => history(t, 'history_6m', range: '6M'));
    testWidgets('month with accounts', (t) => history(t, 'history_1m_accounts', range: '1M', lines: ['Girokonto', 'ETF-Depot']));
    testWidgets('week', (t) => history(t, 'history_1w', range: '1W'));
    testWidgets('day', (t) => history(t, 'history_1t', range: '1T'));
    testWidgets('dark split', (t) => history(
          t,
          'dark_history_split',
          lines: ['Liquide', 'Investiert', 'Schulden'],
          prefs: de.copyWith(theme: ThemePref.dark),
        ));

    testWidgets('account detail', (t) async {
      await setPhoneSize(t, height: 1300);
      await t.pumpWidget(testApp(session: unlocked(data, prefs: de), home: const AccountDetailScreen(accountId: 'depot')));
      await t.pumpAndSettle();
      await t.tap(find.text('3M'));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/account_detail_3m.png'));
    });
  });

  group('dark mode', () {
    final black = de.copyWith(theme: ThemePref.dark);
    final dim = black.copyWith(darkVariant: DarkVariant.dim);

    final screens = <String, (Widget?, int, double)>{
      'accounts': (null, 1, 1100),
      'history': (null, 2, 844),
      'more': (null, 3, 1000),
      'snapshot_editor': (const SnapshotEditor(), 0, 1000),
      'transaction_editor': (const TransactionEditor(), 0, 1000),
      'recurring': (const RecurringScreen(), 0, 1900),
      'investments': (const InvestmentsScreen(), 0, 1500),
      'purchase': (const PurchaseScreen(), 0, 2900),
      'customize': (const CustomizeDashboardScreen(), 0, 1100),
    };
    for (final MapEntry(key: name, value: (home, tab, height)) in screens.entries) {
      testWidgets('$name dark', (t) async {
        await shot(t, 'dark_$name', testApp(session: unlocked(data, prefs: black), home: home, tab: tab), height: height);
      });
    }

    testWidgets('dashboard dim large full', (t) async {
      final large = data.copyWith(dashboard: [for (final c in data.dashboard) c.copyWith(size: CardSize.large)]);
      await shot(t, 'dark_dim_dashboard_large_full', testApp(session: unlocked(large, prefs: dim)), height: 3800);
    });

    testWidgets('quick add sheet dark', (t) async {
      await setPhoneSize(t);
      await t.pumpWidget(testApp(session: unlocked(data, prefs: black)));
      await t.pumpAndSettle();
      await t.tap(find.byType(FloatingActionButton));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/dark_quick_add.png'));
    });

    testWidgets('unlock and forgot dialog dark', (t) async {
      await setPhoneSize(t);
      await t.pumpWidget(testApp(
        session: SessionState(status: SessionStatus.locked, header: fakeHeader(prefs: black)),
      ));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/dark_unlock.png'));
      await t.tap(find.text('Vergessen?'));
      await t.pumpAndSettle();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/dark_forgot_dialog.png'));
      await t.pump(const Duration(seconds: 1));
    });

    testWidgets('setup dark', (t) async {
      await shot(
        t,
        'dark_setup',
        testApp(session: SessionState(status: SessionStatus.needsSetup, header: fakeHeader(prefs: black))),
      );
    });
  });
}

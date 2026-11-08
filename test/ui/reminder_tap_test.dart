import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/state/reminders.dart';
import 'package:financeoverview/state/session.dart';
import 'package:financeoverview/ui/entry/snapshot_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/demo_data.dart';
import '../support/harness.dart';

/// Tapping the reminder opens the balance entry – but only after unlocking.
void main() {
  setUpAll(loadAppFonts);
  const de = AppPrefs(locale: LocalePref.de);

  testWidgets('while the app is locked in the background', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: unlocked(demoData(), prefs: de)));
    await t.pumpAndSettle();
    final container = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
    final session = container.read(sessionProvider.notifier) as FakeSession;

    session.lock();
    await t.pumpAndSettle();
    container.read(reminderServiceProvider).captureRequested.value = true;
    await t.pumpAndSettle();
    expect(find.byType(SnapshotEditor), findsNothing);
    expect(find.text('PIN eingeben'), findsOneWidget);

    session.unlockForTest();
    await t.pumpAndSettle();
    expect(find.byType(SnapshotEditor), findsOneWidget);
    expect(container.read(reminderServiceProvider).captureRequested.value, isFalse);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('when the reminder started the app', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: SessionState(status: SessionStatus.locked, header: fakeHeader(prefs: de), data: demoData())));
    await t.pumpAndSettle();
    final container = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
    container.read(reminderServiceProvider).captureRequested.value = true;
    await t.pumpAndSettle();
    expect(find.byType(SnapshotEditor), findsNothing);

    (container.read(sessionProvider.notifier) as FakeSession).unlockForTest();
    await t.pumpAndSettle();
    expect(find.byType(SnapshotEditor), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('the eye on the dashboard hides all amounts', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: unlocked(demoData(), prefs: de)));
    await t.pumpAndSettle();
    expect(find.textContaining('••••'), findsNothing);

    await t.tap(find.byTooltip('Beträge verbergen'));
    await t.pumpAndSettle();
    expect(find.textContaining('••••'), findsWidgets);
    expect(find.textContaining(RegExp(r'\d\.\d{3},\d{2}')), findsNothing);

    await t.tap(find.byTooltip('Beträge anzeigen'));
    await t.pumpAndSettle();
    expect(find.textContaining('••••'), findsNothing);
    await t.pump(const Duration(seconds: 1));
  });
}

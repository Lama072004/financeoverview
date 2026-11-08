import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/state/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/demo_data.dart';
import '../support/harness.dart';

/// Switching to another app (e.g. the banking app) while entering balances
/// locks the app – the entry and everything typed must still be there after
/// unlocking.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('an unfinished balance entry survives locking', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: unlocked(demoData(), prefs: const AppPrefs(locale: LocalePref.de))));
    await t.pumpAndSettle();

    await t.tap(find.byType(FloatingActionButton));
    await t.pumpAndSettle();
    await t.tap(find.text('Kontostände aktualisieren'));
    await t.pumpAndSettle();
    expect(find.text('Kontostände erfassen'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).first, '1234,56');
    await t.pump();

    final container = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
    final session = container.read(sessionProvider.notifier) as FakeSession;
    session.lock();
    await t.pumpAndSettle();
    expect(find.text('PIN eingeben'), findsOneWidget);
    // Hidden under the lock screen – neither visible nor reachable.
    expect(find.text('Kontostände erfassen'), findsNothing);

    session.unlockForTest();
    await t.pumpAndSettle();
    expect(find.text('Kontostände erfassen'), findsOneWidget);
    expect(find.text('1234,56'), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('a reset drops the hidden screens', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: unlocked(demoData(), prefs: const AppPrefs(locale: LocalePref.de))));
    await t.pumpAndSettle();
    final container = ProviderScope.containerOf(t.element(find.byType(MaterialApp)));
    final session = container.read(sessionProvider.notifier) as FakeSession;
    session.lock();
    await t.pumpAndSettle();
    // The fake wipe waits a moment – let the test clock run instead of awaiting.
    session.resetAll();
    await t.pump(const Duration(milliseconds: 200));
    await t.pumpAndSettle();
    expect(find.text('Übersicht', skipOffstage: false), findsNothing);
    await t.pump(const Duration(seconds: 1));
  });
}

import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/state/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/demo_data.dart';
import '../support/harness.dart';

/// The system switching between light and dark must never break the tree –
/// on every lock-gate screen and after leaving one for another.
void main() {
  setUpAll(loadAppFonts);

  Future<void> flipBrightness(WidgetTester t) async {
    for (final b in [Brightness.dark, Brightness.light, Brightness.dark]) {
      t.platformDispatcher.platformBrightnessTestValue = b;
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    }
    t.platformDispatcher.clearPlatformBrightnessTestValue();
  }

  testWidgets('setup screen', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: const SessionState(status: SessionStatus.needsSetup)));
    await t.pumpAndSettle();
    await flipBrightness(t);
  });

  testWidgets('dashboard', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(session: unlocked(demoData())));
    await t.pumpAndSettle();
    await flipBrightness(t);
  });

  testWidgets('after resetting from the lock screen', (t) async {
    await setPhoneSize(t);
    await t.pumpWidget(testApp(
      session: SessionState(status: SessionStatus.locked, header: fakeHeader(prefs: const AppPrefs(locale: LocalePref.de))),
    ));
    await t.pumpAndSettle();
    await t.tap(find.text('Vergessen?'));
    await t.pumpAndSettle();
    await t.tap(find.text('App zurücksetzen'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'LÖSCHEN');
    await t.pump();
    await t.tap(find.widgetWithText(TextButton, 'App zurücksetzen'));
    await t.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget); // prefs are gone → system language
    expect(t.takeException(), isNull);
    await flipBrightness(t);
    await t.pump(const Duration(seconds: 1));
  });
}

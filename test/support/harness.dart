import 'dart:io';

import 'package:financeoverview/app.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/data/vault/vault_repository.dart';
import 'package:financeoverview/state/session.dart';
import 'package:financeoverview/ui/lock/biometrics.dart';
import 'package:financeoverview/ui/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Session that never touches disk or crypto.
class FakeSession extends SessionController {
  FakeSession(this.initial);

  final SessionState initial;

  @override
  SessionState build() => initial;

  @override
  void updateData(AppData Function(AppData data) change) =>
      state = state.copyWith(data: () => change(state.data ?? const AppData()));

  @override
  Future<void> updatePrefs(AppPrefs Function(AppPrefs prefs) change) async =>
      state = state.copyWith(header: state.header!.copyWith(prefs: change(state.header!.prefs)));

  @override
  void lock() => state = state.copyWith(status: SessionStatus.locked);

  /// Stands in for PIN or fingerprint in widget tests.
  void unlockForTest() => state = state.copyWith(status: SessionStatus.unlocked);

  /// Like the real wipe: takes a moment (file and keystore access).
  @override
  Future<void> resetAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    state = const SessionState(status: SessionStatus.needsSetup);
  }
}

class FakeBiometrics extends BiometricService {
  FakeBiometrics(this.kind);

  final BiometricKind? kind;

  @override
  Future<BiometricKind?> available() async => kind;

  @override
  Future<bool> authenticate(String reason) async => false;
}

VaultHeader fakeHeader({AppPrefs prefs = const AppPrefs(), CredentialType type = CredentialType.pin}) => VaultHeader(
      credentialType: type,
      pinLength: 6,
      salt: '',
      iterations: 1,
      wrappedKey: '',
      prefs: prefs,
    );

final testToday = DateTime(2026, 10, 18, 9, 30);

Future<void> loadAppFonts() async {
  await initializeDateFormatting();
  Future<ByteData> bytes(String path) async => ByteData.view((await File(path).readAsBytes()).buffer);

  final jakarta = FontLoader('PlusJakartaSans');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    jakarta.addFont(bytes('assets/fonts/PlusJakartaSans-$w.ttf'));
  }
  await jakarta.load();

  final root = Platform.environment['FLUTTER_ROOT'] ?? 'D:/Flutter/flutter';
  final icons = FontLoader('MaterialIcons');
  icons.addFont(bytes('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

/// Phone-sized surface (logical 390 × [height]).
Future<void> setPhoneSize(WidgetTester tester, {double height = 844}) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = Size(390 * 2, height * 2);
  addTearDown(tester.view.reset);
}

class _InitialTab extends HomeTab {
  _InitialTab(this.initial);

  final int initial;

  @override
  int build() => initial;
}

Widget testApp({
  required SessionState session,
  Widget? home,
  BiometricKind? biometrics,
  int tab = 0,
}) {
  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(() => FakeSession(session)),
      homeTabProvider.overrideWith(() => _InitialTab(tab)),
      clockProvider.overrideWithValue(() => testToday),
      biometricServiceProvider.overrideWithValue(FakeBiometrics(biometrics)),
    ],
    child: home == null ? const FinanceApp() : FinanceApp(home: home),
  );
}

SessionState unlocked(AppData data, {AppPrefs prefs = const AppPrefs()}) =>
    SessionState(status: SessionStatus.unlocked, header: fakeHeader(prefs: prefs), data: data);

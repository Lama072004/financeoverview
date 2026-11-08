import 'dart:io';

import 'package:financeoverview/data/defaults.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/data/vault/secret_store.dart';
import 'package:financeoverview/data/vault/vault_crypto.dart';
import 'package:financeoverview/data/vault/vault_repository.dart';
import 'package:financeoverview/state/actions.dart';
import 'package:financeoverview/state/session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late VaultRepository repo;
  late DateTime now;
  late ProviderContainer container;

  ProviderContainer create() => ProviderContainer(overrides: [
        vaultRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => now),
      ]);

  Future<void> settle(ProviderContainer c) async {
    c.read(sessionProvider);
    while (c.read(sessionProvider).status == SessionStatus.loading) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('session_test');
    repo = VaultRepository(directory: dir, secrets: MemorySecretStore(), crypto: const VaultCrypto(iterations: 1000));
    now = DateTime(2026, 10, 18, 12);
    container = create();
  });

  tearDown(() async {
    container.dispose();
    await dir.delete(recursive: true);
  });

  Future<SessionController> setUpVault() async {
    await settle(container);
    expect(container.read(sessionProvider).status, SessionStatus.needsSetup);
    final session = container.read(sessionProvider.notifier);
    await session.setup(
      credential: '135790',
      type: CredentialType.pin,
      prefs: const AppPrefs(),
      initialData: initialAppData(german: true),
    );
    return session;
  }

  test('setup unlocks, data changes are persisted encrypted', () async {
    final session = await setUpVault();
    expect(container.read(sessionProvider).status, SessionStatus.unlocked);

    container.read(actionsProvider).saveAccount(const Account(id: 'a', name: 'Giro', typeId: 't'));
    await session.flush();

    // A fresh app start sees a locked vault and the saved account after unlock.
    final restarted = create();
    addTearDown(restarted.dispose);
    await settle(restarted);
    expect(restarted.read(sessionProvider).status, SessionStatus.locked);
    expect(await restarted.read(sessionProvider.notifier).unlock('135790'), isA<UnlockSuccess>());
    expect(restarted.read(appDataProvider).accounts.single.name, 'Giro');
  });

  test('wrong PINs lead to an increasing waiting time', () async {
    final session = await setUpVault();
    session.lock();
    for (var i = 1; i < SessionController.freeAttempts; i++) {
      expect(await session.unlock('000000'), isA<UnlockWrong>());
    }
    final locked = await session.unlock('000000');
    expect(locked, isA<UnlockLockedOut>());
    expect((locked as UnlockLockedOut).until, now.add(const Duration(seconds: 30)));

    // Even the right PIN is refused during the waiting time …
    expect(await session.unlock('135790'), isA<UnlockLockedOut>());
    // … and accepted afterwards; the counter resets.
    now = now.add(const Duration(seconds: 31));
    expect(await session.unlock('135790'), isA<UnlockSuccess>());
    expect(container.read(sessionProvider).header!.failedAttempts, 0);
  });

  test('lockout survives an app restart', () async {
    final session = await setUpVault();
    session.lock();
    for (var i = 0; i < SessionController.freeAttempts; i++) {
      await session.unlock('000000');
    }
    final restarted = create();
    addTearDown(restarted.dispose);
    await settle(restarted);
    expect(await restarted.read(sessionProvider.notifier).unlock('135790'), isA<UnlockLockedOut>());
  });

  test('auto lock honours the timeout', () async {
    final session = await setUpVault();
    await session.updatePrefs((p) => p.copyWith(lockTimeoutSeconds: 60));

    session.onBackground();
    now = now.add(const Duration(seconds: 30));
    session.onForeground();
    expect(container.read(sessionProvider).status, SessionStatus.unlocked);

    session.onBackground();
    now = now.add(const Duration(seconds: 61));
    session.onForeground();
    expect(container.read(sessionProvider).status, SessionStatus.locked);
    // Locked in place: the session stays in memory under the lock screen.
    expect(container.read(sessionProvider).data, isNotNull);
  });

  test('locking keeps unsaved changes, unlocking does not re-read the vault', () async {
    final session = await setUpVault();
    // Change and lock right away, before the write reached the disk.
    container.read(actionsProvider).saveAccount(const Account(id: 'a', name: 'Giro', typeId: 't'));
    session.lock();
    expect(await session.unlock('135790'), isA<UnlockSuccess>());
    expect(container.read(appDataProvider).accounts.single.name, 'Giro');
    await session.flush();
    expect((await repo.readData((await repo.unlock((await repo.loadHeader())!, '135790'))!)).accounts, hasLength(1));
  });

  test('immediate lock when the app is left', () async {
    final session = await setUpVault();
    session.onBackground();
    expect(container.read(sessionProvider).status, SessionStatus.locked);
  });

  test('biometric key unlocks without the PIN and is removed when disabled', () async {
    final session = await setUpVault();
    await session.setBiometrics(true);
    expect(container.read(prefsProvider).biometricsEnabled, isTrue);
    session.lock();
    expect(await session.unlockWithBiometricKey(), isTrue);

    await session.setBiometrics(false);
    session.lock();
    expect(await session.unlockWithBiometricKey(), isFalse);
  });

  test('changing the credential and resetting', () async {
    final session = await setUpVault();
    expect(await session.verifyCredential('135790'), isTrue);
    await session.changeCredential('ein langes Passwort', CredentialType.password);
    session.lock();
    expect(await session.unlock('135790'), isA<UnlockWrong>());
    expect(await session.unlock('ein langes Passwort'), isA<UnlockSuccess>());

    await session.resetAll();
    expect(container.read(sessionProvider).status, SessionStatus.needsSetup);
    expect(await repo.loadHeader(), isNull);
  });

  test('deleting an account removes its balances and references', () async {
    final session = await setUpVault();
    final actions = container.read(actionsProvider);
    actions.saveAccount(const Account(id: 'a', name: 'A', typeId: 't'));
    actions.saveAccount(const Account(id: 'b', name: 'B', typeId: 't'));
    actions.saveSnapshot(Snapshot(id: 's', date: DateTime(2026), values: {'a': 1, 'b': 2}, createdAt: DateTime(2026)));
    actions.saveRecurring(const RecurringItem(id: 'r', name: 'x', type: RecurringType.saving, amount: 1, toAccountId: 'a'));
    actions.deleteAccount('a');
    await session.flush();
    final data = container.read(appDataProvider);
    expect(data.accounts.map((a) => a.id), ['b']);
    expect(data.snapshots.single.values, {'b': 2});
    expect(data.recurring.single.toAccountId, isNull);
  });
}

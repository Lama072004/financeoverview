import 'dart:io';

import 'package:financeoverview/data/defaults.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/data/price_service.dart';
import 'package:financeoverview/data/vault/backup_service.dart';
import 'package:financeoverview/data/vault/secret_store.dart';
import 'package:financeoverview/data/vault/vault_crypto.dart';
import 'package:financeoverview/data/vault/vault_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late MemorySecretStore secrets;
  late VaultRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('vault_test');
    secrets = MemorySecretStore();
    repo = VaultRepository(directory: dir, secrets: secrets, crypto: const VaultCrypto(iterations: 1000));
  });

  tearDown(() => dir.delete(recursive: true));

  final data = initialAppData(german: true).copyWith(
    accounts: const [Account(id: 'a', name: 'Giro', typeId: 'x')],
  );

  test('create, unlock and read the vault', () async {
    final (header, key) = await repo.create(
      credential: '482915',
      type: CredentialType.pin,
      prefs: const AppPrefs(),
      initialData: data,
    );
    expect(header.pinLength, 6);

    final loaded = (await repo.loadHeader())!;
    expect(await repo.unlock(loaded, '000000'), isNull);
    final unlocked = await repo.unlock(loaded, '482915');
    expect(unlocked, key);
    final read = await repo.readData(unlocked!);
    expect(read.accounts.single.name, 'Giro');
    expect(read.categories, hasLength(data.categories.length));
  });

  test('vault file is not readable as plain text', () async {
    await repo.create(credential: 'pw', type: CredentialType.password, prefs: const AppPrefs(), initialData: data);
    final bytes = await File('${dir.path}${Platform.pathSeparator}data.enc').readAsBytes();
    expect(String.fromCharCodes(bytes).contains('Giro'), isFalse);
  });

  test('without the device secret the credential alone is useless', () async {
    await repo.create(credential: '1234', type: CredentialType.pin, prefs: const AppPrefs(), initialData: data);
    final header = (await repo.loadHeader())!;
    final copy = VaultRepository(
      directory: dir,
      secrets: MemorySecretStore()..values['device_secret_v1'] = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      crypto: const VaultCrypto(iterations: 1000),
    );
    expect(await copy.unlock(header, '1234'), isNull);
  });

  test('changing the credential keeps the data', () async {
    final (header, key) =
        await repo.create(credential: '1234', type: CredentialType.pin, prefs: const AppPrefs(), initialData: data);
    final next = await repo.changeCredential(
      header: header,
      dataKey: key,
      credential: 'neues Passwort',
      type: CredentialType.password,
    );
    expect(next.credentialType, CredentialType.password);
    expect(await repo.unlock(next, '1234'), isNull);
    final k = await repo.unlock(next, 'neues Passwort');
    expect((await repo.readData(k!)).accounts.single.id, 'a');
  });

  test('wipe removes files and secrets', () async {
    await repo.create(credential: '1234', type: CredentialType.pin, prefs: const AppPrefs(), initialData: data);
    await repo.wipe();
    expect(await repo.loadHeader(), isNull);
    expect(await repo.hasDeviceSecret(), isFalse);
  });

  group('backup', () {
    const service = BackupService(crypto: VaultCrypto(iterations: 1000));

    test('round trip with password', () async {
      final bytes = await service.create(data, 'geheim');
      final restored = await service.restore(bytes, 'geheim');
      expect(restored.accounts.single.name, 'Giro');
      expect(restored.toJson(), data.toJson());
    });

    test('wrong password and invalid files are reported', () async {
      final bytes = await service.create(data, 'geheim');
      await expectLater(
        service.restore(bytes, 'falsch'),
        throwsA(isA<BackupException>().having((e) => e.error, 'error', BackupError.wrongPassword)),
      );
      await expectLater(
        service.restore('kein backup'.codeUnits, 'geheim'),
        throwsA(isA<BackupException>().having((e) => e.error, 'error', BackupError.invalidFile)),
      );
    });
  });

  test('Tradegate response parsing', () {
    expect(PriceService.parseLast('{"bid": 7.64, "last": 7.657}'), 7.657);
    expect(PriceService.parseLast('{"last": "49,016"}'), 49.016);
    expect(PriceService.parseLast('{"last": 0}'), isNull);
    expect(PriceService.parseLast('<html>'), isNull);
  });
}

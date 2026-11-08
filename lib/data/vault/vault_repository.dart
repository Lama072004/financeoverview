import 'dart:convert';
import 'dart:io';

import '../models.dart';
import '../prefs.dart';
import 'secret_store.dart';
import 'vault_crypto.dart';

/// Unencrypted part of the vault: how to derive the key, plus preferences
/// needed before unlocking. Contains no financial data.
class VaultHeader {
  const VaultHeader({
    required this.credentialType,
    required this.pinLength,
    required this.salt,
    required this.iterations,
    required this.wrappedKey,
    required this.prefs,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  static const currentVersion = 1;

  final CredentialType credentialType;

  /// Number of digits for PIN credentials (shown as dots on the lock screen).
  final int pinLength;
  final String salt;
  final int iterations;

  /// Data key, encrypted with the key encryption key.
  final String wrappedKey;
  final AppPrefs prefs;
  final int failedAttempts;
  final DateTime? lockedUntil;

  VaultHeader copyWith({
    CredentialType? credentialType,
    int? pinLength,
    String? salt,
    int? iterations,
    String? wrappedKey,
    AppPrefs? prefs,
    int? failedAttempts,
    DateTime? Function()? lockedUntil,
  }) =>
      VaultHeader(
        credentialType: credentialType ?? this.credentialType,
        pinLength: pinLength ?? this.pinLength,
        salt: salt ?? this.salt,
        iterations: iterations ?? this.iterations,
        wrappedKey: wrappedKey ?? this.wrappedKey,
        prefs: prefs ?? this.prefs,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        lockedUntil: lockedUntil != null ? lockedUntil() : this.lockedUntil,
      );

  Map<String, Object?> toJson() => {
        'version': currentVersion,
        'credentialType': credentialType.name,
        'pinLength': pinLength,
        'salt': salt,
        'iterations': iterations,
        'wrappedKey': wrappedKey,
        'prefs': prefs.toJson(),
        'failedAttempts': failedAttempts,
        'lockedUntil': lockedUntil?.toIso8601String(),
      };

  factory VaultHeader.fromJson(Map<String, Object?> j) => VaultHeader(
        credentialType: CredentialType.values
            .firstWhere((e) => e.name == j['credentialType'], orElse: () => CredentialType.pin),
        pinLength: (j['pinLength'] as num?)?.toInt() ?? 0,
        salt: j['salt'] as String,
        iterations: (j['iterations'] as num).toInt(),
        wrappedKey: j['wrappedKey'] as String,
        prefs: j['prefs'] is Map ? AppPrefs.fromJson((j['prefs'] as Map).cast()) : const AppPrefs(),
        failedAttempts: (j['failedAttempts'] as num?)?.toInt() ?? 0,
        lockedUntil: j['lockedUntil'] is String ? DateTime.tryParse(j['lockedUntil'] as String) : null,
      );
}

/// Reads and writes the encrypted vault in the app's private directory.
class VaultRepository {
  VaultRepository({required this.directory, required this.secrets, this.crypto = const VaultCrypto()});

  static const _deviceSecretKey = 'device_secret_v1';
  static const _biometricKey = 'biometric_key_v1';

  final Directory directory;
  final SecretStore secrets;
  final VaultCrypto crypto;

  File get _headerFile => File('${directory.path}${Platform.pathSeparator}vault.json');
  File get _dataFile => File('${directory.path}${Platform.pathSeparator}data.enc');

  Future<VaultHeader?> loadHeader() async {
    if (!await _headerFile.exists()) return null;
    final json = jsonDecode(await _headerFile.readAsString());
    return VaultHeader.fromJson((json as Map).cast());
  }

  Future<void> saveHeader(VaultHeader header) =>
      _writeAtomic(_headerFile, utf8.encode(jsonEncode(header.toJson())));

  Future<bool> hasDeviceSecret() async => await secrets.read(_deviceSecretKey) != null;

  /// Creates a new vault and returns the data key.
  Future<(VaultHeader, List<int>)> create({
    required String credential,
    required CredentialType type,
    required AppPrefs prefs,
    required AppData initialData,
  }) async {
    await directory.create(recursive: true);
    final deviceSecret = VaultCrypto.randomBytes(32);
    await secrets.write(_deviceSecretKey, base64Encode(deviceSecret));
    await secrets.delete(_biometricKey);

    final dataKey = VaultCrypto.randomBytes(32);
    final header = await _wrap(
      dataKey: dataKey,
      credential: credential,
      type: type,
      prefs: prefs,
      deviceSecret: deviceSecret,
    );
    await writeData(dataKey, initialData);
    await saveHeader(header);
    return (header, dataKey);
  }

  /// Returns the data key, or null when the credential is wrong.
  Future<List<int>?> unlock(VaultHeader header, String credential) async {
    final deviceSecret = await _deviceSecret();
    final salt = base64Decode(header.salt);
    final stretched = await crypto.stretch(credential, salt, iterations: header.iterations);
    final kek = await crypto.keyEncryptionKey(stretched, deviceSecret, salt);
    try {
      return await crypto.decrypt(kek, base64Decode(header.wrappedKey));
    } on DecryptionFailed {
      return null;
    }
  }

  /// Data key stored for biometric unlock (only after a successful
  /// fingerprint / Face ID check).
  Future<List<int>?> biometricKey() async {
    final stored = await secrets.read(_biometricKey);
    return stored == null ? null : base64Decode(stored);
  }

  Future<void> storeBiometricKey(List<int> dataKey) => secrets.write(_biometricKey, base64Encode(dataKey));

  Future<void> clearBiometricKey() => secrets.delete(_biometricKey);

  /// Re-wraps the data key with a new credential. Data stays untouched.
  Future<VaultHeader> changeCredential({
    required VaultHeader header,
    required List<int> dataKey,
    required String credential,
    required CredentialType type,
  }) async {
    final next = await _wrap(
      dataKey: dataKey,
      credential: credential,
      type: type,
      prefs: header.prefs,
      deviceSecret: await _deviceSecret(),
    );
    await saveHeader(next);
    return next;
  }

  Future<AppData> readData(List<int> dataKey) async {
    final sealed = await _dataFile.readAsBytes();
    final plain = await crypto.decrypt(dataKey, sealed);
    final json = jsonDecode(utf8.decode(plain));
    return AppData.fromJson((json as Map).cast());
  }

  Future<void> writeData(List<int> dataKey, AppData data) async {
    final plain = utf8.encode(jsonEncode(data.toJson()));
    final sealed = await crypto.encrypt(dataKey, plain);
    await _writeAtomic(_dataFile, sealed);
  }

  /// Deletes the vault and every secret. Irreversible.
  Future<void> wipe() async {
    for (final f in [_headerFile, _dataFile]) {
      if (await f.exists()) await f.delete();
    }
    await secrets.delete(_biometricKey);
    await secrets.delete(_deviceSecretKey);
  }

  Future<VaultHeader> _wrap({
    required List<int> dataKey,
    required String credential,
    required CredentialType type,
    required AppPrefs prefs,
    required List<int> deviceSecret,
  }) async {
    final salt = VaultCrypto.randomBytes(16);
    final stretched = await crypto.stretch(credential, salt);
    final kek = await crypto.keyEncryptionKey(stretched, deviceSecret, salt);
    final wrapped = await crypto.encrypt(kek, dataKey);
    return VaultHeader(
      credentialType: type,
      pinLength: type == CredentialType.pin ? credential.length : 0,
      salt: base64Encode(salt),
      iterations: crypto.iterations,
      wrappedKey: base64Encode(wrapped),
      prefs: prefs,
    );
  }

  Future<List<int>> _deviceSecret() async {
    final stored = await secrets.read(_deviceSecretKey);
    if (stored == null) throw StateError('device secret missing');
    return base64Decode(stored);
  }

  /// Write to a temp file first, then rename – a crash never leaves a
  /// half-written vault behind.
  Future<void> _writeAtomic(File target, List<int> bytes) async {
    await directory.create(recursive: true);
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(target.path);
  }
}

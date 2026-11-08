import 'dart:convert';
import 'dart:typed_data';

import '../models.dart';
import 'vault_crypto.dart';

enum BackupError { invalidFile, wrongPassword }

class BackupException implements Exception {
  const BackupException(this.error);
  final BackupError error;
}

/// Password-protected backup file. Unlike the vault it is not bound to the
/// device, so it can be restored on a new phone.
class BackupService {
  const BackupService({this.crypto = const VaultCrypto(iterations: 200000)});

  static const format = 'finanzuebersicht-backup';
  static const version = 1;

  final VaultCrypto crypto;

  static String fileName(DateTime now) =>
      'finanzuebersicht-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.backup';

  Future<Uint8List> create(AppData data, String password, {DateTime? now}) async {
    final salt = VaultCrypto.randomBytes(16);
    final key = await crypto.stretch(password, salt);
    final sealed = await crypto.encrypt(key, utf8.encode(jsonEncode(data.forBackup().toJson())));
    final envelope = {
      'format': format,
      'version': version,
      'createdAt': (now ?? DateTime.now()).toIso8601String(),
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': crypto.iterations,
      'salt': base64Encode(salt),
      'payload': base64Encode(sealed),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
  }

  Future<AppData> restore(List<int> bytes, String password) async {
    final Map<String, Object?> envelope;
    try {
      envelope = (jsonDecode(utf8.decode(bytes)) as Map).cast();
    } catch (_) {
      throw const BackupException(BackupError.invalidFile);
    }
    if (envelope['format'] != format || envelope['payload'] is! String || envelope['salt'] is! String) {
      throw const BackupException(BackupError.invalidFile);
    }
    final salt = base64Decode(envelope['salt'] as String);
    final iterations = (envelope['iterations'] as num?)?.toInt() ?? crypto.iterations;
    final key = await crypto.stretch(password, salt, iterations: iterations);
    final List<int> plain;
    try {
      plain = await crypto.decrypt(key, base64Decode(envelope['payload'] as String));
    } on DecryptionFailed {
      throw const BackupException(BackupError.wrongPassword);
    }
    try {
      return AppData.fromJson((jsonDecode(utf8.decode(plain)) as Map).cast());
    } catch (_) {
      throw const BackupException(BackupError.invalidFile);
    }
  }
}

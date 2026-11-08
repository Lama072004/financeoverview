import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when a ciphertext cannot be authenticated (wrong key or tampered).
class DecryptionFailed implements Exception {
  const DecryptionFailed();
}

/// Crypto primitives of the vault and the backup file.
///
/// * Data: AES-256-GCM, random 96-bit nonce per write.
/// * Credential: PBKDF2-HMAC-SHA256 (run in a background isolate).
/// * Key encryption key: HKDF-SHA256 over the credential key and a random
///   device secret kept in Keychain/Keystore, so a copied vault file cannot be
///   brute-forced without the device.
class VaultCrypto {
  const VaultCrypto({this.iterations = defaultIterations});

  static const defaultIterations = 120000;
  static const _nonceLength = 12;
  static const _macLength = 16;

  final int iterations;

  static final _aes = AesGcm.with256bits();

  static Uint8List randomBytes(int length) {
    final r = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => r.nextInt(256)));
  }

  /// PBKDF2 of a PIN/password. Runs off the UI thread.
  Future<List<int>> stretch(String credential, List<int> salt, {int? iterations}) {
    final n = iterations ?? this.iterations;
    final saltCopy = List<int>.of(salt);
    return Isolate.run(() async {
      final pbkdf2 = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: n, bits: 256);
      final key = await pbkdf2.deriveKeyFromPassword(password: credential, nonce: saltCopy);
      return key.extractBytes();
    });
  }

  /// Combines the stretched credential with the device secret.
  Future<List<int>> keyEncryptionKey(List<int> stretched, List<int> deviceSecret, List<int> salt) async {
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final key = await hkdf.deriveKey(
      secretKey: SecretKey([...stretched, ...deviceSecret]),
      nonce: salt,
      info: utf8.encode('finanzuebersicht/kek/v1'),
    );
    return key.extractBytes();
  }

  Future<Uint8List> encrypt(List<int> key, List<int> plain) async {
    final box = await _aes.encrypt(plain, secretKey: SecretKey(key));
    return box.concatenation();
  }

  Future<List<int>> decrypt(List<int> key, List<int> sealed) async {
    if (sealed.length < _nonceLength + _macLength) throw const DecryptionFailed();
    final box = SecretBox.fromConcatenation(
      sealed,
      nonceLength: _nonceLength,
      macLength: _macLength,
      copy: true,
    );
    try {
      return await _aes.decrypt(box, secretKey: SecretKey(key));
    } on SecretBoxAuthenticationError {
      throw const DecryptionFailed();
    }
  }
}

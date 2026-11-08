import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small key-value store for secrets that must never leave the device
/// (Keychain on iOS, Keystore-backed storage on Android).
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class DeviceSecretStore implements SecretStore {
  DeviceSecretStore()
      : _storage = const FlutterSecureStorage(
          // Never silently wipe secrets: losing the device key would make the
          // vault unreadable.
          aOptions: AndroidOptions(resetOnError: false),
          // Bound to this device, never synced or restored to another one.
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
        );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory implementation for tests.
class MemorySecretStore implements SecretStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

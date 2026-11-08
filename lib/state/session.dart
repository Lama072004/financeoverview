import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/prefs.dart';
import '../data/vault/vault_repository.dart';

/// Injected in main() (and overridden in tests).
final vaultRepositoryProvider = Provider<VaultRepository>((ref) => throw UnimplementedError());

/// Clock, overridable for deterministic tests and screenshots.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

enum SessionStatus { loading, needsSetup, locked, unlocked, keyMissing }

@immutable
class SessionState {
  const SessionState({required this.status, this.header, this.data});

  final SessionStatus status;
  final VaultHeader? header;

  /// Decrypted data – only present while unlocked.
  final AppData? data;

  AppPrefs get prefs => header?.prefs ?? const AppPrefs();

  SessionState copyWith({SessionStatus? status, VaultHeader? header, AppData? Function()? data}) => SessionState(
        status: status ?? this.status,
        header: header ?? this.header,
        data: data != null ? data() : this.data,
      );
}

sealed class UnlockResult {
  const UnlockResult();
}

class UnlockSuccess extends UnlockResult {
  const UnlockSuccess();
}

class UnlockWrong extends UnlockResult {
  const UnlockWrong();
}

class UnlockLockedOut extends UnlockResult {
  const UnlockLockedOut(this.until);
  final DateTime until;
}

/// Owns the vault session: setup, unlock, auto-lock and persisting changes.
class SessionController extends Notifier<SessionState> {
  List<int>? _dataKey;
  Future<void> _writes = Future.value();
  int _autoLockSuspended = 0;
  DateTime? _backgroundedAt;

  /// Wrong attempts allowed before a waiting time kicks in.
  static const freeAttempts = 5;

  VaultRepository get _repo => ref.read(vaultRepositoryProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  SessionState build() {
    Future.microtask(_load);
    return const SessionState(status: SessionStatus.loading);
  }

  Future<void> _load() async {
    final header = await _repo.loadHeader();
    if (header == null) {
      state = const SessionState(status: SessionStatus.needsSetup);
    } else if (!await _repo.hasDeviceSecret()) {
      state = SessionState(status: SessionStatus.keyMissing, header: header);
    } else {
      state = SessionState(status: SessionStatus.locked, header: header);
    }
  }

  Future<void> setup({
    required String credential,
    required CredentialType type,
    required AppPrefs prefs,
    required AppData initialData,
  }) async {
    final (header, key) = await _repo.create(
      credential: credential,
      type: type,
      prefs: prefs,
      initialData: initialData,
    );
    _dataKey = key;
    state = SessionState(status: SessionStatus.unlocked, header: header, data: initialData);
  }

  /// Waiting time after [failedAttempts] wrong entries.
  static Duration lockoutFor(int failedAttempts) {
    if (failedAttempts < freeAttempts) return Duration.zero;
    const steps = [30, 60, 120, 300, 900, 1800, 3600];
    final i = (failedAttempts - freeAttempts).clamp(0, steps.length - 1);
    return Duration(seconds: steps[i]);
  }

  Future<UnlockResult> unlock(String credential) async {
    var header = state.header!;
    final now = _now();
    if (header.lockedUntil != null && header.lockedUntil!.isAfter(now)) {
      return UnlockLockedOut(header.lockedUntil!);
    }
    final key = await _repo.unlock(header, credential);
    if (key == null) {
      final attempts = header.failedAttempts + 1;
      final wait = lockoutFor(attempts);
      header = header.copyWith(
        failedAttempts: attempts,
        lockedUntil: () => wait == Duration.zero ? null : now.add(wait),
      );
      await _repo.saveHeader(header);
      state = state.copyWith(header: header);
      return wait == Duration.zero ? const UnlockWrong() : UnlockLockedOut(header.lockedUntil!);
    }
    await _openWith(key, header.copyWith(failedAttempts: 0, lockedUntil: () => null));
    return const UnlockSuccess();
  }

  /// Call only after a successful biometric check.
  Future<bool> unlockWithBiometricKey() async {
    final key = await _repo.biometricKey();
    if (key == null) return false;
    try {
      await _openWith(key, state.header!.copyWith(failedAttempts: 0, lockedUntil: () => null));
      return true;
    } catch (_) {
      // Stale key (e.g. after a reset) – fall back to PIN/password.
      await _repo.clearBiometricKey();
      return false;
    }
  }

  Future<void> _openWith(List<int> key, VaultHeader header) async {
    // Locked in place (see [lock]): the session is still in memory and may be
    // newer than the file – keep it instead of reading the vault again.
    final data = _dataKey != null && state.data != null ? state.data! : await _repo.readData(key);
    _dataKey = key;
    if (header.failedAttempts != state.header?.failedAttempts || header.lockedUntil != state.header?.lockedUntil) {
      await _repo.saveHeader(header);
    }
    state = SessionState(status: SessionStatus.unlocked, header: header, data: data);
  }

  /// Shows the lock screen on top of the app. Open screens and whatever was
  /// typed into them stay as they were and reappear after unlocking – e.g.
  /// when switching to the banking app in the middle of an entry.
  void lock() {
    if (state.status != SessionStatus.unlocked) return;
    state = state.copyWith(status: SessionStatus.locked);
  }

  // -- Auto lock ------------------------------------------------------------

  /// Keeps the session open while a system dialog (file picker, biometric
  /// prompt) puts the app in the background.
  Future<T> withoutAutoLock<T>(Future<T> Function() action) async {
    _autoLockSuspended++;
    try {
      return await action();
    } finally {
      // Give the lifecycle "resumed" event time to arrive first.
      Future.delayed(const Duration(milliseconds: 600), () => _autoLockSuspended--);
    }
  }

  void onBackground() {
    if (_autoLockSuspended > 0 || state.status != SessionStatus.unlocked) return;
    _backgroundedAt = _now();
    if (state.prefs.lockTimeoutSeconds == 0) lock();
  }

  void onForeground() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null || _autoLockSuspended > 0) return;
    if (_now().difference(since).inSeconds >= state.prefs.lockTimeoutSeconds) lock();
  }

  // -- Data -----------------------------------------------------------------

  void updateData(AppData Function(AppData data) change) {
    final current = state.data;
    final key = _dataKey;
    if (current == null || key == null) return;
    final next = change(current);
    state = state.copyWith(data: () => next);
    _writes = _writes.then((_) => _repo.writeData(key, next)).catchError((Object e) {
      debugPrint('vault write failed: $e');
    });
  }

  /// Completes when every pending write is on disk.
  Future<void> flush() => _writes;

  Future<void> replaceData(AppData data) async {
    final key = _dataKey;
    if (key == null) return;
    await flush();
    await _repo.writeData(key, data);
    state = state.copyWith(data: () => data);
  }

  // -- Preferences & credentials -------------------------------------------

  Future<void> updatePrefs(AppPrefs Function(AppPrefs prefs) change) async {
    final header = state.header;
    if (header == null) return;
    final next = header.copyWith(prefs: change(header.prefs));
    state = state.copyWith(header: next);
    await _repo.saveHeader(next);
  }

  Future<bool> verifyCredential(String credential) async =>
      await _repo.unlock(state.header!, credential) != null;

  Future<void> changeCredential(String credential, CredentialType type) async {
    final key = _dataKey;
    if (key == null) return;
    final next = await _repo.changeCredential(
      header: state.header!,
      dataKey: key,
      credential: credential,
      type: type,
    );
    state = state.copyWith(header: next);
  }

  Future<void> setBiometrics(bool enabled) async {
    final key = _dataKey;
    if (enabled) {
      if (key == null) return;
      await _repo.storeBiometricKey(key);
    } else {
      await _repo.clearBiometricKey();
    }
    await updatePrefs((p) => p.copyWith(biometricsEnabled: enabled));
  }

  /// Deletes everything and returns to the setup screen.
  Future<void> resetAll() async {
    await flush();
    _dataKey = null;
    await _repo.wipe();
    state = const SessionState(status: SessionStatus.needsSetup);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

final prefsProvider = Provider<AppPrefs>((ref) => ref.watch(sessionProvider.select((s) => s.prefs)));

/// The decrypted data. Screens below the lock gate can rely on it.
final appDataProvider = Provider<AppData>((ref) => ref.watch(sessionProvider.select((s) => s.data)) ?? const AppData());

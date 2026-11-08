import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/folder_access.dart';
import '../data/prefs.dart';
import '../data/vault/backup_service.dart';
import '../domain/backup_reminder.dart';
import 'session.dart';

final backupServiceProvider = Provider<BackupService>((ref) => const BackupService());

final folderAccessProvider = Provider<FolderAccess>((ref) => const FolderAccess());

/// Writes an encrypted backup into the chosen folder after every change
/// (bundled for a moment, at most one file per day, the newest
/// [AutoBackupPrefs.keep] are kept). State: a backup is being written.
class AutoBackupController extends Notifier<bool> {
  Timer? _timer;
  bool _running = false;
  bool _again = false;

  @override
  bool build() {
    ref.listen(sessionProvider.select((s) => s.data), (previous, next) {
      // Unlocking (null → data) and resetting (data → null) are no changes.
      if (previous == null || next == null || identical(previous, next)) return;
      if (_configured) _schedule();
    });
    ref.onDispose(() => _timer?.cancel());
    return false;
  }

  bool get _configured {
    final s = ref.read(sessionProvider);
    return s.prefs.autoBackup.enabled && s.data?.autoBackupPassword != null;
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () => runNow());
  }

  /// Writes a backup right away. Returns false when it failed.
  Future<bool> runNow() async {
    _timer?.cancel();
    if (_running) {
      _again = true;
      return true;
    }
    _running = true;
    state = true;
    var ok = false;
    try {
      do {
        _again = false;
        ok = await _write();
      } while (_again && ref.mounted);
    } finally {
      _running = false;
      if (ref.mounted) state = false;
    }
    return ok;
  }

  Future<bool> _write() async {
    final session = ref.read(sessionProvider);
    final data = session.data;
    final uri = session.prefs.autoBackup.folderUri;
    final password = data?.autoBackupPassword;
    if (data == null || uri == null || password == null) return false;
    final now = ref.read(clockProvider)();
    final folder = ref.read(folderAccessProvider);
    final controller = ref.read(sessionProvider.notifier);
    var ok = true;
    try {
      final bytes = await ref.read(backupServiceProvider).create(data, password, now: now);
      await folder.write(uri, autoBackupFileName(now), bytes);
    } catch (e) {
      debugPrint('auto backup failed: $e');
      ok = false;
    }
    if (ok) {
      // Cleaning up is optional – a failure here must not mark the backup failed.
      try {
        for (final name in outdatedAutoBackups(await folder.list(uri))) {
          await folder.delete(uri, name);
        }
      } catch (e) {
        debugPrint('auto backup cleanup failed: $e');
      }
    }
    if (!ref.mounted) return ok;
    await controller.updatePrefs((p) {
      // Folder changed or switched off meanwhile.
      if (p.autoBackup.folderUri != uri) return p;
      return p.copyWith(
        lastBackupAt: ok ? now : null,
        autoBackup: AutoBackupPrefs(
          folderUri: uri,
          folderName: p.autoBackup.folderName,
          lastRunAt: ok ? now : p.autoBackup.lastRunAt,
          failed: !ok,
        ),
      );
    });
    return ok;
  }
}

final autoBackupProvider = NotifierProvider<AutoBackupController, bool>(AutoBackupController.new);

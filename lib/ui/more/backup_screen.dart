import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/folder_access.dart';
import '../../data/prefs.dart';
import '../../data/vault/backup_service.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/auto_backup.dart';
import '../../state/session.dart';
import '../lock/reset_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  SessionController get _session => ref.read(sessionProvider.notifier);

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    final password = await _askPassword(confirm: true, action: l.backupExport, hint: l.backupPasswordHint);
    if (password == null || !mounted) return;
    final session = _session;
    setState(() => _busy = true);
    try {
      await session.flush();
      final now = ref.read(clockProvider)();
      final bytes = await ref.read(backupServiceProvider).create(ref.read(appDataProvider), password, now: now);
      final path = await session.withoutAutoLock(
        () => FilePicker.saveFile(dialogTitle: l.backupExport, fileName: BackupService.fileName(now), bytes: bytes),
      );
      if (path != null) {
        await session.updatePrefs((p) => p.copyWith(lastBackupAt: now, backupReminderSnoozedUntil: () => null));
        if (mounted) showSnack(context, l.backupSaved);
      }
    } catch (_) {
      if (mounted) showSnack(context, l.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    final session = _session;
    final picked = await session.withoutAutoLock(() => FilePicker.pickFiles(withData: true));
    final bytes = picked?.files.single.bytes;
    if (bytes == null || !mounted) return;
    final password = await _askPassword(confirm: false, action: l.backupImport);
    if (password == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final data = await ref.read(backupServiceProvider).restore(bytes, password);
      if (!mounted) return;
      final ok = await confirmDialog(
        context,
        title: l.backupImportConfirmTitle,
        body: l.backupImportConfirmBody,
        confirmLabel: l.backupImport,
      );
      if (!ok) return;
      // The automatic backup of this device keeps working with its password.
      final current = ref.read(appDataProvider).autoBackupPassword;
      await session.replaceData(data.copyWith(autoBackupPassword: () => current));
      if (mounted) showSnack(context, l.backupRestored);
    } on BackupException catch (e) {
      if (mounted) {
        showSnack(context, e.error == BackupError.wrongPassword ? l.backupWrongPassword : l.backupInvalid);
      }
    } catch (_) {
      if (mounted) showSnack(context, l.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // -- Automatic backup ------------------------------------------------------

  /// Lets the user pick a folder (and a password when [askPassword]), then
  /// writes the first backup into it.
  Future<void> _chooseFolder({required bool askPassword}) async {
    final l = AppLocalizations.of(context);
    final session = _session;
    final folders = ref.read(folderAccessProvider);
    PickedFolder? picked;
    try {
      picked = await session.withoutAutoLock(folders.pick);
    } catch (_) {
      if (mounted) showSnack(context, l.backupFailed);
    }
    if (picked == null || !mounted) return;
    if (askPassword) {
      final password = await _askPassword(confirm: true, action: l.autoBackupEnable, hint: l.autoBackupPasswordHint);
      if (password == null || !mounted) {
        await folders.release(picked.uri);
        return;
      }
      ref.read(actionsProvider).setAutoBackupPassword(password);
    }
    final previous = ref.read(prefsProvider).autoBackup.folderUri;
    if (previous != null && previous != picked.uri) await folders.release(previous);
    final folder = picked;
    await session.updatePrefs(
      (p) => p.copyWith(autoBackup: AutoBackupPrefs(folderUri: folder.uri, folderName: folder.name)),
    );
    await _runNow();
  }

  Future<void> _changePassword() async {
    final l = AppLocalizations.of(context);
    final password = await _askPassword(confirm: true, action: l.save, hint: l.autoBackupPasswordHint);
    if (password == null || !mounted) return;
    ref.read(actionsProvider).setAutoBackupPassword(password);
    await _runNow();
  }

  Future<void> _runNow() async {
    final l = AppLocalizations.of(context);
    await _session.flush();
    final ok = await ref.read(autoBackupProvider.notifier).runNow();
    if (mounted) showSnack(context, ok ? l.autoBackupDone : l.backupFailed);
  }

  Future<void> _disable() async {
    final l = AppLocalizations.of(context);
    final uri = ref.read(prefsProvider).autoBackup.folderUri;
    ref.read(actionsProvider).setAutoBackupPassword(null);
    await _session.updatePrefs((p) => p.copyWith(autoBackup: const AutoBackupPrefs()));
    if (uri != null) {
      try {
        await ref.read(folderAccessProvider).release(uri);
      } catch (_) {
        // Access is gone anyway.
      }
    }
    if (mounted) showSnack(context, l.autoBackupDisabled);
  }

  Future<String?> _askPassword({required bool confirm, required String action, String? hint}) => showDialog<String>(
        context: context,
        builder: (_) => _PasswordDialog(confirm: confirm, action: action, hint: hint),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final prefs = ref.watch(prefsProvider);
    final hasPassword = ref.watch(appDataProvider.select((d) => d.autoBackupPassword != null));
    final auto = prefs.autoBackup;
    final autoOn = auto.enabled && hasPassword;
    final running = ref.watch(autoBackupProvider);
    String dateTime(DateTime d) => '${fmt.date(d)}, ${fmt.time(d)}';
    String reminderLabel(int days) => days == 0 ? l.backupReminderOff : l.daysCount(days);

    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconBadge(icon: Icons.shield_moon_rounded, color: context.colors.primary, size: 52),
                ),
                const SizedBox(height: 14),
                Text(l.backupIntro, style: context.text.bodyMedium),
                const SizedBox(height: 10),
                Text(
                  prefs.lastBackupAt == null ? l.backupNone : l.backupLast(dateTime(prefs.lastBackupAt!)),
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 20),
                if (_busy)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text(l.pleaseWait, style: context.text.bodySmall),
                      ],
                    ),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: _export,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(l.backupExport),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _import,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(l.backupImport),
                  ),
                ],
              ],
            ),
          ),
          SectionTitle(l.autoBackupTitle),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.autoBackupIntro, style: context.text.bodyMedium),
                const SizedBox(height: 14),
                if (!autoOn) ...[
                  InfoNote(l.autoBackupTip, icon: Icons.lightbulb_outline_rounded),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => _chooseFolder(askPassword: true),
                    icon: const Icon(Icons.create_new_folder_rounded),
                    label: Text(l.autoBackupEnable),
                  ),
                ] else ...[
                  KeyValueRow(label: l.autoBackupFolder, value: auto.folderName ?? '—'),
                  KeyValueRow(
                    label: l.autoBackupLastRun,
                    value: auto.lastRunAt == null ? l.autoBackupNever : dateTime(auto.lastRunAt!),
                  ),
                  if (auto.failed) ...[
                    const SizedBox(height: 8),
                    InfoNote(l.autoBackupFailed, icon: Icons.warning_amber_rounded),
                  ],
                  const SizedBox(height: 14),
                  FilledButton.tonalIcon(
                    onPressed: running ? null : _runNow,
                    icon: running
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_rounded),
                    label: Text(l.autoBackupRunNow),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _chooseFolder(askPassword: false),
                        child: Text(l.autoBackupChangeFolder),
                      ),
                      TextButton(onPressed: _changePassword, child: Text(l.autoBackupChangePassword)),
                      TextButton(onPressed: _disable, child: Text(l.autoBackupDisable)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SectionTitle(l.backupReminderTitle),
          ListCard(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(l.backupReminderLabel),
                subtitle: Text(l.backupReminderHint),
                trailing: Text(reminderLabel(prefs.backupReminderDays), style: context.text.labelLarge),
                onTap: () async {
                  final picked = await showOptionSheet<int>(
                    context,
                    title: l.backupReminderLabel,
                    selected: prefs.backupReminderDays,
                    options: [
                      for (final d in AppPrefs.backupReminderOptions) PickerOption(value: d, label: reminderLabel(d)),
                    ],
                  );
                  if (picked != null) {
                    await _session.updatePrefs(
                      (p) => p.copyWith(backupReminderDays: picked.value, backupReminderSnoozedUntil: () => null),
                    );
                  }
                },
              ),
            ],
          ),
          SectionTitle(l.dangerZone),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.resetApp, style: context.text.titleSmall),
                      Text(l.resetAppHint, style: context.text.bodySmall),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: context.fin.negative),
                  onPressed: () async {
                    await confirmReset(context, ref);
                  },
                  child: Text(l.resetApp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.confirm, required this.action, this.hint});

  final bool confirm;
  final String action;
  final String? hint;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.backupPassword),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.hint != null) ...[
              Text(widget.hint!, style: context.text.bodySmall),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _password,
              autofocus: true,
              obscureText: _obscure,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l.backupPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if ((v ?? '').isEmpty) return l.requiredField;
                if (widget.confirm && v!.length < 8) return l.backupPasswordTooShort;
                return null;
              },
            ),
            if (widget.confirm) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _repeat,
                obscureText: _obscure,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(labelText: l.backupPasswordRepeat),
                validator: (v) => v != _password.text ? l.credentialsMismatch : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        TextButton(
          onPressed: () {
            if (_form.currentState!.validate()) Navigator.pop(context, _password.text);
          },
          child: Text(widget.action),
        ),
      ],
    );
  }
}

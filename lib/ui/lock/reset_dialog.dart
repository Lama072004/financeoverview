import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/auto_backup.dart';
import '../../state/reminders.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';

Future<void> showForgotDialog(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final reset = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.forgotTitle),
      content: Text(l.forgotBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.close)),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.fin.negative),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.resetApp),
        ),
      ],
    ),
  );
  if (reset == true && context.mounted) await confirmReset(context, ref);
}

/// Asks the user to type the confirmation word, then wipes everything.
Future<void> confirmReset(BuildContext context, WidgetRef ref) async {
  // Read before awaiting: the calling screen is gone once the reset is done.
  final session = ref.read(sessionProvider.notifier);
  final reminders = ref.read(reminderServiceProvider);
  final folders = ref.read(folderAccessProvider);
  final folder = ref.read(prefsProvider).autoBackup.folderUri;
  final confirmed = await showDialog<bool>(context: context, builder: (_) => const _ResetDialog());
  if (confirmed != true) return;
  await session.resetAll();
  // Nothing of the old setup may live on: no reminders, no folder access.
  try {
    await reminders.cancelAll();
    if (folder != null) await folders.release(folder);
  } catch (_) {
    // Best effort – the data itself is already gone.
  }
}

/// Owns its text controller, so the field stays valid while the dialog
/// animates out.
class _ResetDialog extends StatefulWidget {
  const _ResetDialog();

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final matches = _controller.text.trim().toUpperCase() == l.resetConfirmWord;
    return AlertDialog(
      title: Text(l.resetConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.resetConfirmBody),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l.resetTypeConfirm(l.resetConfirmWord)),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: context.fin.negative),
          onPressed: matches ? () => Navigator.pop(context, true) : null,
          child: Text(l.resetApp),
        ),
      ],
    );
  }
}

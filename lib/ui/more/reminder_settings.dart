import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prefs.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/reminders.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

/// "1., 15." / "1st, 15th".
String reminderDayList(List<int> days, String localeName) => days.map((d) {
      if (localeName.startsWith('de')) return '$d.';
      final suffix = (d % 100 >= 11 && d % 100 <= 13)
          ? 'th'
          : switch (d % 10) {
              1 => 'st',
              2 => 'nd',
              3 => 'rd',
              _ => 'th',
            };
      return '$d$suffix';
    }).join(', ');

/// Settings card for the reminder to enter the balances.
class ReminderSettingsCard extends ConsumerWidget {
  const ReminderSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reminder = ref.watch(prefsProvider.select((p) => p.reminder));
    final session = ref.read(sessionProvider.notifier);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: reminder.hour, minute: reminder.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context) || l.localeName.startsWith('de'),
    );
    final days = reminderDayList(reminder.days, l.localeName);

    Future<void> update(ReminderPrefs Function(ReminderPrefs r) change) =>
        session.updatePrefs((p) => p.copyWith(reminder: change(p.reminder)));

    Future<void> toggle(bool enable) async {
      if (enable) {
        final service = ref.read(reminderServiceProvider);
        final allowed = await session.withoutAutoLock(service.requestPermission);
        if (!allowed) {
          if (context.mounted) showSnack(context, l.reminderPermissionDenied);
          return;
        }
      }
      await update((r) => r.copyWith(enabled: enable));
    }

    return ListCard(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_rounded),
          title: Text(l.reminderToggle),
          subtitle: Text(reminder.enabled ? l.reminderSummary(days, time) : l.reminderHint),
          value: reminder.enabled,
          onChanged: toggle,
        ),
        if (reminder.enabled) ...[
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: Text(l.reminderDays),
            trailing: Text(days, style: context.text.labelLarge),
            onTap: () async {
              final picked = await showModalBottomSheet<List<int>>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _DaysSheet(initial: reminder.days),
              );
              if (picked != null) await update((r) => r.copyWith(days: picked));
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: Text(l.reminderTime),
            trailing: Text(time, style: context.text.labelLarge),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
              );
              if (picked != null) await update((r) => r.copyWith(hour: picked.hour, minute: picked.minute));
            },
          ),
        ],
      ],
    );
  }
}

class _DaysSheet extends StatefulWidget {
  const _DaysSheet({required this.initial});

  final List<int> initial;

  @override
  State<_DaysSheet> createState() => _DaysSheetState();
}

class _DaysSheetState extends State<_DaysSheet> {
  late final _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.reminderDays, style: context.text.titleMedium),
            const SizedBox(height: 4),
            Text(l.reminderDaysHint, style: context.text.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var d = 1; d <= ReminderPrefs.maxDay; d++)
                  SizedBox(
                    width: 44,
                    child: FilterChip(
                      label: SizedBox(width: double.infinity, child: Text('$d', textAlign: TextAlign.center)),
                      labelPadding: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      showCheckmark: false,
                      selected: _selected.contains(d),
                      onSelected: (on) => setState(() => on ? _selected.add(d) : _selected.remove(d)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, _selected.toList()..sort()),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../core/ids.dart';
import '../../data/models.dart';
import '../../domain/overview_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

/// One balance entry ("Kontostände" row). Empty fields carry over.
class SnapshotEditor extends ConsumerStatefulWidget {
  const SnapshotEditor({super.key, this.snapshot});

  final Snapshot? snapshot;

  @override
  ConsumerState<SnapshotEditor> createState() => _SnapshotEditorState();
}

class _SnapshotEditorState extends ConsumerState<SnapshotEditor> {
  final _form = GlobalKey<FormState>();
  late DateTime _date;
  late final TextEditingController _note;
  final _controllers = <String, TextEditingController>{};
  late final List<Account> _accounts;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _date = widget.snapshot?.date ?? ref.read(todayProvider);
    _note = TextEditingController(text: widget.snapshot?.note ?? '');
    final data = ref.read(appDataProvider);
    _accounts = [
      for (final a in data.accounts)
        if (!a.archived || (widget.snapshot?.values.containsKey(a.id) ?? false)) a,
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final fmt = Fmt.of(context);
    for (final a in _accounts) {
      final v = widget.snapshot?.values[a.id];
      _controllers[a.id] = TextEditingController(text: v == null ? '' : fmt.plain(v));
    }
  }

  @override
  void dispose() {
    _note.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Balances before this entry (without the entry being edited).
  BalanceRow? _previous(AppData data) {
    final others = data.copyWith(snapshots: data.snapshots.where((s) => s.id != widget.snapshot?.id).toList());
    final rows = balanceHistory(others).where((r) => !r.date.isAfter(_date)).toList();
    return rows.isEmpty ? null : rows.last;
  }

  Map<String, double> _entered() => {
        for (final e in _controllers.entries)
          if (parseAmount(e.value.text) != null) e.key: parseAmount(e.value.text)!,
      };

  void _save() {
    if (!_form.currentState!.validate()) return;
    final values = _entered();
    final actions = ref.read(actionsProvider);
    final existing = widget.snapshot;
    actions.saveSnapshot(
      existing == null
          ? Snapshot(id: newId(), date: dateOnly(_date), values: values, note: _note.text.trim(), createdAt: DateTime.now())
          : existing.copyWith(date: dateOnly(_date), values: values, note: _note.text.trim()),
    );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(context, title: l.deleteConfirmTitle, body: l.deleteConfirmBody) && mounted) {
      ref.read(actionsProvider).deleteSnapshot(widget.snapshot!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final previous = _previous(data);

    // Live preview of the net worth after this entry.
    final entered = _entered();
    var total = 0.0;
    for (final a in data.accounts) {
      final v = entered[a.id] ?? previous?.balanceOf(a.id) ?? 0;
      total += data.behaviorOf(a) == AccountBehavior.debt ? -v : v;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.snapshot == null ? l.snapshotNew : l.snapshotEdit),
        actions: [
          if (widget.snapshot != null)
            IconButton(tooltip: l.deleteEntry, icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
        ],
      ),
      body: _accounts.isEmpty
          ? Padding(padding: formPadding, child: InfoNote(l.needAccountsFirst))
          : Form(
              key: _form,
              child: ListView(
                padding: formPadding,
                children: [
                  DateField(label: l.dateLabel, value: _date, onChanged: (d) => setState(() => _date = d ?? _date)),
                  const SizedBox(height: 12),
                  InfoNote(l.snapshotHint),
                  const SizedBox(height: 16),
                  for (final a in _accounts) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: IconBadge(
                            icon: accountIcon(a.icon),
                            color: context.fin.chartColor(a.colorIndex),
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberField(
                            controller: _controllers[a.id]!,
                            label: a.name,
                            hint: previous == null || fmt.hidden ? null : fmt.plain(previous.balanceOf(a.id)),
                            helper: previous == null ? null : l.lastValue(fmt.money(previous.balanceOf(a.id))),
                            allowNegative: data.behaviorOf(a) == AccountBehavior.liquid,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    fieldGap,
                  ],
                  TextFormField(
                    controller: _note,
                    decoration: InputDecoration(labelText: l.noteLabel),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    color: context.colors.primaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.snapshotTotalPreview,
                            style: context.text.titleSmall?.copyWith(color: context.colors.onPrimaryContainer),
                          ),
                        ),
                        Amount(
                          fmt.money(total),
                          style: context.text.titleMedium?.copyWith(color: context.colors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _save, child: Text(l.save)),
                ],
              ),
            ),
    );
  }
}

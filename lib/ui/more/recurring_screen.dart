import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/ids.dart';
import '../../data/models.dart';
import '../../domain/recurring_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../dashboard/dashboard_cards.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

String rhythmLabel(AppLocalizations l, Rhythm r) => switch (r) {
      Rhythm.weekly => l.rhythmWeekly,
      Rhythm.monthly => l.rhythmMonthly,
      Rhythm.bimonthly => l.rhythmBimonthly,
      Rhythm.quarterly => l.rhythmQuarterly,
      Rhythm.halfYearly => l.rhythmHalfYearly,
      Rhythm.yearly => l.rhythmYearly,
    };

String recurringTypeLabel(AppLocalizations l, RecurringType t) => switch (t) {
      RecurringType.income => l.typeIncome,
      RecurringType.expense => l.typeExpense,
      RecurringType.saving => l.typeSaving,
    };

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final today = ref.watch(todayProvider);
    final summary = ref.watch(recurringSummaryProvider);
    final byCategory = summary.expensesByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.recurringTitle),
        actions: [
          IconButton(
            tooltip: l.addRecurring,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => push(context, const RecurringEditScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const RecurringSummaryCard(large: true),
          if (byCategory.isNotEmpty) ...[
            SectionTitle(l.fixedByCategory),
            AppCard(
              child: Column(
                children: [
                  for (final e in byCategory)
                    Builder(builder: (context) {
                      final s = spendingStyle(context, data, e.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            IconBadge(icon: s.icon, color: s.color, size: 34),
                            const SizedBox(width: 12),
                            Expanded(child: Text(s.label, style: context.text.bodyMedium)),
                            Text(
                              summary.fixedExpenses == 0 ? '' : fmt.percentRound(e.value / summary.fixedExpenses),
                              style: context.text.labelMedium,
                            ),
                            const SizedBox(width: 12),
                            Amount(fmt.money(e.value), style: context.text.titleSmall),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
          for (final type in RecurringType.values) ...[
            if (data.recurring.any((r) => r.type == type)) ...[
              SectionTitle(recurringTypeLabel(l, type)),
              ListCard(
                children: [
                  for (final r in data.recurring.where((r) => r.type == type))
                    _RecurringTile(item: r, monthly: monthlyAmount(r, today)),
                ],
              ),
            ],
          ],
          if (data.recurring.isEmpty) ...[
            const SizedBox(height: 14),
            AppCard(
              child: EmptyState(
                icon: Icons.event_repeat_rounded,
                title: l.noRecurring,
                body: l.recurringHint,
                action: FilledButton.icon(
                  onPressed: () => push(context, const RecurringEditScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.addRecurring),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            InfoNote(l.recurringHint),
          ],
        ],
      ),
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({required this.item, required this.monthly});

  final RecurringItem item;
  final double monthly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final s = spendingStyle(context, data, item.categoryId);
    final inactive = monthly == 0;
    final target = data.accountById(item.type == RecurringType.expense ? item.fromAccountId : item.toAccountId);
    final details = [
      '${fmt.money(item.amount)} ${rhythmLabel(l, item.rhythm)}',
      ?target?.name,
      if (inactive) l.inactive,
    ];
    return Opacity(
      opacity: inactive ? 0.55 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        onTap: () => push(context, RecurringEditScreen(item: item)),
        leading: IconBadge(
          icon: item.type == RecurringType.saving ? Icons.savings_rounded : s.icon,
          color: item.type == RecurringType.income ? context.fin.positive : s.color,
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(details.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Amount(fmt.money(monthly), style: context.text.titleSmall),
            Text(l.perMonth, style: context.text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class RecurringEditScreen extends ConsumerStatefulWidget {
  const RecurringEditScreen({super.key, this.item});

  final RecurringItem? item;

  @override
  ConsumerState<RecurringEditScreen> createState() => _RecurringEditScreenState();
}

class _RecurringEditScreenState extends ConsumerState<RecurringEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _dueDay;
  late final TextEditingController _note;
  late RecurringType _type;
  late Rhythm _rhythm;
  String? _categoryId;
  String? _from;
  String? _to;
  late bool _active;
  DateTime? _start;
  DateTime? _end;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final r = widget.item;
    _name = TextEditingController(text: r?.name ?? '');
    _amount = TextEditingController();
    _dueDay = TextEditingController(text: r?.dueDay?.toString() ?? '');
    _note = TextEditingController(text: r?.note ?? '');
    _type = r?.type ?? RecurringType.expense;
    _rhythm = r?.rhythm ?? Rhythm.monthly;
    _categoryId = r?.categoryId;
    _from = r?.fromAccountId;
    _to = r?.toAccountId;
    _active = r?.active ?? true;
    _start = r?.start;
    _end = r?.end;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (widget.item != null) _amount.text = Fmt.of(context).plain(widget.item!.amount);
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _dueDay.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final due = int.tryParse(_dueDay.text.trim());
    final item = RecurringItem(
      id: widget.item?.id ?? newId(),
      name: _name.text.trim(),
      type: _type,
      categoryId: _categoryId,
      amount: parseAmount(_amount.text)!.abs(),
      rhythm: _rhythm,
      dueDay: due != null && due >= 1 && due <= 31 ? due : null,
      fromAccountId: _type == RecurringType.income ? null : _from,
      toAccountId: _type == RecurringType.expense ? null : _to,
      active: _active,
      start: _start,
      end: _end,
      note: _note.text.trim(),
    );
    ref.read(actionsProvider).saveRecurring(item);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(context, title: l.deleteConfirmTitle, body: l.deleteConfirmBody) && mounted) {
      ref.read(actionsProvider).deleteRecurring(widget.item!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final kind = _type == RecurringType.income ? CategoryKind.income : CategoryKind.expense;
    final categories = data.categories.where((c) => c.kind == kind || c.id == _categoryId).toList();
    final accounts = data.accounts.where((a) => !a.archived || a.id == _from || a.id == _to).toList();
    final amount = parseAmount(_amount.text) ?? 0;

    List<PickerOption<String?>> accountOptions() => [
          PickerOption(value: null, label: l.noAccount),
          for (final a in accounts)
            PickerOption(
              value: a.id,
              label: a.name,
              subtitle: data.typeOf(a)?.name,
              leading: Icon(accountIcon(a.icon), color: context.fin.chartColor(a.colorIndex)),
            ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? l.addRecurring : l.editRecurring),
        actions: [
          if (widget.item != null) IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: formPadding,
          children: [
            SegmentedButton<RecurringType>(
              showSelectedIcon: false,
              segments: [
                for (final t in RecurringType.values) ButtonSegment(value: t, label: Text(recurringTypeLabel(l, t))),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                final k = _type == RecurringType.income ? CategoryKind.income : CategoryKind.expense;
                if (data.categoryById(_categoryId)?.kind != k) _categoryId = null;
              }),
            ),
            if (_type == RecurringType.saving) ...[const SizedBox(height: 12), InfoNote(l.savingHint)],
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.recurringName),
              validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
            ),
            fieldGap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NumberField(
                    controller: _amount,
                    label: l.amountLabel,
                    required: true,
                    helper: l.amountPositiveHint,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PickerField<Rhythm>(
                    label: l.rhythm,
                    value: _rhythm,
                    onChanged: (v) => setState(() => _rhythm = v),
                    options: [for (final r in Rhythm.values) PickerOption(value: r, label: rhythmLabel(l, r))],
                  ),
                ),
              ],
            ),
            if (_rhythm != Rhythm.monthly && amount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  '= ${fmt.money(amount * rhythmFactor(_rhythm))} ${l.perMonth}',
                  style: money(context.text.bodySmall),
                ),
              ),
            fieldGap,
            PickerField<String?>(
              label: l.category,
              value: _categoryId,
              onChanged: (v) => setState(() => _categoryId = v),
              options: [
                PickerOption(value: null, label: l.noCategory),
                for (final c in categories)
                  PickerOption(
                    value: c.id,
                    label: c.name,
                    leading: Icon(categoryIcon(c.icon), color: context.fin.chartColor(c.colorIndex)),
                  ),
              ],
            ),
            fieldGap,
            if (_type != RecurringType.income) ...[
              PickerField<String?>(
                label: l.fromAccount,
                value: _from,
                onChanged: (v) => setState(() => _from = v),
                options: accountOptions(),
              ),
              fieldGap,
            ],
            if (_type != RecurringType.expense) ...[
              PickerField<String?>(
                label: l.toAccount,
                value: _to,
                onChanged: (v) => setState(() => _to = v),
                options: accountOptions(),
              ),
              fieldGap,
            ],
            NumberField(controller: _dueDay, label: l.dueDay, suffix: null, integer: true, hint: '1–31'),
            fieldGap,
            Row(
              children: [
                Expanded(child: DateField(label: l.startDate, value: _start, allowClear: true, onChanged: (d) => setState(() => _start = d))),
                const SizedBox(width: 12),
                Expanded(child: DateField(label: l.endDate, value: _end, allowClear: true, onChanged: (d) => setState(() => _end = d))),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(l.active),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l.noteLabel),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

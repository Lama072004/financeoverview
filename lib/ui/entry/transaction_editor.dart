import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../core/ids.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

/// Single expense or income. Does not touch any balance.
class TransactionEditor extends ConsumerStatefulWidget {
  const TransactionEditor({super.key, this.transaction, this.isIncome = false});

  final TransactionEntry? transaction;
  final bool isIncome;

  @override
  ConsumerState<TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends ConsumerState<TransactionEditor> {
  final _form = GlobalKey<FormState>();
  late bool _income;
  late DateTime _date;
  String? _categoryId;
  String? _accountId;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _income = t?.isIncome ?? widget.isIncome;
    _date = t?.date ?? ref.read(todayProvider);
    _categoryId = t?.categoryId;
    _accountId = t?.accountId;
    _note = TextEditingController(text: t?.note ?? '');
    _amount = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final t = widget.transaction;
    if (t != null) _amount.text = Fmt.of(context).plain(t.amount);
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final amount = parseAmount(_amount.text)!.abs();
    final existing = widget.transaction;
    ref.read(actionsProvider).saveTransaction(
          existing == null
              ? TransactionEntry(
                  id: newId(),
                  date: dateOnly(_date),
                  amount: amount,
                  isIncome: _income,
                  categoryId: _categoryId,
                  accountId: _accountId,
                  note: _note.text.trim(),
                  createdAt: DateTime.now(),
                )
              : existing.copyWith(
                  date: dateOnly(_date),
                  amount: amount,
                  isIncome: _income,
                  categoryId: () => _categoryId,
                  accountId: () => _accountId,
                  note: _note.text.trim(),
                ),
        );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    if (await confirmDialog(context, title: l.deleteConfirmTitle, body: l.deleteConfirmBody) && mounted) {
      ref.read(actionsProvider).deleteTransaction(widget.transaction!.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);
    final kind = _income ? CategoryKind.income : CategoryKind.expense;
    final categories = data.categories.where((c) => c.kind == kind || c.id == _categoryId).toList();
    final title = widget.transaction != null ? l.transactionEdit : (_income ? l.incomeNew : l.expenseNew);
    final accent = _income ? context.fin.positive : context.fin.negative;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.transaction != null)
            IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: formPadding,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l.typeExpense), icon: const Icon(Icons.remove_rounded)),
                ButtonSegment(value: true, label: Text(l.typeIncome), icon: const Icon(Icons.add_rounded)),
              ],
              selected: {_income},
              onSelectionChanged: (s) => setState(() {
                _income = s.first;
                if (data.categoryById(_categoryId)?.kind != (_income ? CategoryKind.income : CategoryKind.expense)) {
                  _categoryId = null;
                }
              }),
            ),
            const SizedBox(height: 18),
            NumberField(
              controller: _amount,
              label: l.amountLabel,
              required: true,
              big: true,
              autofocus: widget.transaction == null,
            ),
            const SizedBox(height: 18),
            Text(l.category, style: context.text.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    selected: c.id == _categoryId,
                    onSelected: (sel) => setState(() => _categoryId = sel ? c.id : null),
                    avatar: Icon(
                      categoryIcon(c.icon),
                      size: 18,
                      color: c.id == _categoryId
                          ? accent
                          : IconBadge.readable(context, context.fin.chartColor(c.colorIndex)),
                    ),
                    label: Text(c.name),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            DateField(label: l.dateLabel, value: _date, onChanged: (d) => setState(() => _date = d ?? _date)),
            fieldGap,
            PickerField<String?>(
              label: l.account,
              value: _accountId,
              onChanged: (v) => setState(() => _accountId = v),
              options: [
                PickerOption(value: null, label: l.noAccount),
                for (final a in data.accounts.where((a) => !a.archived || a.id == _accountId))
                  PickerOption(
                    value: a.id,
                    label: a.name,
                    leading: Icon(accountIcon(a.icon), color: context.fin.chartColor(a.colorIndex)),
                  ),
              ],
            ),
            fieldGap,
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l.noteLabel),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            InfoNote(l.transactionHint),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

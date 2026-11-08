import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/ids.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

String behaviorLabel(AppLocalizations l, AccountBehavior b) => switch (b) {
      AccountBehavior.liquid => l.behaviorLiquid,
      AccountBehavior.invested => l.behaviorInvested,
      AccountBehavior.debt => l.behaviorDebt,
    };

class AccountEditScreen extends ConsumerStatefulWidget {
  const AccountEditScreen({super.key, this.account});

  final Account? account;

  @override
  ConsumerState<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends ConsumerState<AccountEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late final TextEditingController _goal;
  late String _typeId;
  late String _icon;
  late int _color;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    final data = ref.read(appDataProvider);
    _name = TextEditingController(text: a?.name ?? '');
    _note = TextEditingController(text: a?.note ?? '');
    _goal = TextEditingController();
    _typeId = a?.typeId ?? (data.accountTypes.firstOrNull?.id ?? '');
    _icon = a?.icon ?? 'bank';
    _color = a?.colorIndex ?? data.accounts.length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final g = widget.account?.savingsGoal;
    if (g != null) _goal.text = Fmt.of(context).plain(g);
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _goal.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final goal = parseAmount(_goal.text);
    final base = widget.account ?? Account(id: newId(), name: '', typeId: _typeId);
    ref.read(actionsProvider).saveAccount(base.copyWith(
          name: _name.text.trim(),
          typeId: _typeId,
          note: _note.text.trim(),
          icon: _icon,
          colorIndex: _color,
          savingsGoal: () => goal == null || goal <= 0 ? null : goal,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);
    final fin = context.fin;

    return Scaffold(
      appBar: AppBar(title: Text(widget.account == null ? l.addAccount : l.editAccount)),
      body: Form(
        key: _form,
        child: ListView(
          padding: formPadding,
          children: [
            Center(
              child: IconBadge(icon: accountIcon(_icon), color: fin.chartColor(_color), size: 72),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              autofocus: widget.account == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.accountName),
              validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
            ),
            fieldGap,
            PickerField<String>(
              label: l.accountType,
              value: _typeId,
              onChanged: (v) => setState(() => _typeId = v),
              options: [
                for (final t in data.accountTypes)
                  PickerOption(value: t.id, label: t.name, subtitle: behaviorLabel(l, t.behavior)),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.accountIcon, style: context.text.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in accountIcons.entries)
                  _Choice(
                    selected: e.key == _icon,
                    onTap: () => setState(() => _icon = e.key),
                    child: Icon(e.value, color: e.key == _icon ? context.colors.onPrimaryContainer : fin.muted),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.accountColor, style: context.text.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < fin.chart.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: fin.chart[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == _color % fin.chart.length ? context.colors.onSurface : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            NumberField(controller: _goal, label: l.accountGoal, helper: l.goalModeAccountHint),
            fieldGap,
            TextFormField(
              controller: _note,
              decoration: InputDecoration(labelText: l.noteLabel),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.selected, required this.onTap, required this.child});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? context.colors.primaryContainer : context.colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? context.colors.primary : Colors.transparent, width: 1.5),
          ),
          child: Center(child: child),
        ),
      );
}

/// Icon grid used by the account and category editors.
class IconChoiceGrid extends StatelessWidget {
  const IconChoiceGrid({super.key, required this.icons, required this.selected, required this.onSelected});

  final Map<String, IconData> icons;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in icons.entries)
            _Choice(
              selected: e.key == selected,
              onTap: () => onSelected(e.key),
              child: Icon(e.value, color: e.key == selected ? context.colors.onPrimaryContainer : context.fin.muted),
            ),
        ],
      );
}

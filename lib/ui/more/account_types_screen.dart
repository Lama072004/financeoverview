import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ids.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../accounts/account_edit_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

IconData behaviorIcon(AccountBehavior b) => switch (b) {
      AccountBehavior.liquid => Icons.water_drop_rounded,
      AccountBehavior.invested => Icons.trending_up_rounded,
      AccountBehavior.debt => Icons.request_quote_rounded,
    };

class AccountTypesScreen extends ConsumerWidget {
  const AccountTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.accountTypesTitle),
        actions: [
          IconButton(
            tooltip: l.addAccountType,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _edit(context, ref, null),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          ListCard(
            children: [
              for (final t in data.accountTypes)
                ListTile(
                  leading: IconBadge(icon: behaviorIcon(t.behavior), color: _color(context, t.behavior)),
                  title: Text(t.name),
                  subtitle: Text(
                    '${behaviorLabel(l, t.behavior)} · ${l.typeInUse(data.accounts.where((a) => a.typeId == t.id).length)}',
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.fin.muted),
                  onTap: () => _edit(context, ref, t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          InfoNote(l.behaviorDebtHint),
        ],
      ),
    );
  }

  static Color _color(BuildContext context, AccountBehavior b) => switch (b) {
        AccountBehavior.liquid => context.fin.liquidLine,
        AccountBehavior.invested => context.fin.investedLine,
        AccountBehavior.debt => context.fin.debtLine,
      };

  Future<void> _edit(BuildContext context, WidgetRef ref, AccountType? type) =>
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _TypeSheet(type: type));
}

class _TypeSheet extends ConsumerStatefulWidget {
  const _TypeSheet({this.type});

  final AccountType? type;

  @override
  ConsumerState<_TypeSheet> createState() => _TypeSheetState();
}

class _TypeSheetState extends ConsumerState<_TypeSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.type?.name ?? '');
  late AccountBehavior _behavior = widget.type?.behavior ?? AccountBehavior.liquid;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(appDataProvider);
    final actions = ref.read(actionsProvider);
    final inUse = widget.type == null ? 0 : data.accounts.where((a) => a.typeId == widget.type!.id).length;

    String hint(AccountBehavior b) => switch (b) {
          AccountBehavior.liquid => l.behaviorLiquidHint,
          AccountBehavior.invested => l.behaviorInvestedHint,
          AccountBehavior.debt => l.behaviorDebtHint,
        };

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.type == null ? l.addAccountType : l.editAccountType,
                      style: context.text.titleLarge,
                    ),
                  ),
                  if (widget.type != null)
                    IconButton(
                      tooltip: inUse > 0 ? l.typeInUse(inUse) : l.delete,
                      icon: Icon(Icons.delete_outline_rounded, color: inUse > 0 ? context.fin.muted : context.fin.negative),
                      onPressed: inUse > 0
                          ? () => showSnack(context, l.typeInUse(inUse))
                          : () {
                              actions.deleteAccountType(widget.type!.id);
                              Navigator.pop(context);
                            },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                autofocus: widget.type == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.nameLabel),
                validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
              ),
              const SizedBox(height: 16),
              Text(l.behavior, style: context.text.titleSmall),
              const SizedBox(height: 8),
              for (final b in AccountBehavior.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    color: b == _behavior ? context.colors.primaryContainer : context.colors.surfaceContainerHigh,
                    padding: const EdgeInsets.all(14),
                    onTap: () => setState(() => _behavior = b),
                    child: Row(
                      children: [
                        Icon(behaviorIcon(b), color: AccountTypesScreen._color(context, b)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(behaviorLabel(l, b), style: context.text.titleSmall),
                              Text(hint(b), style: context.text.bodySmall),
                            ],
                          ),
                        ),
                        if (b == _behavior) Icon(Icons.check_circle_rounded, color: context.colors.primary),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  final base = widget.type ?? AccountType(id: newId(), name: '', behavior: _behavior);
                  actions.saveAccountType(base.copyWith(name: _name.text.trim(), behavior: _behavior));
                  Navigator.pop(context);
                },
                child: Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

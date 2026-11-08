import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ids.dart';
import '../../data/models.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/session.dart';
import '../accounts/account_edit_screen.dart';
import '../nav.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final categories = ref.watch(appDataProvider.select((d) => d.categories));

    Widget group(CategoryKind kind, String title) {
      final items = categories.where((c) => c.kind == kind).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title),
          ListCard(
            children: [
              for (final c in items)
                ListTile(
                  leading: IconBadge(icon: categoryIcon(c.icon), color: context.fin.chartColor(c.colorIndex)),
                  title: Text(c.name),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.fin.muted),
                  onTap: () => push(context, CategoryEditScreen(category: c)),
                ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.categoriesTitle),
        actions: [
          IconButton(
            tooltip: l.addCategory,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => push(context, const CategoryEditScreen()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [group(CategoryKind.expense, l.kindExpense), group(CategoryKind.income, l.kindIncome)],
      ),
    );
  }
}

class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late CategoryKind _kind;
  late String _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = TextEditingController(text: c?.name ?? '');
    _kind = c?.kind ?? CategoryKind.expense;
    _icon = c?.icon ?? 'other';
    _color = c?.colorIndex ?? ref.read(appDataProvider).categories.length;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final base = widget.category ??
        Category(id: newId(), name: '', icon: _icon, kind: _kind, colorIndex: _color);
    ref.read(actionsProvider).saveCategory(
          base.copyWith(name: _name.text.trim(), icon: _icon, kind: _kind, colorIndex: _color),
        );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final data = ref.read(appDataProvider);
    final id = widget.category!.id;
    final used = data.transactions.any((t) => t.categoryId == id) || data.recurring.any((r) => r.categoryId == id);
    final ok = await confirmDialog(
      context,
      title: l.deleteConfirmTitle,
      body: used ? l.categoryInUse : l.deleteConfirmBody,
    );
    if (ok && mounted) {
      ref.read(actionsProvider).deleteCategory(id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fin = context.fin;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? l.addCategory : l.editCategory),
        actions: [
          if (widget.category != null) IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: formPadding,
          children: [
            Center(child: IconBadge(icon: categoryIcon(_icon), color: fin.chartColor(_color), size: 72)),
            const SizedBox(height: 20),
            SegmentedButton<CategoryKind>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: CategoryKind.expense, label: Text(l.kindExpense)),
                ButtonSegment(value: CategoryKind.income, label: Text(l.kindIncome)),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              autofocus: widget.category == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.nameLabel),
              validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
            ),
            const SizedBox(height: 20),
            Text(l.icon, style: context.text.titleSmall),
            const SizedBox(height: 10),
            IconChoiceGrid(icons: categoryIcons, selected: _icon, onSelected: (k) => setState(() => _icon = k)),
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
                    child: Container(
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
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ],
        ),
      ),
    );
  }
}

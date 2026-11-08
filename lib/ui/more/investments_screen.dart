import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/ids.dart';
import '../../data/models.dart';
import '../../data/price_service.dart';
import '../../domain/investment_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

final priceServiceProvider = Provider<PriceService>((ref) => PriceService());

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  bool _loading = false;

  Future<void> _refresh() async {
    final l = AppLocalizations.of(context);
    final plan = ref.read(appDataProvider).investments;
    final service = ref.read(priceServiceProvider);
    final actions = ref.read(actionsProvider);
    setState(() => _loading = true);
    var updated = 0;
    for (final p in plan.positions) {
      if (p.isin.trim().isEmpty) continue;
      try {
        final price = await service.fetchLastPrice(p.isin);
        if (price != null) {
          actions.saveEtf(p.copyWith(onlinePrice: () => price, onlinePriceAt: () => DateTime.now()));
          updated++;
        }
      } catch (_) {
        // Network errors: keep the manual price.
      }
    }
    if (!mounted) return;
    setState(() => _loading = false);
    showSnack(context, updated > 0 ? l.pricesUpdated(updated) : l.pricesFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(appDataProvider);
    final plan = data.investments;
    final result = ref.watch(investmentResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.investmentsTitle),
        actions: [
          IconButton(
            tooltip: l.addEtf,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showEtfEditor(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          AppCard(
            onTap: () => _editPlan(context, ref, plan),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(l.investmentsSubtitle, trailing: Icon(Icons.edit_rounded, size: 18, color: context.fin.muted)),
                const SizedBox(height: 8),
                KeyValueRow(label: l.annualBudget, value: fmt.money(plan.annualBudget), emphasize: true),
                KeyValueRow(label: l.limitMarkup, value: fmt.percent(plan.limitMarkup)),
                KeyValueRow(label: l.feePerOrder, value: fmt.money(plan.feePerOrder)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (data.onlinePricesEnabled)
            OutlinedButton.icon(
              onPressed: _loading || plan.positions.isEmpty ? null : _refresh,
              icon: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded),
              label: Text(l.refreshPrices),
            )
          else
            InfoNote(l.onlineDisabledHint, icon: Icons.cloud_off_rounded),
          if (plan.positions.isEmpty) ...[
            const SizedBox(height: 14),
            AppCard(
              child: EmptyState(
                icon: Icons.candlestick_chart_rounded,
                title: l.noEtfs,
                action: FilledButton.icon(
                  onPressed: () => showEtfEditor(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.addEtf),
                ),
              ),
            ),
          ],
          for (var i = 0; i < result.rows.length; i++) ...[
            const SizedBox(height: 12),
            _EtfCard(row: result.rows[i], color: context.fin.chartColor(i)),
          ],
          if (plan.positions.isNotEmpty) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  KeyValueRow(label: l.sumShares, value: fmt.percent(result.shareSum)),
                  if (!result.sharesValid)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: context.fin.negative),
                          const SizedBox(width: 6),
                          Text(l.sharesInvalid, style: context.text.bodySmall?.copyWith(color: context.fin.negative)),
                        ],
                      ),
                    ),
                  KeyValueRow(label: l.wholeCost, value: fmt.money(result.totalWholeCost)),
                  KeyValueRow(
                    label: l.restWholeUnits,
                    value: fmt.money(result.rest),
                    emphasize: true,
                    hint: result.cheapest == null || result.rest <= 0 ? null : l.restHint(result.cheapest!.name),
                  ),
                  KeyValueRow(label: l.feesTotal(result.rows.where((r) => r.amount > 0).length), value: fmt.money(result.fees)),
                  KeyValueRow(label: l.feesShare, value: fmt.percent(result.feeShare)),
                ],
              ),
            ),
          ],
          SectionTitle(l.howToBuyTitle),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in [l.howToBuy1, l.howToBuy2, l.howToBuy3])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ', style: context.text.bodyMedium),
                        Expanded(child: Text(t, style: context.text.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlan(BuildContext context, WidgetRef ref, InvestmentPlan plan) =>
      showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _PlanSheet(plan: plan));
}

class _EtfCard extends ConsumerWidget {
  const _EtfCard({required this.row, required this.color});

  final EtfRow row;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final p = row.position;
    final source = switch (row.source) {
      PriceSource.online => l.priceSourceOnline(p.onlinePriceAt == null ? '' : fmt.dateShort(p.onlinePriceAt!)),
      PriceSource.manual => l.priceSourceManual,
      PriceSource.none => l.priceSourceNone,
    };
    String n(double? v, {int decimals = 2}) => v == null ? '—' : fmt.number(v, decimals: decimals);

    Widget cell(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.text.labelSmall),
              const SizedBox(height: 2),
              Text(value, style: money(context.text.titleSmall)),
            ],
          ),
        );

    return AppCard(
      onTap: () => showEtfEditor(context, ref, position: p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text([if (p.isin.isNotEmpty) p.isin, fmt.percent(p.share)].join(' · '), style: context.text.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Amount(fmt.money(row.amount), style: context.text.titleSmall),
                  Text(l.amountPerYear, style: context.text.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              cell(l.priceUsed, n(row.price, decimals: row.price != null && row.price! < 10 ? 3 : 2)),
              cell(l.limitPrice, n(row.limit, decimals: row.limit != null && row.limit! < 10 ? 3 : 2)),
              cell(l.wholeUnits, row.wholeUnits?.toString() ?? '—'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              cell(l.wholeCost, row.wholeCost == null ? '—' : fmt.money(row.wholeCost!)),
              cell(l.unitsByAmount, n(row.unitsByAmount, decimals: 3)),
              Expanded(
                child: Text(
                  source,
                  style: context.text.bodySmall?.copyWith(
                    color: row.source == PriceSource.none ? context.fin.negative : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showEtfEditor(BuildContext context, WidgetRef ref, {EtfPosition? position}) =>
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _EtfSheet(position: position));

class _PlanSheet extends ConsumerStatefulWidget {
  const _PlanSheet({required this.plan});

  final InvestmentPlan plan;

  @override
  ConsumerState<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends ConsumerState<_PlanSheet> {
  final _form = GlobalKey<FormState>();
  final _budget = TextEditingController();
  final _markup = TextEditingController();
  final _fee = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final fmt = Fmt.of(context);
    _budget.text = fmt.plain(widget.plan.annualBudget);
    _markup.text = fmt.plain(widget.plan.limitMarkup * 100);
    _fee.text = fmt.plain(widget.plan.feePerOrder);
  }

  @override
  void dispose() {
    _budget.dispose();
    _markup.dispose();
    _fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.investmentsSubtitle, style: context.text.titleLarge),
            const SizedBox(height: 16),
            NumberField(controller: _budget, label: l.annualBudget, autofocus: true),
            fieldGap,
            NumberField(controller: _markup, label: l.limitMarkup, suffix: '%'),
            fieldGap,
            NumberField(controller: _fee, label: l.feePerOrder),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                ref.read(actionsProvider).updateInvestments((p) => p.copyWith(
                      annualBudget: parseAmount(_budget.text) ?? 0,
                      limitMarkup: (parseAmount(_markup.text) ?? 0) / 100,
                      feePerOrder: parseAmount(_fee.text) ?? 0,
                    ));
                Navigator.pop(context);
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtfSheet extends ConsumerStatefulWidget {
  const _EtfSheet({this.position});

  final EtfPosition? position;

  @override
  ConsumerState<_EtfSheet> createState() => _EtfSheetState();
}

class _EtfSheetState extends ConsumerState<_EtfSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _isin = TextEditingController();
  final _share = TextEditingController();
  final _price = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final fmt = Fmt.of(context);
    final p = widget.position;
    if (p == null) return;
    _name.text = p.name;
    _isin.text = p.isin;
    _share.text = fmt.plain(p.share * 100);
    if (p.manualPrice != null) _price.text = fmt.plain(p.manualPrice!);
  }

  @override
  void dispose() {
    _name.dispose();
    _isin.dispose();
    _share.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final position = widget.position;
    final actions = ref.read(actionsProvider);
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
                  Expanded(child: Text(position == null ? l.addEtf : l.editEtf, style: context.text.titleLarge)),
                  if (position != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: context.fin.negative),
                      onPressed: () async {
                        final ok = await confirmDialog(context, title: l.deleteConfirmTitle, body: l.deleteConfirmBody);
                        if (ok && context.mounted) {
                          actions.deleteEtf(position.id);
                          Navigator.pop(context);
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                autofocus: position == null,
                decoration: InputDecoration(labelText: l.nameLabel),
                validator: (v) => (v ?? '').trim().isEmpty ? l.requiredField : null,
              ),
              fieldGap,
              TextFormField(
                controller: _isin,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l.isin),
              ),
              fieldGap,
              Row(
                children: [
                  Expanded(child: NumberField(controller: _share, label: l.etfShare, suffix: '%', required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: NumberField(controller: _price, label: l.manualPrice)),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  final manual = parseAmount(_price.text);
                  final base = position ?? EtfPosition(id: newId(), name: '');
                  actions.saveEtf(base.copyWith(
                    name: _name.text.trim(),
                    isin: _isin.text.trim().toUpperCase(),
                    share: (parseAmount(_share.text) ?? 0) / 100,
                    manualPrice: () => manual == null || manual <= 0 ? null : manual,
                  ));
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

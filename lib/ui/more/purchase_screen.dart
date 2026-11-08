import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/purchase_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/actions.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  late PurchaseInputs _inputs;
  // Captured up front: ref must not be used in dispose().
  late final DataActions _actions;
  final _c = <String, TextEditingController>{};
  Timer? _debounce;
  bool _initialized = false;

  static const _fields = [
    'label',
    'price',
    'fromSavings',
    'loanRate',
    'loanMonths',
    'monthlyCost',
    'usageYears',
    'residualValue',
    'expectedReturn',
    'emergencyFund',
    'targetSavingsRate',
  ];

  @override
  void initState() {
    super.initState();
    _inputs = ref.read(appDataProvider).purchase;
    _actions = ref.read(actionsProvider);
    for (final f in _fields) {
      _c[f] = TextEditingController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _fill(_inputs);
  }

  void _fill(PurchaseInputs i) {
    final fmt = Fmt.of(context);
    String n(num v) => v == 0 ? '' : fmt.plain(v.toDouble());
    _c['label']!.text = i.label;
    _c['price']!.text = n(i.price);
    _c['fromSavings']!.text = n(i.fromSavings);
    _c['loanRate']!.text = n(i.loanRate * 100);
    _c['loanMonths']!.text = n(i.loanMonths);
    _c['monthlyCost']!.text = n(i.monthlyCost);
    _c['usageYears']!.text = n(i.usageYears);
    _c['residualValue']!.text = n(i.residualValue);
    _c['expectedReturn']!.text = n(i.expectedReturn * 100);
    _c['emergencyFund']!.text = n(i.emergencyFund);
    _c['targetSavingsRate']!.text = n(i.targetSavingsRate * 100);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Providers must not change during unmount – save right after.
    final inputs = _inputs;
    final actions = _actions;
    Future.microtask(() => actions.updatePurchase((_) => inputs));
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _persist() => _actions.updatePurchase((_) => _inputs);

  void _changed() {
    double d(String f) => parseAmount(_c[f]!.text) ?? 0;
    int i(String f) => d(f).round();
    setState(() {
      _inputs = PurchaseInputs(
        label: _c['label']!.text.trim(),
        price: d('price'),
        fromSavings: d('fromSavings'),
        loanRate: d('loanRate') / 100,
        loanMonths: i('loanMonths'),
        monthlyCost: d('monthlyCost'),
        usageYears: i('usageYears'),
        residualValue: d('residualValue'),
        expectedReturn: d('expectedReturn') / 100,
        emergencyFund: d('emergencyFund'),
        targetSavingsRate: d('targetSavingsRate') / 100,
      );
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _persist);
  }

  void _reset() {
    setState(() => _inputs = const PurchaseInputs());
    _fill(_inputs);
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final s = ref.watch(financialSituationProvider);
    final r = calculatePurchase(_inputs, s);
    final fin = context.fin;

    Widget field(String key, String label, {String? suffix = '€', String? helper, bool integer = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NumberField(
            controller: _c[key]!,
            label: label,
            suffix: suffix,
            helper: helper,
            integer: integer,
            onChanged: (_) => _changed(),
          ),
        );

    final (verdictText, verdictColor, verdictIcon) = switch (r.verdict) {
      PurchaseVerdict.belowEmergencyFund => (l.verdictBelowEmergency, fin.negative, Icons.warning_amber_rounded),
      PurchaseVerdict.costsExceedFree => (l.verdictCostsExceed, fin.negative, Icons.warning_amber_rounded),
      PurchaseVerdict.savingsRateDrops => (l.verdictRateDrops, fin.accent, Icons.info_outline_rounded),
      PurchaseVerdict.largeShareOfWealth => (l.verdictLargeShare, fin.accent, Icons.info_outline_rounded),
      PurchaseVerdict.affordable => (l.verdictAffordable, fin.positive, Icons.check_circle_outline_rounded),
    };

    String months(double? v) => v == null ? '—' : fmt.number(v, decimals: 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.purchaseTitle),
        actions: [
          IconButton(tooltip: l.purchaseReset, icon: const Icon(Icons.restart_alt_rounded), onPressed: _reset),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // Verdict first – it is what you came for.
          AppCard(
            color: verdictColor.withValues(alpha: 0.12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(verdictIcon, color: verdictColor),
                    const SizedBox(width: 10),
                    Text(l.verdictTitle, style: context.text.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                Text(verdictText, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                if (_inputs.price > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.verdictSummary(
                      _inputs.label.isEmpty ? l.thePurchase : _inputs.label,
                      fmt.moneyRound(r.costPerMonth),
                      fmt.number(r.monthsOfSavingsLost ?? 0, decimals: 1),
                    ),
                    style: context.text.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionPurchase),
          AppCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _c['label'],
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l.purchaseLabel, hintText: l.purchaseLabelHint),
                    onChanged: (_) => _changed(),
                  ),
                ),
                field('price', l.purchasePrice),
                field('fromSavings', l.purchaseFromSavings),
                field('loanRate', l.purchaseLoanRate, suffix: '%'),
                field('loanMonths', l.purchaseLoanMonths, suffix: null, integer: true),
                field('monthlyCost', l.purchaseMonthlyCost, helper: l.purchaseMonthlyCostHint),
                field('usageYears', l.purchaseUsageYears, suffix: null, integer: true),
                field('residualValue', l.purchaseResidual, helper: l.purchaseResidualHint),
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionAssumptions),
          AppCard(
            child: Column(
              children: [
                field('expectedReturn', l.purchaseReturn, suffix: '%'),
                field('emergencyFund', l.purchaseEmergency),
                field('targetSavingsRate', l.purchaseTargetRate, suffix: '%'),
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionSituation),
          AppCard(
            child: Column(
              children: [
                KeyValueRow(label: l.cardNetWorth, value: fmt.money(s.netWorth)),
                KeyValueRow(label: l.liquid, value: fmt.money(s.liquid)),
                KeyValueRow(label: l.monthlyIncome, value: fmt.money(s.monthlyIncome)),
                KeyValueRow(label: l.monthlyFixed, value: fmt.money(s.monthlyFixedExpenses)),
                KeyValueRow(label: l.monthlySavings, value: fmt.money(s.monthlySavings)),
                KeyValueRow(label: l.monthlyFree, value: fmt.money(s.monthlyFree)),
                KeyValueRow(label: l.currentRate, value: fmt.percent(s.savingsRate)),
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionImmediate),
          AppCard(
            child: Column(
              children: [
                KeyValueRow(label: l.loanAmount, value: fmt.money(r.loanAmount)),
                KeyValueRow(label: l.loanPayment, value: fmt.money(r.loanPayment)),
                KeyValueRow(label: l.interestTotal, value: fmt.money(r.interestTotal)),
                KeyValueRow(
                  label: l.liquidAfter,
                  value: fmt.money(r.liquidAfter),
                  amount: r.liquidAfter - _inputs.emergencyFund,
                  colored: r.liquidAfter < _inputs.emergencyFund,
                ),
                KeyValueRow(label: l.shareOfWealth, value: fmt.percent(r.shareOfWealth)),
                KeyValueRow(label: l.monthsLost, value: months(r.monthsOfSavingsLost)),
                KeyValueRow(label: l.monthsToSave, value: months(r.monthsToSaveUp)),
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionMonthly),
          AppCard(
            child: Column(
              children: [
                KeyValueRow(label: l.extraMonthly, value: fmt.money(r.extraMonthly)),
                KeyValueRow(label: l.freeAfter, value: fmt.money(r.freeAfter), amount: r.freeAfter, colored: true),
                KeyValueRow(label: l.rateAfter, value: fmt.percent(r.savingsRateAfter)),
              ],
            ),
          ),
          SectionTitle(l.purchaseSectionUsage),
          AppCard(
            child: Column(
              children: [
                KeyValueRow(label: l.totalCost, value: fmt.money(r.totalCost)),
                KeyValueRow(label: l.costPerMonth, value: fmt.money(r.costPerMonth), emphasize: true),
                KeyValueRow(label: l.remainingDebt, value: fmt.money(r.remainingDebt)),
                KeyValueRow(label: l.wealthDisadvantage, value: fmt.money(r.wealthDisadvantage), emphasize: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoNote(l.purchaseDisclaimer),
        ],
      ),
    );
  }
}

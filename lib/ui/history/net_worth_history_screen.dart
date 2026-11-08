import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import '../../domain/chart_range.dart';
import '../../domain/overview_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import '../widgets/range_selector.dart';

/// One selectable line of the history chart.
class _Line {
  const _Line(this.key, this.label, this.color, this.value);

  final String key;
  final String label;
  final Color color;
  final double Function(BalanceRow row) value;
}

/// Net worth and every account over time, with selectable lines and windows.
class NetWorthHistoryScreen extends ConsumerStatefulWidget {
  const NetWorthHistoryScreen({super.key, this.initialAccountId});

  /// Opens with this account's line instead of the total.
  final String? initialAccountId;

  @override
  ConsumerState<NetWorthHistoryScreen> createState() => _NetWorthHistoryScreenState();
}

class _NetWorthHistoryScreenState extends ConsumerState<NetWorthHistoryScreen> {
  static const _total = 'total';
  late final Set<String> _selected = {
    widget.initialAccountId == null ? _total : 'account:${widget.initialAccountId}',
  };

  List<_Line> _lines(AppData data, List<BalanceRow> rows) {
    final l = AppLocalizations.of(context);
    final fin = context.fin;
    return [
      _Line(_total, l.total, fin.totalLine, (r) => r.total),
      _Line('liquid', l.liquid, fin.liquidLine, (r) => r.liquid),
      _Line('invested', l.invested, fin.investedLine, (r) => r.invested),
      if (rows.any((r) => r.debt > 0)) _Line('debt', l.debts, fin.debtLine, (r) => -r.debt),
      for (final a in data.accounts)
        if (!a.archived || rows.any((r) => r.snapshot.values.containsKey(a.id)))
          _Line(
            'account:${a.id}',
            a.name,
            fin.chartColor(a.colorIndex),
            data.behaviorOf(a) == AccountBehavior.debt ? (r) => -r.balanceOf(a.id) : (r) => r.balanceOf(a.id),
          ),
    ];
  }

  void _toggle(String key) => setState(() {
        if (_selected.contains(key)) {
          if (_selected.length > 1) _selected.remove(key);
        } else {
          _selected.add(key);
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final fin = context.fin;
    final data = ref.watch(appDataProvider);
    final rows = ref.watch(balanceHistoryProvider);
    final today = ref.watch(todayProvider);
    final range = ref.watch(chartRangeProvider);

    final lines = _lines(data, rows);
    final shown = lines.where((x) => _selected.contains(x.key)).toList();
    if (shown.isEmpty) shown.add(lines.first);
    final points = {for (final x in shown) x.key: rangeSeries(rows, range, today, x.value)};
    final primary = shown.first;
    final primaryPoints = points[primary.key]!;
    final change = seriesChange(primaryPoints);

    String changeText(({double absolute, double? relative}) c) => c.relative == null
        ? fmt.signedMoney(c.absolute)
        : '${fmt.signedMoney(c.absolute)} · ${fmt.percent(c.relative!.abs())}';

    return Scaffold(
      appBar: AppBar(title: Text(l.cardChart)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(primary.label),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Amount(
                    fmt.money(primaryPoints.isEmpty ? 0 : primaryPoints.last.$2),
                    style: context.text.displaySmall,
                  ),
                ),
                const SizedBox(height: 10),
                DeltaChip(text: changeText(change), value: change.absolute, label: l.inRange),
                const SizedBox(height: 18),
                RangeSelector(value: range, onChanged: ref.read(chartRangeProvider.notifier).select),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
            child: rows.length < 2
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l.chartNeedTwo, style: context.text.bodyMedium?.copyWith(color: fin.muted)),
                  )
                : TimeLineChart(
                    height: 300,
                    series: [
                      for (final x in shown)
                        ChartSeries(label: x.label, color: x.color, fill: shown.length == 1, points: points[x.key]!),
                    ],
                  ),
          ),
          if (shown.length > 1) ...[
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  for (final x in shown)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: LegendDot(color: x.color, label: x.label)),
                          Builder(builder: (context) {
                            final p = points[x.key]!;
                            final c = seriesChange(p);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Amount(fmt.money(p.isEmpty ? 0 : p.last.$2), style: context.text.titleSmall),
                                Amount(changeText(c), value: c.absolute, colored: true, style: context.text.bodySmall),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          SectionTitle(l.historyLines),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final x in lines)
                FilterChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selected: _selected.contains(x.key),
                  onSelected: (_) => _toggle(x.key),
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: x.color, shape: BoxShape.circle),
                  ),
                  label: Text(x.label),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

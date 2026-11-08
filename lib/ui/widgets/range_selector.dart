import 'package:flutter/material.dart';

import '../../domain/chart_range.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';

String rangeLabel(AppLocalizations l, ChartRange r) => switch (r) {
      ChartRange.all => l.chartAll,
      ChartRange.year => l.chartYear,
      ChartRange.sixMonths => l.rangeSixMonths,
      ChartRange.threeMonths => l.rangeThreeMonths,
      ChartRange.month => l.rangeMonth,
      ChartRange.week => l.rangeWeek,
      ChartRange.day => l.rangeDay,
    };

/// Compact pill row: Alle · 1J · 6M · 3M · 1M · 1W · 1T.
class RangeSelector extends StatelessWidget {
  const RangeSelector({super.key, required this.value, required this.onChanged});

  final ChartRange value;
  final ValueChanged<ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final r in ChartRange.values)
            Expanded(
              child: Semantics(
                selected: r == value,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: r == value ? context.colors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: r == value ? context.fin.cardShadow : null,
                    ),
                    child: Text(
                      rangeLabel(l, r),
                      style: context.text.labelMedium?.copyWith(
                        color: r == value ? context.colors.onSurface : context.fin.muted,
                        fontWeight: r == value ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

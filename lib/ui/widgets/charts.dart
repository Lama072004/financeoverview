import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/ticks.dart';
import '../theme/app_theme.dart';

class DonutSegment {
  const DonutSegment(this.value, this.color);

  final double value;
  final Color color;
}

/// Ring chart with a widget in the middle.
class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.segments, required this.size, this.thickness, this.center});

  final List<DonutSegment> segments;
  final double size;
  final double? thickness;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final ring = thickness ?? size * 0.14;
    final visible = segments.where((s) => s.value > 0).toList();
    final sections = visible.isEmpty
        ? [PieChartSectionData(value: 1, color: context.fin.track, radius: ring, showTitle: false)]
        : [
            for (final s in visible)
              PieChartSectionData(value: s.value, color: s.color, radius: ring, showTitle: false),
          ];
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: size / 2 - ring,
              sectionsSpace: visible.length > 1 ? 2.5 : 0,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(enabled: false),
              borderData: FlBorderData(show: false),
            ),
            duration: const Duration(milliseconds: 350),
          ),
          if (center != null) Padding(padding: EdgeInsets.all(ring + 6), child: center),
        ],
      ),
    );
  }
}

class ChartSeries {
  const ChartSeries({
    required this.label,
    required this.color,
    required this.points,
    this.fill = false,
    this.dashed = false,
  });

  final String label;
  final Color color;
  final List<(DateTime, double)> points;
  final bool fill;

  /// For projected values.
  final bool dashed;
}

/// Line chart over time with touch tooltips.
class TimeLineChart extends StatelessWidget {
  const TimeLineChart({super.key, required this.series, this.height = 200, this.showAxes = true});

  final List<ChartSeries> series;
  final double height;
  final bool showAxes;

  static double _x(DateTime d) => DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch / 86400000;

  static DateTime _date(double x) {
    final d = DateTime.fromMillisecondsSinceEpoch((x * 86400000).round(), isUtc: true);
    return DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final all = series.expand((s) => s.points).toList();
    if (all.isEmpty) return SizedBox(height: height);

    final lo = all.map((p) => p.$2).reduce(math.min);
    final hi = all.map((p) => p.$2).reduce(math.max);
    final pad = math.max(hi - lo, 1) * 0.08;
    // Round axis values; a line that never goes negative starts at zero at most.
    final ticks = niceTicks(lo >= 0 ? math.max(0, lo - pad) : lo - pad, hi + pad, count: 3);
    final minY = ticks.first;
    final maxY = ticks.last;

    final minX = all.map((p) => _x(p.$1)).reduce(math.min);
    var maxX = all.map((p) => _x(p.$1)).reduce(math.max);
    if (maxX == minX) maxX = minX + 1;
    final span = maxX - minX;
    // Day ticks for short windows (1T, 1W, 1M), otherwise four intervals.
    final xInterval = span <= 1.5 ? 1.0 : (span <= 8 ? 2.0 : (span <= 35 ? 7.0 : span / 4));
    final yInterval = ticks[1] - ticks[0];

    final labelStyle = context.text.labelSmall?.copyWith(fontWeight: FontWeight.w500);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: showAxes,
            drawVerticalLine: false,
            horizontalInterval: yInterval <= 0 ? null : yInterval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: context.colors.outline, strokeWidth: 1, dashArray: const [4, 4]),
          ),
          titlesData: FlTitlesData(
            show: showAxes,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: yInterval < 1000 ? 48 : 40,
                interval: yInterval <= 0 ? null : yInterval,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                  // Short windows move only a little – "28k" three times says nothing.
                  final text = fmt.axis(value, fine: yInterval < 1000);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(text, style: labelStyle, textAlign: TextAlign.right, maxLines: 1),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: xInterval,
                getTitlesWidget: (value, meta) {
                  // A one-day window only has its two edges. Otherwise edge labels
                  // collide with the regular ticks – keep only interior ones.
                  final edge = value - meta.min < xInterval * 0.5 || meta.max - value < xInterval * 0.5;
                  if (edge && span > 1.5) return const SizedBox.shrink();
                  final d = _date(value);
                  final text = span > 1500
                      ? '${d.year}'
                      : (span > 300 ? '${fmt.monthShort(d)} ${d.year % 100}' : fmt.dayMonth(d));
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                    child: Text(text, style: labelStyle),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.colors.inverseSurface,
              tooltipBorderRadius: BorderRadius.circular(12),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              maxContentWidth: 200,
              getTooltipItems: (spots) => [
                for (var i = 0; i < spots.length; i++)
                  LineTooltipItem(
                    i == 0 ? '${fmt.date(_date(spots[i].x))}\n' : '',
                    TextStyle(color: context.colors.onInverseSurface.withValues(alpha: 0.7), fontSize: 11),
                    textAlign: TextAlign.left,
                    children: [
                      TextSpan(
                        text: '${series[spots[i].barIndex].label}: ${fmt.money(spots[i].y)}',
                        style: money(TextStyle(
                          color: context.colors.onInverseSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        )),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (final s in series)
              LineChartBarData(
                spots: [for (final p in s.points) FlSpot(_x(p.$1), p.$2)],
                color: s.color,
                barWidth: s.fill ? 3 : 2.2,
                dashArray: s.dashed ? const [6, 5] : null,
                isCurved: s.points.length > 2,
                curveSmoothness: 0.25,
                preventCurveOverShooting: true,
                isStrokeCapRound: true,
                dotData: FlDotData(show: s.points.length <= 2),
                belowBarData: BarAreaData(
                  show: s.fill,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [s.color.withValues(alpha: 0.22), s.color.withValues(alpha: 0.0)],
                  ),
                ),
              ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

}

class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: context.text.labelMedium),
        ],
      );
}

/// One bar per period (months of a year, years); red only below zero.
class PeriodBarChart extends StatelessWidget {
  const PeriodBarChart({super.key, required this.bars, this.height = 180, this.onTap});

  final List<({String label, String tooltip, double value})> bars;
  final double height;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final fmt = Fmt.of(context);
    final fin = context.fin;
    if (bars.isEmpty) return SizedBox(height: height);
    final hi = bars.map((b) => b.value).fold(0.0, math.max);
    final lo = bars.map((b) => b.value).fold(0.0, math.min);
    final ticks = niceTicks(lo * 1.05, hi * 1.05, count: 3);
    final minY = ticks.first;
    final maxY = ticks.last;
    final interval = ticks[1] - ticks[0];
    final width = math.min(26.0, 150.0 / bars.length + 6);
    final labelStyle = context.text.labelSmall?.copyWith(fontWeight: FontWeight.w500);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (v) => FlLine(
              color: v.abs() < interval * 0.01 ? context.fin.muted.withValues(alpha: 0.5) : context.colors.outline,
              strokeWidth: 1,
              dashArray: v.abs() < interval * 0.01 ? null : const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: interval < 1000 ? 48 : 40,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      fmt.axis(value, fine: interval < 1000),
                      style: labelStyle,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(bars[value.toInt()].label, style: labelStyle),
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchCallback: onTap == null
                ? null
                : (event, response) {
                    final spot = response?.spot;
                    if (event is FlTapUpEvent && spot != null) onTap!(spot.touchedBarGroupIndex);
                  },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.colors.inverseSurface,
              tooltipBorderRadius: BorderRadius.circular(12),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${bars[group.x].tooltip}\n',
                TextStyle(color: context.colors.onInverseSurface.withValues(alpha: 0.7), fontSize: 11),
                children: [
                  TextSpan(
                    text: fmt.signedMoney(rod.toY),
                    style: money(TextStyle(
                      color: context.colors.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    )),
                  ),
                ],
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < bars.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: bars[i].value,
                    width: width,
                    color: bars[i].value < 0 ? fin.negative : fin.positive,
                    borderRadius: BorderRadius.circular(math.min(6, width / 3)),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}

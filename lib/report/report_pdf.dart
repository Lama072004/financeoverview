import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/dates.dart';
import '../core/format.dart';
import '../core/ticks.dart';
import '../data/models.dart';
import '../domain/overview_calc.dart';
import '../domain/projection_calc.dart';
import '../domain/recurring_calc.dart';
import '../domain/review_calc.dart';
import '../domain/savings_goal_calc.dart';
import '../l10n/gen/app_localizations.dart';

class ReportFonts {
  const ReportFonts({required this.regular, required this.semiBold, required this.bold});

  final pw.Font regular;
  final pw.Font semiBold;
  final pw.Font bold;
}

/// Everything a report is made of.
class ReportRequest {
  const ReportRequest({
    required this.input,
    required this.year,
    required this.l,
    required this.fmt,
    required this.generatedAt,
    required this.appVersion,
    required this.projection,
    required this.goal,
    required this.forecasts,
  });

  final ReviewInput input;

  /// null = from the first entry until today.
  final int? year;
  final AppLocalizations l;

  /// Must not be in discreet mode – the report shows the real amounts.
  final Fmt fmt;
  final DateTime generatedAt;
  final String appVersion;
  final Projection projection;
  final SavingsGoalStatus goal;
  final Map<String?, GoalForecast> forecasts;
}

String reportFileName(int? year, DateTime now) =>
    year == null ? 'Finanzbericht-gesamt-${encodeDate(now)}.pdf' : 'Finanzbericht-$year.pdf';

// Light theme of the app.
const _ink = PdfColor.fromInt(0xFF1E2320);
const _muted = PdfColor.fromInt(0xFF6B736C);
const _primary = PdfColor.fromInt(0xFF56665A);
const _tile = PdfColor.fromInt(0xFF4E5D52);
const _mist = PdfColor.fromInt(0xFFE1E6DE);
const _cream = PdfColor.fromInt(0xFFF7F3EA);
const _line = PdfColor.fromInt(0xFFE4DED2);
const _track = PdfColor.fromInt(0xFFECE6DA);
const _accent = PdfColor.fromInt(0xFFE09E2D);
const _positive = PdfColor.fromInt(0xFF6F6C00);
const _positiveBar = PdfColor.fromInt(0xFFAFAC08);
const _negative = PdfColor.fromInt(0xFF960513);
const _chart = [
  PdfColor.fromInt(0xFF9EA79D),
  PdfColor.fromInt(0xFFE09E2D),
  PdfColor.fromInt(0xFFAFAC08),
  PdfColor.fromInt(0xFF56665A),
  PdfColor.fromInt(0xFFF0C877),
  PdfColor.fromInt(0xFF7E7C06),
  PdfColor.fromInt(0xFFC6CEC4),
  PdfColor.fromInt(0xFFB8761A),
  PdfColor.fromInt(0xFFD6D36B),
  PdfColor.fromInt(0xFF3F4A42),
];

const _margin = 36.0;
final _contentWidth = PdfPageFormat.a4.width - 2 * _margin;

Future<Uint8List> buildReportPdf(ReportRequest r, ReportFonts fonts) {
  final l = r.l;
  final fmt = r.fmt;
  final input = r.input;
  final review = r.year == null ? reviewAll(input) : reviewYear(input, r.year!);
  final buckets = r.year == null ? allYears(input) : monthsOfYear(input, r.year!);
  final title = r.year == null ? l.reportTitleAll : l.reportTitleYear(r.year!);
  final generated = '${fmt.date(r.generatedAt)}, ${fmt.time(r.generatedAt)}';

  final doc = pw.Document(
    title: title,
    author: l.appTitle,
    creator: '${l.appTitle} ${r.appVersion}',
    theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
  );
  final s = _Styles(fonts);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(_margin, _margin, _margin, 28),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold).copyWith(defaultTextStyle: s.body),
      ),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              padding: const pw.EdgeInsets.only(bottom: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _line, width: .8)),
              ),
              child: pw.Row(children: [pw.Text('${l.appTitle} · $title', style: s.small)]),
            ),
      footer: (context) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(l.reportFooter(generated), style: s.small),
            pw.Text(l.reportPage(context.pageNumber, context.pagesCount), style: s.small),
          ],
        ),
      ),
      build: (context) => [
        _header(r, s, title, review),
        pw.SizedBox(height: 16),
        if (!review.hasFlow)
          pw.Text(l.reportNoFlow, style: s.body)
        else ...[
          _kpis(r, s, review),
          pw.SizedBox(height: 18),
          _section(s, l.reportChartTitle),
          _netWorthChart(r, s, review),
          pw.SizedBox(height: 6),
          _legend(s, [
            (_primary, l.cardNetWorth),
            (_accent, l.liquid),
            (_positiveBar, l.invested),
            if (review.to!.debt > 0 || review.from!.debt > 0) (_negative, l.debts),
          ]),
          if (buckets.where((b) => b.hasFlow).length > 1) ...[
            pw.SizedBox(height: 18),
            _section(s, r.year == null ? l.reviewPerYear : l.reviewPerMonth),
            _barChart(r, s, buckets),
          ],
        ],
        pw.SizedBox(height: 18),
        _section(s, r.year == null ? l.reportYearsTable : l.reportMonthsTable),
        _bucketTable(r, s, buckets, review, years: r.year == null),
        if (r.year == null && buckets.length > 1) ...[
          pw.SizedBox(height: 18),
          _section(s, l.reportMonthsTable),
          _bucketTable(
            r,
            s,
            [for (final y in buckets) ...monthsOfYear(input, y.start.year)].where((m) => m.hasData).toList(),
            null,
            years: false,
            withYear: true,
          ),
        ],
        pw.SizedBox(height: 18),
        _section(s, l.cardAccounts),
        _accountsTable(r, s, review),
        pw.SizedBox(height: 18),
        _section(s, l.reviewSpending),
        _spendingTable(r, s, review),
        pw.SizedBox(height: 18),
        _section(s, l.reportPlanTitle),
        _planTable(r, s),
        pw.SizedBox(height: 18),
        _section(s, l.reportOutlookTitle),
        _outlook(r, s),
        pw.SizedBox(height: 18),
        pw.Text(l.reportNotes, style: s.small),
      ],
    ),
  );
  return doc.save();
}

class _Styles {
  _Styles(ReportFonts f)
    : body = pw.TextStyle(font: f.regular, fontSize: 9, color: _ink, lineSpacing: 1.5),
      small = pw.TextStyle(font: f.regular, fontSize: 7.5, color: _muted),
      label = pw.TextStyle(font: f.semiBold, fontSize: 8, color: _muted),
      strong = pw.TextStyle(font: f.semiBold, fontSize: 9, color: _ink),
      section = pw.TextStyle(font: f.bold, fontSize: 12.5, color: _ink),
      kpi = pw.TextStyle(font: f.bold, fontSize: 15, color: _ink),
      title = pw.TextStyle(font: f.bold, fontSize: 22, color: PdfColors.white),
      axis = pw.TextStyle(font: f.regular, fontSize: 7, color: _muted);

  final pw.TextStyle body;
  final pw.TextStyle small;
  final pw.TextStyle label;
  final pw.TextStyle strong;
  final pw.TextStyle section;
  final pw.TextStyle kpi;
  final pw.TextStyle title;
  final pw.TextStyle axis;
}

PdfColor _signColor(double v) => v > 0.004 ? _positive : (v < -0.004 ? _negative : _ink);

pw.Widget _section(_Styles s, String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 8),
  child: pw.Text(text, style: s.section),
);

// -- Header -------------------------------------------------------------------

pw.Widget _header(ReportRequest r, _Styles s, String title, PeriodReview review) {
  final fmt = r.fmt;
  final l = r.l;
  final period = '${fmt.date(review.start)} – ${fmt.date(review.end)}';
  return pw.Container(
    padding: const pw.EdgeInsets.all(18),
    decoration: const pw.BoxDecoration(color: _tile, borderRadius: pw.BorderRadius.all(pw.Radius.circular(14))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.CustomPaint(size: const PdfPoint(46, 46), painter: _paintMark),
        pw.SizedBox(width: 14),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l.appTitle, style: s.label.copyWith(color: _mist)),
              pw.SizedBox(height: 2),
              pw.Text(title, style: s.title),
              pw.SizedBox(height: 3),
              pw.Text(l.reportPeriod(period), style: s.body.copyWith(color: _mist)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// The app's donut mark (white, cream yellow, green yellow) on transparent.
void _paintMark(PdfGraphics canvas, PdfPoint size) {
  final c = size.x / 2;
  final radius = size.x * 0.3;
  canvas
    ..setLineWidth(size.x * 0.15)
    ..setLineCap(PdfLineCap.round);
  for (final (color, start, sweep) in const [
    (_cream, -90.0, 150.0),
    (_accent, 96.0, 72.0),
    (PdfColor.fromInt(0xFFC9C52C), 204.0, 30.0),
  ]) {
    canvas.setStrokeColor(color);
    // Clockwise like on screen; PDF's y axis points up.
    for (var i = 0; i <= 30; i++) {
      final a = (start + sweep * i / 30) * math.pi / 180;
      final x = c + radius * math.cos(a), y = c - radius * math.sin(a);
      i == 0 ? canvas.moveTo(x, y) : canvas.lineTo(x, y);
    }
    canvas.strokePath();
  }
}

// -- Key figures ----------------------------------------------------------------

pw.Widget _kpis(ReportRequest r, _Styles s, PeriodReview review) {
  final fmt = r.fmt;
  final l = r.l;
  final rel = review.relativeChange;
  final rate = review.savingsRate;
  final planned = review.plannedSavingsRate;

  pw.Widget box(String label, String value, {PdfColor? color, required String sub}) => pw.Expanded(
    child: pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const pw.BoxDecoration(color: _cream, borderRadius: pw.BorderRadius.all(pw.Radius.circular(10))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: s.label),
          pw.SizedBox(height: 4),
          pw.Text(value, style: s.kpi.copyWith(color: color ?? _ink)),
          pw.SizedBox(height: 2),
          pw.Text(sub, style: s.small, maxLines: 1),
        ],
      ),
    ),
  );

  return pw.Column(
    children: [
      pw.Row(
        children: [
          box(
            l.reportNetWorthAt(fmt.date(review.to!.date)),
            fmt.money(review.to!.total),
            sub: l.reportStartValue(fmt.date(review.from!.date), fmt.money(review.from!.total)),
          ),
          box(
            l.reportGrowth,
            fmt.signedMoney(review.change),
            color: _signColor(review.change),
            sub: rel == null ? l.reviewChange : '${fmt.percent(rel)} ${l.reviewChange}',
          ),
          box(
            l.reviewSavingsRate,
            rate == null ? '—' : fmt.percent(rate),
            sub: planned == null ? l.reportNoPlan : l.reportPlannedRate(fmt.percent(planned)),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          box(
            l.reportKpiSaved,
            fmt.signedMoney(review.saved),
            color: _signColor(review.saved),
            sub: l.reportKpiSavedHint,
          ),
          box(
            l.reportKpiReturn,
            fmt.signedMoney(review.investmentReturn),
            color: _signColor(review.investmentReturn),
            sub: l.reportEstimated,
          ),
          box(l.reportKpiVariable, fmt.money(review.variableExpenses), sub: l.reportEstimated),
        ],
      ),
    ],
  );
}

pw.Widget _legend(_Styles s, List<(PdfColor, String)> items) => pw.Wrap(
  spacing: 14,
  children: [
    for (final (color, label) in items)
      pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
          ),
          pw.SizedBox(width: 5),
          pw.Text(label, style: s.small.copyWith(color: _ink)),
        ],
      ),
  ],
);

// -- Charts -------------------------------------------------------------------

class _Plot {
  _Plot({required this.height, required this.minY, required this.maxY, required this.left});

  static const bottom = 16.0;
  static const top = 6.0;
  static const right = 4.0;

  final double height;
  final double minY;
  final double maxY;
  final double left;

  double get width => _contentWidth;
  double get plotWidth => width - left - right;
  double get plotHeight => height - bottom - top;

  /// Painter y (from the bottom).
  double y(double v) => bottom + (v - minY) / (maxY - minY) * plotHeight;
}

String _axisLabel(Fmt fmt, double v, double step) => step < 1000 ? fmt.number(v, decimals: 0) : fmt.compact(v);

pw.Widget _yLabels(_Plot p, _Styles s, Fmt fmt, List<double> ticks) {
  final step = ticks.length > 1 ? ticks[1] - ticks[0] : 1000.0;
  return pw.Stack(
    children: [
      for (final t in ticks)
        pw.Positioned(
          left: 0,
          top: p.height - p.y(t) - 4,
          child: pw.SizedBox(
            width: p.left - 6,
            child: pw.Text(_axisLabel(fmt, t, step), style: s.axis, textAlign: pw.TextAlign.right),
          ),
        ),
    ],
  );
}

void _paintGrid(PdfGraphics canvas, _Plot p, List<double> ticks) {
  canvas
    ..setStrokeColor(_line)
    ..setLineWidth(.6)
    ..setLineDashPattern([2, 2]);
  for (final t in ticks) {
    canvas
      ..moveTo(p.left, p.y(t))
      ..lineTo(p.width - _Plot.right, p.y(t))
      ..strokePath();
  }
  canvas.setLineDashPattern();
}

/// Values of [value] between [start] and [end]: carried in from the entry
/// before the window and carried on to its end, like the app's history chart.
List<(DateTime, double)> _series(
  List<BalanceRow> rows,
  DateTime start,
  DateTime end,
  double Function(BalanceRow) value,
) {
  final points = <(DateTime, double)>[];
  final before = rows.lastWhere((r) => !r.date.isAfter(start), orElse: () => rows.first);
  points.add((before.date.isAfter(start) ? before.date : start, value(before)));
  for (final r in rows) {
    if (r.date.isAfter(start) && !r.date.isAfter(end)) {
      points.add((r.date, value(r)));
    }
  }
  if (points.last.$1.isBefore(end)) points.add((end, points.last.$2));
  return points;
}

pw.Widget _netWorthChart(ReportRequest r, _Styles s, PeriodReview review) {
  final rows = r.input.rows;
  final start = r.year == null ? review.from!.date : DateTime(r.year!);
  final endOfYear = r.year == null ? r.input.today : DateTime(r.year!, 12, 31);
  final end = endOfYear.isAfter(r.input.today) ? r.input.today : endOfYear;
  final hasDebt = review.to!.debt > 0 || review.from!.debt > 0;
  final lines = [
    (_primary, _series(rows, start, end, (b) => b.total), true),
    (_accent, _series(rows, start, end, (b) => b.liquid), false),
    (_positiveBar, _series(rows, start, end, (b) => b.invested), false),
    if (hasDebt) (_negative, _series(rows, start, end, (b) => b.debt), false),
  ];
  final values = [for (final line in lines) ...line.$2.map((p) => p.$2)];
  var lo = values.reduce(math.min), hi = values.reduce(math.max);
  if (lo > 0) lo = math.max(0, lo - (hi - lo) * 0.15);
  final ticks = niceTicks(lo, hi);
  final p = _Plot(height: 180, minY: ticks.first, maxY: ticks.last, left: 46);
  final span = math.max(1, daysBetween(start, end));
  double x(DateTime d) => p.left + daysBetween(start, d) / span * p.plotWidth;

  // Month starts for a year, year starts (or quarters) for longer spans.
  final xTicks = <DateTime>[];
  if (span <= 400) {
    for (
      var d = DateTime(start.year, start.month + (start.day == 1 ? 0 : 1));
      !d.isAfter(end);
      d = DateTime(d.year, d.month + 1)
    ) {
      xTicks.add(d);
    }
  } else {
    final every = span > 365 * 10 ? 2 : 1;
    for (var y = start.year + 1; !DateTime(y).isAfter(end); y += every) {
      xTicks.add(DateTime(y));
    }
    if (xTicks.length < 2) {
      xTicks
        ..clear()
        ..addAll([
          for (
            var d = DateTime(start.year, ((start.month - 1) ~/ 3 + 1) * 3 + 1);
            !d.isAfter(end);
            d = DateTime(d.year, d.month + 3)
          )
            d,
        ]);
    }
  }
  String xLabel(DateTime d) => span <= 400
      ? r.fmt.monthShort(d).replaceAll('.', '')
      : (d.month == 1 ? '${d.year}' : '${r.fmt.monthShort(d).replaceAll('.', '')} ${d.year % 100}');

  return pw.SizedBox(
    width: p.width,
    height: p.height,
    child: pw.Stack(
      children: [
        pw.CustomPaint(
          size: PdfPoint(p.width, p.height),
          painter: (canvas, size) {
            _paintGrid(canvas, p, ticks);
            for (final (color, points, fill) in lines) {
              if (fill) {
                canvas
                  ..saveContext()
                  ..setGraphicState(const PdfGraphicState(opacity: 0.14))
                  ..setFillColor(color)
                  ..moveTo(x(points.first.$1), p.y(ticks.first));
                for (final pt in points) {
                  canvas.lineTo(x(pt.$1), p.y(pt.$2));
                }
                canvas
                  ..lineTo(x(points.last.$1), p.y(ticks.first))
                  ..closePath()
                  ..fillPath()
                  ..restoreContext();
              }
              canvas
                ..setStrokeColor(color)
                ..setLineWidth(fill ? 1.8 : 1.2)
                ..setLineJoin(PdfLineJoin.round)
                ..setLineCap(PdfLineCap.round);
              for (var i = 0; i < points.length; i++) {
                final px = x(points[i].$1), py = p.y(points[i].$2);
                i == 0 ? canvas.moveTo(px, py) : canvas.lineTo(px, py);
              }
              canvas.strokePath();
            }
          },
        ),
        _yLabels(p, s, r.fmt, ticks),
        for (final d in xTicks)
          pw.Positioned(
            left: x(d) - 22,
            top: p.height - _Plot.bottom + 4,
            child: pw.SizedBox(
              width: 44,
              child: pw.Text(xLabel(d), style: s.axis, textAlign: pw.TextAlign.center),
            ),
          ),
      ],
    ),
  );
}

pw.Widget _barChart(ReportRequest r, _Styles s, List<PeriodReview> buckets) {
  final values = [for (final b in buckets) b.hasFlow ? b.change : 0.0];
  final ticks = niceTicks(math.min(0, values.reduce(math.min)), math.max(0, values.reduce(math.max)));
  final p = _Plot(height: 150, minY: ticks.first, maxY: ticks.last, left: 46);
  final slot = p.plotWidth / buckets.length;
  final barWidth = math.min(28.0, slot * 0.58);
  String label(PeriodReview b) => r.year == null ? '${b.start.year}' : r.fmt.monthShort(b.start).replaceAll('.', '');

  return pw.SizedBox(
    width: p.width,
    height: p.height,
    child: pw.Stack(
      children: [
        pw.CustomPaint(
          size: PdfPoint(p.width, p.height),
          painter: (canvas, size) {
            _paintGrid(canvas, p, ticks);
            canvas
              ..setStrokeColor(_muted)
              ..setLineWidth(.6)
              ..moveTo(p.left, p.y(0))
              ..lineTo(p.width - _Plot.right, p.y(0))
              ..strokePath();
            for (var i = 0; i < values.length; i++) {
              final v = values[i];
              if (v.abs() < 0.005) continue;
              final cx = p.left + slot * (i + .5);
              final y0 = p.y(0), y1 = p.y(v);
              canvas
                ..setFillColor(v < 0 ? _negative : _positiveBar)
                ..drawRRect(cx - barWidth / 2, math.min(y0, y1), barWidth, (y1 - y0).abs(), 2.5, 2.5)
                ..fillPath();
            }
          },
        ),
        _yLabels(p, s, r.fmt, ticks),
        for (var i = 0; i < buckets.length; i++)
          pw.Positioned(
            left: p.left + slot * i,
            top: p.height - _Plot.bottom + 4,
            child: pw.SizedBox(
              width: slot,
              child: pw.Text(label(buckets[i]), style: s.axis, textAlign: pw.TextAlign.center),
            ),
          ),
      ],
    ),
  );
}

// -- Tables ---------------------------------------------------------------------

pw.Widget _table(
  _Styles s, {
  required List<String> headers,
  required List<List<pw.Widget>> rows,
  required List<double> flex,
  List<pw.Widget>? footer,
  int leftColumns = 1,
}) {
  pw.Widget cell(pw.Widget child, int i) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4.5),
    child: pw.Align(alignment: i < leftColumns ? pw.Alignment.centerLeft : pw.Alignment.centerRight, child: child),
  );
  return pw.Table(
    columnWidths: {for (var i = 0; i < flex.length; i++) i: pw.FlexColumnWidth(flex[i])},
    border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: _line, width: .5)),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _mist),
        repeat: true,
        children: [
          for (var i = 0; i < headers.length; i++)
            cell(
              pw.Text(
                headers[i],
                style: s.label.copyWith(color: _tile),
                textAlign: i < leftColumns ? null : pw.TextAlign.right,
              ),
              i,
            ),
        ],
      ),
      for (final row in rows) pw.TableRow(children: [for (var i = 0; i < row.length; i++) cell(row[i], i)]),
      if (footer != null)
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _cream),
          children: [for (var i = 0; i < footer.length; i++) cell(footer[i], i)],
        ),
    ],
  );
}

pw.Widget _text(_Styles s, String t, {bool strong = false}) => pw.Text(t, style: strong ? s.strong : s.body);

pw.Widget _signed(_Styles s, Fmt fmt, double v, {bool strong = false}) =>
    pw.Text(fmt.signedMoney(v), style: (strong ? s.strong : s.body).copyWith(color: _signColor(v)));

pw.Widget _bucketTable(
  ReportRequest r,
  _Styles s,
  List<PeriodReview> buckets,
  PeriodReview? total, {
  required bool years,
  bool withYear = false,
}) {
  final fmt = r.fmt;
  final l = r.l;
  String name(PeriodReview b) =>
      years ? '${b.start.year}' : (withYear ? fmt.month(b.start) : fmt.month(b.start).split(' ').first);
  List<pw.Widget> row(PeriodReview b, String label, {bool strong = false}) => [
    _text(s, label, strong: strong),
    _text(s, b.to == null ? '—' : fmt.money(b.to!.total), strong: strong),
    b.hasFlow ? _signed(s, fmt, b.change, strong: strong) : _text(s, '—'),
    b.hasFlow ? _signed(s, fmt, b.saved, strong: strong) : _text(s, '—'),
    b.hasFlow ? _signed(s, fmt, b.investmentReturn, strong: strong) : _text(s, '—'),
    _text(s, b.hasFlow ? fmt.money(b.variableExpenses) : '—', strong: strong),
    _text(s, b.savingsRate == null ? '—' : fmt.percent(b.savingsRate!), strong: strong),
  ];
  return _table(
    s,
    headers: [
      years ? l.scopeYear : l.scopeMonth,
      l.reportColEnd,
      l.reportGrowth,
      l.reviewColSaved,
      l.reviewColReturn,
      l.reportColVariable,
      l.reportColRate,
    ],
    flex: const [1.45, 1.35, 1.3, 1.25, 1.2, 1.2, 0.85],
    rows: [for (final b in buckets) row(b, name(b))],
    footer: total == null || !total.hasFlow ? null : row(total, l.total, strong: true),
  );
}

pw.Widget _accountsTable(ReportRequest r, _Styles s, PeriodReview review) {
  final fmt = r.fmt;
  final l = r.l;
  final data = r.input.data;
  final to = review.to, from = review.from;
  if (to == null || from == null) return pw.Text('—', style: s.body);
  final gross = to.liquid + to.invested;
  final accounts = data.accounts.where((a) => to.balanceOf(a.id) != 0 || from.balanceOf(a.id) != 0).toList();
  return _table(
    s,
    leftColumns: 2,
    headers: [
      l.reportColAccount,
      l.reportColType,
      l.reportColStart,
      l.reportColEnd,
      l.reportColChange,
      l.reportColShare,
    ],
    flex: const [2.0, 1.3, 1.3, 1.3, 1.2, 0.8],
    rows: [
      for (final a in accounts)
        [
          _text(s, a.archived ? '${a.name} (${l.archivedSection})' : a.name),
          _text(s, data.typeOf(a)?.name ?? '—'),
          _text(s, fmt.money(_sign(data, a, from.balanceOf(a.id)))),
          _text(s, fmt.money(_sign(data, a, to.balanceOf(a.id)))),
          _signed(s, fmt, _sign(data, a, review.accountChange(a.id))),
          _text(
            s,
            data.behaviorOf(a) == AccountBehavior.debt || gross == 0 ? '—' : fmt.percent(to.balanceOf(a.id) / gross),
          ),
        ],
    ],
    footer: [
      _text(s, l.cardNetWorth, strong: true),
      _text(s, ''),
      _text(s, fmt.money(from.total), strong: true),
      _text(s, fmt.money(to.total), strong: true),
      _signed(s, fmt, review.change, strong: true),
      _text(s, ''),
    ],
  );
}

/// Debts count negative in the net worth.
double _sign(AppData data, Account a, double v) => data.behaviorOf(a) == AccountBehavior.debt ? -v : v;

pw.Widget _spendingTable(ReportRequest r, _Styles s, PeriodReview review) {
  final fmt = r.fmt;
  final l = r.l;
  final data = r.input.data;
  final total = review.spendingTotal;
  if (total == 0) return pw.Text(l.reviewNoSpending, style: s.body);
  final months = (review.end.year - review.start.year) * 12 + review.end.month - review.start.month + 1;

  pw.Widget bar(double v, PdfColor color) => pw.Container(
    height: 6,
    width: 70,
    alignment: pw.Alignment.centerLeft,
    decoration: const pw.BoxDecoration(color: _track, borderRadius: pw.BorderRadius.all(pw.Radius.circular(3))),
    // Very small shares would only show the rounded ends.
    child: 70 * v / total < 3
        ? pw.SizedBox()
        : pw.Container(
            width: 70 * (v / total).clamp(0, 1),
            decoration: pw.BoxDecoration(color: color, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
          ),
  );

  List<pw.Widget> row(String name, PdfColor color, double fixed, double single, double sum) => [
    pw.Row(
      children: [
        pw.Container(
          width: 7,
          height: 7,
          decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
        ),
        pw.SizedBox(width: 6),
        pw.Text(name, style: s.body),
      ],
    ),
    _text(s, fixed == 0 ? '—' : fmt.money(fixed)),
    _text(s, single == 0 ? '—' : fmt.money(single)),
    _text(s, fmt.money(sum), strong: true),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        bar(sum, color),
        pw.SizedBox(width: 6),
        pw.SizedBox(
          width: 30,
          child: pw.Text(fmt.percentRound(sum / total), style: s.body, textAlign: pw.TextAlign.right),
        ),
      ],
    ),
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _table(
        s,
        headers: [l.reportColCategory, l.fixedCosts, l.singleBookings, l.total, l.reportColShare],
        flex: const [2.2, 1.2, 1.2, 1.2, 1.8],
        rows: [
          for (final c in review.spending)
            row(
              data.categoryById(c.categoryId)?.name ?? l.noCategory,
              c.categoryId == null
                  ? _muted
                  : _chart[(data.categoryById(c.categoryId)?.colorIndex ?? 0) % _chart.length],
              c.fixed,
              c.single,
              c.total,
            ),
          if (review.unassigned > 0) row(l.unassigned, _track, 0, 0, review.unassigned),
        ],
        footer: [
          _text(s, l.total, strong: true),
          _text(s, ''),
          _text(s, ''),
          _text(s, fmt.money(total), strong: true),
          _text(s, months > 1 ? l.reviewAveragePerMonth(fmt.money(total / months)) : ''),
        ],
      ),
      if (review.singleIncome > 0) ...[
        pw.SizedBox(height: 6),
        pw.Text('${l.reviewSingleIncome}: ${fmt.money(review.singleIncome)}', style: s.body),
      ],
      pw.SizedBox(height: 6),
      pw.Text(l.unassignedHint, style: s.small),
    ],
  );
}

pw.Widget _planTable(ReportRequest r, _Styles s) {
  final fmt = r.fmt;
  final l = r.l;
  final RecurringSummary p = r.input.recurring;
  List<pw.Widget> row(String label, double monthly, {bool strong = false}) => [
    _text(s, label, strong: strong),
    _text(s, fmt.money(monthly), strong: strong),
    _text(s, fmt.money(monthly * 12), strong: strong),
  ];
  return _table(
    s,
    headers: [l.reportPlanAsOf(fmt.date(r.input.today)), l.perMonth, l.perYear],
    flex: const [2.6, 1.2, 1.2],
    rows: [
      row(l.reportFixedIncome, p.fixedIncome),
      row(l.reportFixedExpenses, p.fixedExpenses),
      row(l.reportSavings, p.savingsTotal),
      row(l.reportSavingsInvested, p.savingsInvested),
      row(l.reportFree, p.free, strong: true),
    ],
    footer: [
      _text(s, l.reportPlannedSavingsRate, strong: true),
      _text(s, fmt.percent(p.savingsRate), strong: true),
      _text(s, ''),
    ],
  );
}

pw.Widget _outlook(ReportRequest r, _Styles s) {
  final fmt = r.fmt;
  final l = r.l;
  final p = r.projection;
  final a = p.assumptions;
  final goal = r.goal;
  final lines = <pw.Widget>[];

  if (goal.primary != null) {
    final goals = goal.mode == SavingsGoalMode.perAccount ? goal.accountGoals : [goal.primary!];
    for (final g in goals) {
      final name = switch (goal.mode) {
        SavingsGoalMode.savingsRate => l.goalRateLabel,
        SavingsGoalMode.netWorth => l.goalNetWorthLabel,
        SavingsGoalMode.perAccount => g.account!.name,
      };
      final value = goal.mode == SavingsGoalMode.savingsRate
          ? l.goalOf(fmt.percent(g.current), fmt.percent(g.target))
          : l.goalOf(fmt.money(g.current), fmt.money(g.target));
      final f = r.forecasts[g.account?.id];
      final when = goal.mode == SavingsGoalMode.savingsRate || f == null
          ? (g.reached ? l.goalReached : '')
          : (f.reached
                ? l.goalReached
                : (f.unreachable ? l.forecastUnreachable : l.forecastExpected(fmt.month(f.date!))));
      lines.add(
        pw.Bullet(text: '$name: $value${when.isEmpty ? '' : ' · $when'}', style: s.body, bulletColor: _primary),
      );
    }
  }
  for (final years in const [1, 5, 10]) {
    if (years * 12 >= p.points.length) continue;
    final pt = p.afterMonths(years * 12);
    lines.add(
      pw.Bullet(
        text: l.reportProjectionLine(years, fmt.month(pt.date), fmt.money(pt.total)),
        style: s.body,
        bulletColor: _primary,
      ),
    );
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      ...lines,
      pw.SizedBox(height: 4),
      pw.Text(
        l.reportAssumptions(fmt.money(a.monthlySaving), fmt.money(a.monthlyInvested), fmt.percent(a.annualReturn)),
        style: s.small,
      ),
    ],
  );
}

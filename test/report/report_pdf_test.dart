import 'dart:io';
import 'dart:typed_data';

import 'package:financeoverview/core/format.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/l10n/gen/app_localizations.dart';
import 'package:financeoverview/report/report_pdf.dart';
import 'package:financeoverview/state/derived.dart';
import 'package:financeoverview/state/session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/widgets.dart' as pw;

import '../support/demo_data.dart';
import '../support/harness.dart';

/// Builds the reports from invented data. With REPORT_OUT set, the PDFs are
/// written there for a visual check (e.g. with pdftoppm).
void main() {
  late ReportFonts fonts;

  setUpAll(() async {
    await initializeDateFormatting();
    pw.Font load(String weight) =>
        pw.Font.ttf(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$weight.ttf').readAsBytesSync()));
    fonts = ReportFonts(regular: load('Regular'), semiBold: load('SemiBold'), bold: load('Bold'));
  });

  Future<Uint8List> build(AppData data, int? year, String lang) {
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(() => FakeSession(unlocked(data))),
        clockProvider.overrideWithValue(() => testToday),
      ],
    );
    addTearDown(container.dispose);
    return buildReportPdf(
      ReportRequest(
        input: container.read(reviewInputProvider),
        year: year,
        l: lookupAppLocalizations(Locale(lang)),
        fmt: Fmt(lang),
        generatedAt: testToday,
        appVersion: 'test',
        projection: container.read(projectionProvider),
        goal: container.read(savingsGoalProvider),
        forecasts: container.read(goalForecastsProvider),
      ),
      fonts,
    );
  }

  Future<void> check(String name, AppData data, int? year, String lang) async {
    final bytes = await build(data, year, lang);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(10000));
    final out = Platform.environment['REPORT_OUT'];
    if (out != null) File('$out/$name.pdf').writeAsBytesSync(bytes);
  }

  test('annual report', () => check('report_2026_de', longDemoData(), 2026, 'de'));

  test('report for all time', () => check('report_all_de', longDemoData(), null, 'de'));

  test('report in English with a single year of data', () => check('report_2026_en', demoData(), 2026, 'en'));

  test('year without changes still builds', () => check('report_2023_de', longDemoData(), 2023, 'de'));
}

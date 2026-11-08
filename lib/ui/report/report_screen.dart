import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/app_info.dart';
import '../../core/format.dart';
import '../../domain/review_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../report/report_pdf.dart';
import '../../state/derived.dart';
import '../../state/session.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/forms.dart';

Future<ReportFonts> loadReportFonts() async {
  Future<pw.Font> load(String weight) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'));
  return ReportFonts(regular: await load('Regular'), semiBold: await load('SemiBold'), bold: await load('Bold'));
}

/// PDF report for one year or the whole time, saved wherever the user wants.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.year});

  /// Preselected year; null = the whole time.
  final int? year;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late int? _year = widget.year;

  /// A preselected year without data falls back to the newest one.
  int? _selected(List<int> years) => _year != null && !years.contains(_year) ? years.firstOrNull : _year;
  bool _busy = false;

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final session = ref.read(sessionProvider.notifier);
    final now = ref.read(clockProvider)();
    // The report always shows real amounts, also in discreet mode.
    final fmt = Fmt(Localizations.localeOf(context).toLanguageTag());
    final input = ref.read(reviewInputProvider);
    final year = _selected(reviewYears(input));
    final request = ReportRequest(
      input: input,
      year: year,
      l: l,
      fmt: fmt,
      generatedAt: now,
      appVersion: appVersion,
      projection: ref.read(projectionProvider),
      goal: ref.read(savingsGoalProvider),
      forecasts: ref.read(goalForecastsProvider),
    );
    setState(() => _busy = true);
    try {
      final bytes = await buildReportPdf(request, await loadReportFonts());
      final path = await session.withoutAutoLock(
        () => FilePicker.saveFile(dialogTitle: l.reportTitle, fileName: reportFileName(year, now), bytes: bytes),
      );
      if (mounted && path != null) showSnack(context, l.reportSaved);
    } catch (e) {
      debugPrint('report failed: $e');
      if (mounted) showSnack(context, l.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final input = ref.watch(reviewInputProvider);
    final years = reviewYears(input);
    final hasEntries = input.rows.length >= 2;
    final selected = _selected(years);

    return Scaffold(
      appBar: AppBar(title: Text(l.reportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          if (!hasEntries)
            AppCard(
              child: EmptyState(icon: Icons.picture_as_pdf_rounded, title: l.reportEmptyTitle, body: l.reportEmptyBody),
            )
          else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBadge(icon: Icons.picture_as_pdf_rounded, color: context.fin.accent, size: 48),
                  const SizedBox(height: 14),
                  Text(l.reportIntro, style: context.text.bodyMedium),
                  const SizedBox(height: 18),
                  Text(l.reportChoose, style: context.text.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l.reportAllTime),
                        selected: selected == null,
                        onSelected: (_) => setState(() => _year = null),
                      ),
                      for (final y in years)
                        ChoiceChip(
                          label: Text('$y'),
                          selected: selected == y,
                          onSelected: (_) => setState(() => _year = y),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InfoNote(l.reportUnencrypted, icon: Icons.lock_open_rounded),
            const SizedBox(height: 18),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.save_alt_rounded),
                label: Text(selected == null ? l.reportCreateAll : l.reportCreateYear(selected)),
              ),
          ],
        ],
      ),
    );
  }
}

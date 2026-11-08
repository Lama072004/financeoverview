import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/format.dart';
import '../../domain/review_calc.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../state/derived.dart';
import '../dashboard/dashboard_cards.dart';
import '../nav.dart';
import '../report/report_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

enum ReviewScope { month, year, all }

/// Month, year or the whole time at a glance: growth, savings rate, spending.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, this.initialScope = ReviewScope.month});

  final ReviewScope initialScope;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late ReviewScope _scope = widget.initialScope;
  late DateTime _month = firstOfMonth(ref.read(todayProvider));
  late int _year = ref.read(todayProvider).year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final input = ref.watch(reviewInputProvider);
    final today = input.today;
    final begin = dataStart(input.data);

    final review = switch (_scope) {
      ReviewScope.month => reviewMonth(input, _month),
      ReviewScope.year => reviewYear(input, _year),
      ReviewScope.all => reviewAll(input),
    };
    final buckets = switch (_scope) {
      ReviewScope.month => const <PeriodReview>[],
      ReviewScope.year => monthsOfYear(input, _year),
      ReviewScope.all => allYears(input),
    };

    Widget stepper() {
      final isMonth = _scope == ReviewScope.month;
      final canBack = begin != null && (isMonth ? _month.isAfter(firstOfMonth(begin)) : _year > begin.year);
      final canNext = isMonth ? _month.isBefore(firstOfMonth(today)) : _year < today.year;
      return Row(
        children: [
          IconButton(
            tooltip: l.periodPrevious,
            onPressed: canBack
                ? () => setState(() => isMonth ? _month = DateTime(_month.year, _month.month - 1) : _year--)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              isMonth ? fmt.month(_month) : '$_year',
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: l.periodNext,
            onPressed: canNext
                ? () => setState(() => isMonth ? _month = DateTime(_month.year, _month.month + 1) : _year++)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      );
    }

    void drillDown(int i) {
      final b = buckets[i];
      setState(() {
        if (_scope == ReviewScope.year) {
          _scope = ReviewScope.month;
          _month = b.start;
        } else {
          _scope = ReviewScope.year;
          _year = b.start.year;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.reviewTitle),
        actions: [
          IconButton(
            tooltip: l.reportTitle,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => push(
              context,
              ReportScreen(year: switch (_scope) {
                ReviewScope.month => _month.year,
                ReviewScope.year => _year,
                ReviewScope.all => null,
              }),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          SegmentedButton<ReviewScope>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ReviewScope.month, label: Text(l.scopeMonth)),
              ButtonSegment(value: ReviewScope.year, label: Text(l.scopeYear)),
              ButtonSegment(value: ReviewScope.all, label: Text(l.scopeAll)),
            ],
            selected: {_scope},
            onSelectionChanged: (s) => setState(() => _scope = s.first),
          ),
          const SizedBox(height: 8),
          if (_scope != ReviewScope.all) stepper() else const SizedBox(height: 8),
          if (begin == null)
            AppCard(child: EmptyState(icon: Icons.insights_rounded, title: l.reviewEmptyTitle, body: l.reviewEmptyBody))
          else ...[
            _SummaryCard(review: review),
            if (review.hasFlow) ...[const SizedBox(height: 14), _RateCard(review: review)],
            if (buckets.any((b) => b.hasFlow)) ...[
              const SizedBox(height: 14),
              _BucketsCard(buckets: buckets, years: _scope == ReviewScope.all, onTap: drillDown),
            ],
            const SizedBox(height: 14),
            _SpendingCard(review: review, months: _scope == ReviewScope.month ? 1 : _monthsIn(review)),
          ],
        ],
      ),
    );
  }

  static int _monthsIn(PeriodReview r) => (r.end.year - r.start.year) * 12 + r.end.month - r.start.month + 1;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.review});

  final PeriodReview review;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final r = review;
    if (!r.hasData) {
      return AppCard(
        child: EmptyState(
          icon: Icons.edit_calendar_rounded,
          title: l.reviewNoEntry,
          body: r.from == null ? null : l.reviewLastKnown(fmt.date(r.from!.date), fmt.money(r.from!.total)),
        ),
      );
    }
    final relative = r.relativeChange;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.cardNetWorth, trailing: Text(l.asOf(fmt.date(r.to!.date)), style: context.text.labelMedium)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Amount(fmt.money(r.to!.total), style: context.text.displaySmall?.copyWith(fontSize: 32)),
          ),
          if (r.hasFlow) ...[
            const SizedBox(height: 10),
            DeltaChip(
              text: fmt.signedMoney(r.change),
              value: r.change,
              label: relative == null ? l.reviewChange : '${fmt.percent(relative)} · ${l.reviewChange}',
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 8),
            KeyValueRow(label: l.reviewSaved, value: fmt.signedMoney(r.saved), amount: r.saved, colored: true),
            KeyValueRow(
              label: l.reviewReturn,
              value: fmt.signedMoney(r.investmentReturn),
              amount: r.investmentReturn,
              colored: true,
            ),
            KeyValueRow(label: l.reviewVariable, value: fmt.money(r.variableExpenses)),
            const SizedBox(height: 4),
            Text(
              l.reviewSpan(fmt.date(r.from!.date), fmt.date(r.to!.date), l.daysCount(r.days)),
              style: context.text.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(l.reviewSingleEntry, style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.review});

  final PeriodReview review;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final actual = review.savingsRate;
    final planned = review.plannedSavingsRate;

    Widget bar(String label, double value, Color? color) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: context.text.bodyMedium)),
                  Amount(fmt.percent(value), style: context.text.titleSmall),
                ],
              ),
              const SizedBox(height: 6),
              ProgressBar(value: value, color: color),
            ],
          ),
        );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.reviewSavingsRate),
          const SizedBox(height: 6),
          if (actual == null || planned == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.reviewRateNoIncome, style: context.text.bodyMedium),
            )
          else ...[
            bar(l.reviewRateActual, actual, actual < 0 ? context.fin.negative : context.fin.positive),
            bar(l.reviewRatePlanned, planned, context.colors.primary),
            const SizedBox(height: 6),
            Text(l.reviewRateHint, style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _BucketsCard extends StatelessWidget {
  const _BucketsCard({required this.buckets, required this.years, required this.onTap});

  final List<PeriodReview> buckets;
  final bool years;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    String short(PeriodReview b) => years ? '${b.start.year}' : fmt.monthShort(b.start).replaceAll('.', '');
    String long(PeriodReview b) => years ? '${b.start.year}' : fmt.month(b.start);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CardHeader(years ? l.reviewPerYear : l.reviewPerMonth),
          ),
          const SizedBox(height: 16),
          PeriodBarChart(
            bars: [
              for (final b in buckets) (label: short(b), tooltip: long(b), value: b.hasFlow ? b.change : 0),
            ],
            onTap: onTap,
          ),
          const SizedBox(height: 8),
          for (var i = buckets.length - 1; i >= 0; i--)
            if (buckets[i].hasFlow)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(long(buckets[i]), style: context.text.titleSmall),
                            Text(
                              '${l.reviewColSaved} ${fmt.signedMoneyRound(buckets[i].saved)} · '
                              '${l.reviewColReturn} ${fmt.signedMoneyRound(buckets[i].investmentReturn)}',
                              style: money(context.text.bodySmall),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Amount(
                        fmt.signedMoney(buckets[i].change),
                        value: buckets[i].change,
                        colored: true,
                        style: context.text.titleSmall,
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.fin.muted, size: 20),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _SpendingCard extends ConsumerWidget {
  const _SpendingCard({required this.review, required this.months});

  final PeriodReview review;
  final int months;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = Fmt.of(context);
    final data = ref.watch(reviewInputProvider.select((i) => i.data));
    final total = review.spendingTotal;

    Widget row({required IconData icon, required Color color, required String label, String? sub, required double value}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              IconBadge(icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (sub != null && sub.isNotEmpty)
                      Text(sub, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Amount(fmt.money(value), style: context.text.titleSmall),
                  Text(total == 0 ? '' : fmt.percentRound(value / total), style: context.text.bodySmall),
                ],
              ),
            ],
          ),
        );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(l.reviewSpending, trailing: Amount(fmt.money(total), style: context.text.labelLarge)),
          if (months > 1 && total > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l.reviewAveragePerMonth(fmt.money(total / months)), style: context.text.bodySmall),
            ),
          const SizedBox(height: 8),
          if (total == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l.reviewNoSpending, style: context.text.bodyMedium),
            ),
          for (final c in review.spending)
            Builder(builder: (context) {
              final s = spendingStyle(context, data, c.categoryId);
              return row(
                icon: s.icon,
                color: s.color,
                label: s.label,
                sub: [
                  if (c.fixed > 0) '${l.fixedCosts} ${fmt.moneyRound(c.fixed)}',
                  if (c.single > 0) '${l.singleBookings} ${fmt.moneyRound(c.single)}',
                ].join(' · '),
                value: c.total,
              );
            }),
          if (review.unassigned > 0)
            row(
              icon: Icons.help_outline_rounded,
              color: context.fin.muted,
              label: l.unassigned,
              sub: l.unassignedHint,
              value: review.unassigned,
            ),
          if (review.singleIncome > 0) ...[
            const Divider(height: 20),
            KeyValueRow(label: l.reviewSingleIncome, value: fmt.money(review.singleIncome)),
          ],
        ],
      ),
    );
  }
}

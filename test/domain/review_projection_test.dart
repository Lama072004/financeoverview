import 'package:financeoverview/core/ticks.dart';
import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/data/prefs.dart';
import 'package:financeoverview/domain/backup_reminder.dart';
import 'package:financeoverview/domain/overview_calc.dart';
import 'package:financeoverview/domain/projection_calc.dart';
import 'package:financeoverview/domain/recurring_calc.dart';
import 'package:financeoverview/domain/review_calc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

const eps = 1e-6;

void main() {
  final today = DateTime(2026, 2, 15);
  final data = TestData.build();
  final rows = balanceHistory(data);
  final recurring = summarizeRecurring(data, today);
  final input = ReviewInput(
    data: data,
    rows: rows,
    estimates: periodEstimates(rows, recurring),
    recurring: recurring,
    today: today,
  );

  group('review', () {
    test('a month runs from the last entry before it to the last entry in it', () {
      final jan = reviewMonth(input, DateTime(2026, 1));
      expect(jan.from!.snapshot.id, 's1');
      expect(jan.to!.snapshot.id, 's3');
      expect(jan.change, closeTo(5200 - 4000, eps));
      expect(jan.days, 42);
      // Sum of the per-entry estimates of the history (s2 and s3).
      expect(jan.investmentReturn, closeTo(600 - 300 * 42 / daysPerMonth, eps));
      expect(jan.saved, closeTo(jan.change - jan.investmentReturn, eps));
      expect(jan.plannedIncome, closeTo(3000 * 42 / daysPerMonth, eps));
      expect(jan.savingsRate, closeTo(jan.saved / jan.plannedIncome, eps));
      expect(jan.plannedSavingsRate, closeTo(0.2, eps));
    });

    test('consecutive months add up to the year', () {
      final months = monthsOfYear(input, 2026);
      expect(months, hasLength(2)); // January and February until today
      final year = reviewYear(input, 2026);
      expect(months.fold(0.0, (s, m) => s + m.change), closeTo(year.change, eps));
      expect(months.fold(0.0, (s, m) => s + m.investmentReturn), closeTo(year.investmentReturn, eps));
      expect(year.change, closeTo(5100 - 4000, eps));
    });

    test('the first entry starts the review, a single entry has no change', () {
      final dec = reviewMonth(input, DateTime(2025, 12));
      expect(dec.hasData, isTrue);
      expect(dec.hasFlow, isFalse);
      expect(dec.change, 0);
      expect(dec.savingsRate, isNull);

      final all = reviewAll(input);
      expect(all.from!.snapshot.id, 's1');
      expect(all.to!.snapshot.id, 's4');
      expect(allYears(input).map((r) => r.start.year), [2025, 2026]);
      expect(reviewYears(input), [2026, 2025]);
    });

    test('a month without its own entry and the future have nothing to review', () {
      final march = reviewMonth(input, DateTime(2026, 3));
      expect(march.hasData, isFalse);
      expect(march.spendingTotal, 0);
    });

    test('spending adds the months up, like the dashboard donut', () {
      final withBookings = TestData.build(transactions: [
        TransactionEntry(
          id: 't1',
          date: DateTime(2026, 1, 12),
          amount: 80,
          isIncome: false,
          categoryId: 'groceries',
          createdAt: DateTime(2026),
        ),
      ]);
      final rows2 = balanceHistory(withBookings);
      final year = reviewYear(
        ReviewInput(
          data: withBookings,
          rows: rows2,
          estimates: periodEstimates(rows2, recurring),
          recurring: recurring,
          today: today,
        ),
        2026,
      );
      final housing = year.spending.firstWhere((c) => c.categoryId == 'housing');
      expect(housing.fixed, closeTo(2000, eps)); // January + February
      expect(year.spending.firstWhere((c) => c.categoryId == 'groceries').single, 80);
    });
  });

  group('projection', () {
    final overview = buildOverview(data, rows, recurring);

    test('assumptions come from the standing orders, own values or the trend', () {
      final plan = projectionAssumptions(const ProjectionSettings(), recurring, null);
      expect(plan.basis, ProjectionBasis.plan);
      expect(plan.monthlySaving, 600);
      expect(plan.monthlyInvested, 300);

      final own = projectionAssumptions(const ProjectionSettings(monthlySaving: 1000), recurring, null);
      expect(own.basis, ProjectionBasis.own);
      expect(own.monthlyInvested, closeTo(500, eps)); // same share as planned

      final trend = monthlyTrend(rows, today, (r) => r.total);
      expect(trend, closeTo(1100 / (52 / daysPerMonth), eps));
      final fromTrend = projectionAssumptions(const ProjectionSettings(), RecurringSummary.empty, trend);
      expect(fromTrend.basis, ProjectionBasis.trend);
      expect(fromTrend.annualReturn, 0);

      expect(projectionAssumptions(const ProjectionSettings(), RecurringSummary.empty, null).basis, ProjectionBasis.none);
    });

    test('savings add up and the invested part compounds', () {
      const noReturn = ProjectionAssumptions(
        basis: ProjectionBasis.own,
        monthlySaving: 600,
        monthlyInvested: 300,
        annualReturn: 0,
      );
      final p = project(overview: overview, assumptions: noReturn, today: today, months: 12);
      expect(p.points, hasLength(13));
      expect(p.points.last.total, closeTo(overview.total + 7200, eps));
      expect(p.points.last.contributed, 7200);
      expect(p.points[1].date, DateTime(2026, 3));

      const onlyReturn = ProjectionAssumptions(
        basis: ProjectionBasis.none,
        monthlySaving: 0,
        monthlyInvested: 0,
        annualReturn: 0.05,
      );
      final grown = project(overview: overview, assumptions: onlyReturn, today: today, months: 12);
      expect(grown.points.last.returns, closeTo(overview.invested * 0.05, 1e-6));
    });

    test('goal dates', () {
      const steady = ProjectionAssumptions(
        basis: ProjectionBasis.own,
        monthlySaving: 600,
        monthlyInvested: 0,
        annualReturn: 0,
      );
      final f = netWorthForecast(overview: overview, assumptions: steady, target: overview.total + 6000, today: today);
      expect(f.date, DateTime(2026, 12)); // ten months
      expect(
        netWorthForecast(overview: overview, assumptions: steady, target: 10, today: today).reached,
        isTrue,
      );
      const nothing = ProjectionAssumptions(
        basis: ProjectionBasis.none,
        monthlySaving: 0,
        monthlyInvested: 0,
        annualReturn: 0,
      );
      expect(
        netWorthForecast(overview: overview, assumptions: nothing, target: 1e6, today: today).unreachable,
        isTrue,
      );
    });

    test('account goals use the savings into the account, else its trend', () {
      // Giro receives 200 per month (standing order "Tagesgeld" → a).
      final giro = accountForecast(
        data: data,
        account: TestData.giro,
        balance: 1400,
        target: 2400,
        rows: rows,
        annualReturn: 0.05,
        today: today,
      );
      expect(giro.date, DateTime(2026, 7)); // five months, no return on liquid money

      final noPlan = data.copyWith(recurring: const []);
      final depot = accountForecast(
        data: noPlan,
        account: TestData.depot,
        balance: 5600,
        target: 6000,
        rows: rows,
        annualReturn: 0.05,
        today: today,
      );
      // Trend s1 → s4: +600 in 52 days.
      expect(depot.date, isNotNull);
      expect(accountInflow(data, TestData.depot, today), 300);
    });
  });

  group('backup reminder', () {
    final now = DateTime(2026, 2, 15, 12);
    final created = data.copyWith(
      snapshots: [for (final s in data.snapshots) Snapshot(id: s.id, date: s.date, values: s.values, createdAt: DateTime(2025, 12, 20))],
    );

    test('nothing to save yet, or recently saved', () {
      expect(backupReminder(prefs: const AppPrefs(), data: const AppData(), now: now), BackupReminder.none);
      expect(
        backupReminder(prefs: AppPrefs(lastBackupAt: now.subtract(const Duration(days: 10))), data: created, now: now),
        BackupReminder.none,
      );
    });

    test('never or too long ago', () {
      expect(backupReminder(prefs: const AppPrefs(), data: created, now: now), BackupReminder.never);
      expect(
        backupReminder(prefs: AppPrefs(lastBackupAt: now.subtract(const Duration(days: 40))), data: created, now: now),
        BackupReminder.outdated,
      );
      expect(
        backupReminder(prefs: const AppPrefs(backupReminderDays: 0), data: created, now: now),
        BackupReminder.none,
      );
      expect(
        backupReminder(prefs: AppPrefs(backupReminderSnoozedUntil: now.add(const Duration(days: 1))), data: created, now: now),
        BackupReminder.none,
      );
    });

    test('a working automatic backup needs no reminder, a failing one does', () {
      final withPassword = created.copyWith(autoBackupPassword: () => 'secret-123');
      const ok = AppPrefs(autoBackup: AutoBackupPrefs(folderUri: 'content://x'));
      const failed = AppPrefs(autoBackup: AutoBackupPrefs(folderUri: 'content://x', failed: true));
      expect(backupReminder(prefs: ok, data: withPassword, now: now), BackupReminder.none);
      expect(backupReminder(prefs: failed, data: withPassword, now: now), BackupReminder.autoFailed);
    });

    test('only old automatic backups are cleaned up', () {
      final auto = [for (var d = 1; d <= 12; d++) autoBackupFileName(DateTime(2026, 1, d))];
      final names = [...auto.reversed, 'finanzuebersicht-2026-01-01.backup', 'notes.txt'];
      expect(outdatedAutoBackups(names), [auto[0], auto[1]]);
      expect(outdatedAutoBackups(auto.take(10)), isEmpty);
      expect(autoBackupFileName(DateTime(2026, 3, 7)), 'finanzuebersicht-auto-2026-03-07.backup');
    });
  });

  test('chart axes use round values', () {
    expect(niceTicks(0, 1300, count: 3), [0, 500, 1000, 1500]);
    expect(niceTicks(23558, 33160), [22500, 25000, 27500, 30000, 32500, 35000]);
    expect(niceTicks(-340, 1290, count: 3), [-1000, 0, 1000, 2000]);
    expect(niceTicks(28000, 28000, count: 3), [27950, 28000, 28050]);
  });
}

import 'package:financeoverview/data/models.dart';
import 'package:financeoverview/domain/investment_calc.dart';
import 'package:financeoverview/domain/overview_calc.dart';
import 'package:financeoverview/domain/purchase_calc.dart';
import 'package:financeoverview/domain/recurring_calc.dart';
import 'package:financeoverview/domain/savings_goal_calc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

const eps = 1e-6;

void main() {
  final today = DateTime(2026, 2, 15);

  group('recurring', () {
    test('rhythm factors match the spreadsheet', () {
      expect(rhythmFactor(Rhythm.weekly), closeTo(52 / 12, eps));
      expect(rhythmFactor(Rhythm.monthly), 1);
      expect(rhythmFactor(Rhythm.bimonthly), 0.5);
      expect(rhythmFactor(Rhythm.quarterly), closeTo(1 / 3, eps));
      expect(rhythmFactor(Rhythm.halfYearly), closeTo(1 / 6, eps));
      expect(rhythmFactor(Rhythm.yearly), closeTo(1 / 12, eps));
    });

    test('inactive, not started or ended items count as 0', () {
      const base = RecurringItem(id: 'x', name: 'x', type: RecurringType.expense, amount: 100);
      expect(monthlyAmount(base, today), 100);
      expect(monthlyAmount(base.copyWith(active: false), today), 0);
      expect(monthlyAmount(base.copyWith(start: () => DateTime(2026, 2, 16)), today), 0);
      expect(monthlyAmount(base.copyWith(start: () => today), today), 100);
      expect(monthlyAmount(base.copyWith(end: () => DateTime(2026, 2, 14)), today), 0);
      expect(monthlyAmount(base.copyWith(end: () => today), today), 100);
    });

    test('summary splits savings by target account behaviour', () {
      final s = summarizeRecurring(TestData.build(), today);
      expect(s.fixedIncome, 3000);
      expect(s.fixedExpenses, closeTo(1100, eps));
      expect(s.savingsTotal, 600);
      expect(s.savingsInvested, 300);
      expect(s.savingsLeavingLiquid, 400);
      expect(s.free, closeTo(1300, eps));
      expect(s.savingsRate, closeTo(0.2, eps));
      expect(s.expensesByCategory['housing'], 1000);
      expect(s.expensesByCategory['insurance'], closeTo(100, eps));
    });
  });

  group('overview', () {
    final data = TestData.build();
    final rows = balanceHistory(data);
    final recurring = summarizeRecurring(data, today);
    final overview = buildOverview(data, rows, recurring);

    test('empty accounts keep the previous balance', () {
      expect(rows.map((r) => r.total).toList(), [4000, 4500, 5200, 5100]);
      expect(rows[2].balanceOf('a'), 1500);
      expect(rows[3].balanceOf('b'), 5600);
      expect(rows[3].debt, 1900);
    });

    test('deltas since previous entry and since 1 January', () {
      expect(overview.total, 5100);
      expect(overview.liquid, 1400);
      expect(overview.invested, 5600);
      expect(overview.deltaSincePrevious, -100);
      // Year start = last entry on or before 1.1. (s2, total 4500).
      expect(overview.yearStart!.snapshot.id, 's2');
      expect(overview.deltaSinceYearStart, 600);

      final giro = overview.accounts.firstWhere((a) => a.account.id == 'a');
      expect(giro.deltaSincePrevious, -100);
      expect(giro.deltaSinceYearStart, -100);
      expect(giro.share, closeTo(0.2, eps));
      final loan = overview.accounts.firstWhere((a) => a.account.id == 'c');
      expect(loan.share, isNull);
      expect(loan.deltaSinceYearStart, -100);
    });

    test('year start falls back to the first entry', () {
      final onlyThisYear = data.copyWith(snapshots: data.snapshots.skip(2).toList());
      final r = balanceHistory(onlyThisYear);
      final o = buildOverview(onlyThisYear, r, recurring);
      expect(o.yearStart!.snapshot.id, 's3');
    });

    test('single entry: previous is the same row', () {
      final one = data.copyWith(snapshots: [data.snapshots.first]);
      final o = buildOverview(one, balanceHistory(one), recurring);
      expect(o.deltaSincePrevious, 0);
      expect(o.lastPeriod, isNull);
    });

    test('estimated variable expenses and investment return', () {
      final p = overview.lastPeriod!;
      expect(p.days, 10);
      expect(p.deltaTotal, -100);
      // (3000 − 1100 − 400) × 10 / 30.4375 − (−100)
      expect(p.variableExpenses, closeTo(592.8131416837782, eps));
      // (5600 − 5600) − 300 × 10 / 30.4375
      expect(p.investmentReturn, closeTo(-98.56262833675565, eps));
    });
  });

  group('monthly spending', () {
    TransactionEntry tx(DateTime d, double amount, {bool income = false, String? cat}) => TransactionEntry(
          id: '$d$amount',
          date: d,
          amount: amount,
          isIncome: income,
          categoryId: cat,
          createdAt: d,
        );

    final data = TestData.build(transactions: [
      tx(DateTime(2026, 2, 5), 80, cat: 'groceries'),
      tx(DateTime(2026, 2, 20), 20, cat: 'groceries'),
      tx(DateTime(2026, 2, 7), 50, income: true),
      tx(DateTime(2026, 3, 1), 999, cat: 'groceries'),
    ]);
    final m = monthlySpending(data, DateTime(2026, 2), today, balanceHistory(data));

    test('combines standing orders and single bookings per category', () {
      expect(m.categories.map((c) => c.categoryId).toList(), ['housing', 'insurance', 'groceries']);
      expect(m.categories.last.single, 100);
      expect(m.categories.last.fixed, 0);
      expect(m.singleIncome, 50);
      expect(m.categorized, closeTo(1200, eps));
    });

    test('unassigned = estimate minus net single bookings', () {
      // Only the period 31.1.–10.2. overlaps February, fully.
      expect(m.estimatedVariable, closeTo(592.8131416837782, eps));
      expect(m.unassigned, closeTo(592.8131416837782 - 50, eps));
    });

    test('periods are prorated by their overlap with the month', () {
      final jan = monthlySpending(data, DateTime(2026, 1), today, balanceHistory(data));
      // s1→s2 (20.12.–1.1.): 1 of 12 days in January; s2→s3 fully; s3→s4 not at all.
      final rows = balanceHistory(data);
      final rec = summarizeRecurring(data, DateTime(2026, 1, 31));
      final p1 = estimatePeriod(rows[0], rows[1], rec).variableExpenses;
      final p2 = estimatePeriod(rows[1], rows[2], rec).variableExpenses;
      expect(jan.estimatedVariable, closeTo(p1 / 12 + p2, eps));
    });

    test('no entries in a month means no estimate', () {
      final dec = monthlySpending(data, DateTime(2025, 11), today, balanceHistory(data));
      expect(dec.estimatedVariable, isNull);
      expect(dec.unassigned, 0);
    });
  });

  group('investments', () {
    const plan = InvestmentPlan(
      annualBudget: 1000,
      limitMarkup: 0.01,
      feePerOrder: 2,
      positions: [
        EtfPosition(id: 'p1', name: 'Fonds A', share: 0.5, manualPrice: 8),
        EtfPosition(id: 'p2', name: 'Fonds B', share: 0.3, manualPrice: 25.555, onlinePrice: 26),
        EtfPosition(id: 'p3', name: 'Fonds C', share: 0.2),
      ],
    );

    test('limit, whole units, rest and fees', () {
      final r = calculateInvestments(plan, onlineEnabled: true);
      expect(r.rows[0].limit, 8.08);
      expect(r.rows[0].wholeUnits, 61);
      expect(r.rows[0].wholeCost, closeTo(492.88, eps));
      expect(r.rows[0].unitsByAmount, 62.5);
      expect(r.rows[1].source, PriceSource.online);
      expect(r.rows[1].limit, 26.26);
      expect(r.rows[1].wholeUnits, 11);
      expect(r.rows[1].unitsByAmount, 11.538);
      expect(r.rows[2].source, PriceSource.none);
      expect(r.totalWholeCost, closeTo(781.74, eps));
      expect(r.rest, closeTo(218.26, eps));
      expect(r.fees, 6);
      expect(r.feeShare, closeTo(0.006, eps));
      expect(r.sharesValid, isTrue);
      expect(r.cheapest!.id, 'p1');
    });

    test('manual price is used when online prices are off', () {
      final r = calculateInvestments(plan, onlineEnabled: false);
      expect(r.rows[1].source, PriceSource.manual);
      expect(r.rows[1].limit, 25.81);
    });

    test('rounding: 3 decimals below 10 €, else 2', () {
      expect(roundTo(7.657 * 1.005, 3), 7.695);
      expect(roundTo(49.016 * 1.005, 2), 49.26);
      expect(roundTo(11.908 * 1.005, 2), 11.97);
    });

    test('warns when shares do not add up to 100 %', () {
      final r = calculateInvestments(plan.copyWith(positions: plan.positions.take(2).toList()), onlineEnabled: true);
      expect(r.sharesValid, isFalse);
    });
  });

  group('purchase calculator', () {
    const situation = FinancialSituation(
      netWorth: 50000,
      liquid: 20000,
      monthlyIncome: 3000,
      monthlyFixedExpenses: 1100,
      monthlySavings: 600,
      monthlyFree: 1300,
      savingsRate: 0.2,
    );
    const inputs = PurchaseInputs(
      label: 'Motorrad',
      price: 10000,
      fromSavings: 4000,
      loanRate: 0.05,
      loanMonths: 36,
      monthlyCost: 100,
      usageYears: 5,
      residualValue: 3000,
      expectedReturn: 0.06,
      emergencyFund: 3000,
      targetSavingsRate: 0.7,
    );

    test('matches PMT / FV based spreadsheet results', () {
      final r = calculatePurchase(inputs, situation);
      expect(r.loanAmount, 6000);
      expect(r.loanPayment, closeTo(179.8253826279934, eps));
      expect(r.interestTotal, closeTo(473.7137746077624, eps));
      expect(r.liquidAfter, 16000);
      expect(r.shareOfWealth, closeTo(0.08, eps));
      expect(r.monthsOfSavingsLost, closeTo(6.666666666666667, eps));
      expect(r.monthsToSaveUp, closeTo(7.6923076923076925, eps));
      expect(r.freeAfter, closeTo(1020.1746173720067, eps));
      expect(r.savingsRateAfter, closeTo(0.2, eps));
      expect(r.totalCost, closeTo(13473.713774607762, eps));
      expect(r.costPerMonth, closeTo(224.5618962434627, eps));
      expect(r.remainingDebt, 0);
      expect(r.wealthDisadvantage, closeTo(17303.016711583954, 1e-4));
      expect(r.verdict, PurchaseVerdict.affordable);
    });

    test('remaining debt when the loan runs longer than the usage', () {
      final r = calculatePurchase(inputs.copyWith(loanMonths: 84, usageYears: 3), situation);
      expect(r.loanPayment, closeTo(84.8034544314423, eps));
      expect(r.remainingDebt, closeTo(3682.416665161358, 1e-4));
    });

    test('verdict order follows the spreadsheet', () {
      expect(calculatePurchase(inputs.copyWith(fromSavings: 18000), situation).verdict,
          PurchaseVerdict.belowEmergencyFund);
      expect(calculatePurchase(inputs.copyWith(monthlyCost: 2000), situation).verdict,
          PurchaseVerdict.costsExceedFree);
      expect(
        calculatePurchase(inputs, situation.copyWithRate(0.3)).verdict,
        PurchaseVerdict.savingsRateDrops,
      );
      expect(
        calculatePurchase(inputs.copyWith(fromSavings: 14000, price: 14000), situation).verdict,
        PurchaseVerdict.largeShareOfWealth,
      );
    });
  });

  group('savings goal', () {
    final data = TestData.build();
    final rows = balanceHistory(data);
    final recurring = summarizeRecurring(data, today);
    final overview = buildOverview(data, rows, recurring);

    test('savings rate goal', () {
      final s = savingsGoalStatus(
        data.copyWith(savingsGoal: const SavingsGoalSettings(targetRate: 0.4)),
        overview,
        recurring,
      );
      expect(s.primary!.progress, closeTo(0.5, eps));
    });

    test('net worth goal', () {
      final s = savingsGoalStatus(
        data.copyWith(
          savingsGoal: const SavingsGoalSettings(mode: SavingsGoalMode.netWorth, netWorthTarget: 10200),
        ),
        overview,
        recurring,
      );
      expect(s.primary!.progress, closeTo(0.5, eps));
    });

    test('per-account goals prefer the pinned account', () {
      final withGoals = data.copyWith(
        accounts: [
          TestData.giro.copyWith(savingsGoal: () => 2800),
          TestData.depot.copyWith(savingsGoal: () => 11200),
          TestData.loan,
        ],
        savingsGoal: const SavingsGoalSettings(mode: SavingsGoalMode.perAccount, pinnedAccountId: 'b'),
      );
      final o = buildOverview(withGoals, balanceHistory(withGoals), recurring);
      final s = savingsGoalStatus(withGoals, o, recurring);
      expect(s.accountGoals, hasLength(2));
      expect(s.primary!.account!.id, 'b');
      expect(s.primary!.progress, closeTo(0.5, eps));
    });
  });
}

extension on FinancialSituation {
  FinancialSituation copyWithRate(double rate) => FinancialSituation(
        netWorth: netWorth,
        liquid: liquid,
        monthlyIncome: monthlyIncome,
        monthlyFixedExpenses: monthlyFixedExpenses,
        monthlySavings: monthlySavings,
        monthlyFree: monthlyFree,
        savingsRate: rate,
      );
}

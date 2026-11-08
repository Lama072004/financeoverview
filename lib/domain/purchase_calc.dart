import 'dart:math' as math;

import '../data/models.dart';

// Spreadsheet finance functions (end-of-period payments).

/// PMT(rate, n, -pv): payment that pays off [principal] in [periods].
double payment(double rate, int periods, double principal) {
  if (periods <= 0) return 0;
  if (rate == 0) return principal / periods;
  return principal * rate / (1 - math.pow(1 + rate, -periods));
}

/// PV(rate, n, -pmt): present value of [periods] payments.
double presentValue(double rate, int periods, double pmt) {
  if (periods <= 0) return 0;
  if (rate == 0) return pmt * periods;
  return pmt * (1 - math.pow(1 + rate, -periods)) / rate;
}

/// FV(rate, n, -pmt): future value of [periods] payments.
double futureValue(double rate, int periods, double pmt) {
  if (periods <= 0) return 0;
  if (rate == 0) return pmt * periods;
  return pmt * (math.pow(1 + rate, periods) - 1) / rate;
}

/// The current situation, taken from the overview.
class FinancialSituation {
  const FinancialSituation({
    required this.netWorth,
    required this.liquid,
    required this.monthlyIncome,
    required this.monthlyFixedExpenses,
    required this.monthlySavings,
    required this.monthlyFree,
    required this.savingsRate,
  });

  final double netWorth;
  final double liquid;
  final double monthlyIncome;
  final double monthlyFixedExpenses;
  final double monthlySavings;
  final double monthlyFree;
  final double savingsRate;
}

enum PurchaseVerdict {
  /// Liquid money drops below the emergency fund.
  belowEmergencyFund,

  /// Running costs exceed the free monthly amount.
  costsExceedFree,

  /// Affordable, but the savings rate drops below the target.
  savingsRateDrops,

  /// Affordable, but more than 25 % of the net worth.
  largeShareOfWealth,

  /// Affordable: emergency fund stays, savings plans continue.
  affordable,
}

class PurchaseResult {
  const PurchaseResult({
    required this.loanAmount,
    required this.loanPayment,
    required this.interestTotal,
    required this.liquidAfter,
    required this.shareOfWealth,
    required this.monthsOfSavingsLost,
    required this.monthsToSaveUp,
    required this.extraMonthly,
    required this.freeAfter,
    required this.savingsRateAfter,
    required this.totalCost,
    required this.costPerMonth,
    required this.remainingDebt,
    required this.wealthDisadvantage,
    required this.verdict,
  });

  final double loanAmount;
  final double loanPayment;
  final double interestTotal;
  final double liquidAfter;
  final double shareOfWealth;
  final double? monthsOfSavingsLost;
  final double? monthsToSaveUp;
  final double extraMonthly;
  final double freeAfter;
  final double savingsRateAfter;

  /// Depreciation + running costs + interest over the usage period.
  final double totalCost;
  final double costPerMonth;

  /// Loan still open at the end of the usage period.
  final double remainingDebt;

  /// How much less wealth you have at the end compared to investing instead.
  final double wealthDisadvantage;
  final PurchaseVerdict verdict;
}

PurchaseResult calculatePurchase(PurchaseInputs i, FinancialSituation s) {
  final loan = math.max(0.0, i.price - i.fromSavings);
  final monthlyLoanRate = i.loanRate / 12;
  final pmt = loan == 0 ? 0.0 : payment(monthlyLoanRate, i.loanMonths, loan);
  final interest = loan == 0 ? 0.0 : pmt * i.loanMonths - loan;
  final liquidAfter = s.liquid - i.fromSavings;
  final share = s.netWorth == 0 ? 0.0 : i.fromSavings / s.netWorth;
  final monthsLost = s.monthlySavings == 0 ? null : i.fromSavings / s.monthlySavings;
  final monthsToSave = s.monthlyFree <= 0 ? null : i.price / s.monthlyFree;
  final extra = i.monthlyCost + pmt;
  final freeAfter = s.monthlyFree - extra;
  final rateAfter =
      s.monthlyIncome == 0 ? 0.0 : (s.monthlySavings - math.max(0.0, -freeAfter)) / s.monthlyIncome;
  final usageMonths = i.usageYears * 12;
  final totalCost = i.price - i.residualValue + i.monthlyCost * usageMonths + interest;
  final costPerMonth = i.usageYears == 0 ? 0.0 : totalCost / usageMonths;
  final remaining = pmt > 0 && i.loanMonths > usageMonths
      ? presentValue(monthlyLoanRate, i.loanMonths - usageMonths, pmt)
      : 0.0;

  final r = i.expectedReturn;
  final rm = r / 12;
  final paidMonths = math.min(i.loanMonths, usageMonths);
  final disadvantage = i.fromSavings * math.pow(1 + r, i.usageYears) +
      futureValue(rm, usageMonths, i.monthlyCost) +
      (pmt == 0 ? 0 : futureValue(rm, paidMonths, pmt) * math.pow(1 + rm, usageMonths - paidMonths)) +
      remaining -
      i.residualValue;

  final PurchaseVerdict verdict;
  if (liquidAfter < i.emergencyFund) {
    verdict = PurchaseVerdict.belowEmergencyFund;
  } else if (freeAfter < 0) {
    verdict = PurchaseVerdict.costsExceedFree;
  } else if (rateAfter < s.savingsRate && rateAfter < i.targetSavingsRate) {
    verdict = PurchaseVerdict.savingsRateDrops;
  } else if (share > 0.25) {
    verdict = PurchaseVerdict.largeShareOfWealth;
  } else {
    verdict = PurchaseVerdict.affordable;
  }

  return PurchaseResult(
    loanAmount: loan,
    loanPayment: pmt,
    interestTotal: interest,
    liquidAfter: liquidAfter,
    shareOfWealth: share,
    monthsOfSavingsLost: monthsLost,
    monthsToSaveUp: monthsToSave,
    extraMonthly: extra,
    freeAfter: freeAfter,
    savingsRateAfter: rateAfter,
    totalCost: totalCost,
    costPerMonth: costPerMonth,
    remainingDebt: remaining,
    wealthDisadvantage: disadvantage.toDouble(),
    verdict: verdict,
  );
}

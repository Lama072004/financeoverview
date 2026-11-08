import '../data/models.dart';

/// Conversion to a monthly amount ("Faktor pro Monat" in the spreadsheet).
double rhythmFactor(Rhythm rhythm) => switch (rhythm) {
      Rhythm.weekly => 52 / 12,
      Rhythm.monthly => 1,
      Rhythm.bimonthly => 1 / 2,
      Rhythm.quarterly => 1 / 3,
      Rhythm.halfYearly => 1 / 6,
      Rhythm.yearly => 1 / 12,
    };

/// Active and [on] lies between start and end (both inclusive, both optional).
bool isEffective(RecurringItem item, DateTime on) =>
    item.active &&
    (item.start == null || !item.start!.isAfter(on)) &&
    (item.end == null || !item.end!.isBefore(on));

/// "pro Monat (€)": 0 when inactive or outside start/end.
double monthlyAmount(RecurringItem item, DateTime on) =>
    isEffective(item, on) ? item.amount * rhythmFactor(item.rhythm) : 0;

/// The "Daueraufträge & Abos" block of the overview sheet, per month.
class RecurringSummary {
  const RecurringSummary({
    required this.fixedIncome,
    required this.fixedExpenses,
    required this.savingsTotal,
    required this.savingsInvested,
    required this.savingsLeavingLiquid,
    required this.expensesByCategory,
  });

  final double fixedIncome;
  final double fixedExpenses;
  final double savingsTotal;

  /// "davon in Anlagen": savings whose target account is invested.
  final double savingsInvested;

  /// Savings that leave the liquid accounts (to invested or debt accounts).
  /// Used for the variable-spending estimate.
  final double savingsLeavingLiquid;

  /// Fixed expenses per category id (null = no category).
  final Map<String?, double> expensesByCategory;

  /// "Frei verfügbar nach Fixkosten & Sparen".
  double get free => fixedIncome - fixedExpenses - savingsTotal;

  /// "Sparquote (Sparen ÷ Einnahmen)".
  double get savingsRate => fixedIncome == 0 ? 0 : savingsTotal / fixedIncome;

  static const empty = RecurringSummary(
    fixedIncome: 0,
    fixedExpenses: 0,
    savingsTotal: 0,
    savingsInvested: 0,
    savingsLeavingLiquid: 0,
    expensesByCategory: {},
  );
}

RecurringSummary summarizeRecurring(AppData data, DateTime on) {
  var income = 0.0, expenses = 0.0, savings = 0.0, invested = 0.0, leaving = 0.0;
  final byCategory = <String?, double>{};
  for (final item in data.recurring) {
    final monthly = monthlyAmount(item, on);
    if (monthly == 0) continue;
    switch (item.type) {
      case RecurringType.income:
        income += monthly;
      case RecurringType.expense:
        expenses += monthly;
        byCategory[item.categoryId] = (byCategory[item.categoryId] ?? 0) + monthly;
      case RecurringType.saving:
        savings += monthly;
        final target = data.accountById(item.toAccountId);
        final behavior = target == null ? AccountBehavior.liquid : data.behaviorOf(target);
        if (behavior == AccountBehavior.invested) invested += monthly;
        if (behavior != AccountBehavior.liquid) leaving += monthly;
    }
  }
  return RecurringSummary(
    fixedIncome: income,
    fixedExpenses: expenses,
    savingsTotal: savings,
    savingsInvested: invested,
    savingsLeavingLiquid: leaving,
    expensesByCategory: byCategory,
  );
}

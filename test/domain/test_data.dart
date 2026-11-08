import 'package:financeoverview/data/models.dart';

/// Small synthetic data set used across the calculation tests.
/// (Deliberately unrelated to any real spreadsheet data.)
class TestData {
  static const liquid = AccountType(id: 't-l', name: 'Liquide', behavior: AccountBehavior.liquid);
  static const invested = AccountType(id: 't-i', name: 'Investiert', behavior: AccountBehavior.invested);
  static const debt = AccountType(id: 't-d', name: 'Schulden', behavior: AccountBehavior.debt);

  static const giro = Account(id: 'a', name: 'Giro', typeId: 't-l');
  static const depot = Account(id: 'b', name: 'Depot', typeId: 't-i');
  static const loan = Account(id: 'c', name: 'Kredit', typeId: 't-d');

  static const housing =
      Category(id: 'housing', name: 'Wohnen', icon: 'home', kind: CategoryKind.expense, colorIndex: 0);
  static const insurance =
      Category(id: 'insurance', name: 'Versicherung', icon: 'shield', kind: CategoryKind.expense, colorIndex: 1);
  static const groceries =
      Category(id: 'groceries', name: 'Lebensmittel', icon: 'groceries', kind: CategoryKind.expense, colorIndex: 2);

  static final recurring = [
    const RecurringItem(id: 'r1', name: 'Lohn', type: RecurringType.income, amount: 3000),
    const RecurringItem(
        id: 'r2', name: 'Miete', type: RecurringType.expense, categoryId: 'housing', amount: 1000),
    const RecurringItem(
      id: 'r3',
      name: 'Haushalt',
      type: RecurringType.expense,
      categoryId: 'insurance',
      amount: 1200,
      rhythm: Rhythm.yearly,
    ),
    const RecurringItem(id: 'r4', name: 'ETF', type: RecurringType.saving, amount: 300, toAccountId: 'b'),
    const RecurringItem(id: 'r5', name: 'Tagesgeld', type: RecurringType.saving, amount: 200, toAccountId: 'a'),
    const RecurringItem(id: 'r6', name: 'Sondertilgung', type: RecurringType.saving, amount: 100, toAccountId: 'c'),
    const RecurringItem(id: 'r7', name: 'Alt', type: RecurringType.expense, amount: 999, active: false),
  ];

  static Snapshot snap(String id, DateTime date, Map<String, double> values) =>
      Snapshot(id: id, date: date, values: values, createdAt: DateTime(2026));

  static final snapshots = [
    snap('s1', DateTime(2025, 12, 20), {'a': 1000, 'b': 5000, 'c': 2000}),
    snap('s2', DateTime(2026, 1, 1), {'a': 1500}),
    snap('s3', DateTime(2026, 1, 31), {'b': 5600, 'c': 1900}),
    snap('s4', DateTime(2026, 2, 10), {'a': 1400}),
  ];

  static AppData build({List<TransactionEntry> transactions = const []}) => AppData(
        accountTypes: const [liquid, invested, debt],
        accounts: const [giro, depot, loan],
        categories: const [housing, insurance, groceries],
        recurring: recurring,
        snapshots: AppData.sortSnapshots(snapshots),
        transactions: transactions,
      );
}

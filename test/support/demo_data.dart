import 'dart:math' as math;

import 'package:financeoverview/data/defaults.dart';
import 'package:financeoverview/data/models.dart';

/// Invented demo data for screenshots and widget tests.
AppData demoData({DateTime? today}) {
  final now = today ?? DateTime(2026, 10, 18);
  final base = initialAppData(german: true);
  final liquid = base.accountTypes[0];
  final invested = base.accountTypes[1];
  const debtType = AccountType(id: 'type-debt', name: 'Schulden', behavior: AccountBehavior.debt);
  String cat(String name) => base.categories.firstWhere((c) => c.name == name).id;

  const giro = Account(id: 'giro', name: 'Girokonto', typeId: '', icon: 'bank', colorIndex: 0);
  const tagesgeld = Account(id: 'tg', name: 'Tagesgeld', typeId: '', icon: 'savings', colorIndex: 1, savingsGoal: 10000);
  const depot = Account(id: 'depot', name: 'ETF-Depot', typeId: '', icon: 'chart', colorIndex: 2);
  const gold = Account(id: 'gold', name: 'Gold', typeId: '', icon: 'gold', colorIndex: 7);
  const kredit = Account(id: 'kredit', name: 'Autokredit', typeId: '', icon: 'loan', colorIndex: 10);

  final accounts = [
    giro.copyWith(typeId: liquid.id),
    tagesgeld.copyWith(typeId: liquid.id),
    depot.copyWith(typeId: invested.id),
    gold.copyWith(typeId: invested.id),
    kredit.copyWith(typeId: debtType.id),
  ];

  // Twelve monthly entries plus a mid-month update.
  final snapshots = <Snapshot>[];
  for (var i = 0; i < 12; i++) {
    final date = DateTime(now.year - 1, now.month + i + 1, 2);
    final wiggle = (i % 3 - 1) * 140.0;
    snapshots.add(Snapshot(
      id: 's$i',
      date: date,
      createdAt: date,
      values: {
        'giro': 1450 + wiggle + i * 12,
        'tg': 6200 + i * 210,
        'depot': 14800 + i * 520 + (i == 6 ? -900 : 0) + (i % 2) * 260,
        if (i % 3 == 0) 'gold': 3100 + i * 35,
        'kredit': 9600 - i * 250,
      },
    ));
  }
  final last = DateTime(now.year, now.month, 14);
  snapshots.add(Snapshot(
    id: 's-mid',
    date: last,
    createdAt: last,
    note: 'Nach dem Einkauf',
    values: {'giro': 1180.40, 'depot': 21390.15},
  ));

  final recurring = [
    RecurringItem(id: 'r1', name: 'Gehalt', type: RecurringType.income, categoryId: cat('Gehalt'), amount: 2850, toAccountId: 'giro'),
    RecurringItem(id: 'r2', name: 'Miete', type: RecurringType.expense, categoryId: cat('Wohnen'), amount: 780, fromAccountId: 'giro'),
    RecurringItem(id: 'r3', name: 'Strom', type: RecurringType.expense, categoryId: cat('Wohnen'), amount: 58, fromAccountId: 'giro'),
    RecurringItem(id: 'r4', name: 'Handyvertrag', type: RecurringType.expense, categoryId: cat('Handy & Internet'), amount: 24.9),
    RecurringItem(id: 'r5', name: 'Streaming', type: RecurringType.expense, categoryId: cat('Abos & Streaming'), amount: 13.99),
    RecurringItem(
      id: 'r6',
      name: 'Haushaltsversicherung',
      type: RecurringType.expense,
      categoryId: cat('Versicherung'),
      amount: 420,
      rhythm: Rhythm.yearly,
    ),
    RecurringItem(id: 'r7', name: 'Kreditrate', type: RecurringType.expense, categoryId: cat('Kredit'), amount: 250),
    RecurringItem(id: 'r8', name: 'Fitnessstudio', type: RecurringType.expense, categoryId: cat('Sport & Freizeit'), amount: 39),
    RecurringItem(id: 'r9', name: 'ETF-Sparplan', type: RecurringType.saving, categoryId: cat('Sparen'), amount: 400, toAccountId: 'depot'),
    RecurringItem(id: 'r10', name: 'Notgroschen', type: RecurringType.saving, categoryId: cat('Sparen'), amount: 200, toAccountId: 'tg'),
    const RecurringItem(id: 'r11', name: 'Alter Vertrag', type: RecurringType.expense, amount: 9.99, active: false),
  ];

  TransactionEntry tx(int day, double amount, String category, {bool income = false, String note = ''}) {
    final d = DateTime(now.year, now.month, day);
    return TransactionEntry(
      id: 't$day$amount',
      date: d,
      amount: amount,
      isIncome: income,
      categoryId: cat(category),
      accountId: 'giro',
      note: note,
      createdAt: d,
    );
  }

  final transactions = [
    tx(3, 86.40, 'Lebensmittel', note: 'Wocheneinkauf'),
    tx(6, 42.10, 'Lebensmittel'),
    tx(8, 64.00, 'Mobilität', note: 'Tanken'),
    tx(10, 120.00, 'Sonstige Einnahmen', income: true, note: 'Verkauf Fahrrad'),
    tx(11, 38.50, 'Sport & Freizeit', note: 'Konzert'),
    tx(12, 71.25, 'Lebensmittel'),
    tx(13, 24.90, 'Gesundheit', note: 'Apotheke'),
  ];

  return base.copyWith(
    accountTypes: [...base.accountTypes, debtType],
    accounts: accounts,
    snapshots: snapshots,
    recurring: recurring,
    transactions: transactions,
    savingsGoal: const SavingsGoalSettings(targetRate: 0.25),
    investments: const InvestmentPlan(
      annualBudget: 1200,
      limitMarkup: 0.005,
      feePerOrder: 4.9,
      positions: [
        EtfPosition(id: 'e1', name: 'Welt-ETF Acc', isin: 'XX0000000001', share: 0.7, manualPrice: 104.32),
        EtfPosition(id: 'e2', name: 'Schwellenländer-ETF', isin: 'XX0000000002', share: 0.2, manualPrice: 31.87),
        EtfPosition(id: 'e3', name: 'Europa Small Caps', isin: 'XX0000000003', share: 0.1, manualPrice: 8.41),
      ],
    ),
    purchase: const PurchaseInputs(
      label: 'E-Bike',
      price: 3200,
      fromSavings: 1200,
      loanRate: 0.049,
      loanMonths: 24,
      monthlyCost: 15,
      usageYears: 5,
      residualValue: 600,
      emergencyFund: 3000,
      targetSavingsRate: 0.25,
    ),
  );
}

/// Three invented years of monthly entries and bookings, for the review,
/// the forecast and the PDF report.
AppData longDemoData({DateTime? today}) {
  final now = today ?? DateTime(2026, 10, 18);
  final base = demoData(today: now);
  String cat(String name) => base.categories.firstWhere((c) => c.name == name).id;

  final snapshots = <Snapshot>[];
  for (var i = 0; i < 36; i++) {
    final date = DateTime(now.year - 3, now.month + i + 1, 2);
    snapshots.add(Snapshot(
      id: 'l$i',
      date: date,
      createdAt: date,
      values: {
        'giro': 1300 + (i % 4) * 95.0 + i * 4,
        'tg': 3000 + i * 190.0,
        'depot': 6000 + i * 430.0 + 1100 * math.sin(i / 4),
        'gold': 2600 + i * 30.0,
        'kredit': math.max(0, 12000 - i * 250.0),
      },
    ));
  }
  final mid = DateTime(now.year, now.month, 14);
  snapshots.add(Snapshot(id: 'l-mid', date: mid, createdAt: mid, values: {'giro': 1210.0, 'depot': 21900.0}));

  final transactions = <TransactionEntry>[];
  for (var m = 0; m < 18; m++) {
    for (final (day, amount, category) in [(4, 96.0 + m * 3, 'Lebensmittel'), (9, 55.0 + (m % 3) * 20, 'Mobilität'), (20, 31.0 + (m % 5) * 9, 'Sport & Freizeit')]) {
      final d = DateTime(now.year, now.month - 17 + m, day);
      if (d.isAfter(now)) continue;
      transactions.add(TransactionEntry(
        id: 'lt$m-$day',
        date: d,
        amount: amount,
        isIncome: false,
        categoryId: cat(category),
        accountId: 'giro',
        createdAt: d,
      ));
    }
  }

  return base.copyWith(
    snapshots: snapshots,
    transactions: transactions,
    savingsGoal: const SavingsGoalSettings(mode: SavingsGoalMode.netWorth, netWorthTarget: 60000),
  );
}

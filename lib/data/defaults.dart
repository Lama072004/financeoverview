import '../core/ids.dart';
import 'models.dart';

/// Starting point of a fresh vault: no accounts and no money, only the
/// structure (account types, categories, dashboard layout). The user's
/// spreadsheet data is never copied into the app.
AppData initialAppData({required bool german}) {
  String t(String de, String en) => german ? de : en;

  final types = [
    AccountType(id: newId(), name: t('Liquide', 'Liquid'), behavior: AccountBehavior.liquid),
    AccountType(id: newId(), name: t('Investiert', 'Invested'), behavior: AccountBehavior.invested),
  ];

  var color = 0;
  Category cat(String de, String en, String icon, CategoryKind kind) =>
      Category(id: newId(), name: t(de, en), icon: icon, kind: kind, colorIndex: color++);

  final categories = [
    cat('Gehalt', 'Salary', 'salary', CategoryKind.income),
    cat('Sonstige Einnahmen', 'Other income', 'income', CategoryKind.income),
    cat('Wohnen', 'Housing', 'home', CategoryKind.expense),
    cat('Mobilität', 'Mobility', 'car', CategoryKind.expense),
    cat('Versicherung', 'Insurance', 'shield', CategoryKind.expense),
    cat('Handy & Internet', 'Phone & internet', 'phone', CategoryKind.expense),
    cat('Abos & Streaming', 'Subscriptions', 'subscription', CategoryKind.expense),
    cat('Sport & Freizeit', 'Sports & leisure', 'sport', CategoryKind.expense),
    cat('Lebensmittel', 'Groceries', 'groceries', CategoryKind.expense),
    cat('Bildung', 'Education', 'education', CategoryKind.expense),
    cat('Gesundheit', 'Health', 'health', CategoryKind.expense),
    cat('Kredit', 'Loan', 'loan', CategoryKind.expense),
    cat('Sparen', 'Savings', 'savings', CategoryKind.expense),
    cat('Sonstiges', 'Other', 'other', CategoryKind.expense),
  ];

  return AppData(
    accountTypes: types,
    categories: categories,
    dashboard: defaultDashboard,
  );
}

/// Order from the design brief: balance on top, spending donut, savings goal,
/// categories – followed by the remaining spreadsheet views.
const defaultDashboard = [
  DashboardCardConfig(type: DashboardCardType.netWorth),
  DashboardCardConfig(type: DashboardCardType.spendingDonut),
  DashboardCardConfig(type: DashboardCardType.savingsGoal),
  DashboardCardConfig(type: DashboardCardType.categories),
  DashboardCardConfig(type: DashboardCardType.netWorthChart, size: CardSize.large),
  DashboardCardConfig(type: DashboardCardType.accounts),
  DashboardCardConfig(type: DashboardCardType.recurringSummary),
  DashboardCardConfig(type: DashboardCardType.lastPeriod),
];

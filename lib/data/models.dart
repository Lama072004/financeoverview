import '../core/dates.dart';

// ---------------------------------------------------------------------------
// JSON helpers
// ---------------------------------------------------------------------------

double _d(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;
double? _dn(Object? v) => v is num ? v.toDouble() : null;
int _i(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
String _s(Object? v, [String fallback = '']) => v is String ? v : fallback;
String? _sn(Object? v) => v is String && v.isNotEmpty ? v : null;
bool _b(Object? v, [bool fallback = false]) => v is bool ? v : fallback;
List<Map<String, Object?>> _list(Object? v) =>
    v is List ? v.whereType<Map>().map((e) => e.cast<String, Object?>()).toList() : const [];
T _enum<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((e) => e.name == name, orElse: () => fallback);

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

/// How an account type is treated in the calculations.
enum AccountBehavior {
  /// Bank account or cash – used for income and expenses.
  liquid,

  /// Depot, funds, gold – fluctuates with the market.
  invested,

  /// Loans and other liabilities – subtracted from net worth.
  debt,
}

class AccountType {
  const AccountType({required this.id, required this.name, required this.behavior});

  final String id;
  final String name;
  final AccountBehavior behavior;

  AccountType copyWith({String? name, AccountBehavior? behavior}) =>
      AccountType(id: id, name: name ?? this.name, behavior: behavior ?? this.behavior);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'behavior': behavior.name};

  factory AccountType.fromJson(Map<String, Object?> j) => AccountType(
        id: _s(j['id']),
        name: _s(j['name']),
        behavior: _enum(AccountBehavior.values, j['behavior'], AccountBehavior.liquid),
      );
}

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.typeId,
    this.note = '',
    this.icon = 'bank',
    this.colorIndex = 0,
    this.archived = false,
    this.savingsGoal,
  });

  final String id;
  final String name;
  final String typeId;
  final String note;
  final String icon;
  final int colorIndex;

  /// Archived accounts are hidden from new entries but stay in the history.
  final bool archived;

  /// Optional target balance ("Sparziel pro Konto").
  final double? savingsGoal;

  Account copyWith({
    String? name,
    String? typeId,
    String? note,
    String? icon,
    int? colorIndex,
    bool? archived,
    double? Function()? savingsGoal,
  }) =>
      Account(
        id: id,
        name: name ?? this.name,
        typeId: typeId ?? this.typeId,
        note: note ?? this.note,
        icon: icon ?? this.icon,
        colorIndex: colorIndex ?? this.colorIndex,
        archived: archived ?? this.archived,
        savingsGoal: savingsGoal != null ? savingsGoal() : this.savingsGoal,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'typeId': typeId,
        'note': note,
        'icon': icon,
        'colorIndex': colorIndex,
        'archived': archived,
        'savingsGoal': savingsGoal,
      };

  factory Account.fromJson(Map<String, Object?> j) => Account(
        id: _s(j['id']),
        name: _s(j['name']),
        typeId: _s(j['typeId']),
        note: _s(j['note']),
        icon: _s(j['icon'], 'bank'),
        colorIndex: _i(j['colorIndex']),
        archived: _b(j['archived']),
        savingsGoal: _dn(j['savingsGoal']),
      );
}

// ---------------------------------------------------------------------------
// Balance snapshots ("Kontostände")
// ---------------------------------------------------------------------------

/// One row of the "Kontostände" sheet: a date plus the balances that were
/// entered. Accounts missing from [values] keep their previous balance.
class Snapshot {
  const Snapshot({
    required this.id,
    required this.date,
    required this.values,
    this.note = '',
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final Map<String, double> values;
  final String note;
  final DateTime createdAt;

  Snapshot copyWith({DateTime? date, Map<String, double>? values, String? note}) => Snapshot(
        id: id,
        date: date ?? this.date,
        values: values ?? this.values,
        note: note ?? this.note,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'date': encodeDate(date),
        'values': values,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Snapshot.fromJson(Map<String, Object?> j) {
    final raw = j['values'];
    final values = <String, double>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String && v is num) values[k] = v.toDouble();
      });
    }
    return Snapshot(
      id: _s(j['id']),
      date: decodeDate(_s(j['date'], '2000-01-01')),
      values: values,
      note: _s(j['note']),
      createdAt: DateTime.tryParse(_s(j['createdAt'])) ?? DateTime(2000),
    );
  }
}

// ---------------------------------------------------------------------------
// Categories
// ---------------------------------------------------------------------------

enum CategoryKind { expense, income }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.kind,
    required this.colorIndex,
  });

  final String id;
  final String name;
  final String icon;
  final CategoryKind kind;
  final int colorIndex;

  Category copyWith({String? name, String? icon, CategoryKind? kind, int? colorIndex}) => Category(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        kind: kind ?? this.kind,
        colorIndex: colorIndex ?? this.colorIndex,
      );

  Map<String, Object?> toJson() =>
      {'id': id, 'name': name, 'icon': icon, 'kind': kind.name, 'colorIndex': colorIndex};

  factory Category.fromJson(Map<String, Object?> j) => Category(
        id: _s(j['id']),
        name: _s(j['name']),
        icon: _s(j['icon'], 'category'),
        kind: _enum(CategoryKind.values, j['kind'], CategoryKind.expense),
        colorIndex: _i(j['colorIndex']),
      );
}

// ---------------------------------------------------------------------------
// Standing orders & subscriptions ("Daueraufträge")
// ---------------------------------------------------------------------------

enum RecurringType { income, expense, saving }

enum Rhythm { weekly, monthly, bimonthly, quarterly, halfYearly, yearly }

class RecurringItem {
  const RecurringItem({
    required this.id,
    required this.name,
    required this.type,
    this.categoryId,
    required this.amount,
    this.rhythm = Rhythm.monthly,
    this.dueDay,
    this.fromAccountId,
    this.toAccountId,
    this.active = true,
    this.start,
    this.end,
    this.note = '',
  });

  final String id;
  final String name;
  final RecurringType type;
  final String? categoryId;

  /// Always positive – [type] decides the direction.
  final double amount;
  final Rhythm rhythm;
  final int? dueDay;
  final String? fromAccountId;
  final String? toAccountId;
  final bool active;
  final DateTime? start;
  final DateTime? end;
  final String note;

  RecurringItem copyWith({
    String? name,
    RecurringType? type,
    String? Function()? categoryId,
    double? amount,
    Rhythm? rhythm,
    int? Function()? dueDay,
    String? Function()? fromAccountId,
    String? Function()? toAccountId,
    bool? active,
    DateTime? Function()? start,
    DateTime? Function()? end,
    String? note,
  }) =>
      RecurringItem(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        categoryId: categoryId != null ? categoryId() : this.categoryId,
        amount: amount ?? this.amount,
        rhythm: rhythm ?? this.rhythm,
        dueDay: dueDay != null ? dueDay() : this.dueDay,
        fromAccountId: fromAccountId != null ? fromAccountId() : this.fromAccountId,
        toAccountId: toAccountId != null ? toAccountId() : this.toAccountId,
        active: active ?? this.active,
        start: start != null ? start() : this.start,
        end: end != null ? end() : this.end,
        note: note ?? this.note,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'categoryId': categoryId,
        'amount': amount,
        'rhythm': rhythm.name,
        'dueDay': dueDay,
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'active': active,
        'start': start == null ? null : encodeDate(start!),
        'end': end == null ? null : encodeDate(end!),
        'note': note,
      };

  factory RecurringItem.fromJson(Map<String, Object?> j) => RecurringItem(
        id: _s(j['id']),
        name: _s(j['name']),
        type: _enum(RecurringType.values, j['type'], RecurringType.expense),
        categoryId: _sn(j['categoryId']),
        amount: _d(j['amount']),
        rhythm: _enum(Rhythm.values, j['rhythm'], Rhythm.monthly),
        dueDay: j['dueDay'] is num ? _i(j['dueDay']) : null,
        fromAccountId: _sn(j['fromAccountId']),
        toAccountId: _sn(j['toAccountId']),
        active: _b(j['active'], true),
        start: decodeDateOrNull(j['start']),
        end: decodeDateOrNull(j['end']),
        note: _s(j['note']),
      );
}

// ---------------------------------------------------------------------------
// Single bookings ("Einzelbuchungen")
// ---------------------------------------------------------------------------

/// A one-off expense or income. It does not change any account balance –
/// balances are only ever entered by hand, exactly like in the spreadsheet.
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.categoryId,
    this.accountId,
    this.note = '',
    required this.createdAt,
  });

  final String id;
  final DateTime date;

  /// Always positive.
  final double amount;
  final bool isIncome;
  final String? categoryId;
  final String? accountId;
  final String note;
  final DateTime createdAt;

  TransactionEntry copyWith({
    DateTime? date,
    double? amount,
    bool? isIncome,
    String? Function()? categoryId,
    String? Function()? accountId,
    String? note,
  }) =>
      TransactionEntry(
        id: id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        isIncome: isIncome ?? this.isIncome,
        categoryId: categoryId != null ? categoryId() : this.categoryId,
        accountId: accountId != null ? accountId() : this.accountId,
        note: note ?? this.note,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'date': encodeDate(date),
        'amount': amount,
        'isIncome': isIncome,
        'categoryId': categoryId,
        'accountId': accountId,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionEntry.fromJson(Map<String, Object?> j) => TransactionEntry(
        id: _s(j['id']),
        date: decodeDate(_s(j['date'], '2000-01-01')),
        amount: _d(j['amount']),
        isIncome: _b(j['isIncome']),
        categoryId: _sn(j['categoryId']),
        accountId: _sn(j['accountId']),
        note: _s(j['note']),
        createdAt: DateTime.tryParse(_s(j['createdAt'])) ?? DateTime(2000),
      );
}

// ---------------------------------------------------------------------------
// Investment plan ("Investitionen")
// ---------------------------------------------------------------------------

class EtfPosition {
  const EtfPosition({
    required this.id,
    required this.name,
    this.isin = '',
    this.share = 0,
    this.manualPrice,
    this.onlinePrice,
    this.onlinePriceAt,
  });

  final String id;
  final String name;
  final String isin;

  /// Share of the annual budget, 0..1.
  final double share;
  final double? manualPrice;
  final double? onlinePrice;
  final DateTime? onlinePriceAt;

  EtfPosition copyWith({
    String? name,
    String? isin,
    double? share,
    double? Function()? manualPrice,
    double? Function()? onlinePrice,
    DateTime? Function()? onlinePriceAt,
  }) =>
      EtfPosition(
        id: id,
        name: name ?? this.name,
        isin: isin ?? this.isin,
        share: share ?? this.share,
        manualPrice: manualPrice != null ? manualPrice() : this.manualPrice,
        onlinePrice: onlinePrice != null ? onlinePrice() : this.onlinePrice,
        onlinePriceAt: onlinePriceAt != null ? onlinePriceAt() : this.onlinePriceAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'isin': isin,
        'share': share,
        'manualPrice': manualPrice,
        'onlinePrice': onlinePrice,
        'onlinePriceAt': onlinePriceAt?.toIso8601String(),
      };

  factory EtfPosition.fromJson(Map<String, Object?> j) => EtfPosition(
        id: _s(j['id']),
        name: _s(j['name']),
        isin: _s(j['isin']),
        share: _d(j['share']),
        manualPrice: _dn(j['manualPrice']),
        onlinePrice: _dn(j['onlinePrice']),
        onlinePriceAt: DateTime.tryParse(_s(j['onlinePriceAt'])),
      );
}

class InvestmentPlan {
  const InvestmentPlan({
    this.annualBudget = 0,
    this.limitMarkup = 0.005,
    this.feePerOrder = 0,
    this.positions = const [],
  });

  final double annualBudget;

  /// Added on top of the price for the limit order, e.g. 0.005 = 0.5 %.
  final double limitMarkup;
  final double feePerOrder;
  final List<EtfPosition> positions;

  InvestmentPlan copyWith({
    double? annualBudget,
    double? limitMarkup,
    double? feePerOrder,
    List<EtfPosition>? positions,
  }) =>
      InvestmentPlan(
        annualBudget: annualBudget ?? this.annualBudget,
        limitMarkup: limitMarkup ?? this.limitMarkup,
        feePerOrder: feePerOrder ?? this.feePerOrder,
        positions: positions ?? this.positions,
      );

  Map<String, Object?> toJson() => {
        'annualBudget': annualBudget,
        'limitMarkup': limitMarkup,
        'feePerOrder': feePerOrder,
        'positions': positions.map((p) => p.toJson()).toList(),
      };

  factory InvestmentPlan.fromJson(Map<String, Object?> j) => InvestmentPlan(
        annualBudget: _d(j['annualBudget']),
        limitMarkup: _d(j['limitMarkup'], 0.005),
        feePerOrder: _d(j['feePerOrder']),
        positions: _list(j['positions']).map(EtfPosition.fromJson).toList(),
      );
}

// ---------------------------------------------------------------------------
// Purchase calculator ("Kaufrechner")
// ---------------------------------------------------------------------------

class PurchaseInputs {
  const PurchaseInputs({
    this.label = '',
    this.price = 0,
    this.fromSavings = 0,
    this.loanRate = 0,
    this.loanMonths = 0,
    this.monthlyCost = 0,
    this.usageYears = 0,
    this.residualValue = 0,
    this.expectedReturn = 0.06,
    this.emergencyFund = 0,
    this.targetSavingsRate = 0.2,
  });

  final String label;
  final double price;
  final double fromSavings;

  /// Yearly interest rate, e.g. 0.05.
  final double loanRate;
  final int loanMonths;
  final double monthlyCost;
  final int usageYears;
  final double residualValue;
  final double expectedReturn;
  final double emergencyFund;
  final double targetSavingsRate;

  PurchaseInputs copyWith({
    String? label,
    double? price,
    double? fromSavings,
    double? loanRate,
    int? loanMonths,
    double? monthlyCost,
    int? usageYears,
    double? residualValue,
    double? expectedReturn,
    double? emergencyFund,
    double? targetSavingsRate,
  }) =>
      PurchaseInputs(
        label: label ?? this.label,
        price: price ?? this.price,
        fromSavings: fromSavings ?? this.fromSavings,
        loanRate: loanRate ?? this.loanRate,
        loanMonths: loanMonths ?? this.loanMonths,
        monthlyCost: monthlyCost ?? this.monthlyCost,
        usageYears: usageYears ?? this.usageYears,
        residualValue: residualValue ?? this.residualValue,
        expectedReturn: expectedReturn ?? this.expectedReturn,
        emergencyFund: emergencyFund ?? this.emergencyFund,
        targetSavingsRate: targetSavingsRate ?? this.targetSavingsRate,
      );

  Map<String, Object?> toJson() => {
        'label': label,
        'price': price,
        'fromSavings': fromSavings,
        'loanRate': loanRate,
        'loanMonths': loanMonths,
        'monthlyCost': monthlyCost,
        'usageYears': usageYears,
        'residualValue': residualValue,
        'expectedReturn': expectedReturn,
        'emergencyFund': emergencyFund,
        'targetSavingsRate': targetSavingsRate,
      };

  factory PurchaseInputs.fromJson(Map<String, Object?> j) => PurchaseInputs(
        label: _s(j['label']),
        price: _d(j['price']),
        fromSavings: _d(j['fromSavings']),
        loanRate: _d(j['loanRate']),
        loanMonths: _i(j['loanMonths']),
        monthlyCost: _d(j['monthlyCost']),
        usageYears: _i(j['usageYears']),
        residualValue: _d(j['residualValue']),
        expectedReturn: _d(j['expectedReturn'], 0.06),
        emergencyFund: _d(j['emergencyFund']),
        targetSavingsRate: _d(j['targetSavingsRate'], 0.2),
      );
}

// ---------------------------------------------------------------------------
// Savings goal
// ---------------------------------------------------------------------------

enum SavingsGoalMode {
  /// Work towards a monthly savings rate.
  savingsRate,

  /// A target balance per account.
  perAccount,

  /// A target for the total net worth.
  netWorth,
}

class SavingsGoalSettings {
  const SavingsGoalSettings({
    this.mode = SavingsGoalMode.savingsRate,
    this.targetRate = 0,
    this.netWorthTarget = 0,
    this.pinnedAccountId,
  });

  final SavingsGoalMode mode;
  final double targetRate;
  final double netWorthTarget;

  /// Account shown on the dashboard in [SavingsGoalMode.perAccount].
  final String? pinnedAccountId;

  SavingsGoalSettings copyWith({
    SavingsGoalMode? mode,
    double? targetRate,
    double? netWorthTarget,
    String? Function()? pinnedAccountId,
  }) =>
      SavingsGoalSettings(
        mode: mode ?? this.mode,
        targetRate: targetRate ?? this.targetRate,
        netWorthTarget: netWorthTarget ?? this.netWorthTarget,
        pinnedAccountId: pinnedAccountId != null ? pinnedAccountId() : this.pinnedAccountId,
      );

  Map<String, Object?> toJson() => {
        'mode': mode.name,
        'targetRate': targetRate,
        'netWorthTarget': netWorthTarget,
        'pinnedAccountId': pinnedAccountId,
      };

  factory SavingsGoalSettings.fromJson(Map<String, Object?> j) => SavingsGoalSettings(
        mode: _enum(SavingsGoalMode.values, j['mode'], SavingsGoalMode.savingsRate),
        targetRate: _d(j['targetRate']),
        netWorthTarget: _d(j['netWorthTarget']),
        pinnedAccountId: _sn(j['pinnedAccountId']),
      );
}

// ---------------------------------------------------------------------------
// Projection ("Prognose")
// ---------------------------------------------------------------------------

class ProjectionSettings {
  const ProjectionSettings({this.annualReturn = 0.05, this.monthlySaving, this.monthlyInvested, this.years = 10});

  static const yearOptions = [5, 10, 20, 30];

  /// Expected yearly return of the invested accounts, e.g. 0.05.
  final double annualReturn;

  /// Own value; null = taken from the standing orders ("Sparen gesamt").
  final double? monthlySaving;

  /// Part of [monthlySaving] that is invested; null = from the standing orders.
  final double? monthlyInvested;

  /// Horizon of the chart.
  final int years;

  ProjectionSettings copyWith({
    double? annualReturn,
    double? Function()? monthlySaving,
    double? Function()? monthlyInvested,
    int? years,
  }) =>
      ProjectionSettings(
        annualReturn: annualReturn ?? this.annualReturn,
        monthlySaving: monthlySaving != null ? monthlySaving() : this.monthlySaving,
        monthlyInvested: monthlyInvested != null ? monthlyInvested() : this.monthlyInvested,
        years: years ?? this.years,
      );

  Map<String, Object?> toJson() => {
        'annualReturn': annualReturn,
        'monthlySaving': monthlySaving,
        'monthlyInvested': monthlyInvested,
        'years': years,
      };

  factory ProjectionSettings.fromJson(Map<String, Object?> j) => ProjectionSettings(
        annualReturn: _d(j['annualReturn'], 0.05),
        monthlySaving: _dn(j['monthlySaving']),
        monthlyInvested: _dn(j['monthlyInvested']),
        years: yearOptions.contains(_i(j['years'])) ? _i(j['years']) : 10,
      );
}

// ---------------------------------------------------------------------------
// Dashboard layout
// ---------------------------------------------------------------------------

enum DashboardCardType {
  netWorth,
  spendingDonut,
  savingsGoal,
  categories,
  netWorthChart,
  accounts,
  recurringSummary,
  lastPeriod,
}

enum CardSize { compact, large }

class DashboardCardConfig {
  const DashboardCardConfig({required this.type, this.visible = true, this.size = CardSize.compact});

  final DashboardCardType type;
  final bool visible;
  final CardSize size;

  DashboardCardConfig copyWith({bool? visible, CardSize? size}) =>
      DashboardCardConfig(type: type, visible: visible ?? this.visible, size: size ?? this.size);

  Map<String, Object?> toJson() => {'type': type.name, 'visible': visible, 'size': size.name};

  static DashboardCardConfig? fromJson(Map<String, Object?> j) {
    final type = DashboardCardType.values.where((t) => t.name == j['type']).firstOrNull;
    if (type == null) return null;
    return DashboardCardConfig(
      type: type,
      visible: _b(j['visible'], true),
      size: _enum(CardSize.values, j['size'], CardSize.compact),
    );
  }
}

// ---------------------------------------------------------------------------
// Aggregate
// ---------------------------------------------------------------------------

/// Everything the user owns, stored encrypted as one document.
class AppData {
  const AppData({
    this.accountTypes = const [],
    this.accounts = const [],
    this.snapshots = const [],
    this.categories = const [],
    this.recurring = const [],
    this.transactions = const [],
    this.investments = const InvestmentPlan(),
    this.purchase = const PurchaseInputs(),
    this.savingsGoal = const SavingsGoalSettings(),
    this.dashboard = const [],
    this.onlinePricesEnabled = false,
    this.projection = const ProjectionSettings(),
    this.autoBackupPassword,
  });

  static const schemaVersion = 1;

  final List<AccountType> accountTypes;
  final List<Account> accounts;

  /// Always sorted by date (then creation time).
  final List<Snapshot> snapshots;
  final List<Category> categories;
  final List<RecurringItem> recurring;
  final List<TransactionEntry> transactions;
  final InvestmentPlan investments;
  final PurchaseInputs purchase;
  final SavingsGoalSettings savingsGoal;
  final List<DashboardCardConfig> dashboard;

  /// The single online feature: fetching ETF prices on request.
  final bool onlinePricesEnabled;
  final ProjectionSettings projection;

  /// Password of the automatic backups (the folder is in the device prefs).
  /// Never written into a backup file, see [forBackup].
  final String? autoBackupPassword;

  AppData copyWith({
    List<AccountType>? accountTypes,
    List<Account>? accounts,
    List<Snapshot>? snapshots,
    List<Category>? categories,
    List<RecurringItem>? recurring,
    List<TransactionEntry>? transactions,
    InvestmentPlan? investments,
    PurchaseInputs? purchase,
    SavingsGoalSettings? savingsGoal,
    List<DashboardCardConfig>? dashboard,
    bool? onlinePricesEnabled,
    ProjectionSettings? projection,
    String? Function()? autoBackupPassword,
  }) =>
      AppData(
        accountTypes: accountTypes ?? this.accountTypes,
        accounts: accounts ?? this.accounts,
        snapshots: snapshots != null ? sortSnapshots(snapshots) : this.snapshots,
        categories: categories ?? this.categories,
        recurring: recurring ?? this.recurring,
        transactions: transactions ?? this.transactions,
        investments: investments ?? this.investments,
        purchase: purchase ?? this.purchase,
        savingsGoal: savingsGoal ?? this.savingsGoal,
        dashboard: dashboard ?? this.dashboard,
        onlinePricesEnabled: onlinePricesEnabled ?? this.onlinePricesEnabled,
        projection: projection ?? this.projection,
        autoBackupPassword: autoBackupPassword != null ? autoBackupPassword() : this.autoBackupPassword,
      );

  /// Content of a backup file: everything except this device's secrets.
  AppData forBackup() => autoBackupPassword == null ? this : copyWith(autoBackupPassword: () => null);

  static List<Snapshot> sortSnapshots(List<Snapshot> list) {
    final sorted = [...list];
    sorted.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
    });
    return List.unmodifiable(sorted);
  }

  AccountType? typeOf(Account account) =>
      accountTypes.where((t) => t.id == account.typeId).firstOrNull;

  AccountBehavior behaviorOf(Account account) => typeOf(account)?.behavior ?? AccountBehavior.liquid;

  Account? accountById(String? id) => id == null ? null : accounts.where((a) => a.id == id).firstOrNull;

  Category? categoryById(String? id) =>
      id == null ? null : categories.where((c) => c.id == id).firstOrNull;

  List<Account> get activeAccounts => accounts.where((a) => !a.archived).toList();

  Map<String, Object?> toJson() => {
        'schema': schemaVersion,
        'accountTypes': accountTypes.map((e) => e.toJson()).toList(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'snapshots': snapshots.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'recurring': recurring.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'investments': investments.toJson(),
        'purchase': purchase.toJson(),
        'savingsGoal': savingsGoal.toJson(),
        'dashboard': dashboard.map((e) => e.toJson()).toList(),
        'onlinePricesEnabled': onlinePricesEnabled,
        'projection': projection.toJson(),
        'autoBackupPassword': autoBackupPassword,
      };

  factory AppData.fromJson(Map<String, Object?> j) {
    final inv = j['investments'];
    final pur = j['purchase'];
    final goal = j['savingsGoal'];
    final projection = j['projection'];
    return AppData(
      accountTypes: _list(j['accountTypes']).map(AccountType.fromJson).toList(),
      accounts: _list(j['accounts']).map(Account.fromJson).toList(),
      snapshots: sortSnapshots(_list(j['snapshots']).map(Snapshot.fromJson).toList()),
      categories: _list(j['categories']).map(Category.fromJson).toList(),
      recurring: _list(j['recurring']).map(RecurringItem.fromJson).toList(),
      transactions: _list(j['transactions']).map(TransactionEntry.fromJson).toList(),
      investments: inv is Map ? InvestmentPlan.fromJson(inv.cast()) : const InvestmentPlan(),
      purchase: pur is Map ? PurchaseInputs.fromJson(pur.cast()) : const PurchaseInputs(),
      savingsGoal: goal is Map ? SavingsGoalSettings.fromJson(goal.cast()) : const SavingsGoalSettings(),
      dashboard: normalizeDashboard(
        _list(j['dashboard']).map(DashboardCardConfig.fromJson).whereType<DashboardCardConfig>().toList(),
      ),
      onlinePricesEnabled: _b(j['onlinePricesEnabled']),
      projection: projection is Map ? ProjectionSettings.fromJson(projection.cast()) : const ProjectionSettings(),
      autoBackupPassword: _sn(j['autoBackupPassword']),
    );
  }

  /// Keeps the stored order and appends cards added in newer app versions.
  static List<DashboardCardConfig> normalizeDashboard(List<DashboardCardConfig> stored) {
    final seen = <DashboardCardType>{};
    final result = <DashboardCardConfig>[];
    for (final c in stored) {
      if (seen.add(c.type)) result.add(c);
    }
    for (final t in DashboardCardType.values) {
      if (!seen.contains(t)) result.add(DashboardCardConfig(type: t));
    }
    return result;
  }
}

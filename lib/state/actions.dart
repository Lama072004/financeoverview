import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ids.dart';
import '../data/defaults.dart';
import '../data/models.dart';
import 'session.dart';

/// All mutations of the user's data in one place.
class DataActions {
  DataActions(this._ref);

  final Ref _ref;

  SessionController get _session => _ref.read(sessionProvider.notifier);

  void _update(AppData Function(AppData d) change) {
    // Late saves (e.g. from a screen's dispose) after shutdown are dropped.
    if (!_ref.mounted) return;
    _session.updateData(change);
  }

  List<T> _upsert<T>(List<T> list, T item, String Function(T) id) {
    final i = list.indexWhere((e) => id(e) == id(item));
    if (i < 0) return [...list, item];
    return [...list]..[i] = item;
  }

  // Accounts --------------------------------------------------------------

  void saveAccount(Account a) => _update((d) => d.copyWith(accounts: _upsert(d.accounts, a, (e) => e.id)));

  void reorderAccounts(List<String> orderedIds) => _update((d) {
        final byId = {for (final a in d.accounts) a.id: a};
        final reordered = [for (final id in orderedIds) ?byId[id]];
        final rest = d.accounts.where((a) => !orderedIds.contains(a.id));
        return d.copyWith(accounts: [...reordered, ...rest]);
      });

  /// Removes the account and its balances from every snapshot.
  void deleteAccount(String id) => _update((d) => d.copyWith(
        accounts: d.accounts.where((a) => a.id != id).toList(),
        snapshots: [
          for (final s in d.snapshots) s.copyWith(values: Map.of(s.values)..remove(id)),
        ],
        recurring: [
          for (final r in d.recurring)
            r.copyWith(
              fromAccountId: r.fromAccountId == id ? () => null : null,
              toAccountId: r.toAccountId == id ? () => null : null,
            ),
        ],
        transactions: [
          for (final t in d.transactions) t.accountId == id ? t.copyWith(accountId: () => null) : t,
        ],
        savingsGoal: d.savingsGoal.pinnedAccountId == id ? d.savingsGoal.copyWith(pinnedAccountId: () => null) : null,
      ));

  // Account types ---------------------------------------------------------

  void saveAccountType(AccountType t) =>
      _update((d) => d.copyWith(accountTypes: _upsert(d.accountTypes, t, (e) => e.id)));

  void deleteAccountType(String id) =>
      _update((d) => d.copyWith(accountTypes: d.accountTypes.where((t) => t.id != id).toList()));

  // Snapshots -------------------------------------------------------------

  void saveSnapshot(Snapshot s) => _update((d) => d.copyWith(snapshots: _upsert(d.snapshots, s, (e) => e.id)));

  void deleteSnapshot(String id) =>
      _update((d) => d.copyWith(snapshots: d.snapshots.where((s) => s.id != id).toList()));

  // Transactions ----------------------------------------------------------

  void saveTransaction(TransactionEntry t) =>
      _update((d) => d.copyWith(transactions: _upsert(d.transactions, t, (e) => e.id)));

  void deleteTransaction(String id) =>
      _update((d) => d.copyWith(transactions: d.transactions.where((t) => t.id != id).toList()));

  // Categories ------------------------------------------------------------

  void saveCategory(Category c) => _update((d) => d.copyWith(categories: _upsert(d.categories, c, (e) => e.id)));

  void deleteCategory(String id) => _update((d) => d.copyWith(
        categories: d.categories.where((c) => c.id != id).toList(),
        recurring: [for (final r in d.recurring) r.categoryId == id ? r.copyWith(categoryId: () => null) : r],
        transactions: [
          for (final t in d.transactions) t.categoryId == id ? t.copyWith(categoryId: () => null) : t,
        ],
      ));

  // Standing orders -------------------------------------------------------

  void saveRecurring(RecurringItem r) => _update((d) => d.copyWith(recurring: _upsert(d.recurring, r, (e) => e.id)));

  void deleteRecurring(String id) =>
      _update((d) => d.copyWith(recurring: d.recurring.where((r) => r.id != id).toList()));

  // Investments -----------------------------------------------------------

  void updateInvestments(InvestmentPlan Function(InvestmentPlan p) change) =>
      _update((d) => d.copyWith(investments: change(d.investments)));

  void saveEtf(EtfPosition p) => updateInvestments(
        (plan) => plan.copyWith(positions: _upsert(plan.positions, p, (e) => e.id)),
      );

  void deleteEtf(String id) => updateInvestments(
        (plan) => plan.copyWith(positions: plan.positions.where((p) => p.id != id).toList()),
      );

  // Purchase calculator ---------------------------------------------------

  void updatePurchase(PurchaseInputs Function(PurchaseInputs p) change) =>
      _update((d) => d.copyWith(purchase: change(d.purchase)));

  // Settings stored in the vault -----------------------------------------

  void updateSavingsGoal(SavingsGoalSettings Function(SavingsGoalSettings g) change) =>
      _update((d) => d.copyWith(savingsGoal: change(d.savingsGoal)));

  void setOnlinePrices(bool enabled) => _update((d) => d.copyWith(onlinePricesEnabled: enabled));

  void updateProjection(ProjectionSettings Function(ProjectionSettings p) change) =>
      _update((d) => d.copyWith(projection: change(d.projection)));

  void setAutoBackupPassword(String? password) => _update((d) => d.copyWith(autoBackupPassword: () => password));

  void setDashboard(List<DashboardCardConfig> cards) => _update((d) => d.copyWith(dashboard: cards));

  void resetDashboard() => setDashboard(defaultDashboard);

  static String id() => newId();
}

final actionsProvider = Provider<DataActions>((ref) => DataActions(ref));

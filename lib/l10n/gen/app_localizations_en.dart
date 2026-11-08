// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finance Overview';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get noteLabel => 'Note';

  @override
  String get nameLabel => 'Name';

  @override
  String get dateLabel => 'Date';

  @override
  String get amountLabel => 'Amount';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get deleteConfirmTitle => 'Delete?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get perMonth => 'per month';

  @override
  String get perYear => 'per year';

  @override
  String get today => 'Today';

  @override
  String get notSet => 'not set';

  @override
  String get showAll => 'Show all';

  @override
  String get showLess => 'Show less';

  @override
  String get navHome => 'Home';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navHistory => 'History';

  @override
  String get navMore => 'More';

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get quickAddBalance => 'Update balances';

  @override
  String get quickAddBalanceHint => 'New entry – empty accounts carry over';

  @override
  String get quickAddExpense => 'Expense';

  @override
  String get quickAddExpenseHint => 'Single expense with a category';

  @override
  String get quickAddIncome => 'Income';

  @override
  String get quickAddIncomeHint => 'e.g. sale, gift, refund';

  @override
  String get setupWelcomeTitle => 'Welcome';

  @override
  String get setupWelcomeBody =>
      'Your finances stay on this device – no account, no cloud, no tracking. Protect them with a PIN or a password.';

  @override
  String get setupChooseMethod => 'How do you want to unlock?';

  @override
  String get credentialPin => 'PIN';

  @override
  String get credentialPinHint => '4 to 8 digits';

  @override
  String get credentialPassword => 'Password';

  @override
  String get credentialPasswordHint => 'At least 6 characters';

  @override
  String get setupCreatePin => 'Set a PIN';

  @override
  String get setupConfirmPin => 'Repeat your PIN';

  @override
  String get setupCreatePassword => 'Set a password';

  @override
  String get setupConfirmPassword => 'Repeat your password';

  @override
  String get passwordTooShort => 'At least 6 characters';

  @override
  String get pinTooShort => 'At least 4 digits';

  @override
  String get credentialsMismatch => 'Doesn\'t match – please try again.';

  @override
  String setupBiometricTitle(String method) {
    return 'Unlock with $method?';
  }

  @override
  String get setupBiometricBody =>
      'Unlock faster. Your PIN or password keeps working.';

  @override
  String get enableBiometric => 'Enable';

  @override
  String get notNow => 'Not now';

  @override
  String get setupForgetWarning =>
      'Important: a PIN or password cannot be recovered. Create backups regularly.';

  @override
  String get setupFinishing => 'Encrypting your vault …';

  @override
  String get biometricFingerprint => 'fingerprint';

  @override
  String get biometricFace => 'Face ID';

  @override
  String get biometricGeneric => 'biometrics';

  @override
  String get unlockEnterPin => 'Enter your PIN';

  @override
  String get unlockEnterPassword => 'Enter your password';

  @override
  String get unlockWrong => 'Wrong, please try again.';

  @override
  String unlockLockedOut(String time) {
    return 'Too many attempts. Please wait $time.';
  }

  @override
  String unlockWithBiometric(String method) {
    return 'Unlock with $method';
  }

  @override
  String get biometricReason => 'Unlock your finance overview';

  @override
  String get unlocking => 'Unlocking …';

  @override
  String get forgotCredential => 'Forgot it?';

  @override
  String get forgotTitle => 'Forgot your PIN or password';

  @override
  String get forgotBody =>
      'Without the PIN or password your data cannot be decrypted – by anyone. You can reset the app and then restore a backup.';

  @override
  String get resetApp => 'Reset app';

  @override
  String get resetConfirmTitle => 'Delete all data?';

  @override
  String get resetConfirmBody =>
      'All accounts, entries and settings on this device will be deleted permanently.';

  @override
  String resetTypeConfirm(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get resetConfirmWord => 'DELETE';

  @override
  String get keyMissingTitle => 'Data not readable';

  @override
  String get keyMissingBody =>
      'The device key is missing, for example after restoring to a new device. Reset the app and restore your backup.';

  @override
  String secondsShort(int count) {
    return '$count s';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get dashboardTitle => 'Overview';

  @override
  String asOf(String date) {
    return 'As of $date';
  }

  @override
  String get customizeDashboard => 'Customize dashboard';

  @override
  String get customizeHint =>
      'Drag to reorder, tap the eye to show or hide, pick a size per card.';

  @override
  String get sizeCompact => 'Compact';

  @override
  String get sizeLarge => 'Large';

  @override
  String get resetLayout => 'Restore default';

  @override
  String get cardNetWorth => 'Net worth';

  @override
  String get cardSpending => 'Monthly spending';

  @override
  String get cardSavingsGoal => 'Savings goal';

  @override
  String get cardCategories => 'Categories';

  @override
  String get cardChart => 'Net worth over time';

  @override
  String get cardAccounts => 'Accounts';

  @override
  String get cardRecurring => 'Standing orders & subscriptions';

  @override
  String get cardLastPeriod => 'Last period (estimated)';

  @override
  String get sinceLastEntry => 'since last entry';

  @override
  String get sinceYearStart => 'since 1 January';

  @override
  String get liquid => 'Liquid';

  @override
  String get invested => 'Invested';

  @override
  String get debts => 'Debts';

  @override
  String get emptyWelcomeTitle => 'Let\'s get started';

  @override
  String get emptyWelcomeBody =>
      'Add your accounts – checking, savings, depot, cash … as many as you like.';

  @override
  String get emptyAddAccount => 'Add your first account';

  @override
  String get emptyFirstEntryTitle => 'First entry';

  @override
  String get emptyFirstEntryBody =>
      'Enter your current balances. From the second entry on you\'ll see changes and estimates.';

  @override
  String get emptyFirstEntryButton => 'Enter balances';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get unassignedHint =>
      'Estimated from your balances: spending that wasn\'t booked individually.';

  @override
  String get fixedCosts => 'Fixed costs';

  @override
  String get singleBookings => 'Single bookings';

  @override
  String get total => 'Total';

  @override
  String get noSpendingThisMonth => 'No spending this month';

  @override
  String get goalNotSet => 'No savings goal set yet';

  @override
  String get goalSetUp => 'Set a goal';

  @override
  String get goalRateLabel => 'Planned savings rate';

  @override
  String get goalNetWorthLabel => 'Net worth goal';

  @override
  String goalOf(String current, String target) {
    return '$current of $target';
  }

  @override
  String goalRemaining(String amount) {
    return '$amount to go';
  }

  @override
  String get goalReached => 'Goal reached';

  @override
  String get chartAll => 'All';

  @override
  String get chartYear => '1Y';

  @override
  String get rangeSixMonths => '6M';

  @override
  String get rangeThreeMonths => '3M';

  @override
  String get rangeMonth => '1M';

  @override
  String get rangeWeek => '1W';

  @override
  String get rangeDay => '1D';

  @override
  String get inRange => 'in this period';

  @override
  String get historyLines => 'Lines';

  @override
  String get openHistory => 'Open history';

  @override
  String get chartNeedTwo => 'With two entries you\'ll see the trend here.';

  @override
  String get recurringIncome => 'Fixed income';

  @override
  String get recurringExpenses => 'Fixed expenses';

  @override
  String get recurringSavings => 'Total savings';

  @override
  String get recurringSavingsInvested => 'of which invested';

  @override
  String get recurringFree => 'Free to spend';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String get periodDays => 'Period';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get periodDelta => 'Change in net worth';

  @override
  String get periodVariable => 'est. variable spending';

  @override
  String get periodReturn => 'est. investment return';

  @override
  String get periodHint =>
      'Variable spending = what went out on top of standing orders. Return = change of investments without your contributions. Rough estimate.';

  @override
  String get periodNeedTwo => 'Available from two entries.';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountName => 'Account name';

  @override
  String get accountType => 'Account type';

  @override
  String get accountIcon => 'Icon';

  @override
  String get accountColor => 'Color';

  @override
  String get accountGoal => 'Savings goal for this account';

  @override
  String get archiveAccount => 'Archive';

  @override
  String get unarchiveAccount => 'Restore';

  @override
  String get archiveHint =>
      'Archived accounts no longer appear in new entries. Set the balance to 0 first if the account was closed.';

  @override
  String get deleteAccountBody =>
      'The account and all its balances in earlier entries will be deleted.';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get balance => 'Balance';

  @override
  String get share => 'Share';

  @override
  String get archivedSection => 'Archived';

  @override
  String get manageTypes => 'Manage account types';

  @override
  String get accountTypesTitle => 'Account types';

  @override
  String get addAccountType => 'Add account type';

  @override
  String get editAccountType => 'Edit account type';

  @override
  String get behavior => 'Behaviour';

  @override
  String get behaviorLiquid => 'Liquid';

  @override
  String get behaviorLiquidHint => 'Bank, cash – used for income and spending';

  @override
  String get behaviorInvested => 'Invested';

  @override
  String get behaviorInvestedHint =>
      'Depot, funds, gold – moves with the market';

  @override
  String get behaviorDebt => 'Debt';

  @override
  String get behaviorDebtHint =>
      'Loan, credit card – subtracted from net worth. Enter the outstanding amount as a positive number.';

  @override
  String typeInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return 'Still used by $_temp0.';
  }

  @override
  String get snapshotNew => 'Enter balances';

  @override
  String get snapshotEdit => 'Edit entry';

  @override
  String get snapshotHint => 'Leave empty = last balance carries over.';

  @override
  String lastValue(String amount) {
    return 'last $amount';
  }

  @override
  String get snapshotTotalPreview => 'Net worth after';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get needAccountsFirst => 'Add an account first.';

  @override
  String get toggleSign => 'Toggle sign';

  @override
  String get expenseNew => 'New expense';

  @override
  String get incomeNew => 'New income';

  @override
  String get transactionEdit => 'Edit booking';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get noAccount => 'No account';

  @override
  String get noCategory => 'No category';

  @override
  String get transactionHint =>
      'Single bookings don\'t change balances – they show where the money went.';

  @override
  String get historyBalances => 'Balances';

  @override
  String get historyBookings => 'Bookings';

  @override
  String get noSnapshots => 'No entries yet';

  @override
  String get noTransactions => 'No bookings yet';

  @override
  String get carriedOver => 'carried over';

  @override
  String monthOut(String amount) {
    return 'Spent $amount';
  }

  @override
  String monthIn(String amount) {
    return 'Received $amount';
  }

  @override
  String get recurringTitle => 'Standing orders & subscriptions';

  @override
  String get recurringHint =>
      'Recurring items only: salary, rent, subscriptions, savings plans. They don\'t move money – they feed planning and estimates.';

  @override
  String get addRecurring => 'Add item';

  @override
  String get editRecurring => 'Edit item';

  @override
  String get recurringName => 'Name';

  @override
  String get recurringType => 'Type';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeSaving => 'Saving';

  @override
  String get savingHint =>
      'Saving = transfer to one of your own accounts. Not an expense – the money stays yours.';

  @override
  String get rhythm => 'Rhythm';

  @override
  String get rhythmWeekly => 'weekly';

  @override
  String get rhythmMonthly => 'monthly';

  @override
  String get rhythmBimonthly => 'every two months';

  @override
  String get rhythmQuarterly => 'quarterly';

  @override
  String get rhythmHalfYearly => 'half-yearly';

  @override
  String get rhythmYearly => 'yearly';

  @override
  String get dueDay => 'Due on (day)';

  @override
  String get fromAccount => 'From account';

  @override
  String get toAccount => 'To account';

  @override
  String get active => 'Active';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'End';

  @override
  String get inactive => 'inactive';

  @override
  String get fixedByCategory => 'Fixed expenses by category';

  @override
  String get noRecurring => 'No standing orders yet';

  @override
  String get amountPositiveHint =>
      'Amount is always positive – the type sets the direction.';

  @override
  String get investmentsTitle => 'Investments';

  @override
  String get investmentsSubtitle => 'Annual purchase plan';

  @override
  String get annualBudget => 'Annual budget';

  @override
  String get limitMarkup => 'Limit markup on price';

  @override
  String get feePerOrder => 'Fees per order (estimated)';

  @override
  String get addEtf => 'Add ETF';

  @override
  String get editEtf => 'Edit ETF';

  @override
  String get isin => 'ISIN';

  @override
  String get etfShare => 'Share of budget';

  @override
  String get manualPrice => 'Manual price';

  @override
  String get amountPerYear => 'Amount per year';

  @override
  String get priceUsed => 'Price';

  @override
  String get limitPrice => 'Limit';

  @override
  String get wholeUnits => 'Whole units';

  @override
  String get wholeCost => 'Cost of whole units';

  @override
  String get unitsByAmount => 'Units when buying by amount';

  @override
  String priceSourceOnline(String time) {
    return 'online · $time';
  }

  @override
  String get priceSourceManual => 'manual';

  @override
  String get priceSourceNone => 'no price';

  @override
  String get sumShares => 'Total shares';

  @override
  String get sharesInvalid => 'Shares don\'t add up to 100 %';

  @override
  String get restWholeUnits => 'Rest with whole units';

  @override
  String restHint(String name) {
    return '→ put into $name (lowest unit price)';
  }

  @override
  String feesTotal(int count) {
    return 'Total fees ($count orders)';
  }

  @override
  String get feesShare => 'Fees as % of budget';

  @override
  String get refreshPrices => 'Refresh prices';

  @override
  String pricesUpdated(int count) {
    return '$count prices updated';
  }

  @override
  String get pricesFailed => 'Couldn\'t load prices. Enter the price manually.';

  @override
  String get onlineDisabledHint =>
      'Online prices are off (settings). Enter prices manually.';

  @override
  String get howToBuyTitle => 'How to buy';

  @override
  String get howToBuy1 =>
      'Whole units: quantity from \"Whole units\", order type limit, limit as shown.';

  @override
  String get howToBuy2 =>
      'If \"Whole units\" is 0 (amount smaller than one unit): trade by amount and use the amount per year.';

  @override
  String get howToBuy3 =>
      'Online prices come from Tradegate and may be slightly delayed. Your bank\'s price can differ a little.';

  @override
  String get noEtfs => 'No ETFs in the plan yet';

  @override
  String get purchaseTitle => 'Purchase calculator';

  @override
  String get purchaseSubtitle => 'Is the purchase worth it?';

  @override
  String get purchaseSectionPurchase => 'The purchase';

  @override
  String get purchaseLabel => 'Label';

  @override
  String get purchaseLabelHint => 'e.g. motorbike';

  @override
  String get purchasePrice => 'Price';

  @override
  String get purchaseFromSavings => 'paid from savings';

  @override
  String get purchaseLoanRate => 'Loan interest p.a. (if the rest is financed)';

  @override
  String get purchaseLoanMonths => 'Loan term (months)';

  @override
  String get purchaseMonthlyCost => 'Running costs per month';

  @override
  String get purchaseMonthlyCostHint => 'Insurance, tax, fuel/power, service …';

  @override
  String get purchaseUsageYears => 'Usage (years)';

  @override
  String get purchaseResidual => 'Estimated residual value';

  @override
  String get purchaseResidualHint =>
      'For consumption (holiday, electronics) usually 0.';

  @override
  String get purchaseSectionAssumptions => 'Your assumptions';

  @override
  String get purchaseReturn => 'Return if the money were invested instead';

  @override
  String get purchaseEmergency => 'Emergency fund (stays liquid)';

  @override
  String get purchaseTargetRate => 'Target savings rate';

  @override
  String get purchaseSectionSituation => 'Your current situation';

  @override
  String get monthlyIncome => 'Income per month';

  @override
  String get monthlyFixed => 'Fixed expenses per month';

  @override
  String get monthlySavings => 'Savings per month';

  @override
  String get monthlyFree => 'Free per month';

  @override
  String get currentRate => 'Current savings rate';

  @override
  String get purchaseSectionImmediate => 'Immediate effect';

  @override
  String get loanAmount => 'Loan amount';

  @override
  String get loanPayment => 'Loan payment per month';

  @override
  String get interestTotal => 'Total interest';

  @override
  String get liquidAfter => 'Liquid money after purchase';

  @override
  String get shareOfWealth => 'Share of net worth';

  @override
  String get monthsLost => 'Savings set back by … months';

  @override
  String get monthsToSave => 'Saving up from free money (months)';

  @override
  String get purchaseSectionMonthly => 'Ongoing (per month)';

  @override
  String get extraMonthly => 'Extra burden (running + loan)';

  @override
  String get freeAfter => 'Free afterwards';

  @override
  String get rateAfter => 'Savings rate afterwards';

  @override
  String get purchaseSectionUsage => 'Over the usage period';

  @override
  String get totalCost => 'Total cost (depreciation + running + interest)';

  @override
  String get costPerMonth => 'Cost per month of use';

  @override
  String get remainingDebt => 'Remaining loan at the end';

  @override
  String get wealthDisadvantage => 'Less wealth at the end than without buying';

  @override
  String get verdictTitle => 'Verdict';

  @override
  String get verdictBelowEmergency =>
      'Your liquid money drops below the emergency fund – postpone or save up first.';

  @override
  String get verdictCostsExceed =>
      'The running costs exceed your free amount – you would have to save less.';

  @override
  String get verdictRateDrops =>
      'Affordable, but your savings rate drops below your target.';

  @override
  String get verdictLargeShare =>
      'Affordable, but more than 25 % of your net worth – think it over.';

  @override
  String get verdictAffordable =>
      'Affordable: the emergency fund stays, savings plans continue.';

  @override
  String verdictSummary(String label, String perMonth, String months) {
    return '$label: costs you about $perMonth per month and sets your savings back $months months.';
  }

  @override
  String get purchaseDisclaimer =>
      'Rough estimate. Returns are not guaranteed – be realistic about residual values and running costs.';

  @override
  String get purchaseReset => 'Clear inputs';

  @override
  String get thePurchase => 'The purchase';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryKind => 'Kind';

  @override
  String get kindExpense => 'Expense';

  @override
  String get kindIncome => 'Income';

  @override
  String get categoryInUse =>
      'Still in use – bookings and standing orders will lose the category.';

  @override
  String get icon => 'Icon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get darkVariantLabel => 'Dark mode style';

  @override
  String get darkBlack => 'Pure black';

  @override
  String get darkBlackHint => 'Saves power on OLED screens';

  @override
  String get darkDim => 'Dark grey';

  @override
  String get darkDimHint => 'A bit lighter, softer contrast';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get sectionSecurity => 'Security';

  @override
  String get changeCredential => 'Change PIN or password';

  @override
  String get currentCredential => 'Current PIN or password';

  @override
  String get credentialChanged => 'Changed';

  @override
  String biometricUnlock(String method) {
    return 'Unlock with $method';
  }

  @override
  String get biometricUnavailable => 'Not available on this device';

  @override
  String get lockAfter => 'Lock after leaving';

  @override
  String get lockImmediately => 'immediately';

  @override
  String get sectionGoal => 'Savings goal';

  @override
  String get goalModeRate => 'Monthly savings rate';

  @override
  String get goalModeRateHint => 'A target savings rate you work towards';

  @override
  String get goalModeAccount => 'Goal per account';

  @override
  String get goalModeAccountHint => 'Any target amount per account';

  @override
  String get goalModeNetWorth => 'Net worth goal';

  @override
  String get goalModeNetWorthHint => 'A target for your total net worth';

  @override
  String get goalTargetRate => 'Target savings rate';

  @override
  String get goalTargetNetWorth => 'Target net worth';

  @override
  String get goalPinnedAccount => 'Show on dashboard';

  @override
  String get goalNoAccountGoals =>
      'No account goals yet – enter a target amount for an account below.';

  @override
  String get sectionOnline => 'Online prices';

  @override
  String get onlinePricesToggle => 'Fetch ETF prices online';

  @override
  String get onlinePricesHint =>
      'The only online feature: on request, only the ISIN is sent to tradegate.de. Otherwise the app stays fully offline.';

  @override
  String get sectionAbout => 'About';

  @override
  String get aboutOffline =>
      '100 % offline · no account · no cloud · no tracking';

  @override
  String get guideTitle => 'Guide';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupIntro =>
      'Without cloud your data only lives on this device. Export an encrypted backup regularly and keep it somewhere safe.';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupImport => 'Restore backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordRepeat => 'Repeat password';

  @override
  String get backupPasswordHint =>
      'At least 8 characters. Without this password the backup cannot be opened.';

  @override
  String get backupPasswordTooShort => 'At least 8 characters';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupImportConfirmTitle => 'Restore backup?';

  @override
  String get backupImportConfirmBody =>
      'Your current data will be replaced by the backup.';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get backupWrongPassword => 'Wrong password';

  @override
  String get backupInvalid => 'Not a valid backup file';

  @override
  String get backupFailed => 'That didn\'t work.';

  @override
  String get pleaseWait => 'Please wait …';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get resetAppHint => 'Deletes all data on this device.';

  @override
  String get moreRecurringSub =>
      'Salary, fixed costs, subscriptions, savings plans';

  @override
  String get moreInvestmentsSub => 'Annual ETF purchase plan';

  @override
  String get morePurchaseSub => 'Does a purchase fit your plan?';

  @override
  String get moreCategoriesSub => 'Icons and names for bookings';

  @override
  String get moreAccountTypesSub => 'Liquid, invested, debt …';

  @override
  String get moreSettingsSub => 'Theme, security, savings goal';

  @override
  String get moreBackupSub => 'Encrypted backup and restore';

  @override
  String get moreGuideSub => 'How to use the app';

  @override
  String get lockNow => 'Lock now';

  @override
  String get guideSetupTitle => 'One-time setup';

  @override
  String get guideSetup1 =>
      'Add accounts – as many as you like – and choose a type: liquid = bank account/cash, invested = depot/funds/gold, debt = loans.';

  @override
  String get guideSetup2 =>
      'Under \"Standing orders\" add salary, fixed costs, subscriptions and savings plans. Amounts are always positive; pick the type (income / expense / saving).';

  @override
  String get guideSetup3 =>
      'Use the \"+\" button to enter your first balances.';

  @override
  String get guideRegularTitle => 'Regularly (e.g. twice a month – no must)';

  @override
  String get guideRegular1 =>
      '\"+\" → update balances. Leave an account empty = the last balance carries over.';

  @override
  String get guideRegular2 =>
      'Optionally book single expenses or income. They don\'t change balances, but show where the money went.';

  @override
  String get guideRegular3 =>
      'Dashboard, chart and estimates update automatically.';

  @override
  String get guideNotesTitle => 'Notes';

  @override
  String get guideNote1 =>
      'Cancelled a subscription: switch off \"Active\" or set an end date – the item stays as history.';

  @override
  String get guideNote2 =>
      'Saving to one of your own accounts is not an expense – the money stays yours.';

  @override
  String get guideNote3 =>
      'The estimates for variable spending and return use the currently active standing orders and are rough guides.';

  @override
  String get guideNote4 =>
      'Create a backup regularly – without cloud there is no other copy of your data.';

  @override
  String get guideDashboardTitle => 'Dashboard';

  @override
  String get guideDashboard1 =>
      'Use the pencil icon at the top right to reorder cards, show or hide them and choose their size.';

  @override
  String get discreetOn => 'Hide amounts';

  @override
  String get discreetOff => 'Show amounts';

  @override
  String get discreetTitle => 'Discreet mode';

  @override
  String get discreetHint =>
      'Shows all amounts as ••••. Toggle it quickly with the eye on the dashboard.';

  @override
  String get later => 'Later';

  @override
  String backupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupNone => 'No backup has been made on this device yet.';

  @override
  String get autoBackupTitle => 'Automatic backup';

  @override
  String get autoBackupIntro =>
      'After every change the app saves an encrypted backup to a folder of your choice, at most one per day. The latest 10 are kept, older automatic backups are deleted.';

  @override
  String get autoBackupTip =>
      'A backup on the phone does not help if the phone gets lost. Copy the folder to a computer or USB stick now and then.';

  @override
  String get autoBackupEnable => 'Choose folder and turn on';

  @override
  String get autoBackupPasswordHint =>
      'At least 8 characters. Used for all automatic backups. Without this password they cannot be opened.';

  @override
  String get autoBackupFolder => 'Folder';

  @override
  String get autoBackupLastRun => 'Last saved';

  @override
  String get autoBackupNever => 'not yet';

  @override
  String get autoBackupFailed =>
      'The last automatic backup failed. Was the folder deleted or moved? Then choose it again.';

  @override
  String get autoBackupRunNow => 'Back up now';

  @override
  String get autoBackupChangeFolder => 'Change folder';

  @override
  String get autoBackupChangePassword => 'Change password';

  @override
  String get autoBackupDisable => 'Turn off';

  @override
  String get autoBackupDisabled =>
      'Automatic backup turned off. The existing files stay in the folder.';

  @override
  String get autoBackupDone => 'Backup saved to the folder';

  @override
  String get backupReminderTitle => 'Reminder';

  @override
  String get backupReminderLabel => 'Remind after';

  @override
  String get backupReminderHint =>
      'Shows a hint on the dashboard when the last backup is older. Not needed while the automatic backup works.';

  @override
  String get backupReminderOff => 'Never';

  @override
  String get bannerBackupNeverTitle => 'No backup yet';

  @override
  String get bannerBackupNeverBody =>
      'Without a backup your data is gone if the phone gets lost or breaks.';

  @override
  String bannerBackupOutdatedTitle(int days) {
    return 'Your last backup is $days days old';
  }

  @override
  String get bannerBackupOutdatedBody => 'Time to back up your data again.';

  @override
  String get bannerBackupFailedTitle => 'Automatic backup failed';

  @override
  String get bannerBackupFailedBody =>
      'Check the folder in the backup settings.';

  @override
  String get bannerBackupNow => 'Back up now';

  @override
  String get bannerBackupCheck => 'Check';

  @override
  String get sectionReminder => 'Reminder';

  @override
  String get reminderToggle => 'Reminder to enter balances';

  @override
  String get reminderHint =>
      'A notification on fixed days of the month, without internet.';

  @override
  String reminderSummary(String days, String time) {
    return 'On the $days at $time';
  }

  @override
  String get reminderDays => 'Days of the month';

  @override
  String get reminderDaysHint =>
      'Up to the 28th, so the reminder comes every month.';

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderPermissionDenied =>
      'Notifications are not allowed for the app. You can allow them in the Android settings under Apps › Finanzübersicht.';

  @override
  String get reminderChannel => 'Reminders';

  @override
  String get reminderNotificationTitle => 'Time for your balances';

  @override
  String get reminderNotificationBody =>
      'Enter your current balances, it only takes a minute.';

  @override
  String get periodPrevious => 'Previous';

  @override
  String get periodNext => 'Next';

  @override
  String get sectionAnalysis => 'Analysis';

  @override
  String get reviewTitle => 'Review';

  @override
  String get moreReviewSub =>
      'Months and years: growth, savings rate, spending';

  @override
  String get scopeMonth => 'Month';

  @override
  String get scopeYear => 'Year';

  @override
  String get scopeAll => 'All time';

  @override
  String get reviewEmptyTitle => 'Nothing to look back on yet';

  @override
  String get reviewEmptyBody =>
      'Once you have entered balances or bookings, you will see here how your wealth develops.';

  @override
  String get reviewNoEntry => 'No entry in this period';

  @override
  String reviewLastKnown(String date, String amount) {
    return 'Last balance on $date: $amount';
  }

  @override
  String get reviewChange => 'in this period';

  @override
  String get reviewSaved => 'of which saved';

  @override
  String get reviewReturn => 'of which return (estimated)';

  @override
  String get reviewVariable => 'Variable spending (estimated)';

  @override
  String reviewSpan(String from, String to, String days) {
    return 'Measured between your entries of $from and $to ($days).';
  }

  @override
  String get reviewSingleEntry =>
      'Only one entry so far. A comparison needs at least two.';

  @override
  String get reviewSavingsRate => 'Savings rate';

  @override
  String get reviewRateActual => 'Actual';

  @override
  String get reviewRatePlanned => 'Planned';

  @override
  String get reviewRateHint =>
      'Actual: saved ÷ fixed income in the period. Planned: savings of the standing orders ÷ fixed income.';

  @override
  String get reviewRateNoIncome =>
      'Without fixed income in the standing orders no savings rate can be calculated.';

  @override
  String get reviewPerMonth => 'Growth per month';

  @override
  String get reviewPerYear => 'Growth per year';

  @override
  String get reviewColSaved => 'saved';

  @override
  String get reviewColReturn => 'return';

  @override
  String get reviewSpending => 'Spending by category';

  @override
  String reviewAveragePerMonth(String amount) {
    return 'Ø $amount per month';
  }

  @override
  String get reviewNoSpending => 'No spending in this period.';

  @override
  String get reviewSingleIncome => 'Single income';

  @override
  String get reportTitle => 'PDF report';

  @override
  String get moreReportSub => 'A year or all time, to keep';

  @override
  String get projectionTitle => 'Forecast';

  @override
  String get moreProjectionSub => 'Wealth in the coming years, goal date';

  @override
  String yearsShort(int years) {
    return '$years y';
  }

  @override
  String projectionIn(int years) {
    return 'Wealth in $years years';
  }

  @override
  String get projectionHistory => 'So far';

  @override
  String get projectionToday => 'Today';

  @override
  String get projectionContributed => '+ saved';

  @override
  String get projectionReturns => '+ return with compound interest';

  @override
  String get projectionMilestones => 'Milestones';

  @override
  String projectionAfterYears(int years, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'In $years years',
      one: 'In 1 year',
    );
    return '$_temp0 ($year)';
  }

  @override
  String get projectionAssumptions => 'Assumptions';

  @override
  String get projectionSaving => 'Saving per month';

  @override
  String projectionFromPlan(String amount) {
    return 'Leave empty to use the standing orders ($amount)';
  }

  @override
  String get projectionInvested => 'of which invested';

  @override
  String get projectionInvestedHint =>
      'Only this part and what is invested today earn a return.';

  @override
  String get projectionReturn => 'Return per year';

  @override
  String get projectionReturnHint =>
      'Broad ETFs are often assumed at 5–7 %; a careful value is safer.';

  @override
  String get projectionBasisOwn => 'Calculated with your own saving rate.';

  @override
  String get projectionBasisPlan =>
      'Calculated with the savings of your standing orders.';

  @override
  String projectionBasisTrend(String amount) {
    return 'No savings are set in the standing orders, so the forecast uses your history: Ø $amount per month over the last year, market moves included.';
  }

  @override
  String get projectionBasisNone =>
      'Without a saving rate only what is invested today grows with the return. Enter a saving rate above or add standing orders of type saving.';

  @override
  String get projectionUsePlan => 'Use the standing orders';

  @override
  String get projectionDisclaimer =>
      'A forecast is no guarantee: returns fluctuate, inflation and taxes are not included.';

  @override
  String forecastExpected(String date) {
    return 'expected $date';
  }

  @override
  String get forecastUnreachable => 'not in sight at this rate';

  @override
  String reportTitleYear(int year) {
    return 'Annual report $year';
  }

  @override
  String get reportTitleAll => 'Report for all time';

  @override
  String reportPeriod(String period) {
    return 'Period: $period';
  }

  @override
  String reportFooter(String date) {
    return 'Created on $date with the Finanzübersicht app · confidential';
  }

  @override
  String reportPage(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get reportNoFlow =>
      'There are fewer than two entries for this period, so no development can be shown.';

  @override
  String get reportChartTitle => 'Net worth over time';

  @override
  String reportNetWorthAt(String date) {
    return 'Net worth on $date';
  }

  @override
  String reportStartValue(String date, String amount) {
    return 'Start $date: $amount';
  }

  @override
  String get reportGrowth => 'Growth';

  @override
  String reportPlannedRate(String rate) {
    return 'planned $rate';
  }

  @override
  String get reportYearsTable => 'Years at a glance';

  @override
  String get reportMonthsTable => 'Months at a glance';

  @override
  String get reportColEnd => 'Net worth';

  @override
  String get reportColVariable => 'var. spending';

  @override
  String get reportColRate => 'Rate';

  @override
  String get reportColAccount => 'Account';

  @override
  String get reportColType => 'Type';

  @override
  String get reportColStart => 'Start';

  @override
  String get reportColChange => 'Change';

  @override
  String get reportColShare => 'Share';

  @override
  String get reportColCategory => 'Category';

  @override
  String get reportPlanTitle => 'Standing orders and subscriptions';

  @override
  String reportPlanAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get reportFixedIncome => 'Fixed income';

  @override
  String get reportFixedExpenses => 'Fixed expenses';

  @override
  String get reportSavings => 'Total savings';

  @override
  String get reportSavingsInvested => 'of which invested';

  @override
  String get reportFree => 'Freely available';

  @override
  String get reportPlannedSavingsRate => 'Planned savings rate';

  @override
  String get reportOutlookTitle => 'Savings goal and forecast';

  @override
  String reportProjectionLine(int years, String month, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'In $years years',
      one: 'In 1 year',
    );
    return '$_temp0 ($month): about $amount';
  }

  @override
  String reportAssumptions(String saving, String invested, String rate) {
    return 'Forecast assumptions: saving $saving per month, of which invested $invested, return $rate per year. Inflation and taxes are not included.';
  }

  @override
  String get reportNotes =>
      'Notes: net worth and growth are based on your entries. A period runs from the last entry before it to the last entry in it. “Saved”, “return” and “variable spending” are estimates from balances and the current standing orders. The actual savings rate is saved ÷ fixed income.';

  @override
  String get reportIntro =>
      'A PDF with key figures, net worth over time, growth per month or year, a monthly table, accounts, spending by category, standing orders and forecast.';

  @override
  String get reportChoose => 'Period';

  @override
  String get reportAllTime => 'All time';

  @override
  String get reportUnencrypted =>
      'The report is not encrypted and shows all amounts, also in discreet mode. Only save it where nobody else has access.';

  @override
  String reportCreateYear(int year) {
    return 'Save report $year';
  }

  @override
  String get reportCreateAll => 'Save all-time report';

  @override
  String get reportSaved => 'Report saved';

  @override
  String get reportEmptyTitle => 'Not enough for a report yet';

  @override
  String get reportEmptyBody => 'A report needs at least two balance entries.';

  @override
  String get reportNoPlan => 'no plan';

  @override
  String get reportKpiSaved => 'Saved';

  @override
  String get reportKpiSavedHint => 'growth without return';

  @override
  String get reportKpiReturn => 'Return';

  @override
  String get reportKpiVariable => 'Variable spending';

  @override
  String get reportEstimated => 'estimated';

  @override
  String get guideAnalysisTitle => 'Analysis';

  @override
  String get guideAnalysis1 =>
      'Review (More › Review): growth, actual savings rate and spending per month, per year or for all time. It is measured from the last entry before the period to the last entry in it.';

  @override
  String get guideAnalysis2 =>
      'Forecast: your wealth in 5 to 30 years with your saving rate and an assumed return. The expected date of your savings goal is also shown on the savings goal card.';

  @override
  String get guideAnalysis3 =>
      'PDF report for one year or all time, to keep or print. The report is not encrypted.';

  @override
  String get guideSafetyTitle => 'Backup and reminders';

  @override
  String get guideSafety1 =>
      'Automatic backup (More › Backup): choose a folder and a password once, then the app backs up after every change.';

  @override
  String get guideSafety2 =>
      'Reminder to enter balances (Settings): choose days of the month and a time. Tapping the notification opens the entry after unlocking.';

  @override
  String get guideSafety3 =>
      'Discreet mode: the eye on the dashboard hides all amounts, for example when you are out.';
}

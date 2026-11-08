// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Finanzübersicht';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get done => 'Fertig';

  @override
  String get close => 'Schließen';

  @override
  String get next => 'Weiter';

  @override
  String get noteLabel => 'Notiz';

  @override
  String get nameLabel => 'Name';

  @override
  String get dateLabel => 'Datum';

  @override
  String get amountLabel => 'Betrag';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get invalidNumber => 'Ungültige Zahl';

  @override
  String get deleteConfirmTitle => 'Wirklich löschen?';

  @override
  String get deleteConfirmBody => 'Das kann nicht rückgängig gemacht werden.';

  @override
  String get perMonth => 'pro Monat';

  @override
  String get perYear => 'pro Jahr';

  @override
  String get today => 'Heute';

  @override
  String get notSet => 'nicht gesetzt';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get navHome => 'Start';

  @override
  String get navAccounts => 'Konten';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navMore => 'Mehr';

  @override
  String get quickAddTitle => 'Schnell erfassen';

  @override
  String get quickAddBalance => 'Kontostände aktualisieren';

  @override
  String get quickAddBalanceHint =>
      'Neue Erfassung – leere Konten werden übernommen';

  @override
  String get quickAddExpense => 'Ausgabe';

  @override
  String get quickAddExpenseHint => 'Einzelne Ausgabe mit Kategorie';

  @override
  String get quickAddIncome => 'Einnahme';

  @override
  String get quickAddIncomeHint => 'z. B. Verkauf, Geschenk, Rückerstattung';

  @override
  String get setupWelcomeTitle => 'Willkommen';

  @override
  String get setupWelcomeBody =>
      'Deine Finanzen bleiben auf diesem Gerät – ohne Konto, ohne Cloud, ohne Tracking. Schütze sie mit einer PIN oder einem Passwort.';

  @override
  String get setupChooseMethod => 'Wie möchtest du entsperren?';

  @override
  String get credentialPin => 'PIN';

  @override
  String get credentialPinHint => '4 bis 8 Ziffern';

  @override
  String get credentialPassword => 'Passwort';

  @override
  String get credentialPasswordHint => 'Mindestens 6 Zeichen';

  @override
  String get setupCreatePin => 'PIN festlegen';

  @override
  String get setupConfirmPin => 'PIN wiederholen';

  @override
  String get setupCreatePassword => 'Passwort festlegen';

  @override
  String get setupConfirmPassword => 'Passwort wiederholen';

  @override
  String get passwordTooShort => 'Mindestens 6 Zeichen';

  @override
  String get pinTooShort => 'Mindestens 4 Ziffern';

  @override
  String get credentialsMismatch => 'Stimmt nicht überein – bitte nochmal.';

  @override
  String setupBiometricTitle(String method) {
    return 'Mit $method entsperren?';
  }

  @override
  String get setupBiometricBody =>
      'Schneller entsperren. Deine PIN bzw. dein Passwort funktioniert weiterhin.';

  @override
  String get enableBiometric => 'Aktivieren';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get setupForgetWarning =>
      'Wichtig: PIN und Passwort lassen sich nicht wiederherstellen. Lege regelmäßig ein Backup an.';

  @override
  String get setupFinishing => 'Dein Tresor wird verschlüsselt …';

  @override
  String get biometricFingerprint => 'Fingerabdruck';

  @override
  String get biometricFace => 'Face ID';

  @override
  String get biometricGeneric => 'Biometrie';

  @override
  String get unlockEnterPin => 'PIN eingeben';

  @override
  String get unlockEnterPassword => 'Passwort eingeben';

  @override
  String get unlockWrong => 'Falsch, bitte nochmal.';

  @override
  String unlockLockedOut(String time) {
    return 'Zu viele Versuche. Bitte warte $time.';
  }

  @override
  String unlockWithBiometric(String method) {
    return 'Mit $method entsperren';
  }

  @override
  String get biometricReason => 'Entsperre deine Finanzübersicht';

  @override
  String get unlocking => 'Entsperre …';

  @override
  String get forgotCredential => 'Vergessen?';

  @override
  String get forgotTitle => 'PIN oder Passwort vergessen';

  @override
  String get forgotBody =>
      'Ohne PIN bzw. Passwort lassen sich deine Daten nicht entschlüsseln – von niemandem. Du kannst die App zurücksetzen und danach ein Backup einspielen.';

  @override
  String get resetApp => 'App zurücksetzen';

  @override
  String get resetConfirmTitle => 'Alle Daten löschen?';

  @override
  String get resetConfirmBody =>
      'Alle Konten, Erfassungen und Einstellungen auf diesem Gerät werden endgültig gelöscht.';

  @override
  String resetTypeConfirm(String word) {
    return 'Zum Bestätigen $word eingeben';
  }

  @override
  String get resetConfirmWord => 'LÖSCHEN';

  @override
  String get keyMissingTitle => 'Daten nicht lesbar';

  @override
  String get keyMissingBody =>
      'Der Geräteschlüssel fehlt, zum Beispiel nach einer Wiederherstellung auf einem neuen Gerät. Setze die App zurück und spiele dein Backup ein.';

  @override
  String secondsShort(int count) {
    return '$count s';
  }

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String get dashboardTitle => 'Übersicht';

  @override
  String asOf(String date) {
    return 'Stand $date';
  }

  @override
  String get customizeDashboard => 'Dashboard anpassen';

  @override
  String get customizeHint =>
      'Ziehen zum Sortieren, Auge zum Ein- und Ausblenden, Größe pro Karte wählen.';

  @override
  String get sizeCompact => 'Kompakt';

  @override
  String get sizeLarge => 'Groß';

  @override
  String get resetLayout => 'Standard wiederherstellen';

  @override
  String get cardNetWorth => 'Gesamtvermögen';

  @override
  String get cardSpending => 'Ausgaben im Monat';

  @override
  String get cardSavingsGoal => 'Sparziel';

  @override
  String get cardCategories => 'Kategorien';

  @override
  String get cardChart => 'Vermögensentwicklung';

  @override
  String get cardAccounts => 'Konten';

  @override
  String get cardRecurring => 'Daueraufträge & Abos';

  @override
  String get cardLastPeriod => 'Letzter Zeitraum (geschätzt)';

  @override
  String get sinceLastEntry => 'seit letzter Erfassung';

  @override
  String get sinceYearStart => 'seit Jahresanfang';

  @override
  String get liquid => 'Liquide';

  @override
  String get invested => 'Investiert';

  @override
  String get debts => 'Schulden';

  @override
  String get emptyWelcomeTitle => 'Los geht\'s';

  @override
  String get emptyWelcomeBody =>
      'Lege deine Konten an – Girokonto, Sparkonto, Depot, Bargeld … so viele du willst.';

  @override
  String get emptyAddAccount => 'Erstes Konto anlegen';

  @override
  String get emptyFirstEntryTitle => 'Erste Erfassung';

  @override
  String get emptyFirstEntryBody =>
      'Trag deine aktuellen Kontostände ein. Ab der zweiten Erfassung siehst du Veränderungen und Schätzungen.';

  @override
  String get emptyFirstEntryButton => 'Kontostände eintragen';

  @override
  String get unassigned => 'Nicht zugeordnet';

  @override
  String get unassignedHint =>
      'Aus den Kontoständen geschätzt: Ausgaben, die nicht einzeln erfasst wurden.';

  @override
  String get fixedCosts => 'Fixkosten';

  @override
  String get singleBookings => 'Einzelbuchungen';

  @override
  String get total => 'Gesamt';

  @override
  String get noSpendingThisMonth => 'Keine Ausgaben in diesem Monat';

  @override
  String get goalNotSet => 'Noch kein Sparziel festgelegt';

  @override
  String get goalSetUp => 'Sparziel festlegen';

  @override
  String get goalRateLabel => 'Sparquote laut Plan';

  @override
  String get goalNetWorthLabel => 'Vermögensziel';

  @override
  String goalOf(String current, String target) {
    return '$current von $target';
  }

  @override
  String goalRemaining(String amount) {
    return 'noch $amount';
  }

  @override
  String get goalReached => 'Ziel erreicht';

  @override
  String get chartAll => 'Alle';

  @override
  String get chartYear => '1J';

  @override
  String get rangeSixMonths => '6M';

  @override
  String get rangeThreeMonths => '3M';

  @override
  String get rangeMonth => '1M';

  @override
  String get rangeWeek => '1W';

  @override
  String get rangeDay => '1T';

  @override
  String get inRange => 'im Zeitraum';

  @override
  String get historyLines => 'Kurven';

  @override
  String get openHistory => 'Verlauf öffnen';

  @override
  String get chartNeedTwo => 'Ab zwei Erfassungen siehst du hier den Verlauf.';

  @override
  String get recurringIncome => 'Fixe Einnahmen';

  @override
  String get recurringExpenses => 'Fixe Ausgaben';

  @override
  String get recurringSavings => 'Sparen gesamt';

  @override
  String get recurringSavingsInvested => 'davon in Anlagen';

  @override
  String get recurringFree => 'Frei verfügbar';

  @override
  String get savingsRate => 'Sparquote';

  @override
  String get periodDays => 'Zeitraum';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get periodDelta => 'Veränderung Gesamtvermögen';

  @override
  String get periodVariable => 'gesch. variable Ausgaben';

  @override
  String get periodReturn => 'gesch. Rendite Anlagen';

  @override
  String get periodHint =>
      'Variable Ausgaben = was zusätzlich zu den Daueraufträgen weg ist. Rendite = Wertänderung der Anlagen ohne deine Einzahlungen. Grobe Schätzung.';

  @override
  String get periodNeedTwo => 'Ab zwei Erfassungen verfügbar.';

  @override
  String get addAccount => 'Konto hinzufügen';

  @override
  String get editAccount => 'Konto bearbeiten';

  @override
  String get accountName => 'Kontoname';

  @override
  String get accountType => 'Kontotyp';

  @override
  String get accountIcon => 'Symbol';

  @override
  String get accountColor => 'Farbe';

  @override
  String get accountGoal => 'Sparziel für dieses Konto';

  @override
  String get archiveAccount => 'Archivieren';

  @override
  String get unarchiveAccount => 'Wiederherstellen';

  @override
  String get archiveHint =>
      'Archivierte Konten erscheinen nicht mehr bei neuen Erfassungen. Setze den Stand vorher auf 0, wenn das Konto aufgelöst ist.';

  @override
  String get deleteAccountBody =>
      'Das Konto und alle seine Stände in früheren Erfassungen werden gelöscht.';

  @override
  String get noAccounts => 'Noch keine Konten';

  @override
  String get balance => 'Stand';

  @override
  String get share => 'Anteil';

  @override
  String get archivedSection => 'Archiviert';

  @override
  String get manageTypes => 'Kontotypen verwalten';

  @override
  String get accountTypesTitle => 'Kontotypen';

  @override
  String get addAccountType => 'Kontotyp hinzufügen';

  @override
  String get editAccountType => 'Kontotyp bearbeiten';

  @override
  String get behavior => 'Verhalten';

  @override
  String get behaviorLiquid => 'Liquide';

  @override
  String get behaviorLiquidHint => 'Bank, Bargeld – für Einnahmen und Ausgaben';

  @override
  String get behaviorInvested => 'Investiert';

  @override
  String get behaviorInvestedHint =>
      'Depot, Fonds, Gold – schwankt mit dem Markt';

  @override
  String get behaviorDebt => 'Schulden';

  @override
  String get behaviorDebtHint =>
      'Kredit, Kreditkarte – wird vom Vermögen abgezogen. Offenen Betrag positiv eintragen.';

  @override
  String typeInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konten',
      one: '1 Konto',
    );
    return 'Wird noch von $_temp0 verwendet.';
  }

  @override
  String get snapshotNew => 'Kontostände erfassen';

  @override
  String get snapshotEdit => 'Erfassung bearbeiten';

  @override
  String get snapshotHint => 'Leer lassen = letzter Stand wird übernommen.';

  @override
  String lastValue(String amount) {
    return 'zuletzt $amount';
  }

  @override
  String get snapshotTotalPreview => 'Gesamtvermögen danach';

  @override
  String get deleteEntry => 'Erfassung löschen';

  @override
  String get needAccountsFirst => 'Lege zuerst ein Konto an.';

  @override
  String get toggleSign => 'Vorzeichen wechseln';

  @override
  String get expenseNew => 'Neue Ausgabe';

  @override
  String get incomeNew => 'Neue Einnahme';

  @override
  String get transactionEdit => 'Buchung bearbeiten';

  @override
  String get category => 'Kategorie';

  @override
  String get account => 'Konto';

  @override
  String get noAccount => 'Kein Konto';

  @override
  String get noCategory => 'Ohne Kategorie';

  @override
  String get transactionHint =>
      'Einzelbuchungen ändern keinen Kontostand – sie zeigen, wofür das Geld weg ist.';

  @override
  String get historyBalances => 'Kontostände';

  @override
  String get historyBookings => 'Buchungen';

  @override
  String get noSnapshots => 'Noch keine Erfassungen';

  @override
  String get noTransactions => 'Noch keine Buchungen';

  @override
  String get carriedOver => 'übernommen';

  @override
  String monthOut(String amount) {
    return 'Ausgaben $amount';
  }

  @override
  String monthIn(String amount) {
    return 'Einnahmen $amount';
  }

  @override
  String get recurringTitle => 'Daueraufträge & Abos';

  @override
  String get recurringHint =>
      'Nur wiederkehrende Posten: Gehalt, Miete, Abos, Sparpläne. Sie bewegen kein Geld, sondern fließen in Planung und Schätzungen ein.';

  @override
  String get addRecurring => 'Posten hinzufügen';

  @override
  String get editRecurring => 'Posten bearbeiten';

  @override
  String get recurringName => 'Bezeichnung';

  @override
  String get recurringType => 'Typ';

  @override
  String get typeIncome => 'Einnahme';

  @override
  String get typeExpense => 'Ausgabe';

  @override
  String get typeSaving => 'Sparen';

  @override
  String get savingHint =>
      'Sparen = Übertrag auf ein eigenes Konto. Zählt nicht als Ausgabe – das Geld bleibt dein Vermögen.';

  @override
  String get rhythm => 'Rhythmus';

  @override
  String get rhythmWeekly => 'wöchentlich';

  @override
  String get rhythmMonthly => 'monatlich';

  @override
  String get rhythmBimonthly => 'zweimonatlich';

  @override
  String get rhythmQuarterly => 'vierteljährlich';

  @override
  String get rhythmHalfYearly => 'halbjährlich';

  @override
  String get rhythmYearly => 'jährlich';

  @override
  String get dueDay => 'Fällig am (Tag)';

  @override
  String get fromAccount => 'Von Konto';

  @override
  String get toAccount => 'Auf Konto';

  @override
  String get active => 'Aktiv';

  @override
  String get startDate => 'Start';

  @override
  String get endDate => 'Ende';

  @override
  String get inactive => 'inaktiv';

  @override
  String get fixedByCategory => 'Fixausgaben nach Kategorie';

  @override
  String get noRecurring => 'Noch keine Daueraufträge';

  @override
  String get amountPositiveHint =>
      'Betrag immer positiv – die Richtung ergibt sich aus dem Typ.';

  @override
  String get investmentsTitle => 'Investitionen';

  @override
  String get investmentsSubtitle => 'Jährlicher Kaufplan';

  @override
  String get annualBudget => 'Jahresbudget';

  @override
  String get limitMarkup => 'Limit-Aufschlag auf Kurs';

  @override
  String get feePerOrder => 'Spesen pro Order (geschätzt)';

  @override
  String get addEtf => 'ETF hinzufügen';

  @override
  String get editEtf => 'ETF bearbeiten';

  @override
  String get isin => 'ISIN';

  @override
  String get etfShare => 'Anteil am Budget';

  @override
  String get manualPrice => 'Kurs von Hand';

  @override
  String get amountPerYear => 'Betrag pro Jahr';

  @override
  String get priceUsed => 'Kurs';

  @override
  String get limitPrice => 'Limit';

  @override
  String get wholeUnits => 'Ganze Stück';

  @override
  String get wholeCost => 'Kosten ganze Stück';

  @override
  String get unitsByAmount => 'Stück bei Betrags-Kauf';

  @override
  String priceSourceOnline(String time) {
    return 'online · $time';
  }

  @override
  String get priceSourceManual => 'von Hand';

  @override
  String get priceSourceNone => 'kein Kurs';

  @override
  String get sumShares => 'Summe Anteile';

  @override
  String get sharesInvalid => 'Die Anteile ergeben nicht 100 %';

  @override
  String get restWholeUnits => 'Rest bei ganzen Stück';

  @override
  String restHint(String name) {
    return '→ in $name stecken (günstigster Stückpreis)';
  }

  @override
  String feesTotal(int count) {
    return 'Spesen gesamt ($count Orders)';
  }

  @override
  String get feesShare => 'Spesen in % vom Budget';

  @override
  String get refreshPrices => 'Kurse aktualisieren';

  @override
  String pricesUpdated(int count) {
    return '$count Kurse aktualisiert';
  }

  @override
  String get pricesFailed =>
      'Kurse konnten nicht geladen werden. Trag den Kurs von Hand ein.';

  @override
  String get onlineDisabledHint =>
      'Online-Kurse sind aus (Einstellungen). Kurse trägst du von Hand ein.';

  @override
  String get howToBuyTitle => 'So kaufst du';

  @override
  String get howToBuy1 =>
      'Ganze Stück: Stückzahl aus „Ganze Stück“, Auftragsart Limit, Limit wie angezeigt.';

  @override
  String get howToBuy2 =>
      'Ist „Ganze Stück“ 0 (Betrag kleiner als ein Stück): mit einem Betrag handeln und den Betrag pro Jahr verwenden.';

  @override
  String get howToBuy3 =>
      'Online-Kurse sind Tradegate-Kurse und können leicht verzögert sein. Der Kurs bei deiner Bank kann minimal abweichen.';

  @override
  String get noEtfs => 'Noch keine ETFs im Plan';

  @override
  String get purchaseTitle => 'Kaufrechner';

  @override
  String get purchaseSubtitle => 'Lohnt sich der Kauf?';

  @override
  String get purchaseSectionPurchase => 'Der Kauf';

  @override
  String get purchaseLabel => 'Bezeichnung';

  @override
  String get purchaseLabelHint => 'z. B. Motorrad';

  @override
  String get purchasePrice => 'Kaufpreis';

  @override
  String get purchaseFromSavings => 'davon aus Ersparnissen bezahlt';

  @override
  String get purchaseLoanRate =>
      'Kredit-Zinssatz p. a. (falls Rest finanziert)';

  @override
  String get purchaseLoanMonths => 'Kredit-Laufzeit (Monate)';

  @override
  String get purchaseMonthlyCost => 'Laufende Kosten pro Monat';

  @override
  String get purchaseMonthlyCostHint =>
      'Versicherung, Steuer, Treibstoff/Strom, Service …';

  @override
  String get purchaseUsageYears => 'Nutzungsdauer (Jahre)';

  @override
  String get purchaseResidual => 'Geschätzter Restwert am Ende';

  @override
  String get purchaseResidualHint => 'Bei Konsum (Urlaub, Elektronik) eher 0.';

  @override
  String get purchaseSectionAssumptions => 'Deine Annahmen';

  @override
  String get purchaseReturn =>
      'Rendite, wenn das Geld stattdessen investiert wäre';

  @override
  String get purchaseEmergency => 'Notgroschen-Ziel (soll liquide bleiben)';

  @override
  String get purchaseTargetRate => 'Ziel-Sparquote';

  @override
  String get purchaseSectionSituation => 'Deine aktuelle Lage';

  @override
  String get monthlyIncome => 'Einnahmen pro Monat';

  @override
  String get monthlyFixed => 'Fixe Ausgaben pro Monat';

  @override
  String get monthlySavings => 'Sparen pro Monat';

  @override
  String get monthlyFree => 'Frei verfügbar pro Monat';

  @override
  String get currentRate => 'Sparquote aktuell';

  @override
  String get purchaseSectionImmediate => 'Sofort-Effekt';

  @override
  String get loanAmount => 'Kreditbetrag';

  @override
  String get loanPayment => 'Kreditrate pro Monat';

  @override
  String get interestTotal => 'Zinskosten gesamt';

  @override
  String get liquidAfter => 'Liquides Geld nach dem Kauf';

  @override
  String get shareOfWealth => 'Anteil am Gesamtvermögen';

  @override
  String get monthsLost => 'Zurückgeworfen um … Monate Sparen';

  @override
  String get monthsToSave => 'Ansparen aus freiem Geld (Monate)';

  @override
  String get purchaseSectionMonthly => 'Laufend (pro Monat)';

  @override
  String get extraMonthly => 'Mehrbelastung (laufend + Kreditrate)';

  @override
  String get freeAfter => 'Frei verfügbar danach';

  @override
  String get rateAfter => 'Sparquote danach';

  @override
  String get purchaseSectionUsage => 'Über die Nutzungsdauer';

  @override
  String get totalCost => 'Gesamtkosten (Wertverlust + laufend + Zinsen)';

  @override
  String get costPerMonth => 'Kosten pro Monat der Nutzung';

  @override
  String get remainingDebt => 'Restschuld am Ende der Nutzung';

  @override
  String get wealthDisadvantage => 'Vermögen am Ende weniger als ohne Kauf';

  @override
  String get verdictTitle => 'Fazit';

  @override
  String get verdictBelowEmergency =>
      'Dein liquides Geld fällt unter den Notgroschen – Kauf verschieben oder ansparen.';

  @override
  String get verdictCostsExceed =>
      'Die laufenden Kosten sind höher als dein freier Betrag – du müsstest weniger sparen.';

  @override
  String get verdictRateDrops =>
      'Leistbar, aber deine Sparquote sinkt unter dein Ziel.';

  @override
  String get verdictLargeShare =>
      'Leistbar, aber über 25 % deines Vermögens – gut überlegen.';

  @override
  String get verdictAffordable =>
      'Leistbar: Notgroschen bleibt, Sparpläne laufen weiter.';

  @override
  String verdictSummary(String label, String perMonth, String months) {
    return '$label: kostet dich ca. $perMonth pro Monat und wirft dich $months Monate Sparen zurück.';
  }

  @override
  String get purchaseDisclaimer =>
      'Grobe Schätzung. Renditen sind nicht garantiert – Restwerte und laufende Kosten realistisch ansetzen.';

  @override
  String get purchaseReset => 'Eingaben leeren';

  @override
  String get thePurchase => 'Der Kauf';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get categoryKind => 'Art';

  @override
  String get kindExpense => 'Ausgabe';

  @override
  String get kindIncome => 'Einnahme';

  @override
  String get categoryInUse =>
      'Wird noch verwendet – Buchungen und Daueraufträge verlieren die Kategorie.';

  @override
  String get icon => 'Symbol';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionAppearance => 'Darstellung';

  @override
  String get themeLabel => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get darkVariantLabel => 'Dunkler Modus';

  @override
  String get darkBlack => 'Reines Schwarz';

  @override
  String get darkBlackHint => 'Spart Strom auf OLED-Displays';

  @override
  String get darkDim => 'Dunkelgrau';

  @override
  String get darkDimHint => 'Etwas heller, weicherer Kontrast';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get sectionSecurity => 'Sicherheit';

  @override
  String get changeCredential => 'PIN oder Passwort ändern';

  @override
  String get currentCredential => 'Aktuelle PIN bzw. aktuelles Passwort';

  @override
  String get credentialChanged => 'Geändert';

  @override
  String biometricUnlock(String method) {
    return 'Mit $method entsperren';
  }

  @override
  String get biometricUnavailable => 'Auf diesem Gerät nicht verfügbar';

  @override
  String get lockAfter => 'Sperren nach dem Verlassen';

  @override
  String get lockImmediately => 'sofort';

  @override
  String get sectionGoal => 'Sparziel';

  @override
  String get goalModeRate => 'Monatliche Sparquote';

  @override
  String get goalModeRateHint => 'Ziel-Sparquote, auf die du hinarbeitest';

  @override
  String get goalModeAccount => 'Sparziel pro Konto';

  @override
  String get goalModeAccountHint => 'Beliebiger Zielbetrag je Konto';

  @override
  String get goalModeNetWorth => 'Vermögensziel';

  @override
  String get goalModeNetWorthHint => 'Ziel für dein Gesamtvermögen';

  @override
  String get goalTargetRate => 'Ziel-Sparquote';

  @override
  String get goalTargetNetWorth => 'Zielvermögen';

  @override
  String get goalPinnedAccount => 'Auf dem Dashboard zeigen';

  @override
  String get goalNoAccountGoals =>
      'Noch keine Kontoziele – trag unten bei einem Konto einen Zielbetrag ein.';

  @override
  String get sectionOnline => 'Online-Kurse';

  @override
  String get onlinePricesToggle => 'ETF-Kurse online abrufen';

  @override
  String get onlinePricesHint =>
      'Die einzige Online-Funktion: Auf Knopfdruck wird nur die ISIN an tradegate.de gesendet. Sonst bleibt die App komplett offline.';

  @override
  String get sectionAbout => 'Über die App';

  @override
  String get aboutOffline =>
      '100 % offline · kein Konto · keine Cloud · kein Tracking';

  @override
  String get guideTitle => 'Anleitung';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupIntro =>
      'Ohne Cloud liegen deine Daten nur auf diesem Gerät. Exportiere regelmäßig ein verschlüsseltes Backup und bewahre es sicher auf.';

  @override
  String get backupExport => 'Backup exportieren';

  @override
  String get backupImport => 'Backup einspielen';

  @override
  String get backupPassword => 'Backup-Passwort';

  @override
  String get backupPasswordRepeat => 'Passwort wiederholen';

  @override
  String get backupPasswordHint =>
      'Mindestens 8 Zeichen. Ohne dieses Passwort lässt sich das Backup nicht öffnen.';

  @override
  String get backupPasswordTooShort => 'Mindestens 8 Zeichen';

  @override
  String get backupSaved => 'Backup gespeichert';

  @override
  String get backupImportConfirmTitle => 'Backup einspielen?';

  @override
  String get backupImportConfirmBody =>
      'Deine aktuellen Daten werden durch das Backup ersetzt.';

  @override
  String get backupRestored => 'Backup eingespielt';

  @override
  String get backupWrongPassword => 'Falsches Passwort';

  @override
  String get backupInvalid => 'Keine gültige Backup-Datei';

  @override
  String get backupFailed => 'Das hat nicht geklappt.';

  @override
  String get pleaseWait => 'Bitte warten …';

  @override
  String get dangerZone => 'Gefahrenbereich';

  @override
  String get resetAppHint => 'Löscht alle Daten auf diesem Gerät.';

  @override
  String get moreRecurringSub => 'Gehalt, Fixkosten, Abos, Sparpläne';

  @override
  String get moreInvestmentsSub => 'Jährlicher ETF-Kaufplan';

  @override
  String get morePurchaseSub => 'Passt ein Kauf in deinen Plan?';

  @override
  String get moreCategoriesSub => 'Symbole und Namen für Buchungen';

  @override
  String get moreAccountTypesSub => 'Liquide, Investiert, Schulden …';

  @override
  String get moreSettingsSub => 'Design, Sicherheit, Sparziel';

  @override
  String get moreBackupSub => 'Verschlüsselt sichern und wiederherstellen';

  @override
  String get moreGuideSub => 'So nutzt du die App';

  @override
  String get lockNow => 'Jetzt sperren';

  @override
  String get guideSetupTitle => 'Einmalig einrichten';

  @override
  String get guideSetup1 =>
      'Konten anlegen – so viele du willst – und den Kontotyp wählen: Liquide = Bankkonto/Bargeld, Investiert = Depot/Fonds/Gold, Schulden = Kredite.';

  @override
  String get guideSetup2 =>
      'Unter „Daueraufträge“ Gehalt, Fixkosten, Abos und Sparpläne eintragen. Betrag immer positiv, Typ wählen (Einnahme / Ausgabe / Sparen).';

  @override
  String get guideSetup3 =>
      'Über den „+“-Knopf die ersten Kontostände erfassen.';

  @override
  String get guideRegularTitle => 'Regelmäßig (z. B. 2× im Monat – kein Muss)';

  @override
  String get guideRegular1 =>
      '„+“ → Kontostände aktualisieren. Ein Konto leer lassen = letzter Stand wird übernommen.';

  @override
  String get guideRegular2 =>
      'Optional einzelne Ausgaben oder Einnahmen erfassen. Sie ändern keinen Kontostand, zeigen aber, wofür das Geld weg ist.';

  @override
  String get guideRegular3 =>
      'Dashboard, Diagramm und Schätzungen rechnen sich automatisch.';

  @override
  String get guideNotesTitle => 'Hinweise';

  @override
  String get guideNote1 =>
      'Abo gekündigt: im Dauerauftrag „Aktiv“ ausschalten oder ein Ende-Datum setzen – der Eintrag bleibt als Historie.';

  @override
  String get guideNote2 =>
      'Sparen auf ein eigenes Konto zählt nicht als Ausgabe – das Geld bleibt dein Vermögen.';

  @override
  String get guideNote3 =>
      'Die Schätzungen „variable Ausgaben“ und „Rendite“ nutzen die aktuell aktiven Daueraufträge und sind grobe Richtwerte.';

  @override
  String get guideNote4 =>
      'Lege regelmäßig ein Backup an – ohne Cloud gibt es sonst keine Kopie deiner Daten.';

  @override
  String get guideDashboardTitle => 'Dashboard';

  @override
  String get guideDashboard1 =>
      'Über das Stift-Symbol oben rechts sortierst du die Karten, blendest sie ein oder aus und wählst die Größe.';

  @override
  String get discreetOn => 'Beträge verbergen';

  @override
  String get discreetOff => 'Beträge anzeigen';

  @override
  String get discreetTitle => 'Diskreter Modus';

  @override
  String get discreetHint =>
      'Zeigt alle Beträge als ••••. Schnell umschalten über das Auge im Dashboard.';

  @override
  String get later => 'Später';

  @override
  String backupLast(String date) {
    return 'Letztes Backup: $date';
  }

  @override
  String get backupNone => 'Auf diesem Gerät wurde noch kein Backup angelegt.';

  @override
  String get autoBackupTitle => 'Automatisches Backup';

  @override
  String get autoBackupIntro =>
      'Die App legt nach jeder Änderung selbst ein verschlüsseltes Backup in einem Ordner deiner Wahl ab, höchstens eines pro Tag. Die letzten 10 bleiben erhalten, ältere automatische Backups werden gelöscht.';

  @override
  String get autoBackupTip =>
      'Ein Backup auf dem Handy hilft nicht, wenn das Handy verloren geht. Kopiere den Ordner deshalb ab und zu auf einen PC oder USB-Stick.';

  @override
  String get autoBackupEnable => 'Ordner wählen und einschalten';

  @override
  String get autoBackupPasswordHint =>
      'Mindestens 8 Zeichen. Gilt für alle automatischen Backups. Ohne dieses Passwort lassen sie sich nicht öffnen.';

  @override
  String get autoBackupFolder => 'Ordner';

  @override
  String get autoBackupLastRun => 'Zuletzt gesichert';

  @override
  String get autoBackupNever => 'noch nicht';

  @override
  String get autoBackupFailed =>
      'Das letzte automatische Backup hat nicht geklappt. Wurde der Ordner gelöscht oder verschoben? Wähle ihn dann neu.';

  @override
  String get autoBackupRunNow => 'Jetzt sichern';

  @override
  String get autoBackupChangeFolder => 'Ordner ändern';

  @override
  String get autoBackupChangePassword => 'Passwort ändern';

  @override
  String get autoBackupDisable => 'Ausschalten';

  @override
  String get autoBackupDisabled =>
      'Automatisches Backup ausgeschaltet. Die vorhandenen Dateien bleiben im Ordner.';

  @override
  String get autoBackupDone => 'Backup im Ordner gespeichert';

  @override
  String get backupReminderTitle => 'Erinnerung';

  @override
  String get backupReminderLabel => 'Erinnern nach';

  @override
  String get backupReminderHint =>
      'Hinweis im Dashboard, wenn das letzte Backup älter ist. Bei funktionierendem automatischem Backup nicht nötig.';

  @override
  String get backupReminderOff => 'Nie';

  @override
  String get bannerBackupNeverTitle => 'Noch kein Backup';

  @override
  String get bannerBackupNeverBody =>
      'Ohne Backup sind deine Daten weg, wenn das Handy verloren geht oder kaputt wird.';

  @override
  String bannerBackupOutdatedTitle(int days) {
    return 'Dein letztes Backup ist $days Tage alt';
  }

  @override
  String get bannerBackupOutdatedBody => 'Sichere deine Daten wieder einmal.';

  @override
  String get bannerBackupFailedTitle => 'Automatisches Backup fehlgeschlagen';

  @override
  String get bannerBackupFailedBody =>
      'Prüfe den Ordner in den Backup-Einstellungen.';

  @override
  String get bannerBackupNow => 'Jetzt sichern';

  @override
  String get bannerBackupCheck => 'Prüfen';

  @override
  String get sectionReminder => 'Erinnerung';

  @override
  String get reminderToggle => 'Erinnerung zum Erfassen';

  @override
  String get reminderHint =>
      'Eine Benachrichtigung an festen Tagen im Monat, ganz ohne Internet.';

  @override
  String reminderSummary(String days, String time) {
    return 'Am $days um $time';
  }

  @override
  String get reminderDays => 'Tage im Monat';

  @override
  String get reminderDaysHint =>
      'Bis zum 28. wählbar, damit die Erinnerung jeden Monat kommt.';

  @override
  String get reminderTime => 'Uhrzeit';

  @override
  String get reminderPermissionDenied =>
      'Benachrichtigungen sind für die App nicht erlaubt. Du kannst sie in den Android-Einstellungen unter Apps › Finanzübersicht erlauben.';

  @override
  String get reminderChannel => 'Erinnerungen';

  @override
  String get reminderNotificationTitle => 'Zeit für deine Kontostände';

  @override
  String get reminderNotificationBody =>
      'Trag die aktuellen Stände ein, das dauert nur eine Minute.';

  @override
  String get periodPrevious => 'Zurück';

  @override
  String get periodNext => 'Vor';

  @override
  String get sectionAnalysis => 'Auswertung';

  @override
  String get reviewTitle => 'Rückblick';

  @override
  String get moreReviewSub => 'Monate und Jahre: Zuwachs, Sparquote, Ausgaben';

  @override
  String get scopeMonth => 'Monat';

  @override
  String get scopeYear => 'Jahr';

  @override
  String get scopeAll => 'Gesamt';

  @override
  String get reviewEmptyTitle => 'Noch nichts zum Zurückblicken';

  @override
  String get reviewEmptyBody =>
      'Sobald du Kontostände oder Buchungen erfasst hast, siehst du hier, wie sich dein Vermögen entwickelt.';

  @override
  String get reviewNoEntry => 'Keine Erfassung in diesem Zeitraum';

  @override
  String reviewLastKnown(String date, String amount) {
    return 'Letzter Stand vom $date: $amount';
  }

  @override
  String get reviewChange => 'im Zeitraum';

  @override
  String get reviewSaved => 'davon gespart';

  @override
  String get reviewReturn => 'davon Rendite (geschätzt)';

  @override
  String get reviewVariable => 'Variable Ausgaben (geschätzt)';

  @override
  String reviewSpan(String from, String to, String days) {
    return 'Gemessen zwischen deinen Erfassungen vom $from und $to ($days).';
  }

  @override
  String get reviewSingleEntry =>
      'Nur eine Erfassung bis hierher. Für einen Vergleich braucht es mindestens zwei.';

  @override
  String get reviewSavingsRate => 'Sparquote';

  @override
  String get reviewRateActual => 'Tatsächlich';

  @override
  String get reviewRatePlanned => 'Geplant';

  @override
  String get reviewRateHint =>
      'Tatsächlich: gespart ÷ fixe Einnahmen im Zeitraum. Geplant: Sparen laut Daueraufträgen ÷ fixe Einnahmen.';

  @override
  String get reviewRateNoIncome =>
      'Ohne fixe Einnahmen in den Daueraufträgen lässt sich keine Sparquote berechnen.';

  @override
  String get reviewPerMonth => 'Zuwachs pro Monat';

  @override
  String get reviewPerYear => 'Zuwachs pro Jahr';

  @override
  String get reviewColSaved => 'gespart';

  @override
  String get reviewColReturn => 'Rendite';

  @override
  String get reviewSpending => 'Ausgaben nach Kategorien';

  @override
  String reviewAveragePerMonth(String amount) {
    return 'Ø $amount pro Monat';
  }

  @override
  String get reviewNoSpending => 'Keine Ausgaben in diesem Zeitraum.';

  @override
  String get reviewSingleIncome => 'Einzelne Einnahmen';

  @override
  String get reportTitle => 'PDF-Bericht';

  @override
  String get moreReportSub => 'Jahr oder gesamte Laufzeit zum Aufheben';

  @override
  String get projectionTitle => 'Prognose';

  @override
  String get moreProjectionSub => 'Vermögen in den nächsten Jahren, Zieldatum';

  @override
  String yearsShort(int years) {
    return '$years J.';
  }

  @override
  String projectionIn(int years) {
    return 'Vermögen in $years Jahren';
  }

  @override
  String get projectionHistory => 'Bisher';

  @override
  String get projectionToday => 'Heute';

  @override
  String get projectionContributed => '+ gespart';

  @override
  String get projectionReturns => '+ Rendite mit Zinseszins';

  @override
  String get projectionMilestones => 'Zwischenstände';

  @override
  String projectionAfterYears(int years, int year) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'In $years Jahren',
      one: 'In 1 Jahr',
    );
    return '$_temp0 ($year)';
  }

  @override
  String get projectionAssumptions => 'Annahmen';

  @override
  String get projectionSaving => 'Sparrate pro Monat';

  @override
  String projectionFromPlan(String amount) {
    return 'Leer lassen für den Wert aus den Daueraufträgen ($amount)';
  }

  @override
  String get projectionInvested => 'davon investiert';

  @override
  String get projectionInvestedHint =>
      'Nur dieser Teil und dein heutiges Depot bringen Rendite.';

  @override
  String get projectionReturn => 'Rendite pro Jahr';

  @override
  String get projectionReturnHint =>
      'Für breit gestreute ETFs werden oft 5–7 % angenommen, sicherer ist ein vorsichtiger Wert.';

  @override
  String get projectionBasisOwn => 'Gerechnet mit deiner eigenen Sparrate.';

  @override
  String get projectionBasisPlan =>
      'Gerechnet mit „Sparen“ aus deinen Daueraufträgen.';

  @override
  String projectionBasisTrend(String amount) {
    return 'In den Daueraufträgen ist kein Sparen eingetragen. Die Prognose nimmt deshalb deinen bisherigen Verlauf: Ø $amount pro Monat im letzten Jahr, Kursentwicklung schon enthalten.';
  }

  @override
  String get projectionBasisNone =>
      'Ohne Sparrate wächst nur dein heute investiertes Geld mit der Rendite. Trag oben eine Sparrate ein oder lege Daueraufträge vom Typ Sparen an.';

  @override
  String get projectionUsePlan => 'Werte aus den Daueraufträgen nehmen';

  @override
  String get projectionDisclaimer =>
      'Eine Prognose ist keine Garantie: Renditen schwanken, Inflation und Steuern sind nicht berücksichtigt.';

  @override
  String forecastExpected(String date) {
    return 'voraussichtlich $date';
  }

  @override
  String get forecastUnreachable => 'mit dieser Sparrate nicht absehbar';

  @override
  String reportTitleYear(int year) {
    return 'Jahresbericht $year';
  }

  @override
  String get reportTitleAll => 'Bericht über die gesamte Laufzeit';

  @override
  String reportPeriod(String period) {
    return 'Zeitraum: $period';
  }

  @override
  String reportFooter(String date) {
    return 'Erstellt am $date mit der App Finanzübersicht · vertraulich';
  }

  @override
  String reportPage(int page, int pages) {
    return 'Seite $page von $pages';
  }

  @override
  String get reportNoFlow =>
      'Für diesen Zeitraum gibt es weniger als zwei Erfassungen, daher keine Entwicklung.';

  @override
  String get reportChartTitle => 'Vermögensverlauf';

  @override
  String reportNetWorthAt(String date) {
    return 'Vermögen am $date';
  }

  @override
  String reportStartValue(String date, String amount) {
    return 'Start $date: $amount';
  }

  @override
  String get reportGrowth => 'Zuwachs';

  @override
  String reportPlannedRate(String rate) {
    return 'geplant $rate';
  }

  @override
  String get reportYearsTable => 'Jahre im Überblick';

  @override
  String get reportMonthsTable => 'Monate im Überblick';

  @override
  String get reportColEnd => 'Vermögen';

  @override
  String get reportColVariable => 'var. Ausgaben';

  @override
  String get reportColRate => 'Sparquote';

  @override
  String get reportColAccount => 'Konto';

  @override
  String get reportColType => 'Typ';

  @override
  String get reportColStart => 'Anfang';

  @override
  String get reportColChange => 'Veränderung';

  @override
  String get reportColShare => 'Anteil';

  @override
  String get reportColCategory => 'Kategorie';

  @override
  String get reportPlanTitle => 'Daueraufträge und Abos';

  @override
  String reportPlanAsOf(String date) {
    return 'Stand $date';
  }

  @override
  String get reportFixedIncome => 'Fixe Einnahmen';

  @override
  String get reportFixedExpenses => 'Fixe Ausgaben';

  @override
  String get reportSavings => 'Sparen gesamt';

  @override
  String get reportSavingsInvested => 'davon in Anlagen';

  @override
  String get reportFree => 'Frei verfügbar';

  @override
  String get reportPlannedSavingsRate => 'Geplante Sparquote';

  @override
  String get reportOutlookTitle => 'Sparziel und Prognose';

  @override
  String reportProjectionLine(int years, String month, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'In $years Jahren',
      one: 'In 1 Jahr',
    );
    return '$_temp0 ($month): voraussichtlich $amount';
  }

  @override
  String reportAssumptions(String saving, String invested, String rate) {
    return 'Annahmen der Prognose: Sparrate $saving pro Monat, davon investiert $invested, Rendite $rate pro Jahr. Inflation und Steuern sind nicht berücksichtigt.';
  }

  @override
  String get reportNotes =>
      'Hinweise: Vermögen und Zuwachs beruhen auf deinen Erfassungen. Ein Zeitraum reicht von der letzten Erfassung davor bis zur letzten darin. „Gespart“, „Rendite“ und „variable Ausgaben“ sind Schätzungen aus Kontoständen und aktuellen Daueraufträgen. Die tatsächliche Sparquote ist gespart ÷ fixe Einnahmen.';

  @override
  String get reportIntro =>
      'Ein PDF mit Kennzahlen, Vermögensverlauf, Zuwachs pro Monat bzw. Jahr, Monatstabelle, Konten, Ausgaben nach Kategorien, Daueraufträgen und Prognose.';

  @override
  String get reportChoose => 'Zeitraum';

  @override
  String get reportAllTime => 'Gesamte Laufzeit';

  @override
  String get reportUnencrypted =>
      'Der Bericht ist nicht verschlüsselt und zeigt alle Beträge, auch im diskreten Modus. Speichere ihn nur dort, wo sonst niemand Zugriff hat.';

  @override
  String reportCreateYear(int year) {
    return 'Bericht $year speichern';
  }

  @override
  String get reportCreateAll => 'Gesamtbericht speichern';

  @override
  String get reportSaved => 'Bericht gespeichert';

  @override
  String get reportEmptyTitle => 'Noch zu wenig für einen Bericht';

  @override
  String get reportEmptyBody =>
      'Ein Bericht braucht mindestens zwei Kontostand-Erfassungen.';

  @override
  String get reportNoPlan => 'ohne Plan';

  @override
  String get reportKpiSaved => 'Gespart';

  @override
  String get reportKpiSavedHint => 'Zuwachs ohne Rendite';

  @override
  String get reportKpiReturn => 'Rendite';

  @override
  String get reportKpiVariable => 'Variable Ausgaben';

  @override
  String get reportEstimated => 'geschätzt';

  @override
  String get guideAnalysisTitle => 'Auswertung';

  @override
  String get guideAnalysis1 =>
      'Rückblick (Mehr › Rückblick): Zuwachs, tatsächliche Sparquote und Ausgaben pro Monat, pro Jahr oder gesamt. Gemessen wird von der letzten Erfassung vor dem Zeitraum bis zur letzten darin.';

  @override
  String get guideAnalysis2 =>
      'Prognose: dein Vermögen in 5 bis 30 Jahren mit deiner Sparrate und einer angenommenen Rendite. Das voraussichtliche Datum deines Sparziels steht auch auf der Sparziel-Karte.';

  @override
  String get guideAnalysis3 =>
      'PDF-Bericht für ein Jahr oder die gesamte Laufzeit, zum Aufheben oder Ausdrucken. Der Bericht ist nicht verschlüsselt.';

  @override
  String get guideSafetyTitle => 'Sicherung und Erinnerung';

  @override
  String get guideSafety1 =>
      'Automatisches Backup (Mehr › Backup): einmal Ordner und Passwort wählen, danach sichert die App nach jeder Änderung selbst.';

  @override
  String get guideSafety2 =>
      'Erinnerung zum Erfassen (Einstellungen): Tage im Monat und Uhrzeit wählen. Ein Tipp auf die Benachrichtigung öffnet nach dem Entsperren die Erfassung.';

  @override
  String get guideSafety3 =>
      'Diskreter Modus: Das Auge im Dashboard blendet alle Beträge aus, zum Beispiel unterwegs.';
}

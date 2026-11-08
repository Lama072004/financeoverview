import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Finanzübersicht'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get done;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @noteLabel.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get noteLabel;

  /// No description provided for @nameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @dateLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get dateLabel;

  /// No description provided for @amountLabel.
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get amountLabel;

  /// No description provided for @requiredField.
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Zahl'**
  String get invalidNumber;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Wirklich löschen?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Das kann nicht rückgängig gemacht werden.'**
  String get deleteConfirmBody;

  /// No description provided for @perMonth.
  ///
  /// In de, this message translates to:
  /// **'pro Monat'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In de, this message translates to:
  /// **'pro Jahr'**
  String get perYear;

  /// No description provided for @today.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get today;

  /// No description provided for @notSet.
  ///
  /// In de, this message translates to:
  /// **'nicht gesetzt'**
  String get notSet;

  /// No description provided for @showAll.
  ///
  /// In de, this message translates to:
  /// **'Alle anzeigen'**
  String get showAll;

  /// No description provided for @showLess.
  ///
  /// In de, this message translates to:
  /// **'Weniger anzeigen'**
  String get showLess;

  /// No description provided for @navHome.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get navHome;

  /// No description provided for @navAccounts.
  ///
  /// In de, this message translates to:
  /// **'Konten'**
  String get navAccounts;

  /// No description provided for @navHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get navHistory;

  /// No description provided for @navMore.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get navMore;

  /// No description provided for @quickAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Schnell erfassen'**
  String get quickAddTitle;

  /// No description provided for @quickAddBalance.
  ///
  /// In de, this message translates to:
  /// **'Kontostände aktualisieren'**
  String get quickAddBalance;

  /// No description provided for @quickAddBalanceHint.
  ///
  /// In de, this message translates to:
  /// **'Neue Erfassung – leere Konten werden übernommen'**
  String get quickAddBalanceHint;

  /// No description provided for @quickAddExpense.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get quickAddExpense;

  /// No description provided for @quickAddExpenseHint.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Ausgabe mit Kategorie'**
  String get quickAddExpenseHint;

  /// No description provided for @quickAddIncome.
  ///
  /// In de, this message translates to:
  /// **'Einnahme'**
  String get quickAddIncome;

  /// No description provided for @quickAddIncomeHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Verkauf, Geschenk, Rückerstattung'**
  String get quickAddIncomeHint;

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeBody.
  ///
  /// In de, this message translates to:
  /// **'Deine Finanzen bleiben auf diesem Gerät – ohne Konto, ohne Cloud, ohne Tracking. Schütze sie mit einer PIN oder einem Passwort.'**
  String get setupWelcomeBody;

  /// No description provided for @setupChooseMethod.
  ///
  /// In de, this message translates to:
  /// **'Wie möchtest du entsperren?'**
  String get setupChooseMethod;

  /// No description provided for @credentialPin.
  ///
  /// In de, this message translates to:
  /// **'PIN'**
  String get credentialPin;

  /// No description provided for @credentialPinHint.
  ///
  /// In de, this message translates to:
  /// **'4 bis 8 Ziffern'**
  String get credentialPinHint;

  /// No description provided for @credentialPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get credentialPassword;

  /// No description provided for @credentialPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen'**
  String get credentialPasswordHint;

  /// No description provided for @setupCreatePin.
  ///
  /// In de, this message translates to:
  /// **'PIN festlegen'**
  String get setupCreatePin;

  /// No description provided for @setupConfirmPin.
  ///
  /// In de, this message translates to:
  /// **'PIN wiederholen'**
  String get setupConfirmPin;

  /// No description provided for @setupCreatePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort festlegen'**
  String get setupCreatePassword;

  /// No description provided for @setupConfirmPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get setupConfirmPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen'**
  String get passwordTooShort;

  /// No description provided for @pinTooShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 4 Ziffern'**
  String get pinTooShort;

  /// No description provided for @credentialsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Stimmt nicht überein – bitte nochmal.'**
  String get credentialsMismatch;

  /// No description provided for @setupBiometricTitle.
  ///
  /// In de, this message translates to:
  /// **'Mit {method} entsperren?'**
  String setupBiometricTitle(String method);

  /// No description provided for @setupBiometricBody.
  ///
  /// In de, this message translates to:
  /// **'Schneller entsperren. Deine PIN bzw. dein Passwort funktioniert weiterhin.'**
  String get setupBiometricBody;

  /// No description provided for @enableBiometric.
  ///
  /// In de, this message translates to:
  /// **'Aktivieren'**
  String get enableBiometric;

  /// No description provided for @notNow.
  ///
  /// In de, this message translates to:
  /// **'Nicht jetzt'**
  String get notNow;

  /// No description provided for @setupForgetWarning.
  ///
  /// In de, this message translates to:
  /// **'Wichtig: PIN und Passwort lassen sich nicht wiederherstellen. Lege regelmäßig ein Backup an.'**
  String get setupForgetWarning;

  /// No description provided for @setupFinishing.
  ///
  /// In de, this message translates to:
  /// **'Dein Tresor wird verschlüsselt …'**
  String get setupFinishing;

  /// No description provided for @biometricFingerprint.
  ///
  /// In de, this message translates to:
  /// **'Fingerabdruck'**
  String get biometricFingerprint;

  /// No description provided for @biometricFace.
  ///
  /// In de, this message translates to:
  /// **'Face ID'**
  String get biometricFace;

  /// No description provided for @biometricGeneric.
  ///
  /// In de, this message translates to:
  /// **'Biometrie'**
  String get biometricGeneric;

  /// No description provided for @unlockEnterPin.
  ///
  /// In de, this message translates to:
  /// **'PIN eingeben'**
  String get unlockEnterPin;

  /// No description provided for @unlockEnterPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get unlockEnterPassword;

  /// No description provided for @unlockWrong.
  ///
  /// In de, this message translates to:
  /// **'Falsch, bitte nochmal.'**
  String get unlockWrong;

  /// No description provided for @unlockLockedOut.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Versuche. Bitte warte {time}.'**
  String unlockLockedOut(String time);

  /// No description provided for @unlockWithBiometric.
  ///
  /// In de, this message translates to:
  /// **'Mit {method} entsperren'**
  String unlockWithBiometric(String method);

  /// No description provided for @biometricReason.
  ///
  /// In de, this message translates to:
  /// **'Entsperre deine Finanzübersicht'**
  String get biometricReason;

  /// No description provided for @unlocking.
  ///
  /// In de, this message translates to:
  /// **'Entsperre …'**
  String get unlocking;

  /// No description provided for @forgotCredential.
  ///
  /// In de, this message translates to:
  /// **'Vergessen?'**
  String get forgotCredential;

  /// No description provided for @forgotTitle.
  ///
  /// In de, this message translates to:
  /// **'PIN oder Passwort vergessen'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In de, this message translates to:
  /// **'Ohne PIN bzw. Passwort lassen sich deine Daten nicht entschlüsseln – von niemandem. Du kannst die App zurücksetzen und danach ein Backup einspielen.'**
  String get forgotBody;

  /// No description provided for @resetApp.
  ///
  /// In de, this message translates to:
  /// **'App zurücksetzen'**
  String get resetApp;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten löschen?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Alle Konten, Erfassungen und Einstellungen auf diesem Gerät werden endgültig gelöscht.'**
  String get resetConfirmBody;

  /// No description provided for @resetTypeConfirm.
  ///
  /// In de, this message translates to:
  /// **'Zum Bestätigen {word} eingeben'**
  String resetTypeConfirm(String word);

  /// No description provided for @resetConfirmWord.
  ///
  /// In de, this message translates to:
  /// **'LÖSCHEN'**
  String get resetConfirmWord;

  /// No description provided for @keyMissingTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten nicht lesbar'**
  String get keyMissingTitle;

  /// No description provided for @keyMissingBody.
  ///
  /// In de, this message translates to:
  /// **'Der Geräteschlüssel fehlt, zum Beispiel nach einer Wiederherstellung auf einem neuen Gerät. Setze die App zurück und spiele dein Backup ein.'**
  String get keyMissingBody;

  /// No description provided for @secondsShort.
  ///
  /// In de, this message translates to:
  /// **'{count} s'**
  String secondsShort(int count);

  /// No description provided for @minutesShort.
  ///
  /// In de, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @dashboardTitle.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get dashboardTitle;

  /// No description provided for @asOf.
  ///
  /// In de, this message translates to:
  /// **'Stand {date}'**
  String asOf(String date);

  /// No description provided for @customizeDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard anpassen'**
  String get customizeDashboard;

  /// No description provided for @customizeHint.
  ///
  /// In de, this message translates to:
  /// **'Ziehen zum Sortieren, Auge zum Ein- und Ausblenden, Größe pro Karte wählen.'**
  String get customizeHint;

  /// No description provided for @sizeCompact.
  ///
  /// In de, this message translates to:
  /// **'Kompakt'**
  String get sizeCompact;

  /// No description provided for @sizeLarge.
  ///
  /// In de, this message translates to:
  /// **'Groß'**
  String get sizeLarge;

  /// No description provided for @resetLayout.
  ///
  /// In de, this message translates to:
  /// **'Standard wiederherstellen'**
  String get resetLayout;

  /// No description provided for @cardNetWorth.
  ///
  /// In de, this message translates to:
  /// **'Gesamtvermögen'**
  String get cardNetWorth;

  /// No description provided for @cardSpending.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben im Monat'**
  String get cardSpending;

  /// No description provided for @cardSavingsGoal.
  ///
  /// In de, this message translates to:
  /// **'Sparziel'**
  String get cardSavingsGoal;

  /// No description provided for @cardCategories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get cardCategories;

  /// No description provided for @cardChart.
  ///
  /// In de, this message translates to:
  /// **'Vermögensentwicklung'**
  String get cardChart;

  /// No description provided for @cardAccounts.
  ///
  /// In de, this message translates to:
  /// **'Konten'**
  String get cardAccounts;

  /// No description provided for @cardRecurring.
  ///
  /// In de, this message translates to:
  /// **'Daueraufträge & Abos'**
  String get cardRecurring;

  /// No description provided for @cardLastPeriod.
  ///
  /// In de, this message translates to:
  /// **'Letzter Zeitraum (geschätzt)'**
  String get cardLastPeriod;

  /// No description provided for @sinceLastEntry.
  ///
  /// In de, this message translates to:
  /// **'seit letzter Erfassung'**
  String get sinceLastEntry;

  /// No description provided for @sinceYearStart.
  ///
  /// In de, this message translates to:
  /// **'seit Jahresanfang'**
  String get sinceYearStart;

  /// No description provided for @liquid.
  ///
  /// In de, this message translates to:
  /// **'Liquide'**
  String get liquid;

  /// No description provided for @invested.
  ///
  /// In de, this message translates to:
  /// **'Investiert'**
  String get invested;

  /// No description provided for @debts.
  ///
  /// In de, this message translates to:
  /// **'Schulden'**
  String get debts;

  /// No description provided for @emptyWelcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get emptyWelcomeTitle;

  /// No description provided for @emptyWelcomeBody.
  ///
  /// In de, this message translates to:
  /// **'Lege deine Konten an – Girokonto, Sparkonto, Depot, Bargeld … so viele du willst.'**
  String get emptyWelcomeBody;

  /// No description provided for @emptyAddAccount.
  ///
  /// In de, this message translates to:
  /// **'Erstes Konto anlegen'**
  String get emptyAddAccount;

  /// No description provided for @emptyFirstEntryTitle.
  ///
  /// In de, this message translates to:
  /// **'Erste Erfassung'**
  String get emptyFirstEntryTitle;

  /// No description provided for @emptyFirstEntryBody.
  ///
  /// In de, this message translates to:
  /// **'Trag deine aktuellen Kontostände ein. Ab der zweiten Erfassung siehst du Veränderungen und Schätzungen.'**
  String get emptyFirstEntryBody;

  /// No description provided for @emptyFirstEntryButton.
  ///
  /// In de, this message translates to:
  /// **'Kontostände eintragen'**
  String get emptyFirstEntryButton;

  /// No description provided for @unassigned.
  ///
  /// In de, this message translates to:
  /// **'Nicht zugeordnet'**
  String get unassigned;

  /// No description provided for @unassignedHint.
  ///
  /// In de, this message translates to:
  /// **'Aus den Kontoständen geschätzt: Ausgaben, die nicht einzeln erfasst wurden.'**
  String get unassignedHint;

  /// No description provided for @fixedCosts.
  ///
  /// In de, this message translates to:
  /// **'Fixkosten'**
  String get fixedCosts;

  /// No description provided for @singleBookings.
  ///
  /// In de, this message translates to:
  /// **'Einzelbuchungen'**
  String get singleBookings;

  /// No description provided for @total.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get total;

  /// No description provided for @noSpendingThisMonth.
  ///
  /// In de, this message translates to:
  /// **'Keine Ausgaben in diesem Monat'**
  String get noSpendingThisMonth;

  /// No description provided for @goalNotSet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Sparziel festgelegt'**
  String get goalNotSet;

  /// No description provided for @goalSetUp.
  ///
  /// In de, this message translates to:
  /// **'Sparziel festlegen'**
  String get goalSetUp;

  /// No description provided for @goalRateLabel.
  ///
  /// In de, this message translates to:
  /// **'Sparquote laut Plan'**
  String get goalRateLabel;

  /// No description provided for @goalNetWorthLabel.
  ///
  /// In de, this message translates to:
  /// **'Vermögensziel'**
  String get goalNetWorthLabel;

  /// No description provided for @goalOf.
  ///
  /// In de, this message translates to:
  /// **'{current} von {target}'**
  String goalOf(String current, String target);

  /// No description provided for @goalRemaining.
  ///
  /// In de, this message translates to:
  /// **'noch {amount}'**
  String goalRemaining(String amount);

  /// No description provided for @goalReached.
  ///
  /// In de, this message translates to:
  /// **'Ziel erreicht'**
  String get goalReached;

  /// No description provided for @chartAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get chartAll;

  /// No description provided for @chartYear.
  ///
  /// In de, this message translates to:
  /// **'1J'**
  String get chartYear;

  /// No description provided for @rangeSixMonths.
  ///
  /// In de, this message translates to:
  /// **'6M'**
  String get rangeSixMonths;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In de, this message translates to:
  /// **'3M'**
  String get rangeThreeMonths;

  /// No description provided for @rangeMonth.
  ///
  /// In de, this message translates to:
  /// **'1M'**
  String get rangeMonth;

  /// No description provided for @rangeWeek.
  ///
  /// In de, this message translates to:
  /// **'1W'**
  String get rangeWeek;

  /// No description provided for @rangeDay.
  ///
  /// In de, this message translates to:
  /// **'1T'**
  String get rangeDay;

  /// No description provided for @inRange.
  ///
  /// In de, this message translates to:
  /// **'im Zeitraum'**
  String get inRange;

  /// No description provided for @historyLines.
  ///
  /// In de, this message translates to:
  /// **'Kurven'**
  String get historyLines;

  /// No description provided for @openHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf öffnen'**
  String get openHistory;

  /// No description provided for @chartNeedTwo.
  ///
  /// In de, this message translates to:
  /// **'Ab zwei Erfassungen siehst du hier den Verlauf.'**
  String get chartNeedTwo;

  /// No description provided for @recurringIncome.
  ///
  /// In de, this message translates to:
  /// **'Fixe Einnahmen'**
  String get recurringIncome;

  /// No description provided for @recurringExpenses.
  ///
  /// In de, this message translates to:
  /// **'Fixe Ausgaben'**
  String get recurringExpenses;

  /// No description provided for @recurringSavings.
  ///
  /// In de, this message translates to:
  /// **'Sparen gesamt'**
  String get recurringSavings;

  /// No description provided for @recurringSavingsInvested.
  ///
  /// In de, this message translates to:
  /// **'davon in Anlagen'**
  String get recurringSavingsInvested;

  /// No description provided for @recurringFree.
  ///
  /// In de, this message translates to:
  /// **'Frei verfügbar'**
  String get recurringFree;

  /// No description provided for @savingsRate.
  ///
  /// In de, this message translates to:
  /// **'Sparquote'**
  String get savingsRate;

  /// No description provided for @periodDays.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum'**
  String get periodDays;

  /// No description provided for @daysCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Tag} other{{count} Tage}}'**
  String daysCount(int count);

  /// No description provided for @periodDelta.
  ///
  /// In de, this message translates to:
  /// **'Veränderung Gesamtvermögen'**
  String get periodDelta;

  /// No description provided for @periodVariable.
  ///
  /// In de, this message translates to:
  /// **'gesch. variable Ausgaben'**
  String get periodVariable;

  /// No description provided for @periodReturn.
  ///
  /// In de, this message translates to:
  /// **'gesch. Rendite Anlagen'**
  String get periodReturn;

  /// No description provided for @periodHint.
  ///
  /// In de, this message translates to:
  /// **'Variable Ausgaben = was zusätzlich zu den Daueraufträgen weg ist. Rendite = Wertänderung der Anlagen ohne deine Einzahlungen. Grobe Schätzung.'**
  String get periodHint;

  /// No description provided for @periodNeedTwo.
  ///
  /// In de, this message translates to:
  /// **'Ab zwei Erfassungen verfügbar.'**
  String get periodNeedTwo;

  /// No description provided for @addAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto hinzufügen'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto bearbeiten'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In de, this message translates to:
  /// **'Kontoname'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In de, this message translates to:
  /// **'Kontotyp'**
  String get accountType;

  /// No description provided for @accountIcon.
  ///
  /// In de, this message translates to:
  /// **'Symbol'**
  String get accountIcon;

  /// No description provided for @accountColor.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get accountColor;

  /// No description provided for @accountGoal.
  ///
  /// In de, this message translates to:
  /// **'Sparziel für dieses Konto'**
  String get accountGoal;

  /// No description provided for @archiveAccount.
  ///
  /// In de, this message translates to:
  /// **'Archivieren'**
  String get archiveAccount;

  /// No description provided for @unarchiveAccount.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get unarchiveAccount;

  /// No description provided for @archiveHint.
  ///
  /// In de, this message translates to:
  /// **'Archivierte Konten erscheinen nicht mehr bei neuen Erfassungen. Setze den Stand vorher auf 0, wenn das Konto aufgelöst ist.'**
  String get archiveHint;

  /// No description provided for @deleteAccountBody.
  ///
  /// In de, this message translates to:
  /// **'Das Konto und alle seine Stände in früheren Erfassungen werden gelöscht.'**
  String get deleteAccountBody;

  /// No description provided for @noAccounts.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Konten'**
  String get noAccounts;

  /// No description provided for @balance.
  ///
  /// In de, this message translates to:
  /// **'Stand'**
  String get balance;

  /// No description provided for @share.
  ///
  /// In de, this message translates to:
  /// **'Anteil'**
  String get share;

  /// No description provided for @archivedSection.
  ///
  /// In de, this message translates to:
  /// **'Archiviert'**
  String get archivedSection;

  /// No description provided for @manageTypes.
  ///
  /// In de, this message translates to:
  /// **'Kontotypen verwalten'**
  String get manageTypes;

  /// No description provided for @accountTypesTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontotypen'**
  String get accountTypesTitle;

  /// No description provided for @addAccountType.
  ///
  /// In de, this message translates to:
  /// **'Kontotyp hinzufügen'**
  String get addAccountType;

  /// No description provided for @editAccountType.
  ///
  /// In de, this message translates to:
  /// **'Kontotyp bearbeiten'**
  String get editAccountType;

  /// No description provided for @behavior.
  ///
  /// In de, this message translates to:
  /// **'Verhalten'**
  String get behavior;

  /// No description provided for @behaviorLiquid.
  ///
  /// In de, this message translates to:
  /// **'Liquide'**
  String get behaviorLiquid;

  /// No description provided for @behaviorLiquidHint.
  ///
  /// In de, this message translates to:
  /// **'Bank, Bargeld – für Einnahmen und Ausgaben'**
  String get behaviorLiquidHint;

  /// No description provided for @behaviorInvested.
  ///
  /// In de, this message translates to:
  /// **'Investiert'**
  String get behaviorInvested;

  /// No description provided for @behaviorInvestedHint.
  ///
  /// In de, this message translates to:
  /// **'Depot, Fonds, Gold – schwankt mit dem Markt'**
  String get behaviorInvestedHint;

  /// No description provided for @behaviorDebt.
  ///
  /// In de, this message translates to:
  /// **'Schulden'**
  String get behaviorDebt;

  /// No description provided for @behaviorDebtHint.
  ///
  /// In de, this message translates to:
  /// **'Kredit, Kreditkarte – wird vom Vermögen abgezogen. Offenen Betrag positiv eintragen.'**
  String get behaviorDebtHint;

  /// No description provided for @typeInUse.
  ///
  /// In de, this message translates to:
  /// **'Wird noch von {count, plural, =1{1 Konto} other{{count} Konten}} verwendet.'**
  String typeInUse(int count);

  /// No description provided for @snapshotNew.
  ///
  /// In de, this message translates to:
  /// **'Kontostände erfassen'**
  String get snapshotNew;

  /// No description provided for @snapshotEdit.
  ///
  /// In de, this message translates to:
  /// **'Erfassung bearbeiten'**
  String get snapshotEdit;

  /// No description provided for @snapshotHint.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen = letzter Stand wird übernommen.'**
  String get snapshotHint;

  /// No description provided for @lastValue.
  ///
  /// In de, this message translates to:
  /// **'zuletzt {amount}'**
  String lastValue(String amount);

  /// No description provided for @snapshotTotalPreview.
  ///
  /// In de, this message translates to:
  /// **'Gesamtvermögen danach'**
  String get snapshotTotalPreview;

  /// No description provided for @deleteEntry.
  ///
  /// In de, this message translates to:
  /// **'Erfassung löschen'**
  String get deleteEntry;

  /// No description provided for @needAccountsFirst.
  ///
  /// In de, this message translates to:
  /// **'Lege zuerst ein Konto an.'**
  String get needAccountsFirst;

  /// No description provided for @toggleSign.
  ///
  /// In de, this message translates to:
  /// **'Vorzeichen wechseln'**
  String get toggleSign;

  /// No description provided for @expenseNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Ausgabe'**
  String get expenseNew;

  /// No description provided for @incomeNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Einnahme'**
  String get incomeNew;

  /// No description provided for @transactionEdit.
  ///
  /// In de, this message translates to:
  /// **'Buchung bearbeiten'**
  String get transactionEdit;

  /// No description provided for @category.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get category;

  /// No description provided for @account.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get account;

  /// No description provided for @noAccount.
  ///
  /// In de, this message translates to:
  /// **'Kein Konto'**
  String get noAccount;

  /// No description provided for @noCategory.
  ///
  /// In de, this message translates to:
  /// **'Ohne Kategorie'**
  String get noCategory;

  /// No description provided for @transactionHint.
  ///
  /// In de, this message translates to:
  /// **'Einzelbuchungen ändern keinen Kontostand – sie zeigen, wofür das Geld weg ist.'**
  String get transactionHint;

  /// No description provided for @historyBalances.
  ///
  /// In de, this message translates to:
  /// **'Kontostände'**
  String get historyBalances;

  /// No description provided for @historyBookings.
  ///
  /// In de, this message translates to:
  /// **'Buchungen'**
  String get historyBookings;

  /// No description provided for @noSnapshots.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Erfassungen'**
  String get noSnapshots;

  /// No description provided for @noTransactions.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Buchungen'**
  String get noTransactions;

  /// No description provided for @carriedOver.
  ///
  /// In de, this message translates to:
  /// **'übernommen'**
  String get carriedOver;

  /// No description provided for @monthOut.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben {amount}'**
  String monthOut(String amount);

  /// No description provided for @monthIn.
  ///
  /// In de, this message translates to:
  /// **'Einnahmen {amount}'**
  String monthIn(String amount);

  /// No description provided for @recurringTitle.
  ///
  /// In de, this message translates to:
  /// **'Daueraufträge & Abos'**
  String get recurringTitle;

  /// No description provided for @recurringHint.
  ///
  /// In de, this message translates to:
  /// **'Nur wiederkehrende Posten: Gehalt, Miete, Abos, Sparpläne. Sie bewegen kein Geld, sondern fließen in Planung und Schätzungen ein.'**
  String get recurringHint;

  /// No description provided for @addRecurring.
  ///
  /// In de, this message translates to:
  /// **'Posten hinzufügen'**
  String get addRecurring;

  /// No description provided for @editRecurring.
  ///
  /// In de, this message translates to:
  /// **'Posten bearbeiten'**
  String get editRecurring;

  /// No description provided for @recurringName.
  ///
  /// In de, this message translates to:
  /// **'Bezeichnung'**
  String get recurringName;

  /// No description provided for @recurringType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get recurringType;

  /// No description provided for @typeIncome.
  ///
  /// In de, this message translates to:
  /// **'Einnahme'**
  String get typeIncome;

  /// No description provided for @typeExpense.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get typeExpense;

  /// No description provided for @typeSaving.
  ///
  /// In de, this message translates to:
  /// **'Sparen'**
  String get typeSaving;

  /// No description provided for @savingHint.
  ///
  /// In de, this message translates to:
  /// **'Sparen = Übertrag auf ein eigenes Konto. Zählt nicht als Ausgabe – das Geld bleibt dein Vermögen.'**
  String get savingHint;

  /// No description provided for @rhythm.
  ///
  /// In de, this message translates to:
  /// **'Rhythmus'**
  String get rhythm;

  /// No description provided for @rhythmWeekly.
  ///
  /// In de, this message translates to:
  /// **'wöchentlich'**
  String get rhythmWeekly;

  /// No description provided for @rhythmMonthly.
  ///
  /// In de, this message translates to:
  /// **'monatlich'**
  String get rhythmMonthly;

  /// No description provided for @rhythmBimonthly.
  ///
  /// In de, this message translates to:
  /// **'zweimonatlich'**
  String get rhythmBimonthly;

  /// No description provided for @rhythmQuarterly.
  ///
  /// In de, this message translates to:
  /// **'vierteljährlich'**
  String get rhythmQuarterly;

  /// No description provided for @rhythmHalfYearly.
  ///
  /// In de, this message translates to:
  /// **'halbjährlich'**
  String get rhythmHalfYearly;

  /// No description provided for @rhythmYearly.
  ///
  /// In de, this message translates to:
  /// **'jährlich'**
  String get rhythmYearly;

  /// No description provided for @dueDay.
  ///
  /// In de, this message translates to:
  /// **'Fällig am (Tag)'**
  String get dueDay;

  /// No description provided for @fromAccount.
  ///
  /// In de, this message translates to:
  /// **'Von Konto'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In de, this message translates to:
  /// **'Auf Konto'**
  String get toAccount;

  /// No description provided for @active.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get active;

  /// No description provided for @startDate.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In de, this message translates to:
  /// **'Ende'**
  String get endDate;

  /// No description provided for @inactive.
  ///
  /// In de, this message translates to:
  /// **'inaktiv'**
  String get inactive;

  /// No description provided for @fixedByCategory.
  ///
  /// In de, this message translates to:
  /// **'Fixausgaben nach Kategorie'**
  String get fixedByCategory;

  /// No description provided for @noRecurring.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Daueraufträge'**
  String get noRecurring;

  /// No description provided for @amountPositiveHint.
  ///
  /// In de, this message translates to:
  /// **'Betrag immer positiv – die Richtung ergibt sich aus dem Typ.'**
  String get amountPositiveHint;

  /// No description provided for @investmentsTitle.
  ///
  /// In de, this message translates to:
  /// **'Investitionen'**
  String get investmentsTitle;

  /// No description provided for @investmentsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Jährlicher Kaufplan'**
  String get investmentsSubtitle;

  /// No description provided for @annualBudget.
  ///
  /// In de, this message translates to:
  /// **'Jahresbudget'**
  String get annualBudget;

  /// No description provided for @limitMarkup.
  ///
  /// In de, this message translates to:
  /// **'Limit-Aufschlag auf Kurs'**
  String get limitMarkup;

  /// No description provided for @feePerOrder.
  ///
  /// In de, this message translates to:
  /// **'Spesen pro Order (geschätzt)'**
  String get feePerOrder;

  /// No description provided for @addEtf.
  ///
  /// In de, this message translates to:
  /// **'ETF hinzufügen'**
  String get addEtf;

  /// No description provided for @editEtf.
  ///
  /// In de, this message translates to:
  /// **'ETF bearbeiten'**
  String get editEtf;

  /// No description provided for @isin.
  ///
  /// In de, this message translates to:
  /// **'ISIN'**
  String get isin;

  /// No description provided for @etfShare.
  ///
  /// In de, this message translates to:
  /// **'Anteil am Budget'**
  String get etfShare;

  /// No description provided for @manualPrice.
  ///
  /// In de, this message translates to:
  /// **'Kurs von Hand'**
  String get manualPrice;

  /// No description provided for @amountPerYear.
  ///
  /// In de, this message translates to:
  /// **'Betrag pro Jahr'**
  String get amountPerYear;

  /// No description provided for @priceUsed.
  ///
  /// In de, this message translates to:
  /// **'Kurs'**
  String get priceUsed;

  /// No description provided for @limitPrice.
  ///
  /// In de, this message translates to:
  /// **'Limit'**
  String get limitPrice;

  /// No description provided for @wholeUnits.
  ///
  /// In de, this message translates to:
  /// **'Ganze Stück'**
  String get wholeUnits;

  /// No description provided for @wholeCost.
  ///
  /// In de, this message translates to:
  /// **'Kosten ganze Stück'**
  String get wholeCost;

  /// No description provided for @unitsByAmount.
  ///
  /// In de, this message translates to:
  /// **'Stück bei Betrags-Kauf'**
  String get unitsByAmount;

  /// No description provided for @priceSourceOnline.
  ///
  /// In de, this message translates to:
  /// **'online · {time}'**
  String priceSourceOnline(String time);

  /// No description provided for @priceSourceManual.
  ///
  /// In de, this message translates to:
  /// **'von Hand'**
  String get priceSourceManual;

  /// No description provided for @priceSourceNone.
  ///
  /// In de, this message translates to:
  /// **'kein Kurs'**
  String get priceSourceNone;

  /// No description provided for @sumShares.
  ///
  /// In de, this message translates to:
  /// **'Summe Anteile'**
  String get sumShares;

  /// No description provided for @sharesInvalid.
  ///
  /// In de, this message translates to:
  /// **'Die Anteile ergeben nicht 100 %'**
  String get sharesInvalid;

  /// No description provided for @restWholeUnits.
  ///
  /// In de, this message translates to:
  /// **'Rest bei ganzen Stück'**
  String get restWholeUnits;

  /// No description provided for @restHint.
  ///
  /// In de, this message translates to:
  /// **'→ in {name} stecken (günstigster Stückpreis)'**
  String restHint(String name);

  /// No description provided for @feesTotal.
  ///
  /// In de, this message translates to:
  /// **'Spesen gesamt ({count} Orders)'**
  String feesTotal(int count);

  /// No description provided for @feesShare.
  ///
  /// In de, this message translates to:
  /// **'Spesen in % vom Budget'**
  String get feesShare;

  /// No description provided for @refreshPrices.
  ///
  /// In de, this message translates to:
  /// **'Kurse aktualisieren'**
  String get refreshPrices;

  /// No description provided for @pricesUpdated.
  ///
  /// In de, this message translates to:
  /// **'{count} Kurse aktualisiert'**
  String pricesUpdated(int count);

  /// No description provided for @pricesFailed.
  ///
  /// In de, this message translates to:
  /// **'Kurse konnten nicht geladen werden. Trag den Kurs von Hand ein.'**
  String get pricesFailed;

  /// No description provided for @onlineDisabledHint.
  ///
  /// In de, this message translates to:
  /// **'Online-Kurse sind aus (Einstellungen). Kurse trägst du von Hand ein.'**
  String get onlineDisabledHint;

  /// No description provided for @howToBuyTitle.
  ///
  /// In de, this message translates to:
  /// **'So kaufst du'**
  String get howToBuyTitle;

  /// No description provided for @howToBuy1.
  ///
  /// In de, this message translates to:
  /// **'Ganze Stück: Stückzahl aus „Ganze Stück“, Auftragsart Limit, Limit wie angezeigt.'**
  String get howToBuy1;

  /// No description provided for @howToBuy2.
  ///
  /// In de, this message translates to:
  /// **'Ist „Ganze Stück“ 0 (Betrag kleiner als ein Stück): mit einem Betrag handeln und den Betrag pro Jahr verwenden.'**
  String get howToBuy2;

  /// No description provided for @howToBuy3.
  ///
  /// In de, this message translates to:
  /// **'Online-Kurse sind Tradegate-Kurse und können leicht verzögert sein. Der Kurs bei deiner Bank kann minimal abweichen.'**
  String get howToBuy3;

  /// No description provided for @noEtfs.
  ///
  /// In de, this message translates to:
  /// **'Noch keine ETFs im Plan'**
  String get noEtfs;

  /// No description provided for @purchaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Kaufrechner'**
  String get purchaseTitle;

  /// No description provided for @purchaseSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Lohnt sich der Kauf?'**
  String get purchaseSubtitle;

  /// No description provided for @purchaseSectionPurchase.
  ///
  /// In de, this message translates to:
  /// **'Der Kauf'**
  String get purchaseSectionPurchase;

  /// No description provided for @purchaseLabel.
  ///
  /// In de, this message translates to:
  /// **'Bezeichnung'**
  String get purchaseLabel;

  /// No description provided for @purchaseLabelHint.
  ///
  /// In de, this message translates to:
  /// **'z. B. Motorrad'**
  String get purchaseLabelHint;

  /// No description provided for @purchasePrice.
  ///
  /// In de, this message translates to:
  /// **'Kaufpreis'**
  String get purchasePrice;

  /// No description provided for @purchaseFromSavings.
  ///
  /// In de, this message translates to:
  /// **'davon aus Ersparnissen bezahlt'**
  String get purchaseFromSavings;

  /// No description provided for @purchaseLoanRate.
  ///
  /// In de, this message translates to:
  /// **'Kredit-Zinssatz p. a. (falls Rest finanziert)'**
  String get purchaseLoanRate;

  /// No description provided for @purchaseLoanMonths.
  ///
  /// In de, this message translates to:
  /// **'Kredit-Laufzeit (Monate)'**
  String get purchaseLoanMonths;

  /// No description provided for @purchaseMonthlyCost.
  ///
  /// In de, this message translates to:
  /// **'Laufende Kosten pro Monat'**
  String get purchaseMonthlyCost;

  /// No description provided for @purchaseMonthlyCostHint.
  ///
  /// In de, this message translates to:
  /// **'Versicherung, Steuer, Treibstoff/Strom, Service …'**
  String get purchaseMonthlyCostHint;

  /// No description provided for @purchaseUsageYears.
  ///
  /// In de, this message translates to:
  /// **'Nutzungsdauer (Jahre)'**
  String get purchaseUsageYears;

  /// No description provided for @purchaseResidual.
  ///
  /// In de, this message translates to:
  /// **'Geschätzter Restwert am Ende'**
  String get purchaseResidual;

  /// No description provided for @purchaseResidualHint.
  ///
  /// In de, this message translates to:
  /// **'Bei Konsum (Urlaub, Elektronik) eher 0.'**
  String get purchaseResidualHint;

  /// No description provided for @purchaseSectionAssumptions.
  ///
  /// In de, this message translates to:
  /// **'Deine Annahmen'**
  String get purchaseSectionAssumptions;

  /// No description provided for @purchaseReturn.
  ///
  /// In de, this message translates to:
  /// **'Rendite, wenn das Geld stattdessen investiert wäre'**
  String get purchaseReturn;

  /// No description provided for @purchaseEmergency.
  ///
  /// In de, this message translates to:
  /// **'Notgroschen-Ziel (soll liquide bleiben)'**
  String get purchaseEmergency;

  /// No description provided for @purchaseTargetRate.
  ///
  /// In de, this message translates to:
  /// **'Ziel-Sparquote'**
  String get purchaseTargetRate;

  /// No description provided for @purchaseSectionSituation.
  ///
  /// In de, this message translates to:
  /// **'Deine aktuelle Lage'**
  String get purchaseSectionSituation;

  /// No description provided for @monthlyIncome.
  ///
  /// In de, this message translates to:
  /// **'Einnahmen pro Monat'**
  String get monthlyIncome;

  /// No description provided for @monthlyFixed.
  ///
  /// In de, this message translates to:
  /// **'Fixe Ausgaben pro Monat'**
  String get monthlyFixed;

  /// No description provided for @monthlySavings.
  ///
  /// In de, this message translates to:
  /// **'Sparen pro Monat'**
  String get monthlySavings;

  /// No description provided for @monthlyFree.
  ///
  /// In de, this message translates to:
  /// **'Frei verfügbar pro Monat'**
  String get monthlyFree;

  /// No description provided for @currentRate.
  ///
  /// In de, this message translates to:
  /// **'Sparquote aktuell'**
  String get currentRate;

  /// No description provided for @purchaseSectionImmediate.
  ///
  /// In de, this message translates to:
  /// **'Sofort-Effekt'**
  String get purchaseSectionImmediate;

  /// No description provided for @loanAmount.
  ///
  /// In de, this message translates to:
  /// **'Kreditbetrag'**
  String get loanAmount;

  /// No description provided for @loanPayment.
  ///
  /// In de, this message translates to:
  /// **'Kreditrate pro Monat'**
  String get loanPayment;

  /// No description provided for @interestTotal.
  ///
  /// In de, this message translates to:
  /// **'Zinskosten gesamt'**
  String get interestTotal;

  /// No description provided for @liquidAfter.
  ///
  /// In de, this message translates to:
  /// **'Liquides Geld nach dem Kauf'**
  String get liquidAfter;

  /// No description provided for @shareOfWealth.
  ///
  /// In de, this message translates to:
  /// **'Anteil am Gesamtvermögen'**
  String get shareOfWealth;

  /// No description provided for @monthsLost.
  ///
  /// In de, this message translates to:
  /// **'Zurückgeworfen um … Monate Sparen'**
  String get monthsLost;

  /// No description provided for @monthsToSave.
  ///
  /// In de, this message translates to:
  /// **'Ansparen aus freiem Geld (Monate)'**
  String get monthsToSave;

  /// No description provided for @purchaseSectionMonthly.
  ///
  /// In de, this message translates to:
  /// **'Laufend (pro Monat)'**
  String get purchaseSectionMonthly;

  /// No description provided for @extraMonthly.
  ///
  /// In de, this message translates to:
  /// **'Mehrbelastung (laufend + Kreditrate)'**
  String get extraMonthly;

  /// No description provided for @freeAfter.
  ///
  /// In de, this message translates to:
  /// **'Frei verfügbar danach'**
  String get freeAfter;

  /// No description provided for @rateAfter.
  ///
  /// In de, this message translates to:
  /// **'Sparquote danach'**
  String get rateAfter;

  /// No description provided for @purchaseSectionUsage.
  ///
  /// In de, this message translates to:
  /// **'Über die Nutzungsdauer'**
  String get purchaseSectionUsage;

  /// No description provided for @totalCost.
  ///
  /// In de, this message translates to:
  /// **'Gesamtkosten (Wertverlust + laufend + Zinsen)'**
  String get totalCost;

  /// No description provided for @costPerMonth.
  ///
  /// In de, this message translates to:
  /// **'Kosten pro Monat der Nutzung'**
  String get costPerMonth;

  /// No description provided for @remainingDebt.
  ///
  /// In de, this message translates to:
  /// **'Restschuld am Ende der Nutzung'**
  String get remainingDebt;

  /// No description provided for @wealthDisadvantage.
  ///
  /// In de, this message translates to:
  /// **'Vermögen am Ende weniger als ohne Kauf'**
  String get wealthDisadvantage;

  /// No description provided for @verdictTitle.
  ///
  /// In de, this message translates to:
  /// **'Fazit'**
  String get verdictTitle;

  /// No description provided for @verdictBelowEmergency.
  ///
  /// In de, this message translates to:
  /// **'Dein liquides Geld fällt unter den Notgroschen – Kauf verschieben oder ansparen.'**
  String get verdictBelowEmergency;

  /// No description provided for @verdictCostsExceed.
  ///
  /// In de, this message translates to:
  /// **'Die laufenden Kosten sind höher als dein freier Betrag – du müsstest weniger sparen.'**
  String get verdictCostsExceed;

  /// No description provided for @verdictRateDrops.
  ///
  /// In de, this message translates to:
  /// **'Leistbar, aber deine Sparquote sinkt unter dein Ziel.'**
  String get verdictRateDrops;

  /// No description provided for @verdictLargeShare.
  ///
  /// In de, this message translates to:
  /// **'Leistbar, aber über 25 % deines Vermögens – gut überlegen.'**
  String get verdictLargeShare;

  /// No description provided for @verdictAffordable.
  ///
  /// In de, this message translates to:
  /// **'Leistbar: Notgroschen bleibt, Sparpläne laufen weiter.'**
  String get verdictAffordable;

  /// No description provided for @verdictSummary.
  ///
  /// In de, this message translates to:
  /// **'{label}: kostet dich ca. {perMonth} pro Monat und wirft dich {months} Monate Sparen zurück.'**
  String verdictSummary(String label, String perMonth, String months);

  /// No description provided for @purchaseDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Grobe Schätzung. Renditen sind nicht garantiert – Restwerte und laufende Kosten realistisch ansetzen.'**
  String get purchaseDisclaimer;

  /// No description provided for @purchaseReset.
  ///
  /// In de, this message translates to:
  /// **'Eingaben leeren'**
  String get purchaseReset;

  /// No description provided for @thePurchase.
  ///
  /// In de, this message translates to:
  /// **'Der Kauf'**
  String get thePurchase;

  /// No description provided for @categoriesTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie hinzufügen'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get editCategory;

  /// No description provided for @categoryKind.
  ///
  /// In de, this message translates to:
  /// **'Art'**
  String get categoryKind;

  /// No description provided for @kindExpense.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get kindExpense;

  /// No description provided for @kindIncome.
  ///
  /// In de, this message translates to:
  /// **'Einnahme'**
  String get kindIncome;

  /// No description provided for @categoryInUse.
  ///
  /// In de, this message translates to:
  /// **'Wird noch verwendet – Buchungen und Daueraufträge verlieren die Kategorie.'**
  String get categoryInUse;

  /// No description provided for @icon.
  ///
  /// In de, this message translates to:
  /// **'Symbol'**
  String get icon;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @sectionAppearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get sectionAppearance;

  /// No description provided for @themeLabel.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @darkVariantLabel.
  ///
  /// In de, this message translates to:
  /// **'Dunkler Modus'**
  String get darkVariantLabel;

  /// No description provided for @darkBlack.
  ///
  /// In de, this message translates to:
  /// **'Reines Schwarz'**
  String get darkBlack;

  /// No description provided for @darkBlackHint.
  ///
  /// In de, this message translates to:
  /// **'Spart Strom auf OLED-Displays'**
  String get darkBlackHint;

  /// No description provided for @darkDim.
  ///
  /// In de, this message translates to:
  /// **'Dunkelgrau'**
  String get darkDim;

  /// No description provided for @darkDimHint.
  ///
  /// In de, this message translates to:
  /// **'Etwas heller, weicherer Kontrast'**
  String get darkDimHint;

  /// No description provided for @languageLabel.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In de, this message translates to:
  /// **'Systemsprache'**
  String get languageSystem;

  /// No description provided for @sectionSecurity.
  ///
  /// In de, this message translates to:
  /// **'Sicherheit'**
  String get sectionSecurity;

  /// No description provided for @changeCredential.
  ///
  /// In de, this message translates to:
  /// **'PIN oder Passwort ändern'**
  String get changeCredential;

  /// No description provided for @currentCredential.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle PIN bzw. aktuelles Passwort'**
  String get currentCredential;

  /// No description provided for @credentialChanged.
  ///
  /// In de, this message translates to:
  /// **'Geändert'**
  String get credentialChanged;

  /// No description provided for @biometricUnlock.
  ///
  /// In de, this message translates to:
  /// **'Mit {method} entsperren'**
  String biometricUnlock(String method);

  /// No description provided for @biometricUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät nicht verfügbar'**
  String get biometricUnavailable;

  /// No description provided for @lockAfter.
  ///
  /// In de, this message translates to:
  /// **'Sperren nach dem Verlassen'**
  String get lockAfter;

  /// No description provided for @lockImmediately.
  ///
  /// In de, this message translates to:
  /// **'sofort'**
  String get lockImmediately;

  /// No description provided for @sectionGoal.
  ///
  /// In de, this message translates to:
  /// **'Sparziel'**
  String get sectionGoal;

  /// No description provided for @goalModeRate.
  ///
  /// In de, this message translates to:
  /// **'Monatliche Sparquote'**
  String get goalModeRate;

  /// No description provided for @goalModeRateHint.
  ///
  /// In de, this message translates to:
  /// **'Ziel-Sparquote, auf die du hinarbeitest'**
  String get goalModeRateHint;

  /// No description provided for @goalModeAccount.
  ///
  /// In de, this message translates to:
  /// **'Sparziel pro Konto'**
  String get goalModeAccount;

  /// No description provided for @goalModeAccountHint.
  ///
  /// In de, this message translates to:
  /// **'Beliebiger Zielbetrag je Konto'**
  String get goalModeAccountHint;

  /// No description provided for @goalModeNetWorth.
  ///
  /// In de, this message translates to:
  /// **'Vermögensziel'**
  String get goalModeNetWorth;

  /// No description provided for @goalModeNetWorthHint.
  ///
  /// In de, this message translates to:
  /// **'Ziel für dein Gesamtvermögen'**
  String get goalModeNetWorthHint;

  /// No description provided for @goalTargetRate.
  ///
  /// In de, this message translates to:
  /// **'Ziel-Sparquote'**
  String get goalTargetRate;

  /// No description provided for @goalTargetNetWorth.
  ///
  /// In de, this message translates to:
  /// **'Zielvermögen'**
  String get goalTargetNetWorth;

  /// No description provided for @goalPinnedAccount.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Dashboard zeigen'**
  String get goalPinnedAccount;

  /// No description provided for @goalNoAccountGoals.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kontoziele – trag unten bei einem Konto einen Zielbetrag ein.'**
  String get goalNoAccountGoals;

  /// No description provided for @sectionOnline.
  ///
  /// In de, this message translates to:
  /// **'Online-Kurse'**
  String get sectionOnline;

  /// No description provided for @onlinePricesToggle.
  ///
  /// In de, this message translates to:
  /// **'ETF-Kurse online abrufen'**
  String get onlinePricesToggle;

  /// No description provided for @onlinePricesHint.
  ///
  /// In de, this message translates to:
  /// **'Die einzige Online-Funktion: Auf Knopfdruck wird nur die ISIN an tradegate.de gesendet. Sonst bleibt die App komplett offline.'**
  String get onlinePricesHint;

  /// No description provided for @sectionAbout.
  ///
  /// In de, this message translates to:
  /// **'Über die App'**
  String get sectionAbout;

  /// No description provided for @aboutOffline.
  ///
  /// In de, this message translates to:
  /// **'100 % offline · kein Konto · keine Cloud · kein Tracking'**
  String get aboutOffline;

  /// No description provided for @guideTitle.
  ///
  /// In de, this message translates to:
  /// **'Anleitung'**
  String get guideTitle;

  /// No description provided for @backupTitle.
  ///
  /// In de, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In de, this message translates to:
  /// **'Ohne Cloud liegen deine Daten nur auf diesem Gerät. Exportiere regelmäßig ein verschlüsseltes Backup und bewahre es sicher auf.'**
  String get backupIntro;

  /// No description provided for @backupExport.
  ///
  /// In de, this message translates to:
  /// **'Backup exportieren'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In de, this message translates to:
  /// **'Backup einspielen'**
  String get backupImport;

  /// No description provided for @backupPassword.
  ///
  /// In de, this message translates to:
  /// **'Backup-Passwort'**
  String get backupPassword;

  /// No description provided for @backupPasswordRepeat.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get backupPasswordRepeat;

  /// No description provided for @backupPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen. Ohne dieses Passwort lässt sich das Backup nicht öffnen.'**
  String get backupPasswordHint;

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get backupPasswordTooShort;

  /// No description provided for @backupSaved.
  ///
  /// In de, this message translates to:
  /// **'Backup gespeichert'**
  String get backupSaved;

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Backup einspielen?'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Deine aktuellen Daten werden durch das Backup ersetzt.'**
  String get backupImportConfirmBody;

  /// No description provided for @backupRestored.
  ///
  /// In de, this message translates to:
  /// **'Backup eingespielt'**
  String get backupRestored;

  /// No description provided for @backupWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Falsches Passwort'**
  String get backupWrongPassword;

  /// No description provided for @backupInvalid.
  ///
  /// In de, this message translates to:
  /// **'Keine gültige Backup-Datei'**
  String get backupInvalid;

  /// No description provided for @backupFailed.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt.'**
  String get backupFailed;

  /// No description provided for @pleaseWait.
  ///
  /// In de, this message translates to:
  /// **'Bitte warten …'**
  String get pleaseWait;

  /// No description provided for @dangerZone.
  ///
  /// In de, this message translates to:
  /// **'Gefahrenbereich'**
  String get dangerZone;

  /// No description provided for @resetAppHint.
  ///
  /// In de, this message translates to:
  /// **'Löscht alle Daten auf diesem Gerät.'**
  String get resetAppHint;

  /// No description provided for @moreRecurringSub.
  ///
  /// In de, this message translates to:
  /// **'Gehalt, Fixkosten, Abos, Sparpläne'**
  String get moreRecurringSub;

  /// No description provided for @moreInvestmentsSub.
  ///
  /// In de, this message translates to:
  /// **'Jährlicher ETF-Kaufplan'**
  String get moreInvestmentsSub;

  /// No description provided for @morePurchaseSub.
  ///
  /// In de, this message translates to:
  /// **'Passt ein Kauf in deinen Plan?'**
  String get morePurchaseSub;

  /// No description provided for @moreCategoriesSub.
  ///
  /// In de, this message translates to:
  /// **'Symbole und Namen für Buchungen'**
  String get moreCategoriesSub;

  /// No description provided for @moreAccountTypesSub.
  ///
  /// In de, this message translates to:
  /// **'Liquide, Investiert, Schulden …'**
  String get moreAccountTypesSub;

  /// No description provided for @moreSettingsSub.
  ///
  /// In de, this message translates to:
  /// **'Design, Sicherheit, Sparziel'**
  String get moreSettingsSub;

  /// No description provided for @moreBackupSub.
  ///
  /// In de, this message translates to:
  /// **'Verschlüsselt sichern und wiederherstellen'**
  String get moreBackupSub;

  /// No description provided for @moreGuideSub.
  ///
  /// In de, this message translates to:
  /// **'So nutzt du die App'**
  String get moreGuideSub;

  /// No description provided for @lockNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sperren'**
  String get lockNow;

  /// No description provided for @guideSetupTitle.
  ///
  /// In de, this message translates to:
  /// **'Einmalig einrichten'**
  String get guideSetupTitle;

  /// No description provided for @guideSetup1.
  ///
  /// In de, this message translates to:
  /// **'Konten anlegen – so viele du willst – und den Kontotyp wählen: Liquide = Bankkonto/Bargeld, Investiert = Depot/Fonds/Gold, Schulden = Kredite.'**
  String get guideSetup1;

  /// No description provided for @guideSetup2.
  ///
  /// In de, this message translates to:
  /// **'Unter „Daueraufträge“ Gehalt, Fixkosten, Abos und Sparpläne eintragen. Betrag immer positiv, Typ wählen (Einnahme / Ausgabe / Sparen).'**
  String get guideSetup2;

  /// No description provided for @guideSetup3.
  ///
  /// In de, this message translates to:
  /// **'Über den „+“-Knopf die ersten Kontostände erfassen.'**
  String get guideSetup3;

  /// No description provided for @guideRegularTitle.
  ///
  /// In de, this message translates to:
  /// **'Regelmäßig (z. B. 2× im Monat – kein Muss)'**
  String get guideRegularTitle;

  /// No description provided for @guideRegular1.
  ///
  /// In de, this message translates to:
  /// **'„+“ → Kontostände aktualisieren. Ein Konto leer lassen = letzter Stand wird übernommen.'**
  String get guideRegular1;

  /// No description provided for @guideRegular2.
  ///
  /// In de, this message translates to:
  /// **'Optional einzelne Ausgaben oder Einnahmen erfassen. Sie ändern keinen Kontostand, zeigen aber, wofür das Geld weg ist.'**
  String get guideRegular2;

  /// No description provided for @guideRegular3.
  ///
  /// In de, this message translates to:
  /// **'Dashboard, Diagramm und Schätzungen rechnen sich automatisch.'**
  String get guideRegular3;

  /// No description provided for @guideNotesTitle.
  ///
  /// In de, this message translates to:
  /// **'Hinweise'**
  String get guideNotesTitle;

  /// No description provided for @guideNote1.
  ///
  /// In de, this message translates to:
  /// **'Abo gekündigt: im Dauerauftrag „Aktiv“ ausschalten oder ein Ende-Datum setzen – der Eintrag bleibt als Historie.'**
  String get guideNote1;

  /// No description provided for @guideNote2.
  ///
  /// In de, this message translates to:
  /// **'Sparen auf ein eigenes Konto zählt nicht als Ausgabe – das Geld bleibt dein Vermögen.'**
  String get guideNote2;

  /// No description provided for @guideNote3.
  ///
  /// In de, this message translates to:
  /// **'Die Schätzungen „variable Ausgaben“ und „Rendite“ nutzen die aktuell aktiven Daueraufträge und sind grobe Richtwerte.'**
  String get guideNote3;

  /// No description provided for @guideNote4.
  ///
  /// In de, this message translates to:
  /// **'Lege regelmäßig ein Backup an – ohne Cloud gibt es sonst keine Kopie deiner Daten.'**
  String get guideNote4;

  /// No description provided for @guideDashboardTitle.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get guideDashboardTitle;

  /// No description provided for @guideDashboard1.
  ///
  /// In de, this message translates to:
  /// **'Über das Stift-Symbol oben rechts sortierst du die Karten, blendest sie ein oder aus und wählst die Größe.'**
  String get guideDashboard1;

  /// No description provided for @discreetOn.
  ///
  /// In de, this message translates to:
  /// **'Beträge verbergen'**
  String get discreetOn;

  /// No description provided for @discreetOff.
  ///
  /// In de, this message translates to:
  /// **'Beträge anzeigen'**
  String get discreetOff;

  /// No description provided for @discreetTitle.
  ///
  /// In de, this message translates to:
  /// **'Diskreter Modus'**
  String get discreetTitle;

  /// No description provided for @discreetHint.
  ///
  /// In de, this message translates to:
  /// **'Zeigt alle Beträge als ••••. Schnell umschalten über das Auge im Dashboard.'**
  String get discreetHint;

  /// No description provided for @later.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get later;

  /// No description provided for @backupLast.
  ///
  /// In de, this message translates to:
  /// **'Letztes Backup: {date}'**
  String backupLast(String date);

  /// No description provided for @backupNone.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät wurde noch kein Backup angelegt.'**
  String get backupNone;

  /// No description provided for @autoBackupTitle.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup'**
  String get autoBackupTitle;

  /// No description provided for @autoBackupIntro.
  ///
  /// In de, this message translates to:
  /// **'Die App legt nach jeder Änderung selbst ein verschlüsseltes Backup in einem Ordner deiner Wahl ab, höchstens eines pro Tag. Die letzten 10 bleiben erhalten, ältere automatische Backups werden gelöscht.'**
  String get autoBackupIntro;

  /// No description provided for @autoBackupTip.
  ///
  /// In de, this message translates to:
  /// **'Ein Backup auf dem Handy hilft nicht, wenn das Handy verloren geht. Kopiere den Ordner deshalb ab und zu auf einen PC oder USB-Stick.'**
  String get autoBackupTip;

  /// No description provided for @autoBackupEnable.
  ///
  /// In de, this message translates to:
  /// **'Ordner wählen und einschalten'**
  String get autoBackupEnable;

  /// No description provided for @autoBackupPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen. Gilt für alle automatischen Backups. Ohne dieses Passwort lassen sie sich nicht öffnen.'**
  String get autoBackupPasswordHint;

  /// No description provided for @autoBackupFolder.
  ///
  /// In de, this message translates to:
  /// **'Ordner'**
  String get autoBackupFolder;

  /// No description provided for @autoBackupLastRun.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert'**
  String get autoBackupLastRun;

  /// No description provided for @autoBackupNever.
  ///
  /// In de, this message translates to:
  /// **'noch nicht'**
  String get autoBackupNever;

  /// No description provided for @autoBackupFailed.
  ///
  /// In de, this message translates to:
  /// **'Das letzte automatische Backup hat nicht geklappt. Wurde der Ordner gelöscht oder verschoben? Wähle ihn dann neu.'**
  String get autoBackupFailed;

  /// No description provided for @autoBackupRunNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichern'**
  String get autoBackupRunNow;

  /// No description provided for @autoBackupChangeFolder.
  ///
  /// In de, this message translates to:
  /// **'Ordner ändern'**
  String get autoBackupChangeFolder;

  /// No description provided for @autoBackupChangePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort ändern'**
  String get autoBackupChangePassword;

  /// No description provided for @autoBackupDisable.
  ///
  /// In de, this message translates to:
  /// **'Ausschalten'**
  String get autoBackupDisable;

  /// No description provided for @autoBackupDisabled.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup ausgeschaltet. Die vorhandenen Dateien bleiben im Ordner.'**
  String get autoBackupDisabled;

  /// No description provided for @autoBackupDone.
  ///
  /// In de, this message translates to:
  /// **'Backup im Ordner gespeichert'**
  String get autoBackupDone;

  /// No description provided for @backupReminderTitle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderLabel.
  ///
  /// In de, this message translates to:
  /// **'Erinnern nach'**
  String get backupReminderLabel;

  /// No description provided for @backupReminderHint.
  ///
  /// In de, this message translates to:
  /// **'Hinweis im Dashboard, wenn das letzte Backup älter ist. Bei funktionierendem automatischem Backup nicht nötig.'**
  String get backupReminderHint;

  /// No description provided for @backupReminderOff.
  ///
  /// In de, this message translates to:
  /// **'Nie'**
  String get backupReminderOff;

  /// No description provided for @bannerBackupNeverTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Backup'**
  String get bannerBackupNeverTitle;

  /// No description provided for @bannerBackupNeverBody.
  ///
  /// In de, this message translates to:
  /// **'Ohne Backup sind deine Daten weg, wenn das Handy verloren geht oder kaputt wird.'**
  String get bannerBackupNeverBody;

  /// No description provided for @bannerBackupOutdatedTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein letztes Backup ist {days} Tage alt'**
  String bannerBackupOutdatedTitle(int days);

  /// No description provided for @bannerBackupOutdatedBody.
  ///
  /// In de, this message translates to:
  /// **'Sichere deine Daten wieder einmal.'**
  String get bannerBackupOutdatedBody;

  /// No description provided for @bannerBackupFailedTitle.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup fehlgeschlagen'**
  String get bannerBackupFailedTitle;

  /// No description provided for @bannerBackupFailedBody.
  ///
  /// In de, this message translates to:
  /// **'Prüfe den Ordner in den Backup-Einstellungen.'**
  String get bannerBackupFailedBody;

  /// No description provided for @bannerBackupNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt sichern'**
  String get bannerBackupNow;

  /// No description provided for @bannerBackupCheck.
  ///
  /// In de, this message translates to:
  /// **'Prüfen'**
  String get bannerBackupCheck;

  /// No description provided for @sectionReminder.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get sectionReminder;

  /// No description provided for @reminderToggle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung zum Erfassen'**
  String get reminderToggle;

  /// No description provided for @reminderHint.
  ///
  /// In de, this message translates to:
  /// **'Eine Benachrichtigung an festen Tagen im Monat, ganz ohne Internet.'**
  String get reminderHint;

  /// No description provided for @reminderSummary.
  ///
  /// In de, this message translates to:
  /// **'Am {days} um {time}'**
  String reminderSummary(String days, String time);

  /// No description provided for @reminderDays.
  ///
  /// In de, this message translates to:
  /// **'Tage im Monat'**
  String get reminderDays;

  /// No description provided for @reminderDaysHint.
  ///
  /// In de, this message translates to:
  /// **'Bis zum 28. wählbar, damit die Erinnerung jeden Monat kommt.'**
  String get reminderDaysHint;

  /// No description provided for @reminderTime.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit'**
  String get reminderTime;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen sind für die App nicht erlaubt. Du kannst sie in den Android-Einstellungen unter Apps › Finanzübersicht erlauben.'**
  String get reminderPermissionDenied;

  /// No description provided for @reminderChannel.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get reminderChannel;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeit für deine Kontostände'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderNotificationBody.
  ///
  /// In de, this message translates to:
  /// **'Trag die aktuellen Stände ein, das dauert nur eine Minute.'**
  String get reminderNotificationBody;

  /// No description provided for @periodPrevious.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get periodPrevious;

  /// No description provided for @periodNext.
  ///
  /// In de, this message translates to:
  /// **'Vor'**
  String get periodNext;

  /// No description provided for @sectionAnalysis.
  ///
  /// In de, this message translates to:
  /// **'Auswertung'**
  String get sectionAnalysis;

  /// No description provided for @reviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Rückblick'**
  String get reviewTitle;

  /// No description provided for @moreReviewSub.
  ///
  /// In de, this message translates to:
  /// **'Monate und Jahre: Zuwachs, Sparquote, Ausgaben'**
  String get moreReviewSub;

  /// No description provided for @scopeMonth.
  ///
  /// In de, this message translates to:
  /// **'Monat'**
  String get scopeMonth;

  /// No description provided for @scopeYear.
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get scopeYear;

  /// No description provided for @scopeAll.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get scopeAll;

  /// No description provided for @reviewEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts zum Zurückblicken'**
  String get reviewEmptyTitle;

  /// No description provided for @reviewEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Sobald du Kontostände oder Buchungen erfasst hast, siehst du hier, wie sich dein Vermögen entwickelt.'**
  String get reviewEmptyBody;

  /// No description provided for @reviewNoEntry.
  ///
  /// In de, this message translates to:
  /// **'Keine Erfassung in diesem Zeitraum'**
  String get reviewNoEntry;

  /// No description provided for @reviewLastKnown.
  ///
  /// In de, this message translates to:
  /// **'Letzter Stand vom {date}: {amount}'**
  String reviewLastKnown(String date, String amount);

  /// No description provided for @reviewChange.
  ///
  /// In de, this message translates to:
  /// **'im Zeitraum'**
  String get reviewChange;

  /// No description provided for @reviewSaved.
  ///
  /// In de, this message translates to:
  /// **'davon gespart'**
  String get reviewSaved;

  /// No description provided for @reviewReturn.
  ///
  /// In de, this message translates to:
  /// **'davon Rendite (geschätzt)'**
  String get reviewReturn;

  /// No description provided for @reviewVariable.
  ///
  /// In de, this message translates to:
  /// **'Variable Ausgaben (geschätzt)'**
  String get reviewVariable;

  /// No description provided for @reviewSpan.
  ///
  /// In de, this message translates to:
  /// **'Gemessen zwischen deinen Erfassungen vom {from} und {to} ({days}).'**
  String reviewSpan(String from, String to, String days);

  /// No description provided for @reviewSingleEntry.
  ///
  /// In de, this message translates to:
  /// **'Nur eine Erfassung bis hierher. Für einen Vergleich braucht es mindestens zwei.'**
  String get reviewSingleEntry;

  /// No description provided for @reviewSavingsRate.
  ///
  /// In de, this message translates to:
  /// **'Sparquote'**
  String get reviewSavingsRate;

  /// No description provided for @reviewRateActual.
  ///
  /// In de, this message translates to:
  /// **'Tatsächlich'**
  String get reviewRateActual;

  /// No description provided for @reviewRatePlanned.
  ///
  /// In de, this message translates to:
  /// **'Geplant'**
  String get reviewRatePlanned;

  /// No description provided for @reviewRateHint.
  ///
  /// In de, this message translates to:
  /// **'Tatsächlich: gespart ÷ fixe Einnahmen im Zeitraum. Geplant: Sparen laut Daueraufträgen ÷ fixe Einnahmen.'**
  String get reviewRateHint;

  /// No description provided for @reviewRateNoIncome.
  ///
  /// In de, this message translates to:
  /// **'Ohne fixe Einnahmen in den Daueraufträgen lässt sich keine Sparquote berechnen.'**
  String get reviewRateNoIncome;

  /// No description provided for @reviewPerMonth.
  ///
  /// In de, this message translates to:
  /// **'Zuwachs pro Monat'**
  String get reviewPerMonth;

  /// No description provided for @reviewPerYear.
  ///
  /// In de, this message translates to:
  /// **'Zuwachs pro Jahr'**
  String get reviewPerYear;

  /// No description provided for @reviewColSaved.
  ///
  /// In de, this message translates to:
  /// **'gespart'**
  String get reviewColSaved;

  /// No description provided for @reviewColReturn.
  ///
  /// In de, this message translates to:
  /// **'Rendite'**
  String get reviewColReturn;

  /// No description provided for @reviewSpending.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben nach Kategorien'**
  String get reviewSpending;

  /// No description provided for @reviewAveragePerMonth.
  ///
  /// In de, this message translates to:
  /// **'Ø {amount} pro Monat'**
  String reviewAveragePerMonth(String amount);

  /// No description provided for @reviewNoSpending.
  ///
  /// In de, this message translates to:
  /// **'Keine Ausgaben in diesem Zeitraum.'**
  String get reviewNoSpending;

  /// No description provided for @reviewSingleIncome.
  ///
  /// In de, this message translates to:
  /// **'Einzelne Einnahmen'**
  String get reviewSingleIncome;

  /// No description provided for @reportTitle.
  ///
  /// In de, this message translates to:
  /// **'PDF-Bericht'**
  String get reportTitle;

  /// No description provided for @moreReportSub.
  ///
  /// In de, this message translates to:
  /// **'Jahr oder gesamte Laufzeit zum Aufheben'**
  String get moreReportSub;

  /// No description provided for @projectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Prognose'**
  String get projectionTitle;

  /// No description provided for @moreProjectionSub.
  ///
  /// In de, this message translates to:
  /// **'Vermögen in den nächsten Jahren, Zieldatum'**
  String get moreProjectionSub;

  /// No description provided for @yearsShort.
  ///
  /// In de, this message translates to:
  /// **'{years} J.'**
  String yearsShort(int years);

  /// No description provided for @projectionIn.
  ///
  /// In de, this message translates to:
  /// **'Vermögen in {years} Jahren'**
  String projectionIn(int years);

  /// No description provided for @projectionHistory.
  ///
  /// In de, this message translates to:
  /// **'Bisher'**
  String get projectionHistory;

  /// No description provided for @projectionToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get projectionToday;

  /// No description provided for @projectionContributed.
  ///
  /// In de, this message translates to:
  /// **'+ gespart'**
  String get projectionContributed;

  /// No description provided for @projectionReturns.
  ///
  /// In de, this message translates to:
  /// **'+ Rendite mit Zinseszins'**
  String get projectionReturns;

  /// No description provided for @projectionMilestones.
  ///
  /// In de, this message translates to:
  /// **'Zwischenstände'**
  String get projectionMilestones;

  /// No description provided for @projectionAfterYears.
  ///
  /// In de, this message translates to:
  /// **'{years, plural, =1{In 1 Jahr} other{In {years} Jahren}} ({year})'**
  String projectionAfterYears(int years, int year);

  /// No description provided for @projectionAssumptions.
  ///
  /// In de, this message translates to:
  /// **'Annahmen'**
  String get projectionAssumptions;

  /// No description provided for @projectionSaving.
  ///
  /// In de, this message translates to:
  /// **'Sparrate pro Monat'**
  String get projectionSaving;

  /// No description provided for @projectionFromPlan.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen für den Wert aus den Daueraufträgen ({amount})'**
  String projectionFromPlan(String amount);

  /// No description provided for @projectionInvested.
  ///
  /// In de, this message translates to:
  /// **'davon investiert'**
  String get projectionInvested;

  /// No description provided for @projectionInvestedHint.
  ///
  /// In de, this message translates to:
  /// **'Nur dieser Teil und dein heutiges Depot bringen Rendite.'**
  String get projectionInvestedHint;

  /// No description provided for @projectionReturn.
  ///
  /// In de, this message translates to:
  /// **'Rendite pro Jahr'**
  String get projectionReturn;

  /// No description provided for @projectionReturnHint.
  ///
  /// In de, this message translates to:
  /// **'Für breit gestreute ETFs werden oft 5–7 % angenommen, sicherer ist ein vorsichtiger Wert.'**
  String get projectionReturnHint;

  /// No description provided for @projectionBasisOwn.
  ///
  /// In de, this message translates to:
  /// **'Gerechnet mit deiner eigenen Sparrate.'**
  String get projectionBasisOwn;

  /// No description provided for @projectionBasisPlan.
  ///
  /// In de, this message translates to:
  /// **'Gerechnet mit „Sparen“ aus deinen Daueraufträgen.'**
  String get projectionBasisPlan;

  /// No description provided for @projectionBasisTrend.
  ///
  /// In de, this message translates to:
  /// **'In den Daueraufträgen ist kein Sparen eingetragen. Die Prognose nimmt deshalb deinen bisherigen Verlauf: Ø {amount} pro Monat im letzten Jahr, Kursentwicklung schon enthalten.'**
  String projectionBasisTrend(String amount);

  /// No description provided for @projectionBasisNone.
  ///
  /// In de, this message translates to:
  /// **'Ohne Sparrate wächst nur dein heute investiertes Geld mit der Rendite. Trag oben eine Sparrate ein oder lege Daueraufträge vom Typ Sparen an.'**
  String get projectionBasisNone;

  /// No description provided for @projectionUsePlan.
  ///
  /// In de, this message translates to:
  /// **'Werte aus den Daueraufträgen nehmen'**
  String get projectionUsePlan;

  /// No description provided for @projectionDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Eine Prognose ist keine Garantie: Renditen schwanken, Inflation und Steuern sind nicht berücksichtigt.'**
  String get projectionDisclaimer;

  /// No description provided for @forecastExpected.
  ///
  /// In de, this message translates to:
  /// **'voraussichtlich {date}'**
  String forecastExpected(String date);

  /// No description provided for @forecastUnreachable.
  ///
  /// In de, this message translates to:
  /// **'mit dieser Sparrate nicht absehbar'**
  String get forecastUnreachable;

  /// No description provided for @reportTitleYear.
  ///
  /// In de, this message translates to:
  /// **'Jahresbericht {year}'**
  String reportTitleYear(int year);

  /// No description provided for @reportTitleAll.
  ///
  /// In de, this message translates to:
  /// **'Bericht über die gesamte Laufzeit'**
  String get reportTitleAll;

  /// No description provided for @reportPeriod.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum: {period}'**
  String reportPeriod(String period);

  /// No description provided for @reportFooter.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am {date} mit der App Finanzübersicht · vertraulich'**
  String reportFooter(String date);

  /// No description provided for @reportPage.
  ///
  /// In de, this message translates to:
  /// **'Seite {page} von {pages}'**
  String reportPage(int page, int pages);

  /// No description provided for @reportNoFlow.
  ///
  /// In de, this message translates to:
  /// **'Für diesen Zeitraum gibt es weniger als zwei Erfassungen, daher keine Entwicklung.'**
  String get reportNoFlow;

  /// No description provided for @reportChartTitle.
  ///
  /// In de, this message translates to:
  /// **'Vermögensverlauf'**
  String get reportChartTitle;

  /// No description provided for @reportNetWorthAt.
  ///
  /// In de, this message translates to:
  /// **'Vermögen am {date}'**
  String reportNetWorthAt(String date);

  /// No description provided for @reportStartValue.
  ///
  /// In de, this message translates to:
  /// **'Start {date}: {amount}'**
  String reportStartValue(String date, String amount);

  /// No description provided for @reportGrowth.
  ///
  /// In de, this message translates to:
  /// **'Zuwachs'**
  String get reportGrowth;

  /// No description provided for @reportPlannedRate.
  ///
  /// In de, this message translates to:
  /// **'geplant {rate}'**
  String reportPlannedRate(String rate);

  /// No description provided for @reportYearsTable.
  ///
  /// In de, this message translates to:
  /// **'Jahre im Überblick'**
  String get reportYearsTable;

  /// No description provided for @reportMonthsTable.
  ///
  /// In de, this message translates to:
  /// **'Monate im Überblick'**
  String get reportMonthsTable;

  /// No description provided for @reportColEnd.
  ///
  /// In de, this message translates to:
  /// **'Vermögen'**
  String get reportColEnd;

  /// No description provided for @reportColVariable.
  ///
  /// In de, this message translates to:
  /// **'var. Ausgaben'**
  String get reportColVariable;

  /// No description provided for @reportColRate.
  ///
  /// In de, this message translates to:
  /// **'Sparquote'**
  String get reportColRate;

  /// No description provided for @reportColAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get reportColAccount;

  /// No description provided for @reportColType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get reportColType;

  /// No description provided for @reportColStart.
  ///
  /// In de, this message translates to:
  /// **'Anfang'**
  String get reportColStart;

  /// No description provided for @reportColChange.
  ///
  /// In de, this message translates to:
  /// **'Veränderung'**
  String get reportColChange;

  /// No description provided for @reportColShare.
  ///
  /// In de, this message translates to:
  /// **'Anteil'**
  String get reportColShare;

  /// No description provided for @reportColCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get reportColCategory;

  /// No description provided for @reportPlanTitle.
  ///
  /// In de, this message translates to:
  /// **'Daueraufträge und Abos'**
  String get reportPlanTitle;

  /// No description provided for @reportPlanAsOf.
  ///
  /// In de, this message translates to:
  /// **'Stand {date}'**
  String reportPlanAsOf(String date);

  /// No description provided for @reportFixedIncome.
  ///
  /// In de, this message translates to:
  /// **'Fixe Einnahmen'**
  String get reportFixedIncome;

  /// No description provided for @reportFixedExpenses.
  ///
  /// In de, this message translates to:
  /// **'Fixe Ausgaben'**
  String get reportFixedExpenses;

  /// No description provided for @reportSavings.
  ///
  /// In de, this message translates to:
  /// **'Sparen gesamt'**
  String get reportSavings;

  /// No description provided for @reportSavingsInvested.
  ///
  /// In de, this message translates to:
  /// **'davon in Anlagen'**
  String get reportSavingsInvested;

  /// No description provided for @reportFree.
  ///
  /// In de, this message translates to:
  /// **'Frei verfügbar'**
  String get reportFree;

  /// No description provided for @reportPlannedSavingsRate.
  ///
  /// In de, this message translates to:
  /// **'Geplante Sparquote'**
  String get reportPlannedSavingsRate;

  /// No description provided for @reportOutlookTitle.
  ///
  /// In de, this message translates to:
  /// **'Sparziel und Prognose'**
  String get reportOutlookTitle;

  /// No description provided for @reportProjectionLine.
  ///
  /// In de, this message translates to:
  /// **'{years, plural, =1{In 1 Jahr} other{In {years} Jahren}} ({month}): voraussichtlich {amount}'**
  String reportProjectionLine(int years, String month, String amount);

  /// No description provided for @reportAssumptions.
  ///
  /// In de, this message translates to:
  /// **'Annahmen der Prognose: Sparrate {saving} pro Monat, davon investiert {invested}, Rendite {rate} pro Jahr. Inflation und Steuern sind nicht berücksichtigt.'**
  String reportAssumptions(String saving, String invested, String rate);

  /// No description provided for @reportNotes.
  ///
  /// In de, this message translates to:
  /// **'Hinweise: Vermögen und Zuwachs beruhen auf deinen Erfassungen. Ein Zeitraum reicht von der letzten Erfassung davor bis zur letzten darin. „Gespart“, „Rendite“ und „variable Ausgaben“ sind Schätzungen aus Kontoständen und aktuellen Daueraufträgen. Die tatsächliche Sparquote ist gespart ÷ fixe Einnahmen.'**
  String get reportNotes;

  /// No description provided for @reportIntro.
  ///
  /// In de, this message translates to:
  /// **'Ein PDF mit Kennzahlen, Vermögensverlauf, Zuwachs pro Monat bzw. Jahr, Monatstabelle, Konten, Ausgaben nach Kategorien, Daueraufträgen und Prognose.'**
  String get reportIntro;

  /// No description provided for @reportChoose.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum'**
  String get reportChoose;

  /// No description provided for @reportAllTime.
  ///
  /// In de, this message translates to:
  /// **'Gesamte Laufzeit'**
  String get reportAllTime;

  /// No description provided for @reportUnencrypted.
  ///
  /// In de, this message translates to:
  /// **'Der Bericht ist nicht verschlüsselt und zeigt alle Beträge, auch im diskreten Modus. Speichere ihn nur dort, wo sonst niemand Zugriff hat.'**
  String get reportUnencrypted;

  /// No description provided for @reportCreateYear.
  ///
  /// In de, this message translates to:
  /// **'Bericht {year} speichern'**
  String reportCreateYear(int year);

  /// No description provided for @reportCreateAll.
  ///
  /// In de, this message translates to:
  /// **'Gesamtbericht speichern'**
  String get reportCreateAll;

  /// No description provided for @reportSaved.
  ///
  /// In de, this message translates to:
  /// **'Bericht gespeichert'**
  String get reportSaved;

  /// No description provided for @reportEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch zu wenig für einen Bericht'**
  String get reportEmptyTitle;

  /// No description provided for @reportEmptyBody.
  ///
  /// In de, this message translates to:
  /// **'Ein Bericht braucht mindestens zwei Kontostand-Erfassungen.'**
  String get reportEmptyBody;

  /// No description provided for @reportNoPlan.
  ///
  /// In de, this message translates to:
  /// **'ohne Plan'**
  String get reportNoPlan;

  /// No description provided for @reportKpiSaved.
  ///
  /// In de, this message translates to:
  /// **'Gespart'**
  String get reportKpiSaved;

  /// No description provided for @reportKpiSavedHint.
  ///
  /// In de, this message translates to:
  /// **'Zuwachs ohne Rendite'**
  String get reportKpiSavedHint;

  /// No description provided for @reportKpiReturn.
  ///
  /// In de, this message translates to:
  /// **'Rendite'**
  String get reportKpiReturn;

  /// No description provided for @reportKpiVariable.
  ///
  /// In de, this message translates to:
  /// **'Variable Ausgaben'**
  String get reportKpiVariable;

  /// No description provided for @reportEstimated.
  ///
  /// In de, this message translates to:
  /// **'geschätzt'**
  String get reportEstimated;

  /// No description provided for @guideAnalysisTitle.
  ///
  /// In de, this message translates to:
  /// **'Auswertung'**
  String get guideAnalysisTitle;

  /// No description provided for @guideAnalysis1.
  ///
  /// In de, this message translates to:
  /// **'Rückblick (Mehr › Rückblick): Zuwachs, tatsächliche Sparquote und Ausgaben pro Monat, pro Jahr oder gesamt. Gemessen wird von der letzten Erfassung vor dem Zeitraum bis zur letzten darin.'**
  String get guideAnalysis1;

  /// No description provided for @guideAnalysis2.
  ///
  /// In de, this message translates to:
  /// **'Prognose: dein Vermögen in 5 bis 30 Jahren mit deiner Sparrate und einer angenommenen Rendite. Das voraussichtliche Datum deines Sparziels steht auch auf der Sparziel-Karte.'**
  String get guideAnalysis2;

  /// No description provided for @guideAnalysis3.
  ///
  /// In de, this message translates to:
  /// **'PDF-Bericht für ein Jahr oder die gesamte Laufzeit, zum Aufheben oder Ausdrucken. Der Bericht ist nicht verschlüsselt.'**
  String get guideAnalysis3;

  /// No description provided for @guideSafetyTitle.
  ///
  /// In de, this message translates to:
  /// **'Sicherung und Erinnerung'**
  String get guideSafetyTitle;

  /// No description provided for @guideSafety1.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Backup (Mehr › Backup): einmal Ordner und Passwort wählen, danach sichert die App nach jeder Änderung selbst.'**
  String get guideSafety1;

  /// No description provided for @guideSafety2.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung zum Erfassen (Einstellungen): Tage im Monat und Uhrzeit wählen. Ein Tipp auf die Benachrichtigung öffnet nach dem Entsperren die Erfassung.'**
  String get guideSafety2;

  /// No description provided for @guideSafety3.
  ///
  /// In de, this message translates to:
  /// **'Diskreter Modus: Das Auge im Dashboard blendet alle Beträge aus, zum Beispiel unterwegs.'**
  String get guideSafety3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

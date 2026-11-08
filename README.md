# Finanzübersicht

Deutsch | [English](#english)

Private Vermögensübersicht für **Android und iOS**, eine Flutter-Codebasis, **100 % offline**: kein Backend, kein Konto, keine Cloud, keine Telemetrie. Alle Daten liegen verschlüsselt auf dem Gerät.

Die Anforderungen stehen in [docs/ANFORDERUNGEN.md](docs/ANFORDERUNGEN.md).

## Funktionen

- **Beliebig viele Konten** mit frei definierbaren Kontotypen (liquide, investiert oder Schulden)
- **Kontostände erfassen** wie in einer Excel-Tabelle: leeres Feld = letzter Stand wird übernommen
- **Einzelbuchungen** (Ausgaben und Einnahmen) mit Kategorie. Sie ändern keinen Kontostand.
- **Daueraufträge & Abos** (wöchentlich bis jährlich, Start/Ende, aktiv/inaktiv), nur für die Planung
- **Dashboard** mit frei sortierbaren, ein-/ausblendbaren Karten: Gesamtvermögen, Ausgaben-Donut, Sparziel, Kategorien, Vermögensentwicklung, Konten, Daueraufträge
- **Vermögensverlauf** als Graph für Gesamtvermögen, Liquide, Investiert, Schulden und jedes Konto, auch mehrere Kurven gleichzeitig. Zeiträume von Alle bis 1 Tag, mit Veränderung in € und %.
- **Sparziel**: monatliche Sparquote, Ziel pro Konto oder Vermögensziel
- **Investitionen**: jährlicher ETF-Kaufplan mit Limit, ganzen Stück und Spesen. Kurse von Hand oder optional online (standardmäßig aus).
- **Kaufrechner** mit Kredit, laufenden Kosten, Restwert, entgangener Rendite und Fazit
- **Rückblick** pro Monat, Jahr oder gesamt: Zuwachs, Sparquote (Ist gegen Plan), Rendite, Ausgaben nach Kategorien
- **Prognose** für 5 bis 30 Jahre mit Sparrate und Rendite, inklusive voraussichtlichem Datum des Sparziels
- **PDF-Bericht** für ein Jahr oder die gesamte Laufzeit
- **Erinnerung zum Erfassen** als lokale Benachrichtigung (ohne Beträge)
- **Diskreter Modus**: alle Beträge als „•••• €“, auch in Diagrammen
- **Sicherheit**: PIN oder Passwort, optional Fingerabdruck / Face ID, einstellbare Sperre, verdeckte Vorschau im App-Switcher, steigende Wartezeit nach Fehlversuchen
- **Verschlüsseltes Backup** als Datei sowie automatisches Backup in einen selbst gewählten Ordner, mit Backup-Erinnerung
- Hell / Dunkel / System (Dunkel wahlweise OLED-Schwarz), Deutsch und Englisch, Euro

## Sicherheit im Detail

- Die Daten liegen als ein AES-256-GCM-verschlüsseltes Dokument im privaten App-Ordner.
- Der Datenschlüssel ist mit einem Schlüssel verschlüsselt, der aus zwei Teilen entsteht: PBKDF2-HMAC-SHA256 der PIN bzw. des Passworts (120.000 Runden) und ein zufälliges Geräte-Geheimnis im Keychain bzw. Keystore. Eine kopierte Datei lässt sich ohne das Gerät nicht per Durchprobieren der PIN öffnen.
- Für Biometrie wird der Datenschlüssel im Keychain/Keystore abgelegt und erst nach erfolgreicher Prüfung gelesen.
- Auf dem Speicher liegen die Daten immer nur verschlüsselt. Nach Beenden der App ist wieder PIN bzw. Fingerabdruck nötig.
- Android: `allowBackup=false`, keine Cloud- oder Geräteübertragung, keine Vorschau in der App-Übersicht (ab Android 13).
- Das Backup ist mit einem eigenen Passwort verschlüsselt (PBKDF2 mit 200.000 Runden, AES-256-GCM) und nicht an das Gerät gebunden.
- Automatisches Backup: Zugriff nur auf den gewählten Ordner über das Storage Access Framework, ohne Speicher-Berechtigung.
- **PIN/Passwort vergessen:** Es gibt bewusst keine Hintertür. App zurücksetzen (alle Daten werden gelöscht), neu einrichten, Backup einspielen.
- Der PDF-Bericht ist bewusst unverschlüsselt und zeigt auch im diskreten Modus alle Beträge. Die App weist vor dem Speichern darauf hin.

## Technik

Flutter, Riverpod (State), `fl_chart` (Diagramme), `cryptography` (Verschlüsselung), `flutter_secure_storage`, `local_auth`, `pdf`, `flutter_local_notifications`.

## Projektstruktur

```
lib/
  core/      Datum, Formatierung, IDs
  data/      Modelle, Tresor (Verschlüsselung), Backup, Ordnerzugriff, Erinnerungen, Kursabruf
  domain/    Berechnungen (Übersicht, Daueraufträge, Investitionen, Kaufrechner, Sparziel,
             Rückblick, Prognose, Backup-Erinnerung)
  report/    PDF-Bericht
  state/     Riverpod: Sitzung/Sperre, abgeleitete Werte, Datenänderungen, automatisches Backup
  ui/        Screens, Theme, Widgets
  l10n/      Texte Deutsch/Englisch (ARB)
test/        Berechnungen, Tresor, Backup, Sperre, PDF, UI
```

## Entwickeln

```bash
flutter pub get
flutter test
flutter run
```

### Android-Release

```bash
flutter build appbundle --release   # für den Play Store
flutter build apk --release         # zum direkten Installieren
```

Für signierte Releases wird ein eigener Keystore mit `android/key.properties` benötigt (beides nicht im Repository). Fehlt die Datei, signiert Gradle mit dem Debug-Schlüssel. Für Updates über eine vorhandene Installation müssen App-ID und Keystore gleich bleiben und die Zahl hinter dem `+` in `version` (`pubspec.yaml`) steigen. Dieselbe Version steht zusätzlich in `lib/core/app_info.dart`, ein Test prüft die Übereinstimmung.

### iOS

Vorbereitet (Face-ID-Text, App-Name, Icons), wird aber derzeit weder gebaut noch getestet.

## Lizenz

Noch nicht festgelegt.

---

## English

# Finanzübersicht (Finance Overview)

A private net-worth overview for **Android and iOS**, one Flutter codebase, **100 % offline**: no backend, no account, no cloud, no telemetry. All data is stored encrypted on the device.

The requirements are in [docs/ANFORDERUNGEN.md](docs/ANFORDERUNGEN.md) (German).

### Features

- **Any number of accounts** with freely definable account types (liquid, invested or debt)
- **Record balances** like in a spreadsheet: an empty field keeps the last value
- **Individual transactions** (expenses and income) with category. They do not change account balances.
- **Recurring payments & subscriptions** (weekly to yearly, start/end, active/inactive), for planning only
- **Dashboard** with freely sortable, show/hide-able cards: total net worth, expense donut, savings goal, categories, net-worth development, accounts, recurring payments
- **Net-worth history** as a chart for total, liquid, invested, debt and every single account, several curves at once. Ranges from All down to 1 day, with change in € and %.
- **Savings goal**: monthly savings rate, target per account, or net-worth target
- **Investments**: yearly ETF purchase plan with limit, whole units and fees. Prices manual or optionally online (off by default).
- **Purchase calculator** with loan, running costs, residual value, forgone returns and a verdict
- **Review** per month, year or overall: growth, savings rate (actual vs. plan), returns, expenses by category
- **Projection** for 5 to 30 years with savings rate and return, including the expected date of the savings goal
- **PDF report** for one year or the whole period
- **Entry reminder** as a local notification (contains no amounts)
- **Discreet mode**: all amounts shown as "•••• €", also in charts
- **Security**: PIN or password, optional fingerprint / Face ID, adjustable lock, hidden preview in the app switcher, increasing delay after failed attempts
- **Encrypted backup** as a file, plus automatic backup to a folder of your choice, with a backup reminder
- Light / dark / system (dark optionally pure OLED black), German and English, euro

### Security in detail

- Data is stored as a single AES-256-GCM encrypted document in the private app folder.
- The data key is encrypted with a key made of two parts: PBKDF2-HMAC-SHA256 of the PIN or password (120,000 rounds) and a random device secret in the Keychain/Keystore. A copied file cannot be opened by brute-forcing the PIN without the device.
- For biometrics, the data key is kept in the Keychain/Keystore and only read after a successful check.
- Data on storage is always encrypted. After the app is closed, PIN or fingerprint is required again.
- Android: `allowBackup=false`, no cloud or device transfer, no preview in the app overview (Android 13+).
- The backup is encrypted with its own password (PBKDF2 with 200,000 rounds, AES-256-GCM) and not bound to the device.
- Automatic backup: access only to the chosen folder via the Storage Access Framework, without a storage permission.
- **Forgot PIN/password:** there is deliberately no backdoor. Reset the app (all data is deleted), set it up again, restore a backup.
- The PDF report is deliberately unencrypted and shows all amounts even in discreet mode. The app warns before saving.

### Tech

Flutter, Riverpod (state), `fl_chart` (charts), `cryptography` (encryption), `flutter_secure_storage`, `local_auth`, `pdf`, `flutter_local_notifications`.

### Project structure

```
lib/
  core/      dates, formatting, IDs
  data/      models, vault (encryption), backup, folder access, reminders, price fetch
  domain/    calculations (overview, recurring, investments, purchase calculator, savings goal,
             review, projection, backup reminder)
  report/    PDF report
  state/     Riverpod: session/lock, derived values, data changes, automatic backup
  ui/        screens, theme, widgets
  l10n/      German/English texts (ARB)
test/        calculations, vault, backup, lock, PDF, UI
```

### Development

```bash
flutter pub get
flutter test
flutter run
```

#### Android release

```bash
flutter build appbundle --release   # for the Play Store
flutter build apk --release         # for direct install
```

Signed releases need an own keystore with `android/key.properties` (neither is in the repository). Without it, Gradle signs with the debug key. To update an existing installation, the app ID and keystore must stay the same and the number after the `+` in `version` (`pubspec.yaml`) must increase. The same version is also in `lib/core/app_info.dart`; a test checks that they match.

#### iOS

Prepared (Face ID text, app name, icons) but currently neither built nor tested.

### License

Not decided yet.

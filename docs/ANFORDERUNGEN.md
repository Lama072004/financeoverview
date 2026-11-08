# Finanzübersicht – Anforderungen

Stand: 18.10.2026. Grundlage: `Finanzuebersicht.xlsx` (nur Probedaten – **keine** Daten aus der Excel kommen in die App, sie startet leer).

## Rahmen

- **Plattformen:** nur iOS + Android, eine Flutter-Codebasis. Die Ordner `linux/`, `macos/`, `web/`, `windows/` werden entfernt.
- **Offline:** kein Backend, kein Konto, kein Cloud-Sync, keine Telemetrie. Einzige Ausnahme: optionaler ETF-Kursabruf (siehe Investitionen), standardmäßig aus.
- **Sprache:** Deutsch + Englisch (umschaltbar, Standard = Systemsprache). Währung: nur Euro.
- **App-Name:** Finanzübersicht.
- **Testen:** kein Mac/iPhone-Test. Android über Emulator (SDK ist vorhanden, Android Studio nicht nötig) bzw. Unit-, Widget- und Golden-Tests (gerenderte Screenshots) ohne Gerät.

## Sicherheit

- Beim ersten Start: eigene **PIN oder Passwort** festlegen, optional **Fingerabdruck / Face ID**.
- Datenbank verschlüsselt (SQLCipher), Schlüssel im Keychain/Keystore.
- Sperre beim Verlassen der App: **einstellbar** (sofort / 30 s / 1 min / 5 min), Standard **sofort**. Die Sperre legt sich über die App: Offene Seiten und angefangene Eingaben (z. B. Kontostände) bleiben nach dem Entsperren erhalten (Wunsch vom 20.10.2026).
- Im App-Switcher wird der Inhalt verdeckt. Nach falschen Eingaben steigt die Wartezeit.
- PIN vergessen → keine Wiederherstellung möglich, nur Zurücksetzen (alle Daten löschen) und Backup einspielen. Entscheidung vom 18.10.2026: keine weiteren Rettungswege (kein Notfall-Code, kein PIN-Reset per Fingerabdruck).

## Backup

- **Verschlüsselte Backup-Datei**, manuell exportieren/importieren (eigenes Backup-Passwort). Die Datei speicherst du selbst, wo du willst; die App überträgt nichts.
- **Automatisches Backup** (Wunsch vom 20.10.2026): einmal einen Ordner und ein Backup-Passwort wählen. Danach legt die App nach jeder Änderung ein verschlüsseltes Backup dort ab, höchstens eine Datei pro Tag (eine spätere am selben Tag ersetzt sie). Die letzten 10 automatischen Backups bleiben, ältere löscht die App. Andere Dateien im Ordner fasst sie nicht an.
- **Backup-Erinnerung:** Hinweis im Dashboard, wenn das letzte Backup älter ist als eingestellt (Aus / 14 / 30 / 60 / 90 Tage, Standard 30). Mit funktionierendem automatischem Backup kommt keine Erinnerung, mit fehlgeschlagenem sofort.

## Erinnerung zum Erfassen

- Lokale Benachrichtigung an wählbaren Tagen im Monat (1.–28.) zu einer Uhrzeit, Standard 1. und 15. um 19:00. Standardmäßig aus.
- Ohne Beträge im Text. Ein Tipp öffnet nach dem Entsperren die Kontostand-Erfassung.

## Diskreter Modus

- Augen-Symbol im Dashboard und Schalter in den Einstellungen. Alle Beträge erscheinen als „•••• €“, auch Achsen und Tooltips der Diagramme. Prozente und Datumsangaben bleiben sichtbar.

## Konten

- **Beliebig viele Konten**: Name, Kontotyp, Notiz, Reihenfolge, archivierbar (Historie bleibt).
- **Kontotypen frei definierbar.** Jeder Typ hat ein Verhalten: *Liquide* (Bank/Bargeld), *Investiert* (Depot/Fonds/Gold – schwankt mit dem Markt) oder *Schulden* (wird vom Vermögen abgezogen). Voreinstellung: Liquide, Investiert.

## Kontostände (wie Blatt „Kontostände“)

- Eine Erfassung = Datum + Stand pro Konto + Notiz. Ein Konto leer lassen = letzter Stand wird übernommen.
- Erfassungen werden automatisch nach Datum sortiert, nachträglich bearbeitbar/löschbar.
- Je Erfassung: Gesamt, Liquide, Investiert, Schulden, Δ Gesamt, Tage seit letzter Erfassung, geschätzte variable Ausgaben, geschätzte Rendite.

## Einzelbuchungen

- **Ausgaben und Einnahmen** einzeln erfassen: Betrag, Datum, Kategorie, optional Konto, Notiz.
- **Getrennt wie Excel:** Einzelbuchungen ändern den Kontostand **nicht**. Sie dienen der Auswertung nach Kategorie.

## Daueraufträge & Abos (wie Blatt „Daueraufträge“)

- Bezeichnung, Typ (Einnahme / Ausgabe / Sparen), Kategorie, Betrag (immer positiv), Rhythmus, Fällig am (Tag 1–31), Von Konto, Auf Konto, Aktiv, Start, Ende, Notiz.
- **Nur Planung:** Sie bewegen kein Geld, sondern fließen in Monats- und Jahreswerte, Sparquote und Schätzungen ein.
- Rhythmus → Faktor pro Monat: wöchentlich 52/12 · monatlich 1 · zweimonatlich 1/2 · vierteljährlich 1/3 · halbjährlich 1/6 · jährlich 1/12.
- Zählt nur, wenn aktiv und heute zwischen Start und Ende liegt.
- Sparen auf ein eigenes Konto ist **keine** Ausgabe.

## Übersicht / Berechnungen (wie Blatt „Übersicht“)

- Pro Konto: Stand, Δ seit letzter Erfassung, Δ seit Jahresanfang (letzte Erfassung bis 1.1. des aktuellen Jahres, sonst erste), Anteil.
- Summen: Gesamtvermögen, davon liquide, davon investiert (und Schulden).
- Daueraufträge pro Monat/Jahr: fixe Einnahmen, fixe Ausgaben, Sparen gesamt, davon in Anlagen, frei verfügbar, Sparquote (Sparen ÷ Einnahmen).
- Fixausgaben nach Kategorie.
- Letzter Zeitraum (geschätzt):
  - variable Ausgaben = (fixe Einnahmen − fixe Ausgaben − Sparen in Anlagen) × Tage / 30,4375 − Δ Liquide
  - Rendite = Δ Investiert − Sparen in Anlagen × Tage / 30,4375
- **Vermögensentwicklung:** Graph für Gesamtvermögen, Liquide, Investiert, Schulden und jedes Konto, auch mehrere Kurven gleichzeitig. Zeiträume: seit Anfang (Alle), 1 Jahr, 6 Monate, 3 Monate, 1 Monat, 1 Woche, 1 Tag. Die Werte zwischen zwei Erfassungen gelten als unverändert, der Graph reicht immer bis heute.

## Kategorien

- Voreinstellung wie Excel (Gehalt, Sonstige Einnahmen, Wohnen, Mobilität, Versicherung, Handy & Internet, Abos & Streaming, Sport & Freizeit, Lebensmittel, Bildung, Gesundheit, Kredit, Sparen, Sonstiges), jeweils mit Icon. Frei bearbeitbar.

## Rückblick

- Pro Monat, pro Jahr und gesamt: Vermögen, Zuwachs, davon gespart und Rendite (geschätzt), variable Ausgaben (geschätzt), tatsächliche gegenüber geplanter Sparquote, Ausgaben nach Kategorien (wie der Donut im Dashboard).
- Gemessen wird von der letzten Erfassung vor dem Zeitraum bis zur letzten darin. Aufeinanderfolgende Monate ergeben so genau das Jahr.
- Jahr und gesamt mit Balken pro Monat bzw. Jahr; ein Tipp öffnet den Monat bzw. das Jahr.

## Prognose

- Vermögen in 5, 10, 20 oder 30 Jahren. Sparrate und Anteil „investiert“ kommen aus den Daueraufträgen oder werden selbst eingetragen, Rendite einstellbar (Standard 5 % pro Jahr, nur auf den investierten Teil). Schulden bleiben unverändert.
- Ohne Sparen in den Daueraufträgen rechnet die Prognose mit dem Verlauf der letzten 12 Monate.
- Voraussichtliches Datum für das Vermögensziel und für Ziele pro Konto, auch auf der Sparziel-Karte.

## PDF-Bericht

- Für ein gewähltes Jahr oder die gesamte Laufzeit: Kennzahlen, Vermögensverlauf (Gesamt, Liquide, Investiert, Schulden), Zuwachs pro Monat bzw. Jahr, Monats- und Jahrestabellen, Konten, Ausgaben nach Kategorien, Daueraufträge, Sparziel und Prognose.
- Wird nicht verschlüsselt und zeigt immer alle Beträge. Gespeichert wird über die Dateiauswahl des Systems.

## Sparziel

In den Einstellungen wählbar:

1. **monatliche Ziel-Sparquote** (z. B. 70 %),
2. **Sparziel pro Konto** (beliebiger Betrag je Konto),
3. **Vermögensziel** (Gesamtvermögen).

Das Dashboard zeigt den Fortschrittsbalken für die gewählte Art.

## Investitionen (wie Blatt „Investitionen“)

- Jahresbudget, Limit-Aufschlag (%), Spesen pro Order.
- ETFs: Name, ISIN, Anteil → Betrag pro Jahr, Kurs, Limit (Kurs × (1 + Aufschlag), gerundet auf 3 Nachkommastellen unter 10 €, sonst 2), ganze Stück, Kosten ganze Stück, Stück bei Betragskauf, Kursquelle.
- Rest bei ganzen Stück, Spesen gesamt, Spesen in % vom Budget, Warnung wenn Anteile ≠ 100 %.
- Kurs von Hand. **Optionaler Online-Abruf** von Tradegate per Knopf (es wird nur die ISIN gesendet). Er ist in den Einstellungen standardmäßig aus.

## Kaufrechner (wie Blatt „Kaufrechner“)

- Eingaben: Bezeichnung, Kaufpreis, aus Ersparnissen bezahlt, Kreditzins, Laufzeit, laufende Kosten/Monat, Nutzungsdauer, Restwert, Rendite-Annahme, Notgroschen-Ziel, Ziel-Sparquote.
- Die aktuelle Lage kommt automatisch aus der Übersicht.
- Ergebnisse: Kreditbetrag, Rate, Zinskosten, liquides Geld danach, Anteil am Vermögen, Monate Sparen zurückgeworfen, Ansparen-Dauer, Mehrbelastung, frei verfügbar danach, Sparquote danach, Gesamtkosten, Kosten pro Monat, Restschuld, Vermögensnachteil gegenüber Investieren.
- Fazit mit derselben Ampel-Logik wie in der Excel.

## Bedienung

- **Dashboard** als Startseite, Karten frei **verschiebbar, ein-/ausblendbar und in der Größe anpassbar** (kompakt / groß). Karten:
  - Gesamtvermögen
  - Ausgaben-Donut
  - Sparziel
  - Kategorienliste
  - Vermögensverlauf
  - Konten
  - Daueraufträge-Summen
  - Letzter Zeitraum
- **Tab-Leiste unten** + runder **„+“-Button** für schnelles Erfassen (Kontostand / Ausgabe / Einnahme).
- **Ausgaben-Donut (Monat), kombiniert:** pro Kategorie Fixkosten aus Daueraufträgen + erfasste Einzelausgaben. Dazu „nicht zugeordnet“ = geschätzte variable Ausgaben − erfasste Einzelbuchungen (netto), wenn positiv.

## Design

- Farbpalette aus dem Screenshot (Werte aus dem Bild gemessen, werden für Kontrast feinjustiert):
  | Farbe | Hex | Rolle |
  |---|---|---|
  | Dark Greenish Glaucous 若苗色 | `#9EA79D` | ruhige Hauptfarbe |
  | Cream Yellow 卵色 | `#E09E2D` | Akzent |
  | Pompeian Red 紅樺色 | `#960513` | nur negative Werte |
  | Light Green Yellow 鶸色 | `#AFAC08` | positive Werte |
- Hell / Dunkel / System umschaltbar. Hell: weicher Creme-Hintergrund. Dunkel: reines Schwarz (OLED) oder umschaltbar auf helleres Schwarz.
- Abgerundete Karten mit dezenten Schatten, modernes Card-Layout.
- Schrift: **Plus Jakarta Sans** (in die App eingebaut, offline).
- Stimmung: professionell, vertrauenswürdig, aufgeräumt, selbstbewusst – moderner, sicherer Fintech-Look.

## Bewusst nicht umgesetzt

- **Bank-Anbindung** (George/Sparkasse, Raiffeisen, Trade Republic u. a.): Entscheidung vom 20.10.2026 – Kontostände werden weiter von Hand erfasst. Hintergrund: Die PSD2-Schnittstellen der Banken sind nur für lizenzierte Kontoinformationsdienste zugänglich, Aggregatoren laufen über fremde Server (widerspricht „offline“), Trade Republic hat keine offizielle Schnittstelle. Ein offline möglicher Datei-Import der Bank-Exporte (CSV/JSON) wurde ebenfalls nicht gewünscht.

## Offene Punkte

- Android-App-ID ist `at.mathiaslampert.finanzuebersicht`, die Release-Signatur ist eingerichtet (siehe README).
- iOS und Mac sind derzeit nicht vorgesehen. Vorbereitet sind Face-ID-Text, App-Name und Icons, die Bundle-ID ist noch `com.example.financeoverview`.

## Umsetzungsstand (20.10.2026, Version 1.1.0)

- Alle Punkte oben sind für Android umgesetzt.
- 135 automatische Tests: Excel-Formeln, Zeiträume des Verlaufs, Rückblick, Prognose, Backup-Erinnerung, automatisches Backup, PDF-Bericht, Tresor und Backup, Sitzung und Sperre, Erinnerung, diskreter Modus, Theme-Wechsel nach dem Zurücksetzen, 54 gerenderte Screens (hell und dunkel).
- Die Berechnungen wurden einmalig mit den Probedaten der Excel gegengeprüft und stimmen überein. Der Test wurde danach gelöscht, es sind keine Excel-Daten im Projekt.
- Auf dem Android-Emulator (Android 16) getestet, zuletzt mit der signierten Release-Version:
  - Einrichtung mit PIN, Sperren und Entsperren, automatische Sperre beim Verlassen
  - Konto anlegen und Kontostand erfassen
  - leere Vorschau in der App-Übersicht, App-Icon
  - Darkmode: System, reines Schwarz und Dunkelgrau
  - PIN vergessen → App zurücksetzen → neu einrichten
  - Backup einspielen (Dateiauswahl, Passwort, Ersetzen) und Backup exportieren; die exportierte Datei wurde auf dem PC entschlüsselt und geprüft
  - Vermögensverlauf mit Zeiträumen und zusätzlichen Kurven
- Auf einem echten Gerät getestet: Fingerabdruck-Entsperrung funktioniert auf dem Nothing Phone 4a Pro.
- Nicht getestet: iOS (derzeit nicht vorgesehen).

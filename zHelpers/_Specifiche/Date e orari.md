---
area: Date e orari
progetto: zHelpers
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Date e orari

Questa specifica descrive `TDateTimeHelper`, l'aiutante di record per `TDateTime` della unit `zHelpers\DateTimeHelper.pas`: permette di scrivere `Scadenza.AddMonths(3)`, `Data.StartOfMonth`, `Data.Year` invece delle funzioni di `System.DateUtils`. È codice di terze parti (Colin Johnsun, licenza Apache 2.0) e ogni metodo delega a una funzione della libreria di Delphi; la stessa unit è presente, identica, in `zHelpers\TDateTimeHelper-master\`. **Nessun progetto la compila**: non compare nei `uses` di WT, Gesty, zTicser o zServer né in un pacchetto `.dpk`; la usa solo il suo progetto di prova `TDateTimeHelper-master\Tests\TDateTimeHelperTests.dpr`. Gli altri due aiutanti della cartella, `zStringHelper` (`Coalesce`, `IIF`) e `zWideStringHelper` (`Length`, `PadLeft`, `PadRight` per `WideString`), sono a loro volta inutilizzati e non hanno regole proprie: restano fuori da questa specifica.

**Come funziona.** Un aiutante di record aggiunge metodi e proprietà a un tipo semplice. Dove l'unit è nel `uses`, ogni valore `TDateTime` li espone; i valori restituiti sono nuovi, il valore di partenza non cambia.

**Test che coprono quest'area.** `TDateTimeHelper.Tests` (17 prove nel progetto `TDateTimeHelperTests.dpr`, non nella raccolta `zPackTests` di `_UnitTest`): `Create` con data e ora, `Date`, `DayOfWeek`, `DayOfYear`, le parti da `Year` a `Millisecond`, inizio e fine di anno, mese, settimana e giorno, tutte confrontate con le funzioni di `System.DateUtils` sul 14/02/1995 alle 10:25:15.120. Non sono provati le somme, i confronti, le distanze e `ToString`.

## ZHLP-DAT-001 Costruzione e valori correnti
`TDateTime.Create(Anno, Mese, Giorno)` e `TDateTime.Create(Anno, Mese, Giorno, Ora, Minuto, Secondo, Millisecondo)` costruiscono il valore come `EncodeDate` ed `EncodeDateTime`: una data impossibile solleva `EConvertError`. `TDateTime.Now` è data e ora correnti; `Today`, `Yesterday` e `Tomorrow` sono date senza ora (mezzanotte).

### Scenario: data impossibile
- **Dato** nessun valore
- **Quando** si chiama `TDateTime.Create(2026, 2, 30)`
- **Allora** si ottiene `EConvertError`

### Scenario: domani
- **Dato** il giorno 01/11/2026 alle 15:00
- **Quando** si legge `TDateTime.Tomorrow`
- **Allora** il risultato è il 02/11/2026 alle 00:00

## ZHLP-DAT-002 Parti del valore
`Date` è la sola data, `Time` la sola ora; `Year`, `Month`, `Day`, `Hour`, `Minute`, `Second`, `Millisecond` le singole parti; `DayOfYear` il numero del giorno nell'anno. `DayOfWeek` segue la numerazione ISO: **1 = lunedì, 7 = domenica**, diversa da `System.SysUtils.DayOfWeek`, dove 1 è la domenica (DIV-DAT-3).

### Scenario: giorno della settimana
- **Dato** il valore 01/11/2026, una domenica
- **Quando** si legge `DayOfWeek`
- **Allora** il risultato è 7

## ZHLP-DAT-003 Inizio e fine dei periodi
`StartOfDay`, `StartOfWeek`, `StartOfMonth`, `StartOfYear` restituiscono il primo istante del periodo (ore 00:00:00.000); `EndOfDay`, `EndOfWeek`, `EndOfMonth`, `EndOfYear` l'ultimo (ore 23:59:59.999). La settimana va dal lunedì alla domenica.

### Scenario: fine del mese di febbraio
- **Dato** il valore 10/02/2028
- **Quando** si chiama `EndOfMonth`
- **Allora** il risultato è il 29/02/2028 alle 23:59:59.999

### Scenario: inizio della settimana
- **Dato** il valore 01/11/2026, domenica
- **Quando** si chiama `StartOfWeek`
- **Allora** il risultato è lunedì 26/10/2026 alle 00:00

## ZHLP-DAT-004 Somme
`AddYears`, `AddMonths`, `AddDays`, `AddHours`, `AddMinutes`, `AddSeconds`, `AddMilliseconds` aggiungono la quantità indicata (1 se non indicata; un numero negativo sottrae) e conservano l'ora. Aggiungendo mesi o anni il giorno che non esiste nel mese di arrivo diventa l'ultimo giorno di quel mese.

### Scenario: un mese dopo il 31 gennaio
- **Dato** il valore 31/01/2027
- **Quando** si chiama `AddMonths`
- **Allora** il risultato è il 28/02/2027

## ZHLP-DAT-005 Confronti
`CompareTo` restituisce -1, 0 o 1; `Equals` considera uguali due valori che differiscono per meno di un millisecondo; `IsSameDay` confronta solo la data; `InRange(Inizio, Fine, Estremi)` comprende gli estremi se non indicato altrimenti; `IsToday`, `IsAM`, `IsPM`, `IsInLeapYear` rispondono sul valore.

### Scenario: stesso giorno, ore diverse
- **Dato** i valori 01/11/2026 08:00 e 01/11/2026 22:00
- **Quando** si chiama `IsSameDay`
- **Allora** il risultato è vero, mentre `Equals` è falso

## ZHLP-DAT-006 Distanze
`YearsBetween`, `MonthsBetween`, `WeeksBetween`, `DaysBetween`, `HoursBetween`, `MinutesBetween`, `SecondsBetween`, `MilliSecondsBetween` restituiscono la distanza in unità **intere**, sempre positiva qualunque sia l'ordine dei due valori, troncando la parte incompleta. Anni e mesi si calcolano sulla durata media (365,25 e 30,4375 giorni), non sul calendario. `WithinYears` ... `WithinMilliseconds` sono veri se la distanza intera non supera il numero indicato.

### Scenario: giorni interi
- **Dato** i valori 01/11/2026 10:00 e 03/11/2026 09:00
- **Quando** si chiama `DaysBetween`
- **Allora** il risultato è 1, perché il secondo giorno non è completo

### Scenario: mesi su durata media
- **Dato** i valori 31/01/2027 e 28/02/2027
- **Quando** si chiama `MonthsBetween`
- **Allora** il risultato è 0, perché 28 giorni sono meno di 30,4375

## ZHLP-DAT-007 Testo
`ToString` senza formato restituisce la sola data nel formato breve delle impostazioni locali (`DateToStr`), anche se il valore ha un'ora (DIV-DAT-2); con un formato usa `FormatDateTime`.

### Scenario: valore con ora senza formato
- **Dato** il valore 01/11/2026 15:30 su una macchina italiana
- **Quando** si chiama `ToString`
- **Allora** il risultato è `01/11/2026`, senza l'ora

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DAT-1 🟢 | La unit è di terze parti, presente in due copie identiche (`zHelpers\` e `zHelpers\TDateTimeHelper-master\`), non usata da nessun progetto; le sue prove stanno in un progetto a parte, fuori da `zPackTests` | Codice morto in libreria: una correzione fatta su una copia non arriva all'altra, e `run_tests` non esegue mai le prove |
| DIV-DAT-2 🟢 | `ToString` senza formato perde l'ora | Chi lo usa per un registro o un messaggio con data e ora vede solo la data |
| DIV-DAT-3 🟢 | La proprietà `DayOfWeek` ha lo stesso nome della funzione `System.SysUtils.DayOfWeek` ma una numerazione diversa (ISO, 1 = lunedì, contro 1 = domenica) | In un codice che usa entrambe le forme un controllo sul fine settimana sbaglia di un giorno senza errori di compilazione |

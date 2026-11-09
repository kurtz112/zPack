---
area: Filtri della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Filtri della vista

Questa specifica descrive come una `TzDbView` filtra i suoi record: il filtro rapido del pannello di ricerca, il «Filtro per valore» (F3), il menu degli operatori di una colonna, il controllo dei filtri in linea e il passaggio da condizioni della griglia a `WHERE` della query. Il codice è in `zBase\zDbView.Filter.pas` (`TzDbViewFilterController`, `TzFilterControl`, adattatore degli operatori di `TzFbDataSet`), `zDbView.Controller.pas` (inoltra) e `zDbView.pas` (`InternalFilterChanged`, `UpdateInplaceFilterControlVisibility`). Il «Filtro per valore» è in comune con `TzDbPivot` (`ChiediFiltroPerValore`). Lo usano tutte le viste di WT e Gesty.

**Come funziona.** Il filtro non lavora sulle righe in memoria: le condizioni dell'utente restano nel filtro della griglia (`DataController.Filter`), e ogni cambiamento si traduce nel testo del filtro, che il `DataController` della vista aggiunge alla `WHERE` della query (`ApplyFilter`) riaprendo il dataset. Gli operatori di DevExpress si traducono in operatori Firebird con l'adattatore (`IS NULL` al posto del confronto con Null, `CONTAINING` al posto di `LIKE`/contiene).

**Test che coprono quest'area.** `Test.zDbView.Filter` (6 prove su `ParseStringFilterValue`: testo semplice, asterisco finale, solo asterisco, asterisco in mezzo, stringa vuota, doppio asterisco). `Test.zDbView.Divergenze` (`TTestFiltroCasiLimite`, 3 prove): asterisco iniziale, operatore in ingresso sempre sovrascritto, filtro per valore senza campo. Il resto richiede griglia e finestre e non è coperto.

## ZDBVIEW-FLT-001 Dalle condizioni alla query
`ApplyFilter` non fa niente se il dataset non è utilizzabile o se un'inizializzazione è in corso (`DisableFilter`). Se il filtro della griglia è attivo passa il suo testo (`Filter.FilterText`) al `DataController`, altrimenti passa la stringa vuota: così togliere il filtro riporta la query intera. `InitFilters` (all'avvio) imposta le opzioni del filtro (senza distinzione di maiuscole, descrizione degli operatori) e lo attiva, senza provocare l'applicazione. `Clear` cancella tutte le condizioni; `DeleteConditionsForField(campo)` solo quelle della colonna; `AddFilterCondition(campo, operatore, valore, ..., Overwrite)` toglie prima le condizioni della colonna (se `Overwrite`, predefinito vero), aggiunge la nuova e attiva il filtro; con un campo senza colonna non fa niente. Un cambiamento del filtro arriva alla vista con un messaggio interno (`cmd_FilterChanged`) e si applica solo se la griglia è in `GridMode`.

### Scenario: filtro tolto
- **Dato** una vista con un filtro attivo sul cognome
- **Quando** l'utente lo cancella
- **Allora** la query si riapre senza condizione sul cognome

### Scenario: stessa colonna due volte
- **Dato** una condizione sul cognome
- **Quando** il codice chiama `AddFilterCondition` sul cognome con `Overwrite` vero
- **Allora** resta solo la condizione nuova

## ZDBVIEW-FLT-002 Sintassi del testo digitato
`ParseStringFilterValue(testo, operatore)` imposta sempre l'operatore a «inizia per» (`foBeginsWith`), qualunque valore avesse in ingresso; se il testo finisce con `*` l'operatore diventa «contiene» (`foContains`) e **un solo** asterisco finale si toglie (`rossi**` → `rossi*`). Un asterisco all'inizio o in mezzo non ha significato e resta nel testo. Il solo `*` dà «contiene» con testo vuoto. Vale per il filtro rapido, per il «Filtro per valore» e per il pivot.

### Scenario: ricerca per contenuto
- **Dato** il testo `rossi*`
- **Quando** lo si interpreta
- **Allora** l'operatore è «contiene» e il testo è `rossi`

### Scenario: asterisco iniziale
- **Dato** il testo `*rossi`
- **Quando** lo si interpreta
- **Allora** l'operatore è «inizia per» e il testo resta `*rossi`

## ZDBVIEW-FLT-003 Filtro rapido (pannello di ricerca)
`FilterByFindText` agisce sulla **colonna a fuoco** (senza colonna o senza campo non fa niente). Toglie sempre le condizioni di quella colonna; se il testo del pannello non è vuoto ne aggiunge una nuova, secondo il tipo del campo: testo, booleano, GUID e memo con «inizia per» o «contiene» (ZDBVIEW-FLT-002); interi (anche `AutoInc`, `Smallint`, `Word`) e `Largeint` con uguale, dopo aver tolto i punti dal testo; decimali (`Float`, `Currency`, `BCD`, `FmtBCD`) con uguale, letti con le impostazioni locali; date, ore e data-ora con uguale, letti con `StrToDateTime`. Altri tipi (blob, sconosciuti) e testo vuoto: la condizione si toglie e non se ne aggiunge nessuna.

### Scenario: testo vuoto
- **Dato** una colonna con un filtro rapido attivo
- **Quando** l'utente svuota il pannello di ricerca
- **Allora** la condizione della colonna sparisce

### Scenario: numero con separatore
- **Dato** una colonna intera e il testo `1.250`
- **Quando** si applica il filtro rapido
- **Allora** la condizione è «uguale a 1250»

## ZDBVIEW-FLT-004 Filtro per valore (F3)
`ChiediFiltroPerValore(campo, origine, etichetta, proposto, ...)` chiede il valore con una finestra adatta al campo e restituisce: **falso** se l'utente annulla (non cambia niente), **vero con valore Null** se svuota (la condizione sulla colonna si toglie), **vero con valore e operatore** altrimenti. Senza campo restituisce subito falso. Il valore proposto è quello del record corrente. Per tipo: elenchi di scelta (`ctPickList`, `ctPickListImage`) e Sì/No (`ctCheckBox`, con `TBooleanField` o `S`/`N`) scelgono da elenco e usano uguale; date e ore usano la finestra di data (oggi o adesso se non c'è un valore) e uguale; interi, grandi interi e decimali usano caselle numeriche e uguale; testo (e, con `NumeriComeTesto`, ogni tipo che non sia data od ora: il pivot lo usa perché un numero è un'etichetta) si scrive in **maiuscolo**, senza spazi ai lati, con la sintassi di ZDBVIEW-FLT-002; un testo vuoto o il solo `*` svuota. Tipi che la finestra non sa chiedere (blob, oggetti) non aprono nessuna finestra e restituiscono falso. La condizione si aggiunge poi con l'operatore scelto (`AddFilter`), dopo aver tolto quelle della colonna.

### Scenario: svuotare
- **Dato** una colonna di testo con un filtro attivo
- **Quando** l'utente conferma la finestra con il campo vuoto
- **Allora** la condizione della colonna si toglie e non se ne aggiunge un'altra

### Scenario: annullare
- **Dato** la finestra aperta
- **Quando** l'utente la annulla
- **Allora** il filtro resta com'era

## ZDBVIEW-FLT-005 Operatori e valori nella query
L'adattatore `TzFbDataSetFilterOperatorAdapter` traduce gli operatori per Firebird: «è vuoto» e «non è vuoto» diventano `IS NULL` e `IS NOT NULL`; «contiene», «non contiene», `LIKE` e `NOT LIKE` diventano `CONTAINING` e `NOT CONTAINING` (Mantis 752); gli altri operatori restano quelli di DevExpress. Nel testo del filtro i decimali portano il punto decimale; date, ore e data-ora vanno fra apici nel formato `dd.mm.yyyy` (con `hh:nn` per le ore e `hh:nn:ss.zzzz` per la data-ora); nel `TcxFilterCriteriaItem` si aggiunge il formato breve (`hh:nn` per le ore, `dd.mm.yyyy hh:nn` per la data-ora) perché altrimenti l'ora diventa `31.12.1899`.

### Scenario: contiene
- **Dato** la condizione «Cognome contiene `ross`»
- **Quando** il filtro diventa testo SQL
- **Allora** la condizione è `COGNOME CONTAINING 'ross'`

## ZDBVIEW-FLT-006 Menu degli operatori per colonna
`PrepareFilterMenuForField` svuota e ricrea le voci del sottomenu dei filtri (una per operatore ammesso dal tipo della colonna a fuoco, compresi «tra» e «in elenco», esclusi `LIKE` e `NOT LIKE` che ripeterebbero «contiene») e titola il menu `Filtri <categoria del tipo>`. La scelta di una voce (`MenuFilterClick`) aggiunge una condizione col valore del record corrente: per «è vuoto» il valore è Null; per «tra» e «non tra» un intervallo con i due estremi uguali al valore corrente; per «in elenco» un elenco col solo valore corrente; per gli altri il valore corrente. La condizione si aggiunge senza togliere quelle già presenti sulla colonna.

### Scenario: è vuoto
- **Dato** una colonna a fuoco di tipo testo
- **Quando** l'utente sceglie «è vuoto» dal menu dei filtri
- **Allora** la colonna ha una condizione `IS NULL`

## ZDBVIEW-FLT-007 Controllo dei filtri in linea
`TzFilterControl` (il riquadro sopra la griglia che mostra le condizioni attive) notifica `OnChange` **solo** quando il testo del filtro cambia davvero rispetto all'ultimo notificato (`LastFilterText`), e non mentre il controllo si sta aggiornando dal codice (`BeginUpdateLinkComponent`), è in modifica o non è valido. Il valore digitato in una condizione si controlla prima di accettarlo (Mantis #41): se non è valido, e per le date non si riesce a recuperarlo reinserendo i separatori (`11021971` → `11/02/1971`, 8 cifre per l'anno a quattro cifre, 6 per quello a due, con lo zero iniziale del giorno ripristinato), l'editor si chiude **senza** accettare e la condizione tiene il valore di prima; le date fuori dall'intervallo di `TDateTime` sono invalide. Le eccezioni di disegno (`Paint`) e di `MouseLeave` si ignorano, scritte nel registro del filtro. Il riquadro è visibile solo se il filtro è attivo e non vuoto, ha altezza al più un terzo della vista e si nasconde se l'altezza sarebbe 50 o meno.

### Scenario: data digitata senza separatori
- **Dato** una condizione su una data e il testo `11021971` (locale italiano)
- **Quando** l'utente preme Invio
- **Allora** la condizione diventa l'11 febbraio 1971

## ZDBVIEW-FLT-008 Filtro durante una modifica
Se, quando il filtro cambia, il dataset è in modifica o inserimento, l'applicazione si rinvia (Mantis #269): riscrivere la `WHERE` riaprirebbe il dataset scartando le modifiche. Il comando resta in coda e `DataSourceStateChange` lo riapplica quando il dataset torna in consultazione. Lo stesso rinvio vale se la vista non è visibile (pagina di schede non attiva): `CMShowingChanged` lo riprende al rientro.

### Scenario: record in modifica
- **Dato** un record in modifica e una condizione di filtro che cambia
- **Quando** il cambiamento arriva alla vista
- **Allora** il filtro non si applica finché il record non è salvato o annullato

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FLT-1 🟡 (dedotta) | `FilterByFindText` converte il testo con `ToInteger`, `ToInt64`, `ToDouble` e `StrToDateTime` senza `try/except`: un testo non numerico o una data incompleta in una colonna numerica o di data solleva `EConvertError` | Il pannello di ricerca scatta a ogni carattere digitato: scrivere `12a` o `1/` in una colonna numerica o di data mostra un errore invece di non filtrare |
| DIV-FLT-2 🟡 (dedotta) | Nei decimali `ToDouble` usa le impostazioni locali senza togliere i punti delle migliaia, mentre per gli interi i punti si tolgono | `1.250,5` in una colonna decimale dà errore, in una colonna intera `1.250` funziona |
| DIV-FLT-3 🟡 (dedotta) | `FilterByFindText` tratta i campi booleani come testo («inizia per» con un valore stringa), mentre `ChiediFiltroPerValore` li gestisce con Sì/No | Il filtro rapido su un campo booleano genera una condizione di testo su una colonna booleana: risultato errato o errore di Firebird |
| DIV-FLT-4 🟡 (dedotta) | `FilterByValue` valuta `Field.DisplayLabel`, `Field.Value` e `GetFieldOrigin(Field)` **prima** di chiamare `ChiediFiltroPerValore`, che controlla il campo nullo; `PrepareFilterMenuForField` e `MenuFilterClick` usano la colonna a fuoco senza controllare che esista | Con una colonna non legata a un campo, o senza colonna a fuoco, errore di accesso invece di un'uscita silenziosa |
| DIV-FLT-5 🟢 (dedotta) | `AddFilterCondition` riceve `Checked` e non lo usa | Il parametro inganna chi lo chiama: una condizione «non attiva» non esiste |
| DIV-FLT-6 🟢 (dedotta) | Nel ramo `ftDateTime` di `FilterByFindText` il caso «testo vuoto» (data odierna) è dentro un `if not s.IsEmpty` e non può mai scattare | Codice morto che promette «testo vuoto = oggi», che non succede |

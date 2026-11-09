---
area: Totali di piede della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Totali di piede della vista

Questa specifica descrive i totali (somma, media, conteggio, minimo, massimo) che una `TzDbView` mostra nel piede della griglia. Il codice è in `zBase\zDbView.Footer.pas` (`TzDbViewFooterController`, composizione e lettura della query), `zDbView.Controller.pas` (`CalculateFooterValues`, che porta i valori sulla griglia) e `zDbView.pas` (`doCalcFooters`). Le colonne con totale sono quelle di `TzColumn.FooterKind` (`zSystem.pas`), dichiarate nel dizionario o scelte a mano dall'utente.

**Come funziona.** I totali **non** li calcola la griglia sulle righe caricate: la vista lavora in `GridMode`, vede solo le righe già lette. Il controller compone una seconda query aggregata sulla stessa `FROM` e la stessa `WHERE` della vista e la esegue su una connessione e una transazione uguali a quelle del dataset, con gli stessi parametri. Così il totale riguarda **tutte** le righe del filtro, non solo quelle visibili. Il risultato è una riga: ogni campo va nel `FooterValue` della colonna omonima, e di lì nel piede.

**Test che coprono quest'area.** `Test.zDbView.Footer` (`TTestTotaliDiPiede`, 8 prove; `TTestTotaliDiPiedeDivergenze`, 2 prove): provano la composizione senza griglia né database, con una funzione che risolve l'origine di ogni colonna.

## ZDBVIEW-TOT-001 Composizione della query aggregata
`BuildFooterSQL(testo SQL della vista, colonne, risolutore)` restituisce la stringa vuota se il testo è vuoto o fatto di soli spazi, o se nessuna colonna ha un totale (o nessuna ha un'origine). Altrimenti restituisce `SELECT`, un'espressione per riga separate da virgola e a capo (`#13`), e poi la parte `FROM ... WHERE ...` ricavata dal testo della vista con la routine che prepara il conteggio dei record (`CountSelect`): la `FROM` e la `WHERE` principali si conservano, l'`ORDER BY` si toglie, gli elenchi di campi non servono.

### Scenario: select semplice
- **Dato** la vista `SELECT PAGAMENTI.IMPORTO FROM PAGAMENTI WHERE PAGAMENTI.ANNO = 2026 ORDER BY 1 DESC` e la colonna `IMPORTO` con totale somma
- **Quando** si compone la query
- **Allora** il risultato comincia con `SELECT`, contiene `SUM(PAGAMENTI.IMPORTO) IMPORTO`, `FROM PAGAMENTI` e `WHERE PAGAMENTI.ANNO = 2026`, e non contiene `ORDER BY`

### Scenario: nessun totale
- **Dato** nessuna colonna con totale
- **Quando** si compone la query
- **Allora** il risultato è la stringa vuota e nessuna query parte

## ZDBVIEW-TOT-002 Funzioni dei totali
Il tipo di totale della colonna (`FooterKind`) diventa la funzione SQL: `skSUM` → `SUM`, `skAverage` → `AVG`, `skCOUNT` → `COUNT`, `skMIN` → `MIN`, `skMAX` → `MAX`; `skNone` non produce niente. L'espressione è `FUNZIONE(origine) NomeColonna`: l'argomento è l'origine del campo nel dizionario (`GetFieldOrigin`, o il nome del campo se vuota) e l'alias è il nome della colonna, che serve a riportare il valore sulla colonna giusta. `COUNT` conta i valori non nulli dell'origine, non le righe.

### Scenario: tutte le funzioni
- **Dato** cinque colonne con totale somma, media, conteggio, minimo, massimo
- **Quando** si compone la query
- **Allora** compaiono `SUM(...) A`, `AVG(...) B`, `COUNT(...) C`, `MIN(...) D`, `MAX(...) E`

## ZDBVIEW-TOT-003 Colonne senza origine e passi di guardia
Una colonna il cui campo il data controller non trova (origine vuota) si salta senza errore; se le saltano tutte la query non si compone. Il calcolo (`CalculateFooterValues`) cancella prima i valori precedenti e non fa niente se il dataset non è attivo, se non è una query SQL (`IsSQL`) o se un calcolo è già in corso (`busy`: il piede si può ricalcolare mentre la griglia si disegna). La query gira su un dataset usa e getta `NomeDataset__FOOTER`, con i parametri copiati per nome da quello della vista; se la preparazione o l'apertura falliscono (`except` che ignora) il piede resta vuoto, senza messaggio. `TzDbViewController.CalculateFooterValues` riporta i valori sulle colonne del piede, adotta il formato di visualizzazione dei campi numerici (`DisplayFormat`) se la colonna non lo ha già uguale, e mette `Null` dove la colonna non esiste più. Con `Flags.Footer` falso il piede non si vede e `doCalcFooters` non calcola: i totali a runtime scelti dall'utente (dal 2025-06-24) funzionano comunque se il piede è mostrato.

### Scenario: dataset non attivo
- **Dato** una vista il cui dataset è chiuso
- **Quando** si ricalcolano i totali
- **Allora** nessuna query parte e il piede non viene aggiornato

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-TOT-1 🟡 (provata sulla query) | Se la vista ha `GROUP BY`, `HAVING`, `UNION`, `DISTINCT`, `FIRST` o `ROWS`, `CountSelect` produce `SELECT COUNT(*) FROM (...) AS CONTEGGIO_RIGHE`; la query dei totali riusa quel testo e mette `SUM(TABELLA.CAMPO)` **fuori** dalla sottoquery, dove la colonna d'origine non esiste | Firebird rifiuta la query, l'`except` la ignora e il piede resta vuoto, senza messaggio, per ogni vista con raggruppamento o `DISTINCT` |
| DIV-TOT-2 🟢 (provata sulla query) | Se il testo non è una `SELECT` (o `CountSelect` non lo capisce) la parte `FROM` è vuota e `BuildFooterSQL` restituisce comunque `SELECT SUM(...) Nome` senza `FROM` | La query fallisce a ogni ricalcolo e l'errore si ingoia: solo costo inutile; il controllo `IsSQL` a monte la rende rara |
| DIV-TOT-3 🟢 (dedotta) | `CalculateFooterValues` (`TzDbViewFooterController` e `TzDbViewController`) esce con `Exit` dopo `SiMain.EnterMethod` senza `LeaveMethod` | Il registro SmartInspect perde l'allineamento dei livelli di rientro, solo in diagnostica |
| DIV-TOT-4 🟢 (dedotta) | In `TzDbViewController.CalculateFooterValues` il secondo controllo `if not DataController.IsActive` (che azzera i totali del piede) non può mai scattare: il primo controllo, poche righe sopra, è già uscito | Codice morto; se il dataset si chiude, il piede mostra i valori vecchi invece di svuotarsi |
| DIV-TOT-5 🟢 (dedotta) | L'alias del totale è il nome della colonna scritto senza virgolette: un nome che coincide con una parola riservata di Firebird (`VALUE`, `YEAR`) o contiene caratteri strani rende la query non valida | Il piede di quella colonna resta vuoto e, per l'`except`, senza messaggio |

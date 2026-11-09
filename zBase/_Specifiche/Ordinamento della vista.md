---
area: Ordinamento della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Ordinamento della vista

Questa specifica descrive come una `TzDbView` traduce l'ordinamento scelto dall'utente sulla griglia nella clausola `ORDER BY` della query, e come la riporta sulle colonne all'apertura. Il codice è in `zBase\zDbView.Sort.pas` (`TzDbViewSortController`); lo crea `TzDbViewController` (`zDbView.Controller.pas`) e lo chiama `TzDbView` dall'evento `OnSortingChanged` della griglia e all'avvio (`InitControllers`). Lo usano tutte le viste di WT e Gesty, comprese quelle costruite dai metadati LZ.

**Come funziona.** L'ordinamento non lo fa la griglia in memoria: la griglia lavora in modalità `GridMode` e ogni cambio di ordinamento riscrive la `ORDER BY` della query (`DataController.SQL_OrderBy`) e riapre il dataset. `Sort` legge le colonne ordinate della griglia, per ciascuna ricava un'espressione SQL (l'origine del campo nel dizionario, il nome del campo, oppure l'indice posizionale del campo se il campo non esiste nei metadati) e la direzione, e compone il testo. `InitColumns` fa il percorso inverso: legge `SQL_OrderBy`, lo spezza in voci e mette ordine e posizione sulle colonne corrispondenti. L'interruttore `Flags.Sort` della vista abilita o disabilita il tutto.

**Test che coprono quest'area.** `Test.zDbView.Sort` (in `zPack\_UnitTest\_src`): `TTestBuildOrderBy` prova la composizione (lista vuota, campo ascendente e discendente, più campi, espressione vuota saltata); `TTestParseOrderBy` prova la lettura (vuota, singola, `DESC` maiuscolo e minuscolo, `DESCRIZIONE` non scambiato per discendente, voci vuote saltate, andata e ritorno). `Test.zDbView.Divergenze` (`TTestOrdinamentoDivergenze`) fotografa le divergenze qui sotto.

## ZDBVIEW-ORD-001 Composizione della ORDER BY
`BuildOrderBy` unisce le voci con `, ` nell'ordine ricevuto; ogni voce è la sua espressione, seguita da ` DESC` se discendente (l'ascendente non porta suffisso). Le voci con espressione vuota si saltano, senza lasciare virgole orfane. Con nessuna voce il risultato è la stringa vuota, cioè nessun ordinamento.

### Scenario: più campi misti
- **Dato** le voci `COGNOME` ascendente, `NOME` ascendente, `3` discendente
- **Quando** si compone la clausola
- **Allora** il risultato è `COGNOME, NOME, 3 DESC`

### Scenario: voce senza espressione
- **Dato** le voci `A`, una voce vuota discendente, `B`
- **Quando** si compone la clausola
- **Allora** il risultato è `A, B`

## ZDBVIEW-ORD-002 Lettura della ORDER BY
`ParseOrderBy` spezza il testo sulle virgole, toglie gli spazi a inizio e fine di ogni pezzo, salta i pezzi vuoti e riconosce la direzione solo se il pezzo **finisce** con ` DESC` (spazio incluso, senza distinzione di maiuscole): così `DESCRIZIONE` non è scambiata per una voce discendente. Il suffisso si toglie dall'espressione. I nomi fra virgolette doppie restano come sono (`"NOME ANNO" DESC` dà l'espressione `"NOME ANNO"`). Composizione e lettura sono inverse fra loro per le clausole che la composizione stessa produce: leggere e ricomporre `COGNOME, NOME DESC, 3` restituisce lo stesso testo.

### Scenario: campo che contiene la sequenza DESC
- **Dato** il testo `DESCRIZIONE`
- **Quando** lo si legge
- **Allora** c'è una voce ascendente con espressione `DESCRIZIONE`

### Scenario: andata e ritorno
- **Dato** il testo `COGNOME, NOME DESC, 3`
- **Quando** lo si legge e lo si ricompone
- **Allora** il risultato è identico al testo di partenza

## ZDBVIEW-ORD-003 Espressione di ordinamento di una colonna
Per ogni colonna ordinata che ha un campo, `Sort` sceglie l'espressione così: se il campo **non** esiste nei metadati del database (`Base.MetaData.FieldOrParamExists` sulla tabella di origine del campo), usa l'indice posizionale `Campo.Index + 1`, che regge anche i campi calcolati e le espressioni della `SELECT`; altrimenti usa l'origine del campo (`DataController.GetFieldOrigin`), e se è vuota il nome del campo. Le colonne senza campo non producono voci. La direzione è discendente se l'ordine della colonna è `soDescending`.

### Scenario: campo calcolato
- **Dato** una colonna ordinata il cui campo è il terzo della `SELECT` e non esiste nei metadati
- **Quando** si ordina
- **Allora** la `ORDER BY` contiene `3`

## ZDBVIEW-ORD-004 Quando l'ordinamento è attivo
`Sort` non fa niente se il dataset non è utilizzabile (`DataController.DataSetOk` falso), se `SortingEnabled` è falso (lo imposta `Flags.Sort` della vista, con `PropsChanged`) o se è in corso `InitColumns`: durante l'apertura le colonne vengono ordinate dal codice e la modifica non deve riscrivere la query (`DisableSorting`). `InitColumns` toglie prima ogni ordinamento della griglia (`ClearSorting`), poi per ogni voce di `SQL_OrderBy` cerca il campo corrispondente all'origine (`GetFieldNameByOrigin`) e imposta ordine e `SortIndex` uguale alla posizione della voce; le voci senza campo corrispondente si ignorano.

### Scenario: apertura con ordinamento salvato
- **Dato** una vista con `SQL_OrderBy` uguale a `COGNOME, NOME DESC`
- **Quando** la vista si apre
- **Allora** la colonna del cognome è ordinata in modo ascendente con indice 0 e quella del nome in modo discendente con indice 1, e la query non viene riscritta

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice. Le prove di `TTestOrdinamentoDivergenze` le fotografano tutte e tre.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-ORD-1 🟡 (provata) | `ParseOrderBy` spezza il testo su **ogni** virgola, anche dentro le parentesi: `COALESCE(A, B) DESC` diventa due voci, `COALESCE(A` e `B)` discendente | `InitColumns` non trova il campo di nessuna delle due: l'ordinamento salvato con un'espressione non si riporta sulla griglia. La query resta corretta, perché `SQL_OrderBy` non si riscrive finché l'utente non ordina di nuovo |
| DIV-ORD-2 🟢 (provata) | Il solo suffisso riconosciuto è ` DESC`: `NOME ASC` e `DATA DESC NULLS LAST` restano espressioni intere e la direzione risulta ascendente | Chi scrive una `ORDER BY` a mano nel dizionario con `NULLS LAST` vede l'indicatore di direzione sbagliato. Con `ASC` il campo non si trova e la freccia manca |
| DIV-ORD-3 🟢 (provata) | ` DESC` preceduto da tabulazione o a capo non è riconosciuto | Come DIV-ORD-2, per `ORDER BY` scritte su più righe |

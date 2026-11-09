---
area: Selezione dei record della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Selezione dei record della vista

Questa specifica descrive come una `TzDbView` fa lavorare il codice sui record che l'utente ha selezionato nella griglia (selezione multipla): scorrimento, raccolta degli identificativi, eliminazione multipla e scelta multipla dalla finestra `TzDbViewDlg`. Il codice è in `zBase\zDbView.pas` (`EnumSelectedRows`, `ForEach`, `GetSelectedRows`, `AreAllRowsSelected`, `dbDelete`) e `zDbViewDlg.pas` (`TzDbViewForm.Execute`). Lo usano le azioni di massa di WT e Gesty e le finestre di scelta.

**Come funziona.** Con `Flags.MultiSelect` la griglia mostra le caselle di selezione. Il codice che deve agire su più record non guarda la griglia: chiama `GetSelectedRows(proc)` (o `ForEach`), che porta il **dataset** su ciascun record selezionato e chiama `proc`, così `proc` può leggere i campi del dataset come per un record qualunque. Alla fine ripristina il record corrente.

**Test che coprono quest'area.** Nessuna: richiede griglia e dataset aperti.

## ZDBVIEW-SEL-001 Scorrimento dei record selezionati
`EnumSelectedRows(proc, direzione)` non fa niente se il dataset non è utilizzabile o è vuoto. Altrimenti, con la finestra di attesa e il record corrente salvato (segnalibro in `GridMode`, record della griglia altrimenti):
1. **nessuna riga selezionata**: chiama `proc` una volta, sul record corrente;
2. **tutte le righe selezionate** (`AreAllRowsSelected`): scorre l'intero dataset dall'inizio (`edAscending`) o dalla fine (`edDescending`);
3. **altrimenti in `GridMode`**: va su ogni segnalibro selezionato (`GetSelectedBookmark`) nell'ordine di selezione o al contrario;
4. **altrimenti in memoria** (griglia raggruppata o con tutti i record caricati): mette a fuoco ogni record selezionato (`SelectedRecords`) e riporta il dataset su di esso.
A fine giro, anche con un errore, il dataset torna sul record di partenza e i controlli collegati si riattivano; gli errori di quel ripristino si ingoiano.

### Scenario: nessuna selezione
- **Dato** una vista con multiselezione e nessuna riga selezionata
- **Quando** il codice chiama `GetSelectedRows`
- **Allora** `proc` viene chiamata una volta sul record corrente

### Scenario: tutte selezionate
- **Dato** tutte le righe selezionate, 3 record
- **Quando** si scorre in ordine crescente
- **Allora** `proc` è chiamata una volta per ognuno dei 3 record

## ZDBVIEW-SEL-002 Raccolta degli identificativi
`GetSelectedRows(campo, elenco, [funzione,] [distinti])` svuota l'elenco e, per ogni record selezionato (in ordine crescente), aggiunge il valore del campo, **saltando** i valori `Null`; con `Distinct` vero salta i valori già presenti; con la funzione (di tipo `TFunc<Boolean>`) aggiunge il valore solo se la funzione risponde vero sul record corrente. Se il campo non esiste nel dataset l'elenco resta vuoto. L'elenco può essere di `Int64` (`AsLargeInt`), `Integer` (`AsInteger`) o stringhe (`AsString`).

### Scenario: valori ripetuti
- **Dato** tre righe selezionate con `ID_CLIENTE` 5, 7, 5 e `Distinct` vero
- **Quando** si raccoglie `ID_CLIENTE` in una lista di `Int64`
- **Allora** la lista è `5, 7`

### Scenario: valore nullo
- **Dato** una riga selezionata con `ID_CLIENTE` nullo
- **Quando** si raccoglie
- **Allora** quella riga non aggiunge niente

## ZDBVIEW-SEL-003 Tutte le righe selezionate
`AreAllRowsSelected` è vero se lo dice il data controller (`AreAllRowsSelected`) oppure se la griglia ha almeno una riga selezionata e il numero di record selezionati è maggiore o uguale al numero di record del data controller: la seconda condizione copre il caso in cui la selezione è fatta in memoria e il data controller non lo riconosce.

### Scenario: nessuna riga selezionata
- **Dato** nessuna riga selezionata
- **Quando** si chiama `AreAllRowsSelected`
- **Allora** il risultato è falso, anche se il dataset ha zero record

## ZDBVIEW-SEL-004 Eliminazione di più record
`dbDelete` (azione «Elimina»): se la vista ha l'evento `OnDataSetDelete` lo chiama e basta; altrimenti, se il dataset consente l'eliminazione (`CanDelete`) e `Flags.ButtonDelete` è vero, con una riga o nessuna selezionata chiede conferma (`ConfirmDelete(False)`) ed elimina il record corrente; con più righe selezionate chiede la conferma per gli elementi multipli (`ConfirmDelete(True)`), elimina in ordine **decrescente** (`EnumSelectedRows(..., edDescending)`, perché eliminare in ordine crescente sposterebbe i record ancora da eliminare) e toglie la selezione.

### Scenario: due righe selezionate
- **Dato** due righe selezionate non contigue
- **Quando** l'utente conferma l'eliminazione multipla
- **Allora** vengono eliminati quei due record e nessun altro, e la selezione è vuota

## ZDBVIEW-SEL-005 Scelta multipla dalla finestra
`TzDbViewForm.Execute` (finestra di scelta di `TzDbViewDlg`) restituisce vero se l'utente chiude con OK. Solo in quel caso, se il dataset non è vuoto e c'è una procedura (`MultiSelectProc`) o un evento (`MultiSelectEvent`) di scelta multipla, li chiama con `GetSelectedRows`, cioè una volta per record selezionato (o una sola, sul record corrente, se nessuno è selezionato). La procedura ha la precedenza sull'evento. La posizione e le dimensioni della finestra si salvano nel file `.Dlgs` dell'utente, nella sezione `IniSection`.

### Scenario: annullo
- **Dato** la finestra di scelta con tre righe selezionate
- **Quando** l'utente annulla
- **Allora** nessuna procedura o evento di scelta viene chiamato

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-SEL-1 🟡 (dedotta) | Nel ramo «tutte selezionate» in ordine decrescente il ciclo `while not Bof` chiama `proc` e poi `Prior`; quando `Prior` dal primo record accende `Bof`, il ciclo finisce e il codice successivo (`if not IsEmpty then proc`) chiama `proc` **ancora** sul primo record | Il primo record viene trattato due volte: una raccolta di valori senza `Distinct` avrebbe un duplicato (oggi l'ordine decrescente lo usa solo l'eliminazione, ma `ForEach` lo espone a tutti) |
| DIV-SEL-2 🟡 (dedotta) | Nello stesso ramo, con l'eliminazione come `proc`, `Prior` dopo ogni `Delete` salta un record (il dataset dopo `Delete` sta già sul precedente o sul successivo) | Eliminando «tutte le righe selezionate» possono restare record non eliminati e, al contrario, il passo in più può agire sul record sbagliato. Da provare sul banco con 4-5 record e «seleziona tutto» |
| DIV-SEL-3 🟢 (dedotta) | `GetSelectedRows` con elenco di `Integer` usa `AsInteger`: su un campo `Largeint` il valore oltre 2.147.483.647 si tronca o dà errore | Nessuna chiave di WT o Gesty arriva a quei valori oggi; chi ne ha bisogno deve usare l'elenco di `Int64` |
| DIV-SEL-4 🟢 (dedotta) | `EnumSelectedRows` accende la finestra di attesa (`StartWait`) prima del `try`: se la preparazione fallisce (lettura del segnalibro) l'attesa non si spegne | La finestra di attesa resta aperta dopo un errore |
| DIV-SEL-5 🟢 (dedotta) | Nel ramo «tutte selezionate» lo scorrimento è sul dataset intero e non sulle righe della griglia: con un filtro in memoria (non `GridMode`) il dataset può avere più record di quelli visti | Un'azione di massa con «seleziona tutto» può agire anche su record che l'utente non vede; oggi i filtri riscrivono la `WHERE`, quindi i due insiemi coincidono |

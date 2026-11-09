---
area: Layout della card
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbcard/003
---

# Layout della card

Questa specifica descrive come `TzDbCard` dispone i campi in righe dentro il `TdxLayoutControl`: le metriche di riga, i nomi degli elementi generati, la larghezza suggerita del dialogo e le regole di costruzione (`Build`). Il codice è in `zBase\zDbCard.Layout.pas` (`TzRowModel`, `TzCardLayoutNames`, `TzDialogWidthModel`, `TzLayoutMetrics`, `TzCardLayoutBuilder`); la card lo chiama da `zDbCard.pas` (`NewRowModel`, `BuildLayoutItems`, `CalcSuggestedDialogWidth`, `SyncLayoutFromEditor`). Lo usano WT e Gesty tramite `TzDbCard` (la libreria è la stessa) e ogni form documentale, perché le card nascono dai metadati LZ. Le copie `zDbCard - Layout.pas`, `zDbCard - Mio Codice.pas` e la cartella `zDbCard - Mio\` non compaiono nel pacchetto `zBase_Common_104.dpk` e non si specificano. Descrive il comportamento atteso, non il codice.

**Come funziona.** Un campo occupa una «dimensione» in caratteri (`Size`), che il modello converte in pixel con la larghezza di un carattere (7 px di riserva, oppure misurata sul font reale). La riga radice ha una capacità in pixel (`RowMaxPx`) e in caratteri (`RowMaxSize`). `Build` lavora in due passate: prima crea i gruppi (`ctGroupBox`, `ctCheckGroupBox`), poi i campi, che fluiscono in righe orizzontali e vanno a capo quando la riga è piena. Con `SnapToGrid` le larghezze si agganciano a `ColCount` colonne esatte con i gutter veri; senza griglia vale il calcolo a caratteri. Alla fine si riapplica la struttura salvata dall'utente (`Props.Layout.SaveToLayout`).

**Test che coprono quest'area.** `Test.zDbCard.Layout` (metriche di `TzRowModel`, nomi di `TzCardLayoutNames`, `GridColumnEdge`, `SuggestedWidth`, fotografia di DIV-LAY-1) e `Test.zDbCard.Estrazioni` (`TzDialogWidthModel`). Il `Build` vero richiede un `TdxLayoutControl` con finestra e non ha test automatici: si prova sul banco.

## ZDBCARD-LAY-001 Metriche della riga
`TzRowModel.Create(DlgWidth, Font)` calcola la capacità della riga: `RowMaxPx = Max(0, DlgWidth - 20 - 20)` (margine `H_MARGIN` e scrollbar `VSCROLLBAR_WIDTH`) e `RowMaxSize = Max(20, RowMaxPx div CharWidth)`. Con `DlgWidth <= 0` la larghezza non è nota: `RowMaxSize = 130` (`FALLBACK_ROW_SIZE`) e `RowMaxPx = 130 * CharWidth`. `CreateFromAreaWidth` prende invece un'area già al netto dei margini (nessuna sottrazione). Senza font `CharWidth = 7` e `LineHeight = 18`; con un font la larghezza è la media su venti caratteri campione (minimo 4) e l'altezza è quella del testo più 1 (minimo 12), così le unità seguono corpo e DPI del frame.

### Scenario: dialogo di 800 px
- **Dato** un modello creato con larghezza 800 e senza font
- **Quando** si leggono le capacità
- **Allora** `RowMaxPx` è 760 e `RowMaxSize` è 108

### Scenario: larghezza non nota
- **Dato** un modello creato con larghezza 0
- **Quando** si leggono le capacità
- **Allora** `RowMaxSize` è 130 e `RowMaxPx` è 910

## ZDBCARD-LAY-002 Dimensione effettiva e ingombro
`EffectiveSize(Size, Domain)` restituisce `Size` se positivo, altrimenti la dimensione del dominio (`GetCtrlSize`), altrimenti 20 (`DEFAULT_SIZE`), mai oltre `RowMaxSize`. `EffectiveSlot` aggiunge la caption quando sta a sinistra: `CaptionLen + 1` se la caption non è vuota; anche il risultato non supera `RowMaxSize`. `Overflows(Usato, Dimensione)` è vero solo se la somma supera la capacità: la somma pari alla capacità non sfora.

### Scenario: caption a sinistra
- **Dato** un campo di 20 caratteri con una caption di 10
- **Quando** si calcola l'ingombro
- **Allora** vale 31 (20 + 10 + 1 per il separatore)

### Scenario: riga piena al limite
- **Dato** una riga già occupata per `RowMaxSize - 8` caratteri
- **Quando** si aggiunge un campo da 8 caratteri
- **Allora** `Overflows` è falso; con 9 caratteri è vero

## ZDBCARD-LAY-003 Griglia di colonne
Con la griglia attiva (`SnapToGrid`, `GridCols = Max(1, ColCount)`) la capacità è divisa in `GridCols` colonne separate da `GridCols - 1` gutter reali. `TzLayoutMetrics.GridColumnEdge(CapacityPx, ColumnIndex, GridCols, ItemGapPx)` dà il bordo sinistro in pixel della colonna `ColumnIndex` (da 0): lo spazio netto è `Max(GridCols, CapacityPx - (GridCols - 1) * ItemGapPx)` e il bordo è `ColumnIndex * netto div GridCols + ColumnIndex * ItemGapPx`; con `GridCols <= 0` vale 0. Il bordo della colonna «dopo l'ultima» cade un gutter oltre la capacità. Il builder e le guide della griglia della card usano questa stessa formula, perché i bordi coincidano al pixel fra righe diverse. Il numero di colonne di un campo (`ColumnSpan`) conta anche i gutter interni, ed è limitato fra 1 e `GridCols`; con `ColSpan` fisso del campo (non booleano) vale quello dichiarato, limitato a `GridCols`.
Per le righe interne ai gruppi e per i pesi dei gruppi vale la quantizzazione in caratteri: `SnapSlot(Chars, Capacity, GridCols)` arrotonda al multiplo superiore dell'unità `Capacity div GridCols` e non supera la capacità; con `GridCols <= 1` o capacità non positiva restituisce il valore invariato.

### Scenario: bordi di una griglia a quattro colonne
- **Dato** capacità 1000 px, 4 colonne, gutter 7 px
- **Quando** si calcolano i bordi delle colonne 0, 1, 2 e 4
- **Allora** valgono 0, 251, 503 e 1007

### Scenario: quantizzazione in caratteri
- **Dato** capacità 100 caratteri e 10 colonne
- **Quando** si quantizza un campo di 13 caratteri
- **Allora** diventa 20; un campo di 95 diventa 100 (non oltre la capacità)

## ZDBCARD-LAY-004 Minimo di un elemento
`MinSlotPx(SlotChars, CaptionLen, CaptionAtLeft)` è la larghezza in pixel sotto cui un elemento non si comprime: con la caption a sinistra `CaptionLen + 4` caratteri (`MIN_EDIT_CHARS`), altrimenti 4; mai oltre `SlotChars`, e almeno 1 carattere. La somma dei minimi di una riga non supera quindi la sua larghezza e non compare la barra di scorrimento orizzontale.
### Scenario: caption a sinistra
- **Dato** un campo di 20 caratteri con caption di 8
- **Quando** si calcola il minimo
- **Allora** vale 12 caratteri, cioè 84 px; per un campo di 10 caratteri vale 70 px (limitato dallo slot)

## ZDBCARD-LAY-005 Nomi degli elementi generati
Gli elementi creati dal controller hanno nomi fissi, che includono il nome della card: campo `li_<CAMPO>_<card>`, gruppo `grp_<CAMPO>_<card>`, riga radice `row_<n>_<card>`, riempitivo `fill_<n>_<usato>_<card>`, separatore `sep_<n>_<card>`, riga di gruppo `grprow_<n>_<gruppo>_<card>`, riempitivo di gruppo `grpfill_<n>_<usato>_<gruppo>_<card>`. Il nome della card si passa a ogni chiamata, perché il `Name` di un frame può essere assegnato dopo la costruzione.

### Scenario: nomi di esempio
- **Dato** la card `Card1`
- **Quando** si chiedono i nomi del campo `NOME`, del gruppo `NOTE` e della riga 2 del gruppo `grpAzienda`
- **Allora** si ottengono `li_NOME_Card1`, `grp_NOTE_Card1` e `grprow_2_grpAzienda_Card1`

## ZDBCARD-LAY-006 Lettura dei nomi
`ExtractFieldName(Card, Item)` restituisce il nome del campo solo per `li_…` e `grp_…` che finiscono con `_<card>`; per righe, riempitivi, separatori, righe e riempitivi di gruppo e per un nome di un'altra card restituisce una stringa vuota. I nomi con il trattino basso (`DATA_NASCITA`, card `frm_Card`) tornano interi. `ExtractGroupNameFromRowName` ricava il nome del gruppo solo da `grprow_<n>_<gruppo>_<card>`; da una riga radice o da un riempitivo restituisce vuoto. Un nome di gruppo con trattini bassi torna intero.

### Scenario: andata e ritorno
- **Dato** il nome costruito per il campo `DATA_NASCITA` della card `Card1`
- **Quando** lo si legge con `ExtractFieldName`
- **Allora** si ottiene `DATA_NASCITA`

### Scenario: riga radice
- **Dato** il nome `row_1_Card1`
- **Quando** si chiede il nome del gruppo
- **Allora** il risultato è vuoto

## ZDBCARD-LAY-007 Larghezza suggerita del dialogo
`TzDialogWidthModel.MaxRowSum` somma gli ingombri per riga (`ROW_BREAK = -1` chiude la riga, per `ctLineBreak` e `ctSeparator`) e restituisce la riga più larga, compresa l'ultima senza interruzione. `SuggestedWidth(Caratteri, LarghezzaCarattere, Minimo, MassimoDisponibile)` calcola `Caratteri * LarghezzaCarattere + 20 + 20`, con 130 caratteri se la somma è zero o negativa, poi porta il risultato al minimo, poi al massimo disponibile, e tronca al multiplo di 10. Il massimo vince sul minimo: su uno schermo stretto la larghezza resta sotto il minimo. `TzDbCard.CalcSuggestedDialogWidth` usa 400 px di minimo e il 75% della larghezza del monitor attivo come massimo, considera solo i campi visibili e fuori dai gruppi (un gruppo ha una sua dimensione) e conta la caption (`Length(DisplayLabel)`) solo con la caption a sinistra.

### Scenario: calcolo base
- **Dato** una riga di 100 caratteri, 7 px per carattere, minimo 400, massimo 1000
- **Quando** si calcola la larghezza
- **Allora** vale 740

### Scenario: schermo stretto
- **Dato** una riga di 10 caratteri, minimo 400 e massimo disponibile 300
- **Quando** si calcola la larghezza
- **Allora** vale 300

## ZDBCARD-LAY-008 Righe radice e andata a capo
`Build` crea per ogni riga radice un gruppo orizzontale senza bordo e senza caption. I campi visibili (con un controllo, `EditControl` o `FallbackControl`) fluiscono nella riga; si va a capo quando l'elemento non ci sta, quando il campo ha `rpForceNewLine` (se la riga ha già contenuto), o per un `ctLineBreak` visibile (`FlushRow`; con `Group` valorizzato chiude invece la riga interna di quel gruppo). Un `ctSeparator` chiude la riga e crea un elemento separatore a tutta larghezza (`sep_`). Una riga di campi si chiude con un riempitivo che assorbe lo spazio residuo (capacità meno la posizione del prossimo elemento in modalità griglia; senza griglia capacità meno somma delle larghezze meno un gutter per campo), creato solo se positivo; una riga di gruppi non ha riempitivo, perché i gruppi riempiono la larghezza. Gli elementi invisibili non producono niente. Gli elementi generati sono marcati non definiti dall'utente (`SetFlagUserDefined(false)`), così `ClearGeneratedItems` li toglie al ricostruire senza distruggere i controlli ospitati.

### Scenario: campo che non ci sta
- **Dato** una riga già piena di campi
- **Quando** arriva un altro campo
- **Allora** `Build` apre la riga successiva (`row_<n+1>_<card>`) e chiude la precedente con il riempitivo

## ZDBCARD-LAY-009 Gruppi
Ogni `ctGroupBox` o `ctCheckGroupBox` visibile e senza `Group` ha un gruppo del layout (`grp_`), creato nella prima passata. Per default sta in una riga propria a tutta larghezza (direzione verticale, così il gruppo chiuso si ripiega bene); con `rpSameRow` e una riga con contenuto, si affianca all'elemento precedente e i gruppi affiancati si dividono la riga in proporzione al loro `Size`, senza limite di capacità (il `Size` è un peso). I campi con `Group` valorizzato vanno in righe interne al gruppo (`grprow_`), con una capacità propria: la larghezza misurata dal `Build` precedente, altrimenti una stima (la riga radice meno i margini reali del bordo, o la quota del `Size` per i gruppi affiancati) e il numero di gruppi stimati si riporta in `EstimatedGroups`. La capacità non supera mai la riga radice corrente meno i margini, e ha un minimo di 10 caratteri. Un campo il cui gruppo non esiste nel layout cade nella riga radice.

### Scenario: gruppo affiancato
- **Dato** un campo e, subito dopo, un gruppo con `rpSameRow`
- **Quando** si costruisce il layout
- **Allora** il gruppo entra nella stessa riga e la riga non ha riempitivo

## ZDBCARD-LAY-010 Booleani, memo e colonne fisse
I booleani non occupano colonne: la loro larghezza è quella reale della caption più un margine (`BoolSlotPx`, minimo 5 caratteri) e avanzano a pixel negli spazi parziali. Un memo o RTF occupa tutte le colonne residue della riga, oppure solo quelle dichiarate con `ColSpan`; se subito dopo di lui ci sono booleani con `rpSameRow` nello stesso contenitore, il memo lascia lo spazio per loro e la riga non si chiude. L'altezza dei memo è sempre esplicita: con una riga l'altezza naturale di un campo a riga singola della card, altrimenti `Righe * LineHeight + 4`, con al più 40 righe; i campi a riga singola restano in automatico. `ColSpan` fisso vale solo con la griglia attiva e mai per i booleani.

### Scenario: memo con un flag accanto
- **Dato** un memo seguito da un booleano `rpSameRow` nello stesso gruppo
- **Quando** si costruisce la riga
- **Allora** il memo è più stretto della riga residua del posto del flag e il flag sta alla sua destra

## ZDBCARD-LAY-011 Metriche reali del motore
Quando il controllo è disponibile `TzLayoutMetrics` sostituisce le costanti con i valori veri del motore DevExpress: `ItemGap` è l'offset reale fra elementi adiacenti (7 px se non risolvibile o non positivo); `RootCapacityWidth` è la larghezza del client meno due offset radice meno la scrollbar verticale, e vale 0 senza finestra o senza client utilizzabile (la card ricade sulla stima da `DlgWidth`); `GroupInnerHorizontalMargins` è bordo sinistro più destro più due offset (20 px di riserva senza look and feel). La capacità non si misura mai dal contenuto già calcolato, altrimenti uno sforamento si autoalimenterebbe a ogni ricostruzione. Il `Build` costruisce le colonne su una capacità ridotta di una banda di sicurezza (`Max(2, gutter)`), che il riempitivo di fine riga assorbe.

### Scenario: controllo senza finestra
- **Dato** un `TdxLayoutControl` senza handle
- **Quando** si chiede `RootCapacityWidth`
- **Allora** il risultato è 0 e la card usa la stima

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-211 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita; DIV-LAY-1 è fotografata da un test; DIV-LAY-3 è stata provata sul banco e non si è riprodotta nel caso semplice.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LAY-1 🟢 | `RowMaxSize` ha il minimo di 20 caratteri (140 px), `RowMaxPx` no: con una larghezza di 100 px si ha `RowMaxPx = 60` e `RowMaxSize = 20`. Provata da `Create_LarghezzaStretta_RowMaxSizeSuperaLaCapacitaInPixel` | In un frame molto stretto le righe a caratteri e quelle a pixel hanno capacità diverse; oltre ai 60 px reali compare la barra di scorrimento |
| DIV-LAY-2 ✅ (corretta) | `SnapSlotPx`, `SpanGapPxOfPx` e `GroupCapacity` non avevano chiamanti in `zBase` (solo la copia `zDbCard - Layout.pas`, fuori dal pacchetto, e i test). Tolti nel rilascio 007, con i loro test | Nessuna: era codice morto |
| DIV-LAY-3 🟡 (non riprodotta sul banco, 2026-11-02) | `TzDbCard.SyncLayoutFromEditor` decide il wrap con `RowModel.SnapSlot` (caratteri) e `Overflows`, mentre `Build` con la griglia attiva usa `ColumnSpan` e `ColumnEdge` (colonne esatte con gutter). `WouldOverflow` applica già `SnapSlot` quando `SnapToGrid` è attivo | In teoria dopo la chiusura dell'editor una riga potrebbe andare a capo in un punto diverso da quello del `Build`. Provata sul banco Gesty con la card `Aule.Aule` (6 righe, griglia attiva): aperta, editor di layout aperto e chiuso senza modifiche, card chiusa e riaperta, disposizione identica in tutte le righe. Resta non provato il caso con campi spostati o ridimensionati nell'editor, con booleani o memo affiancati: lì le due logiche (caratteri e colonne esatte) potrebbero ancora divergere. Non corretta, per non toccare un codice che nel caso provato funziona |
| DIV-LAY-4 🟢 (dedotta) | Un `ctGroupBox` con `Group` valorizzato (gruppo dentro un gruppo) non crea il suo gruppo nella prima passata, e nella seconda `FindItem` non lo trova: viene saltato senza segnalazione. I suoi membri cadono in riga radice | I gruppi nidificati non sono gestiti: non compare né un errore né il gruppo, e i campi risultano fuori posto |

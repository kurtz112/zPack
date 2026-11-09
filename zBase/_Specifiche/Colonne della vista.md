---
area: Colonne della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Colonne della vista

Questa specifica descrive come una `TzDbView` costruisce le colonne della griglia dal dizionario LZ e dal dataset, come applica le impostazioni della vista (flag), la finestra «Seleziona colonne», la formattazione condizionale dell'utente e il doppio clic. Il codice è in `zBase\zDbView.pas` (`CreateColumns`, `LoadProperties`, `AllineaLocate`, `cxGridDBTableViewDblClick`, formattazione condizionale), `zDbView.Columns.Frm.pas` (`TFormDbViewColumns`) e `zSystem.pas` (`TzColumn`, `TzColumns`, `TzDbViewProps`, `TzDbViewFlags`). Il salvataggio e il caricamento della disposizione sono in «Layout colonne della vista.md». Lo usano tutte le viste di WT e Gesty; le form documentali le costruiscono dai metadati.

**Come funziona.** La vista non ha colonne disegnate: all'apertura (`CreateColumns`) la griglia crea una colonna per ogni campo del dataset (`CreateAllItems`), poi le proprietà del dizionario (`TzColumn`) si riportano su ciascuna: titolo, tipo di controllo, sola lettura, larghezza. Le impostazioni della vista (`TzDbViewFlags`) governano le opzioni della griglia (`LoadProperties`).

**Test che coprono quest'area.** Nessuna: richiede griglia, dataset e dizionario.

## ZDBVIEW-COL-001 Titolo, tipo e proprietà di una colonna
Per ogni `TzColumn` del dizionario che ha una colonna e un campo nel dataset: il **titolo** viene, in ordine di precedenza, dalla personalizzazione del cliente (`Overrides.CaptionGrid` per dataset e campo), poi dal titolo scritto sulla vista (`RawCaption`), poi dall'etichetta del dominio del campo. Il **tipo di controllo** è quello della colonna, se non è `ctDefault`, altrimenti quello del dominio; i tipi di ricerca (`IsLookup`) diventano un campo di testo semplice. La colonna riceve le proprietà del tipo (`dx.InitProperties`), la sola lettura del dizionario (la colonna non è modificabile se `ReadOnly`), `Options.Sorting` uguale a `Flags.Sort` e la larghezza del dizionario. I tipi con comportamento proprio: `ctHyperLink` (collegamento che si apre con un clic, senza prefisso automatico, il prefisso è il nome della colonna), `ctColorCombo` (disegno personalizzato della cella), `ctToggleSwitch` (senza indicatore di stato). I campi del dataset senza `TzColumn` restano con le proprietà predefinite della griglia.

### Scenario: titolo personalizzato dal cliente
- **Dato** un campo con etichetta del dominio `Cognome` e una personalizzazione del cliente `Cognome e nome`
- **Quando** la vista si apre
- **Allora** la colonna ha il titolo `Cognome e nome`

### Scenario: colonna di sola lettura
- **Dato** una colonna del dizionario con `ReadOnly` vero
- **Quando** la vista si apre
- **Allora** l'utente non può modificarla né in cella né nella proprietà dell'editor

## ZDBVIEW-COL-002 Impostazioni della vista
`LoadProperties` (all'apertura, dopo «Personalizza» e dopo «Carica impostazioni»; non in fase di progettazione) riporta sulla griglia: sola lettura della vista (`IsViewReadOnly`) sul `DataController`; `Flags.Editing` su modifica e annullamento all'uscita; `Flags.AutoWidth` sulle colonne adattate alla griglia; `Flags.IgnoreTimeForFiltering`, `Flags.Footer` (piede), `Flags.GroupBy` (riquadro di raggruppamento), `Flags.GroupFooters`, `Flags.GroupsAlwaysExpanded` (gruppi sempre aperti); `Flags.MultiSelect` (selezione multipla e caselle di selezione sulle righe e sull'intestazione); `Flags.RowSelect` (selezione a riga intera: spegne la selezione di cella e la selezione invertita); `Flags.HideFocusRectOnExit`; `Flags.Sort` su ogni colonna; la colonna di anteprima (`PreviewFieldName`); la colonna e l'apertura del pannello di ricerca (`SearchFields`, `Flags.Search`); la formattazione condizionale del dizionario; la descrizione; poi ricostruisce la barra e aggiorna le azioni. La ricerca incrementale è sempre spenta.

### Scenario: selezione multipla
- **Dato** `Flags.MultiSelect` vero
- **Quando** si caricano le proprietà
- **Allora** le righe e l'intestazione mostrano le caselle di selezione

## ZDBVIEW-COL-003 Finestra «Seleziona colonne»
`EditDbViewColumns` mostra le colonne **con un campo nel dataset** nell'ordine del dizionario, ciascuna con una casella (visibile o no) e il titolo della colonna. L'utente può spuntare, nascondere o mostrare le selezionate, selezionare tutto, spostare su e giù le selezionate, trascinarle, cercare per titolo (la ricerca porta il cursore sulla prima voce che contiene il testo, senza distinzione di maiuscole). Alla conferma (e a ogni «Applica») la finestra scrive nelle proprietà della vista visibilità e posizione (`Index`) di ciascuna colonna e rilegge le colonne; poi la vista salva con `SaveToIni` (ZDBVIEW-LAY-004).

### Scenario: nascondere una colonna
- **Dato** la colonna `NOTE` visibile
- **Quando** l'utente la deseleziona e conferma
- **Allora** `NOTE` sparisce dalla griglia e dal layout personale

## ZDBVIEW-COL-004 Formattazione condizionale dell'utente
Le regole di formattazione condizionale scelte dall'utente si conservano **per vista**, in un file accanto al layout personale: `<nome del .Columns senza estensione>.<ViewID>.conditionalFormatting` (i caratteri non ammessi nei nomi di file si sostituiscono con `_`), più un file `.fields` con i nomi dei campi nell'ordine degli item della griglia al momento del salvataggio. Senza regole il salvataggio **cancella** i due file di quella vista e basta. Alla rilettura le aree delle regole (indici di colonna) si riallineano per nome di campo: la regola il cui campo non esiste più si scarta, quella con area «tutte le colonne» non cambia. Il vecchio file unico per programma (R-020) non si legge più.

### Scenario: colonna aggiunta dal dizionario
- **Dato** una regola salvata sulla terza colonna e un dizionario che ha aggiunto una colonna prima di essa
- **Quando** la vista si riapre
- **Allora** la regola colpisce ancora lo stesso campo, che ora è la quarta colonna

## ZDBVIEW-COL-005 Doppio clic
Il doppio clic su una cella (o sullo spazio vuoto della griglia) apre la scheda del record (`ShowRecord(False)`); se la colonna a fuoco è un collegamento ipertestuale e il clic è su una cella apre il collegamento (`DoHyperLink`). Il doppio clic sulle intestazioni e sulle altre parti della griglia non fa niente.

### Scenario: doppio clic su un collegamento
- **Dato** la colonna a fuoco di tipo collegamento ipertestuale
- **Quando** l'utente fa doppio clic su una sua cella
- **Allora** si apre il collegamento e non la scheda del record

## ZDBVIEW-COL-006 Locate del dataset con la griglia raggruppata
Una griglia raggruppata (o fuori da `GridMode`) carica tutti i record e posiziona il dataset con `Locate` sulla chiave: finché è così la vista spegne la ricerca su SQL del dataset (`UseSqlLocate`, che riaprirebbe la query con il solo record cercato e mostrerebbe una riga sola) e conserva il valore di prima; quando la griglia torna in `GridMode` o la vista lascia il dataset, lo ripristina. Il modo si guarda dalle cause (`GridMode` falso o gruppi presenti), non da `IsGridMode`, perché `OnGroupingChanged` può arrivare prima del ricalcolo del modo.

### Scenario: raggruppamento per data
- **Dato** una vista in `GridMode` con ricerca su SQL attiva
- **Quando** l'utente raggruppa per una colonna
- **Allora** la ricerca su SQL si spegne e l'elenco raggruppato mostra tutti i record

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-COL-1 🟡 (dedotta) | Nella finestra «Seleziona colonne» `MoveUpExecute` sposta le voci selezionate ognuna di un posto, ma salta solo quelle già in cima: con due voci contigue selezionate in cima alla lista la prima resta e la seconda sale davanti a lei (`MoveDownExecute` fa lo stesso in fondo) | Le due voci si scambiano invece di restare ferme; l'ordine che l'utente voleva si inverte |
| DIV-COL-2 🟡 (dedotta) | `ListBoxDragDrop` sposta le voci selezionate all'indice restituito da `itemAtPos(punto, True)`, che è -1 se si rilascia fuori da una voce | Rilasciare nello spazio vuoto della lista imposta `Index` a -1: errore invece di non fare niente |
| DIV-COL-3 🟢 (dedotta) | `AssignColumnsToProps` assegna a ogni colonna `Index := i`, dove `i` è la posizione nella lista, ma la lista salta le colonne senza campo nel dataset | Se il dizionario ha colonne senza campo, le posizioni scritte non corrispondono a quelle della griglia |
| DIV-COL-4 🟢 (dedotta) | La ricerca della finestra cerca nel testo delle voci (titolo della colonna, dal Mantis 977) ma l'elenco dei suggerimenti si riempie con `Field.DisplayLabel` | Il suggerimento proposto può non essere trovato fra le voci, se il titolo della colonna è stato cambiato |
| DIV-COL-5 🟢 (dedotta) | `CreateColumns`, `CheckColumnWidths` e `AllargaColonneAlContenuto` escono con `Exit` dopo `SiMain.EnterMethod` senza `LeaveMethod` | Il registro SmartInspect perde l'allineamento dei livelli, solo in diagnostica |

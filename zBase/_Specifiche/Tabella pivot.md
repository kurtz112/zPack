---
area: Tabella pivot
progetto: zBase
aggiornato: 2026-11-02
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/007
---

# Tabella pivot

Questa specifica descrive il componente `TzDbPivot`, il frame che mostra un dataset come tabella pivot DevExpress (`TcxDBPivotGrid`), e le impostazioni che il dizionario LZ conserva per ogni pivot. Il codice del frame è in `zBase\zDbPivot.pas` (con `zDbPivot.dfm`); le impostazioni (`TzDbPivotProps`, `TzDbPivotFlags`, `TzPivotField`, `TzPivotFields`) stanno in `zBase\zSystem.pas`, e il loro formato su disco è quello comune delle collezioni (`ZBASE-COL-007`, `ZBASE-COL-010`, `ZBASE-COL-011`). Non copre la disposizione dei controlli, né l'editor delle proprietà del pivot (`zz.base.editor.DbPivot.pas`), né l'archivio LZ in sé (`ZBASE-COL-015`, `ZBASE-AVV-006`). La unit è compilata: `zBaseRegister.pas` la include e registra il componente nel pacchetto `zBase` di tutte le versioni di Delphi.

Lo usano Gesty (`frmAnalisiRilevamenti`, `frmAssistenzaScolastica`, `frmAS_Rendicontazione`, `frmBudget`, `frmQuestionari`; nel dizionario `Gesty_Group\LZ\TzDbPivots.dfm` ci sono 707 righe di nome) e WinTarif (`frmGera_RendicontazioniVerifica`; `Wintarif_Group\LZ\TzDbPivots.dfm`). Le form lo trovano con `TBaseForm.GetPivot(NomeDataSet, PivotID)`, e `Init_Controls` gli assegna `zSystem` e l'elenco delle immagini delle azioni. Nessun pivot dei dizionari attuali usa campi calcolati (`Kind = fkCalc`) né il drill-down (`DrillDown`): sono funzioni previste dal codice e dall'editor, non ancora usate.

**Come funziona.** Il pivot lavora su un `TzFbDataSet` (`zDataSet`) e su un `TzSystem` (`zSystem`); quando ha entrambi (`InitPivot`) carica le impostazioni dal dizionario, crea i campi della griglia dal dataset e li configura. Le impostazioni di un pivot sono un elemento della collezione `zDbPivots` del dizionario LZ, che vale per **tutti** gli utenti: il pivot non ha un layout personale per utente (a differenza di `TzDbView`, `ZDBVIEW-LAY-001`). Chi può salvare nel dizionario è solo l'amministratore. Il pivot DevExpress resta di proprietà della griglia: le impostazioni sono la fotografia che si riapplica a ogni apertura.

**Test che coprono quest'area.** `Test.zDbPivot` (nessun database e nessuna interfaccia) prova i valori predefiniti e la copia (`Assign`) di `TzDbPivotFlags`, `TzPivotField` e `TzDbPivotProps`, le notifiche dei flag, la scrittura e la lettura in formato JSON dell'elenco dei campi e dei pivot (valori predefiniti omessi, `Kind`, elenchi di valori). Provano anche che `DrillDown` viene copiato (DIV-PVT-1, corretta nel rilascio 007) e che il reset dei campi conserva i soli campi calcolati (DIV-PVT-2, rilascio 008). Restano senza prova, perché richiedono la griglia DevExpress, i dialoghi o un `TzFbDataSet` aperto: creazione dei campi, ricalcolo dei totali, campi calcolati, larghezze, filtri rapidi, esportazione, drill-down.

## ZBASE-PVT-001 Collegamento al dataset e al sistema
Il pivot si prepara quando ha sia `zSystem` sia un dataset valido (`InitPivot`, richiamata da `SetzSystem` e da `SetzDataSet`: l'ordine in cui si assegnano non conta). `SetzDataSet` imposta il dataset del controllore dati (`DataController`) e collega il `DataSource` interno al dataset **dentro** `InitPivot`, dopo `BeginUpdate` della griglia, così il pivot non ricalcola a ogni passo. `InitPivot` non fa niente se la griglia ha già dei campi: riassegnare il dataset a un pivot già costruito non lo ricostruisce (lo fa solo `actSQL` dopo la modifica della query, con `DestroyFields`, riapertura e `InitPivot`). Dopo la creazione dei campi la chiave del dataset di dati della griglia (`KeyFieldNames`) diventa la chiave primaria del dataset: serve a `GetCrossCellKeys` (ZBASE-PVT-016). Il dataset si apre con `ActivateDataSet` solo se il controllore dati ha `AutoOpen`. Se `zSystem` manca la `Notification` lo azzera e il pivot resta vuoto.

### Scenario: sistema assegnato dopo il dataset
- **Dato** un pivot con `zDataSet` già assegnato e `zSystem` nullo
- **Quando** si assegna `zSystem`
- **Allora** il pivot carica le impostazioni e crea i suoi campi

### Scenario: dataset assegnato una seconda volta
- **Dato** un pivot con campi già creati
- **Quando** si riassegna `zDataSet`
- **Allora** i campi esistenti restano com'erano

## ZBASE-PVT-002 Identificativo del pivot (`PivotID`) e titolo
`PivotID` è il nome dell'elemento delle impostazioni (`zDbPivotProps.Name`); se è vuoto vale l'identificativo del dataset (`DataController.IdDataSet`, nella forma `NomeModuloDati.NomeDataSet`) e viene memorizzato. Una form con due pivot sullo stesso dataset dà quindi a uno dei due un `PivotID` esplicito (`SetPivotID`, o la proprietà `ID` dell'interfaccia). Il titolo mostrato (`GetTitle`) è, in ordine: il testo dell'etichetta del titolo, il `Title` delle impostazioni, il nome del componente senza la prima occorrenza di «pivot». L'etichetta è visibile solo se contiene del testo e solo con il flag `Toolbar`. Il titolo si modifica dal menu del pivot (solo amministratore) e a ogni digitazione salva le impostazioni.

### Scenario: nome del pivot non dato
- **Dato** un pivot sul dataset `AnalisiRilevamenti.Timesheet` senza nome
- **Quando** si chiede `PivotID`
- **Allora** vale `AnalisiRilevamenti.Timesheet`

## ZBASE-PVT-003 Impostazioni nel dizionario e lettura
`TzDbPivotProps` (un elemento di `zDbPivots`, tipo `ctPivot`) contiene: `Name`, `DataSet` (identificativo del dataset), `Title`, `Caption` (predefinita `@`, come le schede), `BestFitAfterExpand` (predefinito vero), `Flags` (ZBASE-PVT-013), `Fields` (ZBASE-PVT-006), `ToolFilters` (filtri della barra, SQL), `ToolActions` (azioni della barra), `ActionOwnerName`, `Description`. `LoadFromBase` cerca nel dizionario l'elemento con lo stesso nome e **copia** il suo contenuto (`Assign`) nelle impostazioni del pivot; se non c'è, lo crea nel dizionario **in memoria** con i valori attuali (`SaveToBase(False)`), senza scrivere il file `.LZ`. Se l'applicazione ha assegnato `OnCustomLoadProps` si chiama quello al posto del dizionario. Dopo la lettura i campi sono allineati al dataset (ZBASE-PVT-006) e applicati alla griglia (ZBASE-PVT-007). Se manca il nome o il dataset non è valido non si legge niente.

### Scenario: primo uso di un pivot nuovo
- **Dato** un pivot il cui nome non è nel dizionario
- **Quando** si apre per la prima volta
- **Allora** nel dizionario in memoria compare un elemento con quel nome e i campi del dataset

## ZBASE-PVT-004 Salvataggio e amministratore
`doSalvaImpostazioni` riporta la griglia nelle impostazioni (ZBASE-PVT-007), completa nome e dataset se mancano e le consegna al dizionario in memoria (`SaveToBase(False)`, sincrono, senza thread). La scrittura del file `.LZ` (`SaveZip(csDbPivots, ...)`) è **rimandata e unica**: si accoda un messaggio interno, e più salvataggi ravvicinati (per esempio la digitazione del titolo) producono una sola scrittura; un messaggio rimasto in coda alla distruzione del frame viene eseguito dal distruttore. `SaveZip` scrive solo se c'è un utente collegato, il dizionario è caricato e l'utente è amministratore (se il file esiste già): per un utente normale i cambiamenti restano in memoria e **si perdono alla chiusura del programma**. Il pivot non scrive nessun file personale: il nome `.pivot` mostrato da «Nome file ini» (`IniFileName`, cartella personale) non viene mai né scritto né letto. Se l'applicazione ha assegnato `OnCustomSaveProps` si chiama quello al posto del dizionario. Il salvataggio parte da: titolo modificato, comando «Salva impostazioni» (con finestra di attesa), «Personalizza» confermato, ricostruzione di azioni o filtri, e al primo caricamento se tutte le larghezze sono ancora quella di partenza (ZBASE-PVT-015). Il comando «Carica impostazioni» ricarica quelle del dizionario dopo conferma.

### Scenario: utente normale
- **Dato** un utente non amministratore che sposta un campo
- **Quando** il programma si chiude
- **Allora** il file `.LZ` non è stato modificato

## ZBASE-PVT-005 Formato di scrittura e valori predefiniti
Le impostazioni si scrivono come ogni collezione (ZBASE-COL-007 e ZBASE-COL-010): in `TzDbPivots.dfm` (o nel JSON) compare, per ogni campo, solo ciò che si discosta dai valori predefiniti. Valori predefiniti di un `TzPivotField`: `Area` = `faFilter`, `AreaIndex` = -1, `DataVisibility` = `dvAllCells`, `GroupIndex` = -1, `Hidden` falso, `MinWidth` = `cxPivotGridDefaultFieldMinWidth`, `SummaryType` = `stSum`, `SortOrder` = `soNone`, `SummaryVariation` = `svNone`, `TotalsVisibility` = `tvAutomatic`, `TopValueCount` 0, `TopValueShowOthers` falso, `Sizeable` vero, `Visible` vero, `MaxWidth` 0, `Width` -1, `TotalMode` = `ctmNull`, `zCtrlType` = `ctDefault`, didascalia e formato vuoti, elenchi vuoti. Il tipo di campo `Kind` (`fkField` o `fkCalc`) non è una proprietà pubblicata: si scrive solo se vale `fkCalc`, con lo stesso nome `Kind`, sia nel DFM (`DefineProperties`) sia nel JSON (`WriteJsonExtraProperties`, `ReadJsonExtraProperty`, e voce `enum` nello schema). Con un nome di enumerato sconosciuto il valore resta `fkField`. `Description` e `ToolActions` si scrivono solo se non vuoti. Un campo che sparisce dal dataset sparisce dalle impostazioni al primo allineamento (ZBASE-PVT-006), non dal file finché non si salva.

### Scenario: campo con soli valori predefiniti
- **Dato** un campo che ha solo il nome
- **Quando** si scrive in JSON
- **Allora** l'oggetto contiene solo `Name`

### Scenario: campo calcolato
- **Dato** un campo con `Kind = fkCalc`
- **Quando** si scrive in JSON e si rilegge
- **Allora** il campo riletto è ancora `fkCalc`

## ZBASE-PVT-006 Elenco dei campi allineato al dataset (`ValidateDataset`)
Prima di ogni uso (all'apertura, dopo «Personalizza», prima di creare i campi) `TzPivotFields.ValidateDataset` allinea l'elenco al dataset: 1) azzera il dominio di ogni voce e **toglie** le voci `fkField` che il dataset non ha più (confronto sul nome del campo); i campi calcolati restano; 2) aggiunge in coda i campi del dataset che l'elenco non ha, con `FieldOrigin` (origine del campo nel database), il dominio del dizionario dei dati, didascalia vuota, larghezza -1; 3) un campo nuovo è **visibile** solo se è visibile nel dataset **e** l'elenco non conteneva ancora nessun campo `fkField` (primo uso); non lo è mai se è un parametro di dettaglio del dataset, né se è un campo di tracciatura (`USER_INS`, `DATA_INS`, `USER_MDF`, `DATA_MDF`, `SYSDBA_DATA_MDF`, `USR_USER_INS`, `USR_DATA_INS`, `USR_USER_MDF`, `USR_DATA_MDF`, `USR_DATA_DBA`). Quindi un campo aggiunto al dataset dopo il primo salvataggio compare nell'elenco come non visibile, e va portato nel pivot con la personalizzazione. `Reset` svuota l'elenco e lo ricostruisce con le stesse regole.

### Scenario: nuovo campo del dataset dopo il primo salvataggio
- **Dato** un pivot già salvato e un campo `NOTE` aggiunto alla SELECT
- **Quando** il pivot si riapre
- **Allora** `NOTE` è nell'elenco con `Visible` falso

## ZBASE-PVT-007 Dalla griglia alle impostazioni e ritorno
`AssignFromPivotFields` (usata dal salvataggio e da «Personalizza») riscrive l'elenco partendo dalla griglia: per ogni campo non calcolato copia nome (campo del dataset), didascalia **attuale** (se coincide con quella del dominio la lascia vuota, cioè ereditata: così un cambio nel dizionario dei dati arriva ai pivot già salvati), posizione, larghezza, visibilità, `Area`, `AreaIndex`, `DataVisibility`, `DisplayFormat`, `GroupIndex`, `Hidden`, `MinWidth`, `SummaryType`, `SortOrder`, `SummaryVariation`, `TotalsVisibility`, `TopValueCount`, `TopValueShowOthers`. Quello che la griglia non conosce si ripristina da una copia dell'elenco precedente, per nome: `MaxWidth`, `Sizeable`, `zCtrlType`, `GrandTotalExcludeValues`. I campi calcolati (`Kind = fkCalc`, riconosciuti nella griglia dalla `Tag` 999, `zCalcFieldTag`) non si leggono dalla griglia: si reinseriscono tali e quali dalla copia, con l'`AreaIndex` che `PivotLayoutChanged` ha già aggiornato (ZBASE-PVT-011). `AssignToPivotFields` fa il percorso inverso su un campo esistente, trovato per nome del campo senza distinzione di maiuscole; salta i calcolati e i campi non presenti nella griglia; applica la didascalia solo se non è vuota; la larghezza -1 diventa 100; se il campo usa un editor numerico (`TcxSpinEditProperties`) copia anche il formato nelle sue proprietà; tutto dentro `BeginUpdate`/`EndUpdate`. Con elenco vuoto non fa niente.

### Scenario: parametro che la griglia non conosce
- **Dato** un campo con `GrandTotalExcludeValues = ['Ore Dirette Totali']`
- **Quando** si salva il layout
- **Allora** l'elenco delle esclusioni resta quello di prima

## ZBASE-PVT-008 Creazione dei campi della griglia (`CreateFields`)
Si richiama all'apertura e dopo «Personalizza colonna»: chiama `OnBeforeCreateControls`, azzera i campi calcolati e i tetti di larghezza, cancella tutti i campi della griglia e li ricrea dal dataset (`CreateAllFields`), allinea e applica le impostazioni (ZBASE-PVT-006 e 007), poi per ogni voce delle impostazioni che ha un campo corrispondente nella griglia e nel dataset: la didascalia è quella delle impostazioni, se vuota quella del dominio del dizionario dei dati (`DisplayLabel`); il tipo di controllo è quello delle impostazioni, se `ctDefault` quello del dominio; **un tipo «lookup» (`IsLookup`) diventa sempre `ctEdit`**, perché il pivot mostra il valore del campo e non la ricerca; la classe e le proprietà dell'editor vengono dal tipo (`dx.GetPropertiesClass`, `dx.InitProperties`): per questo una picklist mostra la descrizione e non il codice. Poi imposta le proprietà del campo (ZBASE-PVT-009), ricorda il tetto `MaxWidth` per le larghezze (ZBASE-PVT-015), attiva la casella di ricerca nella tendina dei filtri di ogni campo, chiama `OnAfterCreateControls` e infine crea i campi calcolati (ZBASE-PVT-011). Una voce senza campo nel dataset si salta.

### Scenario: campo con picklist
- **Dato** un campo con tipo `ctPickList` e valori codificati
- **Quando** si crea il campo
- **Allora** la cella mostra la descrizione del valore e non il codice

## ZBASE-PVT-009 Funzioni di riepilogo e formati numerici
Ogni campo ha il suo `SummaryType` (predefinito `stSum`: somma), applicato com'è alla griglia; con `SummaryVariation` si ottengono variazioni; `TotalsVisibility` e `DataVisibility` decidono dove compaiono i totali e i valori; `TopValueCount` e `TopValueShowOthers` limitano ai primi valori; `SortOrder` ordina i valori del campo. Un campo con `GrandTotalExcludeValues` non vuoto passa a `stCustom` (ZBASE-PVT-010); un `stCustom` rimasto **senza gestore** (lista svuotata) torna a `stSum`, altrimenti la colonna resterebbe vuota. Quando un campo numerico non ha un formato proprio valgono i predefiniti di DevExpress che la unit imposta **a livello di processo** all'avvio: decimali `###,##0.00`, interi `###,##0` (`cxPivotGridDefaultFieldFloatFormat`, `cxPivotGridDefaultFieldIntFormat`); per un formato diverso serve un campo con tipo `ctSpin` e il `DisplayFormat`. I valori **negativi** delle celle dati si disegnano con lo stile rosso (`cxStyleRed`). Prefiltro e filtri di campo non distinguono maiuscole e minuscole, e il prefiltro scrive «inizia per», non `LIKE`.

### Scenario: cella negativa
- **Dato** una cella dati numerica con valore -12,5
- **Quando** la cella si disegna
- **Allora** usa lo stile rosso

## ZBASE-PVT-010 Esclusioni dal totale generale (`GrandTotalExcludeValues`)
Per un campo dati, `GrandTotalExcludeValues` elenca i valori del gruppo di **colonna** da non sommare nel totale generale di riga: serve quando una colonna è già un totale derivato (Gesty: «Ore Dirette Totali» per `ORE_TOTALI` e `COSTO_TOTALE`). `SetGrandTotalExclusions(NomeCampo, [...])` scrive la lista nelle impostazioni e, se il campo esiste già nella griglia, lo applica subito (`stCustom` con il gestore condiviso `GrandTotalExcludeSummary`); con lista vuota toglie il gestore e torna a `stSum`; un nome non presente nelle impostazioni si registra come avviso e non cambia niente. Il gestore calcola la cella normale (e il totale generale di riga) come la somma, e il totale generale di **colonna** come la somma delle sole celle i cui valori di colonna non sono nella lista. Il confronto è sul valore del gruppo convertito in testo (`VarToStr`, valore grezzo, non il testo visualizzato) e distingue maiuscole e minuscole. Le liste scritte da codice finiscono nelle impostazioni e quindi, con il salvataggio dell'amministratore, nel dizionario.

### Scenario: colonna totale derivata
- **Dato** `ORE_TOTALI` con esclusione `Ore Dirette Totali` e una riga con 10 nella colonna `Ore Dirette Totali`, 4 e 6 nelle altre
- **Quando** si calcola il totale generale di colonna della riga
- **Allora** vale 10 e non 20

## ZBASE-PVT-011 Campi calcolati
Una voce con `Kind = fkCalc`, `Name`, `SourceFieldName` (campo sorgente, già presente con somma) e `ColumnFieldName` crea un campo dati in più (`Tag` 999, area `faData`) con `SummaryType = stCustom`. Il suo valore su una riga è la **somma** dei valori del campo sorgente nelle sole colonne del campo `ColumnFieldName` il cui valore (in testo, `VarToStr`) è in `ColumnValues`. Sulle righe di totale vale `TotalMode`: `ctmNull` (predefinito) cella vuota, `ctmZero` zero, `ctmCalc` calcolo normale. Il formato è `DisplayFormat` della voce, altrimenti quello del campo sorgente. Una voce senza nome, sorgente o campo colonna, o con sorgente inesistente, si salta. I gruppi di colonna si tengono in una cache per campo, invalidata a ogni cambio di layout (`OnLayoutChanged`); lo stesso evento riporta nell'impostazione l'`AreaIndex` del campo calcolato, spostato con il trascinamento. Le celle senza valore (nulle o vuote) **non si sommano e non azzerano il risultato**: contano come zero.

### Scenario: tre colonne, due nell'elenco
- **Dato** un campo calcolato con `ColumnValues = ['D', 'M']` e una riga con D = 3, M = 2, X = 5
- **Quando** si calcola la riga
- **Allora** vale 5

## ZBASE-PVT-012 Valori nulli e vuoti
Nel pivot un valore nullo o vuoto **non è mai un'etichetta da filtrare né un valore da sommare**: `GetGroupItemValue` restituisce `Null` se il gruppo o il campo non esistono; la ricerca testuale (ZBASE-PVT-017) salta i valori nulli o vuoti; la somma delle celle dei campi calcolati li ignora; con `Value = Null` la finestra del filtro rapido vuol dire «togli la condizione» e non «uguale a nullo»; un elenco di valori da includere che risultasse vuoto non si applica, perché per DevExpress vuol dire «nessun filtro». Il testo di una cella con valore nullo è quello che DevExpress mostra per il valore mancante; i totali (`TotalsForSingleValues`, `GrandTotalsForSingleValues`) seguono i flag di ZBASE-PVT-013.

### Scenario: gruppo senza campo
- **Dato** un gruppo di righe e un nome di campo che non c'è nel pivot
- **Quando** si chiama `GetGroupItemValue`
- **Allora** il risultato è `Null`

## ZBASE-PVT-013 Flags del pivot
`TzDbPivotFlags` raccoglie le opzioni, tutte applicate alla griglia da `LoadProperties` (all'apertura, dopo «Personalizza» e a ogni `RebuildToolbar`). Predefiniti: **veri** `ButtonArrows`, `ButtonRefresh`, `ButtonExpand`, `Toolbar`, `DrawExpandButtons`, `ColumnGrandTotals`, `ColumnTotals`, `FilterSeparator`, `RowGrandTotals`, `RowTotals`; **falsi** `ButtonExpandCaption`, `Params`, `Filter`, `DrillDown`, `ExpandRows`, `ExpandColumns`, `ExpandInnerLevels`, `HideColumnFields`, `HideDataFields`, `HideFilterFields`, `HideRowFields`, `GrandTotalsForSingleValues`, `MarkNarrowCells`, `RowTreeLayout`, `TotalsForSingleValues`; testi dei totali generali (`ColumnGrandTotalText`, `RowGrandTotalText`) vuoti. Effetti: `Hide*` nasconde l'area dei campi (opzioni `ColumnFields`, `DataFields`, `FilterFields`, `RowFields` della griglia); `Filter` rende il prefiltro sempre visibile (altrimenti solo se non vuoto); `RowTreeLayout` mette tutti i campi riga in una colonna sola ad albero (`rtlTree`), altrimenti `rtlFar`; `ButtonExpand` mostra Espandi e Riduci, `ButtonExpandCaption` la loro scritta; `Params` mostra «Elabora» (finestra dei parametri del dataset); `Toolbar` mostra la barra e il titolo. Ogni modifica con il setter chiama `OnChange`, salvo dentro `BeginUpdate`/`EndUpdate`; `EndUpdate` **non** notifica. `Assign` copia tutti i flag **tranne `DrillDown`** (DIV-PVT-1).

### Scenario: setter
- **Dato** un gestore di `OnChange`
- **Quando** si imposta `ButtonArrows := False`
- **Allora** il gestore viene chiamato una volta

### Scenario: aggiornamento a blocchi
- **Dato** un `BeginUpdate` e tre modifiche
- **Quando** si chiama `EndUpdate`
- **Allora** il gestore non è stato chiamato

## ZBASE-PVT-014 Espandi, Riduci e livelli interni
`FullExpand` apre tutti i gruppi e **rimette** i flag di apertura automatica della griglia (`ExpandRows`, `ExpandColumns`) come da impostazioni; `FullCollapse` li **spegne**, perché con quei flag attivi DevExpress considera aperto ogni gruppo con figli e `CollapseAll` non cambierebbe niente, poi chiude tutti i gruppi. Entrambe finiscono con l'adattamento delle larghezze (ZBASE-PVT-015). Con `ExpandInnerLevels` aprendo un gruppo del primo livello di riga si aprono da soli tutti i livelli sotto (campi riga visibili con `AreaIndex` maggiore di 0), e se `BestFitAfterExpand` è vero si adattano le larghezze; senza il flag, con `BestFitAfterExpand` vero, ogni clic su un pulsante di espansione adatta le larghezze. L'interruttore `ButtonExpand` falso nasconde i due comandi: serve ai pivot che non devono ridursi mai.

### Scenario: Riduci dopo l'apertura automatica
- **Dato** un pivot con `ExpandRows` vero
- **Quando** l'utente sceglie Riduci
- **Allora** i gruppi si chiudono e il flag automatico della griglia resta spento fino al prossimo Espandi o ricaricamento delle impostazioni

## ZBASE-PVT-015 Larghezze dei campi
`ApplyBestFit` (comando «Incolonna», con finestra di attesa; non fa niente a dataset chiuso) esegue in ordine: `ApplyBestFit` della griglia, l'allargamento dei campi riga al testo come viene disegnato (picklist con descrizione e immagine, spazio del pulsante di espansione), l'allargamento sulle celle effettivamente visibili (la larghezza mancante si somma al campo), poi il tetto: nessun campo supera il suo `MaxWidth` se questo è maggiore di zero. I campi riga si allargano, non si stringono mai; nel layout ad albero (`rtlTree`) e con zero righe i due allargamenti non fanno niente. A ogni apertura o ricarica dei dati (collegamento al `DataSource`, non lo scorrimento) si accoda un solo messaggio di adattamento, eseguito dopo che la griglia ha ricalcolato le celle: se il frame non ha ancora la finestra l'adattamento aspetta la prima visualizzazione. Oltre **5000 celle** (righe per colonne del pivot espanso) l'adattamento automatico si salta e si lascia «Incolonna» all'utente. Le larghezze dipendono dai valori del momento: si ricalcolano a ogni caricamento, e i ritocchi manuali valgono fino alla ricarica. All'apertura, se **tutti** i campi hanno ancora la larghezza 50 (quella di `CreateAllFields`), si adatta e si salva.

### Scenario: pivot grande
- **Dato** un pivot espanso di 100 righe per 80 colonne
- **Quando** i dati si ricaricano
- **Allora** le larghezze non vengono ricalcolate in automatico

## ZBASE-PVT-016 Doppio clic, drill-down e chiavi
`OnCellDblClick(Sender, CrossCell, var Handled)` scatta sul doppio clic di una cella dati, `OnGroupHeaderDblClick(Sender, GroupItem, var Handled)` su un'intestazione di riga o colonna (distinguibili da `GroupItem.Field.Area`); `CrossCell` vale solo durante la chiamata. Con `Handled` vero si interrompe tutto; altrimenti, su una cella dati e con il flag `DrillDown`, `ShowDrillDown` apre una finestra modale «`<titolo>` - Dettaglio (N record)» con una griglia di sola lettura che ha **una colonna per ogni campo del pivot, nello stesso ordine** (il collegamento è per posizione), con didascalia, visibilità e stato nascosto del campo. Per l'intestazione di gruppo `Handled` oggi non cambia niente. `GetGroupItemValue(Gruppo, NomeCampo)` legge il valore di un campo (anche nascosto, come un identificativo) sul record rappresentativo del gruppo; `GetCrossCellKeys(Cella)` restituisce i valori delle chiavi primarie (`KeyFieldNames`, ZBASE-PVT-001) dei record sottostanti una cella, o un elenco vuoto per cella nulla. Gesty la usa in `frmBudget` per aprire la scheda del progetto dal doppio clic.

### Scenario: doppio clic gestito
- **Dato** un gestore di `OnCellDblClick` che imposta `Handled := True` e il flag `DrillDown` vero
- **Quando** si fa doppio clic su una cella dati
- **Allora** il drill-down standard non si apre

## ZBASE-PVT-017 Filtri rapidi in memoria
Agiscono sui dati già caricati, non rileggono il database e **non toccano** i filtri della barra (`ToolFilters`, filtri SQL). Sono disponibili solo con dataset valido e attivo e almeno un campo. **F3** («Filtro per valore») agisce sempre sul campo di riga **più interno** (il visibile dell'area righe con `AreaIndex` più alto), qualunque sia la riga con il fuoco; propone il valore della riga solo se la riga è proprio di quel campo, non per il totale generale. La finestra è quella di `zDbView` (`ChiediFiltroPerValore`) ma tratta i numeri come testo: «3» deve trovare anche 30 e 3/S. Regola dell'asterisco: testo = «inizia per», testo seguito da `*` = «contiene», vuoto = toglie la condizione. «Inizia per» e «contiene» non passano dal prefiltro: si confrontano senza distinzione di maiuscole i valori distinti del campo (con `AnsiUpperCase`) e si spuntano nella tendina del campo (`ftIncluded`) quelli che corrispondono; se nessuno corrisponde si avvisa e non si cambia nulla. Uguaglianze (date, elenchi di scelta) e rimozione passano dal prefiltro (`DataController.Filter`), che si riattiva se l'utente l'aveva spento; una nuova condizione sullo stesso campo sostituisce la precedente e toglie le spunte del campo. **Solo questo valore** lascia solo il valore (spunta `ftIncluded`); **Escludi questo valore** lo toglie (`ftExcluded`): con spunte già «solo questi» lo toglie dall'elenco, e se è l'ultimo avvisa e non fa niente (un elenco vuoto vorrebbe dire «nessun filtro»). Dopo ogni filtro i livelli esterni dello stesso asse si aprono, e il fuoco va al primo valore rimasto. **F4** apre la finestra del prefiltro; **Ctrl+Backspace** toglie prefiltro e spunte di tutti i campi. Le voci del menu «Solo» ed «Escludi» compaiono solo se sotto il mouse c'è un valore.

### Scenario: ricerca per inizio
- **Dato** i valori `LUDOPATIA` e `LUDO PARCO` del campo riga più interno
- **Quando** l'utente inserisce `ludo` con F3
- **Allora** restano entrambi, spuntati nella tendina del campo

### Scenario: ultimo valore
- **Dato** un campo con la sola spunta «solo» su `ROMA`
- **Quando** l'utente sceglie «Escludi questo valore» su `ROMA`
- **Allora** compare un avviso e il filtro non cambia

## ZBASE-PVT-018 Esportazione in Excel
Il comando «Excel» apre la finestra di salvataggio, con cartella iniziale la cartella personale, e offre quattro formati, scelti dal filtro del file: 1) «Excel» `.xlsx` completo (`cxExportPivotGridToXLSX`: formattazione e totali come a video); 2) «Excel (solo dati)» `.xlsx` (`cxExportPivotGridDataToExcel`: dati in struttura semplificata, senza stili); 3) «Excel 97» `.xls` completo (`cxExportPivotGridToExcel`); 4) «Excel 97 (solo dati)» `.xls` (`cxExportPivotGridDataToExcel`, la stessa chiamata della 2: cambia solo il nome del file). Esporta ciò che il pivot ha in memoria, cioè i dati **come filtrati e raggruppati a video**, non i record del dataset. A esportazione finita si apre la cartella del file in Esplora risorse; se l'esportazione solleva un errore non si apre niente.

### Scenario: formato completo
- **Dato** il filtro «Excel» e il nome `Rendiconto.xlsx`
- **Quando** l'utente conferma
- **Allora** si scrive un file con la formattazione del pivot e si apre la sua cartella

## ZBASE-PVT-019 Comandi per l'amministratore
Solo l'amministratore (`zSystem.IsAdmin`) vede e può usare: mostra e copia la query (`DataController.GetDebugInfo`), «Salva impostazioni», «Carica impostazioni», «Reset colonne» (toglie dall'elenco i campi del dataset, tiene i calcolati, li riapplica alla griglia e salva; le didascalie già scritte nella griglia non cambiano), «SQL» (modifica la query del dataset: dopo la conferma il pivot si ricrea da zero), «Personalizza» (editor delle proprietà dell'intero pivot: campi, flag, titolo, azioni, filtri), «Personalizza colonna» (modifica del dominio del campo selezionato nel dizionario dei dati, con salvataggio di `csFieldProps` e ricreazione dei campi), «Copia PivotID», «Tools...» (configurazione di azioni e filtri della barra), e il menu delle impostazioni con il campo del titolo. Il menu del pivot dalla barra si apre solo per l'amministratore. La barra mostra prima i filtri e poi le azioni (`RebuildToolbar`); ogni ricostruzione di azioni o filtri salva le impostazioni.

### Scenario: utente normale
- **Dato** un utente non amministratore
- **Quando** apre il menu del pivot
- **Allora** non vede «SQL», «Personalizza» né «Salva impostazioni»

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato o contraddice un commento. Non sono stati corretti né giudicati difetti: si decidono nella voce R-213 di `Attivita Rinviate.md` (numero assegnato dalla sessione principale); quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-PVT-4 🟡 (dedotta) | `CreateFields` assegna `PivotField.Width := zPivotFld.Width` subito dopo `AssignToPivotFields`, che per la larghezza -1 aveva usato 100; per un campo nuovo vale quindi -1 | L'effetto dipende dal limite minimo di DevExpress (da verificare con la griglia): un campo nuovo può nascere con la larghezza minima invece di 100, e `CheckFieldWidths` (che cerca la larghezza 50) può non scattare |
| DIV-PVT-6 🟢 (dedotta) | Il commento di `GrandTotalExcludeValues` in `zSystem.pas` dice che il confronto è sul valore **visualizzato** della colonna; il codice confronta `VarToStr(Child.Value)`, cioè il valore grezzo del gruppo | Per una colonna il cui valore differisce dal testo mostrato (picklist, formato) la lista va scritta con il valore grezzo e non con la dicitura che si vede, al contrario di quanto dice il commento: chi configura l'esclusione sul testo a video non ottiene l'effetto voluto |
| DIV-PVT-7 🟢 (dedotta) | `ClearIniSectionAllUsersExecute` ha il corpo vuoto (la riga è commentata), «Nome file ini» mostra un file `.pivot` mai scritto, `ActionListUpdate` e `OnFlagChange` sono vuoti o mai collegati (`Flags.OnChange` non è assegnato da nessuno) | Comandi dell'amministratore che non fanno niente o riferiti a un meccanismo (layout personale in file) che non esiste: confondono, e un cambio di flag fatto da codice non aggiorna da solo barra e azioni |
| DIV-PVT-8 🟢 (dedotta) | `CreateFields` ha un `case zCtrlType of` con tutti i rami vuoti (codice morto) | Nessuna conseguenza oggi; fa credere che esistano regole per tipo di controllo |
| DIV-PVT-9 🟢 (dedotta) | `SaveDescription` scrive nel file `.descriptions` solo `Align`, `Size` e `Visible`; il testo della descrizione resta nelle impostazioni e va al dizionario solo al salvataggio successivo | Un testo modificato e non seguito da un altro salvataggio dell'amministratore (o da un utente normale) si perde alla chiusura |
| DIV-PVT-10 🟢 (dedotta) | La finestra di esportazione ha `Dialog.DefaultExt = '*.xls'` (con l'asterisco) mentre il primo formato è `.xlsx`; dopo l'esportazione si apre la cartella anche se il formato scelto non è fra i quattro previsti | Un nome di file scritto senza estensione può prendere un'estensione sbagliata; nessun danno ai dati |
| DIV-PVT-11 🟢 (dedotta) | `CalcFieldCustomSummary` cerca la riga del `CrossCell` scorrendo **tutte** le righe a ogni cella; con celle senza valore somma zero invece di restare vuota | Con molti campi calcolati e molte righe i ricalcoli rallentano; una riga priva di dati mostra 0 e non una cella vuota |
| DIV-PVT-12 🟢 (dedotta) | Per l'utente normale il pivot non ha layout personale: larghezze, ordine e area dei campi cambiati a mano si perdono alla chiusura (ZBASE-PVT-004), diversamente da `TzDbView` (`ZDBVIEW-LAY-001`) | Differenza di comportamento fra viste e pivot da confermare come voluta |

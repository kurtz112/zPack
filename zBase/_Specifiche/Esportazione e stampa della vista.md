---
area: Esportazione e stampa della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbview/001
---

# Esportazione e stampa della vista

Questa specifica descrive l'esportazione dei dati di una `TzDbView` (Excel, CSV, finestra di esportazione generica) e la stampa rapida dell'elenco. Il codice è in `zBase\zDbView.Export.pas` (`ExportView2Excel`, `ExportView`, `ExportViewExcel2007Data`, `ExportViewExcel2007Full`, `ExportViewExcel97Data`, `ExportViewExcel97Full`, `ExportViewCSV`) e `zDbView.Print.pas` (`Print_zDbView`); le chiamano `ExcelExecute`, `EsportaExecute` e `actStampaExecute` di `zDbView.pas`. Lo usano tutte le viste di WT e Gesty. Non copre le stampe documentali (`zOffice`).

**Come funziona.** Esistono due famiglie di esportazione. Quella «completa» (`...Full`) la fa la griglia DevExpress (`ExportGridToXLSX`, `ExportGridToExcel`): riporta formattazione, raggruppamenti, colori, ma solo ciò che la griglia ha in memoria. Quella «solo dati» (`...Data`, CSV, `ExportView`) la fa la libreria QExport4 direttamente dal dataset, con una riga per record e le sole colonne visibili: riporta tutti i record del filtro, senza formattazione. La stampa rapida costruisce al volo un rapporto FastReport con le colonne visibili.

**Test che coprono quest'area.** Nessuna: tutto richiede griglia, finestre di dialogo o librerie di terzi.

## ZDBVIEW-ESP-001 Scelta del formato e del file
`ExportView2Excel` apre la finestra «Salva con nome» con cinque tipi (`InitExcelExportDialog`, nell'ordine: XLSX solo dati, XLSX completo, XLS completo, XLS solo dati, CSV), cartella iniziale la cartella personale dell'utente, richiesta di conferma se il file esiste, percorso obbligatoriamente esistente e file non di sola lettura. L'esportazione scrive prima in un **file temporaneo** (per i terminal server) e poi lo copia sul nome scelto, sostituendo l'eventuale file esistente; il temporaneo si cancella sempre. Alla fine chiede se aprire il file generato.

### Scenario: file esistente
- **Dato** un file con lo stesso nome nella cartella scelta
- **Quando** l'utente conferma la sostituzione ed esporta
- **Allora** il file vecchio viene sostituito dal nuovo e il temporaneo sparisce

## ZDBVIEW-ESP-002 Solo dati: colonne e record
Le esportazioni «solo dati» (XLSX, XLS, e CSV nel formato `etCSV` di QExport4) riportano le colonne **visibili** della vista, con l'intestazione `Caption` della colonna e il campo `DataBinding.FieldName`, e tutti i record del dataset. L'ora si formatta `hh:mm`. Per XLS e XLSX i valori troppo lunghi per una cella si tagliano (`AutoTruncateValue`, richiesta del 2025-06-14). Durante l'esportazione una finestra di avanzamento permette di annullare con conferma.

### Scenario: colonna nascosta
- **Dato** una vista con la colonna `NOTE` nascosta
- **Quando** si esporta «solo dati»
- **Allora** il file non contiene `NOTE`

## ZDBVIEW-ESP-003 Completa: modo della griglia e filtri
`ExportGridData` esporta ciò che la griglia ha in memoria: per questo, prima dell'esportazione, porta la griglia fuori da `GridMode` (carica tutti i record), disattiva il filtro della griglia se era in `GridMode` e scollega il suo evento di cambio filtro; a esportazione finita ripristina `GridMode`, il filtro e l'evento. Una finestra di avanzamento con annulla accompagna l'esportazione. In `GridMode` la griglia vedrebbe solo i record già letti.

### Scenario: elenco lungo
- **Dato** una vista con 5000 record in `GridMode`
- **Quando** si esporta «completa»
- **Allora** il file contiene tutti i 5000 record e, a fine esportazione, la vista torna in `GridMode` con il suo filtro

## ZDBVIEW-ESP-004 Finestra di esportazione generica
`ExportView` (comando «Esporta») apre il dialogo di QExport4 sul dataset. Prima rende il dataset **unidirezionale** (più veloce, meno memoria): lo chiude, lo riapre in quel modo con i controlli collegati disattivati (`DisableControls`); a fine lavoro lo richiude e lo riapre in modo normale, con i controlli riattivati.

### Scenario: esportazione generica
- **Dato** una vista con 100.000 record
- **Quando** l'utente sceglie «Esporta»
- **Allora** il dialogo lavora su un dataset unidirezionale e, chiuso il dialogo, il dataset torna normale Le colonne proposte sono le visibili.

## ZDBVIEW-ESP-005 Stampa rapida
`Print_zDbView` non fa niente se la vista o il suo dataset non esistono. Costruisce un rapporto FastReport a pagina orizzontale, con un'intestazione (titolo della colonna, bordo pieno) e una banda dati per le colonne visibili, in ordine di visualizzazione, ciascuna larga quanto in griglia e affiancata alla precedente; ferma l'elenco alla prima colonna che farebbe superare la larghezza utile della pagina (le successive non si stampano). Mostra l'anteprima (`ShowReport`) e libera rapporto e dataset del rapporto a fine uso.

### Scenario: vista larga
- **Dato** una vista le cui colonne visibili superano la larghezza della pagina
- **Quando** si stampa
- **Allora** la stampa riporta solo le colonne che ci stanno e le altre mancano senza avviso

## Divergenze note
Si decidono nella voce R-210 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-ESP-1 🟡 (dedotta) | Nella finestra «Salva con nome» l'ordine dei tipi (XLSX solo dati, XLSX completo, **XLS completo, XLS solo dati**, CSV) non coincide con quello dell'enumerazione `TViewExportType` (XLSX dati, XLSX completo, **XLS dati, XLS completo**, CSV) su cui `ExportView2Excel` calcola `FilterIndex - 1` | Chi sceglie «XLS (completo)» ottiene l'esportazione «solo dati», e viceversa |
| DIV-ESP-2 🟡 (dedotta) | `ExportGridData` non ha `try/finally`: se l'esportazione solleva un errore (disco pieno, utente che annulla con `Abort` dalla finestra di avanzamento) la griglia resta fuori da `GridMode`, senza filtro e con l'evento di cambio filtro scollegato | Dopo un'esportazione annullata la vista è lenta e i filtri successivi non si applicano alla query, fino a riaprire la vista |
| DIV-ESP-3 🟡 (dedotta) | `GetExportedFields` scorre `Columns[i]` per indice di creazione e non `VisibleColumns` per ordine di visualizzazione; la stampa invece rispetta l'ordine a video | L'esportazione «solo dati» ha le colonne in un ordine diverso da quello che l'utente vede e ha scelto |
| DIV-ESP-4 🟢 (dedotta) | Le etichette della finestra di avanzamento (`TdxExportHandler.Create`) sono sbagliate: `vetExcel97Data` dice «XLSX (solo dati)», `vetExcel97Full` «XLS (solo dati)», `vetExcel2007Data` «XLSX (completo)», `vetExcel2007Full` «XLS (completo)» | Il messaggio mostrato durante l'esportazione non dice il formato vero |
| DIV-ESP-5 🟢 (dedotta) | `InitExcelExportDialog` imposta `DefaultExt` a `*.xlsx` (con l'asterisco, che la finestra non interpreta come estensione) e `FilterIndex` a 0, e l'estensione del nome non segue il tipo scelto | Un nome scritto senza estensione può prendere `.*.xlsx` o nessuna estensione, anche scegliendo CSV |
| DIV-ESP-6 🟢 (dedotta) | `oldExportView2Excel` (esportazione precedente) è ancora nell'unit e non è chiamata da nessuno | Codice morto che duplica `ExportView2Excel` |
| DIV-ESP-7 🟢 (dedotta) | `Print_zDbView` taglia in silenzio le colonne che non stanno nella pagina | Una stampa può mancare di colonne senza che l'utente lo sappia |
| DIV-ESP-8 🟢 (dedotta) | `ExportView` chiude e riapre il dataset due volte (unidirezionale e poi normale) | Dopo la finestra di esportazione il dataset riparte da capo: la posizione del record e un eventuale record in modifica si perdono |

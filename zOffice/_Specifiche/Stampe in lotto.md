---
area: Stampe in lotto
progetto: zOffice
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/004
---

# Stampe in lotto

Questa specifica descrive come `TzReportsManager` stampa o esporta in PDF lo stesso modello per molti record senza intervento dell'utente: la sessione manuale (`BatchInit`, `BatchPrint`, `BatchExportPdf`, `BatchDone`), il ciclo guidato da un `TzBatchController` (`RunBatchPrint`, `RunBatchExportPdf`) e le impostazioni della modalità lotto. Il codice è in `zOffice\zOffice.Reports.Batch.pas` (`TzReportBatchRunner`), `zOffice.Reports.BatchController.pas` (`TzBatchController` e il contratto astratto `TProtocolloController`) e nei metodi omonimi di `zOffice.Reports.pas`; la preparazione di ogni stampa è quella di `Stampe.md` (ZOFF-STA-005). Lo usa WT: `dmGeDoStampeMassive` (estrazione massiva GEDO, PDF o stampa) e `dmDocumenti` usano la sessione manuale; `frmDocumenti` crea un `TzBatchController` dalla configurazione `DOCUMENTI_STAMPA_MULTIPLA`, ma nessuno, né in WT né in Gesty, chiama oggi `RunBatchPrint` o `RunBatchExportPdf`. `TProtocolloController` è implementato in WT (`TGeDo_ProtocolloController`, agganciato da `BaseFrm`).

**Come funziona.** La sessione manuale prepara una volta (`BeforePrint`, caricamento del `.fr3`, modalità lotto), poi il chiamante scorre i suoi record e chiama una stampa o un'esportazione per ciascuno; `BatchDone` chiude. Il ciclo guidato fa lo stesso da sé, chiedendo al controller quanti record ci sono, come passare al successivo e come chiamare il file, con una barra di avanzamento e il pulsante Annulla.

**Test che coprono quest'area.** Nessuna.

## ZOFF-LOT-001 Sessione manuale
`BatchInit(modello)` esegue `BeforePrint`, carica il modello FastReport e attiva la modalità lotto (ZOFF-LOT-002); se `BeforePrint` restituisce `False` o il modello non si carica, la sessione non si attiva e `BatchPrint` e `BatchExportPdf` non fanno nulla (`BatchExportPdf` restituisce `False`). `BatchPrint(etichetta, dialogo)` prepara il report, lo stampa con l'etichetta come nome del lavoro di stampa e mostra la finestra della stampante solo se `dialogo` è vero. `BatchExportPdf(file)` prepara il report e lo esporta in `file` con estensione forzata `.pdf`, creando la cartella; restituisce l'esito dell'esportazione. Dopo ogni documento le pagine preparate si liberano dalla memoria. `BatchDone` chiude la sessione, toglie l'eventuale `OnBeforePrint` del report, ripristina le impostazioni interattive ed esegue `AfterPrint`. La sessione manuale vale solo per i modelli FastReport.

### Scenario: estrazione massiva in PDF
- **Dato** `BatchInit('Fattura-3700-0319')` riuscito e tre record
- **Quando** per ogni record si chiama `BatchExportPdf(Cartella + 'GEDO_<id>')`
- **Allora** nella cartella compaiono tre file `GEDO_<id>.pdf`

### Scenario: nome del file mancante
- **Dato** una sessione attiva
- **Quando** si chiama `BatchExportPdf('')`
- **Allora** viene sollevata `EArgumentException` con «ExportPdf: FileName non specificato.»

## ZOFF-LOT-002 Modalità lotto
In modalità lotto il report FastReport non mostra la finestra della stampante né la barra di avanzamento nativa, e l'esportazione PDF non mostra finestre, non apre il file, non chiede conferma di sovrascrittura, comprime, incorpora i font e produce PDF/A-1a. Alla fine della sessione il report torna a mostrare la finestra della stampante e la barra, e l'esportazione PDF torna alle impostazioni interattive (ZOFF-STA-009).

### Scenario: lotto PDF senza finestre
- **Dato** la modalità lotto attiva
- **Quando** si esportano cento documenti
- **Allora** non compare nessuna finestra di scelta del file e ogni PDF è PDF/A-1a

## ZOFF-LOT-003 Controller del lotto
`TzBatchController` fornisce al ciclo tre funzioni del chiamante: `InitProc` (prepara e imposta `RecordCount`), `NextProc` (passa al record successivo), `FileNamePdfFunc` (nome del PDF del record corrente). `Init` riporta `RecordCount` a -1 e chiama `InitProc`. `Count` vale `RecordCount`, limitato a `Max` se `Max` è positivo; `Max` e `RecordCount` valgono -1 alla creazione. `AvvisaSeSuperamentoMax` avvisa «Attenzione: verranno stampati solamenti i primi <Max> record.» se `Max` è positivo e `RecordCount` lo è anche. Senza funzioni assegnate i passi non fanno nulla e il nome del PDF è vuoto.

### Scenario: tetto dalla configurazione
- **Dato** `Max = 50` e 120 documenti selezionati
- **Quando** parte il lotto
- **Allora** compare l'avviso dei primi 50 record e se ne stampano 50

## ZOFF-LOT-004 Stampa in lotto guidata
`RunBatchPrint(modello, controller, didascalia)` solleva `EArgumentNilException` («RunPrint: Controller non assegnato.») senza controller e si ferma con «Report non trovato: <nome>» se il modello manca. Altrimenti avvisa del tetto, inizializza il controller e, per ogni record fino a `Count`, mostra «i / N» nella barra, si ferma se l'utente ha annullato, esegue `BeforePrint` (se restituisce `False` il record si salta), stampa ed esegue `AfterPrint`, poi passa al record successivo. Per FastReport la finestra della stampante compare solo al primo documento stampato. Alla fine la barra si chiude e il report torna a mostrare finestra e barra nativa.

### Scenario: record saltato dal chiamante
- **Dato** `OnBeforePrint` che restituisce `False` per il secondo di tre record
- **Quando** si esegue `RunBatchPrint`
- **Allora** si stampano il primo e il terzo

## ZOFF-LOT-005 Esportazione PDF in lotto guidata
`RunBatchExportPdf(modello, controller, cartella, didascalia)` segue le regole di ZOFF-LOT-004 e restituisce il numero di PDF prodotti. Se la cartella è vuota la chiede all'utente («Seleziona la cartella di destinazione PDF»); se l'utente annulla restituisce 0 senza fare nulla. La cartella si crea se manca. Il nome di ogni file è `FileNamePdf` del controller o, se vuoto, `aaaammgg_hhnnss_<indice>`, sempre con estensione `.pdf`. Per FastReport il lotto attiva la modalità lotto (ZOFF-LOT-002) e la toglie alla fine.

### Scenario: nome assente
- **Dato** un controller senza `FileNamePdfFunc`
- **Quando** si esporta il record di indice 3 il 1° novembre 2026 alle 10:30:00
- **Allora** il file si chiama `20261101_103000_3.pdf`

## ZOFF-LOT-006 Contratto del protocollo di uscita
`TProtocolloController` è la classe astratta con cui WT protocolla i documenti generati in uscita (GEDO): `Inizializza`, `Protocollato`, `Protocolla`, `CheckProtocollato`, `Conferma`, `Annulla`, `Invia(metodo, tutti)`, `GetFileNameProtocollo`. È distinta dalle azioni documentali dell'anteprima (ZOFF-STA-013) e non va rimossa finché WT la implementa.

### Scenario: implementazione di WT
- **Dato** `TGeDo_ProtocolloController` in WT
- **Quando** si compila WT
- **Allora** la classe astratta è disponibile con gli otto metodi

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-202 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LOT-1 🟡 (dedotta) | `RunPrint` e `RunExportPdf` per un modello FastReport non caricano mai il `.fr3` (a differenza di `BatchInit`), e l'`AfterPrint` di ogni record svuota il report | Il lotto guidato FastReport stampa o esporta un report vuoto o quello rimasto in memoria; oggi nessuno lo usa |
| DIV-LOT-2 🟡 (dedotta) | Per Word ed Excel il lotto guidato passa da `zOffice.MailMerge` e `BuildSpreadSheetReport`, che aprono il visualizzatore modale; `RunExportPdf` conta come prodotto ogni record senza verificare il file | Un lotto Word apre una finestra per record e il numero restituito non dice quanti PDF esistono davvero |
| DIV-LOT-3 🟡 (dedotta) | `RestoreInteractiveMode` ripristina finestra della stampante e barra, ma non le opzioni PDF messe dalla modalità lotto (`ShowDialog = False`, PDF/A-1a, compressione), né `ReportOptions.Name` e `DatasetName` | Dopo un lotto, l'esportazione PDF dall'anteprima FastReport dello stesso manager non chiede più il file e produce PDF/A-1a, finché un JSON con il nodo `fastreport` non la reimposta (ZOFF-LOT-002) |
| DIV-LOT-4 🟢 (dedotta) | Nel lotto guidato ogni record ripassa da `BeforePrint`, che ricarica tutti i modelli da disco e avvisa la finestra dei report | Su lotti lunghi molti accessi al disco inutili |
| DIV-LOT-5 🟢 | Il messaggio del tetto dice «solamenti» | Errore di battitura visto dall'utente |

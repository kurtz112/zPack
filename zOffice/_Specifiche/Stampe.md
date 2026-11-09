---
area: Stampe
progetto: zOffice
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/004
---

# Stampe

Questa specifica descrive come un'applicazione trova, configura ed esegue una stampa con `TzReportsManager`: dove stanno i modelli (FastReport `.fr3`, Word `.docx`, Excel `.xlsx`), che cosa dice il file JSON che li accompagna, come si preparano dataset e variabili, che cosa fanno anteprima, stampa e progettazione, e come l'anteprima offre le azioni documentali (firma, protocollo, conservazione, PEC, posta). Il codice è in `zOffice\zOffice.Reports.pas` (il manager) e nei suoi collaboratori `zOffice.Reports.Variables`, `.Pipeline`, `.JsonConfig`, `.json`, `.FastReport`, `.types`, `.Azioni`, `.Controller`, `.ActionsBarHelper`, `.Progress`, `.Proprieta`, `.PropertyEditors` e `.Form` (la finestra dei report). Le stampe in lotto stanno in `Stampe in lotto.md` (ZOFF-LOT), la stampa unione Word in `Documenti Word e stampa unione.md` (ZOFF-WRD); Excel è fuori da questa specifica. Le unit non sono in nessun pacchetto `.dpk`: le compilano direttamente WT e Gesty, che hanno un manager per DataModule (`Reports` in WT, `ReportsManager` in Gesty), impostano `zReportConfig.ReportRoot := zSystem.Root_Files` in `ConfigModule` e agganciano un solo controller delle azioni in `dmCommon` (`ReportsManager.ActionsController := FirmaElettronicaController`). Il file `------ zOffice.Reports.pas` è una copia di storia e non si specifica.

**Come funziona.** Ogni `Preview`, `Print` e `Design` passa da `BeforePrint` (rilegge i modelli, legge il JSON, apre i dataset, crea i collegamenti FastReport, ricostruisce le variabili) e da `AfterPrint` in un `finally` (chiude ciò che ha aperto e ripristina i dataset). Il motore si sceglie dall'estensione del modello. Le azioni documentali passano da quattro controlli in fila: profilo documentale del modello, permesso dell'utente, precondizioni sulla catena delle versioni, stato delle registrazioni dei motori; i primi due nascondono il comando, il terzo lo disabilita con il motivo, il quarto dice se l'azione è in corso o completata.

**Test che coprono quest'area.** `Test.zOffice.Reports.Controller` (6 prove, Mantis #210) prova la cache per documento di `TzDocumentActionsControllerBase`: una sola lettura per documento chiesto cento volte, una lettura per documento con due documenti in alternanza, l'invalidazione che svuota tutti i documenti, `VerificaEseguibile` che rilegge lo stato, il tetto di `MassimoDocumentiInCache` con l'uscita del meno recente e la conservazione di quello riusato (ZOFF-STA-016). Il resto dell'area non ha prove automatiche.

## ZOFF-STA-001 Dove si cercano i modelli
La cartella dei modelli è `zReportConfig.ReportRoot + Folder`, dove `ReportRoot` aggiunge da sé `Reports\` al valore assegnato e `Folder` è il gruppo del manager. Si caricano i file `*.fr3`, `*.docx`, `*.xlsx` della cartella e delle sottocartelle, saltando le sottocartelle il cui nome comincia con `_` (fra cui `__backup` e `__Shared`), quelle elencate in `ExcludeFolders` e i frammenti Word (nome con `~~~`, ZOFF-WRD-004). Un modello si chiama con il nome del file senza estensione, senza distinzione fra maiuscole e minuscole; la ricerca guarda prima i file della cartella, poi le sottocartelle in ordine. Un modello che non c'è produce l'avviso «Report non trovato: <nome>» e la stampa non parte. `GetFolder` restituisce la cartella di un gruppo e la crea se manca.

### Scenario: modello in una sottocartella
- **Dato** il gruppo `Documenti` e il file `Reports\Documenti\Solleciti\Sollecito.fr3`
- **Quando** si chiama `Preview('sollecito')`
- **Allora** si apre l'anteprima di `Sollecito.fr3`

### Scenario: modello inesistente
- **Dato** nessun file `Copertina.*` nella cartella del gruppo
- **Quando** si chiama `Print('Copertina')`
- **Allora** compare «Report non trovato: Copertina» e `AfterPrint` viene eseguito lo stesso

## ZOFF-STA-002 Modelli condivisi
`SharedReports` aggiunge alla radice modelli presi da `<ReportRoot>\__Shared\`. Ogni riga è `NomeFile`, `Alias=NomeFile` o `Alias=[DataSet.Campo]`; nell'ultima forma il nome del file si legge, al momento del caricamento, dal campo del dataset indicato (se il dataset o il campo mancano, la riga si scarta e si scrive nel registro «DataSet non trovato» o «Field non trovato»). Per ogni riga si aggiunge un file per ciascuna estensione ammessa che esiste davvero; il modello condiviso prende il nome dell'alias, se c'è, ed è segnato come condiviso.

### Scenario: alias da un campo
- **Dato** `SharedReports` con `Contratto=[Contratti.MODELLO]` e il campo `MODELLO` che vale `ContrattoStandard`
- **Quando** si caricano i modelli
- **Allora** `GetReport('Contratto')` restituisce `__Shared\ContrattoStandard.docx`, se il file esiste

## ZOFF-STA-003 Ricaricamento dei modelli
`LoadReports` distrugge e ricrea tutti gli oggetti dei modelli. Prima di distruggerli chiama `OnReportsReloading`, dopo averli ricreati `OnReportsReloaded` (Mantis #139): chi tiene riferimenti agli oggetti (la finestra dei report li tiene nei nodi dell'albero) li lascia andare nel primo avviso e li riprende nel secondo. I modelli si ricaricano a ogni `BeforePrint`, dopo `Design` e dopo `NewReport`.

### Scenario: albero aperto durante un'anteprima
- **Dato** la finestra dei report aperta, con un modello selezionato
- **Quando** l'anteprima ricarica i modelli
- **Allora** l'albero si svuota prima della distruzione e si ricostruisce dopo, mantenendo la selezione

## ZOFF-STA-004 Il file JSON del modello
Accanto al modello può stare un file JSON, cercato prima come `<file>.<est>.json` (`Fattura.fr3.json`) e poi come `<file>.json`. Un file assente, illeggibile o che non contiene un oggetto JSON vale come se non ci fosse, senza messaggi. Chiavi riconosciute:

| Chiave | Effetto |
|---|---|
| `id`, `group` | `ReportId`, `ReportGroup` del manager |
| `mainDataset` | dataset principale (come `WithMainDataSet`) |
| `datasets` | elenco di `{ "name", "close" }`: aperti prima della stampa, chiusi dopo se `close` è `true` |
| `variables` | coppie nome-valore di testo (ZOFF-STA-008) |
| `profilo`, `tipologiaDocumentale`, `tipoDocumento` | classificazione documentale, ripulite dagli spazi e portate in maiuscolo |
| `tipoAllegato` | ripulita dagli spazi, maiuscole e minuscole conservate |
| `word` | `readOnly`, `fragments` (`variable`, `template`, `dataset`), `pdf` |
| `excel` | `readOnly`, `allowBuildReport`, `databinding`, `pdf` |
| `fastreport` | `showDialog`, `openAfterExport`, `embeddedFonts`, `overwritePrompt` per l'esportazione PDF |

Nel nodo `pdf`, `method` vale `dialog`, `filename`, `fieldname` o `tempfile` (anche con il prefisso `mgf`), `fontEmbedding` vale `none`/`N`, `full`/`F`, `subset`/`S`; seguono `fileName`, `fieldName`, `openFileAfterExport`, `showMessageAfterExport`. Un valore booleano che non è `true` o `false` si ignora. Le chiavi `word.firma` e `word.inviaMail` e il nodo `azioni` sono ritirati: non pilotano più nulla, le azioni vengono dal profilo (ZOFF-STA-013).

### Scenario: JSON non valido
- **Dato** `Fattura.fr3.json` che contiene testo non JSON
- **Quando** si apre l'anteprima di `Fattura`
- **Allora** l'anteprima si apre con le impostazioni predefinite e nessun profilo documentale

### Scenario: profilo scritto in minuscolo
- **Dato** un JSON con `"profilo": " contratti "`
- **Quando** si prepara la stampa
- **Allora** il profilo passato al controller è `CONTRATTI`

## ZOFF-STA-005 Preparazione e chiusura di ogni stampa
`BeforePrint`, in quest'ordine: ricarica i modelli; azzera la sessione delle azioni documentali (documento corrente, profilo, tipologia, tipi, funzione di esportazione PDF del visualizzatore); propone `Documenti` dell'utente come cartella dell'esportazione PDF FastReport; applica il JSON; apre i dataset registrati per quel modello (`RegisterReportDataSets` o `datasets` del JSON) che non erano già aperti, ricordandoli; crea i collegamenti FastReport; ricostruisce le variabili; mette tutti i dataset del manager e il dataset selezionato in lettura a blocchi (`DisableControlsExt`, mai `DisableControls`, che spegnerebbe il legame master/dettaglio di FireDAC); infine chiama `BeforePrintProc` con il nome del modello, se il nome non è vuoto. Se `BeforePrintProc` restituisce `False` la stampa non parte.

`AfterPrint` gira sempre, anche quando la stampa non è partita o è fallita: distrugge i collegamenti, svuota il report FastReport, ripristina i dataset (`EnableControlsExt`), chiude quelli aperti da `BeforePrint` e quelli con `close: true`, ignorando gli errori di chiusura, e chiama `AfterPrintProc`.

### Scenario: stampa annullata dal chiamante
- **Dato** `OnBeforePrint` che restituisce `False`
- **Quando** si chiama `Preview('Fattura')`
- **Allora** nessuna anteprima si apre
- **E** i dataset tornano come prima e `AfterPrintProc` viene chiamata

### Scenario: dataset aperto solo per la stampa
- **Dato** un dataset `Righe` chiuso e registrato per il modello `Fattura`
- **Quando** l'anteprima si chiude
- **Allora** `Righe` è di nuovo chiuso

## ZOFF-STA-006 Anteprima, stampa e progettazione
Il motore si sceglie dall'estensione (`.fr3`, `.docx`, `.xlsx`, senza distinzione fra maiuscole e minuscole):

| Comando | FastReport | Word | Excel |
|---|---|---|---|
| `Preview(nome, DataSet)` | anteprima propria (`TzOfficeFastReportForm`) con le azioni documentali | stampa unione e visualizzatore (ZOFF-WRD-001) | costruzione del foglio e visualizzatore |
| `Print(nome)` | preparazione e poi stampa (ZOFF-STA-012 per l'avanzamento) | come `Preview` | come `Preview` |
| `Design(nome)` | progettista FastReport, con copia di sicurezza (ZOFF-STA-010) | editor dei modelli Word | editor dei modelli Excel |

`Preview` con un dataset lo rende il dataset selezionato prima di preparare la stampa. `NewReport` chiede il tipo (FastReport, Template Word, Template Excel): annullare la scelta non apre nulla; altrimenti si apre l'editor vuoto, che propone di salvare nella cartella del gruppo, e alla fine i modelli si ricaricano.

### Scenario: modello Word in anteprima
- **Dato** il modello `Lettera.docx` e un dataset selezionato
- **Quando** si chiama `Preview('Lettera')`
- **Allora** si apre il visualizzatore Word con il documento unito

## ZOFF-STA-007 Dataset e collegamenti FastReport
I dataset del manager si aggiungono con `AddDataSet`, `WithDataSet` o `WithMainDataSet` (che lo rende anche selezionato), senza doppioni; un dataset distrutto esce da sé dall'elenco. A ogni stampa ogni dataset riceve un collegamento FastReport (`TfrxDBDataSet`) il cui nome è `ReportPipe` del dataset, se valorizzato, altrimenti `<nome del proprietario del manager>_<nome del dataset>`. `GetDataSet(nome)` cerca per nome del dataset o del collegamento; con il nome vuoto restituisce il dataset selezionato. `DataSetNames` elenca le coppie `dataset = collegamento`.

### Scenario: nome del collegamento
- **Dato** il manager di `dmFatture` e il dataset `Testata` senza `ReportPipe`
- **Quando** si prepara la stampa
- **Allora** nel report il dataset si chiama `dmFatture_Testata`, e `GetDataSet('dmFatture_Testata')` restituisce `Testata`

## ZOFF-STA-008 Variabili
Una variabile si risolve nello stesso modo per i tre motori, in quest'ordine: `OnGetVariable` del manager (se restituisce un valore diverso da `Null`); il dizionario; le espressioni `NOW`, `CURRENT_TIME`, `CURRENT_TIMESTAMP` (data e ora), `TODAY`, `CURRENT_DATE` (data), `TOMORROW`, `YESTERDAY`; altrimenti `Null`. Il nome si ripulisce dagli spazi e dagli apici singoli. A ogni stampa il dizionario si ricostruisce: si svuota, riceve i parametri di ogni dataset del manager col nome `<nome del manager>_<nome del dataset><nome del parametro>` (i testi restano testi) e poi ciò che aggiunge `AddVariablesProc`. FastReport riceve il dizionario nella categoria `zVariabili`, con i testi fra apici; lo stesso aggiornamento si ripete all'inizio del documento. `VariableExists` guarda solo il dizionario.

### Scenario: variabile aggiunta durante la preparazione
- **Dato** `AddVariablesProc` che aggiunge `RegistrazioniContabili_Interrogazioni_Conto` = `'1010'`
- **Quando** si stampa un modello FastReport che la usa
- **Allora** nel report la variabile vale `1010`

### Scenario: data del giorno
- **Dato** nessuna variabile `TODAY` nel dizionario e `OnGetVariable` che restituisce `Null`
- **Quando** un modello Word chiede `TODAY`
- **Allora** riceve la data di oggi

## ZOFF-STA-009 Esportazione PDF dall'anteprima FastReport
Valori predefiniti: finestra di scelta del file sì, apertura dopo l'esportazione no, conferma di sovrascrittura no, font incorporati sì, cartella proposta `Documenti` dell'utente. Il nodo `fastreport` del JSON li sostituisce tutti e quattro.

### Scenario: nessun JSON
- **Dato** un modello `.fr3` senza JSON
- **Quando** l'utente esporta in PDF dall'anteprima
- **Allora** si apre la finestra di scelta nella cartella `Documenti`

## ZOFF-STA-010 Copie di sicurezza in progettazione
Aprire un modello FastReport nel progettista ne fa prima una copia in `<cartella del modello>\__backup\<aaaammgghhnnss>_<file>`, anche con percorsi oltre i 260 caratteri (Mantis #131). La cartella di apertura e di salvataggio del progettista è quella del modello, o la cartella del gruppo per un modello nuovo. L'editor Word fa la stessa copia a ogni salvataggio (ZOFF-WRD-010).

### Scenario: progettazione
- **Dato** il modello `Fattura.fr3`
- **Quando** si chiama `Design('Fattura')`
- **Allora** in `__backup` compare `20261101103000_Fattura.fr3` prima che il progettista si apra

## ZOFF-STA-011 Modifica del contenuto in anteprima
Nell'anteprima FastReport gli oggetti si possono modificare a mano solo se l'utente ha il permesso `Report.Preview.Editing`; senza permesso il pulsante di modifica non c'è.

### Scenario: utente senza permesso
- **Dato** un utente senza `Report.Preview.Editing`
- **Quando** apre un'anteprima FastReport
- **Allora** non può modificare il testo delle pagine

## ZOFF-STA-012 Avanzamento e annullamento
I tre motori ricevono dal manager lo stesso contratto `IzReportProgress`: `Start` mostra la barra (indeterminata se il totale non è noto, come per FastReport ed Excel), `Step` la aggiorna e restituisce `False` quando l'utente ha premuto Annulla, `Done` la chiude sempre. Se l'utente annulla la preparazione, il visualizzatore non si apre e non si stampa nulla.

### Scenario: annullamento di un'anteprima FastReport
- **Dato** un modello lungo in preparazione
- **Quando** l'utente preme Annulla
- **Allora** la preparazione si ferma, la barra si chiude e l'anteprima non compare

## ZOFF-STA-013 Azioni documentali dell'anteprima
Se il JSON dichiara un `profilo` e il manager ha un `ActionsController`, `BeforePrint` chiede una volta sola `AzioniDelProfilo(profilo)`; senza profilo, senza controller o con un profilo senza azioni, il gruppo «Documento» del visualizzatore resta nascosto. Il contesto di ogni domanda al controller si costruisce ogni volta (`ContestoCorrente`): documento persistito (0 se non ancora), OID dell'entità, nome del modello, profilo, tipologia, `tipoDocumento`, `tipoAllegato` e azioni del profilo. L'OID viene, in quest'ordine, da `WithOid`, da `OnGetOid`, dal campo OID del dataset selezionato.

### Scenario: modello senza profilo
- **Dato** un modello con JSON senza `profilo`
- **Quando** si apre l'anteprima
- **Allora** il gruppo «Documento» non compare

## ZOFF-STA-014 Stato di un'azione
`TzDocumentActionsControllerBase.Stato` applica in ordine: azione assente o disattivata nel profilo, oppure permesso negato → `adsNonDisponibile` (comando nascosto); precondizioni non soddisfatte o regola dell'applicazione (`OnAzioneAmmessa`) contraria → `adsBloccata` (comando visibile e disabilitato, con il motivo nel suggerimento); altrimenti lo stato dell'ultima registrazione del motore:

| Azione | In corso | Completata | Di nuovo disponibile |
|---|---|---|---|
| Firma | I, A, D | F | R, S |
| Protocolla | P, A | K | E, X |
| Conserva | INS, GEN, INV | ACC, CON | RIF, ANN |
| Invia PEC | P, I, A | C | E, X |
| Invia Mail | mai | mai | sempre |

Firma e Protocolla si fanno una volta sola: completate, il comando diventa «Vedi estremi - <azione>» e mostra gli estremi. Conserva, Invia PEC e Invia Mail restano eseguibili e mostrano l'ultimo esito nel suggerimento («Ultimo esito: …»). Il comando «Aggiorna stato» compare solo se almeno un'azione è in corso e interroga il fornitore per tutte quelle in corso.

### Scenario: firma completata
- **Dato** un documento con la firma in stato `F` ed estremi `1234/2026 del 14/07/2026`
- **Quando** il visualizzatore aggiorna i comandi
- **Allora** il comando si chiama «Vedi estremi - Firma» e mostra `1234/2026 del 14/07/2026`

## ZOFF-STA-015 Precondizioni sulla catena delle versioni
La colonna `RICHIEDE` del profilo elenca i tipi di versione che devono esistere tutti nella catena del documento. Se mancano, il motivo è «<Azione> disponibile solo dopo <descrizioni>», con le descrizioni unite da « e » (`ORI` la generazione del documento, `FIR` la firma, `PRO` la protocollazione, `STA` la versione per lo stampatore, `PEC` la trasmissione PEC, `RIC` la ricevuta, altrimenti «la versione <tipo>»). Un documento non ancora persistito non ha catena: l'azione è bloccata con il primo tipo richiesto.

### Scenario: PEC prima della firma
- **Dato** Invia PEC con `RICHIEDE = FIR` e una catena che contiene solo `ORI`
- **Quando** si chiede lo stato
- **Allora** è `adsBloccata` con motivo «Invia PEC disponibile solo dopo la firma»

## ZOFF-STA-016 Esecuzione di un'azione e persistenza del documento
Prima di eseguire, il comando chiede conferma («Procedere con la firma del documento?» e simili; per un'azione ripetibile già eseguita aggiunge l'avviso e l'ultimo esito), salvo `RichiediConferma = False`. `EseguiAzione` persiste il documento al primo uso: chiede al visualizzatore un PDF temporaneo, lo passa a `PersistDocument` (versione `ORI` più la generazione) e cancella il temporaneo; la persistenza è una sola per sessione di anteprima. Senza controller o senza funzione di esportazione del visualizzatore solleva `EzAzioneDocumentoBloccata`. Poi il controller riverifica lo stato da zero (`VerificaEseguibile` svuota la cache) e rifiuta con `EzAzioneDocumentoBloccata` un'azione bloccata o non disponibile (con il motivo, o «L'azione X non e' disponibile per questo documento»), in corso («… e' gia' in corso: attendere l'esito o usare "Aggiorna stato"») o completata e non ripetibile («… e' gia' stata eseguita per questo documento (<estremi>)»). Nel visualizzatore l'errore compare come avviso. Il comando «Genera allegato» persiste il documento senza eseguire azioni ed è attivo solo finché il documento non è persistito; l'esportazione PDF del visualizzatore, quando l'allegato si può ancora generare, chiede se generare anche l'allegato.

### Scenario: firma rifiutata perché già fatta
- **Dato** un documento persistito con la firma completata
- **Quando** un'applicazione chiama `Esegui(adFirma, …)` senza passare dal visualizzatore
- **Allora** solleva `EzAzioneDocumentoBloccata` con gli estremi della firma

## ZOFF-STA-017 Cache per documento del controller
Il controller tiene in cache, per gli ultimi `MassimoDocumentiInCache` (8) documenti, i tipi di versione della catena, lo stato e gli estremi di ogni azione, così l'aggiornamento continuo dei comandi non legge il database a ogni momento di inattività (Mantis #194, #210). Il documento usato per ultimo va in testa; oltre il tetto esce il meno recente. `InvalidaCacheDocumento` svuota tutto e va chiamata dopo ogni azione; gli estremi di un documento non persistito non si memorizzano.

### Scenario: due visualizzatori sullo stesso controller
- **Dato** due documenti valutati in alternanza tre volte
- **Quando** si chiede lo stato della firma a ogni giro
- **Allora** i tipi di versione e lo stato si leggono una volta per documento

## ZOFF-STA-018 Finestra dei report e proprietà del modello
`ShowReportForm(dataset)` rende selezionato il dataset e apre la finestra dei report: doppio clic apre l'anteprima; Nuovo, Modifica, Cartella e le politiche di accesso hanno livello predefinito nessuno, Anteprima e Stampanti pieno; il menu Sistema e le Proprietà compaiono solo con il permesso `Report.Modifica`. Le Proprietà modificano il JSON del modello (ZOFF-STA-004): riscrivono solo `id`, `group`, `mainDataset`, `profilo`, `tipologiaDocumentale` (in maiuscolo; un valore vuoto toglie la chiave) e le opzioni dei nodi `word`, `excel`, `fastreport` e `pdf`, lasciando intatto il resto del file; senza JSON e senza valori impostati non creano il file; un JSON esistente ma non valido le blocca con «Il file "<percorso>" esiste ma non contiene JSON valido: correggerlo prima di modificare le proprieta'». Le tendine di profilo e tipologia leggono `OBJ_FILES_PROFILI_DOCUMENTALI` e `OBJ_FILES_TIPOLOGIE_DOCUMENTALI`.

### Scenario: proprietà su un modello senza JSON
- **Dato** `Lettera.docx` senza JSON
- **Quando** l'utente apre le Proprietà e conferma senza impostare nulla
- **Allora** nessun file `Lettera.docx.json` viene creato

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-202 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-STA-1 🔴 (dedotta) | `SaveWordFragment`, `RemoveWordFragment` e `SaveExcelDataBinding` riscrivono il JSON passando dalla classe `TzJsonReportParams`, che non conosce `profilo`, `tipologiaDocumentale`, `tipoDocumento`, `tipoAllegato`, `variables` né le chiavi sconosciute (le Proprietà invece le conservano) | Aggiungere o togliere un frammento nell'editor Word, o salvare il collegamento dati di Excel, cancella dal JSON il profilo documentale: il modello perde le azioni documentali senza alcun avviso |
| DIV-STA-2 🟡 (dedotta) | Le variabili del nodo `variables` del JSON e quelle impostate con `SetVar`/`AddVariable` prima di `Preview` finiscono nel dizionario, che `AddVariables` subito dopo svuota (ZOFF-STA-008) | Funzionano solo `AddVariablesProc` e `OnGetVariable`; il nodo `variables` e l'interfaccia `SetVar` non hanno effetto |
| DIV-STA-3 🟡 (dedotta) | `ApplyJsonContext` cambia `frxPDFExport`, `WordParams` (`ReadOnly`, `Fragments`, `pdf`) ed `ExcelParams` del manager, e niente li riporta ai valori predefiniti; i frammenti si sostituiscono solo se il nuovo JSON ne ha | Un modello senza JSON, o con un JSON parziale, eredita sola lettura, frammenti e opzioni PDF del modello stampato prima dallo stesso manager |
| DIV-STA-4 🟡 (dedotta) | `GetDataSet` con un nome sconosciuto restituisce il dataset selezionato o il primo dell'elenco invece di `nil` | Un nome sbagliato in `mainDataset`, `datasets` o nei condivisi `[DataSet.Campo]` lavora in silenzio sul dataset selezionato: con `close: true` lo chiude dopo la stampa |
| DIV-STA-5 🟡 (dedotta) | `Print` di FastReport chiama il motore con `ShowDialog = True`, che esegue `ShowReport` (anteprima nativa di FastReport) e non `Print`; per Word ed Excel `Print` fa la stessa cosa di `Preview`. Il commento del motore parla di «dialogo stampante» | `Reports.Print('Copertina')` (WT) e `Print('Incarico')` (Gesty) mostrano un'anteprima, quella FastReport senza azioni documentali, invece di stampare |
| DIV-STA-6 🟡 (dedotta) | Il manager non passa al motore FastReport né `zSystem` né `CurrentUserDisplayName` | Il permesso `Report.Preview.Editing` non viene mai letto e la modifica in anteprima non è mai concessa (ZOFF-STA-011); `CurrentUserDisplayName` non serve a nulla |
| DIV-STA-7 🟡 (dedotta) | `WithOid` resta valido per tutte le anteprime successive: `BeforePrint` non lo azzera e, se valorizzato, vince su `OnGetOid` e sul dataset selezionato | Rischio latente: oggi nessuno chiama `WithOid` (in WT c'è solo una riga commentata), ma chi lo usasse persisterebbe i documenti seguenti sull'entità sbagliata |
| DIV-STA-8 🟢 (dedotta) | Lo stato delle azioni di un documento non persistito si memorizza sotto `IdObjectFile = 0`, voce condivisa da tutti i documenti non ancora persistiti; gli estremi invece non si memorizzano | Se l'applicazione calcola uno stato diverso per due documenti non persistiti, il secondo vede quello del primo fino alla prossima invalidazione |
| DIV-STA-9 🟢 | Le testate di `zOffice.Reports.pas`, `zOffice.Reports.Controller.pas` e `zOffice.Reports.JsonConfig.pas` dicono «PROPOSTA - Mantis #90 … Non sostituisce il file sorgente»; altri commenti parlano ancora del nodo `azioni` e del «fallback nel parsing di zOffice.Reports.Azioni», che non esiste più; `TzFastReportEngine.ConfigureFromJson` non è chiamata da nessuno | Chi legge crede che il codice sia una bozza non in produzione o che il nodo `azioni` conti ancora |
| DIV-STA-10 🟢 | `InizializzaAzioniDocumento` pretende l'azione `actDocGeneraAllegato` (errore `EzDocumentActionsConfig` se manca), mentre il commento la dice facoltativa e `TrovaAzioneOpzionale` esiste per questo | Oggi i quattro visualizzatori la hanno; un visualizzatore nuovo senza quel comando non si apre |
| DIV-STA-11 🟢 | La finestra Proprietà non mostra `tipoDocumento` e `tipoAllegato` (li conserva, ma non li fa modificare) | Le due chiavi si scrivono solo a mano nel file |

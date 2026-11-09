---
area: Visualizzatore di file
progetto: zBase
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/016
---

# Visualizzatore di file

Questa specifica descrive `TzFileViewer`, il riquadro che mostra un allegato PDF accanto ai dati di una scheda o di una griglia: WT lo usa per i documenti, le ricevute, le planimetrie, i certificati catastali e gli allegati di emissioni e tariffe; Gesty per gli allegati di studenti, aziende, progetti, tirocini e simili. Il codice è in `zBase\zFileViewer.pas` (con il suo `.dfm`, che contiene il visualizzatore PDF di DevExpress, la barra degli strumenti, la barra di stato e le azioni di stampa, salvataggio e apertura). Lo usano 24 file di WT e 25 di Gesty (conteggio per riga nell'`uses`, copie di lavoro escluse); si crea in tre modi: da codice con `CreateFileViewer` (13 chiamate nei `dbForms` di WT), dal `TLayoutController` di `zFormController.pas` quando la scheda LZ dichiara un componente di tipo file, e da `zForm_Help.pas` (guida in PDF). La unit non è elencata nei `.dpk` di zBase (vi compare solo `zBaseRegister`, che la usa e registra il componente) né nei `.dpr` di WT e di Gesty: si compila perché è nel library path e la raggiunge una catena di `uses`; compare solo in `GestyWeb.dpr`. Descrive il comportamento atteso, non il codice né la disposizione dei pulsanti.

**Come funziona.** Il riquadro sa mostrare **solo file PDF**. Gli viene dato un dataset e il nome del campo che contiene il nome del file (`FieldName`, predefinito `FULL_FILE_NAME`) e, se il campo contiene un nome relativo, la cartella (`Folder`). Ogni cambiamento del dataset (cambio di record, modifica di un campo) fa ripartire un timer di mezzo secondo; allo scadere legge il nome del file dal record corrente e lo carica, oppure svuota il riquadro. In alternativa il chiamante assegna direttamente `FileName`. Il file mostrato non viene mai modificato: le uniche scritture sono la copia fatta da **Salva** (ZBASE-FVW-009) e il PDF prodotto da `GenerateFromTemplate` (ZBASE-FVW-011). Nessuna finestra di errore compare per un file mancante: il riquadro resta vuoto.

**Test che coprono quest'area.** `Test.zFileViewer` (41 prove, tutte eseguite, comprese quelle di `CreateFileViewer`, che crea `TzFileViewer` e non la classe di prova senza finestra genitore; il riquadro è un frame e mentre si costruisce un controllo figlio chiede la finestra, quindi in un programma di console serve un genitore di comodo: `Application.Handle` vale 0, lo fa la finestra di una form di prova) crea il riquadro con quel genitore di comodo e senza mostrarlo, e prova i valori iniziali, la cartella (`Folder`), l'assegnazione di `FileName` con file mancante, con estensione diversa da `.pdf` e con il blocco, la lettura del nome dal record del dataset (campo mancante, vuoto, con cartella), la reazione alla scomparsa del dataset, il blocco e il suo effetto sulla barra di stato, la visibilità di **Importa** e l'inoltro del file scelto, la creazione con `CreateFileViewer`, l'interfaccia `IzBaseComponent` e `IzBaseDbComponent`. Non provano, perché serve una finestra visibile o il caricamento di un PDF vero: l'apertura del documento (salvo il caso di `Init` con nome conservato, provato con un PDF minimo), la barra di stato con documento caricato, stampa, salvataggio, apertura con l'applicazione associata, la generazione da modello e la configurazione degli strumenti.

## ZBASE-FVW-001 Tipi di file riconosciuti
Il riquadro apre soltanto i file con estensione `.pdf`, senza distinzione fra maiuscole e minuscole (`.PDF` vale quanto `.pdf`). Qualunque altro file (immagine, Word, Excel, testo) non viene mostrato: il riquadro si svuota e `FileName` torna alla stringa vuota. L'enumerazione `TFileType` (`ftNull`, `ftImage`, `ftPdf`) e il campo `FileType` esistono ma nessuno li valorizza né li legge (DIV-FVW-5): per mostrare più formati i chiamanti usano `TzMultiViewer` (unit `zOffice.MultiViewer`), che sceglie il visualizzatore dal tipo.

### Scenario: file con estensione diversa
- **Dato** un file `foto.jpg` esistente
- **Quando** si assegna `FileName := 'C:\Allegati\foto.jpg'`
- **Allora** `FileName` resta vuoto e il riquadro non mostra nulla
- **E** non compare nessun messaggio

### Scenario: estensione in maiuscolo
- **Dato** un file `Contratto.PDF` esistente e il riquadro già inizializzato
- **Quando** si assegna il suo nome a `FileName`
- **Allora** il file viene caricato come un `.pdf`

## ZBASE-FVW-002 Come si indica il file: `FileName`, `Folder`, `FieldName`
Il file da mostrare si indica in due modi, che si possono combinare:
- **direttamente**, assegnando `FileName` (percorso completo, come nella guida in PDF e nella scheda delle planimetrie);
- **dal dataset**: a ogni lettura il riquadro cerca nel record corrente il campo `FieldName` (predefinito `FULL_FILE_NAME`; nei chiamanti anche `NOME_FILE` e `FILENAME`) e imposta `FileName := Folder + valore del campo`.

`Folder` si imposta con una stringa libera: gli spazi ai bordi sono tolti e, se il risultato non è vuoto, viene aggiunta la barra rovesciata finale quando manca (`IncludeTrailingPathDelimiter`). Una cartella vuota o fatta di soli spazi resta vuota. Con `Folder` vuoto il campo del dataset deve quindi contenere già il percorso completo (è il caso della vista `FULL_FILE_NAME`); con `Folder` valorizzato deve contenere solo il nome del file. Un campo che contiene un percorso assoluto, concatenato a una cartella non vuota, dà un percorso senza senso: il file non esiste e il riquadro si svuota.

Il campo `FieldNameOID` (nome del campo con l'identificativo dell'oggetto) non serve a mostrare il file: lo legge chi gestisce l'importazione (ZBASE-FVW-007).

### Scenario: cartella normalizzata
- **Dato** un riquadro appena creato
- **Quando** si assegna `Folder := '  C:\Allegati '`
- **Allora** `Folder` vale `C:\Allegati\`

### Scenario: cartella già terminata
- **Dato** un riquadro appena creato
- **Quando** si assegna `Folder := 'C:\Allegati\'`
- **Allora** `Folder` vale `C:\Allegati\` (una sola barra)

### Scenario: cartella vuota
- **Dato** un riquadro con `Folder` uguale a `C:\Allegati\`
- **Quando** si assegna `Folder := '   '`
- **Allora** `Folder` è la stringa vuota

### Scenario: nome relativo più cartella
- **Dato** `Folder` uguale a `C:\Allegati\` e un record con `NOME_FILE` uguale a `planimetria.pdf`
- **Quando** il riquadro legge il record
- **Allora** `FileName` diventa `C:\Allegati\planimetria.pdf`, se il file esiste

## ZBASE-FVW-003 File mancante, vuoto, non leggibile, grande
- **File che non esiste** (o percorso vuoto): il riquadro si svuota in silenzio, senza messaggio, senza eccezione; `FileName` torna alla stringa vuota. Un allegato registrato nel database ma sparito dal disco appare quindi come un riquadro bianco, senza spiegazione.
- **Record senza valore** (campo vuoto) e **dataset vuoto**: il riquadro si svuota. Con il dataset vuoto lo fa solo se in quel momento mostra un file.
- **Campo `FieldName` inesistente** nel dataset: il riquadro non cambia e non segnala nulla (resta mostrato il file di prima: DIV-FVW-3).
- **File esistente ma `.pdf` non valido** (vuoto, troncato, cifrato non apribile): il caricamento lo fa `dxPDFViewer.LoadFromFile`; se solleva un'eccezione, il riquadro nasconde l'indicatore di attesa e **rilancia** l'eccezione, che arriva al gestore globale dell'applicazione (dalla scheda del timer, quindi con la finestra di errore standard). Il codice non verifica la dimensione né ricontrolla prima di caricare: il comportamento con un file di zero byte è quello di DevExpress, non verificato qui. `FileName` conserva comunque il nome del file che non si è aperto.
- **File molto grande**: nessun limite di dimensione e nessun caricamento in un thread separato; la lettura blocca l'interfaccia, con l'indicatore di attesa e il cursore a clessidra, finché DevExpress non ha finito.

Mentre controlla l'esistenza del file il riquadro mostra e nasconde l'indicatore di attesa anche per un controllo istantaneo.

### Scenario: file sparito dal disco
- **Dato** un record il cui campo indica un file che non esiste più
- **Quando** il timer scade e il riquadro legge il record
- **Allora** il riquadro è vuoto e `FileName` è la stringa vuota
- **E** nessun messaggio compare all'utente

### Scenario: dataset vuoto
- **Dato** un riquadro che mostra un file e un dataset che diventa vuoto
- **Quando** il timer scade
- **Allora** il riquadro si svuota

### Scenario: campo non trovato
- **Dato** un dataset senza il campo indicato in `FieldName`
- **Quando** il timer scade
- **Allora** il riquadro resta com'era

## ZBASE-FVW-004 Blocco del caricamento (`Locked`)
Con `Locked` vero il riquadro non carica nulla: ogni assegnazione di `FileName` lo svuota, come se il file non esistesse. Serve a impostare dataset e cartella senza che parta un caricamento: i chiamanti scrivono `viewer.Locked := True; viewer.DataSet := ...; viewer.Locked := False`. Tornando a falso il riquadro fa ripartire la lettura (timer). Assegnare lo stesso valore non fa nulla. Nella barra di stato il pannello 1 mostra `!` quando `Locked` è vero, ma si aggiorna solo alla prossima pulizia o apertura (DIV-FVW-4).

### Scenario: caricamento bloccato
- **Dato** `Locked` vero
- **Quando** si assegna `FileName` a un PDF esistente
- **Allora** il riquadro è vuoto e `FileName` è la stringa vuota

### Scenario: sblocco
- **Dato** `Locked` vero
- **Quando** si assegna `Locked := False`
- **Allora** il timer di lettura parte

## ZBASE-FVW-005 Quando il riquadro legge (inizializzazione e timer)
Il riquadro non apre niente finché non è **inizializzato** (`Init`): l'inizializzazione costruisce le azioni degli strumenti dalla configurazione LZ ed è automatica alla prima volta che il riquadro diventa visibile (insieme a una lettura del record corrente), oppure esplicita (`Init`, come fa la guida in PDF prima di assegnare `FileName`). Prima dell'inizializzazione `FileName` può conservare il nome di un PDF esistente senza che sia caricato; `Init` lo apre appena l'inizializzazione è fatta (DIV-FVW-1, corretta nel rilascio 016).

Ogni cambiamento del dataset (cambio di record, o modifica del campo `FieldName`; la modifica di un altro campo non conta, DIV-FVW-2 corretta nel rilascio 014) chiama `Reload`, che spegne e riaccende un timer di 500 ms: solo l'ultimo cambiamento di una raffica produce una lettura, e scorrere velocemente i record non carica i PDF intermedi. Allo scadere il timer si spegne e legge il record (ZBASE-FVW-002).

### Scenario: scorrimento veloce
- **Dato** un dataset con molti record e un PDF per record
- **Quando** l'utente scorre dieci record in meno di mezzo secondo
- **Allora** viene caricato solo il PDF dell'ultimo record

### Scenario: riquadro appena creato
- **Dato** un riquadro creato ma non ancora mostrato
- **Quando** si legge `Timer.Enabled`
- **Allora** è falso

## ZBASE-FVW-006 Collegamento al dataset
`DataSet` accetta qualunque `TDataSet`; lo collega al `DataSource` interno del riquadro, che notifica ogni cambiamento. Se il dataset viene distrutto e ha lo stesso proprietario del riquadro (o ha chiesto la notifica di distruzione), il riquadro lo scollega (`DataSet` torna nullo) e si svuota alla lettura successiva. L'interfaccia `IzBaseDbComponent.zDataSet` restituisce lo stesso dataset **visto come `TzFbDataSet`**: con un dataset di altro tipo la lettura solleva un errore di conversione (`EInvalidCast`); con il dataset nullo restituisce nullo. Assegnare `zDataSet` equivale ad assegnare `DataSet`.

Anche se il dataset ha un proprietario diverso (nei form di WT e Gesty i dataset stanno nei moduli dati e il riquadro nella scheda), la distruzione del dataset avvisa il riquadro: `SetDataSet` chiede la notifica con `FreeNotification` (DIV-FVW-6, corretta nel rilascio 014).

### Scenario: dataset stesso proprietario
- **Dato** un riquadro e un dataset con lo stesso proprietario
- **Quando** il dataset viene distrutto
- **Allora** `DataSet` del riquadro è nullo

### Scenario: dataset non di Gesty/WT
- **Dato** un riquadro con un `TFDMemTable` come `DataSet`
- **Quando** si legge `zDataSet` dall'interfaccia `IzBaseDbComponent`
- **Allora** viene sollevato `EInvalidCast`

## ZBASE-FVW-007 Importazione di un file (`OnImportFile`)
Il pulsante **Importa** della barra (finestra di scelta con filtro `Pdf|*.pdf|Tutti|*.*`) è visibile **solo se** il chiamante ha assegnato `OnImportFile`. Quando l'utente sceglie un file, il riquadro chiama `OnImportFile(Self, nome del file scelto)`: il riquadro non copia né registra niente, non verifica che sia un PDF (il filtro `Tutti` lo permette) e non ricarica: spetta al gestore. In WT e Gesty il gestore è `TBaseForm.doImportFile` (assegnato in `AfterCreateComponent` di `BaseFrm.pas`), che registra il file con `ImportObjFile(oid, dataset, nome, nil, True)`, dove `oid` viene da `FieldNameOID` del riquadro, e poi seleziona nella vista il record nuovo con il filtro `ID_OBJECT_FILE`. Alcune schede di WT (automezzi, operatori, richieste, manutenzioni, fattura fornitore, home Gera) assegnano un proprio gestore.

### Scenario: nessun gestore
- **Dato** un riquadro senza `OnImportFile`
- **Quando** la barra si aggiorna
- **Allora** l'azione **Importa** non è visibile

### Scenario: file scelto
- **Dato** un riquadro con `OnImportFile` assegnato
- **Quando** l'utente conferma la scelta di `C:\Posta\verbale.pdf`
- **Allora** il gestore riceve il riquadro come mittente e `C:\Posta\verbale.pdf` come nome

## ZBASE-FVW-008 Creazione e valori iniziali
`CreateFileViewer(Proprietario, Genitore, Nome='zFileViewer', Allinea=alClient)` crea un riquadro con quel proprietario, gli assegna il nome, lo mette nel genitore e lo allinea; restituisce il riquadro creato. Un nome già usato da un altro componente dello stesso proprietario solleva l'eccezione di nome duplicato: due riquadri nella stessa scheda vogliono nomi diversi (i chiamanti di WT lo fanno: `viewerPdf`, `viewerAllegati`, `pdfStragiudiziali`...). Il `TLayoutController` di `zFormController.pas` non usa questa funzione: crea il riquadro con `TzFileViewer.Create`, gli dà nome e `ID` presi dalla scheda LZ, lo collega al `TzFbDataSet` e imposta `FieldName` e `FieldNameOID`.

Valori iniziali: `FileName` vuoto, `Folder` vuota, `FieldName` uguale a `FULL_FILE_NAME`, `FieldNameOID` vuoto, `ID` vuoto, `Locked` falso, nessun dataset, nessun gestore di eventi, timer spento, nessun documento caricato.

### Scenario: creazione con nome predefinito
- **Dato** un proprietario qualsiasi
- **Quando** si chiama `CreateFileViewer(Proprietario, nil)`
- **Allora** il riquadro si chiama `zFileViewer`, ha `Align` uguale a `alClient`, è raggiungibile con `Proprietario.FindComponent('zFileViewer')`

### Scenario: valori iniziali
- **Dato** un riquadro appena creato con `TzFileViewer.Create(nil)`
- **Quando** si leggono le proprietà
- **Allora** `FieldName` è `FULL_FILE_NAME`, `FileName` e `Folder` sono vuoti, `Locked` è falso e `DataSet` è nullo

## ZBASE-FVW-009 Barra di stato, stampa, salvataggio, apertura esterna
- **Barra di stato**, aggiornata a ogni apertura, pulizia, cambio di pagina e caricamento: pannello 0 («Documento firmato») visibile solo se il documento caricato è firmato digitalmente; pannello 1 mostra `!` se `Locked` è vero; pannello 2 mostra `Pagina N di M` (con `N` l'indice della pagina corrente e `M` il numero di pagine, così come li dà DevExpress) quando c'è un documento, altrimenti è vuoto.
- **Stampa** (`Print`): apre la finestra di stampa di DevExpress per il documento corrente, con scala «adatta alla pagina» e margini di 1 cm (Mantis #128: prima l'allegato usciva in miniatura). Non controlla che ci sia un documento.
- **Salva** (azione `FileSaveAs`, filtro `Pdf|*.pdf|Tutti|*.*`): copia il file mostrato nel percorso scelto con `TFile.Copy` (sovrascrivendo la destinazione se esiste; se `FileName` è vuoto o il file è sparito non fa nulla, DIV-FVW-7 corretta nel rilascio 014) e apre la cartella di destinazione in Esplora risorse. Il file è una copia byte per byte dell'originale, non un PDF riscritto da DevExpress (richiesta del 2013: un file ricomposto veniva contestato da Poste online). L'azione `SalvaExecute` esiste ma è vuota.
- **Adobe** (azione `ApriConAdobe`): se il file esiste lo apre con l'applicazione associata (`ShellExecute 'open'`).
- **Chiusura** (`CloseFile`): azzera `FileName`, svuota il visualizzatore se c'è un documento e aggiorna la barra di stato.

### Scenario: stampa in scala
- **Dato** un PDF caricato
- **Quando** l'utente apre la finestra di stampa
- **Allora** la scala è «adatta alla pagina» e i margini sono 1 cm

### Scenario: salvataggio su un file esistente
- **Dato** un PDF mostrato e un file di destinazione già presente
- **Quando** l'utente conferma il salvataggio
- **Allora** `TFile.Copy` solleva un'eccezione e la cartella non viene aperta

### Scenario: blocco nella barra di stato
- **Dato** `Locked` vero e il riquadro che si svuota
- **Quando** si aggiorna la barra di stato
- **Allora** il pannello 1 è visibile e mostra `!`

## ZBASE-FVW-010 Azioni degli strumenti e configurazione
Il riquadro implementa `IzBaseComponent` / `IzBaseDbComponent`: `GetComponentType` restituisce `ctFile`, `GetToolbar` la barra `dxBarManagerBar`, `ID` e `ToolActions` si leggono e scrivono. Il `ID` è la chiave del componente nel dizionario LZ (`Base.zFiles`, un `TzFileViewerProps` con dataset, campo, campo OID, cartella, blocco e azioni degli strumenti). `Init` ricostruisce le azioni degli strumenti dalle proprietà LZ e le mette nella barra; senza `ID` (o senza dizionario) non c'è nessuna proprietà e `Init` non fa niente. `AddAction(Azione, ImmagineLista)` registra un'azione da codice nelle proprietà LZ (marcandola `FromCode`, perché la lettura del dizionario non la cancelli) e restituisce la sua voce; con azione nulla, o senza proprietà LZ, restituisce nullo (DIV-FVW-10); l'elenco delle immagini è ignorato. `ExecuteToolConfig` e l'azione **EditTools** (finestra di configurazione degli strumenti) sono riservate all'amministratore: per un utente normale non fanno niente e l'azione è nascosta.

### Scenario: azione nulla
- **Dato** un riquadro qualunque
- **Quando** si chiama `AddAction(nil, nil)`
- **Allora** il risultato è nullo

### Scenario: componente di tipo file
- **Dato** un riquadro appena creato
- **Quando** si legge `ComponentType` dall'interfaccia `IzBaseComponent`
- **Allora** vale `ctFile`

## ZBASE-FVW-011 Generazione di un PDF da un modello (`GenerateFromTemplate`)
`GenerateFromTemplate(DataSet, NomeModello, NomeDestinazione, FillFieldProc, BeforeSavePdfProc)` carica il modello PDF, riempie i suoi campi e salva il risultato in `NomeDestinazione`; il codice porta il commento «eliminare» e nessun chiamante di WT, Gesty o zPack lo usa (`zOffice.Pdf.Frame` ha una propria copia). Regole, per ogni campo del modulo:
- se è presente `FillFieldProc`, la si chiama prima di tutto; il campo è elaborato dal resto solo se la procedura imposta `Continue` a vero;
- il campo diventa scrivibile, poi il suo nome (`FullName`, senza `@`) viene cercato come campo del dataset;
- un nome che **comincia per `@`** chiede il valore all'utente: casella di scelta Sì/No/Annulla per le caselle di controllo, `InputQuery` per i testi; Annulla salta il campo; i campi di tipo elenco, casella combinata e gruppo di scelta non sono gestiti;
- campo trovato: la casella di controllo si imposta da un campo booleano oppure da un campo testo uguale a `S` (altro tipo: eccezione `Conversione non valida per il campo ...`), il gruppo di scelta da un campo numerico (indice), il testo con `AsString`; il campo compilato diventa di sola lettura;
- campo di testo **non trovato** nel dataset: viene scritto `Campo NOME non trovato.` e il campo diventa di sola lettura;
- prima di salvare si chiama `BeforeSavePdfProc`, se presente.
L'evento `OnGenerateFromTemplate(Sender)` è un altro meccanismo: l'azione **GeneraDaTemplate** è visibile solo se l'evento è assegnato e, premuta, lo richiama.

### Scenario: campo mancante
- **Dato** un modello con il campo di testo `RAGIONE_SOCIALE` e un dataset senza quel campo
- **Quando** si genera il PDF
- **Allora** il campo contiene `Campo RAGIONE_SOCIALE non trovato.`

### Scenario: evento non assegnato
- **Dato** un riquadro senza `OnGenerateFromTemplate`
- **Quando** la barra si aggiorna
- **Allora** l'azione **GeneraDaTemplate** non è visibile

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FVW-1 ✅ (corretta) | `SetFileName` prima di `Init` conservava il nome ma né `Init` né il passaggio a visibile lo caricavano. Corretta nel rilascio 016: `Init` apre il `FileName` conservato | Nessuna |
| DIV-FVW-2 ✅ (corretta) | `DataSourceDataChange` chiamava `Reload` per qualunque evento, anche per la modifica di un campo del record corrente. Corretta nel rilascio 014: `Reload` parte solo per il cambio di record (`Field` nullo) o per la modifica del campo `FieldName` | Nessuna |
| DIV-FVW-3 🟢 (dedotta) | `dbOpenFile` con un campo `FieldName` inesistente esce senza svuotare il riquadro (il dataset vuoto e il campo vuoto lo svuotano), e con dataset nullo esce senza chiudere il metodo di registro (`EnterMethod` senza `LeaveMethod`; vale anche per l'uscita sul campo mancante) | Con un campo configurato male il riquadro mostra il PDF del record precedente senza segnalare l'errore di configurazione; il registro SmartInspect resta con un livello di annidamento aperto |
| DIV-FVW-4 🟢 (dedotta) | `SetLocked` non aggiorna la barra di stato: il pannello `!` compare solo al successivo `CloseFile` o caricamento | Subito dopo aver bloccato un riquadro che mostra un PDF il segno di blocco non si vede |
| DIV-FVW-5 🟢 (dedotta) | `TFileType`, `FileType` e `ftImage` non sono usati; `Loading` viene messo a vero in `OpenFile` e non torna mai falso né è letto; `OldActiveControl` viene assegnato e subito azzerato, quindi il ripristino del fuoco dopo il caricamento non avviene mai; `FrameViewer` (variabile globale), `AcroPDFMessage`, `SalvaExecute` e `gtPDFViewerViewerChange` sono residui del vecchio visualizzatore Acrobat | Codice morto che fa credere che il riquadro gestisca le immagini e che ripristini il fuoco; dopo il caricamento il fuoco resta dove l'ha lasciato DevExpress |
| DIV-FVW-6 ✅ (corretta) | `SetDataSet` non chiedeva la notifica di distruzione del dataset: il riquadro restava con un puntatore non valido se il dataset aveva un altro proprietario. Corretta nel rilascio 014 (`SetDataSet` chiama `FreeNotification`) | Nessuna |
| DIV-FVW-7 ✅ (corretta) | `FileSaveAsAccept` copiava senza sovrascrittura e senza controllare che `FileName` fosse non vuoto e il file esistente. Corretta nel rilascio 014 (esce senza fare nulla se manca l'origine, sovrascrive la destinazione); senza prova automatica, perché apre Esplora risorse | Nessuna |
| DIV-FVW-8 🟢 (dedotta) | `GetzDataSet` usa `FDataSet as TzFbDataSet`: con un dataset che non è un `TzFbDataSet` solleva `EInvalidCast`, mentre `DataSet` accetta qualunque `TDataSet` | Il chiamante di `IzBaseDbComponent` (editor LZ, controller) può cadere se qualcuno assegna a `DataSet` un dataset di altro tipo; oggi lo assegna solo codice che passa `TzFbDataSet` |
| DIV-FVW-9 🟢 (dedotta) | `GenerateFromTemplate` ha `// eliminare` nel sorgente, non ha chiamanti, ed è duplicata in `TzViewerPdfFrame`; i gruppi di scelta, gli elenchi e le caselle combinate dei moduli con nome che comincia per `@` non chiedono nessun valore | Codice destinato a sparire e già divergente dalla copia in `zOffice.Pdf.Frame`: correggerne uno senza l'altro le fa divergere ancora |
| DIV-FVW-10 🟢 (dedotta) | Il commento di `IzBaseComponent.Props` dice «sempre assegnato: il componente crea il props se manca», ma `GetProps` restituisce nullo quando mancano `ID` o dizionario (`EnsureProps` crea il props solo con `Base` assegnato e `ID` non vuoto) | Chi legge `Props` dall'interfaccia senza controllare riceve un puntatore nullo per un riquadro creato a mano senza `ID` |

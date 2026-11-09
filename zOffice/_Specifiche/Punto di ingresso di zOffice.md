---
area: Punto di ingresso di zOffice
progetto: zOffice
aggiornato: 2026-11-02
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/010
---

# Punto di ingresso di zOffice

Questa specifica descrive la unit `zOffice\zOffice.pas`, la facciata con cui le applicazioni aprono un file con il visualizzatore giusto, compongono o inviano posta, modificano un modello Word o Excel e generano un documento da un modello. Descrive anche i tipi di file riconosciuti (`TzFileType` e il suo helper, in `zOffice\zOffice.types.pas`), perché è da lì che la facciata sceglie il visualizzatore. La unit è sottile: ogni procedura rimanda alla unit del visualizzatore (`zOffice.Word.Form`, `zOffice.Excel.Form`, `zOffice.Pdf.Form`, `zOffice.Image.Form`, `zOffice.SynEdit.Form`, `zOffice.Mail.Form`, `zOffice.Mail.Editor`, `zOffice.Word.Editor`, `zOffice.Word.MailMerge`, `zOffice.Excel.Editor`), il cui comportamento interno è nelle specifiche `Documenti Word e stampa unione.md` (ZOFF-WRD), `Posta.md` (ZOFF-MAI), `Stampe.md` (ZOFF-STA) e `Stampe in lotto.md` (ZOFF-LOT). Non descrive form, ribbon e disposizione dei controlli.

La unit è compilata da tutti i programmi che la citano: `zOffice` compare nella clausola `uses` di 13 file di WT e Gesty (`ConfigModule`, `zTemplates.Doc.Form` di WT, `dmGeDoEmail`, `dmRichieste`, `dmAttrezzature`, `dmFrontOffice`, `dmOrientamento`, `dmRisorse`, `dmRiunioni`, `dmScheduler.Tools`, `WizInserimentoIncaricoDM`), nei `ConfigModule` di zTicser e in `zBase\zExceptions`, `zExceptions.form` e `zSystem`; il resto dei 47 file di WT e Gesty che nominano zOffice usa soltanto le sue unit interne (`zOffice.Types`, `zOffice.Mail.Utils`, `zOffice.Reports.*`). Nessuna applicazione chiama oggi `ViewFile` generico: lo chiamano i riquadri del visualizzatore multiplo (`Word`, `Excel`, `Image`, `Pdf`, `SynEdit`, `Mail` Frame, azione «Apri»), la finestra di composizione per aprire un allegato con doppio clic e `zOffice.Mail.Utils` (`ShowAttachmentFile`) per aprire un allegato di un messaggio letto. `TzFileType.FromFileName` lo usa Gesty in `Files.Lib` per scrivere il tipo del file nel database (`File_Type`). `MailMerge` e `EditTemplateWord` sono chiamate da WT in `zTemplates.Doc.Form`.

**Come funziona.** `ViewFile(nome)` ricava il tipo dal nome del file (solo dall'estensione, mai dal contenuto) e chiama la procedura del tipo; `ViewFile(tipo, nome)` salta il riconoscimento. Ogni visualizzatore è una finestra modale creata con `Application.CreateForm` e liberata alla chiusura: la procedura torna al chiamante solo quando l'utente chiude la finestra. Le procedure per Word, Excel, posta e modelli sono rimandi diretti alle unit dei visualizzatori. L'unico stato della unit è la variabile `SMTPServerParams`, inizializzata all'avvio con `Init`.

**Test che coprono quest'area.** Nessuna unit esistente. `Test.zOffice.pas` prova il riconoscimento del tipo dal nome, la conversione da e verso il codice di una lettera, l'indice dell'icona, l'apertura dei tipi non gestiti con il programma di sistema (sostituito nei test da `SystemOpenProc`), i parametri di `ViewFileWord` e `CheckSMTPServerParams`. Non si provano i visualizzatori: sono finestre modali.

## ZOFF-OFF-001 Tipo di file dall'estensione
`TzFileType.FromFileName(nome)` guarda solo l'estensione, senza distinguere maiuscole e minuscole (`ExtractFileExt` poi `ToLower`), e restituisce:

| Estensioni | Tipo |
|---|---|
| `.pdf` | `ftPdf` |
| `.doc`, `.docx`, `.rtf` | `ftWord` |
| `.xls`, `.xlsx`, `.csv` | `ftExcel` |
| `.bmp`, `.png`, `.jpeg`, `.jpg` | `ftImage` |
| `.eml` | `ftMail` |
| `.txt` | `ftTXT` |
| `.xml` | `ftXML` |
| `.json` | `ftJSON` |
| ogni altra, o nessuna | `ftNone` |

Il percorso non conta: si guarda l'estensione dell'ultimo elemento (`C:\cartella.eml\nome` non ha estensione). `zAllFileTypes` contiene tutti i tipi tranne `ftNone`.

### Scenario: maiuscole e percorso
- **Dato** il nome `C:\Dati\Lettera.DOCX`
- **Quando** si chiama `TzFileType.FromFileName`
- **Allora** il risultato è `ftWord`

### Scenario: estensione non gestita
- **Dato** i nomi `foto.gif`, `registro.log`, `foglio.xlsm`, `archivio.zip` e `senzaestensione`
- **Quando** si chiama `FromFileName`
- **Allora** il risultato è sempre `ftNone`

## ZOFF-OFF-002 Codici e icone dei tipi
Ogni tipo ha un codice di una lettera, usato per scriverlo nel database: `ftPdf` `P`, `ftWord` `W`, `ftExcel` `E`, `ftImage` `I`, `ftMail` `M`, `ftTXT` `T`, `ftXML` `X`, `ftJSON` `J`, `ftNone` testo vuoto. Leggendo il codice (`AsString := ...`) si ignorano spazi e maiuscole; un codice sconosciuto o vuoto dà `ftNone`. `ImageIndex` dà l'indice dell'icona nella galleria delle applicazioni: `ftNone` 0, `ftPdf` 1, `ftWord` 2, `ftExcel` 3, `ftImage` 4, `ftMail` 5, `ftTXT` 6, `ftXML` 7, `ftJSON` 8.

### Scenario: codice con spazi
- **Dato** il testo `' w '`
- **Quando** lo si assegna ad `AsString`
- **Allora** il tipo è `ftWord`

### Scenario: scrittura nel database di Gesty
- **Dato** il file `verbale.pdf`
- **Quando** `Files.Lib` scrive `TzFileType.FromFileName(nome).AsString`
- **Allora** nel campo `File_Type` finisce `P`

## ZOFF-OFF-003 Apertura per tipo
`ViewFile(tipo, nome, soloLettura)` sceglie il visualizzatore così:

| Tipo | Chiamata | `soloLettura` |
|---|---|---|
| `ftPdf` | `ViewFilePdf(nome)` | non applicabile |
| `ftWord` | `ViewFileWord(nome, soloLettura)` | passato |
| `ftExcel` | `ViewFileExcel(nome, soloLettura)` | passato |
| `ftImage` | `ViewFileImage(nome)` | **non passato** (vale il predefinito falso) |
| `ftMail` | `ViewFileMail(nome, SMTPServerParams, nil)` con inoltro e risposta consentiti | non applicabile |
| `ftTXT`, `ftXML`, `ftJSON` | `ViewFileSynEdit(nome)` | non applicabile: l'editor di testo è in sola lettura nel file della form |
| `ftNone` | `OpenWithSystemProgram(nome)`: apre il file con il programma associato da Windows (`ShellExecute` con il verbo `open`) | non applicabile |

`OpenWithSystemProgram` non fa niente se il nome è vuoto; se Windows non riesce ad aprire il file (nessun programma associato, file inesistente) solleva `Exception('Impossibile aprire il file "<nome>" con il programma di sistema.')`. La variabile `zOffice.SystemOpenProc`, se assegnata, prende il posto di `ShellExecute`: serve ai test per non lanciare programmi veri. Attenzione: la procedura torna subito, senza aspettare la chiusura del programma esterno, quindi chi apre una copia temporanea non può eliminarla subito dopo la chiamata per questi tipi. `ShowAttachmentFile` lo rispetta: per i tipi non gestiti (`FromFileName` dà `ftNone`) non elimina la copia temporanea, che resta nella cartella dell'allegato e viene sostituita alla prossima apertura dello stesso allegato.

La forma senza tipo (`ViewFile(nome, soloLettura)`) ricava prima il tipo con `FromFileName`. Le due forme di `ViewFileMail` e `WriteMail` con `TSMTPServerParams` ricevono i parametri dal chiamante; solo `ViewFile` usa la variabile globale `SMTPServerParams` (ZOFF-OFF-006) e non passa nessuna rubrica degli indirizzi.

### Scenario: file Excel in sola lettura
- **Dato** `ViewFile('C:\Prospetti\costi.xlsx', True)`
- **Quando** la facciata sceglie il visualizzatore
- **Allora** apre il visualizzatore Excel con la modifica disabilitata (`OptionsBehavior.Editing = False`)

### Scenario: file CSV
- **Dato** `ViewFile('C:\Import\righe.csv')`
- **Quando** la facciata sceglie il visualizzatore
- **Allora** si apre il visualizzatore Excel, non l'editor di testo

### Scenario: tipo non gestito
- **Dato** `ViewFile('C:\Dati\archivio.zip')`
- **Quando** viene chiamata
- **Allora** il file si apre con il programma che Windows associa a `.zip`, senza finestre di zOffice

### Scenario: nome vuoto
- **Dato** `ViewFile(ftNone, '')`
- **Quando** viene chiamata
- **Allora** non succede niente: nessuna apertura, nessun messaggio, nessuna eccezione

## ZOFF-OFF-004 Visualizzatori modali
Ogni visualizzatore (`Word`, `Excel`, `Pdf`, `Image`, `SynEdit`) nasce con `Application.CreateForm`, mostra la finestra con `ShowModal` e la libera in un `try/finally`. Conseguenze per chi chiama: la procedura torna solo alla chiusura della finestra; il file aperto da questi visualizzatori si può quindi eliminare subito dopo la chiamata (lo fa `ShowAttachmentFile` con la copia temporanea di un allegato; non vale per i tipi aperti col programma di sistema, ZOFF-OFF-003); un errore nel caricamento esce dalla procedura dopo la liberazione della form.

### Scenario: allegato temporaneo
- **Dato** un allegato `preventivo.pdf` copiato in una cartella temporanea
- **Quando** `ShowAttachmentFile` chiama `ViewFile` e l'utente chiude il visualizzatore
- **Allora** la copia temporanea viene eliminata e l'originale non viene toccato

### Scenario: allegato di tipo non gestito
- **Dato** un allegato `elenco.zip` copiato in una cartella temporanea
- **Quando** `ShowAttachmentFile` chiama `ViewFile`, che lo affida al programma di sistema e torna subito
- **Allora** la copia temporanea non viene eliminata, perché il programma potrebbe non averla ancora aperta

## ZOFF-OFF-005 File mancante
I visualizzatori `Pdf`, `Image`, `SynEdit`, `Word` ed `Excel` caricano il file solo se esiste (`FileExists`): se manca si apre ugualmente una finestra vuota, senza messaggio. Il visualizzatore Excel azzera il foglio prima del controllo, quindi mostra un foglio vuoto.

### Scenario: percorso errato
- **Dato** `ViewFile('C:\Dati\non-c-e.pdf')`
- **Quando** viene chiamata
- **Allora** si apre il visualizzatore PDF senza documento e senza avviso

## ZOFF-OFF-006 Parametri SMTP globali
La variabile `zOffice.SMTPServerParams` è inizializzata con `Init` all'avvio (porta -1, nessuna autenticazione impostata, `ssl` `N`: vedi ZOFF-MAI-001) e non vale niente finché l'applicazione non la riempie. `CheckSMTPServerParams` solleva `Exception('Parametri SMTP non configurati.')` se `SMTPServerParams.IsValid` è falso e non fa niente altrimenti. Le procedure `SendMail`, `WriteMail` e `ViewFileMail` non leggono la variabile: usano il parametro che ricevono. Gesty e zTicser la riempiono all'accesso (`InitSMTPServerDefault`, stored procedure `SMTP_PARAMS_DEFAULT`) e le procedure di Gesty che compongono una mail (`dmAttrezzature`, `dmFrontOffice`, `dmOrientamento`, `dmRisorse`) chiamano `CheckSMTPServerParams` prima di `WriteMail`. WT non la riempie mai: i suoi moduli (`dmGeDoEmail`, `dmRichieste`) e quelli di Gesty che scelgono un account diverso (`dmRiunioni`, `dmScheduler.Tools`, `WizInserimentoIncaricoDM`, e `zSystem` per il codice OTP) dichiarano una variabile locale con lo stesso nome `SMTPServerParams`, che nasconde il globale, e passano quella.

### Scenario: parametri non configurati
- **Dato** `SMTPServerParams` appena inizializzato
- **Quando** si chiama `CheckSMTPServerParams`
- **Allora** viene sollevata l'eccezione «Parametri SMTP non configurati.»

### Scenario: parametri validi
- **Dato** `Host` valorizzato, `Port = 25`, `ssl = 'N'` e `ssl_ver = '1'`
- **Quando** si chiama `CheckSMTPServerParams`
- **Allora** la procedura termina senza eccezioni

## ZOFF-OFF-007 Stampa unione, modelli e prospetti
`MailMerge(parametri)` chiama `zOffice.Word.MailMerge.MailMerge`, che restituisce un flusso con il documento generato, oppure `nil` se l'utente ha annullato la generazione. Con un flusso valido la facciata lo mostra con `ViewFileWord(flusso, parametri)` e lo libera al ritorno del visualizzatore (sempre, anche in caso di errore); con `nil` non apre niente. `EditTemplateWord`, `EditTemplateExcel` e `BuildSpreadSheetReport` rimandano senza altra logica agli editor (ZOFF-WRD-009..011 per Word; il comportamento interno di Excel non ha ancora una specifica). `ViewFileWord(nome, soloLettura)` prepara i parametri con `NewWordParamsForFile`: `Init` (nessun gancio), poi `FileName`, `ReadOnly` e formato `Undefined`, così il visualizzatore riconosce il formato dal contenuto e apre anche `.doc` e `.rtf`, come il riquadro del visualizzatore multiplo. Le altre forme di `ViewFileWord` usano il formato che il chiamante ha messo nei parametri (`OpenXML` dopo `Init`).

### Scenario: generazione annullata
- **Dato** una stampa unione che l'utente annulla nella finestra di avanzamento
- **Quando** `MailMerge` riceve `nil` dal motore
- **Allora** non si apre nessun visualizzatore e non c'è nessun flusso da liberare

## Divergenze note
Le divergenze seguenti si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-OFF-1 ✅ (corretta nel rilascio 010: `ViewFile` apre questi tipi con il programma di sistema) | `ViewFile` ignorava in silenzio i file di tipo non riconosciuto (`ftNone`) e quelli con estensione non elencata, come `.zip`, `.msg`, `.gif`, `.htm`, `.log` | un doppio clic su un allegato di questi tipi, dalla finestra di composizione o dalla lettura di un messaggio, sembra non fare niente: nessun avviso e nessuna apertura con il programma di sistema |
| DIV-OFF-2 🟡 (dedotta; difetto di WT, annotato come R-217: WT deve valorizzare `SMTPServerParams`, zOffice non si tocca) | `ViewFile` per i `.eml` passa la variabile globale `SMTPServerParams`, che in WT non viene mai valorizzata (la riempiono solo Gesty e zTicser); in WT e in parte di Gesty diverse variabili locali con lo stesso nome nascondono il globale | in WT l'apertura di un `.eml` con `ViewFile` o dal visualizzatore multiplo mostra il messaggio, ma risposta e inoltro partono con parametri non validi e non si possono inviare; il nome uguale rende facile sbagliare quale dei due si sta usando |
| DIV-OFF-3 ✅ (corretta nel rilascio 010: formato `Undefined`) | `ViewFileWord(nome, soloLettura)` preparava `TWordParams` con formato `OpenXML` fisso, e il visualizzatore carica con `LoadDocument(nome, OpenXML)`, mentre `FromFileName` manda a Word anche `.doc` e `.rtf`; il riquadro del visualizzatore multiplo usa invece `Undefined` (formato rilevato dal contenuto) | l'apertura con `ViewFile` di un `.doc` o `.rtf` può fallire o mostrare un documento illeggibile, mentre nello stesso file aperto dal riquadro funziona; manca una prova eseguita |
| DIV-OFF-4 🟢 (dedotta) | `ViewFile` non passa `soloLettura` a `ViewFileImage`, e il visualizzatore delle immagini, anche quando riceve il parametro, non lo usa (`ShowFile` carica il file e mostra la finestra senza assegnare `ReadOnly`) | l'immagine si può tagliare, incollare o cancellare nella finestra anche quando il chiamante ha chiesto la sola lettura; il file su disco non cambia se non con «Salva con nome» |
| DIV-OFF-5 🟢 (dedotta) | per file mancante i visualizzatori mostrano una finestra vuota senza segnalare l'errore (ZOFF-OFF-005) | un percorso sbagliato passa inosservato; chi vuole l'avviso deve controllare `FileExists` prima |

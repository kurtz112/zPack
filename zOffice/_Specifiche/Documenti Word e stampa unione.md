---
area: Documenti Word e stampa unione
progetto: zOffice
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/004
---

# Documenti Word e stampa unione

Questa specifica descrive come un modello Word (`.docx`) diventa un documento: la stampa unione con i dati dei dataset, i campi, i frammenti, le immagini (dai campi del database, dai grafici, dalla rete) con le loro misure, i collegamenti ipertestuali, e poi il visualizzatore che salva ed esporta in PDF e l'editor in cui si scrivono i modelli. Il codice è in `zOffice\zOffice.Word.MailMerge.pas` (motore), `zOffice.Word.Utils.pas` (frammenti, misure delle immagini), `zOffice.Word.UriStreamProvider.pas` (immagini), `zOffice.Word.Form.pas` (visualizzatore), `zOffice.Word.Editor.pas` (editor dei modelli) e `zOffice.Word.Frame.pas` (riquadro Word del visualizzatore multiplo); i parametri stanno in `TWordParams` di `zOffice.types`. Lo usano WT e Gesty attraverso `TzReportsManager` (`Stampe.md`, ZOFF-STA-006), che assegna i parametri; Gesty usa anche direttamente il visualizzatore, e il riquadro serve `zOffice.MultiViewer`.

**Come funziona.** Il motore carica il modello in un server di documenti DevExpress, ne raccoglie le misure delle immagini, esegue l'unione in un documento in memoria (dove i campi `DOCVARIABLE` si risolvono con le variabili, i campi dei dataset o i frammenti), riapplica le misure, sostituisce i collegamenti ipertestuali e salva il risultato in un flusso che il visualizzatore apre. Nei modelli un campo si scrive come `DOCVARIABLE <collegamento>.<CAMPO>` e un'immagine come `INCLUDEPICTURE dbimg://"<collegamento>.<CAMPO>" @L:A`.

**Test che coprono quest'area.** Nessuna.

## ZOFF-WRD-001 Generazione e visualizzazione
`zOffice.MailMerge(parametri)` genera il documento dal modello `TemplateFileName` e lo apre nel visualizzatore modale. Durante l'unione la barra di avanzamento (se assegnata) avanza a ogni record; se l'utente annulla, non si produce nessun documento e il visualizzatore non si apre.

### Scenario: annullamento
- **Dato** una stampa unione in corso con la barra di avanzamento
- **Quando** l'utente preme Annulla
- **Allora** l'unione si ferma e nessuna finestra si apre

## ZOFF-WRD-002 Dataset principale
Il dataset dell'unione è quello che ha il nome del modello senza estensione; se non c'è, quello restituito per il nome vuoto (nel manager, il dataset selezionato). Se non c'è nemmeno quello compare «MailMerge: dataset non trovato». I record uniti sono quelli selezionati del dataset (opzione `MergeRecords = Selected` di DevExpress).

### Scenario: dataset col nome del modello
- **Dato** il modello `Contratto.docx` e un dataset `Contratto` nel manager
- **Quando** si genera il documento
- **Allora** i dati vengono da `Contratto`, non dal dataset selezionato

## ZOFF-WRD-003 Valore di un campo
Un campo `DOCVARIABLE nome` si risolve così: prima `OnGetVariable` (nel manager: variabili, dizionario ed espressioni, ZOFF-STA-008), se restituisce un valore diverso da `Null`; poi il campo del dataset, con `nome` nella forma `DataSet.Campo` (il dataset si cerca per nome o per nome del collegamento) o `Campo` (dataset principale). Un campo memo dà il testo intero, ogni altro campo il testo formattato (`DisplayText`). Un nome che non si risolve passa ai frammenti (ZOFF-WRD-004); se nemmeno quelli rispondono, il campo resta senza valore. Le date seguono il formato della lingua della macchina.

### Scenario: campo di un dataset
- **Dato** il campo `DOCVARIABLE dmRisorse_Risorse.COGNOME` e il cognome `Rossi`
- **Quando** si genera il documento
- **Allora** al posto del campo compare `Rossi`

## ZOFF-WRD-004 Frammenti
Un frammento è un documento Word che si unisce a parte e si inserisce al posto di un campo. Si riconosce da `word.fragments` del JSON (`variable`, `template`, `dataset`) oppure, per convenzione, dal file `<modello>~~~<variabile>.docx` accanto al modello; un percorso senza cartella si cerca nella cartella del modello. Il dataset del frammento è quello dichiarato o, per convenzione, quello col nome della variabile; senza dataset il campo resta vuoto. Il frammento unisce tutti i record del suo dataset in un'unica tabella (`JoinTables`), e i suoi campi si risolvono con le stesse regole. I file dei frammenti non compaiono fra i modelli (ZOFF-STA-001).

### Scenario: elenco dei corsi in un contratto
- **Dato** `Contratto.docx` con il campo `DOCVARIABLE Corsi` e il file `Contratto~~~Corsi.docx`, e un dataset `Corsi` con tre righe
- **Quando** si genera il contratto
- **Allora** al posto del campo compare una tabella di tre righe

## ZOFF-WRD-005 Immagini
L'immagine di un campo `INCLUDEPICTURE` si cerca, in quest'ordine: indirizzi `http…` scaricati dalla rete (accettati solo se sono davvero immagini); grafici aperti `chart://Nome` (`zOffice.Grafici`); campo grafico (`BLOB` di tipo grafico, non nullo) indicato da `dbimg://DataSet.Campo`; immagini registrate in anticipo con `dbimg://<nome>`. Il manager registra tutti i campi grafici del dataset principale e gli alias `Header`, `Logo`, `Footer`, `FirmaDirettore`, `FirmaLegaleRappresentante`, `FIRMA_RESPONSABILE`, `FIRMA_COORDINATORE_CORSO`, `FIRMA_REFERENTE_SEGRETERIA`, `LOGO_INTESTAZIONE`, `LOGO_FOOTER` dai campi `CARTA_INTESTATA_*` e omonimi. Un'immagine che non si trova resta vuota, senza il quadratino segnaposto. I nomi si confrontano senza distinguere maiuscole e minuscole.

### Scenario: logo della carta intestata
- **Dato** un dataset con il campo `CARTA_INTESTATA_LOGO_INTESTAZ` valorizzato e un modello con `INCLUDEPICTURE dbimg://Header`
- **Quando** si genera il documento
- **Allora** nell'intestazione compare il logo

## ZOFF-WRD-006 Misure delle immagini
La misura voluta di un'immagine sta nel codice del suo campo, dopo il primo `@`: `@L:A` (larghezza e altezza in centimetri) o `@L` (solo larghezza, altezza in proporzione). Si scrive sempre con il punto decimale, si legge anche con la virgola; larghezza zero o negativa non è una misura. Un suffisso che non è una misura (come `@hidden`) si lascia com'è. Nella stampa unione le misure si leggono dal modello prima dell'unione e si riapplicano al documento unito, abbinandole per indirizzo dell'immagine, poi nell'ordine del modello. Nell'editor e nel visualizzatore le immagini più larghe dello spazio fra i margini si riducono in proporzione.

### Scenario: misura con la virgola
- **Dato** un modello vecchio con `INCLUDEPICTURE dbimg://Header @17,8:1,98`
- **Quando** si genera il documento
- **Allora** l'immagine misura 17,8 × 1,98 cm

## ZOFF-WRD-007 Collegamenti ipertestuali calcolati
Un collegamento la cui destinazione comincia con `@` ha la forma `@<variabile del testo>=<variabile dell'indirizzo>`: dopo l'unione il testo e l'indirizzo si prendono da `OnGetHyperLink` o, se non assegnata, dalle due variabili (ZOFF-WRD-003). Se non si risolvono, il collegamento si toglie dal documento. Vale per il corpo, l'intestazione e il piè di pagina.

### Scenario: collegamento senza valori
- **Dato** un collegamento `@LinkTesto=LinkUrl` e nessuna delle due variabili
- **Quando** si genera il documento
- **Allora** il collegamento non compare

## ZOFF-WRD-008 Visualizzatore
Il visualizzatore apre il documento in sola lettura se `ReadOnly` è vero (`word.readOnly` del JSON), chiama `BeforeShowProc` con il nome del modello (un suo errore si mostra ma non impedisce l'apertura) e, se il manager ha azioni documentali, mostra il gruppo «Documento» (ZOFF-STA-013). Salva sul file `FileName` o, se vuoto, chiede dove (cartella proposta `Documenti`); chiudendo con modifiche chiede «Attenzione: si vuole salvare le modifiche effettuate?». L'esportazione PDF prende il nome del file dal metodo `pdf.method`: `dialog` lo chiede (cartella `Documenti`, e il filtro scelto decide l'incorporazione dei font), `filename` usa `pdf.FileName`, `fieldname` usa il valore del campo `pdf.FieldName` del dataset principale con estensione `.pdf`, `tempfile` un file temporaneo cancellato subito dopo l'esportazione e dopo `AfterExportProc`. Un nome senza cartella va in `Documenti`. Dopo l'esportazione chiede se aprire il file (`OpenFileAfterExport`, mai con `tempfile`) oppure avvisa «File pdf generato.» (`ShowMessageAfterExport`, predefinito vero).

### Scenario: PDF con il nome da un campo
- **Dato** `pdf.method = "fieldname"`, `pdf.fieldName = "NOME_FILE"` e il campo che vale `Contratto_123`
- **Quando** l'utente esporta in PDF
- **Allora** si crea `Documenti\Contratto_123.pdf`

## ZOFF-WRD-009 Editor dei modelli: campi e immagini
L'editor (`EditTemplateWord`) propone i dataset del manager e i loro campi; inserire un campo scrive `DOCVARIABLE <collegamento>.<CAMPO>`, inserire un campo grafico scrive `INCLUDEPICTURE dbimg://"<collegamento>.<CAMPO>"`, nel corpo, nell'intestazione o nel piè di pagina secondo dove sta il cursore. I campi con `@hidden` si mostrano in rosso a richiesta e si nascondono prima di salvare. Senza dataset l'editor propone tre campi d'esempio (`CAMPO_1`, `CAMPO_2`, `CAMPO_3`). Il comando di stampa unione salva (se serve) e genera il documento come ZOFF-WRD-001.

### Scenario: inserimento di un campo
- **Dato** il dataset `Risorse` del manager di `dmRisorse` e il campo `COGNOME`
- **Quando** l'utente lo inserisce nel modello
- **Allora** nel modello compare `DOCVARIABLE dmRisorse_Risorse.COGNOME`

## ZOFF-WRD-010 Editor dei modelli: salvataggio
Salvare chiede «Attenzione: si vuole salvare il template?», copia prima il file che si sta salvando (il modello o il frammento aperto) in `__backup\<aaaammgghhnnss>_<file>` accanto a esso (anche oltre i 260 caratteri, Mantis #131), scrive nel codice di ogni `INCLUDEPICTURE` la misura attuale della sua immagine (ZOFF-WRD-006) e salva. Un modello nuovo, senza nome, apre «Salva con nome» nella cartella del gruppo (`DefaultFolder`); se l'utente annulla lì, si annulla anche la chiusura o il cambio di frammento che aveva chiesto il salvataggio.

### Scenario: modello nuovo
- **Dato** l'editor aperto da `NewReport` sul gruppo `Contratti`
- **Quando** l'utente salva
- **Allora** la finestra «Salva con nome» si apre nella cartella `Reports\Contratti`

## ZOFF-WRD-011 Editor dei modelli: frammenti
Aggiungere un frammento richiede un modello già salvato («Salvare prima il template: …») e un nome non vuoto e non già usato. Se il chiamante gestisce il JSON (`OnAddFragment`), è lui a decidere il file e ad aggiornare `word.fragments`; altrimenti vale la convenzione `<modello>~~~<nome>.docx`. Se il file non esiste si crea un documento Word vuoto. Eliminare un frammento chiede conferma, toglie prima la voce dal JSON (se la rimozione fallisce l'eliminazione si annulla con un messaggio), poi copia il file in `__backup` e lo cancella; il modello principale non si può eliminare.

### Scenario: eliminazione con JSON non aggiornabile
- **Dato** un frammento dichiarato nel JSON e `OnRemoveFragment` che restituisce `False`
- **Quando** l'utente lo elimina
- **Allora** compare «Il fragment non e' stato tolto dalla configurazione JSON del report: eliminazione annullata.» e il file resta

## ZOFF-WRD-012 Riquadro Word del visualizzatore multiplo
Il riquadro apre un file Word esistente (un nome inesistente lo svuota), stampa e mostra l'anteprima di stampa solo con un file aperto, crea la stampante DevExpress solo al primo uso (Mantis #156: così aprire il riquadro non legge la stampante predefinita) e genera un PDF con `GeneraPdf(percorso)`, che restituisce vero se il file esiste dopo l'esportazione.

### Scenario: stampa senza documento
- **Dato** il riquadro senza file aperto
- **Quando** si guarda il comando Stampa
- **Allora** è disabilitato

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-202 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. La perdita delle chiavi del JSON quando l'editor aggiunge o toglie un frammento è DIV-STA-1 di `Stampe.md`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-WRD-1 🟡 (dedotta) | Con il dataset non trovato il motore avvisa ma restituisce un flusso vuoto invece di `nil`, e `zOffice.MailMerge` apre lo stesso il visualizzatore | Dopo l'avviso l'utente vede un documento bianco |
| DIV-WRD-2 🟡 (dedotta) | Con `pdf.method = "tempfile"` il visualizzatore cancella il PDF anche quando il nome gli è stato passato dal chiamante, come nell'esportazione per la persistenza del documento (ZOFF-STA-016) | Un modello con `"tempfile"` nel JSON non riesce a persistere il documento: `PersistDocument` riceve un file già cancellato |
| DIV-WRD-3 🟢 (dedotta) | I collegamenti calcolati (ZOFF-WRD-007) si cercano solo nell'intestazione e nel piè di pagina della prima sezione; l'editor inserisce campi solo in quelle della prima sezione; le misure delle immagini invece guardano tutte le sezioni | In un documento con più sezioni i collegamenti delle intestazioni successive restano con la destinazione `@…` |
| DIV-WRD-4 🟢 (dedotta) | `TImageUriStreamProvider.AddImage` tratta come `BLOB` qualunque campo trovato col nome dato, senza controllarne il tipo | Un campo `CARTA_INTESTATA_*` che non sia un `BLOB` fa fallire la generazione del documento |
| DIV-WRD-5 🟢 | Esportare in PDF con la finestra imposta `ReadOnly` dei parametri del visualizzatore, senza effetto sul documento | Codice che inganna chi lo legge |
| DIV-WRD-6 🟢 | La barra di stato del riquadro (e del gemello della posta) scrive «Pagina x di y» solo quando il documento è vuoto: la condizione è rovesciata | Con un documento aperto la barra di stato resta vuota |

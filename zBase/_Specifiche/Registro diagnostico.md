---
area: Registro diagnostico
progetto: zBase
aggiornato: 2026-11-02
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/013
---

# Registro diagnostico

Questa specifica descrive la sessione di registrazione per l'assistenza: l'utente la avvia da una voce di menu o da una scorciatoia, l'applicazione scrive per tutta la sessione un registro dettagliato (SmartInspect) e un file di durate, e alla chiusura raccoglie i file in uno zip e apre un ticket privato su Mantis. Il codice è in `zBase\zDiagnostica.Log.pas` (classe `TzSessioneLog`, accessibile con la funzione `SessioneLog`). Le unit vicine, che questa specifica richiama ma non descrive, sono `zDiagnostica.Log.Perf` (raccolta delle durate e riga del CSV: la usano anche `zDbView`, `zDbCard`, `zFormController`, `zMap`, `zStoredProc`, `zSystem` e `zFbDataSet` per segnalare le operazioni misurate), `zDiagnostica.Log.OpzioniForm` (procedura guidata di avvio), `zDiagnostica.Video` e `zDiagnostica.Video.Sblocco` (filmato) e la famiglia `zExceptions` (`zExceptions.mantis` per il ticket, `zExceptions.context` per il contesto).

Lo usano WT, Gesty e zTicser con lo stesso schema: il `.dpr` chiama `SessioneLog.AvviaAllAvvio` dopo aver attivato SmartInspect e prima di creare qualunque modulo, e `SessioneLog.ChiudiPerTerminazione` prima di `ExitProcess`; il `MainForm` configura le proprietà (`InitSessioneLog`: categoria `LOG`, soglie, durata e dimensione massime, filmato in Gesty e WT) e chiama `VerificaSessioneInterrotta`; il `ConfigModule` aggancia la scorciatoia Ctrl+Maiusc+L (`Commuta(ocScorciatoia)`), il segnalibro Ctrl+Maiusc+S (`InserisciSegnalibro`) e `OnMonitorFireDAC`; WT assegna anche `OnMessaggio` per mostrare gli avvisi con la finestra non modale di DevExpress. In zPack la usa anche la finestra `zMantis.TicketAssistenza.form` («Le mie segnalazioni»), con il pulsante «Registra / Allega registro». Le altre unit di zPack che citano `zDiagnostica.Log.*` usano soltanto `zDiagnostica.Log.Perf`, non questa unit.

**Come funziona.** La sessione è una macchina a due stati (`Attiva` falso o vero). Con `Avvia` (o `Commuta`) l'applicazione reindirizza SmartInspect su due file, avvia la raccolta delle durate, scrive l'intestazione e accende un timer da mezzo secondo che campiona le risorse, rileva i blocchi dell'interfaccia e controlla i limiti. Con `TerminaESegnala` chiude tutto, crea lo zip e apre il ticket. In alternativa la registrazione si prenota per il prossimo avvio con un file di richiesta, che il `.dpr` consuma prima dell'accesso. Un file marcatore (`.inCorso`) resta sul disco finché la sessione non è chiusa in modo ordinato: se l'applicazione termina con la registrazione attiva, all'avvio successivo la sessione si propone di nuovo per l'invio.

**Test che coprono quest'area.** Nessuna unit esistente. La bozza `Test.zDiagnostica.Log.pas` prova, su una istanza propria di `TzSessioneLog` con una cartella temporanea e senza avviare SmartInspect, i valori predefiniti, la disponibilità legata ai parametri Mantis, i testi del menu, la richiesta per il prossimo avvio (scrittura, annullamento, nome per postazione), il segnalibro senza registrazione, le scelte proposte all'utente e la scansione dei marcatori delle sessioni interrotte. Non si prova la registrazione vera (tocca SmartInspect globale, `Screen` e il timer), la creazione dello zip, l'invio a Mantis e il filmato.

## ZBASE-LOG-001 Avvio, chiusura e comando unico
`Commuta(origine)` avvia la registrazione se non è attiva e la chiude e segnala se lo è: è l'unico metodo che servono la voce di menu e la scorciatoia. `Avvia` restituisce falso senza fare niente se la registrazione è già attiva. L'origine (`ocMenu` o `ocScorciatoia`) cambia due cose: dal menu compaiono le opzioni di avvio (ZBASE-LOG-003), dalla scorciatoia si parte subito con le opzioni predefinite e senza conferma; dal menu i messaggi sono finestre modali, dalla scorciatoia finestre di avviso non modali (ZBASE-LOG-017). `Annulla` chiude la sessione senza aprire il ticket e toglie il marcatore: i file restano su disco. `ChiudiPerTerminazione` chiude la sessione (riepilogo, ripristino di SmartInspect) ma lascia il marcatore, perché l'applicazione sta uscendo senza che l'utente abbia chiuso la registrazione.

### Scenario: scorciatoia a registrazione spenta
- **Dato** la registrazione non attiva, i parametri Mantis validi e `Commuta(ocScorciatoia)`
- **Quando** l'utente preme Ctrl+Maiusc+L
- **Allora** la registrazione parte con `TzOpzioniRegistrazione.Predefinite`, senza finestre di scelta, e compare l'avviso «Registrazione log avviata»

### Scenario: scorciatoia a registrazione accesa
- **Dato** una registrazione attiva
- **Quando** l'utente preme di nuovo Ctrl+Maiusc+L
- **Allora** `Commuta` chiama `TerminaESegnala` e la sessione si chiude

## ZBASE-LOG-002 Disponibilità
`Disponibile` è vero solo se `TzExceptionManager.MantisServerParams.IsValid`, cioè con indirizzo e chiave di Mantis valorizzati: senza un posto dove mandare il log la registrazione non è offerta. `Avvia` esce in silenzio (restituisce falso, nessun messaggio) quando non è disponibile; le voci di menu e il segnalibro delle applicazioni si nascondono con lo stesso criterio. La disponibilità si rilegge dopo il collegamento al database, perché i parametri arrivano da una tabella. Con la registrazione già attiva la scorciatoia la chiude anche se nel frattempo i parametri non sono più validi. `AvviaAllAvvio` non controlla la disponibilità (prima dell'accesso i parametri non sono noti): se alla chiusura Mantis non è configurato, lo zip si crea lo stesso e il messaggio dice dove si trova.

### Scenario: Mantis non configurato
- **Dato** `MantisServerParams` senza indirizzo
- **Quando** si chiama `Avvia(ocMenu)`
- **Allora** il risultato è falso, `Attiva` resta falso e non compare nessuna finestra

### Scenario: un solo dei due valori
- **Dato** indirizzo valorizzato e chiave vuota
- **Quando** si legge `Disponibile`
- **Allora** il valore è falso

## ZBASE-LOG-003 Valori predefiniti e opzioni di avvio
Una istanza nuova ha: categoria Mantis `LOG`, soglia di operazione lenta 300 ms, soglia di blocco 1500 ms, campionamento delle risorse ogni 15 secondi, durata massima 120 minuti, dimensione massima 40 MB (somma di `.sil` e `.log`), valori dei parametri non registrati (`RegistraValoriParametri` falso: sono dati personali, la registrazione va attivata esplicitamente), conservazione 30 giorni, scorciatoia `Ctrl+Shift+L` (testo che compare nei messaggi), filmato non disponibile (`VideoDisponibile` falso, limiti 15 minuti e 20 MB), `ProssimoAvvioNellaProcedura` falso, cartella vuota. Le opzioni (`TzOpzioniRegistrazione`) hanno tre insiemi: `Predefinite` (nessuna misura in più, domanda della nota alla chiusura, invio alla fine, nessun filmato: usate dalla scorciatoia e dal prossimo avvio), `Tutte` (tempi di lettura dal server, tempi della griglia e monitor FireDAC accesi) e `Proposte` (come `Tutte` ma con il monitor FireDAC spento, perché chiude e riapre la connessione: è lo stato che la procedura guidata propone dal menu). Dal menu, `Avvia` mostra la procedura guidata (`OnChiediOpzioni` se l'applicazione ne ha una propria; senza, `zDiagnostica.Log.OpzioniForm`); se l'utente annulla, non parte niente.

### Scenario: opzioni proposte dal menu
- **Dato** i parametri Mantis validi, `OnChiediOpzioni` assegnato e nessun monitor FireDAC agganciato
- **Quando** si chiama `Avvia(ocMenu)`
- **Allora** la funzione riceve `TempiFetch`, `TempiGriglia`, `ChiediCommento` e `InviaAllaFine` veri, `MonitorFireDAC` e `Video` falsi, e il secondo parametro (monitor disponibile) falso

### Scenario: utente annulla la procedura
- **Dato** `OnChiediOpzioni` che restituisce falso
- **Quando** si chiama `Avvia(ocMenu)`
- **Allora** il risultato è falso, nessun file è stato creato e SmartInspect non è stato toccato

### Scenario: prenotazione già presente
- **Dato** `ProssimoAvvioNellaProcedura` vero, un file di richiesta presente e conferma dell'utente a «annulla la prenotazione»
- **Quando** si chiama `Avvia(ocMenu)`
- **Allora** la richiesta viene cancellata, compare «Prenotazione annullata» e la funzione restituisce falso senza mostrare le opzioni

## ZBASE-LOG-004 Cartella e nomi dei file
La cartella dei file di sessione è, in ordine: `CartellaLog` se valorizzata, `TzExceptionManager.LogFolder`, la sottocartella `log` accanto all'eseguibile; viene sempre creata (`ForceDirectories`, senza controllare l'esito) e normalizzata con la barra finale. Presso i clienti l'eseguibile sta spesso su una cartella di rete usata da tutte le postazioni, quindi ogni nome porta utente Windows e computer. Identificativo della sessione: `LOG-aaaammgg-hhmmss-<utente>-<computer>`. File derivati: `<id>.sil` (registro SmartInspect completo), `<id>.log` (registro di testo), `<id>-perf.csv` (durate), `<id>-firedac.txt` (traccia del monitor FireDAC, solo se acceso), `<id>.zip`, `<id>.inCorso` (marcatore), `<id>-video-NN.mp4` (parti del filmato); la richiesta per il prossimo avvio è `LOG-avvio-<utente>-<computer>.richiesta`. Utente e computer si riducono ai caratteri `a-z A-Z 0-9 - _ .`: ogni altro carattere diventa `_`, e un nome vuoto diventa `sconosciuto`. Si usa l'utente Windows e non quello dell'applicazione, perché la richiesta si legge prima dell'accesso.

### Scenario: nome con spazio e dominio
- **Dato** utente Windows `COMUNE\mario rossi` e computer `PC-UFF01`
- **Quando** si calcola il nome della postazione
- **Allora** vale `mario_rossi-PC-UFF01`

### Scenario: cartella non indicata
- **Dato** `CartellaLog` vuota e `TzExceptionManager.LogFolder` vuota
- **Quando** parte una sessione
- **Allora** i file finiscono in `log\` accanto all'eseguibile

## ZBASE-LOG-005 Formato dei file di registro
All'avvio SmartInspect riceve due destinazioni nella stessa stringa di connessione: `file(filename="<id>.sil", append="false")`, il registro binario completo (comprese le voci con dati allegati: elenchi, SQL, dataset), che si legge con la Console SmartInspect o con `log_summary` di zsrc, e `text(filename="<id>.log", append="false", indent="true", pattern="%timestamp% | %level% | %thread% | %session% | %title%")`, una riga per voce con il solo titolo (i dati allegati non finiscono nel testo; per questo le informazioni di sistema si scrivono come titoli «nome = valore» con `LogString`). Il livello passa a `lvDebug`, il livello predefinito delle voci a `lvMessage`, la risoluzione dell'orologio a `crHigh`; alla chiusura tornano i valori di prima. Non si usa mai `maxsize` (spezzerebbe il registro su più file numerati). Se all'avvio è già attiva una destinazione `file(...)` (il `.sil` chiesto con `-log` sulla riga di comando) viene conservata accanto alle due della sessione; la destinazione predefinita verso la Console no.

Il contenuto del registro ha voci con prefisso fisso: `META.*` in testa (`sessione`, `inizio`, `avvio` = «dal menu» o «dal prossimo avvio», `applicazione`, `versione`, `eseguibile`, `rigaDiComando`, `database`, `cliente`, `utente`, `utenteSistema`, `computer`, `dpi`, `monitor`, soglie, `valoriParametriRegistrati`, `fileSil`, `fileCsv`, `opzioni`, `notaUtente`, `fileMonitor`), il contesto iniziale delimitato da `--- INIZIO CONTESTO INIZIALE ---` e `--- FINE ...` (testo su più righe), `RISORSE` (memoria e handle), `NAVIGAZIONE.formAttiva`, `SEGNALIBRO`, `VIDEO.*`, il riepilogo `RIEPILOGO.*` con le durate delle operazioni più costose e la riga di chiusura `=== FINE SESSIONE DI REGISTRAZIONE ===`. Il CSV (prodotto da `zDiagnostica.Log.Perf`) ha intestazione `istante;categoria;nome;ms;righe;modulo;dettaglio`, campi separati da punto e virgola, in UTF-8 con BOM.

### Scenario: registro già attivo da riga di comando
- **Dato** SmartInspect avviato con `-log=C:\Temp\prova.sil`
- **Quando** parte una sessione
- **Allora** la stringa di connessione contiene `prova.sil` oltre ai due file della sessione, e alla chiusura torna quella di prima

### Scenario: avvio dal prossimo avvio
- **Dato** una sessione partita da `AvviaAllAvvio`
- **Quando** l'utente ha fatto l'accesso e l'applicazione chiama `VerificaSessioneInterrotta`
- **Allora** il registro riceve `--- ACCESSO COMPLETATO ---`, di nuovo `META.database`, `META.cliente`, `META.utente` e il contesto dopo l'accesso, e compare l'avviso «Registrazione per l'assistenza in corso»

## ZBASE-LOG-006 Cosa si registra durante la sessione
Ogni 500 ms scatta un timer nel thread principale (`BattitoScattato`, metodo di istanza: un `class procedure` come gestore romperebbe il registratore). A ogni battito: se il tempo trascorso dal battito precedente supera `SogliaBloccoMs` (1500) si registra una operazione di categoria `blocco` con la durata e il modulo attivo, perché in quel tempo l'interfaccia non rispondeva; ogni `IntervalloCampionamentoSecondi` (15) si campiona il processo (memoria in uso, picco, file di paging, oggetti GDI e USER) come categoria `risorse` con durata zero, e si scrive anche la voce `RISORSE`; si controllano il filmato, la crescita dei file e i limiti. La form attiva (`Screen.OnActiveFormChange`, con la catena del gestore precedente rispettata) aggiorna il modulo corrente e scrive `NAVIGAZIONE.formAttiva`. `InserisciSegnalibro(testo)` scrive `SEGNALIBRO` e una operazione di categoria `segnalibro`; senza testo lo chiede all'utente (annullando non scrive niente); senza registrazione attiva avvisa «Nessuna registrazione in corso» e indica la scorciatoia per avviarla.

### Scenario: segnalibro senza registrazione
- **Dato** nessuna registrazione attiva e `TestoScorciatoia = 'Ctrl+Shift+L'`
- **Quando** si chiama `InserisciSegnalibro('qui e'' lento')`
- **Allora** compare un avviso con titolo «Nessuna registrazione in corso» e nel testo la scorciatoia, e non viene scritta nessuna voce

### Scenario: interfaccia ferma
- **Dato** una registrazione attiva con `SogliaBloccoMs = 1500`
- **Quando** il thread principale resta occupato 4 secondi e il timer scatta di nuovo
- **Allora** nel CSV compare una riga `blocco` con durata di circa 4000 ms e il nome del modulo attivo

## ZBASE-LOG-007 Limiti e chiusura automatica
La registrazione si chiude da sola quando i minuti trascorsi raggiungono `DurataMassimaMinuti` o la somma di `.sil` e `.log` raggiunge `DimensioneMassimaMb` (il CSV, la traccia FireDAC e il filmato non contano). Prima, a un minuto dal primo limite, compare un avviso non modale (una volta sola per limite). Al limite il battito si ferma; se l'utente aveva escluso l'invio alla fine si chiude e si dice dove sono i file, altrimenti si chiede «Invio ora la segnalazione all'assistenza?» (no = chiusura con `Annulla`); se la domanda della nota viene annullata la registrazione si chiude comunque con `Annulla`. `TempoResiduo` dice quanto manca al primo limite (secondi, durata totale stimata per una barra che si svuota, motivo come «si chiude la registrazione: 120 minuti»); la dimensione si stima dalla crescita misurata ogni 30 secondi, quindi i primi 30 secondi la stima per dimensione manca. `LimiteImminente` è vero sotto i 2 minuti. A registrazione spenta `TempoResiduo` dà `Secondi = -1`, `Totale = 0`, motivo vuoto; `DurataSecondi` dà 0.

### Scenario: nessuna registrazione
- **Dato** una sessione non attiva
- **Quando** si leggono `TempoResiduo`, `LimiteImminente` e `DurataSecondi`
- **Allora** i valori sono `-1`, falso e `0`

### Scenario: dimensione raggiunta
- **Dato** `DimensioneMassimaMb = 40` e `.sil` più `.log` a 40,2 MB
- **Quando** scatta il battito
- **Allora** la registrazione si ferma per limite con motivo «dimensione massima di 40 MB raggiunta» e si apre la domanda di invio

## ZBASE-LOG-008 Prestazioni e thread
A registrazione spenta il costo per chi misura è la lettura di un booleano (`RegistrazionePrestazioniAttiva`); a registrazione attiva l'applicazione è più lenta, e i messaggi lo dicono all'utente: SmartInspect in modalità debug con risoluzione al microsecondo, SQL e valori dei parametri nel registro (se `RegistraValoriParametri`), un campionamento ogni 15 secondi e un timer da 500 ms. Il lavoro è nel thread principale: il timer, i messaggi, la creazione dello zip e l'apertura del ticket (sincrona, con il cursore a clessidra, con il tempo massimo dei parametri Mantis, 30 secondi se non diversamente configurato). Fuori dal thread principale ci sono due cose: chiunque può scrivere nel registro (SmartInspect e la raccolta delle durate, protetta da una sezione critica, sono adatti ai thread) e l'invio delle parti del filmato dopo l'apertura del ticket (thread `zDiagnostica.Log.InvioFilmato`, una parte alla volta). `TzSessioneLog` stesso non è sicura per i thread: tutti i suoi metodi vanno chiamati dal thread principale. La unit crea la sessione al primo uso (`Istanza`) e la libera nella finalizzazione; se all'uscita la registrazione è ancora attiva, il distruttore la chiude lasciando il marcatore.

### Scenario: registrazione spenta
- **Dato** nessuna sessione attiva
- **Quando** `zDbView` o `zFbDataSet` chiedono `RegistrazionePrestazioniAttiva`
- **Allora** ricevono falso senza avviare cronometri né comporre dettagli

## ZBASE-LOG-009 Chiusura e invio
`TerminaESegnala` chiude la sessione e apre il ticket. Nell'ordine: determina la nota (quella scritta all'avvio; se vuota e `ChiediCommento` è vero la chiede, e se l'utente annulla la registrazione resta attiva e la funzione restituisce falso); chiama `Annulla` (arresta battito, monitor FireDAC e filmato, scrive il riepilogo, ripristina SmartInspect, rimuove il marcatore); se `InviaAllaFine` è falso mostra «Registrazione chiusa» con la cartella e l'elenco dei file e termina, lasciando i file non compressi; altrimenti `InviaAMantis`. `InviaAMantis` crea sempre lo zip (anche senza Mantis, perché è il file da mandare a mano), poi, se i parametri Mantis sono validi, apre un ticket con: progetto = nome del cliente (altrimenti il nome del database), segnalatore = utente dell'applicazione, oggetto `[LOG] <modulo> - <cliente> - <utente> - <id>` limitato a 120 caratteri, categoria `CategoriaMantis`, stato di visibilità `private`, allegato lo zip. La descrizione contiene, separati da linee di trattini bassi: la segnalazione dell'utente, i dati della sessione (id, misure aggiuntive, applicazione, versione, database, cliente, utente, utente di sistema, computer, inizio, durata, eventi misurati, valori dei parametri nel log, nome dello zip, file lasciati fuori dallo zip, eventuale interruzione per limite, filmato), il riepilogo delle 20 operazioni più costose, le istruzioni di analisi e il contesto alla chiusura. Gli allegati rifiutati (di solito per dimensione) non annullano il ticket: l'utente riceve «Log non allegato» con il percorso dello zip. Se la compressione o l'apertura del ticket falliscono, il messaggio d'errore dice dove restano i file; il ticket non si riprova in automatico.

### Scenario: invio escluso
- **Dato** `InviaAllaFine = False` scelto all'avvio
- **Quando** l'utente chiude la registrazione
- **Allora** non si crea nessuno zip né ticket e compare «Registrazione chiusa» con la cartella e i nomi dei file `.sil`, `.log` e `-perf.csv`

### Scenario: Mantis non raggiungibile
- **Dato** parametri Mantis validi ma server spento
- **Quando** l'utente chiude la registrazione
- **Allora** lo zip esiste, compare «Ticket non aperto» con il messaggio dell'errore e il percorso dello zip, e il marcatore non c'è più

## ZBASE-LOG-010 Archivio zip
`CreaArchivio` scrive `<id>.zip` (sostituendo uno zip omonimo) con i file `.sil`, `.log`, `-perf.csv` e, se esiste, `-firedac.txt`, compressi con deflate e senza percorso. Un file ancora aperto da un altro processo (la traccia FireDAC, che il tracciatore chiude nel suo thread) si riprova 10 volte a distanza di 200 ms; se resta bloccato si lascia fuori dallo zip, si scrive nel registro e si riporta nella descrizione del ticket (`File non compressi nello zip`) senza far fallire tutto lo zip. Si cancellano gli originali solo se sono entrati nello zip. Lo zip stesso non si cancella mai dopo l'invio. Le parti del filmato non vanno nello zip: sono già compresse e lo renderebbero inallegabile.

### Scenario: file bloccato
- **Dato** la traccia `-firedac.txt` aperta da un altro processo per tutta la durata dei tentativi
- **Quando** si crea lo zip
- **Allora** lo zip contiene `.sil`, `.log` e `-perf.csv`, il file della traccia resta su disco e la descrizione del ticket lo elenca

## ZBASE-LOG-011 Registrazione dal prossimo avvio
Serve per i problemi che nascono prima che l'utente possa premere qualunque cosa (accesso, caricamento del dizionario LZ, creazione dei moduli dati). La richiesta è un file `LOG-avvio-<utente>-<computer>.richiesta` nella cartella dei log, in UTF-8, con voci `nome=valore`: `richiesta` (data e ora `aaaa-mm-gg hh:nn:ss`), `utente`, `postazione`, e, se scritta dalla procedura guidata, `opzioni=1`, `tempiFetch`, `tempiGriglia`, `invio` (valori `0`/`1`) e `nota` (Base64 UTF-8 su una riga). `CommutaRichiestaAvvio` è un solo comando per chiedere e per annullare: se la richiesta c'è la cancella e dice «Richiesta annullata»; altrimenti, se `Disponibile`, chiede conferma (`OnChiediConferma`) e scrive la richiesta senza opzioni, dicendo «Registrazione richiesta»; senza conferma o senza parametri Mantis non scrive niente. L'annullamento funziona anche se Mantis non è più configurato. `AvviaAllAvvio` (da chiamare nel `.dpr` dopo `si.Enabled := True`) cerca la richiesta di questa postazione: se non c'è restituisce falso; se c'è la legge e la cancella subito, perché vale per un avvio solo, e se non riesce a cancellarla non avvia (altrimenti la registrazione ripartirebbe a ogni apertura). Senza `opzioni=1` valgono le opzioni predefinite; con `opzioni=1` si rileggono fetch, griglia, invio e nota, e la domanda della nota alla chiusura si spegne. Filmato e monitor FireDAC restano sempre spenti negli avvii senza finestra. Nessuna conferma e nessun messaggio: l'avviso arriva dopo l'accesso, da `VerificaSessioneInterrotta`.

### Scenario: prenotare e annullare
- **Dato** i parametri Mantis validi e nessuna richiesta
- **Quando** l'utente chiama due volte `CommutaRichiestaAvvio` (confermando la prima)
- **Allora** dopo la prima esiste `LOG-avvio-<postazione>.richiesta` con `richiesta`, `utente` e `postazione`, e dopo la seconda il file non c'è più

### Scenario: richiesta di un altro computer
- **Dato** nella cartella condivisa un file `LOG-avvio-mrossi-PC02.richiesta`
- **Quando** `RichiestaAvvioPresente` viene letto da `PC01`
- **Allora** vale falso e `AvviaAllAvvio` non lo consuma

### Scenario: richiesta della procedura guidata
- **Dato** una richiesta con `opzioni=1`, `invio=0` e `nota` che decodifica in «non stampa»
- **Quando** parte `AvviaAllAvvio`
- **Allora** la sessione ha `InviaAllaFine` falso, `Nota = 'non stampa'`, `ChiediCommento` falso, monitor FireDAC e filmato spenti

## ZBASE-LOG-012 Sessione interrotta
All'avvio della registrazione si scrive il marcatore `<id>.inCorso`: voci `sessione`, `postazione`, `inizio`, `log`, `sil`, `csv`, `monitor` (vuoto se spento) e, se c'è, `nota` in Base64. Si toglie solo con la chiusura ordinata (`Annulla` o `TerminaESegnala`), non con `ChiudiPerTerminazione`. `VerificaSessioneInterrotta` si chiama dopo l'accesso: se la registrazione è attiva e partita dall'avvio completa l'intestazione (ZBASE-LOG-005) ed esce; altrimenti, se `Disponibile`, scorre tutti i `*.inCorso` della cartella e per ciascuno: salta (senza toccarlo) quello di un'altra postazione o senza postazione (scritto prima di questa versione: lo toglie la pulizia per età); salta quello di una sessione ancora aperta da un altro processo della stessa postazione (`.log` o `.sil` non apribili in esclusiva); se `.log` o `.sil` esistono chiede «Invio ora la segnalazione all'assistenza?»; se l'utente accetta ricostruisce le parti del filmato su disco (solo quelle complete: atomo `moov` presente), reinvia con la nota del marcatore, o la chiede se manca, e in ogni caso alla fine elimina il marcatore. Se `Disponibile` è falso i marcatori restano dove sono, per una configurazione successiva. Con un invio di filmato già in corso, la sessione interrotta parte con il solo log.

### Scenario: marcatore di un altro computer
- **Dato** un marcatore con `postazione=altro-PC` e file esistenti
- **Quando** si chiama `VerificaSessioneInterrotta` sulla postazione `mrossi-PC01`
- **Allora** non viene fatta nessuna domanda e il marcatore resta

### Scenario: file spariti
- **Dato** un marcatore della postazione con `.log` e `.sil` non più presenti
- **Quando** si chiama `VerificaSessioneInterrotta`
- **Allora** il marcatore viene eliminato senza domande

### Scenario: utente rifiuta
- **Dato** un marcatore della postazione con `.sil` presente
- **Quando** l'utente risponde no alla domanda
- **Allora** il marcatore viene eliminato, il `.sil` resta su disco fino alla pulizia per età e non si apre nessun ticket

## ZBASE-LOG-013 Pulizia dei file vecchi
A ogni avvio di una registrazione (non prima: nessuna pulizia periodica) `EliminaFileVecchi` cancella nella cartella tutti i file `LOG-*.*` (log, csv, traccia FireDAC, zip, marcatori, richieste, parti del filmato) con data di ultima scrittura anteriore a `now - GiorniConservazione` giorni (30 per default). Il criterio è solo l'età e riguarda anche i file delle altre postazioni della cartella condivisa; gli errori di cancellazione (file aperti) e quelli di lettura della cartella si ignorano. Gli zip e i file restano quindi sul disco anche dopo l'invio, fino alla prima registrazione avviata dopo la scadenza.

### Scenario: file di un mese fa
- **Dato** nella cartella un `LOG-20261001-101500-mrossi-PC01.zip` con data di scrittura di 31 giorni fa
- **Quando** parte una nuova registrazione
- **Allora** il file viene eliminato, mentre un file di 5 giorni fa resta

## ZBASE-LOG-014 Cartella non scrivibile e altri errori di scrittura
Cosa succede per ciascun file: la richiesta per il prossimo avvio che non si può scrivere dà l'errore «Richiesta non registrata» con il percorso (`ScriviRichiestaAvvio`); la richiesta che non si può cancellare impedisce l'avvio della registrazione (ZBASE-LOG-011); il marcatore che non si riesce a scrivere si ignora in silenzio (la sessione parte lo stesso, ma non verrà riproposta se interrotta); l'errore di lettura di un marcatore interrompe la scansione senza messaggio (vedi DIV-LOG-4); un `.sil` o `.log` che SmartInspect non riesce a scrivere dipende dal comportamento di SmartInspect, che questa unit non controlla; lo zip che non si riesce a creare dà «Ticket non aperto» con il percorso dei file. Un errore nell'attivazione di SmartInspect (`si.Connections`, `si.Enabled`) ripristina le impostazioni di prima e, dal menu, mostra «Registrazione non avviata»; all'avvio non mostra niente e l'applicazione parte comunque. L'errore di creazione del CSV, invece, non è protetto (vedi DIV-LOG-1).

### Scenario: richiesta in cartella di sola lettura
- **Dato** una cartella dei log senza permesso di scrittura
- **Quando** l'utente chiede la registrazione dal prossimo avvio
- **Allora** compare «Richiesta non registrata» con il percorso del file e il messaggio dell'errore

## ZBASE-LOG-015 Filmato
Se l'applicazione lo prevede (`VideoDisponibile`) e la procedura guidata lo ha scelto con il codice di sblocco dell'assistenza (`zDiagnostica.Video.Sblocco`, non richiesto sotto debugger), parte `TzRegistratoreVideo` sul monitor della finestra principale dopo l'accensione del monitor FireDAC; produce parti MP4 da 4 MB accanto al registro, che non finiscono nello zip. Il filmato si ferma da solo dopo `DurataMassimaVideoMinuti` (tempo vero, pause comprese) o `DimensioneMassimaVideoMb` (l'avviso è non modale; il registro continua) o per un errore del codificatore; `PausaVideo` sospende la cattura e scrive `VIDEO.pausa`/`VIDEO.ripresa`. Alla chiusura le parti si caricano sul ticket già aperto, in un thread, una alla volta, con un tempo massimo per parte calcolato dalla dimensione e dalla velocità minima di 0,5 Mbit/s (almeno 30 secondi); la velocità di invio misurata si ricorda in `%LOCALAPPDATA%\zDiagnostica\Registrazione.ini`. Alla fine una nota sul ticket dice quante parti sono arrivate e quali no. Il ticket esiste quindi anche se l'invio si interrompe; `InterrompiInvio` ferma dopo la parte in corso. Le parti incomplete (senza atomo `moov`) si lasciano sul disco.

### Scenario: limite di durata del filmato
- **Dato** `DurataMassimaVideoMinuti = 15` e filmato attivo
- **Quando** passano 15 minuti
- **Allora** il filmato si ferma con l'avviso «Filmato fermato», il registro prosegue e le parti si inviano alla chiusura

## ZBASE-LOG-016 Monitor FireDAC
`OnMonitorFireDAC(attiva, file)` è un aggancio dell'applicazione (che per cambiare `MonitorBy` deve riconnettersi): all'avvio, se l'opzione è accesa e l'aggancio esiste, si chiama con `<id>-firedac.txt` nella cartella dei log; l'errore non ferma la registrazione, scrive `META.fileMonitor` con il motivo e mostra «Monitor FireDAC non attivato». Alla chiusura si chiama con `attiva = falso`, prima del riepilogo. Senza aggancio la casella nella procedura è disabilitata.

### Scenario: monitor non attivabile
- **Dato** un `OnMonitorFireDAC` che solleva eccezione
- **Quando** parte la registrazione con l'opzione accesa
- **Allora** la registrazione prosegue senza traccia FireDAC e `META.fileMonitor` riporta «non attivato: <messaggio>»

## ZBASE-LOG-017 Messaggi all'utente
Ogni messaggio passa da `Mostra(titolo, testo, tipo)`: se l'applicazione ha assegnato `OnMessaggio`, vale solo quella; altrimenti gli errori sono sempre dialoghi modali (contengono percorsi da leggere), e gli altri messaggi sono finestre di avviso non modali se il comando viene dalla scorciatoia (o al termine dell'invio del filmato, che imposta l'origine su `ocScorciatoia`) e dialoghi modali se viene dal menu. Dal menu, al termine di `Avvia` non compare un secondo messaggio: la procedura guidata ha già spiegato come chiudere.

### Scenario: applicazione con proprio messaggio
- **Dato** `OnMessaggio` assegnato
- **Quando** si chiama `InserisciSegnalibro` senza registrazione
- **Allora** l'applicazione riceve titolo, testo e tipo `tmAvviso`, e nessuna finestra della unit compare

## Divergenze note
Le divergenze seguenti si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LOG-1 🟡 (dedotta) | in `AvviaRegistrazione` la chiamata a `TzRaccoltaPrestazioni.Avvia`, che crea il CSV con `TStreamWriter`, sta fuori da ogni `try/except`, dopo che SmartInspect è stato già riconfigurato (livello `lvDebug`, risoluzione alta, nuove destinazioni) | con la cartella non scrivibile l'eccezione risale al chiamante (finestra di errore dal menu, o errore all'avvio del programma da `AvviaAllAvvio` nel `.dpr`), `Attiva` resta falso e SmartInspect non viene ripristinato: l'applicazione continua con il registro in modo debug e destinazioni su una cartella che non scrive |
| DIV-LOG-2 🟡 (dedotta) | la sessione interrotta reinviata da `VerificaSessioneInterrotta` costruisce oggetto e descrizione dal processo che reinvia, non dalla sessione persa: durata calcolata da `inizio` del marcatore fino a ora, eventi misurati sempre 0, riepilogo vuoto, opzioni e valore di `RegistraValoriParametri` del processo nuovo, versione, database, cliente e utente attuali, contesto della finestra attuale | il ticket di una sessione interrotta riporta ad esempio «Durata 14 h» per una sessione di 10 minuti, nessun riepilogo e contesto estraneo al problema, e chi analizza può trarne conclusioni sbagliate |
| DIV-LOG-3 🟡 (dedotta) | `DimensioneRegistriMb` somma solo `.sil` e `.log`: la traccia `-firedac.txt` (che con la registrazione dei dati letti può diventare molto grande), il CSV e il filmato non contano per `DimensioneMassimaMb` | lo zip può superare il limite di Mantis anche con `.sil` e `.log` entro i 40 MB: il ticket si apre senza allegato («Log non allegato») e si perde il vantaggio del limite pensato per tenere lo zip allegabile |
| DIV-LOG-4 ✅ (corretta nel rilascio 013: la lettura di ogni marcatore è protetta, uno illeggibile viene saltato e resta dov'è) | tutta la scansione dei marcatori in `VerificaSessioneInterrotta` è dentro un solo `try/except` che ignora ogni errore: se la lettura di un marcatore fallisce (file bloccato da antivirus o da un altro processo, accesso negato) l'eccezione esce prima del `TFile.Delete` e il ciclo si interrompe | i marcatori che seguono nell'ordine del disco non sono mai proposti, e quello difettoso blocca la scansione a ogni avvio, senza messaggio, finché non lo cancella la pulizia per età |
| ~~DIV-LOG-5~~ ✅ corretta il 2026-11-01 (rilascio 003): il valore predefinito di `RegistraValoriParametri` e' ora falso, provato da `Creazione_IstanzaNuova_ValoriPredefiniti` | Testo originale: il valore predefinito di `RegistraValoriParametri` è vero (WT e Gesty non lo cambiano) e il registro `.sil` contiene SQL e valori dei parametri, cioè dati personali; gli zip restano nella cartella dei log (spesso condivisa in rete) per 30 giorni dopo l'invio, e i file non compressi finché non li cancella la pulizia, che gira solo all'avvio di un'altra registrazione | dati personali di cittadini o di corsisti restano leggibili da chi usa la cartella condivisa per settimane; la riservatezza poggia sul solo stato `private` del ticket e sull'avviso mostrato all'utente |
| DIV-LOG-6 🟢 (dedotta) | `OggettoTicket` compone `[LOG] modulo - cliente - utente - id` e poi taglia a 120 caratteri | con un nome di cliente lungo l'identificativo della sessione, che sta in fondo ed è la parte che distingue un ticket dall'altro, esce troncato |
| DIV-LOG-7 🟢 (dedotta) | nel ramo `not InviaAllaFine` di `BattitoScattato` il risultato di `TerminaESegnala` è ignorato (negli altri due rami, se annullata, si chiama `Annulla`) | con una finestra delle opzioni dell'applicazione (`OnChiediOpzioni`) che lasci `ChiediCommento` vero, se l'utente annulla la nota al limite la registrazione resta attiva con il battito fermo: nessun campionamento, nessun controllo dei limiti, nessun avviso |
| DIV-LOG-8 🟢 (dedotta) | `IstruzioniAnalisi` dice che lo zip contiene tre file; con il monitor FireDAC acceso ne contiene quattro | chi analizza non cerca la traccia FireDAC fra gli allegati se non legge `META.opzioni` |
| DIV-LOG-9 🟢 (dedotta) | `GiorniConservazione` non ha controlli sul valore: con 0 o un valore negativo `EliminaFileVecchi` cancella tutti i `LOG-*` non bloccati della cartella, anche delle altre postazioni | un valore sbagliato nel `MainForm` fa perdere le sessioni interrotte di tutta la rete alla prima registrazione avviata |
| DIV-LOG-10 🟢 (dedotta) | dopo `TerminaESegnala` il marcatore è già stato tolto (`Annulla`) quando si tenta l'apertura del ticket; se l'invio fallisce (rete assente) la sessione non è più riproposta all'avvio successivo | il tentativo si ripete solo a mano, con lo zip indicato nel messaggio d'errore |

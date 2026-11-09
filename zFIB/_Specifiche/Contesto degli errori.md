---
area: Contesto degli errori
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Contesto degli errori

Questa specifica descrive come, quando FireDAC solleva un errore del database, l'applicazione ne conserva il contesto: quale dataset stava lavorando, con quale SQL, con quali parametri e valori, quale `INSERT` o `UPDATE` stava tentando. Il codice è in `zBase\zExceptions.firedac.pas` (**non** in zFIB, ma lavora in coppia con `TzFbDataSet`); il destinatario del contesto è `zExceptions.context`, che lo mostra nel dettaglio dell'eccezione e lo allega ai ticket. Descrive il comportamento atteso, non il codice.

**Come funziona.** `TzFbDataSet.Create` assegna al proprio `OnError` il gestore `HandleDataSetError`; inoltre l'applicazione chiama `CaptureFailedDataSet` nel gestore di errore della connessione. FireDAC chiama prima il gestore del dataset (che sa con certezza chi è) e poi quello della connessione (dove l'iniziatore può essere nullo o un oggetto del livello fisico, come `TFDPhysFBCommand`). La unit `zExceptions.firedac` legge `zFbDataSet.CurrentOpeningDataSet`, e non il contrario, per tenere la dipendenza a senso unico.

**Test che coprono quest'area.** `Test.zExceptions.Firedac` (rilascio 012, 11 prove su SQLite in memoria) prova `DumpDataSet` su dataset nullo, chiuso e aperto, la riga SQL con i parametri sostituiti (apici raddoppiati, date e numeri in formato invariante, valore nullo, parametri dal nome simile, dollaro nel valore), `CaptureFailedDataSet` con iniziatore nullo o dataset, l'apertura in corso consumata (DIV-ERR-1), il gestore del dataset e la finestra di due secondi del suo dump (DIV-ERR-2). Restano senza prova, perché servono Firebird o un conflitto di aggiornamento vero, il dump di una stored procedure e la ricostruzione della DML. `Test.zExceptions.Fib` prova `EstraiPercorsoChiamate`, che sta in un'altra unit (`zExceptions.fib`) e legge la catena «At procedure 'X' line: N» dai messaggi di Firebird.

## ZFIB-ERR-001 Aggancio automatico
Basta che la unit compaia in un `uses` del progetto: all'avvio imposta `OnCollectDbContext` di `zExceptions.context` con la raccolta del contesto delle connessioni (ZFIB-ERR-008), alla chiusura lo toglie e libera il gestore.

### Scenario: unit presente
- **Dato** un programma che include `zExceptions.firedac`
- **Quando** parte
- **Allora** `OnCollectDbContext` è assegnato senza altro codice

## ZFIB-ERR-002 La cattura non fa mai fallire la gestione dell'errore
`DumpDataSet`, `HandleDataSetError` e `CaptureFailedDataSet` non sollevano mai eccezioni e non toccano l'eccezione originale (che il chiamante rilancia con `raise AException`). Una sezione del dump che non si riesce a leggere viene sostituita da un testo `<messaggio>`; un errore durante la cattura si scrive nel registro e in coda al dump, così la sezione non sparisce in silenzio.

### Scenario: proprietà illeggibile
- **Dato** un dataset a metà di un errore di lettura, con una proprietà che solleva eccezione
- **Quando** si chiede `DumpDataSet`
- **Allora** il dump esce lo stesso, con il testo dell'errore al posto della proprietà

## ZFIB-ERR-003 Gestore a livello di dataset (`HandleDataSetError`)
`TzFbDataSet` assegna al proprio `OnError` il metodo di un oggetto unico di unità (`DataSetErrorHandler`), mai una `class procedure`: in un metodo di classe il campo `Data` del puntatore a metodo conterrebbe il riferimento di classe e il registro SmartInspect andrebbe in errore. A questo livello `ASender` è sempre il dataset: il gestore registra il dump del dataset, il suo nome, il suo identificativo LZ (ZFIB-ERR-009), il nome del modulo proprietario e la classe del modulo dati proprietario, senza toccare l'eccezione.

### Scenario: errore di un dataset
- **Dato** un `TzFbDataSet` il cui `OnError` è quello assegnato dal costruttore
- **Quando** FireDAC segnala un errore su quel dataset
- **Allora** `zExceptions.context` riceve dump, nome, identificativo LZ e modulo del dataset

## ZFIB-ERR-004 Cattura a livello di connessione (`CaptureFailedDataSet`)
Da chiamare nel gestore di errore della connessione, prima del `raise`, con `ASender` e `AInitiator` così come li dà FireDAC. Nell'ordine:
1. legge e azzera subito `CurrentOpeningDataSet` (ZFIB-ERR-005), qualunque ramo risponda poi; se un dump è già stato registrato **per questo errore** (dal gestore del dataset, negli ultimi 2 secondi) esce senza toccarlo; un dump più vecchio, di un errore precedente mai consumato, si riscrive;
2. scrive subito un dump minimo con le classi di `ASender` e `AInitiator`, perché se il resto fallisce resti almeno quello;
3. se `AInitiator` è un dataset, ne fa il dump con nome, identificativo LZ e modulo;
4. altrimenti, se la traccia di `CurrentOpeningDataSet` letta al passo 1 era valorizzata, il responsabile è quel dataset e lo si registra;
5. altrimenti elenca i dataset attivi sulla connessione come «candidati da verificare» (ZFIB-ERR-006);
6. in ultima istanza scrive solo il nome della classe di `AInitiator`, o un messaggio che dice che non c'è niente da riportare.

### Scenario: errore durante l'apertura
- **Dato** un dataset con la traccia di apertura valorizzata e `AInitiator` che è un oggetto del livello fisico
- **Quando** scatta l'errore della connessione
- **Allora** il dump riguarda il dataset in apertura e la traccia viene azzerata

### Scenario: dump già presente
- **Dato** un dump registrato dal gestore del dataset
- **Quando** `CaptureFailedDataSet` viene chiamata per lo stesso errore
- **Allora** il dump esistente resta invariato

## ZFIB-ERR-005 Dataset in apertura (`CurrentOpeningDataSet`)
`TzFbDataSet` scrive in `CurrentOpeningDataSet` se stesso in `DoBeforeOpen` e durante la preparazione della query che ricostruisce i campi (`BuildFields`), salvando il valore precedente e ripristinandolo alla fine perché le aperture si annidano (un dettaglio apre prima il suo master, e la preparazione di un dataset può scattare dentro l'apertura di un altro). `DoAfterOpen` lo azzera, ma solo se contiene ancora il proprio dataset. `CaptureFailedDataSet` la legge e la azzera a ogni errore, qualunque ramo poi risponda (iniziatore dataset, dump del gestore del dataset, traccia, candidati), perché un'apertura fallita non arriva mai a `DoAfterOpen` e l'errore successivo non va attribuito a lei.

### Scenario: apertura riuscita
- **Dato** un dataset che si apre senza errori
- **Quando** `DoAfterOpen` ha finito
- **Allora** `CurrentOpeningDataSet` è `nil`

### Scenario: aperture annidate
- **Dato** un dataset detail la cui apertura apre prima il master
- **Quando** il master finisce di aprirsi
- **Allora** `CurrentOpeningDataSet` non viene azzerata, perché contiene ancora il detail

## ZFIB-ERR-006 Candidati quando il responsabile non è certo
Se non c'è un dataset noto, si cerca la connessione (in quest'ordine: `ASender` è una connessione; `AInitiator` è un componente con una connessione; `ASender` è un componente che ne ha una; la connessione in uso nel `FDManager`) e si elencano i suoi dataset **attivi**, ciascuno con il suo dump, fino a otto. Gli altri sono sostituiti da una riga «altri dataset attivi omessi (limite 8)». Un dataset registrato sulla connessione che non è un `TFDDataSet` è saltato senza far perdere la cattura. Se il candidato è uno solo, nome, identificativo e modulo vengono registrati come per un dataset certo; se sono più d'uno, il testo dice apertamente che il responsabile non è identificabile.

### Scenario: un solo dataset attivo
- **Dato** un errore con `AInitiator` nullo e un solo dataset attivo sulla connessione
- **Quando** si cattura il contesto
- **Allora** il dump elenca quel dataset come candidato e ne registra nome e identificativo

### Scenario: nessun dataset attivo
- **Dato** un errore senza dataset in apertura e nessun dataset attivo
- **Quando** si cattura il contesto
- **Allora** il dump dice «nessun dataset attivo sulla connessione in questo momento»

## ZFIB-ERR-007 Contenuto del dump di un dataset
`DumpDataSet(ADS)` produce sezioni separate da titoli:
- **SQL**: il testo della query o la chiamata `EXECUTE PROCEDURE nome(valori)` della stored procedure, con l'elenco dei parametri (nome, tipo, direzione per le procedure, valore) e una versione **letterale** della query con i parametri sostituiti, da incollare in IBExpert; i parametri di uscita non entrano nella chiamata;
- **Istruzione DML ricostruita** quando il dataset è in inserimento o modifica: la `INSERT` con le sole colonne valorizzate, o la `UPDATE` con le sole colonne cambiate e la `WHERE` sui campi chiave coi loro valori **precedenti**; non è il testo mandato da FireDAC, che non lo espone, ma segue le stesse regole. La `DELETE` non è ricostruibile (durante `Delete` il dataset resta in `dsBrowse`);
- **Campi valorizzati** del record corrente (nome, tipo, valore, incolonnati; i memo riportati per intero), **campi vuoti** (solo i nomi) e **campi vuoti con un valore predefinito previsto** (Mantis #153), così si vede se un inserimento ha perso i valori predefiniti (`Salvataggio e valori predefiniti.md`, ZFIB-SAL-010);
- il dataset vuoto fuori da inserimento e modifica produce «(dataset vuoto)».

Per la ricostruzione della DML la tabella è `UpdateTableName`, o la tabella che FireDAC dichiara, o la prima dopo `FROM` della SELECT (nei dataset documentali è proprio la vista aggiornabile).

### Scenario: inserimento in corso
- **Dato** un dataset in `dsInsert` con due campi valorizzati
- **Quando** si chiede `DumpDataSet`
- **Allora** il dump contiene un `INSERT` con quei due campi e i valori

### Scenario: parametro nullo
- **Dato** una query con un parametro `NULL`
- **Quando** si chiede `DumpDataSet`
- **Allora** nella versione letterale il parametro compare come `NULL`

## ZFIB-ERR-008 Valori scritti come letterali e contesto delle connessioni
Un valore di parametro o di campo diventa un letterale SQL così: `NULL`; interi e booleani (come `1` o `0`) senza apici; numeri con il **punto** decimale a prescindere dalla lingua della macchina; date, ore e data-ora in formato `aaaa-mm-gg`, `hh:nn:ss`, `aaaa-mm-gg hh:nn:ss` fra apici; testo fra apici con l'apice raddoppiato; valori binari o memo di parametri non riportati e sostituiti da un commento `/* BLOB nome: ... */`. Un valore che non si legge diventa `/* valore non leggibile (messaggio) */`.

`CollectFireDacContext` (agganciata a `OnCollectDbContext`) scrive lo stato di `FDManager` e, per ogni connessione già creata, stato, transazioni e dataset aperti; una connessione non ancora istanziata non viene creata solo per descriverla.

### Scenario: numero decimale
- **Dato** un parametro 12,5 su una macchina con la virgola decimale
- **Quando** si ricostruisce la versione letterale
- **Allora** compare `12.5`

### Scenario: apice nel testo
- **Dato** un parametro di testo `L'aquila`
- **Quando** si ricostruisce la versione letterale
- **Allora** compare `'L''aquila'`

## ZFIB-ERR-009 Identificativo LZ del dataset (`IdDataSetOf`)
Solo un `TzFbDataSet` ha un identificativo, nella forma `NomeModuloDati.NomeDataSet`, la chiave con cui la finestra di dettaglio apre l'editor dell'SQL del dataset. Se `IdDataSet` è ancora vuoto (l'errore scatta durante il caricamento delle proprietà dall'LZ) lo si ricostruisce da proprietario e nome. Per ogni altro tipo di dataset il risultato è la stringa vuota, e la finestra non offre l'editor.

### Scenario: dataset che non è dell'LZ
- **Dato** una `TFDQuery` qualunque
- **Quando** si chiede `IdDataSetOf`
- **Allora** il risultato è una stringa vuota

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-197 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-ERR-1 e 2 sono state corrette nel rilascio 008 e non compaiono più (nessuna prova: servono un errore vero e un dataset in apertura). Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-ERR-4 🟢 (in parte corretta nel rilascio 012) | Le prove ora ci sono (vedi sopra) e hanno trovato un difetto, corretto: con `ASender` o `AInitiator` nulli la riga di registro iniziale di `CaptureFailedDataSet` sollevava una violazione di accesso, e la cattura si fermava al dump minimo anche quando c'era un dataset in apertura da riportare | Restano senza prova il dump di una stored procedure e la ricostruzione della DML su un conflitto di aggiornamento: una loro modifica può ancora togliere il contesto dal ticket senza che nessuna prova lo dica |

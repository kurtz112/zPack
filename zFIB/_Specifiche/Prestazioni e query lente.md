---
area: Prestazioni e query lente
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Prestazioni e query lente

Questa specifica descrive come `TzFbDataSet` (unit `zFbDataSet.pas`) prepara le query, legge le righe e misura il tempo che ci mette, e quali scelte servono a non far pagare al server un'esecuzione di troppo. Descrive il comportamento atteso, non il codice. Nasce dal lavoro del Mantis #183 (query pesanti di Gesty), dal #49 (attribuire un errore al dataset che lo ha causato) e dal #161 (campi ricostruiti prima dell'apertura). Le regole di apertura e di cambio di SQL sono in `Dataset Firebird.md` (ZFIB-DAT), la ricerca in `Ricerca nel dataset.md` (ZFIB-LOC).

**Perché conta.** Su query complesse (viste con molti join, elenchi di incarichi) ogni esecuzione in più costa secondi, e in connessione VPN la preparazione di decine di dataset si somma: le misure del #183 riportano 255 ms per la preparazione di un solo dataset (Progetti), 11,3 s su 64 dataset in una sessione in VPN, 3,7 s per leggere la sola struttura di «Incarichi Da Gestire», circa 100 ms a riga per un BLOB letto riga per riga (una stampa di 300 righe da 7 a 30 s).

**Test che coprono quest'area.** Nessuno diretto: le prove sono state fatte a mano su progetti di prova in `D:\AI\SandBox` (`Prova183FieldDefs`). I casi qui sotto sono quelli per cui un test automatico sarebbe sensato.

## ZFIB-PRE-001 Struttura delle colonne letta senza far lavorare il server
Quando `BuildFields` deve rileggere la struttura delle colonne (`clear` richiesto o nessun `FieldDef`) e il dataset non era ancora preparato, **prepara la SELECT con `RecsMax = 0`**: FireDAC aggiunge `ROWS 0` in coda, il server non produce righe e la definizione costa pochi millisecondi. Senza questo, `FieldDefs.Update` a dataset chiuso eseguirebbe la SELECT per intero (il driver Firebird definisce le colonne aprendo il cursore) e poi l'apertura vera la rieseguirebbe. Il meccanismo si usa solo se: `zfoFieldDefsWithoutRows` è fra le `ExtendedFetchOptions`; `FetchOptions.Mode` non è `fmExactRecsMax` (non genera il limite); `RecsSkip` non è positivo; la SELECT non è vuota.

### Scenario: dataset non preparato
- **Dato** un dataset di una vista pesante, non ancora preparato, con `ExtendedFetchOptions` predefinite
- **Quando** si chiama `BuildFields(True)`
- **Allora** i `FieldDefs` sono identici a quelli letti con l'esecuzione
- **E** il server non ha eseguito la query sulle righe

### Scenario: meccanismo spento
- **Dato** un dataset con `zfoFieldDefsWithoutRows` tolto da `ExtendedFetchOptions`
- **Quando** si chiama `BuildFields(True)`
- **Allora** la struttura si legge eseguendo la query come prima

## ZFIB-PRE-002 Ripiego quando `ROWS 0` non è ammesso
Se la preparazione con limite zero fallisce (per esempio una `SELECT FIRST n`, che Firebird rifiuta insieme a `ROWS` con errore -104) il dataset rimette il limite di prima, sprepara e prepara in modo normale: costa l'esecuzione in più come prima, ma la struttura si legge lo stesso. Se la SELECT è davvero sbagliata l'errore esce dalla preparazione normale come sempre. In ogni caso, finita la lettura della struttura, il dataset **rimette il `RecsMax` del dizionario e sprepara**: una preparazione con `ROWS 0` non deve mai servire un'apertura vera, che darebbe zero righe.

### Scenario: SELECT FIRST
- **Dato** una SELECT con `FIRST 10`
- **Quando** si chiama `BuildFields(True)`
- **Allora** la struttura è letta senza errore e `RecsMax` è quello di prima

### Scenario: apertura dopo la lettura della struttura
- **Dato** un dataset dopo `BuildFields` con preparazione senza righe
- **Quando** si apre
- **Allora** restituisce le righe vere (non zero)

## ZFIB-PRE-003 Preparazione conservata e firma dei parametri
Se `BuildFields` ha trovato il dataset già preparato (o la struttura era già nota) la preparazione resta in piedi e l'apertura che segue la riusa: risparmia un giro di rete e il lavoro dell'ottimizzatore, per ogni dataset. Per riconoscere una preparazione ormai invalida il dataset conserva una **firma dei parametri** (nome, tipo, dimensione, precisione, scala e verso di ciascuno): prima dell'apertura, se la firma è diversa, sprepara e prepara di nuovo. Il valore dei parametri non fa parte della firma.

### Scenario: stessi tipi
- **Dato** un dataset preparato da `BuildFields`
- **Quando** si cambia solo il valore di un parametro e si apre
- **Allora** non c'è una nuova preparazione

### Scenario: tipo diverso
- **Dato** lo stesso dataset
- **Quando** si cambia il tipo di un parametro e si apre
- **Allora** il dataset sprepara e prepara prima di aprire

## ZFIB-PRE-004 Riprova unica se la preparazione riusata non è valida
La firma non vede un caso: nel costrutto `(CAMPO = :P) OR (:P IS NULL)`, usato da 201 dataset di Gesty per i filtri facoltativi, Firebird descrive le due occorrenze dello stesso parametro con tipi diversi (la seconda è sempre `SQL_NULL`) e FireDAC può rifiutare l'esecuzione con la preparazione riusata. Se l'apertura con la preparazione conservata solleva un errore, il dataset lo scrive nel registro, sprepara e **riprova una volta sola** con la preparazione normale; se fallisce anche così l'errore esce.

### Scenario: filtro facoltativo
- **Dato** un dataset con `(CAMPO = :P) OR (:P IS NULL)` preparato da `BuildFields`
- **Quando** si apre
- **Allora** si apre, direttamente o dopo una sola ripreparazione, senza errori per l'utente

## ZFIB-PRE-005 Opzioni di lettura aggiuntive (`ExtendedFetchOptions`)
Due opzioni, impostabili per dataset dal dizionario LZ (`TzDataSet.ExtendedFetchOptions`), in aggiunta alle `FetchOptions` di FireDAC:
- `zfoBlobsWithRow` (predefinita): i BLOB arrivano insieme alla riga. Tolta, FireDAC li legge quando il campo viene letto, rieseguendo per quella riga la `RefreshSQL`: senza chiave primaria la lettura **fallisce**, su una vista pesante costa una query per riga. Si toglie solo sui dataset di cui si guardano i BLOB del solo record corrente, mai su quelli usati per le stampe. È una vista su `fiBlobs` di `FetchOptions.Items`, che resta l'unico stato vero: chi tocca `FetchOptions` direttamente la vede riflessa.
- `zfoFieldDefsWithoutRows` (predefinita): ZFIB-PRE-001.

La proprietà si salva nel `.dfm` solo se diversa dal predefinito.

### Scenario: BLOB solo del record corrente
- **Dato** un dataset senza `zfoBlobsWithRow`
- **Quando** lo si scorre e si legge un BLOB
- **Allora** il BLOB della riga si legge al momento, con una query per riga

### Scenario: coerenza con FetchOptions
- **Dato** un dataset con `fiBlobs` tolto da `FetchOptions.Items` nel codice
- **Quando** si legge `ExtendedFetchOptions`
- **Allora** `zfoBlobsWithRow` non c'è

## ZFIB-PRE-006 Dataset in apertura (`CurrentOpeningDataSet`)
Durante l'apertura e la preparazione che la precede (`BuildFields`) la variabile globale `CurrentOpeningDataSet` contiene il dataset. Serve a chi raccoglie il contesto di un errore del database (`zExceptions.firedac`): nel gestore di errore della connessione il dataset non è altrimenti raggiungibile (arrivano la connessione e il comando) e non è ancora attivo. Regole: chi la valorizza la azzera **solo se contiene ancora il proprio dataset** (le aperture si annidano: un dettaglio apre prima il suo master); `BuildFields` salva e ripristina il valore, perché può essere chiamata dentro l'apertura di un altro dataset; chi la consuma attribuendo un errore la azzera, altrimenti un'apertura fallita (che non arriva a `DoAfterOpen`) farebbe attribuire a questo dataset l'errore successivo. La dipendenza va in un solo verso: il livello dati dichiara cosa sta facendo, la diagnostica legge.

### Scenario: errore in apertura
- **Dato** un dataset la cui SELECT usa una colonna eliminata
- **Quando** si apre
- **Allora** l'errore riporta il nome del dataset da correggere

### Scenario: apertura annidata
- **Dato** un dettaglio che apre prima il suo master
- **Quando** il master finisce di aprirsi
- **Allora** la traccia del dettaglio non è cancellata

### Scenario: errore successivo
- **Dato** un'apertura fallita e un errore attribuito a quel dataset
- **Quando** poco dopo avviene un altro errore del database non legato ad aperture
- **Allora** non viene attribuito al dataset di prima

## ZFIB-PRE-007 Misura del tempo di apertura
`OpenTime` è il tempo trascorso fra l'inizio dell'apertura (dopo la preparazione dei parametri) e `DoAfterOpen`, in `TTimeSpan`. Con la registrazione delle prestazioni attiva (azionabile dall'utente per l'assistenza) ogni apertura è segnalata a `zDiagnostica.Log.Perf` con nome del dataset, durata e `GetDebugInfo` (SQL e parametri). A registrazione spenta il costo è la lettura di un booleano: `GetDebugInfo`, che ricostruisce SQL e parametri, non viene chiamata. `BuildFields` misura allo stesso modo (nome, già preparato sì/no, senza righe sì/no). La raccolta ha una soglia in millisecondi (iniziale 300) oltre la quale un evento compare nel dettaglio; l'aggregato comprende sempre tutti gli eventi.

### Scenario: registrazione accesa
- **Dato** la registrazione delle prestazioni accesa
- **Quando** un dataset si apre in 800 ms
- **Allora** l'evento compare con nome e durata del dataset

### Scenario: registrazione spenta
- **Dato** la registrazione spenta
- **Quando** un dataset si apre
- **Allora** il dataset non compone il testo di diagnostica

## ZFIB-PRE-008 Misura dei rowset letti (`RegistrazioneFetchAttiva`)
Con la registrazione dei fetch accesa (casella «tempi dei dataset») il dataset misura ogni gruppo di righe letto dal server. Il primo fetch dell'apertura è quello in cui Firebird esegue la query e la ordina; i successivi sono solo trasferimento: per questo hanno due nomi (`<dataset> fetch 1` e `<dataset> fetch 2+`) e il riepilogo li somma separati. Ogni misura riporta numero del fetch, indici del primo e dell'ultimo record, righe arrivate e righe lette finora. Il contatore riparte a ogni apertura e alla fine dell'apertura si scrive quanti fetch ha richiesto. Se la registrazione si accende fra l'inizio e la fine di un fetch non si scrive niente; un cronometro rimasto in corsa da un fetch fallito si ferma, per non attribuirlo al fetch successivo.

### Scenario: due fetch
- **Dato** un dataset che legge 1000 righe in due gruppi
- **Quando** si apre con la registrazione dei fetch accesa
- **Allora** compaiono una misura `fetch 1` e una `fetch 2+`
- **E** alla fine dell'apertura il registro dice «2 fetch»

## ZFIB-PRE-009 Dataset sequenziale (`InitForwardOnly`)
`InitForwardOnly` mette il dataset in lettura sequenziale a richiesta (`UniDirectional`, `fmOnDemand`, `RecsMax = -1`, `SilentMode`) e ricostruisce i campi con `BuildFields(True)`. Con `doDisableControls` vero (predefinito) chiama anche `DisableControls`: l'`EnableControls` corrispondente è a carico del chiamante, di norma in un `try/finally` (scelta documentata nel codice, già DIV-PRE-2).

### Scenario: lettura di un grande elenco
- **Dato** un dataset con `InitForwardOnly`
- **Quando** lo si scorre fino alla fine
- **Allora** non tiene in memoria tutte le righe e non si può tornare indietro

## ZFIB-PRE-010 Blocco del ridisegno (`DisableControlsExt`, `EnableControlsExt`)
`DisableControlsExt` salva `BlockReadSize` e `FetchOptions.DetailDelay` (solo alla prima chiamata di una serie), poi mette `BlockReadSize` a `MaxInt` e `DetailDelay` a 0: le griglie non ridisegnano e i dettagli seguono subito il master. Le chiamate si annidano con un contatore. `EnableControlsExt` scende di uno e, quando il contatore torna a zero, rimette i valori salvati. Una `EnableControlsExt` senza la `DisableControlsExt` corrispondente non fa niente. **Il contatore scende anche a dataset chiuso**: se il dataset si chiude (o è chiuso da una riapertura) fra le due chiamate, la serie si chiude lo stesso e i valori salvati si rimettono. Una `DisableControlsExt` a dataset chiuso non fa niente.

### Scenario: chiusura fra le due chiamate
- **Dato** un dataset su cui si è chiamata `DisableControlsExt`
- **Quando** il dataset si chiude e poi si chiama `EnableControlsExt`
- **Allora** il contatore torna a zero e, alla riapertura, una coppia nuova salva i valori attuali e li rimette

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-PRE-1 è stata corretta nel rilascio 008 (ZFIB-PRE-010).

Nessuna divergenza aperta. DIV-PRE-2 è stata chiusa documentando il comportamento (rilascio 010): `InitForwardOnly(True)` lascia i controlli disabilitati per scelta, e il chiamante deve chiamare `EnableControls` a fine lettura, di norma in un `try/finally`; il commento nel codice lo dice, e ZFIB-PRE-009 lo riporta.

---
area: Dataset Firebird
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Dataset Firebird

Questa specifica descrive come `TzFbDataSet` (unit `zFbDataSet.pas`, discendente di `TFDQuery`) si costruisce, si apre, cambia la propria SELECT e segue il dataset master. Descrive il comportamento atteso, non il codice. Le altre aree di zFIB hanno una specifica propria:

| Area | File | Prefisso |
|---|---|---|
| Nuovo record, valori predefiniti, salvataggio | `Salvataggio e valori predefiniti.md` | ZFIB-SAL |
| Ricerca nel dataset (`Locate`, `Lookup`) | `Ricerca nel dataset.md` | ZFIB-LOC |
| Connessione, transazioni, generatori | `Transazioni e connessione.md` | ZFIB-TRA |
| Procedure memorizzate (`TzStoredProc`) | `Procedure memorizzate.md` | ZFIB-SPR |
| `TNullable<T>` | `Valori nullable.md` | ZFIB-NUL |
| Preparazione, lettura delle righe, misure | `Prestazioni e query lente.md` | ZFIB-PRE |

**Cosa compone zFIB.** Il pacchetto `zBase_FIB_Delphi*.dpk` contiene solo `zBase_FIB_Register.pas`. Le unit vere stanno nella stessa cartella: `zFbDataSet.pas` (`TzFbDatabase`, `TzFbTransaction`, `TzFbDataSet`, `TzFbStoredProc`, gli helper di `TFDConnection`, `TFDStoredProc`, `TFDParam`, `TFDAdaptedDataSet` e `TDataSet`), `zFbScriptRunner.pas` e le unit `zSql.*` (analisi e composizione del testo SQL). Due classi di cui si parla qui non stanno in zFIB: `TzStoredProc` è in `zBase\zStoredProc.pas` e `TNullable<T>` in `zLibs\zz.Nullable.pas`. La cartella `zFDAC backup` è storia e non si compila. `zFbScriptRunner`, le unit `zSql.*` e `zExceptions.firedac` hanno le specifiche `Esecuzione di script.md` (ZFIB-SCR), `Analisi del testo SQL.md` (ZFIB-SQL) e `Contesto degli errori.md` (ZFIB-ERR).

**Test che coprono quest'area.** Nessuno in modo diretto: l'apertura, il cambio di SQL e il master/detail non hanno test automatici. I test esistenti sono citati nelle altre specifiche (`Test.zFbDataSet.Predefiniti`, `Test.zFbDataSet.CampiBinari`, `Test.zFbDataSet.UpdateParziale`); `Test.zFbDataSet.Divergenze` prova ZFIB-DAT-005 (chiavi) e ZFIB-DAT-006 (la `Where` passa da `Test.zSql.TestoSql`). La divergenza DIV-DAT-8 è dedotta dalla lettura del codice e non ha ancora una prova.

## ZFIB-DAT-001 Valori iniziali di un dataset nuovo
Un `TzFbDataSet` appena creato ha questi valori, che il dizionario LZ o il codice cambiano dopo: `ActivationMode = amAutomatic`, `AutoCommit = True`, `AutoCreateFields = True`, `UseSqlLocate = True`, `Sanification = True`, `ReopenAfterPost = False`, `UpdateChangedFields = False`, `AutoUpdate = False`, `CachedUpdates = False`, `ExtendedFetchOptions = [zfoBlobsWithRow, zfoFieldDefsWithoutRows]`, `FetchOptions.DetailDelay = 300` ms, `FetchOptions.AutoFetchAll = afTruncate`, `NewRecordOptions.ParamsToFields` e `MasterToFields` veri. Il motivo di `afTruncate`: un inserimento nel master di un master/detail non deve scaricare per intero il dataset del dettaglio.

### Scenario: dataset creato da codice
- **Dato** un `TzFbDataSet` creato con `Create(Owner)`
- **Quando** si leggono le proprietà sopra elencate
- **Allora** hanno i valori indicati
- **E** `OnError` è collegato al gestore comune degli errori FireDAC (`DataSetErrorHandler.HandleDataSetError`, unit `zExceptions.firedac`)
- **E** il dataset ha un `TFDUpdateSQL` interno già assegnato come `UpdateObject`

## ZFIB-DAT-002 Fabbrica `CreateFbDataSet`
`CreateFbDataSet(Owner, Connection, ReadTrans, WriteTrans, UniDirectional)` crea il dataset e gli assegna connessione, transazione di lettura (`Transaction`) e di scrittura (`UpdateTransaction`). Con `UniDirectional = True` lo mette in sola lettura sequenziale, senza memorizzare le righe: `FetchOptions.UniDirectional = True`, `Mode = fmOnDemand`, `RecsMax = -1`, `SilentMode = True`. Di norma si usa per scorrere grandi elenchi una volta sola.

### Scenario: dataset sequenziale
- **Dato** una connessione e due transazioni
- **Quando** si chiama `CreateFbDataSet(nil, Connessione, Lettura, Scrittura, True)`
- **Allora** le righe si leggono una alla volta, non si può tornare indietro e il numero di righe non è limitato

## ZFIB-DAT-003 Modalità di attivazione (`ActivationMode`)
`ActivationMode` dice se il dataset va aperto da solo (`amAutomatic`, `amWhenNeeded`) o solo su richiesta esplicita del codice (`amManual`). **Il dataset non si apre da sé in nessuno dei tre casi**: la proprietà è solo dichiarata, e la leggono i controllori delle form. Oggi l'unica lettura è `TzDataController.GetAutoOpen` (`zBase\zDataController.pas`), che risponde «apri» per ogni valore diverso da `amManual`. `amAutomatic` e `amWhenNeeded` sono quindi equivalenti (vedi DIV-DAT-1). La proprietà viaggia dal dizionario LZ (`TzDataSet.ActivationMode`) al dataset quando si crea e viceversa quando si salva il dizionario. `Active` non si salva nel `.dfm` (`stored false`).

### Scenario: dataset manuale
- **Dato** un dataset con `ActivationMode = amManual` su una form generata dai metadati
- **Quando** la form si apre
- **Allora** il dataset resta chiuso finché il codice non lo apre

### Scenario: dataset automatico
- **Dato** un dataset con `ActivationMode = amAutomatic` o `amWhenNeeded`
- **Quando** la form si apre
- **Allora** il controllore lo apre

## ZFIB-DAT-004 Cosa succede prima dell'apertura
Prima di aprire, il dataset esegue sempre, in quest'ordine: registra se stesso come «dataset in apertura» (ZFIB-PRE-006); controlla `KeyFields` e `AutoIncFields` (ZFIB-DAT-005); copia nei propri parametri i valori del master (ZFIB-DAT-009); chiama `OnGetQueryParams` perché il codice completi i parametri; se la SELECT è cambiata e il dataset ha già dei campi, li ricostruisce con `BuildFields(True)` prima di aprire (ZFIB-DAT-007); se i parametri hanno tipo, dimensione, precisione, scala o verso diversi da quelli della preparazione conservata, sprepara (ZFIB-PRE-003). Una SELECT vuota non impedisce l'apertura: scrive un avviso rosso nel registro (`SQL non specificato`) e lascia a FireDAC l'errore.

### Scenario: parametri cambiati dopo la preparazione
- **Dato** un dataset preparato da `BuildFields` con un parametro intero
- **Quando** `OnGetQueryParams` ne cambia il tipo prima dell'apertura
- **Allora** il dataset sprepara e prepara di nuovo, invece di fallire con «Query must be reprepared»

## ZFIB-DAT-005 Controllo delle chiavi a ogni apertura
Se `UpdateOptions.KeyFields` o `UpdateOptions.AutoIncFields` nominano un campo che non esiste nel risultato, il dataset **toglie dalla proprietà i campi che non esistono** (e conserva quelli giusti: `ID;ID_X` diventa `ID`) e scrive l'errore nel registro; non solleva eccezioni. Il motivo: una chiave sbagliata nel dizionario non deve impedire di leggere i dati. Se tutti i campi sono sbagliati la proprietà diventa vuota e le modifiche successive non hanno una chiave per aggiornare la riga (vedi DIV-DAT-2). Se all'apertura il dataset non ha ancora campi, il controllo non fa niente.

### Scenario: chiave inesistente
- **Dato** un dataset con `KeyFields = 'ID_X'` che la SELECT non restituisce
- **Quando** si apre
- **Allora** il dataset si apre
- **E** `UpdateOptions.KeyFields` diventa vuoto
- **E** nel registro compare «KeyFields non valido sul dataset»

## ZFIB-DAT-006 Testo della SELECT e delle altre istruzioni
`SelectSQL` e `SQL_Select` sono lo stesso testo di `SQL`. `InsertSQL`, `UpdateSQL`, `DeleteSQL`, `RefreshSQL` (e gli alias `SQL_*`) sono il testo di `InsertSQL`, `ModifySQL`, `DeleteSQL`, `FetchRowSQL` del `TFDUpdateSQL` interno. `DefaultSQL` è la SELECT di partenza a cui `RevertSQL` ritorna. `CountSQL` è l'istruzione di conteggio. `Where` (e `MainWhereClause`) legge e scrive la clausola WHERE principale della SELECT (non la prima del testo, che può stare in una sottoquery); se la SELECT non ha WHERE, scrivere un valore la aggiunge, e scrivere un valore vuoto non fa niente; `OrderBy` (e `OrderClause`) la clausola ORDER BY; `AddWhereCondition` aggiunge una condizione in AND.

### Scenario: aggiunta di una condizione
- **Dato** un dataset aperto con una SELECT senza WHERE
- **Quando** si chiama `AddWhereCondition('STATO = 1')`
- **Allora** la SELECT riporta `WHERE STATO = 1`, i campi si ricostruiscono e il dataset si riapre

## ZFIB-DAT-007 Cambio di SQL (`ChangeSQL`, `TryChangeSQL`, `Where`, `OrderBy`, `ApplyFilter`)
Cambiare la SELECT chiude il dataset, marca i campi da ricostruire e, **se il dataset era aperto, lo riapre**; se era chiuso resta chiuso. Se il nuovo testo è uguale al vecchio (senza distinguere maiuscole) non succede niente. Se la riapertura fallisce, il dataset rimette la vecchia SELECT, la riapre e **rilancia l'errore originale**: un errore sul ripristino si scrive nel registro ma non maschera quello vero. Questo è il comportamento di `ChangeSQL`, usato da `Where`, `OrderBy` e `ApplyFilter`. `TryChangeSQL` fa lo stesso ma **non rilancia**: scrive l'errore nel registro e restituisce `False` (`True` se il cambio riesce o il testo è uguale).

### Scenario: nuova SQL non valida
- **Dato** un dataset aperto
- **Quando** `ChangeSQL` riceve una SELECT che il server rifiuta
- **Allora** l'eccezione del server arriva al chiamante
- **E** il dataset torna aperto con la SELECT precedente

### Scenario: nuova SQL non valida con TryChangeSQL
- **Dato** un dataset aperto
- **Quando** `TryChangeSQL` riceve una SELECT che il server rifiuta
- **Allora** restituisce `False` e non solleva
- **E** il dataset torna aperto con la SELECT precedente

### Scenario: stessa SQL
- **Dato** un dataset aperto
- **Quando** `ChangeSQL` o `TryChangeSQL` riceve lo stesso testo con maiuscole diverse
- **Allora** il dataset non si chiude e non si riapre

## ZFIB-DAT-008 Ritorno alla SELECT di partenza
`RevetNeeded` è vero se `DefaultSQL` non è vuoto e diverso dalla SELECT attuale. `RevertSQL(Activate)` chiude il dataset se la SELECT è diversa o se `Activate` è vero, rimette `DefaultSQL` se serve e, con `Activate`, riapre. Con `DefaultSQL` vuoto non ha niente da ripristinare e la SELECT non cambia mai.

### Scenario: ripristino con riapertura
- **Dato** un dataset filtrato da `AddWhereCondition` e con `DefaultSQL` valorizzato
- **Quando** si chiama `RevertSQL(True)`
- **Allora** la SELECT torna a `DefaultSQL` e il dataset è aperto

## ZFIB-DAT-009 Master/detail
Un dataset con `DataSource` collegato a un altro `TzFbDataSet` prende i propri parametri di ingresso dal master: per ogni parametro in ingresso cerca prima un parametro omonimo del master, poi un campo omonimo. Con `LoadParamsFromMaster` i valori si sovrascrivono sempre; con `CopyParams(Master, False)` solo quelli ancora nulli. Il master è letto anche all'apertura e a ogni cambio di record (`CheckMasterRange`). Il detail si riapre solo se almeno un parametro è davvero cambiato. I parametri senza corrispondenza nel master restano come sono. Un master che non è un `TzFbDataSet` non viene letto.

### Scenario: cambio di record nel master
- **Dato** un master e un detail con parametro `ID_PROGETTO`
- **Quando** il master si sposta su un altro progetto
- **Allora** il detail copia il nuovo valore e si riapre dopo `DetailDelay`

### Scenario: stesso valore
- **Dato** un master che si sposta su un record con lo stesso valore del collegamento
- **Quando** il detail ricarica i parametri
- **Allora** il detail non si riapre

## ZFIB-DAT-010 Scorrimento da codice (`DisableControlsExt`, `EnableControlsExt`)
Per scorrere il dataset da codice (stampe, esportazioni) senza ridisegnare le griglie e **senza spegnere il master/detail**, `DisableControlsExt` imposta `BlockReadSize = MaxInt` e `DetailDelay = 0`; `EnableControlsExt` li rimette ai valori salvati. Le chiamate si possono annidare: solo l'ultima `EnableControlsExt` ripristina. Una `EnableControlsExt` senza la sua `DisableControlsExt` non fa niente. Con il dataset chiuso la `DisableControlsExt` non fa niente, mentre la `EnableControlsExt` chiude comunque la serie e rimette i valori salvati (ZFIB-PRE-010).

### Scenario: annidamento
- **Dato** un dataset aperto con `DetailDelay = 300`
- **Quando** si chiamano due volte `DisableControlsExt` e una volta `EnableControlsExt`
- **Allora** `DetailDelay` resta 0
- **E** dopo la seconda `EnableControlsExt` torna 300

## ZFIB-DAT-011 Nuovo record in un master/detail: il master non deve essere in modifica
Prima di inserire un record in un dettaglio, se il master è in inserimento o in modifica, il dataset forza il salvataggio (`CheckBrowseMode`) del master, **senza attivare il suo master/detail** (`DisableControlsExt`), perché altrimenti salverebbe anche il dettaglio.

### Scenario: dettaglio in un master in modifica
- **Dato** un master in `dsEdit`
- **Quando** si inserisce un record nel dettaglio
- **Allora** il master viene salvato prima

## ZFIB-DAT-012 Chiusura con modifiche pendenti
Prima di chiudersi, un dataset con modifiche non salvate (`Modified`) passa da `CheckBrowseMode`: le modifiche vengono salvate (o rifiutate dal controllo dei campi obbligatori, ZFIB-SAL-004), non perse in silenzio.

### Scenario: chiusura con riga in modifica
- **Dato** un dataset con una riga in `dsEdit` e `Modified = True`
- **Quando** si chiude
- **Allora** la riga viene salvata prima della chiusura

## ZFIB-DAT-013 Conteggio righe dal server (`RecordCountFromServer`)
Il conteggio si ottiene con una query separata, sulla stessa connessione e sulla stessa transazione di lettura, con i valori dei parametri copiati dal dataset. Il testo è il parametro `CountSQL` della funzione se non è vuoto; altrimenti la proprietà `CountSQL` del dataset se valorizzata; altrimenti la SELECT trasformata in `COUNT`. Ritorna il valore della prima colonna (parametro rispettato dal rilascio 010, già DIV-DAT-3).

### Scenario: conteggio senza CountSQL
- **Dato** un dataset con SELECT e due parametri valorizzati
- **Quando** si chiama `RecordCountFromServer`
- **Allora** i parametri della query di conteggio hanno gli stessi valori e il risultato è il numero di righe che il server restituirebbe

## ZFIB-DAT-014 Limite di righe raggiunto
Se `FetchOptions.RecsMax` è positivo e il dataset, arrivato in fondo (`EOF`), ha esattamente `RecsMax` righe, scatta una volta sola per apertura `OnRecordLimitReached`, così l'interfaccia può avvisare che l'elenco è stato troncato. Il controllo si fa dopo ogni lettura di righe e dopo ogni scorrimento. Non interroga il server (costerebbe un conteggio su query complesse).

### Scenario: elenco troncato
- **Dato** un dataset con `RecsMax = 1000` e una SELECT che restituisce più righe
- **Quando** l'utente arriva all'ultima riga letta
- **Allora** `OnRecordLimitReached` viene chiamato una volta

### Scenario: riapertura
- **Dato** un dataset che ha già segnalato il limite
- **Quando** si riapre
- **Allora** il segnale può scattare di nuovo

## ZFIB-DAT-015 Campi: nome, tipo, attributi
Alla creazione dei campi ogni `TField` prende il nome `<NomeDataset><NomeCampo>` ripulito dai caratteri diversi da lettere, cifre e trattino basso (un campo `ID-X` nel dataset `Corsi` diventa `CorsiIDX`). Gli attributi dal dizionario LZ (`UpdateFieldAttributes`) si applicano solo alla prima creazione; alle successive si rimettono soltanto le espressioni predefinite (ZFIB-SAL-006). I campi automatici (creati dentro l'apertura) perdono gli attributi quando FireDAC li riscrive: il dataset li fotografa alla creazione e li rimette subito dopo (`Origin`, `DefaultExpression`, `ReadOnly`, `DisplayFormat`, `EditFormat`), così la griglia non mostra `123456` al posto di `123.456` (Mantis #161). I campi persistenti non sono toccati. Un campo in sola lettura per il solo fatto di essere in un join (`IsJoinedField`) o di essere `IdentityField` lo diventa per effetto di `SetFieldsReadOnly` e `SetIdentityField`.

### Scenario: maschera di un campo automatico
- **Dato** un dataset senza campi persistenti e una `DisplayFormat` assegnata in `InitFields`
- **Quando** si apre
- **Allora** la `DisplayFormat` è ancora sul campo dopo l'apertura

## ZFIB-DAT-016 Campi binari
Una colonna `CHAR(n) CHARACTER SET OCTETS` (dominio UUID) è un `TBinaryField`: la sua rappresentazione testuale è il valore in esadecimale maiuscolo, due cifre per byte, senza separatori (`TestoEsadecimale`); un valore nullo o vuoto dà testo vuoto. Il campo resta di sola lettura da tastiera. Se il codice ha già assegnato un proprio `OnGetText`, non viene sovrascritto. Test: `Test.zFbDataSet.CampiBinari` (`TestoEsadecimale_Vuoto`, `TestoEsadecimale_Uuid`, `TestoEsadecimale_ZeriIniziali`, `CampiAutomatici_Valorizzato_Esadecimale`, `CampiPersistenti_Valorizzato_Esadecimale`, `CampoNullo_TestoVuoto`, `GestoreProprio_NonSovrascritto`).

### Scenario: identificativo binario
- **Dato** un campo UUID con i byte `00 1F A0`
- **Quando** la griglia ne chiede il testo
- **Allora** vede `001FA0`

### Scenario: gestore proprio
- **Dato** un campo binario con `OnGetText` assegnato da un DataModule
- **Quando** il dataset crea i campi
- **Allora** il gestore del DataModule resta quello

## ZFIB-DAT-017 Origine dei campi
`FieldOrigin(Campo)` dà l'origine `TABELLA.COLONNA` della colonna. La ricava dal risultato della preparazione; quando il server non la dichiara (colonne di viste, espressioni) la cerca nel testo della SELECT con la sua tabella. `GetFieldByOrigin`, `GetFieldNameByOrigin` e `GetFieldTableName` fanno il percorso inverso. Le origini si ricalcolano a ogni ricostruzione dei campi o cambio di SQL. Quando la stessa colonna compare più volte nel risultato, ne conta la posizione fra le omonime. Il valore calcolato si conserva (cache per nome di campo) fino alla ricostruzione dei campi o al cambio di SQL (`InvalidateFieldOrigins`); se l'origine non si determina, il registro riceve l'errore «Origin non determinato» con SQL e dati della colonna, una volta sola per campo. Come le origini nascono sulle colonne e sui campi lo dice ZFIB-DAT-020.

### Scenario: colonna di una tabella
- **Dato** una SELECT `SELECT CORSI.ID, CORSI.TITOLO FROM CORSI`
- **Quando** si chiede `FieldOrigin` del campo `TITOLO`
- **Allora** il risultato è `CORSI.TITOLO`

## ZFIB-DAT-018 Dati di una riga e dei parametri
`GetParamValues(Parametri)` e `SetParamValues(Parametri)` copiano i parametri verso e da una lista `TParams` con nome, tipo e verso; `ParamExists` dice se esiste un parametro con quel nome; `ClearParamValues` mette a `Null` tutti i parametri di ingresso e di ingresso/uscita; `GetDebugInfo` restituisce SQL e parametri in forma leggibile per il registro. Gli helper di `TDataSet` danno l'enumerazione `for Riga in DataSet` (restituisce ogni record come variant; riposiziona il dataset dov'era), `ForEach` e `CurrentRec`.

### Scenario: svuotamento dei parametri
- **Dato** un dataset con due parametri di ingresso valorizzati
- **Quando** si chiama `ClearParamValues`
- **Allora** entrambi sono nulli

## ZFIB-DAT-019 Eliminazione, modifica e inserimento consentiti
`CanInsert`, `CanUpdate`, `CanDelete` riportano `UpdateOptions.EnableInsert`, `EnableUpdate`, `EnableDelete`. Prima di una cancellazione il registro riporta il testo del `DeleteSQL`.

### Scenario: dataset di sola lettura
- **Dato** un dataset con `UpdateOptions.EnableUpdate = False`
- **Quando** il codice chiede `CanUpdate`
- **Allora** la risposta è falsa

## ZFIB-DAT-020 Aggiornamento delle origini (`UpdateFieldOrigins`)
Quando il dataset costruisce i campi la prima volta, come primo passo di `UpdateFieldAttributes` (prima di `OnInitFields`, quindi prima che il dizionario LZ assegni gli attributi), ricava le origini in due fasi.

1. **Colonne.** Per ogni colonna del risultato preparato il cui `OriginTabName` è vuoto (il server non lo dichiara: espressioni, colonne di tabelle derivate, alcune viste) chiede a `TSelectOriginResolver` (ZFIB-SQL-007 e 008) l'origine `TABELLA.COLONNA` per nome della colonna nel risultato (`SourceName`) e posizione fra le omonime; se la risposta c'è, la spezza all'ultimo punto in `OriginTabName` e `OriginColName`. Il risolutore si costruisce una volta sola e solo se c'è almeno una colonna da risolvere. Le colonne per cui il server ha dichiarato la tabella non si toccano.
2. **Campi.** Azzera la cache delle origini e, per ogni campo che ha una colonna omonima con `OriginTabName` non vuoto, scrive `Field.Origin` come `TABELLA.COLONNA` **senza virgolette** (`AnsiDequotedStr`, Mantis 0005935) e lo mette nella cache usata da `FieldOrigin` (ZFIB-DAT-017).

I campi senza colonna omonima (calcolati dal dataset, di lookup) non ricevono nessuna origine: `FieldOrigin` risponde con il solo nome del campo. Se il dataset non ha una tabella (non ancora preparato) il metodo non fa niente. Il motivo: `LocateSQL` (ZFIB-LOC-007) e il riconoscimento dei campi di join (`IsJoinedField`, che confronta la tabella di origine con quella del dataset) hanno bisogno di sapere da quale tabella viene ogni colonna, e FireDAC lascia vuoto il dato quando il server non lo dichiara.

I campi automatici perdono `Origin` quando FireDAC li riscrive; il dataset li fotografa e li rimette (ZFIB-DAT-015).

### Scenario: espressione
- **Dato** una SELECT `SELECT UPPER(TITOLO) AS T FROM CORSI`
- **Quando** il dataset costruisce i campi
- **Allora** la colonna `T` resta senza origine e `FieldOrigin` del campo `T` è `T`

### Scenario: origine dichiarata dal server
- **Dato** una SELECT `SELECT C.TITOLO FROM CORSI C` su cui il server dichiara la tabella
- **Quando** il dataset costruisce i campi
- **Allora** l'origine è `CORSI.TITOLO` (tabella reale, non l'alias) e l'analisi del testo non interviene

### Scenario: due costruzioni di seguito
- **Dato** un dataset che ricostruisce i campi per un cambio di SQL
- **Quando** `UpdateFieldOrigins` gira di nuovo
- **Allora** la cache è azzerata e le origini sono quelle della SELECT nuova

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DAT-1 🟢 | `TActivationMode` ha tre valori ma `amWhenNeeded` non è letto da nessuno (solo `amManual` fa differenza, `TzDataController.GetAutoOpen`) | Chi imposta `amWhenNeeded` si aspetta un'apertura «quando serve» e ottiene l'apertura automatica; il significato previsto non è documentato da nessuna parte. Dal rilascio 011 il tipo ha un commento nel codice che lo dice; il comportamento resta quello |
| DIV-DAT-2 🟢 (corretta in parte nel rilascio 008) | `ValidateKeyFields` toglie solo i campi sbagliati e conserva i giusti (corretto), ma segnala l'errore solo nel registro (una volta con `LogError`, una con `LogMessage` della sessione principale) | L'utente non vede nulla; modifiche e cancellazioni su quel dataset falliscono più tardi con un errore che non nomina la chiave. Il controllo non fa niente se all'apertura il dataset non ha ancora campi (mai passato da `BuildFields`), perché non ha niente da confrontare |
| DIV-DAT-7 🟢 (parte rimasta) | Per un campo calcolato l'origine è il solo nome del campo (il ripiego morto che anteponeva la tabella è stato tolto nel rilascio 010, senza cambiare il risultato) | Una `LocateSQL` su un campo calcolato scrive una colonna che il server non conosce (vedi ZFIB-LOC-007): resta come comportamento noto, fuori dalla correzione |
| DIV-DAT-8 🟢 (dedotta) | `UpdateFieldOrigins` e `FieldOrigin` tolgono le virgolette da tabella e colonna (Mantis 0005935) | Una tabella o colonna creata con virgolette e minuscole o spazi (`"Clienti"."Nome Cognome"`) ha un'origine `Clienti.Nome Cognome`: nella condizione di `LocateSQL` il server la maiuscolizza o la rifiuta e la ricerca non funziona. Verificato il 2026-11-01 sui metadati di GESTY (master) e WT (master): nessuna tabella e nessuna colonna ha nome in minuscolo o con caratteri speciali, quindi oggi non si manifesta |

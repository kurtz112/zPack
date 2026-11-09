---
area: Procedure memorizzate
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Procedure memorizzate

Questa specifica descrive come il codice chiama le stored procedure di Firebird: la classe base `TzStoredProc` (unit `zBase\zStoredProc.pas`, **non** in zFIB, ma ne è la parte più usata), le classi `TSP_*` generate in `Wt3_StoredProcs.pas` e `Gesty_StoredProcs.pas`, e gli helper di `TFDStoredProc` e `TFDParam` che stanno in `zFbDataSet.pas`. Descrive il comportamento atteso, non il codice. `TzFbStoredProc` (in `zFbDataSet.pas`) è una classe vuota e non fa parte del meccanismo.

**Come funziona.** Ogni procedura ha una classe generata `TSP_NOMEPROCEDURA` che discende da `TzStoredProc`: l'attributo `TStoredProcedure` porta il nome della procedura e se è selezionabile (contiene `SUSPEND`), ogni proprietà con l'attributo `TParam` rappresenta un parametro in ingresso o in uscita. Il codice assegna le proprietà, chiama un metodo di esecuzione e legge le proprietà di uscita. I tipi delle proprietà sono `Nullable<T>` per gli scalari (ZFIB-NUL) e `TStringList` per i parametri MEMO e BLOB, letti e scritti con `.Text` (AGENTS.md, sezione 4 punto 6). I file generati non si modificano a mano: in caso di dubbio sulla firma si legge la classe `TSP_...`, non la si indovina.

**Test che coprono quest'area.** Nessuno: le correzioni di DIV-SPR-1 (immagine nulla) e DIV-SPR-5 (virgole di `DebugString`) del rilascio 008 non sono provate, perché i test non usano Firebird. `Test.zExceptions.Fib` prova la lettura del percorso delle chiamate negli errori Firebird (`zExceptions.firedac`), che è un'altra area.

## ZFIB-SPR-001 Creazione
Il costruttore legge l'attributo `TStoredProcedure` della classe e ne ricava `StoredProcName` e `Selectable`. Se esiste, chiama poi il gancio globale `InitStoredProc(Self)`, con cui l'applicazione assegna connessione, transazione e `zSystem`. `Create(Transazione)` assegna anche la transazione. Un `TzStoredProc` non è un componente: non ha proprietario e va liberato da chi lo crea.

### Scenario: nome della procedura
- **Dato** una classe `TSP_X` con attributo `TStoredProcedure('X', True)`
- **Quando** si crea
- **Allora** `StoredProcName = 'X'` e `Selectable = True`

## ZFIB-SPR-002 Esecuzione di una procedura con un'unica riga (`ExecuteAndCommit`, `ExecuteWithoutCommit`)
Eseguono `EXECUTE PROCEDURE`. Se la transazione non è attiva la avviano. `ExecuteAndCommit` conferma la transazione dopo l'esecuzione; `ExecuteWithoutCommit` la lascia com'è, aperta, perché è del DataModule chiamante e può avere altro lavoro. **In caso di errore**: con `ExecuteAndCommit` annulla la transazione (`Rollback`) e rilancia l'errore; con `ExecuteWithoutCommit` rilancia l'errore senza annullare niente. I valori di uscita si leggono **dopo** la conferma (i BLOB, con la conferma automatica, non sarebbero più leggibili: «invalid blob id»). Su una procedura selezionabile, `EXECUTE PROCEDURE` si ferma alla prima riga di `SUSPEND`.

### Scenario: esecuzione riuscita
- **Dato** una procedura con un parametro di uscita
- **Quando** si chiama `ExecuteAndCommit`
- **Allora** la transazione è confermata e la proprietà di uscita contiene il valore restituito

### Scenario: errore con conferma
- **Dato** una procedura che solleva un'eccezione nel server
- **Quando** si chiama `ExecuteAndCommit`
- **Allora** la transazione è annullata e l'eccezione arriva al chiamante

### Scenario: errore senza conferma
- **Dato** una procedura che solleva un'eccezione e una transazione con altro lavoro pendente
- **Quando** si chiama `ExecuteWithoutCommit`
- **Allora** l'eccezione arriva al chiamante e la transazione resta attiva con il suo lavoro

## ZFIB-SPR-003 Lettura di più righe (`Open`, `Next`, `EOF`, `Close`)
Per una procedura selezionabile (`SELECT * FROM procedura`) `Open` avvia la transazione se serve, apre il cursore e posiziona sulla prima riga; i valori di ritorno si leggono dalle proprietà di uscita, riempite dai campi del cursore. `Next` passa alla riga successiva e aggiorna le proprietà. `EOF` è vero se non c'è un cursore aperto o il cursore è finito. Al termine le proprietà di uscita sono nulle: non restano i valori dell'ultima riga. **`Open` non conferma mai**: la transazione deve restare aperta per tutta la lettura e il commit spetta al chiamante, dopo `Close`. Se l'apertura fallisce chiude il cursore, **non annulla** la transazione e rilancia l'errore. `Open` su una procedura non dichiarata selezionabile scrive un avviso nel registro ma procede.

### Scenario: scorrimento
- **Dato** una procedura selezionabile che restituisce tre righe
- **Quando** si chiama `Open` e poi `Next` finché non si arriva a `EOF`
- **Allora** le proprietà di uscita assumono a turno i valori delle tre righe
- **E** all'`EOF` le proprietà di uscita sono nulle

### Scenario: procedura non selezionabile
- **Dato** una classe con `Selectable = False`
- **Quando** si chiama `Open`
- **Allora** il registro riporta «Open su una procedura non dichiarata selezionabile» e la chiamata prosegue

### Scenario: scorrimento senza cursore
- **Dato** un `TzStoredProc` mai aperto
- **Quando** si chiama `Next`
- **Allora** non succede niente e `EOF` è vero

## ZFIB-SPR-004 Un'istanza si riusa
`CreateInternalStoredProc(AsCursor)` crea il `TFDStoredProc` interno alla prima chiamata e lo riusa dopo. Per cambiare modo (esecuzione singola o cursore) sulla stessa istanza deve ripreparare, perché FireDAC congela nel comando preparato la scelta fra `EXECUTE PROCEDURE` e `SELECT * FROM`. Richiede `DataBase` e `Transaction` assegnati (asserzione). A ogni chiamata ricarica i parametri di ingresso dalle proprietà.

### Scenario: passaggio da esecuzione a cursore
- **Dato** un'istanza già eseguita con `ExecuteAndCommit`
- **Quando** si chiama `Open`
- **Allora** il comando è ripreparato e la procedura si legge come `SELECT`

## ZFIB-SPR-005 Parametri di ingresso
Prima di ogni chiamata tutti i parametri del comando sono azzerati, poi per ogni proprietà di ingresso: se la proprietà è nulla il parametro è nullo, altrimenti riceve il valore con l'accessore del suo tipo (data, ora, data e ora, booleano) o `Value` per gli altri. Una proprietà senza parametro corrispondente nella procedura **non è un errore**: viene registrata («Parametro di input non trovato») e saltata. Una `TStringList` vuota vale nullo; un `TPicture` vale nullo se non ha nessuna immagine caricata (`Graphic` assente o vuoto): una bitmap mai valorizzata va a `NULL`.

### Scenario: parametro nullo
- **Dato** una proprietà `Nullable` senza valore
- **Quando** si esegue
- **Allora** il parametro arriva al server come `NULL`

### Scenario: parametro mancante
- **Dato** una classe generata con una proprietà il cui parametro non esiste più nella procedura
- **Quando** si esegue
- **Allora** il registro segnala il parametro e l'esecuzione prosegue senza quel valore

### Scenario: memo vuoto
- **Dato** un parametro MEMO con testo vuoto
- **Quando** si esegue
- **Allora** il parametro arriva al server come `NULL`

## ZFIB-SPR-006 Parametri di uscita
Dopo `ExecuteAndCommit`, `ExecuteWithoutCommit`, `Open` e `Next` i valori di uscita si copiano nelle proprietà: dai parametri se la procedura è stata eseguita, dai campi del cursore se è stata aperta come `SELECT`. Un valore nullo del server azzera la proprietà. Un'uscita senza proprietà corrispondente fra i parametri o le colonne è registrata e saltata.

### Scenario: uscita nulla
- **Dato** una procedura che restituisce `NULL`
- **Quando** si esegue
- **Allora** la proprietà di uscita non ha valore (`IsNull`)

## ZFIB-SPR-007 Lettura e scrittura dinamica dei parametri
`SetParamValue(Nome, Valore, ENullo)` assegna una proprietà di ingresso o di uscita per nome del parametro (non della proprietà): con `ENullo` vero la azzera. `SetParamValue(Campo)` e `SetParamValue(Nome, Campo)` copiano un campo di dataset (nullo compreso). `GetParamValue` e `ParamIsNull` leggono. `ClearParam`, `ClearParams` azzerano. `ParamExists` risponde per i soli parametri dichiarati nella classe, non quelli del server. Il nome di un parametro senza proprietà solleva «Proprietà non trovata per il parametro». Una classe di tipo `Nullable<T>` si scrive riempiendo i campi interni `fHasValue` e `fValue` per riflessione: rinominarli in `zz.Nullable.pas` rompe questa unit (ZFIB-NUL-007).

### Scenario: copia di un campo
- **Dato** un campo di dataset con valore 7 e una classe con parametro `ID`
- **Quando** si chiama `SetParamValue('ID', Campo)`
- **Allora** la proprietà `ID` vale 7

### Scenario: parametro sconosciuto
- **Dato** un nome di parametro che la classe non dichiara
- **Quando** si chiama `SetParamValue`
- **Allora** viene sollevata un'eccezione con il nome del parametro

## ZFIB-SPR-008 Registrazione e diagnostica
Con la registrazione delle prestazioni attiva, ogni esecuzione e ogni `Open` riporta nome della procedura, durata e testo `EXECUTE PROCEDURE nome(...)` (`SELECT * FROM nome(...)` per le procedure lette con `Open`) con i valori dei parametri (`DebugString`). Con il debugger collegato, utente amministratore e tasto Ctrl premuto, il testo della procedura viene anche copiato negli appunti; è uno strumento di sviluppo e non ha effetto in produzione.

### Scenario: registrazione spenta
- **Dato** la registrazione delle prestazioni spenta
- **Quando** si esegue una procedura
- **Allora** il costo è la lettura di un booleano, senza cronometro

## ZFIB-SPR-009 Helper di `TFDStoredProc` e `TFDParam`
`TFDStoredProc` ha in più: `ParamExists`, `ParamByName` (solleva se manca), `InputParamsCount`, `OutputParamsCount`, `DebugString(Selezionabile)` (falso = `EXECUTE PROCEDURE`, vero = `SELECT * FROM`). `TFDParam` ha i predicati `IsString`, `IsInteger`, `IsFloat`, `IsNumeric`, `IsDate`, `IsTime`, `IsDateTime`, `IsBoolean`, `IsBlob`, `IsMemo`, `IsInputParam` (ingresso e ingresso/uscita), `IsOutputParam` (uscita e ingresso/uscita). `DebugString` scrive i numeri col punto e le date tra apici con il punto come separatore, e mette la virgola fra i soli parametri in ingresso (il conto conta quelli già scritti, quindi i parametri di uscita non spostano le virgole).

### Scenario: parametro ingresso/uscita
- **Dato** un parametro `ptInputOutput`
- **Quando** si chiedono `IsInputParam` e `IsOutputParam`
- **Allora** entrambi sono veri

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-SPR-1 e 5 sono state corrette nel rilascio 008 e non compaiono più.

Nessuna divergenza aperta. Nel rilascio 010:

- **DIV-SPR-6 corretta:** `DebugString` descrive `SELECT * FROM nome(...)` quando la procedura è stata letta come cursore (`Open`), `EXECUTE PROCEDURE nome(...)` altrimenti.
- **DIV-SPR-2 scelta documentata:** `PropertyFromParam` solleva sempre se manca la proprietà. In scrittura (`ClearParam`, `SetParamValue`, `ParamIsNull`, `GetParamValue`) l'errore arriva al chiamante, perché indica una classe generata fuori allineamento; in ingresso (ZFIB-SPR-005) un parametro senza proprietà si salta con una riga nel registro, per non bloccare una procedura con parametri nuovi. I controlli `if PropertyName = ''` nei chiamanti non scattano mai e sono superflui.
- **DIV-SPR-3 e 4 documentate nel codice:** `AfterExecute` non è collegato (i valori di uscita si leggono in `InternalExecute` e in `Open`); `ParamFromProperty` non ha chiamanti (verificato con `find_references`) e il messaggio d'errore non comincia più con una `X`.

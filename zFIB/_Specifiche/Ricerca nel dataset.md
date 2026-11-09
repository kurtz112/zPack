---
area: Ricerca nel dataset
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Ricerca nel dataset

Questa specifica descrive come `TzFbDataSet` (unit `zFbDataSet.pas`) risolve `Locate`, `LocateSQL`, `LocateNonSQL`, `ReopenLocate` e `Lookup`. Descrive il comportamento atteso, non il codice. È l'area dove `TzFbDataSet` si comporta più diversamente da un `TDataSet` normale: **`Locate` può cambiare la SELECT e riaprire il dataset**.

**Perché esiste la ricerca con SQL.** I campi di scelta (combo, lookup, ricerca per codice) lavorano su dataset di anagrafiche che possono avere decine di migliaia di righe. Cercare con la `Locate` standard obbligherebbe a scaricarle tutte; con `UseSqlLocate` il dataset chiede al server solo il record cercato. Il prezzo è che il contenuto del dataset non è più l'elenco completo (ZFIB-LOC-004).

**Test e prove che coprono quest'area.** `Test.zFbDataSet.Divergenze` (SQLite in memoria) prova le correzioni del rilascio 008: ripristino dopo una ricerca fallita (ZFIB-LOC-004), maiuscole, data con ora, alias della tabella, numeri con decimali, jolly di `LIKE`, stringa vuota in una chiave composta. La condizione si legge dal testo della SELECT dopo `LocateSQL` (`GetLocateSQL` è privata). Le condizioni generate sono state provate anche **sul server**, su una tabella di prova in un banco Firebird 5 (collazione `UNICODE_CI_AI`, quella predefinita dei database di Gesty). **Non provato:** il caso di un campo `ftSingle` (su SQLite una colonna `FLOAT` non diventa `ftSingle`, quindi la prova di ZFIB-LOC-003 su quel tipo non gira), perché i test non usano Firebird.

## ZFIB-LOC-001 `Locate` sceglie fra SQL e ricerca in memoria
`Locate(Campi, Valori, Opzioni)` usa `LocateSQL` se `UseSqlLocate` è vero (predefinito), altrimenti la `Locate` di FireDAC sulle righe già in memoria (`LocateNonSQL`). `LocateNonSQL` chiama sempre la `Locate` di FireDAC, qualunque sia `UseSqlLocate`. Ogni `Locate` scrive nel registro il nome del dataset, i campi cercati, il valore (`VarArray` se più valori) e il risultato (verde se trovato, rosso se no); un dataset chiuso è segnalato come `CLOSED`.

### Scenario: ricerca con SQL
- **Dato** un dataset aperto con `UseSqlLocate = True`
- **Quando** si chiama `Locate('ID', 42)`
- **Allora** la ricerca passa da `LocateSQL`

### Scenario: ricerca in memoria
- **Dato** un dataset con `UseSqlLocate = False` oppure una chiamata a `LocateNonSQL`
- **Quando** si cerca un valore
- **Allora** il dataset non cambia SELECT e cerca fra le righe già lette

## ZFIB-LOC-002 `LocateSQL`: casi che non toccano il server
`LocateSQL` risponde `False` senza fare altro quando il dataset è chiuso e quando è già in corso un'altra `LocateSQL` sullo stesso dataset (la rientranza è ignorata). Se **tutti** i valori cercati sono nulli o stringhe vuote, il dataset ritorna alla SELECT di partenza e **si riapre** (`RevertSQL(True)`), e la risposta è `False`: la ricerca di «niente» ripristina l'elenco completo, per i campi di scelta i cui `MasterFields` sono cambiati dopo la creazione. Se il record corrente soddisfa già la ricerca (stessi valori, con le stesse regole di maiuscole e prefisso), la risposta è `True` e il dataset non cambia né posizione né SELECT.

### Scenario: dataset chiuso
- **Dato** un dataset chiuso
- **Quando** si chiama `Locate('ID', 1)`
- **Allora** la risposta è `False`

### Scenario: valore vuoto
- **Dato** un dataset filtrato da una ricerca precedente
- **Quando** si chiama `Locate('ID', Null)`
- **Allora** la SELECT torna a quella di partenza, il dataset è riaperto con tutte le righe e la risposta è `False`

### Scenario: record già corrente
- **Dato** un dataset posizionato sul record con `ID = 42`
- **Quando** si chiama `Locate('ID', 42)`
- **Allora** la risposta è `True` senza nessuna query

## ZFIB-LOC-003 Composizione della condizione
Per ogni campo cercato, il nome usato nella condizione è l'origine `TABELLA.COLONNA` del campo (ZFIB-DAT-017, ZFIB-LOC-007) o, se manca, il nome del campo. Un valore nullo fra i valori di una ricerca su più campi **salta quel campo** (la condizione usa solo gli altri). Le condizioni dei vari campi si uniscono con `AND`. Per tipo:

| Tipo del campo | Condizione |
|---|---|
| testo | di norma `= 'valore'`; con `loPartialKey` `STARTING WITH 'valore'`; se il valore finisce con `*`, `LIKE '%valore%' ESCAPE '\'` (contiene), anche senza `loPartialKey`: nel valore `\`, `%` e `_` sono protetti con `\`, quindi cercano il carattere vero; gli apici si raddoppiano |
| testo con `loCaseInsensitive` | il valore e il campo sono portati in maiuscolo: `UPPER(CAMPO) = UPPER('valore')`. Costa l'uso dell'indice sul campo |
| data | `= 'gg.mm.aaaa'` |
| ora | `= 'hh:nn:ss.zzz'` |
| data e ora | `= 'gg.mm.aaaa hh:nn:ss.zzz'`: il confronto è sull'istante esatto, non sul giorno |
| booleano | `= TRUE` o `= FALSE` |
| interi, `ftSingle`, decimali, valuta | `= numero`. Un numero vero (intero o decimale) si scrive così com'è, con il punto come separatore dei decimali; una stringa si legge con le impostazioni della postazione (tolto il separatore delle migliaia). Un intero cercato su un campo intero con decimali (`2.5`) non trova nessuna riga ma non è più `null`. Un valore non numerico diventa `null` |
| altri tipi (blob, memo, binari) | eccezione «tipo di campo non valido» |

Quattro precisazioni che la tabella non dice:
- Una **stringa vuota è trattata come un valore nullo**: in una ricerca su più campi salta il campo (la condizione usa solo gli altri). La ricerca non parte solo se *tutti* i valori sono nulli o vuoti (ZFIB-LOC-002). Chi vuole cercare i record con il campo vuoto non può farlo con `Locate`.
- Il carattere `*` finale prevale su `loPartialKey`: con tutte e due la condizione è `LIKE '%valore%'`, non `STARTING WITH`.
- L'eccezione del tipo non ammesso sorge mentre si compone la condizione, **prima** che il dataset tocchi la SELECT: il dataset resta aperto, con le righe di prima.
- Se il server rifiuta la condizione (nome di colonna non valido, per esempio, vedi ZFIB-LOC-007), l'errore arriva al chiamante come eccezione e il dataset rimette la SELECT precedente (ZFIB-DAT-007): la ricerca non risponde `False`.

### Scenario: più campi
- **Dato** un dataset con chiave su `ANNO` e `NUMERO`
- **Quando** si chiama `Locate('ANNO;NUMERO', VarArrayOf([2026, 15]))`
- **Allora** la condizione è `ANNO = 2026 AND NUMERO = 15`

### Scenario: prefisso
- **Dato** un campo testo
- **Quando** si cerca `'Ros'` con `[loPartialKey]`
- **Allora** la condizione è `CAMPO STARTING WITH 'Ros'`

### Scenario: contiene
- **Dato** un campo testo
- **Quando** si cerca `'oss*'`
- **Allora** la condizione è `CAMPO LIKE '%oss%'`

### Scenario: apice nel valore
- **Dato** un campo testo
- **Quando** si cerca `"D'Angelo"`
- **Allora** nella condizione l'apice è raddoppiato e la ricerca non fallisce con un errore di sintassi

### Scenario: tipo non ammesso
- **Dato** un campo memo
- **Quando** lo si usa come chiave di ricerca
- **Allora** viene sollevata un'eccezione con il nome del campo
- **E** il dataset resta aperto con le righe di prima

### Scenario: stringa vuota in una chiave composta
- **Dato** una ricerca su `CODICE;ANNO` con valori `''` e `2026`
- **Quando** si compone la condizione
- **Allora** è `ANNO = 2026`

### Scenario: contiene con un jolly nel valore
- **Dato** un campo testo
- **Quando** si cerca `50%*`
- **Allora** la condizione è `CAMPO LIKE '%50\%%' ESCAPE '\'` e trova solo i testi che contengono davvero `50%`

### Scenario: data e ora
- **Dato** un campo `TIMESTAMP`
- **Quando** si cerca il `TDateTime` 31.12.2026 12:30
- **Allora** la condizione è `CAMPO = '31.12.2026 12:30:00.000'`

## ZFIB-LOC-004 Dopo `LocateSQL` il dataset è filtrato
Per cercare, `LocateSQL` ricorda il record corrente (i campi di `UpdateOptions.KeyFields`), ripristina la SELECT di partenza (`RevertSQL(False)`), aggiunge la condizione (ZFIB-DAT-006) e riapre il dataset con i controlli sospesi. La risposta è `True` se il dataset contiene almeno una riga.

- **Ricerca riuscita:** il dataset resta aperto con la condizione aggiunta e contiene soltanto le righe che la soddisfano. L'elenco completo torna con `RevertSQL(True)` o con una `Locate` a valori vuoti (ZFIB-LOC-002).
- **Ricerca fallita, caso normale** (`MantieniElencoSeNonTrova` falso, il predefinito): il dataset ripristina la SELECT di partenza, si riapre con l'elenco completo e torna al record di prima (cercato per le chiavi di `UpdateOptions.KeyFields`, se ci sono). Come una `Locate` di un `TDataSet` normale, che non cambia l'elenco. Il ripristino richiede che `DefaultSQL` sia valorizzata (lo è sempre per i dataset caricati dal dizionario).
- **Ricerca fallita, campi di scelta** (`MantieniElencoSeNonTrova` vero): il dataset resta filtrato e vuoto. È la scelta del 2026-05-05: i campi di scelta assegnavano il primo record dell'elenco quando non trovavano corrispondenze. I dataset che alimentano i campi di scelta (copie create in `Tdx` per i combo con ricerca) hanno la proprietà vera.

### Scenario: record trovato
- **Dato** un dataset con 5000 righe
- **Quando** `Locate('ID', 42)` trova il record
- **Allora** il dataset contiene la riga 42 e solo quella (se la chiave è unica) e la risposta è `True`

### Scenario: record non trovato
- **Dato** un dataset con 5000 righe e `MantieniElencoSeNonTrova` falso, posizionato sul record 17
- **Quando** `Locate('ID', 999999)` non trova nulla
- **Allora** la risposta è `False`, il dataset contiene di nuovo le 5000 righe ed è posizionato sul record 17

### Scenario: record non trovato in un campo di scelta
- **Dato** un dataset con `MantieniElencoSeNonTrova` vero
- **Quando** `Locate('ID', 999999)` non trova nulla
- **Allora** la risposta è `False` e il dataset è aperto con zero righe

### Scenario: ritorno all'elenco completo
- **Dato** un dataset filtrato da una ricerca
- **Quando** il codice chiama `RevertSQL(True)`
- **Allora** il dataset contiene tutte le righe di `DefaultSQL`

## ZFIB-LOC-005 `ReopenLocate`
`ReopenLocate(Campo)` ricorda il valore del campo nel record corrente, riapre il dataset (`ReOpen`) tornando al record per segnalibro o, se non vale più, per numero di riga, e poi ricerca il valore **in memoria** (disattiva `UseSqlLocate` per quella chiamata e poi lo rimette). Serve per rileggere il dataset dal server restando sul record, senza filtrarlo.

### Scenario: riapertura che conserva il record
- **Dato** un dataset posizionato sul record con `ID = 42`
- **Quando** si chiama `ReopenLocate('ID')`
- **Allora** il dataset è riletto dal server e il record corrente è ancora quello con `ID = 42`
- **E** `UseSqlLocate` ha il valore di prima

## ZFIB-LOC-006 `Lookup`
`Lookup(Campi, Valori, CampiRisultato)` è la `Lookup` di FireDAC sulle righe già in memoria: **non** passa da `UseSqlLocate`, non cambia la SELECT. Dal rilascio 011 non scrive più nulla nel registro (prima ogni chiamata scriveva in rosso la riga `Lookup!!!!!`).

### Scenario: lookup su dataset filtrato
- **Dato** un dataset filtrato da una `LocateSQL`
- **Quando** si chiama `Lookup`
- **Allora** cerca soltanto fra le righe rimaste

## ZFIB-LOC-007 Il nome della colonna nella condizione
La condizione di `LocateSQL` scrive ogni colonna come `QUALIFICATORE.COLONNA`, dove la tabella è quella che il server (o l'analisi della SELECT, ZFIB-DAT-020) dichiara come origine del campo, senza virgolette, e il qualificatore è **l'alias che quella tabella ha nel `FROM`** della SELECT corrente, o il nome della tabella se non ha alias. Serve perché Firebird, quando una tabella ha un alias, non accetta più il nome originale (`FROM CORSI C ... WHERE CORSI.ID = 42` dà «Column unknown»; provato su Firebird 5 il 2026-10-31). Il motivo del nome qualificato: in una SELECT con più tabelle un nome di colonna senza tabella sarebbe ambiguo. Per i campi senza origine (calcolati dal dataset, di lookup) la condizione usa il solo nome del campo, che non è una colonna del server: la ricerca fallisce con un errore del server (vedi ZFIB-LOC-003, ultima precisazione).

### Scenario: tabella senza alias
- **Dato** un dataset con SELECT `SELECT CORSI.ID, CORSI.TITOLO FROM CORSI`
- **Quando** si chiama `Locate('TITOLO', 'Excel')`
- **Allora** la condizione è `CORSI.TITOLO = 'Excel'`

### Scenario: tabella con alias
- **Dato** un dataset con SELECT `SELECT C.ID, C.TITOLO FROM CORSI C`
- **Quando** si chiama `Locate('ID', 42)`
- **Allora** la condizione è `C.ID = 42` (l'alias della tabella nel `FROM`) e la ricerca funziona

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-LOC-1, 2, 3, 4, 8, 9, 10 e 11 sono state corrette nel rilascio 008 e non compaiono più: i requisiti ZFIB-LOC-003, 004 e 007 descrivono il comportamento nuovo.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LOC-5 🟢 | Un valore nullo in una chiave composta fa saltare quel campo; la ricerca prosegue con gli altri | Una ricerca su `ANNO;NUMERO` con `ANNO` nullo trova il primo `NUMERO` di qualunque anno invece di rispondere «non trovato». Lasciato così nel rilascio 011: non si è contato quanti chiamanti di WT e Gesty passano chiavi con valori nulli, e cambiarlo li farebbe rispondere «non trovato» |
| DIV-LOC-6 🟢 | `loPartialKey` è ignorato per i campi non testo; la sola regola del carattere `*` finale vale solo per il testo | Un chiamante che passa `loPartialKey` su un numero non ottiene la ricerca per prefisso, senza che nessuno glielo dica. Lasciato così nel rilascio 011: il prefisso su un numero non ha un significato in SQL |
| DIV-LOC-7 🟢 (in parte corretta nel rilascio 011) | `Lookup` usa la ricerca in memoria, ignorando `UseSqlLocate` (la riga rossa nel registro è stata tolta) | Su un dataset filtrato da una `LocateSQL` precedente, `Lookup` non vede le righe fuori filtro; resta così perché cambiarlo altera una funzione di FireDAC usata da tutti |

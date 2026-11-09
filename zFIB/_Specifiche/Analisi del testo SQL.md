---
area: Analisi del testo SQL
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Analisi del testo SQL

Questa specifica descrive come zFIB legge e riscrive il testo di una SELECT senza passare dal server: aggiunta di una condizione, cambio dell'ordinamento, query di conteggio, origine delle colonne, UPDATE delle sole colonne cambiate. Le unit sono `zSql.SqlTxtRtns.pas` (il lettore `TSQLParser` e le funzioni libere che lo usano), `zSql.SelectOrigins.pas`, `zSql.UpdateParziale.pas` e, di supporto, `zSql.StrUtil.pas`. Descrive il comportamento atteso, non il codice. Il lettore non è un vero analizzatore SQL: cerca le parole chiave nel testo, tenendo conto di commenti, letterali, virgolette doppie e parentesi.

**Cosa è in uso davvero.** `TzFbDataSet` usa solo `AddToWhereClause`, `OrderStringTxt`, `SetOrderClause`, `CountSelect`, `MainWhereClause` e `TSQLParser.SetWhereClause`, più `TSelectOriginResolver` e `ComponiUpdateParziale`; `CountSelect` lo usa anche `zDbView.Footer.pas`, e l'editor di `zz.base.editor.DataSet.pas` usa `TSQLParser` e `AddToWhereClause`. Le altre funzioni (`AllSQLTables`, `TableByAlias`, `FullFieldName`, `GetExportDataScript`, i molti ausiliari di `zSql.StrUtil`) vengono da una libreria più vecchia e **non sono specificate qui**: sono spiegate solo quando un consumatore le usa. `zSql.StrUtil` ha oltre 2000 righe di ausiliari di testo e non ha test.

**Test che coprono quest'area.** `Test.zSql.TestoSql`: sedici prove sui requisiti ZFIB-SQL-001..006 (tipo di istruzione, `WHERE` principale, aggiunta di condizione, ordinamento, conteggio con raggruppamento, `DISTINCT` e `WITH`, sostituzione della `WHERE`) e tre per le divergenze DIV-SQL-3, 4 e 5, senza database. `Test.zFbDataSet.UpdateParziale` copre ZFIB-SQL-009. Restano senza prova ZFIB-SQL-006..008 e DIV-SQL-6.

## ZFIB-SQL-001 Tipo di istruzione
`TSQLParser.SQLKind` guarda la prima parola, dopo spazi e commenti iniziali: `SELECT` e `MERGE` → select; `UPDATE` → update; `UPDATE OR INSERT` → update-or-insert; `DELETE`; `INSERT`; `EXECUTE PROCEDURE`; `EXECUTE BLOCK`; `ALTER`, `CREATE`, `COMMENT`, `DROP`, `DECLARE`, `GRANT`, `RECREATE`, `REVOKE` e alcuni `SET` → DDL; tutto il resto → sconosciuto. Una query che comincia con `WITH` è sconosciuta (vedi DIV-SQL-3): per `SQLKind` e per tutte le funzioni tranne `CountSelect`, che la riconosce da sé (ZFIB-SQL-005).

### Scenario: commento prima della SELECT
- **Dato** il testo `/* nota */ SELECT ID FROM T`
- **Quando** si legge `SQLKind`
- **Allora** il tipo è select

## ZFIB-SQL-002 Che cosa conta come «principale»
Le clausole `FROM`, `WHERE`, `GROUP BY`, `ORDER BY` e `PLAN` si cercano ignorando commenti (`--`, `/* */`), letterali fra apici e identificatori fra virgolette doppie. «Principale» significa a profondità di parentesi zero: una `WHERE` dentro una sottoquery o una tabella derivata non è mai la `WHERE` principale. Le parole chiave si riconoscono senza badare alle maiuscole e solo se circondate da spazi, a capo, parentesi o virgolette.

### Scenario: WHERE in una sottoquery
- **Dato** `SELECT (SELECT MAX(X) FROM U WHERE U.ID = T.ID) FROM T WHERE T.A = 1`
- **Quando** si chiede la `WHERE` principale con `MainWhereClause`
- **Allora** il risultato è `T.A = 1`

## ZFIB-SQL-003 Aggiunta di una condizione (`AddToWhereClause`)
`AddToWhereClause(SQL, Condizione)` restituisce la SELECT con la condizione in più. Se la `WHERE` principale esiste, la vecchia condizione e la nuova sono racchiuse ciascuna fra parentesi e unite da `and`. Se non esiste, si inserisce una `WHERE` alla fine della sezione `FROM`, prima di `GROUP BY`, `ORDER BY` o `PLAN`; in una SELECT senza `FROM` (per esempio `SELECT 1`) la `WHERE` va in coda al testo (corretto nel rilascio 011, prova `DIV_SQL_5_SelectSenzaFrom_WhereInCodaAlTesto`). Una condizione vuota o fatta di soli spazi lascia il testo com'era. Con `ForceCLRF` vero (come fa il dataset) la condizione sta su righe a parte.

`TzFbDataSet.AddWhereCondition` la usa sulla SELECT corrente; `ApplyFilter` la usa sulla SELECT di partenza (`DefaultSQL`), così il filtro non si accumula (`Dataset Firebird.md`, ZFIB-DAT-007 e ZFIB-DAT-008).

### Scenario: condizione su una SELECT con WHERE
- **Dato** `SELECT ID FROM T WHERE A = 1 ORDER BY ID`
- **Quando** si aggiunge la condizione `B = 2`
- **Allora** il risultato contiene `( A = 1` e `( B = 2 )` uniti da `and`, in una sola `WHERE`
- **E** `ORDER BY ID` resta in fondo

### Scenario: condizione su una SELECT senza WHERE
- **Dato** `SELECT ID FROM T ORDER BY ID`
- **Quando** si aggiunge la condizione `B = 2`
- **Allora** la `WHERE` compare fra `FROM T` e `ORDER BY`

### Scenario: condizione vuota
- **Dato** una SELECT qualunque
- **Quando** si aggiunge una condizione di soli spazi
- **Allora** il testo restituito è identico

## ZFIB-SQL-004 Ordinamento (`OrderStringTxt`, `SetOrderClause`)
`OrderStringTxt` restituisce il testo dopo `ORDER BY` della SELECT principale e la sua posizione; vuoto e posizione 0 se non c'è. `SetOrderClause(SQL, Nuovo)` sostituisce l'elenco esistente con `Nuovo`; se `Nuovo` è vuoto toglie l'`ORDER BY`; se la SELECT non ne ha, ne aggiunge uno in fondo (o lascia il testo com'era se `Nuovo` è vuoto). L'ordinamento è l'ultima clausola presa in considerazione: tutto ciò che segue `ORDER BY` fino alla fine del testo (per esempio un `ROWS` o un `FOR UPDATE`) è considerato parte dell'ordinamento.

`TzFbDataSet.SetOrderBy` la usa e cambia la SELECT passando da `TryChangeSQL` (ZFIB-DAT-007).

### Scenario: sostituzione
- **Dato** `SELECT ID FROM T ORDER BY ID`
- **Quando** si imposta l'ordinamento `NOME DESC`
- **Allora** il testo termina con `NOME DESC` e contiene un solo `ORDER BY`

### Scenario: rimozione
- **Dato** `SELECT ID FROM T ORDER BY ID`
- **Quando** si imposta l'ordinamento vuoto
- **Allora** il testo non contiene più `ORDER BY`

## ZFIB-SQL-005 Query di conteggio (`CountSelect`)
`CountSelect(SQL)` per una select semplice costruisce `Select Count(*)`, seguito dalla clausola `FROM` principale (tabelle e join) e dalla `WHERE` principale, scartando elenco campi e `ORDER BY`. Se la select ha `GROUP BY`, `HAVING`, `UNION`, `DISTINCT`, `FIRST` o `ROWS`, il conteggio sarebbe sbagliato: allora conta il risultato vero, `SELECT COUNT(*) FROM (<la select, senza ORDER BY salvo con FIRST o ROWS>) AS CONTEGGIO_RIGHE`. Una query che comincia con `WITH` mantiene le definizioni davanti e conta la select principale: `WITH ... SELECT COUNT(*) FROM (<select principale>) AS CONTEGGIO_RIGHE`. Limite: nel risultato di una select usata come tabella derivata Firebird non ammette due colonne con lo stesso nome, quindi una select con join e colonne omonime (senza alias diversi) dà un errore del server invece del conteggio. Restituisce testo vuoto se l'istruzione non è una select (né una `WITH`) o se non trova la `FROM`. `TzFbDataSet.GetRecordCountSQL` usa `CountSQL` se compilato, altrimenti questa (`Dataset Firebird.md`, ZFIB-DAT-013).

### Scenario: conteggio semplice
- **Dato** `SELECT ID, NOME FROM T WHERE A = 1 ORDER BY NOME`
- **Quando** si chiede `CountSelect`
- **Allora** il testo è `Select Count(*)` seguito da `FROM T` e da `WHERE A = 1`, senza `ORDER BY` e senza i campi

### Scenario: istruzione che non è una select
- **Dato** `UPDATE T SET A = 1`
- **Quando** si chiede `CountSelect`
- **Allora** il risultato è vuoto

## ZFIB-SQL-006 Sostituzione della WHERE (`Where` del dataset)
`TzFbDataSet.Where` (cioè `MainWhereClause` in scrittura) sostituisce la `WHERE` principale con il valore dato (non la prima del testo, che può stare in una sottoquery); con valore vuoto la toglie. Usa `SetMainWhereClause`. Se la SELECT non ha `WHERE`, un valore la aggiunge (come `AddToWhereClause`) e un valore vuoto lascia il testo com'è.

### Scenario: sostituzione
- **Dato** `SELECT ID FROM T WHERE A = 1`
- **Quando** si imposta `Where` a `A = 2`
- **Allora** la SELECT contiene `WHERE A = 2` e non più `A = 1`

## ZFIB-SQL-007 Interprete dei campi di una SELECT (`TSelectOriginResolver`)
`TSelectOriginResolver` divide la SELECT principale in elenco campi e clausola `FROM` leggendola per parole intere (non per posizione), a profondità zero: salta le `WITH` iniziali, `FIRST n`, `SKIP n`, `DISTINCT` e `ALL`. Gli identificatori non fra virgolette si portano in maiuscolo, come fa il server; quelli fra virgolette restano come sono. Per ogni voce dell'elenco riconosce una colonna (`COLONNA`, `TABELLA.COLONNA`, `ALIAS.COLONNA`), un asterisco (`*` o `TABELLA.*`) o un'espressione, con o senza alias (`AS NOME` oppure `NOME` dopo un operando completo). `COLONNA COLLATE X` resta la colonna. Nel `FROM` riconosce tabelle, nomi qualificati, procedure selezionabili con argomenti, tabelle derivate e alias con o senza `AS`.

### Scenario: alias di colonna
- **Dato** `SELECT CORSI.TITOLO AS NOME FROM CORSI`
- **Quando** si chiede l'origine della colonna `NOME`
- **Allora** il risultato è `CORSI.TITOLO`

## ZFIB-SQL-008 Origine di una colonna (`SelectColumnOrigin`, `OriginOf`)
`OriginOf(NomeNelRisultato, Occorrenza)` dà `TABELLA.COLONNA` oppure stringa vuota se dal solo testo non si può dire. Regole:
- colonna qualificata: l'alias si risolve sul `FROM` e si riporta la **tabella reale**;
- colonna non qualificata: si risolve solo se il `FROM` ha una sola sorgente reale, o se l'elenco delle colonne di una sola sorgente la contiene;
- espressione (calcolo, funzione, costante, `CASE`): nessuna origine;
- `TABELLA.*`: le colonne che nessuna voce nominata spiega si attribuiscono all'asterisco; con più asterischi serve l'elenco colonne;
- asterisco senza qualificatore su più sorgenti (Mantis #193): il server mette le colonne di tutte le sorgenti nell'ordine del `FROM`; le omonime si contano sorgente per sorgente; serve l'elenco colonne di ogni sorgente e si rinuncia davanti a tabelle derivate, procedure, o a una sorgente con alias (l'origine si scrive con il nome reale della tabella);
- `Occorrenza` (0 = la prima) distingue le colonne omonime nel risultato.

L'elenco delle colonne di una tabella lo fornisce la funzione `TTableColumnsProvider` passata al costruttore (`TzFbDataSet` usa `GetTableColumns`); un errore del fornitore vale come elenco non disponibile. È la base di `FieldOrigin` (`Dataset Firebird.md`, ZFIB-DAT-017).

### Scenario: due tabelle, alias
- **Dato** `SELECT A.ID, B.ID FROM CORSI A JOIN ISCRITTI B ON B.CORSO = A.ID`
- **Quando** si chiede l'origine della seconda colonna `ID` (occorrenza 1)
- **Allora** il risultato è `ISCRITTI.ID`

### Scenario: espressione
- **Dato** `SELECT UPPER(TITOLO) AS T FROM CORSI`
- **Quando** si chiede l'origine di `T`
- **Allora** il risultato è vuoto

### Scenario: colonna non qualificata con due sorgenti
- **Dato** `SELECT TITOLO FROM CORSI, ISCRITTI` e nessun fornitore di colonne
- **Quando** si chiede l'origine di `TITOLO`
- **Allora** il risultato è vuoto

## ZFIB-SQL-009 UPDATE delle sole colonne cambiate (`ComponiUpdateParziale`)
`ComponiUpdateParziale(Tabella, Colonne, Chiavi, Where, Returning)` scrive `UPDATE Tabella SET ... Where RETURNING ...`, con le `Colonne` nell'ordine ricevuto; la `Where` arriva già completa della parola `WHERE`. Con `Colonne` vuoto il `SET` riguarda le sole `Chiavi` (`CHIAVE=:CHIAVE`): l'UPDATE non cambia niente ma parte lo stesso, e trigger, conteggio righe e `RETURNING` si comportano come in un salvataggio senza modifiche. Con `Colonne` e `Chiavi` vuoti, o `Tabella` vuota, il risultato è vuoto: chi chiama deve tenere l'UPDATE completo, perché un `ModifySQL` vuoto farebbe rieseguire a FireDAC il comando precedente. `Returning` vuoto o `nil` toglie `RETURNING`. Le chiavi qualificate (`TABELLA.COLONNA`) entrano nel `SET` col solo nome della colonna (`ColonnaSenzaTabella`). L'uso nel salvataggio è in `Salvataggio e valori predefiniti.md` (ZFIB-SAL-009).

Test: `Test.zFbDataSet.UpdateParziale` prova la composizione (una colonna, nessuna colonna, chiavi qualificate, `RETURNING`, casi che danno testo vuoto).

### Scenario: una colonna
- **Dato** tabella `T`, colonna `NOME`, `Where` `WHERE T.ID=:OLD_ID`
- **Quando** si compone l'UPDATE
- **Allora** il testo contiene `UPDATE T SET NOME=:NOME` e la `Where` data

### Scenario: niente da comporre
- **Dato** tabella `T`, nessuna colonna e nessuna chiave
- **Quando** si compone l'UPDATE
- **Allora** il risultato è la stringa vuota

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-197 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-SQL-1 e 2 sono state corrette nel rilascio 008 e non compaiono più. Quelle marcate «provata» sono confermate da una prova eseguita il 2026-10-31 (`Test.zFbScriptRunner`, `Test.zSql.TestoSql`, nella voce R-197); quelle «dedotta» vengono dalla lettura del codice, senza prova.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-SQL-3 🟢 (provata, in parte corretta nel rilascio 008) | Una query che comincia con `WITH` non è riconosciuta come select (tipo sconosciuto). `CountSelect` la gestisce da sé; le altre funzioni (per esempio `AddToWhereClause` e `Where`) no | Aggiungere una condizione a una query con CTE non funziona: il lettore cerca la prima `FROM`, che sta dentro la definizione. Riconoscere `WITH` come select cambierebbe il comportamento di tutte le funzioni e non si è fatto |
| DIV-SQL-4 🟢 (provata) | `MERGE` è classificato come select | `CountSelect` e le altre funzioni per select trattano un `MERGE` come una select; non è un uso previsto, ma nessuno lo scarta. Decisione del rilascio 011: lasciato com'è e commentato nel codice, perché il motivo originale non è documentato e cambiare la classificazione tocca tutte le funzioni per select |

DIV-SQL-6 (unit grandi con molte funzioni senza consumatori) è stata documentata nel codice nel rilascio 010: l'intestazione di `zSql.SqlTxtRtns.pas` dice che le parti vive sono quelle di questa specifica e che prima di toccare il lettore (`IsFromEnd`, `ScanText`) si esegue `Test.zSql.TestoSql`. Nessun codice è stato tolto.

---
area: Esecuzione di script
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Esecuzione di script

Questa specifica descrive `TzFbScriptRunner` (unit `zFbScriptRunner.pas`), il componente che esegue script SQL nel formato prodotto da isql, IBExpert e FlameRobin: `SET TERM`, `COMMIT` e `ROLLBACK` in mezzo al testo, direttive che il server non conosce, commenti. Descrive il comportamento atteso, non il codice. In `zPack` nessuna unit lo usa; lo usano gli strumenti `zFbExpert` e `Gesty_Group\_Sorgenti\FbTools`.

**Perché esiste.** `TFDScript` di FireDAC spezza il testo al primo `;`, quindi rompe i corpi di stored procedure e trigger, che contengono `;` e `:variabile`. Il runner fa da solo il lavoro di spezzatura e poi esegue ogni comando già isolato con una `TFDQuery` interna a preprocessing spento (nessun parametro, nessuna macro, nessuna nuova spezzatura). Per questo la proprietà `Script` serve solo come ripiego per trovare la connessione.

**Test che coprono quest'area.** `Test.zFbScriptRunner`: diciassette prove (sette sulla spezzatura del testo, senza database; dieci sull'esecuzione, su SQLite in memoria) per i requisiti ZFIB-SCR-001..004 e 006..009, per DIV-SCR-4 (`Failed` conta i comandi) e per DIV-SCR-6 (spezzatura veloce su un comando lungo). Senza prova: la codifica di `ExecuteFile` (DIV-SCR-5). Le prove di DIV-SCR-1, 2, 3 e 8 sono state capovolte nel rilascio 008 e ora affermano il comportamento corretto. Restano senza prova ZFIB-SCR-005 (ordine di valutazione) e il gestore `OnCustomCommand`.

## ZFIB-SCR-001 Connessione e transazione usate
`Connection` è obbligatoria: se manca ma `Script` ha una connessione, si usa quella; se non c'è niente l'esecuzione si ferma con l'eccezione «Proprieta' Connection non assegnata». Se la connessione è chiusa, il runner la apre. La transazione è `Transaction` se assegnata, altrimenti quella predefinita della connessione; se non c'è nemmeno quella, il runner ne crea una sua, legata alla connessione, e la gestisce come le altre (vedi ZFIB-SCR-006).

### Scenario: connessione assente
- **Dato** un runner senza `Connection` e senza `Script`
- **Quando** si chiama `ExecuteText`
- **Allora** viene sollevata un'eccezione prima di eseguire qualunque comando

## ZFIB-SCR-002 Commenti
Prima di spezzare il testo si tolgono i commenti di riga (`--` fino a fine riga) e di blocco (`/* ... */`, anche annidati). I fine riga dei commenti restano, così i numeri di riga non si spostano; al posto di un commento di blocco resta uno spazio, così `SELECT/*c*/1` diventa `SELECT 1` e le parole accanto non si incollano. Dentro un letterale fra apici e dentro un identificatore fra virgolette doppie i segni di commento non valgono: fanno parte del testo.

### Scenario: commento di riga
- **Dato** lo script `SELECT 1 FROM RDB$DATABASE; -- fine`
- **Quando** si chiama `ParseOnly`
- **Allora** si ottiene un solo comando, senza il commento

### Scenario: segno di commento dentro un letterale
- **Dato** un comando `INSERT INTO T (A) VALUES ('a -- b')`
- **Quando** si chiama `ParseOnly`
- **Allora** il comando resta intero, con `'a -- b'` al suo posto

## ZFIB-SCR-003 Terminatore e `SET TERM`
Il terminatore parte da `DefaultTerminator` (`;` se vuoto). `SET TERM` lo cambia da lì in avanti, ed è riconosciuto solo a inizio comando e fuori da letterali, così la stringa `'SET TERM ^'` dentro un `INSERT` non cambia nulla. Sono accettate la forma con spazio (`SET TERM ^ ;`), quella compatta (`SET TERM ^;`) e il ritorno a `;` (`SET TERM ; ^` e `SET TERM ;^`). Il vecchio terminatore chiude la direttiva stessa. Dopo l'ultimo `SET TERM`, `CurrentTerminator` riporta il terminatore rimasto in vigore.

### Scenario: corpo di procedura
- **Dato** uno script con `SET TERM ^ ;`, un `CREATE PROCEDURE` con `;` al suo interno chiuso da `^`, e `SET TERM ; ^`
- **Quando** si chiama `ParseOnly`
- **Allora** il `CREATE PROCEDURE` è un solo comando con i suoi `;` interni
- **E** le due direttive `SET TERM` non compaiono nell'elenco

### Scenario: terminatore dentro un letterale
- **Dato** un comando `INSERT INTO T (A) VALUES ('x;y');`
- **Quando** si chiama `ParseOnly`
- **Allora** il comando è uno solo

## ZFIB-SCR-004 Direttive di isql ignorate
Sono saltate, e contate come ignorate, le direttive che il server non capisce: `SET SQL DIALECT`, `SET AUTODDL`, `SET NAMES`, `SET CLIENTLIB`, `SET STATS`, `SET STATISTICS` (ma non `SET STATISTICS INDEX`, che è un comando vero), `SET COUNT`, `SET ECHO`, `SET PLAN`, `SET LIST`, `SET BLOBDISPLAY`, `SET HEADING`, `SET BAIL`, `SET TIME` (ma non `SET TIME ZONE`, che è un comando vero di Firebird 4 e successivi), `CONNECT`, `CREATE DATABASE`, `DROP DATABASE`, `SHOW`, `INPUT`, `OUTPUT`, `QUIT`, `EXIT`, `HELP`. Il confronto guarda l'inizio del comando senza badare alle maiuscole. Con `SkipUnsupportedDirectives` falso non vengono saltate: vanno al server e falliscono lì.

### Scenario: direttiva saltata
- **Dato** un comando `SET SQL DIALECT 3`
- **Quando** lo script viene eseguito con `SkipUnsupportedDirectives` vero
- **Allora** non arriva al server
- **E** `Skipped` aumenta di uno e `OnMessage` riceve un messaggio di tipo `mkSkipped`

## ZFIB-SCR-005 Ordine di valutazione di ogni comando
Per ogni comando, nell'ordine: (1) `OnProgress`, poi (2) `OnCustomCommand`: se l'applicazione risponde `Handled`, il comando conta come ignorato e non si fa altro; (3) direttive ignorate (ZFIB-SCR-004); (4) `COMMIT` e `ROLLBACK` (ZFIB-SCR-006); (5) esecuzione vera (ZFIB-SCR-007). L'applicazione può quindi intercettare anche `COMMIT` e `SET`.

### Scenario: comando assorbito dall'applicazione
- **Dato** un gestore `OnCustomCommand` che risponde `Handled` a ogni comando che comincia con `INPUT`
- **Quando** lo script contiene `INPUT altro.sql;`
- **Allora** il comando non è eseguito né segnalato come direttiva ignorata

## ZFIB-SCR-006 Modalità di transazione e `COMMIT` / `ROLLBACK` nello script
`TransactionMode` decide chi comanda la transazione:

| Modalità | Comportamento |
|---|---|
| `tmScriptControlled` (predefinita) | Si avvia una transazione se non c'è. `COMMIT` e `ROLLBACK` dello script la chiudono e ne riavviano una subito. A fine script: commit se tutto è andato bene, rollback se si è interrotto |
| `tmAutoCommit` | Commit (e nuova transazione) dopo ogni comando eseguito. `COMMIT` e `ROLLBACK` nello script valgono come in `tmScriptControlled` |
| `tmExternal` | Il runner non tocca mai la transazione: non la avvia, non conferma a fine script. I `COMMIT` e i `ROLLBACK` incontrati non fanno niente e sono solo segnalati (`mkSkipped`) |

Se né `Transaction` né la connessione hanno una transazione, il runner ne usa una sua e la gestisce come descritto sopra: avvio, `COMMIT` finale e rollback in caso di interruzione funzionano. Un comando che comincia con `COMMIT` (anche `COMMIT RETAIN`) o con `ROLLBACK` (anche `ROLLBACK RETAIN`) vale come conferma o annullamento intero, ed è contato fra i comandi ignorati. **`ROLLBACK TO SAVEPOINT nome` (anche `ROLLBACK WORK TO`) non è un annullamento intero: è un comando del server e viene eseguito**, quindi torna al punto di salvataggio.

### Scenario: interruzione con transazione dello script
- **Dato** uno script in `tmScriptControlled` con due `INSERT`, un `COMMIT`, un terzo `INSERT` e un quarto comando sbagliato, con `StopOnError` vero
- **Quando** lo script viene eseguito
- **Allora** i primi due `INSERT` restano (confermati dal `COMMIT`)
- **E** il terzo viene annullato dal rollback finale, perché lo script si è interrotto

### Scenario: transazione esterna
- **Dato** un runner in `tmExternal` con una transazione già aperta dal chiamante
- **Quando** lo script contiene un `COMMIT`
- **Allora** la transazione del chiamante resta aperta e non confermata

## ZFIB-SCR-007 Errori su un singolo comando
Se un comando fallisce: `LastError` riceve il messaggio e, quando il fallimento è definitivo (non c'è un nuovo tentativo), `Failed` aumenta di uno: `Failed` conta i comandi falliti, non i tentativi; `OnMessage` riceve un messaggio `mkError` col messaggio e l'inizio del comando. Poi si decide: senza `OnError`, `StopOnError` vero ferma lo script, falso salta il comando e prosegue. Con `OnError` il gestore parte già con l'azione predefinita dettata da `StopOnError` (`eaAbort` o `eaSkip`) e può cambiarla in `eaAbort`, `eaSkip` o `eaRetry` (riesegue lo stesso comando). Una fermata imposta `Aborted`, e a fine script la transazione, se gestita dal runner, viene annullata.

### Scenario: proseguire dopo un errore
- **Dato** uno script con un comando sbagliato in mezzo e `StopOnError` falso
- **Quando** lo script viene eseguito
- **Allora** i comandi dopo l'errore vengono eseguiti
- **E** `Failed` vale 1 e `Succeeded` è falso

### Scenario: gestore che ritenta
- **Dato** un `OnError` che risponde `eaRetry` la prima volta e `eaSkip` la seconda
- **Quando** un comando fallisce due volte
- **Allora** il comando è stato tentato due volte e lo script prosegue col successivo
- **E** `Failed` vale 1, non 2

### Scenario: comando lungo
- **Dato** un testo con un comando di centinaia di migliaia di caratteri
- **Quando** si spezza il testo (`ParseOnly`)
- **Allora** il tempo cresce in modo lineare con la lunghezza, non col quadrato

## ZFIB-SCR-008 Esito e messaggi
`ExecuteText` e `ExecuteFile` restituiscono (e conservano in `LastResult`) `Total` (comandi trovati), `Executed` (eseguiti dal server), `Skipped` (ignorati o assorbiti, `COMMIT` e `ROLLBACK` compresi), `Failed`, `Aborted`, `ElapsedMs`, `LastError`. `Succeeded` è vero se `Failed = 0` e non c'è stata interruzione. `OnMessage` riceve solo le categorie scelte in `Messages`; di base `mkFeedback`, `mkSkipped` e `mkError` (non `mkEcho` né `mkTiming`). `OnBeforeExecute` parte prima di spezzare il testo, `OnAfterExecute` dopo il commit o il rollback finale.

### Scenario: esito di uno script riuscito
- **Dato** uno script di tre `INSERT` validi seguiti da un `COMMIT`
- **Quando** viene eseguito
- **Allora** `Total` è 4, `Executed` è 3, `Skipped` è 1, `Failed` è 0 e `Succeeded` è vero

## ZFIB-SCR-009 Interruzione, anteprima e file
`Abort` ferma lo script dopo il comando in corso; vale solo durante l'esecuzione (all'avvio il segnale si azzera). `ParseOnly(Testo, Elenco)` esegue solo commenti e spezzatura e riempie l'elenco con i comandi, senza toccare il database. `ExecuteFile(NomeFile, Codifica)` legge il file con la codifica indicata (`TEncoding`, ad esempio `TEncoding.GetEncoding(1252)`); senza codifica legge come UTF-8, e un BOM nel file ha comunque la precedenza. Poi esegue il testo.

### Scenario: anteprima
- **Dato** un runner senza `Connection`
- **Quando** si chiama `ParseOnly` con due comandi
- **Allora** l'elenco riceve due comandi e non viene sollevato nessun errore

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-197 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-SCR-1, 2, 3 e 8 sono state corrette nel rilascio 008 e non compaiono più. Quelle marcate «provata» sono confermate da una prova eseguita il 2026-10-31 (`Test.zFbScriptRunner`, `Test.zSql.TestoSql`, nella voce R-197); quelle «dedotta» vengono dalla lettura del codice, senza prova.

Nessuna divergenza aperta. DIV-SCR-4, 5, 6 e 7 sono state corrette (le prime tre) o documentate nel codice (la quarta: commenti allineati) nel rilascio 010.

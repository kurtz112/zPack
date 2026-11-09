---
area: Salvataggio e valori predefiniti
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Salvataggio e valori predefiniti

Questa specifica descrive che cosa fa `TzFbDataSet` (unit `zFbDataSet.pas`) quando l'utente o il codice inserisce un record, lo completa con i valori predefiniti, lo salva e lo annulla. Descrive il comportamento atteso, non il codice. L'apertura e il master/detail sono in `Dataset Firebird.md` (ZFIB-DAT); la composizione del testo dell'`INSERT` e dell'`UPDATE` automatici a partire dal dizionario LZ non è in zFIB (è di `TzSystem`).

**Test che coprono quest'area** (progetto `zPack\_UnitTest`, unit di prova DUnitX):
- `Test.zFbDataSet.Predefiniti`: `CampiPersistenti_Append_ValorePredefinito`, `CampiAutomatici_Append_ValorePredefinito`, `CampiPersistenti_DefaultExpressionAzzerata_Ripristinata`, `CampiAutomatici_DefaultExpressionAzzerata_Ripristinata`, `Riapertura_ValorePredefinitoConservato`, `ValorePredefinitoDelCodice_NonSovrascritto`, `SenzaValorePredefinito_PostFermato`;
- `Test.zFbDataSet.UpdateParziale`: quattordici prove, citate in ZFIB-SAL-009.

- `Test.zFbDataSet.Divergenze`: `AutoCommit` dopo `Delete` e dentro un'operazione atomica (ZFIB-SAL-008).

Restano senza test: l'ordine di applicazione dei valori al nuovo record, la copia dal master, la sanificazione, `ReopenAfterPost`, i default di tipo data e di `DefaultValues` su un campo `COMPUTED BY` (ZFIB-SAL-006 e 011, corretti ma senza prova).

## ZFIB-SAL-001 Come nasce un nuovo record
Quando si inserisce un record, il dataset valorizza i campi in questo ordine, a ridisegno sospeso (`DisableControls`): (1) le espressioni predefinite dei campi (ZFIB-SAL-006); (2) i valori di `DefaultValues` che rimandano a un campo di un altro dataset (`Campo=[Dataset.Campo]`); (3) i parametri del dataset, copiati nei campi omonimi (ZFIB-SAL-002); (4) i campi del master, copiati nei campi omonimi ancora nulli (ZFIB-SAL-003). Ogni passo opera solo se il dataset è ancora in inserimento o modifica: un annullamento arrivato nel mezzo (tasto Annulla durante l'inserimento) non fa scrivere nulla.

### Scenario: ordine dei valori
- **Dato** un dettaglio con una espressione predefinita sul campo `STATO` e un parametro `STATO` valorizzato dal master
- **Quando** si inserisce un record
- **Allora** `STATO` ha il valore del parametro, non quello dell'espressione, perché il passo 3 viene dopo il passo 1

### Scenario: annullamento durante l'inserimento
- **Dato** un nuovo record in inserimento
- **Quando** l'evento di annullamento arriva mentre i valori vengono assegnati
- **Allora** i passi successivi non scrivono nulla

## ZFIB-SAL-002 Parametri copiati nei campi (`ParamsToFields`)
Con `NewRecordOptions.ParamsToFields` vero (predefinito) ogni parametro del dataset il cui nome, tolti i due `##` iniziali, coincide con un campo viene copiato nel campo. Fanno eccezione i campi elencati in `ParamsToFieldsExcluded` (separati da punto e virgola; la virgola viene convertita) e il caso in cui il parametro è nullo e il campo ha già un valore (per non azzerare, per esempio, un tipo di progetto già assegnato). Serve al master/detail: il detail nasce già con la chiave del collegamento.

### Scenario: parametro di collegamento
- **Dato** un dettaglio con parametro `ID_PROGETTO = 7`
- **Quando** si inserisce un record
- **Allora** il campo `ID_PROGETTO` vale 7

### Scenario: campo escluso
- **Dato** `ParamsToFieldsExcluded = 'TIPO'` e un parametro `TIPO = 2`
- **Quando** si inserisce un record
- **Allora** il campo `TIPO` non riceve il valore del parametro

### Scenario: parametro nullo
- **Dato** un parametro nullo e un campo omonimo già valorizzato da un valore predefinito
- **Quando** si copiano i parametri
- **Allora** il campo conserva il suo valore

## ZFIB-SAL-003 Campi del master copiati nei campi (`MasterToFields`)
Con `MasterToFields` vero (predefinito) i campi del dettaglio che sono ancora nulli prendono il valore del campo omonimo del master (`DataSource.DataSet`), tranne quelli in `MasterToFieldsExcluded` e il campo chiamato `Note`, mai copiato (vedi DIV-SAL-1). Chi ha già un valore, per esempio da una espressione predefinita, lo mantiene: il valore del master non lo sovrascrive.

### Scenario: campo già valorizzato
- **Dato** un dettaglio con espressione predefinita `0` sul campo `ESCLUDI_CALCOLO` e un master che ha lo stesso campo a 1
- **Quando** si inserisce un record
- **Allora** `ESCLUDI_CALCOLO` resta 0

### Scenario: campo nullo
- **Dato** un campo nullo con omonimo nel master
- **Quando** si inserisce un record
- **Allora** il campo prende il valore del master

## ZFIB-SAL-004 Campi obbligatori
Prima di scrivere, `CheckBeforePost` controlla i campi obbligatori e, se ne manca qualcuno, solleva un'eccezione che elenca le etichette dei campi mancanti (`<Dataset>: i campi seguenti devono avere un valore`). Un campo obbligatorio vuoto non conta come mancante se è di sola lettura, se non è un campo dati, se è un campo di join, se è calcolato dal server (`COMPUTED BY`) o calcolato dal dataset. Il salvataggio non parte.

### Scenario: obbligatorio mancante
- **Dato** un campo obbligatorio senza valore e senza espressione predefinita
- **Quando** si salva
- **Allora** compare un messaggio con l'etichetta del campo
- **E** nessuna istruzione arriva al server
- (prova: `SenzaValorePredefinito_PostFermato`)

### Scenario: campo calcolato dal server
- **Dato** un campo obbligatorio `COMPUTED BY` e vuoto
- **Quando** si salva
- **Allora** il controllo lo ignora

## ZFIB-SAL-005 Campi di collegamento riletti dal master
Un inserimento nel dettaglio rilegge, subito prima del controllo dei campi obbligatori, i campi di collegamento ancora nulli (quelli che sono anche parametri di collegamento del master): prima dal parametro omonimo del master (catena di dettagli), poi dal suo campo; si tiene il primo valore non nullo. Il motivo: fra l'apertura del record e il salvataggio il master può aver cambiato chiave e lasciato il dettaglio con un valore vuoto (Mantis #150). Se il master non fornisce nessun valore, il campo resta nullo e il controllo ZFIB-SAL-004 decide.

### Scenario: collegamento perso
- **Dato** un nuovo record di dettaglio con `ID_PROGETTO` nullo e un master posizionato sul progetto 7
- **Quando** si salva
- **Allora** `ID_PROGETTO` vale 7 e l'inserimento riesce

## ZFIB-SAL-006 Espressioni predefinite (`DefaultExpression`)
Le espressioni predefinite vengono dal dizionario LZ, da `DefaultValues` del dataset e dalla `DEFAULT` della colonna. Sono normalizzate alla prima inizializzazione: tolto il prefisso `DEFAULT`, tolti gli apici esterni, le date sentinella `31.12.9999` e `01.01.1900` convertite in `31/12/9999` e `01/01/1900`; per stringhe e date si rimettono gli apici, per i numeri no. Le colonne calcolate dal server hanno la loro espressione predefinita svuotata (Mantis 0006163). Al momento dell'inserimento si applicano così:

| Tipo di campo | Espressione | Valore |
|---|---|---|
| qualunque | `NULL` | campo svuotato |
| data e ora | `NOW`, `CURRENT_TIME`, `CURRENT_TIMESTAMP` | data e ora attuali |
| data e ora | `TODAY`, `CURRENT_DATE` | data di oggi |
| data e ora | `TOMORROW`, `YESTERDAY` | domani, ieri |
| data e ora | un'altra data | la data scritta con `/` al posto di `.`, letta sempre come `gg/mm/aaaa` (con ora facoltativa `hh:nn:ss`) qualunque sia il formato data della postazione; un testo che non si legge così è assegnato come testo al campo |
| booleano | `TRUE`, `FALSE` | vero, falso |
| numerico | `1.5` | il numero col separatore decimale della postazione |
| testo | `'abc'` | `abc` senza apici |

Un campo di sola lettura riceve ugualmente il valore, che poi torna in sola lettura.

Dopo la prima apertura i campi automatici e i campi persistenti possono perdere l'espressione predefinita (FireDAC la riscrive quando ricostruisce il tracciato): il dataset ne conserva una copia e la rimette **solo dove la proprietà è vuota**, scrivendolo nel registro; un'espressione assegnata dal codice applicativo al posto di quella del dizionario non si sovrascrive. Test: `CampiPersistenti_Append_ValorePredefinito`, `CampiAutomatici_Append_ValorePredefinito`, `CampiPersistenti_DefaultExpressionAzzerata_Ripristinata`, `CampiAutomatici_DefaultExpressionAzzerata_Ripristinata`, `Riapertura_ValorePredefinitoConservato`, `ValorePredefinitoDelCodice_NonSovrascritto`.

### Scenario: espressione azzerata da FireDAC
- **Dato** un campo con espressione `5` che dopo la riapertura risulta vuota
- **Quando** si inserisce un record
- **Allora** il campo vale 5 e il registro dice «Default azzerato e ripristinato»

### Scenario: espressione scelta dal codice
- **Dato** un campo con espressione `7` assegnata dal codice, diversa da quella del dizionario
- **Quando** si inserisce un record
- **Allora** il campo vale 7

### Scenario: data di oggi
- **Dato** un campo data con espressione `CURRENT_DATE`
- **Quando** si inserisce un record
- **Allora** il campo contiene la data di oggi senza ora

### Scenario: separatore decimale
- **Dato** una postazione con la virgola come separatore e una espressione `1.5`
- **Quando** si inserisce un record
- **Allora** il campo vale 1,5 e l'inserimento non si interrompe

## ZFIB-SAL-007 Sanificazione dei campi di testo
Con `Sanification` vero (predefinito) i campi stringa e memo **modificati in questo salvataggio** passano da `TzSanificazione` al livello sicuro (caratteri di controllo, caratteri di formato invisibili, spazi Unicode, simboli di font, ricomposizione NFC). Si saltano: i campi vuoti, di sola lettura, calcolati o di lookup; in modifica quelli non cambiati (il dato storico non cambia di nascosto); i testi che sembrano RTF, HTML, XML o JSON. Non solleva errori: la validazione di formato resta ai trigger e agli editor. Va spenta (`Sanification = False`) sui dataset di appoggio delle importazioni, che devono conservare il dato grezzo. Quando cambia un testo, il registro riporta quali anomalie sono state tolte.

### Scenario: spazio non separabile
- **Dato** un campo di testo con uno spazio non separabile
- **Quando** si salva
- **Allora** il valore salvato ha uno spazio normale

### Scenario: dato storico non toccato
- **Dato** un record in modifica in cui il testo di un campo non è cambiato e contiene un carattere invisibile
- **Quando** si salva
- **Allora** quel campo non viene ripulito

### Scenario: JSON
- **Dato** un campo memo con un documento JSON
- **Quando** si salva
- **Allora** il testo resta identico

## ZFIB-SAL-008 Evento prima del salvataggio, salvataggio e conferma
`DoBeforePost` esegue nell'ordine: la sanificazione (ZFIB-SAL-007), poi `OnCustomBeforePost`. `InternalPost` esegue: il controllo dei campi obbligatori (ZFIB-SAL-004 e 005), la composizione dell'`UPDATE` (ZFIB-SAL-009), la scrittura nel registro (istruzione e valori di ogni campo, `<null>` per i nulli), il salvataggio vero. Con `ReopenAfterPost` vero rilegge subito il record (`RefreshRecord`), perché il `RETURNING` non basta sulle viste e i valori calcolati dal server altrimenti non arrivano. Con `AutoCommit` vero (predefinito), dopo ogni salvataggio **e dopo ogni cancellazione** il dataset conferma (`Commit`) la transazione di scrittura (`UpdateTransaction`) se è attiva. **Il commit riguarda l'intera transazione**, quindi anche il lavoro che altri dataset hanno fatto sulla stessa transazione. Per proteggere un'operazione in più passi, se la `UpdateTransaction` è una `TzFbTransaction` il codice chiama `BeginOperazioneAtomica` prima e `EndOperazioneAtomica` dopo (in un `try ... finally`, annidabili): finché un'operazione atomica è aperta, `AutoCommit` non conferma niente e la conferma la fa il codice alla fine. Con un'altra classe di transazione la protezione non c'è.

### Scenario: autocommit
- **Dato** un dataset con `AutoCommit = True` e una transazione di scrittura attiva
- **Quando** si salva un record
- **Allora** la transazione viene confermata subito dopo

### Scenario: cancellazione con autocommit
- **Dato** un dataset con `AutoCommit = True` e una transazione di scrittura attiva
- **Quando** si cancella un record
- **Allora** la transazione viene confermata subito dopo

### Scenario: operazione atomica
- **Dato** un dataset con `AutoCommit = True` e una `TzFbTransaction` su cui il codice ha chiamato `BeginOperazioneAtomica`
- **Quando** si salva o si cancella un record
- **Allora** la transazione resta attiva fino a una conferma del codice, dopo `EndOperazioneAtomica`

### Scenario: senza autocommit
- **Dato** un dataset con `AutoCommit = False`
- **Quando** si salva un record
- **Allora** la transazione resta attiva fino a una conferma del codice

### Scenario: dato calcolato da un trigger
- **Dato** un dataset su una vista con `ReopenAfterPost = True`
- **Quando** si salva
- **Allora** il record visibile contiene i valori scritti dal trigger

## ZFIB-SAL-009 Aggiornamento delle sole colonne cambiate (`UpdateChangedFields`)
L'`UPDATE` automatico (`AutoUpdate` vero, testo scritto da `TzSystem` con `Build_Sql_Update`) mette di norma nel `SET` tutte le colonne della tabella. Una scheda aperta prima che un'altra finestra salvasse riscriveva così anche le colonne che non aveva toccato, con i valori vecchi (la nota persa del Mantis #257). Con `UpdateChangedFields` vero il `SET` contiene solo le colonne **diverse dal record letto da questo dataset** (non da quello del database: una scheda vecchia con la nota vecchia, non toccata, non la riscrive). Regole:
- vale solo in modifica (`dsEdit`), con `AutoUpdate` vero e senza `CachedUpdates`; l'inserimento non cambia;
- le colonne assenti dalla SELECT, i campi calcolati e i campi di lookup non vanno mai nel `SET`; l'ordine è quello della tabella;
- memo, blob e campi binari si confrontano con i buffer di FireDAC (un blob non letto e non toccato non risulta cambiato); un memo riassegnato con lo stesso testo non è cambiato; gli altri campi si confrontano con `VarSameValue`;
- se nessuna colonna è cambiata il `SET` contiene la sola chiave: l'`UPDATE` parte lo stesso, perché i trigger, `USR_DATA_MDF`, il `RETURNING` e il conteggio delle righe si comportino come in un salvataggio senza modifiche;
- `WHERE` e `RETURNING` sono quelli di sempre; il testo ha la stessa forma di `Build_Sql_Update` (con tutte le colonne è identico riga per riga);
- se l'`UPDATE` che il dataset conosce è stato cambiato da altri dopo l'impostazione automatica, non lo tocca e lo scrive nel registro;
- con la proprietà spenta (predefinita) rimette l'`UPDATE` completo, se un salvataggio precedente l'aveva ridotto;
- non assegna mai un testo vuoto (FireDAC eseguirebbe il comando precedente) e riassegna il testo solo se cambia, perché l'assegnazione fa ripreparare il comando.

Test (`Test.zFbDataSet.UpdateParziale`): `Componi_UnaColonna`, `Componi_NessunaColonna_SetDellaChiave`, `Componi_NienteDaScrivere_Vuoto`, `Componi_TutteLeColonne_FormaDiBuildSqlUpdate`, `Post_PiuColonne_OrdineDellaTabella`, `Post_MemoRiassegnatoUguale_NonScritto`, `Post_ColonnaAssenteECampoCalcolato_NonNelSet`, `Post_DueSchede_NotaDellAltraSchedaResta`, `Post_DueSalvataggi_TestoNuovo`, `Post_SenzaModifiche_SetDellaChiave`, `Post_Inserimento_Invariato`, `Post_ProprietaSpenta_UpdateCompleto`, `Post_Predefinito_SpentaEUpdateCompleto`, `Post_UpdateSQLCambiatoDaAltri_NonToccato`.

### Scenario: una colonna cambiata
- **Dato** un record letto con tre colonne e un dataset con `UpdateChangedFields = True`
- **Quando** l'utente cambia una sola colonna e salva
- **Allora** il `SET` dell'`UPDATE` contiene quella colonna

### Scenario: nota di un'altra scheda
- **Dato** due schede aperte sullo stesso record
- **Quando** la prima salva una nota nuova e la seconda, che non ha toccato la nota, salva un altro campo
- **Allora** la nota della prima resta nel database

### Scenario: nessuna colonna cambiata
- **Dato** un record non modificato
- **Quando** si salva
- **Allora** l'`UPDATE` parte con il `SET` della sola chiave

### Scenario: UpdateSQL scritto a mano
- **Dato** un dataset con `AutoUpdate = False` e un `UpdateSQL` scritto a mano
- **Quando** si salva con `UpdateChangedFields = True`
- **Allora** il testo scritto a mano non viene toccato

## ZFIB-SAL-010 Il default previsto ma nullo non viene riempito
In inserimento, se un campo ha una espressione predefinita ma è ancora nullo al salvataggio, il dataset **non assegna il valore**: scrive nel registro «Default previsto ma campo NULL». Il motivo: riempire il campo coprirebbe il difetto (voce mancante nel dizionario, origine non determinata) e cambierebbe il senso di un campo svuotato apposta; senza la riga di registro il difetto emergerebbe solo come violazione `NOT NULL` del server, con un messaggio che nomina la tabella di origine (Mantis #106).

### Scenario: default non applicato
- **Dato** un campo con espressione predefinita che al salvataggio è nullo
- **Quando** si salva
- **Allora** il campo resta nullo
- **E** il registro riporta il nome del campo e l'espressione

## ZFIB-SAL-011 Da dove viene l'espressione predefinita e chi vince (`DefaultValues`)
Quando il dataset costruisce i campi per intero (la prima volta, o quando il dizionario non era ancora agganciato), l'espressione predefinita di ogni campo nasce in quattro passi, in quest'ordine:
1. `OnInitFields` porta quelle del dizionario LZ e della colonna; le soppressioni (`OVERRIDES`, `ofSuppressDefault`) le svuotano.
2. Il dataset le normalizza (ZFIB-SAL-006) e svuota quelle dei campi calcolati dal server.
3. Le voci di `DefaultValues` nella forma `Campo=Valore` (senza parentesi quadre) **sostituiscono** l'espressione del campo omonimo, scritte così come sono: non sono normalizzate né quotate, perché all'inserimento `ApplyDefaultExpression` toglie comunque gli apici e converte `.` e `/`. Vincono sul dizionario e sulla colonna. Una voce per un campo che non esiste è ignorata, senza avviso, e lo stesso vale per un campo calcolato dal server (`COMPUTED BY`): non riceve il default, per non riportare l'errore del Mantis 0006163. Il motivo: `DefaultValues` è il modo di dichiarare un default su un dataset solo, senza toccare il dizionario del campo.
4. Il dataset fotografa tutte le espressioni non vuote. Una costruzione completa rifà la fotografia da zero, quindi riflette quello che i passi 1-3 hanno prodotto *quella volta*. Una espressione soppressa (vuota) non entra nella copia e non torna mai (ZFIB-SAL-006).

Le costruzioni successive dei campi non ripercorrono i passi: rimettono soltanto le espressioni vuote che la copia conosce. Le voci `Campo=[Dataset.Campo]` non sono espressioni: valgono solo al passo 2 di ZFIB-SAL-001; se il dataset indicato non si trova, il campo non riceve niente e nessuno lo segnala.

### Scenario: DefaultValues contro dizionario
- **Dato** un campo `STATO` con espressione `1` dal dizionario e `DefaultValues` con `STATO=2`
- **Quando** il dataset costruisce i campi e si inserisce un record
- **Allora** `STATO` vale 2

### Scenario: campo che non esiste
- **Dato** una voce `DefaultValues` per un campo che il risultato non ha
- **Quando** il dataset costruisce i campi
- **Allora** la voce è ignorata e non compare nessun errore

### Scenario: default soppresso
- **Dato** un campo con il default soppresso da `OVERRIDES`
- **Quando** il dataset ricostruisce i campi e si inserisce un record
- **Allora** il campo resta nullo e il registro non riporta nessun ripristino

### Scenario: dataset esterno mancante
- **Dato** una voce `STATO=[Master.STATO]` il cui dataset non esiste
- **Quando** si inserisce un record
- **Allora** `STATO` non riceve valore da questa voce

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. DIV-SAL-2, 3, 4 e 5 sono state corrette nel rilascio 008 e non compaiono più.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-SAL-1 🟢 | `CopyMasterFields` esclude sempre il campo chiamato `Note`, con il nome scritto nel codice, oltre a quelli di `MasterToFieldsExcluded` | Un dettaglio con un campo `Note` che dovrebbe seguire il master non lo fa, e nessuna proprietà lo dice; chi ha un campo `Note` da copiare deve assegnarlo a mano. Dal rilascio 011 il codice lo dice in un commento; il comportamento resta quello, perché cambiarlo copierebbe le note del master in tutti i dettagli di WT e Gesty che hanno un campo `Note` |

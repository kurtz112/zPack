---
area: Creazione e allineamento del dizionario
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Creazione e allineamento del dizionario

Questa specifica descrive come il dizionario LZ nasce e si tiene allineato alla struttura del database: la sequenza `Init_zSystem` che, a partire dai metadati (`Metadati del database.md`), crea o aggiorna generatori, liste di valori, ricerche (le chiavi esterne) e voci del dizionario dei dati; il tipo di controllo scelto per un campo; e la voce che il programma crea da solo in esecuzione quando un campo non è nel `.LZ`. Il codice è in `zBase\zSystem_Init.pas` (`Init_zSystem`, record `TzSystemInitializer`) e in `zBase\zSystem.pas` (`TzSystem.InitializeFromDB`, `UpdateFromDB`, `InitFields`, `MetaDataDefault`, le funzioni `GetCtrlType` e `CapFirst`). Lo usano: WT e Gesty, indirettamente, perché i loro moduli dati chiamano `TzSystem.DataSetLoadProps` per ogni dataset (`Base_DbDataModule.pas` in WT, `Base_DataModule.pas` in Gesty) e questa chiama `InitFields`; e perché le procedure di aggiornamento del dizionario (`InitializeFromDB`, dall'azione `AggiornaCache` della form di sistema, e `UpdateFromDB` di `zMCP_LZ` chiamato da `zBuilder`) eseguono `Init_zSystem`. Nessun file di WT o di Gesty chiama direttamente `Init_zSystem` o `GetCtrlType`. Il generatore scelto qui (ZBASE-INI-002) è quello che `DataSetLoadProps` poi assegna ai dataset di quella tabella, con la sua colonna come chiave primaria e come campo a numerazione automatica. Descrive il comportamento atteso, non il codice. La parte di `zSystem_Init.pas` che chiama `SISTEMAZIONI` non è attiva (DIV-INI-2).

**Come funziona.** Dopo avere riletto i metadati dal database, `Init_zSystem` esegue nell'ordine sei passi: generatori, liste di valori, ricerche, voci del dizionario dei dati, nome tabella dei dataset, sistemazioni finali. Ogni passo segna prima tutto ciò che esiste nel dizionario come «non più esistente» (`Exists` falso) e poi lo rimette a vero per ciò che i metadati contengono ancora: così in un secondo momento si vede che cosa è sparito dal database. Per gli elementi **nuovi** il passo ricava tutto dai metadati; per quelli **già presenti** conserva ciò che il dizionario ha già personalizzato (didascalie, tipo di controllo, ricerche assegnate a mano) e riallinea solo ciò che deriva dalla struttura del database.

**Test che coprono quest'area.** `Test.zSystem.Dizionario` prova la creazione e l'aggiornamento delle voci del dizionario dei dati, i generatori e le liste di valori. `Test.zSystem.Funzioni` prova `GetCtrlType` e `CapFirst`. Restano senza prova le ricerche (`InitLookups`) con la creazione dei dataset, delle schede e delle viste collegati, `AssignTableNameToDataset` e `InitFields`, che richiedono un database o un dataset aperto.

## ZBASE-INI-001 Sequenza di `Init_zSystem` e punti d'ingresso
`Init_zSystem(Sistema, Metadati, Richiamata)` esegue: `InitGenerators`, `InitPickLists`, `InitLookups`, `InitDataDictionary`, `AssignTableNameToDataset`, `SISTEMAZIONI`, e prima di ciascuno chiama la richiamata con un testo di avanzamento («Inizializzazione Generators», «Inizializzazione PickLists», «Inizializzazione Lookups», «Inizializzazione DataDictionary», «Aggiornamento TableName», «Sistemazioni finali»). Due punti d'ingresso lo usano:
- `InitializeFromDB` (con finestra di avanzamento): rilegge i metadati, esegue `Init_zSystem`, segna il dizionario caricato e salva tutto con `SaveZip(csAll, 'InitFromDB')`;
- `UpdateFromDB(Database, Transazione, Richiamata)` (senza finestre e senza salvare): gli stessi due passi di rilettura e `Init_zSystem`, poi segna il dizionario caricato; solleva «UpdateFromDB: database non assegnato» o «UpdateFromDB: transazione non assegnata» se manca uno dei due. Il salvataggio lo chiede poi chi chiama (`Ciclo di vita e archivio LZ.md`, ZBASE-AVV-008).

La richiamata è facoltativa: con `nil` i passi girano in silenzio.

### Scenario: richiamata assente
- **Dato** metadati vuoti e nessuna richiamata
- **Quando** si chiama `Init_zSystem`
- **Allora** termina senza eccezioni e il dizionario resta vuoto

## ZBASE-INI-002 Generatori
`InitGenerators` segna `Exists` falso a tutti i generatori del dizionario e poi, per ogni generatore dei metadati:
- se il dizionario non ne ha uno con lo stesso nome (senza distinguere le maiuscole): ne aggiunge uno con `Name` e `GeneratorName` uguali al nome del generatore, `Exists` vero; ricava il nome della tabella dal nome del generatore togliendo il prefisso `GEN_` e il suffisso `_ID` (`GEN_PERSONE_ID` dà `PERSONE`); se una tabella dei metadati **comincia** con quel nome (primo risultato in ordine di lettura, senza distinguere le maiuscole) ne assegna il nome completo a `TableName` e, se quella tabella ha una chiave primaria di una sola colonna, il suo nome a `FieldName`;
- se esiste già: `Exists` vero; se `AutoFieldName` è vero (predefinito) e la tabella indicata esiste con quel nome esatto e ha una chiave primaria di una sola colonna, `FieldName` si riallinea a quella colonna. Il resto del generatore non cambia.

I generatori con `Exists` vero, tabella, colonna e nome compilati sono quelli che `TzSystem.UpdateGenerators` riallinea al valore massimo della colonna.

### Scenario: generatore nuovo senza tabella
- **Dato** nei metadati il generatore `GEN_PERSONE_ID` e nessuna tabella `PERSONE`
- **Quando** si chiama `Init_zSystem`
- **Allora** il dizionario ha un generatore `GEN_PERSONE_ID` con `GeneratorName = GEN_PERSONE_ID`, `Exists` vero e `TableName` vuoto

### Scenario: generatore sparito
- **Dato** nel dizionario un generatore `GEN_VECCHIO_ID` che i metadati non contengono più
- **Quando** si chiama `Init_zSystem`
- **Allora** il generatore resta nel dizionario con `Exists` falso

## ZBASE-INI-003 Liste di valori
`InitPickLists` prende ogni lista dei metadati (nata dal commento di un dominio SQL) e ne cerca una con lo stesso nome nel dizionario, aggiungendola se manca. Una lista nuova viene generata per intero: la descrizione dei metadati diventa descrizione della lista e da lei nascono le voci, una per ogni riga non vuota nella forma `codice=descrizione`. Su una lista esistente, se la descrizione dei metadati è cambiata, le voci si rigenerano solo se non sono state personalizzate a mano (ritrovano `ImageIndex` e `Indent` delle voci con lo stesso valore); se sono state personalizzate, la descrizione si aggiorna comunque ma le voci restano e nel registro compare l'avviso «il commento del dominio ... è cambiato, ma le voci sono personalizzate e non sono state riallineate». L'avviso compare una volta sola, perché dalla volta dopo la descrizione coincide.

### Scenario: lista nuova
- **Dato** nei metadati una lista `STATO_PRATICA` con descrizione di tre righe nella forma `codice=descrizione`
- **Quando** si chiama `Init_zSystem`
- **Allora** il dizionario ha una lista `STATO_PRATICA` con la stessa descrizione e tre voci

## ZBASE-INI-004 Ricerche (chiavi esterne) e oggetti collegati
`InitLookups`:
1. segna `Exists` falso alle ricerche che nascono da una chiave esterna (`IsForeignKey`) e vero a quelle create a mano (personalizzate);
2. per ogni ricerca dei metadati ne cerca una con lo stesso nome nel dizionario (la aggiunge se manca), la segna `Exists` e `IsForeignKey` e completa questi campi: `FieldNames`, `TableName`, `FieldNamesFK`, `TableNameFK`, `DisplayColumns`, `Mappings`, **solo se nel dizionario sono vuoti** (cosa si è scelto a mano resta). `KeyField`, se vuoto, diventa la prima colonna di `FieldNames` (prima del primo `;`); `DisplayColumns`, se ancora vuoto, diventa `FieldNamesFK`;
3. dà alla ricerca i nomi del dataset, della vista e della scheda `_lk_<nome della ricerca>` se mancano, e se il dataset `_lk_...` non esiste lo crea con la vista e la scheda collegate. Il dataset nuovo (se l'elemento dei metadati è nuovo) prende la tabella `TableNameFK`, il generatore della tabella, le istruzioni `INSERT`, `UPDATE`, `DELETE` costruite dai metadati e, se la ricerca ne ha una, la `SELECT` dei metadati; la scheda e la vista nuove prendono come titolo il nome della tabella con la prima lettera maiuscola;
4. elimina, con il suo dataset e la sua vista, ogni ricerca da chiave esterna che non esiste più nei metadati;
5. per tutte le ricerche (anche personalizzate) completa i nomi mancanti del dataset, della vista e della scheda con il nome della ricerca e crea gli oggetti che non ci sono;
6. a ricerche già sistemate, scrive la `SELECT` dei metadati nei dataset che non ne hanno una.

### Scenario: chiave esterna sparita
- **Dato** una ricerca `FK_ORDINI_CLIENTI` nata da una chiave esterna che nei metadati non c'è più
- **Quando** si chiama `Init_zSystem`
- **Allora** la ricerca, il suo dataset e la sua vista non sono più nel dizionario

### Scenario: ricerca personalizzata
- **Dato** una ricerca creata a mano, senza chiave esterna nei metadati
- **Quando** si chiama `Init_zSystem`
- **Allora** la ricerca resta con `Exists` vero e senza altre modifiche, salvo i nomi mancanti del dataset, della vista e della scheda

## ZBASE-INI-005 Voci del dizionario dei dati
`InitDataDictionary` lavora con l'indice per nome attivo (`IndexEnabled`, che distingue le maiuscole, `Collezione LZ.md` ZBASE-COL-003) e lo spegne sempre alla fine. Segna `Exists` falso a tutte le voci e, per ogni voce dei metadati (nome `TABELLA.CAMPO`), cerca o aggiunge la voce del dizionario, la segna `Exists` e le riallinea sempre: `TableName`, `FieldName`, `DataType`, `Size`, `ColSpan`, `Precision` (le cifre decimali), `Calculated`, `Identity`, i flag di campo «solo lettura» e «obbligatorio» dai metadati (`ReadOnlyField` e `RequiredField`), e la riservatezza (`HasSensitivity`, `Sensitivity`). Il valore effettivo di «solo lettura» e «obbligatorio» è quello del flag di campo, a meno che il dizionario non abbia una scelta manuale (`ReadOnlyOverride`, `RequiredOverride` di `TzDomain`).

Per una voce **nuova** copia dai metadati anche `Domain` (il dominio SQL), `Alignment`, `DisplayLabel` (dal titolo), `DefaultExpression` (dal valore predefinito), `Lookup`, `PickList` e il tipo di controllo (`zCtrlType`), poi imposta il formato di visualizzazione dei numeri (`###,##0` per gli interi, `###,##0.00` per gli altri numeri; DIV-INI-1) e applica le regole del dominio (ZBASE-INI-006).

Per una voce **già presente**:
- se il dominio SQL è cambiato rispetto alla voce (`Domain` diverso dal dominio dei metadati) applica di nuovo le regole del dominio (ZBASE-INI-006); il campo `Domain` della voce non viene però riscritto;
- `DefaultExpression` si riempie dai metadati solo se la voce l'ha vuota;
- una ricerca (`Lookup`) o una lista di valori (`PickList`) dei metadati si assegna solo se la voce non ne ha una; se la voce ha una lista di valori e il suo tipo di controllo non è una lista, il tipo diventa quello predefinito per le liste e `CharCase` diventa `ecNormal`; se ottiene una ricerca e il suo tipo non è una ricerca, diventa il tipo predefinito per le ricerche;
- «solo lettura» e «obbligatorio» dei metadati non si ricopiano sulle scelte del dizionario (il codice che lo faceva è commentato).

Alla fine, ogni voce con un tipo di controllo di tipo ricerca ma senza ricerca assegnata diventa un campo di testo (`ctEdit`).

### Scenario: voce nuova di tipo intero
- **Dato** nei metadati una voce `PERSONE.ETA` di tipo intero, nome campo `ETA`, tabella `PERSONE`
- **Quando** si chiama `Init_zSystem`
- **Allora** il dizionario ha la voce `PERSONE.ETA` con `TableName = PERSONE`, `FieldName = ETA`, `Exists` vero e `DisplayFormat = ###,##0`

### Scenario: voce nuova di tipo decimale
- **Dato** una voce dei metadati di tipo `ftFloat`
- **Quando** si chiama `Init_zSystem`
- **Allora** il `DisplayFormat` della voce è `###,##0.00`

### Scenario: valore predefinito già deciso
- **Dato** una voce già presente con `DefaultExpression = 'X'` e metadati con valore predefinito `'Y'`
- **Quando** si chiama `Init_zSystem`
- **Allora** la voce conserva `X`

### Scenario: valore predefinito mancante
- **Dato** una voce già presente senza `DefaultExpression` e metadati con valore predefinito `'Y'`
- **Quando** si chiama `Init_zSystem`
- **Allora** la voce ha `DefaultExpression = 'Y'`

### Scenario: campo sparito dal database
- **Dato** una voce `PERSONE.VECCHIO` nel dizionario che i metadati non contengono più
- **Quando** si chiama `Init_zSystem`
- **Allora** la voce resta nel dizionario con `Exists` falso

## ZBASE-INI-006 Regole per dominio SQL
Quando si crea una voce o ne cambia il dominio, secondo il nome del dominio SQL (senza distinguere le maiuscole, tranne il prefisso `VALUTA_`, che si riconosce distinguendole):
- comincia con `VALUTA_`: formato `###,##0.00` preceduto dal simbolo della valuta (nel sorgente, salvato in codifica Windows-1252, compare come carattere non leggibile: probabilmente l'euro) e `Currency` vero;
- `SI_NO` o `TRUE_FALSE`: controllo a casella (`ctCheckBox`);
- `ANNO`: formato di visualizzazione vuoto, altrimenti un anno si scriverebbe `1.971`;
- `NOTE` o `MEMO`: controllo di testo lungo (`ctMemo`) se non lo è già (`IsMemo`) e tipo di blob `ftMemo`;
- `IMMAGINE`: controllo `ctImage` e blob `ftGraphic`.

### Scenario: dominio ANNO
- **Dato** una voce nuova di tipo intero con dominio `ANNO`
- **Quando** si chiama `Init_zSystem`
- **Allora** il suo `DisplayFormat` è vuoto

### Scenario: dominio SI_NO
- **Dato** una voce nuova con dominio `SI_NO`
- **Quando** si chiama `Init_zSystem`
- **Allora** il suo tipo di controllo è `ctCheckBox`

### Scenario: dominio NOTE
- **Dato** una voce nuova con dominio `NOTE`
- **Quando** si chiama `Init_zSystem`
- **Allora** il tipo di controllo è `ctMemo` e il blob è `ftMemo`

## ZBASE-INI-007 Tipo di controllo di un campo e didascalia predefinita
`GetCtrlType(TipoCampo, Dominio)` sceglie il tipo di controllo per un campo, prima dal tipo di dato e poi, se il dominio SQL è uno dei noti, dal dominio (il dominio prevale):

| Tipo di dato | Controllo |
|---|---|
| `ftString`, `ftFixedChar`, `ftWideString` | `ctEdit` |
| `ftSmallint`, `ftInteger`, `ftWord`, `ftAutoInc`, `ftLargeint`, `ftFloat`, `ftCurrency`, `ftBCD` | `ctEdit` |
| `ftBoolean` | `ctCheckBox` |
| `ftDate` | `ctDate` |
| `ftTime` | `ctTime` |
| `ftDateTime`, `ftTimeStamp` | `ctDateTime` |
| `ftMemo`, `ftFmtMemo` | `ctMemo` |
| `ftGraphic` | `ctImage` |
| ogni altro (`ftUnknown`, `ftFMTBcd`, `ftBlob`, `ftWideMemo`, ...) | `ctDefault` |

| Dominio | Controllo |
|---|---|
| `SI_NO`, `BOOLEAN` | `ctCheckBox` |
| `DATA` | `ctDate` |
| `DATA_ORA` | `ctDateTime` |
| `ORA` | `ctTime` |
| `NOTE`, `MEMO` | `ctMemo` |
| `IMMAGINE` | `ctImage` |

`CapFirst(Testo)` è l'ultima didascalia di ripiego di una colonna della griglia che non ha né didascalia propria né dominio: rende maiuscola la prima lettera e di ciascun carattere successivo la rende maiuscola se il precedente è uno spazio o un carattere di controllo (codice sotto 33) e minuscola altrimenti; il trattino basso non separa le parole. Un testo vuoto o fatto di soli spazi dà una stringa vuota.

### Scenario: dominio che prevale
- **Dato** un campo `ftString` con dominio `DATA`
- **Quando** si chiama `GetCtrlType(ftString, 'DATA')`
- **Allora** il risultato è `ctDate`

### Scenario: didascalia di ripiego
- **Dato** il nome di colonna `DATA_NASCITA`
- **Quando** si chiama `CapFirst('DATA_NASCITA')`
- **Allora** il risultato è `Data_nascita`
- **E** `CapFirst('rossi mario')` dà `Rossi Mario`

## ZBASE-INI-008 Voce creata in esecuzione da `InitFields` e valori predefiniti
Ogni volta che un dataset del dizionario si apre, `TzSystem.InitFields` porta sui suoi campi gli attributi del dizionario. Non fa niente se il dataset non ha `SelectSQL`; non fa niente, con una riga nel registro a livello dettagliato, se non ha identificativo (`idDataSet` vuoto e senza proprietario) o se il dizionario non contiene il dataset: in questi due casi nessun valore predefinito viene applicato e il difetto si vede solo come violazione `NOT NULL` al salvataggio (Mantis #106).

Per ogni campo cerca la voce `TABELLA.CAMPO` (con l'origine del campo, o `TableName.NomeCampo` per i campi calcolati). Se non c'è la **crea in memoria** (`Modified` vero) copiando dal campo: allineamento, tipo, `DefaultExpression` (se vuota la ricava dai metadati con `MetaDataDefault`, perché per una colonna di vista il valore predefinito sta sulla tabella di origine), didascalia (se coincide con il nome del campo la ricava con `FormatDisplayLabel`), tabella e campo spezzando l'origine al primo punto, dominio SQL dai metadati (con ripiego `<procedure>`, `<view>`, `<table>` se il dominio non c'è ma la relazione sì), maschera, precisione, formato dei numeri, «solo lettura» (falso per il campo `SELECTED`, vero per i calcolati), «obbligatorio», dimensione, tipo di controllo (`GetCtrlType`), ricerca dei metadati (tipo di controllo ricerca predefinito, o `ctComboDlg` se la ricerca ha più campi) o, altrimenti, lista di valori se il dominio ne ha una (`ctPickListImage`). Ne scrive una riga nel registro. Poi, per ogni campo, esistente o nuovo: applica identità, allineamento, didascalia, maschera, `DefaultExpression`, «solo lettura», «obbligatorio», formato numerico, precisione, tipo di blob e l'evento `OnChange` dichiarato nel dizionario.

`DefaultExpression` di un campo è quella della voce; se la voce non ne ha, quella dei metadati, valida solo per la sessione senza modificare il dizionario, che non finisce quindi nel `.LZ`. In fondo `InitFields` svuota il valore predefinito dei campi che hanno una personalizzazione di soppressione (`Personalizzazioni dei campi.md`, ZBASE-OVR-005). Un campo «obbligatorio» che è un campo di join o calcolato dal server torna facoltativo; un campo «solo lettura» con tipo di controllo ricerca che è un campo di join o calcolato dal server torna scrivibile (ricerche su campi di join).

### Scenario: campo mancante nel dizionario
- **Dato** un dataset del dizionario con un campo `PERSONE.NUOVO` senza voce
- **Quando** il dataset si apre
- **Allora** nasce la voce `PERSONE.NUOVO` in memoria, `TzSystem.Modified` è vero e il registro riporta «voce di dizionario mancante»

### Scenario: dataset senza identificativo
- **Dato** un dataset senza `idDataSet` e senza proprietario
- **Quando** si chiama `InitFields`
- **Allora** nessun campo riceve attributi e il registro riporta «dataset senza id»

## ZBASE-INI-009 Nome tabella dei dataset
`AssignTableNameToDataset` controlla ogni dataset del dizionario: se il suo `TableName` non è una tabella, una vista o una procedura dei metadati, prova a ricavare il nome dalla `SELECT` (`Get_TableNameFromSQL`, `zSqlLib`); se lo trova lo assegna e, se c'è un generatore per quella tabella, assegna anche il generatore. Un nome non riconosciuto resta com'è.

### Scenario: nome tabella sbagliato
- **Dato** un dataset con `TableName` che nei metadati non esiste e una `SELECT` su una tabella valida
- **Quando** si chiama `Init_zSystem`
- **Allora** il `TableName` del dataset diventa quello della `SELECT`

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-212 di `Attivita Rinviate.md` indicata dalla sessione principale. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-INI-1 🟡 (dedotta) | `InitDataDictionary` riserva il formato `###,###` ai campi il cui nome comincia con `ID_` (`Domain.Name.StartsWith('ID_')`), ma `Domain.Name` è il nome intero `TABELLA.CAMPO`, che non comincia mai con `ID_` (a meno di una tabella con quel nome): il ramo non scatta. Nel dizionario di WT `ACC_DENUNCE_ICP.ID_ACCERTAMENTO` ha infatti `###,##0` | Gli identificativi nuovi si visualizzano con il separatore delle migliaia (`1.234`) invece che come numeri semplici: l'eccezione voluta per le chiavi non si applica mai |
| DIV-INI-2 🟢 (dedotta) | `SISTEMAZIONI` comincia con `exit`: le correzioni che segue (ricerche, tipi di controllo dai metadati, riallineamento di «obbligatorio» e «solo lettura» come scelta manuale, `SISTEMA_OVERRIDE`) non girano mai. Il file ha in coda frammenti di testo dopo l'ultimo `end.`, e una vecchia `InitLookups` commentata | Codice morto che dà l'idea di un passo finale di bonifica: nessuna bonifica avviene; i frammenti dopo `end.` non vengono compilati |
| DIV-INI-3 🟡 (dedotta) | `InitGenerators` cerca la tabella di un generatore nuovo con il confronto «comincia con» sul nome ricavato (`IndexOf(..., UseStartingWith = True)`): `GEN_DOC_ID` si lega alla prima tabella il cui nome comincia con `DOC` se `DOC` non esiste. Per un generatore già presente le esecuzioni successive riallineano solo `FieldName`, quindi il collegamento errato non si corregge più | `UpdateGenerators` (azione «Aggiornare i progressivi ?» di WT e Gesty e della form di sistema) imposta il generatore al massimo della colonna della tabella sbagliata: può portarlo sotto il valore reale e dare chiavi duplicate al prossimo inserimento |
| DIV-INI-4 🟢 (dedotta) | `ExtractTableNameFromGeneratorName` toglie `_ID` con il confronto `Pos('_ID', s) = Length(s) - 3 + 1`: con un nome di due caratteri `Pos` vale 0 e anche l'espressione vale 0, quindi il confronto è vero senza che ci sia il suffisso, e `Copy(s, 1, -1)` dà la stringa vuota (per esempio `GEN_AB`) | Il generatore di una tabella con nome di due lettere perde il nome della tabella: caso teorico |
| DIV-INI-5 🟢 (dedotta) | `GetCtrlType` non conosce `ftFMTBcd` (che `SqlFuncsForDataType` invece tratta come numerico), `ftWideMemo`, `ftLongWord`, `ftShortint`, `ftByte`, `ftSingle` e altri: restituiscono `ctDefault`. In WT la regola di FireDAC trasforma `dtFmtBCD` in `dtDouble` e il problema non si vede per i numeri; per i testi lunghi dipende da come FireDAC espone il campo | Un campo di quei tipi, creato in esecuzione senza un dominio `NOTE` o `MEMO`, nasce con il controllo predefinito, che può non essere quello che si vuole |
| DIV-INI-6 🟡 (dedotta) | Le voci create in esecuzione da `InitFields` (campo mancante nel `.LZ`) non passano per le regole dei domini di `InitDataDictionary` (`VALUTA_`, `ANNO`, `TRUE_FALSE`, `IMMAGINE`, `NOTE`/`MEMO` con blob): ricevono solo `GetCtrlType` e il formato numerico `###,##0` | Un anno o un importo in valuta di un campo non ancora nel dizionario si vedono come `2.026` e senza simbolo, finché un amministratore non rilegge i metadati; la stessa colonna dà risultati diversi secondo la strada da cui è entrata nel dizionario |
| DIV-INI-7 🟢 (dedotta) | Per una voce già presente, `InitDataDictionary` rilancia le regole del dominio quando `Domain.Domain` è diverso dal dominio dei metadati, ma non riscrive mai `Domain.Domain` della voce: la condizione resta vera a ogni riallineamento successivo | Per i domini con regole (`VALUTA_`, `SI_NO`, `TRUE_FALSE`, `ANNO`, `NOTE`, `MEMO`, `IMMAGINE`) il tipo di controllo e il formato scelti a mano nel dizionario vengono rimessi a quelli della regola a ogni rilettura dei metadati |

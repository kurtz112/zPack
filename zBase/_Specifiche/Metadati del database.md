---
area: Metadati del database
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/003
---

# Metadati del database

Questa specifica descrive la fotografia della struttura del database Firebird che il programma tiene nel dizionario LZ (`MetaData`): il modello `TzMetadata` con domini, sequenze, funzioni, procedure, tabelle con campi e vincoli, viste, trigger, pacchetti e le tre tabelle di base (`PickLists`, `Lookups`, `DataDictionary`); la sua lettura dal database attraverso le viste `META.*` e le tabelle `BASE.*`; la sua persistenza nell'archivio; le ricerche usate in esecuzione; la generazione degli script SQL. Il codice è in `zBase\zMetadata.pas` (modello, ricerche, persistenza), `zMetadata.Loader.pas` (lettura con FireDAC), `zMetadata.Query.pas` (le istruzioni SQL), `zMetadata.Utils.pas` (conversione dei tipi), `zMetadata.Types.pas` (tipo di editor) e `zMetadata.ScriptGenerator.pas` (script). Lo usano WT e Gesty: `TzSystem.LoadZip` legge `MetaData` dall'archivio, `TzSystem.InitializeFromDB` (voce «Aggiornamento Metadata») e `UpdateFromDB` lo rileggono dal database e riallineano il dizionario (`zSystem_Init`), `ConfigModule` di WT controlla campi e viste aggiornabili, `zExceptions.fib` lo usa per tradurre le violazioni di vincolo in messaggi leggibili, gli strumenti FBExpert dei due programmi (`zFBExpert.Engine.pas`) generano gli script. `zlz` usa `UpdateFromDB` per il comando `--aggiorna-metadata`, che zBuilder lancia nel passo «Cache LZ». Il progetto `zFbExpert` ha una propria copia di `zMetadata.ScriptGenerator.pas`, diversa da questa e fuori da questa specifica. `GetFirebirdDataType` di `zMetadata.Utils` non è chiamata da nessuna parte (DIV-MET-7).

**Come funziona.** `FillFirebirdMetadata` svuota `TzMetadata` e lo riempie con una sequenza fissa di query, una per tipo di oggetto; le righe di dettaglio (campi, chiavi, parametri) si agganciano al proprietario cercandolo per nome a partire dall'ultimo trovato, quindi il loro ordine deve seguire quello dei proprietari. Il risultato si salva nell'archivio come membro `MetaData` (DFM o JSON secondo `zCollectionPersistence`, `Collezione LZ.md`, ZBASE-COL-007) e si rilegge a ogni `LoadZip`. Le funzioni di `TScriptGenerator` trasformano un oggetto del modello nell'istruzione SQL che lo crea, lo modifica o lo elimina.

**Test che coprono quest'area.** Nessuna prova automatica in `D:\AI\SRC\zPack\_UnitTest\_src`: lettura dal database, conversione dei tipi, ricerche e generazione degli script sono senza prova.

## ZBASE-MET-001 Modello dei metadati
`TzMetadata` è un componente con undici collezioni published, nell'ordine di dichiarazione: `Domains`, `Generators`, `Functions`, `Procedures`, `Tables`, `Views`, `Triggers`, `Packages`, `PickLists`, `Lookups`, `DataDictionary`. Sono tutte create non ordinate e conservano l'ordine di lettura; anche le collezioni annidate (campi, chiave primaria, chiavi esterne, indici, vincoli, parametri) sono non ordinate e hanno come `Master` l'oggetto che le contiene, così un campo o un vincolo risale alla sua tabella con `Table`. Procedure e funzioni di un pacchetto hanno nome `PACCHETTO.NOME` (`FullMetadataName`). Ogni oggetto ha `Description` (righe di testo); procedure, funzioni, viste, trigger, pacchetti, liste e voci del dizionario hanno anche `Source`. `Clear` svuota tutte le collezioni e porta `Loaded` a falso; `IsEmpty` è vero solo se tutte le undici sono vuote.

### Scenario: campo e tabella
- **Dato** un `TzmdTableField` letto nella collezione `Fields` della tabella `CLIENTI`
- **Quando** si chiama `Table`
- **Allora** il risultato è la `TzmdTable` `CLIENTI`

## ZBASE-MET-002 Persistenza di MetaData
`SaveToStream` scrive nel formato deciso da `zResolveWriteFormat`; `SaveToStreamAs` in quello indicato: in JSON un oggetto con una chiave per collezione (`Collezione LZ.md`, ZBASE-COL-012), in DFM il componente intero. `LoadFromStream` riconosce il formato da solo, usa `StrictJSON` per il JSON, e alla fine porta `Loaded` a vero; un flusso nullo o vuoto non cambia niente. **La lettura non svuota prima**: ogni collezione presente nel flusso sostituisce la propria, quelle assenti restano come erano. Nell'archivio il membro si chiama col nome del componente (`MetaData.dfm` o `MetaData.json`); `SaveZip` lo riscrive solo con `csAll` o `csMetadata`, e per ciascun formato lo scrive o lo rimuove secondo il suo flag.

### Scenario: salvataggio JSON
- **Dato** `zCollectionPersistence.WriteJSON = True` e `WriteDFM = False`
- **Quando** `SaveZip(csAll)` salva l'archivio
- **Allora** l'archivio contiene `MetaData.json` e non `MetaData.dfm`

## ZBASE-MET-003 Lettura dal database
`FillFirebirdMetadata(Metadata, Connection, Transaction, LoadSource, CallBack, loadBase)` richiede metadati, connessione e transazione assegnati, svuota `Metadata` e legge, in quest'ordine: domini, sequenze, funzioni, parametri delle funzioni, tabelle, campi, chiavi primarie, chiavi esterne, vincoli univoci, vincoli `CHECK`, indici, dipendenze delle chiavi, procedure, parametri delle procedure, viste, campi delle viste, trigger, pacchetti; con `loadBase` vero (predefinito) anche `BASE.PICKLISTS`, `BASE.LOOKUPS` e `BASE.DATA_DICTIONARY`. Prima di ogni passo chiama `CallBack` con un messaggio «Lettura <oggetti>». Le query sono quelle di `TMetadataQuery` (`SELECT * FROM META.DOMAINS`, `META.TABLE_FIELDS`, ...): il database deve avere lo schema `META` con quelle viste e procedure, e con `loadBase` anche le tre tabelle di `BASE`. Il parametro `:LOAD_SOURCE` di `META.FUNCTIONS`, `META.PROCEDURES`, `META.VIEWS` e `META.TRIGGERS` riceve `LoadSource`: con falso (come fanno `InitializeFromDB` e `UpdateFromDB`) il sorgente PSQL non viene caricato. Alla fine copia funzioni e procedure di ogni pacchetto nel pacchetto stesso (`AssignPackageDetails`, vedi DIV-MET-3) e porta `Loaded` a vero. Tutti i testi letti sono ripuliti dagli spazi iniziali e finali.

### Scenario: aggiornamento senza sorgenti
- **Dato** un database con la procedura `CALCOLA_RATE`
- **Quando** `InitializeFromDB` legge i metadati
- **Allora** `Procedures` contiene `CALCOLA_RATE` con i parametri e con `Source` vuoto

### Scenario: senza tabelle di base
- **Dato** `loadBase` falso
- **Quando** si leggono i metadati
- **Allora** `PickLists`, `Lookups` e `DataDictionary` sono vuote e le tabelle `BASE.*` non vengono interrogate

## ZBASE-MET-004 Ordine delle righe di dettaglio
Le righe di `META.TABLE_FIELDS`, `TABLE_PRIMARY_KEYS`, `TABLE_FOREIGN_KEYS`, `TABLE_UNIQUES`, `TABLE_CHECKS`, `TABLE_INDEXES`, `TABLE_DEPENDENCIES`, `VIEW_FIELDS`, `PROCEDURE_PARAMS` e `FUNCTION_PARAMS` devono essere raggruppate per proprietario e i gruppi devono comparire nello stesso ordine dei proprietari letti prima (tabelle, viste, procedure, funzioni): il proprietario della riga si cerca a partire dalla posizione dell'ultimo trovato. Una riga il cui proprietario non c'è, o sta prima nella lista, non viene agganciata e la lettura si interrompe con un errore (DIV-MET-5). Le chiavi esterne sono raggruppate per `FK_NAME`, gli indici e i vincoli univoci per nome: ogni riga aggiunge un campo all'oggetto.

### Scenario: chiave esterna su due campi
- **Dato** due righe consecutive di `META.TABLE_FOREIGN_KEYS` con lo stesso `FK_NAME` e campi `ID_A`, `ID_B`
- **Quando** si leggono i metadati
- **Allora** la tabella ha una sola chiave esterna con `Fields` = `ID_A, ID_B` e `FkFields` con i due campi di riferimento

## ZBASE-MET-005 Tipi, valori predefiniti e obbligatorietà
`DataType` (tipo `TFieldType`) si ricava dal tipo e dal sottotipo Firebird con `GetDataType`: `SMALLINT` → `ftSmallInt`, `INTEGER` → `ftInteger`, `BIGINT` → `ftLargeInt`; gli stessi con sottotipo `NUMERIC` o `DECIMAL` → `ftFloat`; `FLOAT`, `DOUBLE` → `ftFloat`; `VARCHAR` → `ftString`; `CHAR` con sottotipo 0 o 2 → `ftString`, 1 (`OCTETS`) → `ftBytes`, 3 → `ftWideString`, ogni altro sottotipo → `ftUnknown`; `DATE`, `TIME`, `TIMESTAMP` → `ftDate`, `ftTime`, `ftDateTime`; `BOOLEAN` (17 e 23) → `ftBoolean`; `BLOB` di testo → `ftMemo`, binario → `ftBlob`; tipo sconosciuto → `ftUnknown`. `FbDataType` è il testo SQL del tipo come lo restituisce la vista `META` (`VARCHAR(50)`, `NUMERIC(15,2)`, ...). Per un campo: `DefaultValue` è il predefinito del campo o, se vuoto, quello del dominio; `DefaultFromField` e `DefaultFromDomain` li tengono separati; `NotNull` è vero se è obbligatorio il campo o il dominio; `Identity` se il campo è identità; `CalculatedSource` non vuoto indica un campo calcolato. `HasDomain` è vero solo per un dominio esplicito, non per quelli di sistema che cominciano con `RDB$`. Le tabelle hanno `TableType`: `0` → `ttPersistent`, `4` → `ttPerConnection` (tabella temporanea che conserva le righe), `5` → `ttPerSession` (tabella temporanea che cancella le righe al termine della transazione).

### Scenario: predefinito del dominio
- **Dato** un campo senza `DEFAULT` proprio il cui dominio ha `DEFAULT 0`
- **Quando** si leggono i metadati
- **Allora** `DefaultValue` vale `DEFAULT 0`, `DefaultFromField` è vuoto e `DefaultFromDomain` vale `DEFAULT 0`

## ZBASE-MET-006 Dipendenze delle chiavi
Ogni riga di `META.TABLE_DEPENDENCIES` dice quale chiave esterna dipende dalla chiave primaria o da un vincolo univoco della tabella: con `CONSTRAINT_TYPE = 'PRIMARY KEY'` va in `PrimaryKeyDependencies`, con `'UNIQUE'` nelle `Dependencies` del vincolo univoco omonimo. Un vincolo univoco che non esiste interrompe la lettura con «PK/UNIQUE non trovato. Tabella <tabella> pk/unique <vincolo>», un altro tipo con «Tipo constraint non gestito: <tipo>. Tabella <tabella> pk/unique <vincolo>».

### Scenario: tipo di vincolo inatteso
- **Dato** una riga di `META.TABLE_DEPENDENCIES` con `CONSTRAINT_TYPE = 'CHECK'`
- **Quando** si leggono i metadati
- **Allora** la lettura si interrompe con «Tipo constraint non gestito: CHECK. ...»

## ZBASE-MET-007 Trigger
`TriggerType` (il valore Firebird di `RDB$TRIGGER_TYPE`) determina le proprietà di sola lettura: `BeforeInsert` per 1, 17, 25, 113; `AfterInsert` per 2, 18, 26, 114; `BeforeUpdate` per 3, 17, 27, 113; `AfterUpdate` per 4, 18, 28, 114; `BeforeDelete` per 5, 25, 27, 113; `AfterDelete` per 6, 26, 28, 114; `OnConnect` 8192, `OnDisconnect` 8193, `OnTransactionStart` 8194, `OnTransactionCommit` 8195, `OnTransactionRollback` 8196, `BeforeAnyStatement` e `AfterAnyStatement` per i due valori dei trigger DDL su ogni istruzione. `IsDbTrigger` è vero per i trigger di database e DDL. `TriggerKind` è `tkBefore` se c'è almeno un evento `Before`, altrimenti `tkAfter` se c'è un evento `After`, altrimenti `tkUnknown`. `Active` è falso solo se `TRIGGER_INACTIVE` vale `1`; un trigger nuovo ha `Active` vero e `TriggerType` -1.

### Scenario: trigger su più eventi
- **Dato** un trigger con `TriggerType = 113`
- **Quando** si leggono le sue proprietà
- **Allora** `BeforeInsert`, `BeforeUpdate` e `BeforeDelete` sono veri e `TriggerKind` è `tkBefore`

## ZBASE-MET-008 Tabelle di base
Da `BASE.PICKLISTS` si leggono nome (`PICKLIST`) e descrizione; da `BASE.LOOKUPS` nome, campi e tabella, campi e tabella di riferimento, colonne visibili, `MAPPINGS` e `SELECT_SQL`; da `BASE.DATA_DICTIONARY` una voce per campo con nome `FIELD_ORIGIN`, tipo, dimensione, decimali, flag (`CALCULATED`, `IDENTITY_`, `READONLY`, `REQUIRED`), predefinito, etichetta, lookup, lista. Le tre collezioni vengono poi ordinate per nome. L'allineamento `ALIGN` vale `D` → destra, `S` → sinistra, ogni altro valore (anche vuoto) → centrato. `EDITOR_TYPE` è una lettera: `T` testo, `N` numerico, `D` data, `H` ora, `@` data e ora, `B` booleano, `P` lista, `L` lookup, `M` memo, `I` immagine; una lettera diversa lascia il valore precedente, cioè `metText`. Il tipo di editor diventa il tipo di controllo (`zCtrlType`): `metNumeric` → `ctSpin`, `metBoolean` → `ctCheckBox`, `metPickList` e `metLookup` → i controlli predefiniti per liste e lookup, e così via. La colonna `SENSITIVITY` è facoltativa: se manca, o se è nulla, `HasSensitivity` è falso e `Sensitivity` è `slNone`.

### Scenario: allineamento non previsto
- **Dato** una voce di `BASE.DATA_DICTIONARY` con `ALIGN = 'X'`
- **Quando** si leggono i metadati
- **Allora** `Alignment` è `taCenter`

### Scenario: database senza colonna di riservatezza
- **Dato** un database la cui `BASE.DATA_DICTIONARY` non ha la colonna `SENSITIVITY`
- **Quando** si leggono i metadati
- **Allora** la lettura riesce e ogni voce ha `HasSensitivity` falso

## ZBASE-MET-009 Ricerche in esecuzione
Le ricerche per nome non distinguono maiuscole e minuscole. `GetFK`, `GetIndex`, `GetUniqueConstraint` e `GetCheckConstraint` scorrono le tabelle e restituiscono il primo oggetto con quel nome, altrimenti `nil`. `GetIdentity(Tabella)` restituisce il campo identità o una stringa vuota. `FieldOrParamExists(Nome, Campo)` cerca il nome fra le tabelle, poi fra le viste, poi fra le procedure (parametri di ingresso e di uscita), e risponde falso se il nome non è nessuno dei tre. `GetLookup(Relazione, Campo)` risale, se la relazione è una vista, alla tabella e al campo d'origine del campo della vista, poi restituisce il nome della prima chiave esterna di quella tabella che contiene il campo, altrimenti una stringa vuota. Le tre funzioni `Extract*Params` preparano i dati per i messaggi di `zExceptions.fib`: tabella e campi senza il prefisso `ZZ_`, con l'iniziale di ogni parola maiuscola e i trattini bassi sostituiti da spazi (`zzCapFirst`); `ExtractUniqueParams` cerca il nome prima fra le chiavi primarie, poi fra i vincoli univoci, poi fra gli indici (Mantis #180: un indice univoco senza vincolo solleva un errore di duplicato con il nome dell'indice); `ExtractCheckConstraintParams` toglie dal testo del vincolo `CHECK` e le parentesi esterne.

### Scenario: chiave univoca violata su un indice
- **Dato** l'indice univoco `UNQ1_AULE_PRENOTAZIONI` sulla tabella `AULE_PRENOTAZIONI`, senza vincolo con lo stesso nome
- **Quando** si chiama `ExtractUniqueParams('UNQ1_AULE_PRENOTAZIONI', ...)`
- **Allora** il risultato è vero, con la tabella `Aule Prenotazioni` e i campi dell'indice scritti allo stesso modo

### Scenario: lookup da una vista
- **Dato** la vista `V_CLIENTI` il cui campo `ID_COMUNE` viene da `CLIENTI.ID_COMUNE`, e la chiave esterna `FK_CLIENTI_COMUNI` su quel campo
- **Quando** si chiama `GetLookup('V_CLIENTI', 'ID_COMUNE')`
- **Allora** il risultato è `FK_CLIENTI_COMUNI`

## ZBASE-MET-010 Script di creazione
`TScriptGenerator` produce il testo SQL Firebird di un oggetto del modello; le istruzioni PSQL finiscono con `^` (da usare fra `SetTerm(True)` = `SET TERM ^ ;` e `SetTerm(False)` = `SET TERM ; ^`), le altre con `;`.
- `CreateTable`: `CREATE TABLE` o `CREATE GLOBAL TEMPORARY TABLE`, un campo per riga allineato, col dominio se esplicito altrimenti col tipo, `GENERATED BY DEFAULT AS IDENTITY` per l'identità, altrimenti il predefinito del campo e `NOT NULL`; chiusura `);`, `) ON COMMIT PRESERVE ROWS;` (`ttPerConnection`) o `) ON COMMIT DELETE ROWS;` (`ttPerSession`); i campi calcolati vengono dopo, uno per riga, come `ALTER TABLE ... ADD <campo> COMPUTED BY <espressione>;`.
- `CreateTableField`: `ALTER TABLE <tabella> ADD <campo> ...`; un campo obbligatorio non identità finisce con `NOT NULL; -- @NOT NULL` (seguito da `[DefaultValue]` se ha un predefinito) perché chi compone lo script prepari l'aggiornamento dei dati esistenti; con `skipNotNull` il vincolo si omette. `InitializeNotNull` produce lo scheletro `UPDATE <tabella> SET <tabella>.<campo>, ...; COMMIT WORK;` fra i segnaposto `-- @NOT NULL!!! DA DEFINIRE` e `-- \@NOT NULL`, da completare a mano.
- `CreatePrimaryKey`, `CreateForeignKey` (con `ON UPDATE` e `ON DELETE` solo se la regola non è vuota e non è `RESTRICT`), `CreateTableUnique` (con `USING INDEX` se c'è l'indice), `CreateTableCheck`, `CreateTableIndex` (`UNIQUE`, `DESCENDING`, `COMPUTED BY` per gli indici su espressione).
- `CreateFunctionImpl`, `CreateProcImpl`, `CreateView`, `CreateTrigger`, `CreatePackage` (intestazione, poi `RECREATE PACKAGE BODY`): l'oggetto completo col suo sorgente, sempre `CREATE OR ALTER`.
- `CreateFunctionIntf` e `CreateProcIntf` producono la sola interfaccia con un corpo vuoto (`RETURN NULL;`, `EXIT;` o `SUSPEND;`); `CommentFunction`, `CommentProc` (interfaccia con i tipi base invece dei domini) e `CommentView` (vista con `CAST(NULL AS <tipo>)` da `RDB$DATABASE`) producono segnaposto: servono a creare prima gli oggetti, rompendo le dipendenze circolari, e a ricrearli dopo col sorgente.
- `CreateTrigger` solleva «Errore trigger <nome>» se il trigger non è di database e `TriggerKind` è `tkUnknown`.
- Modifiche ed eliminazioni (`AlterDomainType`, `AlterTableFieldType`, `AlterTableFieldDefault`, `AlterTableFieldNotNull`, `Drop*`) producono una sola istruzione; quelle che cambiano un tipo aggiungono i segnaposto `--@DOMAIN TYPE`, `-- @FIELD TYPE` e `-- @IDENTITY` per la revisione a mano. `Comment` produce `COMMENT ON <tipo> <nome> IS '<descrizione>';` con gli apici raddoppiati e senza le righe vuote finali.

### Scenario: chiave esterna con cancellazione a cascata
- **Dato** la chiave esterna `FK_RIGHE_TESTATA` di `RIGHE` su `ID_TESTATA` verso `TESTATE(ID_TESTATA)` con `DeleteRule = 'CASCADE'` e `UpdateRule = 'RESTRICT'`
- **Quando** si chiama `CreateForeignKey`
- **Allora** il risultato è `ALTER TABLE RIGHE ADD CONSTRAINT FK_RIGHE_TESTATA FOREIGN KEY (ID_TESTATA) REFERENCES TESTATE (ID_TESTATA) ON DELETE CASCADE;`

### Scenario: tabella temporanea
- **Dato** una tabella con `TableType = ttPerSession`
- **Quando** si chiama `CreateTable`
- **Allora** il testo comincia con `CREATE GLOBAL TEMPORARY TABLE` e finisce con `) ON COMMIT DELETE ROWS;`

## Divergenze note
Si decidono nella voce R-201 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MET-1 🟡 (dedotta) | In `Fill_TableForeignKeys` la prima chiave esterna viene creata fuori dal ciclo con solo nome e tabella di riferimento; nel ciclo la stessa riga non è «nuova» e `FkContraintType`, `FkContraintName`, `UpdateRule` e `DeleteRule` non vengono mai assegnati | La prima chiave esterna del database (nell'ordine di `META.TABLE_FOREIGN_KEYS`) perde le regole: lo script generato la ricrea senza `ON DELETE CASCADE` o `ON UPDATE`, cambiando il comportamento del database |
| DIV-MET-2 🟡 (dedotta) | `ExtractFkParams` usa `FK.Table` anche quando `GetFK` non trova la chiave esterna (per esempio perché `MetaData` è più vecchio del database) | Durante la traduzione di una violazione di chiave esterna in `zExceptions.fib` scatta un errore di accesso alla memoria al posto del messaggio «Relazione violata tra le tabelle ...» |
| DIV-MET-3 🟡 (dedotta) | `TzmdProcedure.Assign` (come `TzmdTable.Assign` e `TzmdView.Assign`) non chiama la versione ereditata e non copia `Name` né `Description` | `AssignPackageDetails` mette nei pacchetti procedure senza nome; ogni copia di tabelle, viste o procedure con `Assign` perde nome e descrizione |
| DIV-MET-4 🟡 (dedotta) | Per un trigger di database `CreateTrigger` sostituisce l'intera riga `ACTIVE`/`INACTIVE` con `ON CONNECT`, `ON DISCONNECT`, ... | Un trigger di database disattivato viene ricreato attivo dallo script |
| DIV-MET-5 🟢 (dedotta) | Se una riga di dettaglio ha un proprietario che non si trova (ordine diverso fra le viste `META`, oggetto sparito fra due query) il proprietario è `nil` e la lettura si ferma con un errore di accesso alla memoria; solo la prima riga delle chiavi esterne ha un messaggio chiaro («FK - Tabella non trovata: ...») | L'aggiornamento dei metadati fallisce con un messaggio che non dice quale tabella o vista manca |
| DIV-MET-6 🟢 (dedotta) | `FirebirdMetadataCallBackSteps` vale 17, ma `FillMetadata` chiama `CallBack` 18 volte, 21 con `loadBase` | Le barre di avanzamento dimensionate su questa costante (`InitializeFromDB` con `FirebirdMetadataCallBackSteps + 9`, zFbTools) contano su un numero di passi sbagliato e non rispecchiano l'avanzamento reale |
| DIV-MET-7 🟢 (dedotta) | `GetFirebirdDataType` riconosce `BOOLEAN` sul codice 17 invece di 23, ignora il sottotipo `NUMERIC` di `SMALLINT` e divide sempre per 4 la lunghezza di `CHAR` e `VARCHAR`; non è chiamata da nessuna parte | Codice morto che inganna: chi la riusasse otterrebbe `<unknown>` per i booleani e tipi sbagliati |
| DIV-MET-8 🟢 (dedotta) | Molti setter di collezioni ed elenchi sostituiscono il riferimento invece di copiare il contenuto: `TzMetadata.SetDomains`, `SetGenerators`, `SetProcedures`, `SetTables`, `SetViews`; `TzmdForeignKey.SetFields`, `SetFkFields`; `TzmdView.SetFields`; `TzmdProcedure.SetParamsInput`, `SetParamsOutput`; `TzmdLookup.SetSelectSQL`; `TzMetadataItem.SetDescription` | La lettura DFM e JSON non passa dai setter, ma un'assegnazione da codice perde l'oggetto originale e porta a una doppia liberazione alla chiusura |
| DIV-MET-9 🟢 (dedotta) | `TzmdPackage` non ha distruttore: `Procedures`, `Functions`, `Header` e `Body` non vengono mai liberati; `TzmdPicklist` ridichiara `Description` con un secondo elenco | Perdita di memoria a ogni lettura dei metadati; due `Description` diverse sulla stessa lista a seconda del tipo con cui la si guarda |
| DIV-MET-10 🟢 (dedotta) | `ExtractCheckConstraintParams` toglie **tutte** le `(` e tutte le occorrenze di `CHECK ` dal testo, poi una sola `)` finale | Nei messaggi di violazione di un vincolo con parentesi annidate (`CHECK (STATO IN ('A','B'))`) il testo mostrato è sbilanciato |
| DIV-MET-11 🟢 (dedotta) | `TzMetadata.LoadFromStream` non svuota le collezioni prima di leggere | Se l'archivio non ha `MetaData`, o ne ha uno senza alcune sezioni, restano in memoria i dati del caricamento precedente |
| DIV-MET-12 🟢 (dedotta) | In `TScriptGenerator` la pulizia delle righe vuote finali (`AddStrings`) continua a leggere l'ultima riga anche quando l'elenco si è svuotato | Una `Description` o un `Source` fatti solo di righe vuote fanno sollevare un errore di indice fuori dai limiti durante la generazione dello script |

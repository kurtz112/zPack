---
area: Personalizzazioni dei campi
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Personalizzazioni dei campi

Questa specifica descrive le personalizzazioni di campo che un cliente può chiedere senza toccare il dizionario LZ distribuito con il programma: una didascalia diversa per la scheda o per la griglia, e alcuni interruttori per singolo campo (campo obbligatorio, di sola lettura, nascosto, senza valore predefinito). Vivono nella tabella `OVERRIDES` del database del cliente, quindi sopravvivono agli aggiornamenti del file `.LZ`. Il codice è in `zBase\zOverrides.pas` (`TOverrideItem`, `TOverrideCollection`, `TOverrideManager`, funzione `Overrides` che dà l'oggetto unico) e nei punti che le applicano: `TzSystem.Login` le carica, `TzSystem.InitFields` toglie i valori predefiniti (`zSystem.pas`), `TzColumns.AssignToGridColumns` e `TzDbView.CreateColumns` decidono la didascalia delle colonne (`zSystem.pas`, `zDbView.pas`), `TzControl.SetDisplayLabel` e `TzControls.LoadFromProps` quella delle schede (`zDbCard.pas`), `TzDbRecordViewRowsBuilder` quella della vista record (`zDbRecordView.Rows.pas`). WT e Gesty non usano `zOverrides` direttamente: lo ricevono attraverso questi componenti, e la voce di menu «Override campo» che le modifica compare solo all'amministratore (`OverrideCampoUpdate` in `TzDbView` e `TzDbCard`). La tabella e la procedura `OVERRIDE_SAVE` esistono nei dizionari di WT, Gesty e zTicser. La unit non ha prefisso applicativo e non dipende da `TzSystem`: riceve la connessione da chi la chiama. Descrive il comportamento atteso, non il codice.

**Come funziona.** All'accesso `TzSystem.Login` chiede a `Overrides.LoadFromDB` di leggere tutta la tabella e di costruire due indici in memoria, uno per `DATASET.CAMPO` e uno per solo dataset. Chi disegna una colonna, un controllo o un campo chiede al gestore se per quel campo c'è una personalizzazione e, se c'è, la applica prima di ogni altra regola. La chiave è sempre il nome del dataset del dizionario (`modulo.dataset`, per esempio `Studenti.Elenco`) e il nome del campo, senza distinguere le maiuscole.

**Test che coprono quest'area.** `Test.zOverrides` prova il caricamento con i flag attivi, le ricerche senza distinzione di maiuscole, le due forme di `OverrideExists`, le didascalie, `Add`, `Remove` e `Assign`. Restano senza prova, perché servono Firebird e la procedura `OVERRIDE_SAVE`, `SaveItem` e l'effetto di `InitFields`.

## ZBASE-OVR-001 Tabella e caricamento
La tabella `OVERRIDES` ha come chiave primaria `DATASET` e `FIELD_NAME` e le colonne `CAPTION_CARD` e `CAPTION_GRID` (facoltative), `FORCE_REQUIRED`, `FORCE_READONLY`, `FORCE_HIDDEN` e `SUPPRESS_DEFAULT` (booleane, obbligatorie, falso se non indicate) e `NOTE`. `LoadFromDB(Connessione)` svuota la collezione, legge `SELECT * FROM OVERRIDES ORDER BY DATASET, FIELD_NAME`, crea un elemento per riga, ricostruisce gli indici e segna `Loaded` vero. Un secondo caricamento sostituisce il contenuto del primo. Se la query fallisce (tabella mancante, connessione chiusa) l'errore esce da `LoadFromDB` e, dentro `TzSystem.Login`, interrompe l'avvio (DIV-OVR-5).

### Scenario: tabella con due righe
- **Dato** la tabella `OVERRIDES` con le righe `Studenti.Elenco / COGNOME` e `Studenti.Elenco / NOME`
- **Quando** si chiama `Overrides.LoadFromDB`
- **Allora** `Overrides.Overrides.Count` è 2 e `Overrides.Loaded` è vero

### Scenario: ricaricamento
- **Dato** un caricamento già fatto con due righe
- **Quando** la tabella ha una sola riga e si richiama `LoadFromDB`
- **Allora** la collezione ne contiene una sola

## ZBASE-OVR-002 Chiave e ricerca
La chiave di un elemento è `DATASET.CAMPO` tutto in maiuscolo (`TOverrideItem.Key`). `FindOverride(Dataset, Campo)` cerca nell'indice con la stessa regola e restituisce l'elemento, oppure `nil` se non c'è. `OverrideExists(Dataset, Flag)` è vero se per quel dataset esiste almeno una personalizzazione; con un insieme di flag non vuoto è vero solo se almeno un elemento del dataset ha attivo almeno uno dei flag indicati. `OverrideExists(Dataset, Campo, Flag)` vale per un solo campo con la stessa regola. Con l'insieme dei flag vuoto (il predefinito) basta che la personalizzazione esista. Un dataset o un campo sconosciuto dà falso, mai un errore.

### Scenario: maiuscole e minuscole
- **Dato** una personalizzazione caricata per `Studenti.Elenco / Cognome`
- **Quando** si chiama `FindOverride('STUDENTI.ELENCO', 'cognome')`
- **Allora** si ottiene lo stesso elemento

### Scenario: almeno uno dei flag
- **Dato** una personalizzazione di `Studenti.Elenco / NOME` con solo `SUPPRESS_DEFAULT` vero
- **Quando** si chiama `OverrideExists('Studenti.Elenco', 'NOME', [ofCaptionCard, ofSuppressDefault])`
- **Allora** il risultato è vero
- **E** con `[ofCaptionCard]` da solo è falso

## ZBASE-OVR-003 Flag attivi
Ogni elemento ha `ActiveFlags`, l'insieme di ciò che la riga del database ha davvero impostato:
- `ofCaptionCard` e `ofCaptionGrid` quando la colonna corrispondente **non è NULL** (una didascalia vuota ma non NULL conta come impostata);
- `ofForceRequired`, `ofForceReadOnly`, `ofForceHidden` e `ofSuppressDefault` solo quando il valore è **vero**: il falso coincide con «niente da forzare».

`ActiveFlags` si ricalcola solo in `LoadFromDB`; non fa parte delle proprietà pubblicate, quindi un editore di proprietà non lo vede e non lo aggiorna (DIV-OVR-1). I tre flag di forzatura si salvano e si ricaricano, ma oggi nessuna parte di zPack, di WT o di Gesty li applica (DIV-OVR-2).

### Scenario: didascalia nulla
- **Dato** una riga con `CAPTION_CARD` NULL e `CAPTION_GRID = 'Cognome e nome'`
- **Quando** viene caricata
- **Allora** `ActiveFlags` contiene `ofCaptionGrid` e non contiene `ofCaptionCard`

### Scenario: booleani
- **Dato** una riga con `FORCE_HIDDEN` vero e gli altri tre falsi
- **Quando** viene caricata
- **Allora** `ActiveFlags` è esattamente `[ofForceHidden]`

## ZBASE-OVR-004 Didascalie e loro priorità
`CaptionGrid(Dataset, Campo)` e `CaptionCard(Dataset, Campo)` restituiscono la didascalia solo se il flag corrispondente è attivo; altrimenti la stringa vuota, che per chi chiama vuol dire «nessuna personalizzazione: applica la regola successiva». La personalizzazione ha sempre la priorità più alta:
- **Griglia** (`TzColumns.AssignToGridColumns`, `TzDbView.CreateColumns`): personalizzazione del cliente; poi la didascalia salvata nella vista; poi quella del dominio (`DisplayLabel`); in ultimo il nome del campo con la prima lettera maiuscola (`CapFirst`);
- **Scheda** (`TzControl.SetDisplayLabel`, `TzControls.LoadFromProps`): personalizzazione del cliente; poi la didascalia del controllo; poi quella del dominio;
- **Vista record** (`TzDbRecordViewRowsBuilder.FieldCaption`): personalizzazione del cliente; poi la didascalia della riga; poi l'etichetta del campo.

Quando una colonna ha una personalizzazione, il salvataggio della vista (`TzColumns.AssignFromGridColumns` e `TzColumns.ValidateDataset`) non memorizza la sua didascalia (la lascia vuota), così la personalizzazione non finisce nel dizionario.

### Scenario: personalizzazione della griglia
- **Dato** una personalizzazione `CAPTION_GRID = 'Cognome e nome'` per `Studenti.Elenco / COGNOME` e una didascalia di dominio `Cognome`
- **Quando** la griglia disegna la colonna
- **Allora** l'intestazione è «Cognome e nome»

### Scenario: nessuna personalizzazione
- **Dato** una personalizzazione che ha solo `CAPTION_CARD`
- **Quando** si chiama `CaptionGrid`
- **Allora** il risultato è la stringa vuota

## ZBASE-OVR-005 Soppressione del valore predefinito
`TzSystem.InitFields` porta sui campi di un dataset gli attributi del dizionario, compresa la `DefaultExpression`; alla fine, se per il dataset esiste almeno una personalizzazione con `ofSuppressDefault`, svuota la `DefaultExpression` dei campi che hanno quel flag attivo e `SuppressDefault` vero. La soppressione prevale sul valore predefinito del dizionario e su quello dedotto dai metadati (`Creazione e allineamento del dizionario.md`, ZBASE-INI-008). Il dataset deve però avere un identificativo e una voce nel dizionario: se `InitFields` esce prima per questo motivo, nessuna soppressione si applica.

### Scenario: campo senza valore predefinito
- **Dato** un campo con `DEFAULT` nel dizionario e una personalizzazione con `SUPPRESS_DEFAULT` vero
- **Quando** il dataset si apre e `InitFields` termina
- **Allora** il campo ha `DefaultExpression` vuota

## ZBASE-OVR-006 Modifica da parte dell'amministratore
La voce di menu «Override campo» (visibile solo se `IsAdmin`) cerca la personalizzazione del campo con `FindOverride`; se non c'è ne aggiunge una in memoria con `Overrides.Add(Dataset, Campo)`; apre l'editor delle proprietà (`zEditProperties`) e, se l'amministratore conferma, chiama `SaveItem`, poi riapplica la didascalia al controllo o alla colonna (didascalia vuota: ricade sul dominio o sul nome del campo). Se annulla e la personalizzazione era nuova, la toglie con `Remove`.

`SaveItem(Elemento, Connessione)` chiama `OVERRIDE_SAVE` con tutti i campi (i quattro booleani sempre, come 1 o 0; le didascalie come valore se il flag corrispondente è in `ActiveFlags`, altrimenti NULL; `NOTE`), poi `Commit` della connessione, poi aggiorna gli indici e, se l'elemento non era ancora nella collezione, ne aggiunge una copia. `Add` crea l'elemento con `ActiveFlags` vuoto e **non** lo mette negli indici: `FindOverride` lo trova solo dopo `SaveItem` o dopo un nuovo `LoadFromDB`. `Remove` elimina l'elemento dalla collezione e non tocca né il database né gli indici (DIV-OVR-3).

### Scenario: aggiunta non ancora salvata
- **Dato** nessuna personalizzazione per `Studenti.Elenco / NOME`
- **Quando** si chiama `Overrides.Add('Studenti.Elenco', 'NOME')`
- **Allora** `Overrides.Overrides.Count` aumenta di uno e `FindOverride('Studenti.Elenco', 'NOME')` restituisce `nil`

### Scenario: copia di un elemento
- **Dato** un elemento con didascalie, quattro flag, nota e `ActiveFlags`
- **Quando** lo si copia con `Assign` in un altro elemento
- **Allora** tutte le proprietà e `ActiveFlags` sono uguali

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-212 di `Attivita Rinviate.md` indicata dalla sessione principale. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-OVR-1 🟡 (dedotta) | `SaveItem` decide se scrivere le didascalie e `OverrideExists` decide se un flag è attivo leggendo `ActiveFlags`, ma l'editor delle proprietà (`zEditProperties`) modifica solo le proprietà pubblicate e `ActiveFlags` non lo è; nessun altro codice lo imposta (ricerca su zPack, WT e Gesty) | Una personalizzazione **nuova** (`Add` lascia `ActiveFlags` vuoto) salva sempre le didascalie come NULL: la didascalia scritta dall'amministratore si perde in silenzio, anche dopo il riavvio. Su una personalizzazione già caricata vale solo per le didascalie che aveva già. I booleani si scrivono nel database, ma nella sessione in corso `OverrideExists` non li vede (per esempio `ofSuppressDefault`) fino al riavvio |
| DIV-OVR-2 🟡 (dedotta) | `ForceRequired`, `ForceReadOnly` e `ForceHidden` si salvano, si caricano e compaiono nell'editor, ma nessuno li legge: `OverrideExists`/`FindOverride` con questi flag non sono chiamati da nessuna parte (ricerca su zPack, WT e Gesty; gli unici usi sono didascalie e `ofSuppressDefault`). Per «obbligatorio» e «sola lettura» il dizionario ha già un meccanismo suo (`RequiredOverride` e `ReadOnlyOverride` di `TzDomain`, modificabile solo con il dizionario LZ distribuito), ma non è personalizzabile dal cliente senza ricevere un nuovo `.LZ`: la tabella `OVERRIDES` doveva colmare questo vuoto, come lascia intendere il commento «Ripristinare dopo l'introduzione degli OVERRIDE» in `InitDataDictionary` (`zSystem_Init.pas`) | L'amministratore imposta «campo obbligatorio», «sola lettura» o «nascosto» per un campo e non succede niente: la funzione è promessa dall'editor e mai applicata |
| DIV-OVR-3 🟢 (dedotta) | `Add` e `Remove` non aggiornano gli indici, e `Remove` non cancella la riga dal database: se un elemento già salvato venisse tolto, `FindOverride` restituirebbe un puntatore a un oggetto già liberato. Se `SaveItem` fallisce, l'elemento resta nella collezione e una nuova apertura dell'editor ne aggiunge un secondo con la stessa chiave | Oggi i chiamanti rimuovono solo elementi appena aggiunti e mai salvati, quindi il rischio non si manifesta; ma `Remove` non è utilizzabile per «annullare» una personalizzazione salvata, e un errore di salvataggio lascia doppioni fino al riavvio |
| DIV-OVR-4 🟢 (dedotta) | `SaveItem` chiude con `Connection.Commit`, cioè conferma la transazione predefinita dell'intera connessione, non solo la propria scrittura | Se in quel momento la connessione ha altro lavoro non confermato nella transazione predefinita, viene confermato insieme |
| DIV-OVR-5 🟡 (dedotta) | `TzSystem.Login` chiama `Overrides.LoadFromDB` senza proteggerla, subito dopo un accesso riuscito e prima di leggere il dizionario | Con un database che non ha ancora la tabella `OVERRIDES` (aggiornamento non eseguito) l'avvio fallisce con un errore di database dopo l'accesso, e il messaggio non dice che manca uno script. Nei dizionari di WT, Gesty e zTicser la tabella è prevista |

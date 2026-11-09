---
area: Lookup di zDX
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/001
---

# Lookup di zDX

Questa specifica descrive come `zDX` trasforma un campo «scegli da un elenco» in un editor DevExpress configurato: le caselle con elenco a tendina semplice (`TcxLookupComboBox`) e a griglia (`TcxExtLookupComboBox`), i loro `Properties`, le liste di valori (picklist) sulle caselle immagine, e la voce «Tutti» dei filtri. Il codice è in `zBase\zDX.pas` (modulo dati `Tdx`, raggiungibile con la funzione `dx`), con il legame al dizionario LZ in `zBase\zSystem.pas` (`TzSystem.GetLookup`, `TzLookup`, `TzPickList`). La unit non compare per nome nei `.dpr` di WT e Gesty: entra nella compilazione perché la includono nell'`uses` circa 62 file di WT, 43 di Gesty e 37 di zPack (copie di lavoro escluse). Righe di chiamata nei sorgenti (copie escluse): `InitLookup` 76 in WT, 60 in Gesty e 16 in zPack; `InitPickList` 28 in WT, 14 in Gesty e 1 in zPack; `AssignPickList`, `CreateGridDBTableView` e `InitLookupColumns` non risultano chiamate da fuori `zDX`: le usano solo `InitProperties`, `InitLookup` e `LookupComboButtonClick` dentro `zDX` stesso. La specifica descrive il comportamento atteso verso chi configura un lookup, non la grafica della tendina. Le altre parti di `zDX` (colori, skin, stili, correttore ortografico, griglie, barre) hanno specifiche proprie.

**Come funziona.** `dx.InitLookup(IdLookup, editor, DataSet, DataSource, Chiave, Colonne, ...)` fa quattro cose, sempre in questo ordine: ricava dal dizionario LZ la «ricerca» (`TzLookup`) che si chiama `IdLookup` o, se è vuoto, come l'`IdDataSet` del dataset; applica all'editor l'aspetto standard dei lookup (`InitProperties`); sceglie se l'utente può digitare un valore fuori elenco (campo `OnlyFromLookup` della ricerca); collega l'editor al `DataSource` e a campo chiave e colonne. Per la tendina a griglia crea in più una vista (`TcxGridDBTableView`) con la griglia dell'elenco e si aggancia agli eventi di apertura e chiusura per adattare la finestra del popup al contenuto. Il pulsante «...» accanto alla freccia apre la finestra di scelta con la vista completa dei dati (`TzDbViewDlg`).

**Test che coprono quest'area.** Il test `Test.zDX.Lookup` prova la parte che non richiede finestre né il modulo `Tdx`: la ricerca del dizionario (`TzSystem.GetLookup`, ZBASE-LKP-002), la chiave e le colonne ricavate da `TzLookup` (ZBASE-LKP-003 e ZBASE-LKP-004), il copiare una picklist su una casella immagine (`TzPickList.AssignToProps`, ZBASE-LKP-014) e la costante `ImmagineVoceTutti` (ZBASE-LKP-015). Restano senza prova tutte le routine di `Tdx` (`InitLookup`, `InitLookupColumns`, `CreateGridDBTableView`, i gestori del popup, `AssignPickList`, `InitPickList`): sono metodi del modulo dati, e crearlo (`dx`) carica il DFM con le skin, applica la traduzione italiana ai testi di DevExpress e di Delphi (`zTranslate`, che modifica risorse comuni a tutto il processo) e tocca il look and feel globale, con effetti che non è possibile escludere senza eseguirlo. `TLookupViewProps` e il contatore di generazione del popup sono dichiarati nella parte `implementation` o privati e non si raggiungono da un test. Il comportamento di queste parti si prova sul banco con la sonda di collaudo.

## ZBASE-LKP-001 Le quattro forme di InitLookup
`Tdx.InitLookup` esiste in quattro forme, a coppie: una per l'editor (`TcxCustomLookupComboBox` o `TcxCustomExtLookupComboBox`) e una per le sole `Properties` (`TcxLookupComboBoxProperties` o `TcxExtLookupComboBoxProperties`, con in più il nome del campo dati `DataField`, usato dalle colonne delle griglie). Le forme su editor ricavano `DataField` da `DataBinding.DataField` solo se l'editor è la variante `TcxDB...` (legata a un campo); per gli editor non legati `DataField` vale stringa vuota. Poi chiamano la forma su `Properties`.
- Forma semplice: `InitLookup(IdLookup, editor|Properties, DataSet, DataSource, Chiave, Colonne, HyperLink=False)`.
- Forma a griglia: `InitLookup(IdLookup, editor|Properties, DataSet, DataSource, Chiave, Colonne, ArchivioViste=nil, HyperLink=False, AggiungiCancella=False)`.
`DataSet` e `DataSource` sono obbligatori (controllo con `Assert`: nelle compilazioni senza asserzioni un valore nullo diventa una violazione di accesso, DIV-LKP-4).

### Scenario: editor legato a un campo
- **Dato** un `TcxDBExtLookupComboBox` con `DataBinding.DataField` = `ID_PERSONA`
- **Quando** si chiama `dx.InitLookup('', combo, DataSet, DataSource, 'ID_PERSONA', 'COGNOME;NOME')`
- **Allora** la chiave del combo si ricava da `TzLookup.GetKeyFieldForCombo('ID_PERSONA')`, quindi tiene conto delle mappature (ZBASE-LKP-003)

### Scenario: editor non legato
- **Dato** un `TcxLookupComboBox` non legato ai dati (per esempio in un filtro)
- **Quando** si chiama `InitLookup`
- **Allora** `DataField` è vuoto e la chiave è quella della ricerca, senza mappature

## ZBASE-LKP-002 La ricerca del dizionario LZ
`InitLookup` chiede a `Base.GetLookup(IdLookup, DataSet, Chiave, Colonne)` la ricerca (`TzLookup`) da usare. Regole di `TzSystem.GetLookup`:
- il nome della ricerca è `IdLookup`; se `IdLookup` è vuoto è `DataSet.IdDataSet`;
- se la ricerca non esiste nel dizionario viene **creata** con quel nome, `DataSet` e `DbView` uguali a `DataSet.IdDataSet`, chiave uguale al parametro `Chiave` (se vuoto, alla chiave primaria del dataset, `PrimaryKeyFields`), colonne uguali al parametro `Colonne` (se vuoto, alla chiave), `IsForeignKey` falso (altrimenti l'aggiornamento della cache la eliminerebbe), e il dizionario risulta modificato (`Base.Modified`);
- se esiste già, non si toccano i valori presenti: si riempiono solo la chiave e le colonne rimaste vuote, con le stesse regole di prima (parametro, poi chiave primaria, poi chiave).
Un `IdLookup` mai visto non è quindi un errore: il lookup nasce al volo, con le colonne scritte dal chiamante, e resta in memoria nel dizionario.

### Scenario: lookup nuovo
- **Dato** un dizionario senza la ricerca `Anagrafica.Soggetti` e un dataset con `IdDataSet` `Anagrafica.Soggetti` e chiave primaria `ID_SOGGETTO`
- **Quando** si chiama `GetLookup('', DataSet)` senza chiave né colonne
- **Allora** nasce la ricerca `Anagrafica.Soggetti` con chiave `ID_SOGGETTO` e colonne `ID_SOGGETTO`

### Scenario: lookup già presente
- **Dato** una ricerca esistente con chiave `COD` e colonne `COD;DESC`
- **Quando** si chiama `GetLookup` con altre chiave e colonne
- **Allora** restano `COD` e `COD;DESC`

### Scenario: ricerca esistente con colonne vuote
- **Dato** una ricerca esistente con chiave `COD` e colonne vuote
- **Quando** si chiama `GetLookup` con colonne `COD;DESC`
- **Allora** le colonne diventano `COD;DESC` e la chiave resta `COD`

## ZBASE-LKP-003 Chiave e colonne dell'elenco
`TzLookup.KeyField` e `TzLookup.DisplayColumns` accettano elenchi separati da `;` o da `,` e salvano sempre `;` (le virgole vengono sostituite). Per il combo:
- `GetKeyFieldForCombo(DataField)`: parte dalla chiave della ricerca; se `DataField` non è vuoto e la mappatura (`Mappings`, coppie `CampoDelDataSetPrincipale=CampoDellElenco`) lo contiene, usa il campo mappato; poi sostituisce `,` con `;` e, se resta un elenco, prende **solo il primo campo**: una combo mostra una chiave sola;
- `GetListFieldNamesForCombo(DataField)`: `DisplayColumns` così com'è; se è vuoto e la ricerca ha una vista (`DbView`) sceglie i campi visibili della vista; se è ancora vuoto, la chiave del combo.
Nella tendina semplice il risultato di `GetKeyFieldForCombo` va in `KeyFieldNames`; in quella a griglia vanno in `KeyFieldNames` e `ListFieldNames` dopo la creazione delle colonne della vista. Nella tendina semplice le colonne mostrate non si ricavano da `GetListFieldNamesForCombo` (DIV-LKP-6).

### Scenario: chiave multipla
- **Dato** una ricerca con chiave `ID_ANNO;ID_CORSO`
- **Quando** si chiama `GetKeyFieldForCombo('')`
- **Allora** il risultato è `ID_ANNO`

### Scenario: mappatura
- **Dato** una ricerca con chiave `ID` e la mappatura `ID_CLIENTE=COD_CLIENTE`
- **Quando** si chiama `GetKeyFieldForCombo('ID_CLIENTE')`
- **Allora** il risultato è `COD_CLIENTE`
- **E** per `GetKeyFieldForCombo('ALTRO')` il risultato è `ID`

### Scenario: colonne non indicate
- **Dato** una ricerca senza `DisplayColumns` e senza vista, con chiave `COD`
- **Quando** si chiama `GetListFieldNamesForCombo('')`
- **Allora** il risultato è `COD`

## ZBASE-LKP-004 Digitazione libera o solo da elenco
Il campo `OnlyFromLookup` della ricerca (predefinito vero) decide come si comporta il combo:
- vero: `DropDownListStyle` = `lsEditFixedList` (si sceglie solo fra le voci) e `ClearKey` = `VK_DELETE` (il tasto Canc svuota il campo);
- falso: `DropDownListStyle` = `lsEditList` (si può scrivere un valore che non è in elenco) e `ClearKey` = 0.
Gli altri campi predefiniti di una ricerca nuova: `IsForeignKey` vero, `Exists` vero, `IgnoreFieldReadOnly` vero.

### Scenario: elenco chiuso
- **Dato** una ricerca con `OnlyFromLookup` vero
- **Quando** si chiama `InitLookup`
- **Allora** l'utente può solo scegliere, e Canc svuota il campo

## ZBASE-LKP-005 Aspetto e pulsanti dei lookup
`InitLookup` applica prima l'aspetto standard (`InitProperties`), poi le regole di ZBASE-LKP-004. Valori impostati:
- tutti i lookup: 10 righe visibili (`DropDownRows`), elenco ridimensionabile (`DropDownSizeable`), filtro mentre si digita disattivato (`IncrementalFiltering` falso), `Revertable` vero, `ImmediatePost` vero, `PostPopupValueOnTab` falso, caratteri validi con in più `.` e `,` (per le chiavi numeriche);
- tendina semplice: `ListOptions.ColumnSorting` falso, `ListOptions.SyncMode` vero, `GridMode` falso;
- tendina a griglia: `GridMode` vero (altrimenti carica tutto il dataset), `UseMouseWheel` falso, `DropDownAutoSize` falso (la larghezza la decide il best fit, ZBASE-LKP-011).
Pulsanti: se l'editor ha un solo pulsante (la freccia), se ne aggiunge uno `bkEllipsis` (indice 1); con `HyperLink` vero se ne aggiunge un terzo (indice 2) con l'icona della lista `Glyphs`. Se l'editor ha già più di un pulsante non se ne aggiungono. `OnButtonClick` va a `LookupComboButtonClick` (ZBASE-LKP-013). Il parametro `AggiungiCancella` (`AddClearButton`) è accettato ma non ha nessun effetto (DIV-LKP-1); `HyperLink` sulla tendina semplice è difettoso (DIV-LKP-2).

### Scenario: pulsanti standard
- **Dato** un combo a griglia con il solo pulsante di discesa
- **Quando** si chiama `InitLookup` con `HyperLink` falso
- **Allora** i pulsanti sono due: freccia e «...»

### Scenario: pulsante di collegamento
- **Dato** lo stesso combo
- **Quando** si chiama `InitLookup` con `HyperLink` vero
- **Allora** i pulsanti sono tre e il terzo mostra l'icona 0 di `Glyphs`

## ZBASE-LKP-006 La vista della tendina a griglia
`CreateGridDBTableView(Archivio, DataSource, Chiave)` crea nell'archivio di viste indicato una `TcxGridDBTableView` per la tendina: modo a blocchi (`GridMode` vero) con blocco fisso di 100 record (`GridModeBufferCount`, Mantis #303: i lookup piccoli stanno tutti in memoria, quelli grandi si caricano a blocchi), nessun riquadro di raggruppamento, larghezza colonne non automatica (altrimenti `ApplyBestFit` non funziona), selezione di riga (non di cella). Il `DataSource` e la chiave si assegnano al `DataController`. Alla vista si agganciano `OnCanFocusRecord` e `OnCellClick` (ZBASE-LKP-010) e un `TLookupViewProps` (ZBASE-LKP-010) proprietà della vista stessa.
`InitLookup` a griglia, prima di crearla, **libera** la vista già assegnata alle `Properties` (se c'è), poi la crea nell'archivio passato dal chiamante o, se manca, in quello del modulo `Tdx`, la svuota e ne crea le colonne da tutti i campi del dataset (`CreateAllItems`). Chiave e colonne si assegnano dopo la creazione delle colonne. Alla fine `ListFieldItem` (la colonna che il combo mostra quando si sceglie) dovrebbe essere la prima colonna di `ListFieldNames`, altrimenti la chiave, altrimenti la prima colonna visibile (DIV-LKP-3).

### Scenario: rieseguire InitLookup
- **Dato** un combo a griglia già inizializzato
- **Quando** si richiama `InitLookup` sullo stesso combo
- **Allora** la vista precedente viene liberata e sostituita da una nuova, senza vista orfana nelle `Properties`

## ZBASE-LKP-007 Colonne della tendina a griglia
`InitLookupColumns(IdLookup, Properties, DataSet)` (forma a griglia) fa quanto segue sulla vista già creata; senza vista esce senza fare nulla.
- Tutte le didascalie delle colonne passano per `CapFirst` (iniziale maiuscola).
- Se la ricerca esiste nel dizionario (`Base.zLookups.Get(IdLookup, False)`), si carica una copia della vista del dizionario che ha il nome `zLookup.DbView`. Se la vista esiste, i campi mostrati sono le prime 10 colonne visibili della vista che esistono davvero nel dataset (`ComboColumns`); se non esiste, sono le `DisplayColumns` della ricerca. Un risultato vuoto lascia i campi già impostati.
- Poi si applicano alle colonne della griglia didascalie, ordine, visibilità e larghezze salvate nella vista (`AssignToGridColumns`).
- Mantis #303: la larghezza salvata di una colonna (se maggiore di zero) diventa il tetto del ricalcolo automatico (`BestFitMaxWidth`); le colonne senza larghezza salvata (−1) restano libere (`BestFitMaxWidth` = 0).
- Se `Base` è nulla o la ricerca non esiste, le colonne restano com'erano alla creazione.
Con il dataset chiuso e senza campi persistenti, la vista copiata perde tutte le colonne (nessuna esiste nel dataset), `ComboColumns` restituisce vuoto, e i campi mostrati restano quelli già impostati (le colonne di `GetListFieldNamesForCombo`). Se la vista non è nel dizionario, `LoadFromBase` ne aggiunge una vuota al dizionario in memoria (DIV-LKP-9).

### Scenario: larghezza salvata
- **Dato** una vista del lookup con la colonna `DESCRIZIONE` di larghezza salvata 180
- **Quando** si inizializza il lookup
- **Allora** la colonna ha `BestFitMaxWidth` 180 e può essere più stretta ma non più larga di 180 dopo il best fit

### Scenario: dataset chiuso
- **Dato** un dataset non aperto
- **Quando** si inizializza un lookup a griglia
- **Allora** la tendina usa le colonne indicate dal chiamante (`DisplayColumns`) e non solleva errori

## ZBASE-LKP-008 Colonne della tendina semplice
`InitLookupColumns(IdLookup, Properties, DataSet)` (forma semplice) richiede `DataSet` assegnato. Usa come vista il nome `IdLookup` (non `zLookup.DbView`, DIV-LKP-8). Se la vista esiste nel dizionario, i campi mostrati sono le colonne visibili della vista (come nella forma a griglia); un errore in questa fase (ad esempio un indice fuori limite sulla vista) viene registrato nel diario e non interrompe. Per ogni colonna già presente in `ListColumns` e descritta nella vista: didascalia presa dalla vista se non vuota, larghezza presa dalla vista o, se vale −1, `FieldSize(campo) × larghezza di un carattere` (50 senza campo). Se `ListColumns` è vuoto, si creano le colonne dai **primi tre campi** del dataset, con didascalia `DisplayLabel` e larghezza calcolata allo stesso modo (nome campo, DIV-LKP-7). Con il dataset chiuso senza campi non si crea nessuna colonna.
`FieldSize` restituisce, per i testi, 20, 50 o 100 secondo la lunghezza del campo (fino a 20, da 21 a 50, oltre), 5 per i logici, 999 per blob, memo e grafici, 20 negli altri casi non numerici.

### Scenario: nessuna colonna indicata
- **Dato** un dataset aperto con sei campi
- **Quando** si inizializza una tendina semplice senza colonne
- **Allora** si mostrano i primi tre campi

## ZBASE-LKP-009 Apertura della tendina a griglia
All'apertura del popup (`OnPopup`, non `OnInitPopup`: lì la vista non è ancora nella griglia del popup) `LookupInitPopup` agisce solo su un `TcxCustomExtLookupComboBox` con vista; altrimenti esce. Fa questo: riattiva sulla vista la selezione (`AllowSelect` vero) e il best fit (`AllowApplyBestFit` vero); registra il popup come quello corrente (ZBASE-LKP-012); aggancia `OnFocusedRecordChanged`; imposta su ogni colonna `MinWidth` = 20 (il minimo della sessione precedente non deve restare); chiama `LookupApplyBestFit` con `BestFitMaxRecordCount` = `DropDownRows` (10), oppure 1 se il valore del combo è nullo (il motivo non è dichiarato nel codice). Dal 2026-10-05 le misure si calcolano subito, non più con un rinvio di 100 ms.

### Scenario: combo vuoto
- **Dato** un combo a griglia con valore nullo
- **Quando** si apre il popup
- **Allora** il best fit calcola il contenuto su una sola riga

## ZBASE-LKP-010 Regole di selezione delle righe
Ogni vista della tendina porta un `TLookupViewProps` (nel campo `Tag`) con due interruttori, predefiniti veri: `AllowSelect` (si può spostare la riga corrente) e `AllowApplyBestFit` (si può eseguire il best fit).
- `LookupGridViewCanFocusRecord` risponde con `AllowSelect`; per una vista senza `TLookupViewProps` (altra vista) risponde vero. Gli accessori `LookupGridViewAllowSelect(Vista, Predefinito)` e `LookupGridViewAllowApplyBestFit(Vista, Predefinito)` restituiscono l'interruttore, o `Predefinito` se la vista non ha le proprietà; i `Set` non fanno nulla in quel caso.
- `LookupGridViewCellClick` mette `AllowSelect` a falso: dopo il clic su una riga il cursore non può più cambiare record prima che il valore arrivi al dataset (altrimenti scorrendo con la rotella il record corrente del dataset cambierebbe prima di `OnEditValueChanged`). Si riattiva alla prossima apertura (ZBASE-LKP-009).
- `LookupGridViewCanSelectRecord` e `LookupGridViewSelectionChanged` esistono ma non sono agganciati a nessuna vista (DIV-LKP-10).

### Scenario: clic su una riga
- **Dato** un popup aperto
- **Quando** l'utente fa clic su una riga
- **Allora** `AllowSelect` diventa falso e nessun altro spostamento di riga è accettato fino alla riapertura

## ZBASE-LKP-011 Adattare la finestra al contenuto
`LookupApplyBestFit(Vista, MassimoRecord)` si esegue solo se `AllowApplyBestFit` è vero e la vista ha un sito dentro una finestra. Durante l'esecuzione mette `AllowApplyBestFit` a falso (si ripristina sempre alla fine), così gli eventi di cambio riga generati dal calcolo non la rilanciano. Regole:
- calcola il best fit con `BestFitMaxRecordCount` = massimo fra il parametro e le righe visibili, senza cursore a clessidra; ogni colonna prende come `MinWidth` il maggiore fra il suo minimo e la larghezza calcolata: nel corso di una stessa apertura la finestra non si restringe;
- larghezza finale: intestazione + barra di scorrimento verticale + 3 pixel, ma mai meno della larghezza del combo (es. un progetto con descrizioni corte non sta più stretto del campo);
- posizione sinistra: quella del popup; se vale 0 (accade nei wizard, dove DevExpress porta la X a 0) quella del combo sullo schermo;
- altezza: righe intere, `min(record, DropDownRows)` con minimo 1, più bordi e maniglia, più la barra orizzontale se visibile (Mantis #303: prima l'altezza restava quella del popup e l'ultima riga poteva restare tagliata); se il popup si apre sopra il combo il bordo inferiore resta attaccato al combo;
- ridimensiona il popup con il controllo di misura bloccato (`LockCheckSize`).
`LookupFocusedRecordChanged` (cambio della riga evidenziata) rilancia il best fit con `-1` dopo 30 ms, solo se `AllowApplyBestFit` è vero e il popup registrato è ancora valido (ZBASE-LKP-012) e usa la stessa vista del chiamante.

### Scenario: elenco corto
- **Dato** un lookup con 2 record e `DropDownRows` 10
- **Quando** si apre il popup
- **Allora** il popup è alto 2 righe intere

### Scenario: combo largo
- **Dato** un combo largo 400 pixel con colonne che richiedono 250 pixel
- **Quando** si apre il popup
- **Allora** il popup è largo 400 pixel

## ZBASE-LKP-012 Guardia del popup e chiusura (Mantis #151)
Le chiamate rinviate (cambio riga) potrebbero arrivare dopo che il popup si è chiuso o la form è stata distrutta. `Tdx` tiene `FLookupPopupComboBox` (il combo del popup aperto) e un contatore `FLookupPopupGenerazione`:
- `LookupPopupRegistra` incrementa il contatore, ricorda il combo, si fa avvisare della sua distruzione (`FreeNotification`) e restituisce il numero; se c'era un altro combo registrato, ne toglie l'avviso;
- `LookupPopupDimentica` incrementa il contatore, toglie l'avviso e azzera il riferimento;
- `Notification` (distruzione del combo registrato) azzera il riferimento e incrementa il contatore;
- `LookupPopupAncoraValido(N)` è vero solo se N è il contatore corrente, il combo è registrato, è ancora aperto (`DroppedDown`) e ha una vista.
`LookupCloseUp` (`OnCloseUp`): esce se il mittente non è un combo a griglia; toglie `OnFocusedRecordChanged` dalla vista se c'è; se il combo è quello registrato, lo dimentica (così le chiamate in coda scadono).

### Scenario: chiusura prima del rinvio
- **Dato** un cambio riga accodato con generazione 7
- **Quando** il popup si chiude (la generazione passa a 8) e il rinvio scatta
- **Allora** `LookupPopupAncoraValido(7)` è falso e il best fit non si esegue

## ZBASE-LKP-013 Pulsante «...» e finestra di scelta
`LookupComboButtonClick(Mittente, Indice)`:
- indice 0 (freccia): per un combo a griglia non ancora aperto, lo apre; per gli altri non fa nulla;
- indice 1 («...»): ricava dal combo campo dati, `DataSource`, chiave e colonne; se il `DataSource` manca o il suo dataset non è un `TzFbDataSet`, esce senza avvisare; altrimenti clona il dataset (nome `LK_<nome>`, `IdDataSet` uguale, `AutoCommit` vero, `UseSqlLocate` vero, `MantieniElencoSeNonTrova` vero, parametri copiati), lo apre se ha una `SELECT`, e mostra `TzDbViewDlg` con il lookup `IdDataSet`; se l'utente conferma, rilegge il valore della chiave dal clone, richiama `InitLookup` con `IdLookup` vuoto (e `HyperLink` vero se i pulsanti sono più di due) e assegna e invia il valore al combo (`EditValue` e `PostEditValue`); il clone viene chiuso e liberato in ogni caso. Per un combo a griglia, a prescindere dall'esito, le colonne si rileggono dalla vista (`InitLookupColumns`, Mantis #303): le sistemazioni fatte nella finestra valgono subito;
- indice 2 e oltre: nessuna azione.

### Scenario: scelta dalla finestra completa
- **Dato** un combo a griglia con valore vuoto
- **Quando** l'utente preme «...» e conferma il record 15 nella finestra
- **Allora** il combo ha come valore la chiave del record 15 e le colonne della tendina sono quelle aggiornate nella finestra

## ZBASE-LKP-014 Liste di valori (picklist) sulle caselle
Una picklist (`TzPickList`) è un elenco di voci `Nome` (testo mostrato), `Value` (valore salvato) e `ImageIndex` (icona, −1 senza icona).
- `TzPickList.AssignToProps(Properties)` (casella immagine): svuota le voci della casella e ne aggiunge una per voce, nello stesso ordine, con `Description` = nome, `Value` = valore, `ImageIndex` = icona. Una picklist vuota svuota la casella.
- `Tdx.AssignPickList(Properties, Lista)`: nessuna azione se `Properties` o `Lista` sono nulle; per una casella immagine fa come `AssignToProps`; per un gruppo di pulsanti di scelta (`TcxRadioGroupProperties`) svuota e riempie gli elementi con `Caption` = nome e `Value` = valore; per qualunque altra casella di testo con elenco (`TcxCustomTextEditProperties`) imposta `LookupItems` con i **soli valori**, uno per riga (i nomi non compaiono); per altri tipi di `Properties` non fa nulla.
- `Tdx.InitPickList(Properties, NomeLista)`: cerca la picklist per nome nel dizionario (`Base.zPickLists`, senza crearla); se c'è la applica con `AssignToProps`; se non c'è non cambia le voci (le voci già presenti restano). In ogni caso, se la casella aveva già una lista di icone (`Images`), questa viene sostituita da `Immagini` (la lista unica delle icone di zPack); `LargeImages` viene azzerata. Una casella senza `Images` resta senza icone.
- `InitProperties` per tipo `ctPickList`: `Images` nulla (altrimenti il testo si sposta a destra) e `ImmediatePost` vero; per `ctPickListImage`: `Images` = `Immagini` e `ImmediatePost` vero. `InitProperties` con dominio e campo, se il dominio ha una picklist esistente, la applica con `AssignPickList`; se il nome non esiste nel dizionario non applica nulla e senza avviso.
- `TzPickList.AsText` restituisce i valori, ciascuno seguito da `#13`; `AssignToStrings` aggiunge una riga `Nome=Valore` per voce.

### Scenario: stati di una pratica
- **Dato** la picklist `STATI_PRATICA` con le voci `Aperta=A` (icona 3) e `Chiusa=C` (senza icona)
- **Quando** si chiama `InitPickList(combo.Properties, 'STATI_PRATICA')`
- **Allora** la casella ha due voci: `Aperta` con valore `A` e icona 3, `Chiusa` con valore `C` e icona −1

### Scenario: picklist inesistente
- **Dato** una casella con una voce `Prova`
- **Quando** si chiama `InitPickList(combo.Properties, 'NON_ESISTE')`
- **Allora** la voce `Prova` resta e nessun errore viene segnalato (DIV-LKP-15)

## ZBASE-LKP-015 Voce «Tutti» dei filtri
La costante `ImmagineVoceTutti` (554) è l'indice, nella lista unica `Immagini`, del pallino grigio della voce «Tutti». I filtri a picklist (`WT_Filters.pas` di WT, `Gesty_Filters.pas` di Gesty, `zTicser_Filters.pas` di zTicser, `dmTools.pas` di WT) dopo `InitPickList` aggiungono in testa una voce con descrizione «Tutti» (o il testo del filtro), `Value` nullo e `ImageIndex` = `ImmagineVoceTutti`, solo se il filtro ammette il valore nullo. La voce non è creata da `zDX`: lo stesso blocco è ripetuto nei quattro punti (DIV-LKP-12).

### Scenario: filtro con «Tutti»
- **Dato** un filtro a picklist che ammette il valore nullo
- **Quando** si costruisce il filtro
- **Allora** la prima voce è «Tutti» con valore nullo e il pallino grigio

## ZBASE-LKP-016 Dati assenti: cosa succede
Riepilogo dei casi limite verso chi chiama:
- `IdLookup` sconosciuto con dataset valido: la ricerca nasce al volo (ZBASE-LKP-002), nessun errore;
- `IdLookup` vuoto e `DataSet.IdDataSet` vuoto: `GetLookup` non trova il nome, `TzCollection.Get` restituisce nulla e la riga successiva legge `IsNew` di un oggetto nullo (violazione di accesso, DIV-LKP-4);
- `DataSet` o `DataSource` nulli: `Assert` (ZBASE-LKP-001);
- dataset chiuso: tendina a griglia con le colonne indicate dal chiamante, tendina semplice senza colonne se non indicate (ZBASE-LKP-007 e ZBASE-LKP-008); la tendina si riempie quando il dataset si apre, perché la vista e il `DataSource` sono già collegati;
- vista non presente nel dizionario: si usa l'elenco di colonne del chiamante, e il dizionario in memoria riceve una vista vuota con quel nome (DIV-LKP-9);
- picklist non trovata: nessuna voce assegnata, nessun avviso (ZBASE-LKP-014);
- combo che non è del tipo atteso nei gestori (`LookupInitPopup`, `LookupCloseUp`, `LookupComboButtonClick`): esce senza fare niente.

### Scenario: lookup con dataset chiuso
- **Dato** un dataset che non è stato aperto e un `IdLookup` nuovo
- **Quando** si chiama `InitLookup` a griglia
- **Allora** non ci sono errori, la ricerca esiste nel dizionario e la tendina mostra le colonne passate al chiamante

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-LKP-1 🟢 (dedotta) | `AddClearButton` è accettato da `InitLookup` a griglia ma il corpo non lo legge (resta il commento «AddClearButton da gestire»); nessun sorgente di WT, Gesty e zPack cita il nome | Passare `True` non aggiunge nessun pulsante di cancellazione: chi lo facesse si aspetterebbe un pulsante che non c'è |
| DIV-LKP-2 🟡 (dedotta) | `InitLookup` semplice con `HyperLink` vero chiama `InitProperties(ctLookupHyperLink, ...)`, che per quel tipo converte le `Properties` in `TcxExtLookupComboBoxProperties` senza controllo anche se sono quelle di una tendina semplice; nel ramo `ctLookup` il test `if ControlType = ctLookupHyperLink` non è mai vero (codice morto) | Con `HyperLink` vero su un `TcxLookupComboBox` si scrivono proprietà della tendina a griglia su un oggetto di classe diversa: valori fuori posto o violazione di accesso. Oggi nessun percorso vivo ci arriva: `zDbCard` ottiene dalla tabella dei tipi una tendina a griglia per `ctLookupHyperLink`, e `TzFormBuilder.AddLookupComboHyperLink` (che chiama la forma semplice con `True`) non ha chiamanti |
| DIV-LKP-3 🟡 (dedotta) | La funzione locale `GetListFieldItem` di `InitLookup` a griglia, se non trova né la colonna dell'elenco né la chiave, assegna la prima colonna visibile direttamente a `ListFieldItem` e restituisce nullo; il chiamante poi esegue `ListFieldItem := GetListFieldItem` e lo riporta a nullo | Il ripiego «prima colonna visibile» è annullato subito: con colonne e chiave non presenti nella vista il combo non ha colonna da mostrare |
| DIV-LKP-4 🟡 (dedotta) | `IdLookup` vuoto con `DataSet.IdDataSet` vuoto: `TzSystem.GetLookup` chiama `zLookups.Get('', True)`, che restituisce nullo per un nome vuoto, e poi legge `result.IsNew`. Gli `Assert` sui parametri nulli, inoltre, spariscono nelle compilazioni senza asserzioni | Violazione di accesso invece di un messaggio comprensibile; dataset creati da codice senza `IdDataSet` e usati con `IdLookup` vuoto falliscono così |
| DIV-LKP-5 🟡 (dedotta) | Dopo la finestra di scelta, `LookupComboButtonClick` richiama `InitLookup('', ...)` e `InitLookupColumns(comboDataSet.IdDataSet, ...)` con il nome del dataset, non con l'`IdLookup` usato in origine | Per un lookup creato con un `IdLookup` diverso dall'`IdDataSet` (per esempio `RC_Ingiunzioni_NuovoInvioAtto_IdInvio`) la ricerca cercata è un'altra: le colonne sistemate nella finestra non si rileggono (`Get(..., False)` restituisce nulla) e, se non esiste, nasce una ricerca con il nome del dataset |
| DIV-LKP-6 🟡 (dedotta) | La forma semplice di `InitLookup` non assegna mai le colonne ricavate da `GetListFieldNamesForCombo` o dal parametro `Colonne`: `InitLookupColumns` imposta `ListFieldNames` solo se la vista del dizionario esiste, altrimenti si ricade sui primi tre campi del dataset | Su un combo semplice, il parametro `Colonne` (per esempio `'METODO_SPEDIZIONE;DESC_METODO_SPEDIZIONE'`) non determina le colonne mostrate se la vista del lookup non è nel dizionario; si vedono i primi tre campi del dataset, non quelli chiesti |
| DIV-LKP-7 🟢 (dedotta) | Nel ripiego «primi tre campi» la forma semplice assegna `Column.FieldName := Field.Name`, cioè il nome del componente campo, non `Field.FieldName` | Il nome del componente coincide con il nome del campo solo per i campi persistenti con nome standard; per un campo creato in apertura potrebbe essere vuoto o prefissato dal nome del dataset, e la colonna resterebbe senza dati |
| DIV-LKP-8 🟢 (dedotta) | La forma semplice di `InitLookupColumns` carica la vista col nome `IdLookup`, la forma a griglia con `zLookup.DbView` | Un lookup il cui `DbView` è diverso dal nome (cosa che `GetLookup` evita per i lookup nuovi, ma non per quelli del dizionario) mostra colonne diverse nei due tipi di combo |
| DIV-LKP-9 🟡 (dedotta) | `TzDbViewProps.LoadFromBase`, usata da entrambe le `InitLookupColumns`, quando la vista non esiste la salva vuota nel dizionario in memoria (`SaveToBase(False)`) | Ogni lookup inizializzato lascia nel dizionario una vista vuota col suo nome, anche senza che nessuno l'abbia configurata; la vista compare poi nell'elenco delle viste e può finire nell'archivio LZ al primo salvataggio completo |
| DIV-LKP-10 🟢 (dedotta) | `LookupGridViewCanSelectRecord` e `LookupGridViewSelectionChanged` non sono agganciati a nessuna vista (le righe di `CreateGridDBTableView` sono commentate); in fondo ai gestori resta un blocco commentato della vecchia `LookupInitPopup` con rinvio | Codice morto che fa credere che la selezione sia controllata da due gestori in più; chi lo modifica non ottiene effetto |
| DIV-LKP-11 🟢 (dedotta) | Il commento in `CreateGridDBTableView` dice che le proprietà della vista sono distrutte «dal OnDestroy della view», ma `TLookupViewProps` ha come proprietario la vista (`Create(result)`) ed è distrutto dal distruttore della vista; il commento ha anche una lettera accentata rovinata (codifica) | Commento fuorviante: nessun gestore `OnDestroy` esiste nel codice |
| DIV-LKP-12 🟡 (dedotta) | `ImmagineVoceTutti` vale 554 scritto a mano, mentre `IndiceIcona('nome')` esiste proprio perché gli indici cambiano quando il catalogo delle icone si rigenera; il blocco che aggiunge la voce «Tutti» è copiato in quattro file | Se il catalogo si rigenera e l'indice si sposta, i filtri mostrano un'altra icona senza nessun errore; la correzione va fatta in quattro punti |
| DIV-LKP-13 🟡 (dedotta) | Se il chiamante non passa un archivio di viste, `InitLookup` a griglia crea la vista nell'archivio del modulo `Tdx`, che vive quanto il programma, e nessuna routine di `zDX` libera mai quelle viste alla chiusura della form | Memoria che cresce a ogni apertura di una form con lookup a griglia; ogni vista conserva il riferimento a un `DataSource` che può appartenere a una form già chiusa |
| DIV-LKP-14 🟢 (dedotta) | `InitLookup` a griglia libera con `View.Free` la vista assegnata alle `Properties` prima di crearne una nuova, senza controllare che non sia condivisa con altri combo (per esempio una vista disegnata nel DFM) | Se due combo condividono la vista, il secondo `InitLookup` distrugge la vista dell'altro |
| DIV-LKP-15 🟢 (dedotta) | `InitPickList` con un nome inesistente (o vuoto) non fa niente e non avvisa; non svuota nemmeno le voci già presenti | Un errore di battitura nel nome di una picklist produce una casella senza voci, o con le voci vecchie, senza nessun segnale: lo si scopre solo guardando la form |
| DIV-LKP-16 🟡 (dedotta) | `TzCollectionItem.IsNew` resta vero dalla creazione fino al salvataggio dell'archivio LZ (`ItemSaved`), e `GetLookup` sovrascrive nome, dataset, vista, chiave e colonne ogni volta che trova `IsNew` vero | Due `InitLookup` con lo stesso `IdLookup` nella stessa sessione, prima di un salvataggio, si sovrascrivono: vale l'ultimo chiamante, non il primo, e l'altro editor dipende da dati che non sono più i suoi |
| DIV-LKP-17 🟢 (dedotta) | `LookupGridViewAllowApplyBestFit` racchiude la lettura in un `try/except` vuoto; le altre tre routine di accesso a `TLookupViewProps` no | Un `Tag` che punta a un oggetto già distrutto viene ignorato in silenzio solo in una delle quattro routine; il difetto si sposta altrove |

---
area: Raccolta dei dataset
progetto: zCommon
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/002
---

# Raccolta dei dataset

Questa specifica descrive il componente `TdbMaster`, con la collezione `TDataSetCollection` e le sue voci `TDataSetItem` (`zCommon\dbMaster.pas`, 549 righe). `TdbMaster` tiene un elenco di dataset e permette di aprirli, chiuderli, salvarli, annullarli e aggiornarli tutti insieme, con eventi prima e dopo ogni operazione, sia per l'intero componente sia per la singola voce. La unit è compilata dai pacchetti `zBase_Common_*` di zCommon (entra per `zCommon_Register`, che registra il componente nella tavolozza `zCommon` e il suo editor `TdbMasterEditor` di `dbMasterCompEd.pas`, fuori da questa specifica). Il codice nasce da un componente di terzi del 1998 (intestazione: «TdbMaster (C)opyright 1998 Version 1.0, Author: Jeff Swim») ed è stato modificato in casa: la licenza originale non risulta altrove nei sorgenti e andrebbe verificata prima di una distribuzione esterna.

Chi lo usa. Il componente non compare nelle form: sta **una sola volta**, sul modulo dati di base di ciascuna applicazione (`Base_DbDataModule.dfm` di WT, WinSinfo e ShareFood; `Base_DataModule.dfm` di Gesty e zTicser), con `AutoOpen = False`, `AutoClose = False`, `OnOpenProgress = dbMasterOpenProgress` e `OnClose = ocPost`. Gli altri moduli dati lo ereditano: 211 DFM di WT e 30 di Gesty hanno un blocco `inherited dbMaster: TdbMaster` (alcuni sono copie o file di storia: 216 in tutto escluse le cartelle e i nomi «Copia», «prec», «rotti», «eliminat*», «OLD») che aggiunge solo le voci di `DataSets` (`DisplayName`, `DataSet` e `OnClose = ocPost`). In nessun DFM di `D:\AI\SRC` è collegato un evento `Before*` o `After*` del componente o di una voce, né `OnSlowDataSet`, né compare `AutoOpen`, `AutoClose` o `OpenInDesigner` diversi dal base: la parte a eventi e il caricamento automatico di `Loaded` non sono usati in produzione. Da codice, `dbMaster` è usato così, e solo così, in `TBaseDbDataModule` (WT, `Base_DbDataModule.pas`) e nel suo gemello `TBaseDataModule` (Gesty): `OpenAll` in `InternalOpenDataSets` (riga 514 in WT), `CloseAll` in `InternalCloseDataSets`, `PostAll` in `InternalCommit`, `CancelAll` in `InternalRollback`, `AddDataSet` quando crea i dataset dinamici in `GetDataSet`, `OnSlowDataSet := OnSlowDataSet` nel costruttore e il ciclo su `DataSets[I]` per leggere e cambiare `IncludeInOpen` (`AggiornaAutoOpen`, `TogliAutoOpen`, l'apertura manuale). **Nessuna** chiamata a `RefreshAll`, `IsModified`, `OpenCount` e `FindDataSetItem` in tutti i sorgenti (DIV-DBM-10).

**Come funziona.** Ogni voce lega un nome (`DisplayName`) a un `TDataSet` e a cinque interruttori (`IncludeInOpen`, `IncludeInClose`, `IncludeInPost`, `IncludeInCancel`, `IncludeInRefresh`, tutti veri all'inizio) più `OnClose`, che dice se alla chiusura una modifica in sospeso si salva (`ocPost`, predefinito) o si scarta (`ocCancel`). Le operazioni di gruppo scorrono le voci nell'ordine dell'elenco, saltano quelle senza dataset o escluse e, per ognuna, chiamano l'evento della voce prima e dopo; l'evento del componente scatta una volta all'inizio e una alla fine del giro. Il componente si fa avvisare (`FreeNotification`) della distruzione dei dataset e toglie da solo la voce del dataset distrutto. Gli eventi sono `TNotifyEvent`: il `Sender` dovrebbe essere il componente per gli eventi del componente e la voce per quelli di voce, ma tre eventi del componente passano un valore sbagliato (DIV-DBM-1 e DIV-DBM-2).

**Test che coprono quest'area.** Nessuna prova in `zPackTests` oggi. Il test `Test.dbMaster` prova tutti i requisiti con `TFDMemTable` (nessun database, nessuna finestra), tranne la segnalazione del messaggio all'apertura fallita (ZCOMMON-DBM-003), che chiama `ShowMessage` e non si può provare senza finestre. Le prove con prefisso `Divergenza_` descrivono il comportamento corretto e **falliscono** finché il codice non è corretto (DIV-DBM-1, 2, 3, 9 e 10).

## ZCOMMON-DBM-001 Componente, collezione e voci: valori iniziali e copia
`TdbMaster.Create` crea la collezione `DataSets` (classe `TDataSetCollection`, voci `TDataSetItem`, proprietario della collezione il componente) e imposta `AutoOpen = True`, `AutoClose = True`, `OpenInDesigner = False`. `OpenInDesigner` non viene salvata nel `.dfm` (`stored false`). `OnClose` del componente vale `ocPost` (primo valore dell'enumerazione), nessun evento è assegnato. Una voce nuova ha `DataSet = nil`, `DisplayName` vuoto, i cinque `IncludeIn*` veri, `OnClose = ocPost` e nessun evento. `TDataSetItem.Assign` ha lo scopo di copiare tutte le impostazioni pubblicate di una voce (dataset, interruttori, `OnClose`, i dieci eventi e `DisplayName`); `TdbMaster.DataSets := Altro.DataSets` (`SetCollection`) ha lo scopo di sostituire le voci con una copia di quelle di `Altro`. Dal rilascio 002 lo fa per intero (DIV-DBM-3 corretta); prima sollevava sempre `EConvertError`.

### Scenario: componente nuovo
- **Dato** un `TdbMaster` creato in esecuzione
- **Quando** si leggono le proprietà
- **Allora** `AutoOpen = True`, `AutoClose = True`, `OpenInDesigner = False`, `DataSets.Count = 0`, `OnClose = ocPost` e nessun evento è assegnato

### Scenario: voce nuova
- **Dato** una voce aggiunta con `DataSets.Add`
- **Quando** si leggono le proprietà
- **Allora** `DataSet = nil`, `DisplayName = ''`, `IncludeInOpen`, `IncludeInClose`, `IncludeInPost`, `IncludeInCancel` e `IncludeInRefresh` sono veri e `OnClose = ocPost`

### Scenario: copia di una voce
- **Dato** una voce con `IncludeInOpen = False`, `OnClose = ocCancel`, un evento `BeforeOpen` e `DisplayName = 'Origine'`
- **Quando** si chiama `Assign` su una voce nuova
- **Allora** `IncludeInOpen`, `OnClose` e `BeforeOpen` sono copiati
- **E** (voluto, oggi non vero) `DisplayName` diventa `'Origine'` e non si solleva nessuna eccezione

## ZCOMMON-DBM-002 Aggiungere e cercare voci
`AddDataSet(DisplayName, DataSet)` cerca prima una voce con quel nome e, se esiste, la restituisce **senza toccarla** (anche se il `DataSet` passato è un altro: DIV-DBM-9); altrimenti aggiunge una voce in coda, con quel nome e quel dataset (anche `nil`: la voce resta vuota e viene saltata da tutte le operazioni). `FindDataSetItem` confronta i nomi con `SameText`, quindi senza distinguere maiuscole e minuscole, e restituisce `nil` se non trova niente. È il modo in cui `GetDataSet` del modulo dati di base registra i dataset creati dai metadati LZ; subito dopo il chiamante regola `IncludeInOpen` secondo `ActivationMode = amAutomatic`.

### Scenario: dataset nuovo
- **Dato** un componente senza voci
- **Quando** si chiama `AddDataSet('Anagrafe', Dati)`
- **Allora** `DataSets.Count = 1`, la voce restituita è `DataSets[0]` con `DisplayName = 'Anagrafe'` e `DataSet = Dati`

### Scenario: nome già presente
- **Dato** una voce `'Anagrafe'` collegata a `Dati`
- **Quando** si chiama `AddDataSet('ANAGRAFE', Altro)`
- **Allora** viene restituita la voce esistente, `DataSets.Count` resta 1 e il suo `DataSet` resta `Dati`

### Scenario: ricerca senza distinzione di maiuscole
- **Dato** una voce `'Anagrafe'`
- **Quando** si chiama `FindDataSetItem('aNaGrAfE')` e poi `FindDataSetItem('Altro')`
- **Allora** la prima restituisce la voce e la seconda `nil`

## ZCOMMON-DBM-003 Apertura di tutti i dataset (`OpenAll`)
`OpenAll` chiama `BeforeOpen` del componente, poi per ogni voce, nell'ordine dell'elenco: fa girare `Application.ProcessMessages`, chiama `OnOpenProgress` (ZCOMMON-DBM-004), salta la voce se non ha dataset, e se `IncludeInOpen` è vero chiama `BeforeOpen` della voce, `DataSet.Open`, controlla i tempi (ZCOMMON-DBM-004) e chiama `AfterOpen` della voce; alla fine chiama `AfterOpen` del componente. Un dataset già aperto non dà errore (`Open` non fa niente), ma gli eventi della voce scattano comunque. Le voci con `IncludeInOpen = False` restano chiuse: è il meccanismo con cui i dataset ad attivazione manuale non si aprono all'avvio del modulo dati. Se `Open` solleva un'eccezione, `OpenAll` mostra `ShowMessage('Errore apertura dataset <nome>')` (finestra bloccante, anche fuori da un utente seduto) e rilancia l'eccezione: le voci successive restano chiuse e `AfterOpen` del componente non scatta (DIV-DBM-4). `OpenAll` scrive anche una riga con `OutputDebugString` per ogni apertura e una traccia SmartInspect (`SiMain`); entrambe sono innocue in un programma senza connessione.

### Scenario: apertura selettiva
- **Dato** tre voci: `'A'` con dataset, `'B'` con dataset ma `IncludeInOpen = False`, `'C'` senza dataset
- **Quando** si chiama `OpenAll`
- **Allora** il dataset di `'A'` è attivo, quello di `'B'` resta chiuso e non si solleva nessuna eccezione

### Scenario: ordine degli eventi
- **Dato** due voci `'A'` e `'B'` chiuse, con tutti gli eventi collegati
- **Quando** si chiama `OpenAll`
- **Allora** gli eventi scattano in questo ordine: `BeforeOpen` del componente, avanzamento di `'A'`, `BeforeOpen` e `AfterOpen` di `'A'`, avanzamento di `'B'`, `BeforeOpen` e `AfterOpen` di `'B'`, `AfterOpen` del componente

### Scenario: nessuna voce
- **Dato** un componente senza voci
- **Quando** si chiama `OpenAll`
- **Allora** scattano solo `BeforeOpen` e `AfterOpen` del componente

### Scenario: dataset già aperto
- **Dato** una voce il cui dataset è già attivo
- **Quando** si chiama `OpenAll`
- **Allora** il dataset resta attivo e scattano comunque `BeforeOpen` e `AfterOpen` della voce

## ZCOMMON-DBM-004 Avanzamento e dataset lenti
`OnOpenProgress(Sender, ItemName, ItemNo)` scatta **per ogni voce**, prima di controllare se ha un dataset e se `IncludeInOpen` è vero: quindi anche per le voci senza dataset e per quelle escluse. `ItemName` è il `DisplayName` e `ItemNo` l'indice della voce nell'elenco, **da zero** (il gestore di `TBaseDbDataModule` lo usa come indice in `dbMaster.DataSets[ItemNo]`). Dopo ogni apertura il componente misura il tempo con uno `TStopwatch`: se `Elapsed.Seconds` supera 3 (cioè dopo almeno quattro secondi pieni) scrive una traccia SmartInspect colorata e, se `OnSlowDataSet` è assegnato, lo chiama con il nome, il dataset e la durata come `TTimeSpan`. Il gestore di `TBaseDbDataModule.OnSlowDataSet` aggiunge una riga a `QueryLente.Log` con la query e i parametri del dataset, solo per i `TzFbDataSet`. Il confronto usa il componente «secondi» (0-59) e non il totale: oltre il minuto la soglia perde di significato (DIV-DBM-5). La concatenazione `' Tempo: ' + Stopwatch.Elapsed` di `OutputDebugString` compila perché `TTimeSpan` ha la conversione implicita a stringa e scrive il tempo in forma leggibile: non è un difetto.

### Scenario: avanzamento
- **Dato** tre voci `'A'`, `'B'` (esclusa dall'apertura) e `'C'` (senza dataset), con `OnOpenProgress` collegato
- **Quando** si chiama `OpenAll`
- **Allora** il gestore riceve `('A', 0)`, `('B', 1)` e `('C', 2)`, in questo ordine

### Scenario: dataset veloce
- **Dato** un dataset che si apre subito e `OnSlowDataSet` collegato
- **Quando** si chiama `OpenAll`
- **Allora** `OnSlowDataSet` non viene chiamato

### Scenario: dataset lento
- **Dato** un dataset la cui apertura dura più di quattro secondi
- **Quando** si chiama `OpenAll`
- **Allora** `OnSlowDataSet` è chiamato una volta con il nome della voce, il dataset e una durata di almeno quattro secondi

## ZCOMMON-DBM-005 Chiusura di tutti i dataset (`CloseAll`)
`CloseAll` chiama `BeforeClose` del componente e poi, per ogni voce con dataset, `IncludeInClose` vero e dataset **attivo**: chiama `BeforeClose` della voce, risolve una modifica in sospeso (stato `dsEdit` o `dsInsert`) secondo `OnClose` della **voce** (`ocPost` fa `Post`, `ocCancel` fa `Cancel`), chiude il dataset e chiama `AfterClose` della voce; infine `AfterClose` del componente. I dataset chiusi o esclusi e le voci senza dataset non producono eventi di voce. Se `Post` solleva un'eccezione (vincolo, evento `BeforePost` che rifiuta), `CloseAll` si interrompe: il dataset resta aperto in modifica, i successivi non vengono chiusi e `AfterClose` del componente non scatta (DIV-DBM-7). Non esiste un valore predefinito diverso a livello di componente: `TdbMaster.OnClose` è pubblicata ma `CloseAll` non la legge mai (DIV-DBM-8).

### Scenario: chiusura selettiva
- **Dato** due dataset attivi, `'A'` incluso e `'B'` con `IncludeInClose = False`, e una voce `'C'` con `DataSet = nil`
- **Quando** si chiama `CloseAll`
- **Allora** `'A'` è chiuso, `'B'` resta attivo e non si solleva nessuna eccezione

### Scenario: ordine degli eventi
- **Dato** due voci attive `'A'` e `'B'` con tutti gli eventi collegati
- **Quando** si chiama `CloseAll`
- **Allora** scattano `BeforeClose` del componente, `BeforeClose` e `AfterClose` di `'A'`, `BeforeClose` e `AfterClose` di `'B'`, `AfterClose` del componente

### Scenario: modifica in sospeso con `ocPost`
- **Dato** un dataset attivo in inserimento e la voce con `OnClose = ocPost`
- **Quando** si chiama `CloseAll`
- **Allora** il record è salvato (`Post` eseguito una volta, nessun `Cancel`) e il dataset è chiuso

### Scenario: modifica in sospeso con `ocCancel`
- **Dato** un dataset attivo in inserimento e la voce con `OnClose = ocCancel`
- **Quando** si chiama `CloseAll`
- **Allora** il record è scartato (`Cancel` eseguito una volta, nessun `Post`) e il dataset è chiuso

### Scenario: errore nel salvataggio
- **Dato** due dataset attivi, il primo in inserimento con un `BeforePost` che solleva un'eccezione
- **Quando** si chiama `CloseAll`
- **Allora** l'eccezione arriva al chiamante, il primo dataset resta attivo, il secondo non viene chiuso e `AfterClose` del componente non scatta

## ZCOMMON-DBM-006 Salvataggio di tutti i dataset (`PostAll`)
`PostAll` chiama `BeforePost` del componente (con il `Sender` sbagliato, DIV-DBM-1) e poi, per ogni voce con dataset, `IncludeInPost` vero, dataset attivo e stato `dsEdit` o `dsInsert`: `BeforePost` della voce, `DataSet.Post`, `AfterPost` della voce; infine `AfterPost` del componente (con `Self`). I dataset in navigazione, chiusi o esclusi non vengono toccati. Un'eccezione di `Post` interrompe il giro e si propaga. `TBaseDbDataModule.InternalCommit` lo chiama subito prima di chiudere le transazioni di scrittura, così le modifiche aperte nelle griglie finiscono nel database.

### Scenario: salvataggio selettivo
- **Dato** tre dataset attivi: `'A'` in inserimento, `'B'` in navigazione, `'C'` in inserimento ma con `IncludeInPost = False`
- **Quando** si chiama `PostAll`
- **Allora** `'A'` esce dall'inserimento con il record salvato, `'B'` resta com'è e `'C'` resta in inserimento

### Scenario: ordine degli eventi
- **Dato** una voce `'A'` in inserimento con tutti gli eventi collegati
- **Quando** si chiama `PostAll`
- **Allora** scattano `BeforePost` del componente, `BeforePost` e `AfterPost` di `'A'`, `AfterPost` del componente

## ZCOMMON-DBM-007 Annullamento di tutte le modifiche (`CancelAll`)
`CancelAll` ha la stessa struttura di `PostAll` con `Cancel` al posto di `Post`, `IncludeInCancel` al posto di `IncludeInPost` e gli eventi `BeforeCancel` e `AfterCancel`; `BeforeCancel` del componente riceve un `Sender` sbagliato (DIV-DBM-1). Non annulla le transazioni: `TBaseDbDataModule.InternalRollback` lo chiama prima di fare il rollback e di riaprire i `TzFbDataSet`.

### Scenario: annullamento selettivo
- **Dato** tre dataset attivi: `'A'` in inserimento, `'B'` in navigazione, `'C'` in inserimento ma con `IncludeInCancel = False`
- **Quando** si chiama `CancelAll`
- **Allora** `'A'` torna in navigazione senza il record nuovo, `'B'` resta com'è e `'C'` resta in inserimento

### Scenario: ordine degli eventi
- **Dato** una voce `'A'` in inserimento con tutti gli eventi collegati
- **Quando** si chiama `CancelAll`
- **Allora** scattano `BeforeCancel` del componente, `BeforeCancel` e `AfterCancel` di `'A'`, `AfterCancel` del componente

## ZCOMMON-DBM-008 Aggiornamento di tutti i dataset (`RefreshAll`)
`RefreshAll` chiama `BeforeRefresh` del componente e poi, per ogni voce con dataset, `IncludeInRefresh` vero e dataset attivo: `BeforeRefresh` della voce, `DataSet.Refresh`, `AfterRefresh` della voce; infine `AfterRefresh` del componente, che riceve come `Sender` l'**ultima voce** esaminata (o un valore non definito se non ci sono voci) invece del componente (DIV-DBM-2). Nessun codice di WT e Gesty lo chiama (DIV-DBM-10). Il `Refresh` di un `TDataSet` con una modifica in sospeso la salva o la scarta da sé (`CheckBrowseMode`): non è una scelta di `TdbMaster`.

### Scenario: aggiornamento selettivo
- **Dato** due dataset attivi, il secondo con `IncludeInRefresh = False`, e un terzo chiuso
- **Quando** si chiama `RefreshAll`
- **Allora** `Refresh` è eseguito una volta sul primo e mai sugli altri

### Scenario: ordine degli eventi
- **Dato** una voce `'A'` attiva con tutti gli eventi collegati
- **Quando** si chiama `RefreshAll`
- **Allora** scattano `BeforeRefresh` del componente, `BeforeRefresh` e `AfterRefresh` di `'A'`, `AfterRefresh` del componente

## ZCOMMON-DBM-009 Modifiche in sospeso (`IsModified`)
`IsModified` (virtuale) scorre le voci con dataset attivo; se il dataset è in uno stato di modifica (`dsEditModes`) chiama `UpdateRecord`, che fa scrivere nel record i valori ancora nei controlli collegati, ingoiando **qualunque** eccezione (DIV-DBM-6); poi risponde vero alla prima voce con `Modified` vero oppure in stato `dsInsert`. Un inserimento appena aperto e mai toccato è quindi «modificato»; una modifica (`dsEdit`) senza campi cambiati no. Non guarda gli interruttori `IncludeIn*`: conta ogni dataset attivo, anche se escluso dal salvataggio. Nessun codice lo chiama: il modulo dati di base calcola `Modified` per conto suo.

### Scenario: nessuna voce
- **Dato** un componente senza voci
- **Quando** si chiama `IsModified`
- **Allora** il risultato è falso

### Scenario: inserimento appena aperto
- **Dato** un dataset attivo in `dsInsert` senza campi toccati
- **Quando** si chiama `IsModified`
- **Allora** il risultato è vero

### Scenario: modifica senza cambiamenti e con cambiamenti
- **Dato** un dataset attivo in `dsEdit`
- **Quando** si chiama `IsModified` prima e dopo aver cambiato un campo
- **Allora** il risultato è falso la prima volta e vero la seconda; dopo `Post` torna falso

### Scenario: dataset chiusi o senza dataset
- **Dato** una voce senza dataset e una voce con dataset chiuso
- **Quando** si chiama `IsModified`
- **Allora** il risultato è falso e non si solleva nessuna eccezione

### Scenario: errore di `UpdateRecord`
- **Dato** un dataset in inserimento con un campo cambiato e una `TDataSource` il cui `OnUpdateData` solleva un'eccezione
- **Quando** si chiama `IsModified`
- **Allora** l'eccezione non arriva al chiamante e il risultato è vero

## ZCOMMON-DBM-010 Numero di dataset da aprire (`OpenCount`)
`OpenCount` è pensata per dire quanti dataset aprirà `OpenAll` (per una barra di avanzamento). Il codice di oggi parte da 1 e aggiunge 1 per ogni voce con `IncludeInOpen` vero, anche se la voce non ha dataset: restituisce quindi **uno in più** (zero voci: 1) e conta voci che `OpenAll` salta (DIV-DBM-10). Nessun codice la chiama. Il comportamento atteso è il numero delle voci che `OpenAll` apre davvero.

### Scenario: nessuna voce
- **Dato** un componente senza voci
- **Quando** si chiama `OpenCount`
- **Allora** (voluto, oggi non vero) il risultato è 0

### Scenario: voci incluse ed escluse
- **Dato** due voci con dataset e `IncludeInOpen` vero e una con `IncludeInOpen` falso
- **Quando** si chiama `OpenCount`
- **Allora** (voluto, oggi non vero) il risultato è 2

## ZCOMMON-DBM-011 Dataset distrutto: la voce sparisce
Quando si assegna `DataSet` a una voce, il componente (proprietario della collezione) si fa avvisare della distruzione di quel dataset (`FreeNotification`); cambiando o azzerando il `DataSet` la notifica si toglie dal vecchio. Se un dataset viene distrutto (`opRemove`), `Notification` cerca la voce che lo contiene e la **elimina dalla collezione**, a meno che il componente stesso sia in distruzione. Funziona anche quando dataset e componente stanno sullo stesso modulo dati: il proprietario comune inoltra la notifica. Altri componenti e operazioni `opInsert` sono ignorati. Elimina solo la **prima** voce che trova: se lo stesso dataset compare in due voci, la seconda resta con un puntatore a un oggetto distrutto (DIV-DBM-9).

### Scenario: dataset senza proprietario
- **Dato** due voci `'A'` e `'B'` con due dataset senza proprietario
- **Quando** si distrugge il dataset di `'A'`
- **Allora** `DataSets.Count = 1` e resta la voce `'B'`

### Scenario: dataset sullo stesso modulo
- **Dato** un componente e un dataset con lo stesso proprietario
- **Quando** si distrugge il dataset
- **Allora** la sua voce è tolta dalla collezione

### Scenario: voce scollegata
- **Dato** una voce il cui `DataSet` è stato riportato a `nil`
- **Quando** si distrugge il dataset di prima
- **Allora** la voce resta nella collezione

### Scenario: dataset sostituito
- **Dato** una voce passata da un dataset `X` a un dataset `Y`
- **Quando** si distrugge `X` e poi `Y`
- **Allora** alla distruzione di `X` la voce resta; alla distruzione di `Y` è tolta

### Scenario: altro componente e inserimento
- **Dato** una voce con un dataset
- **Quando** `Notification` riceve `opRemove` di un componente che non è nell'elenco oppure `opInsert` del dataset
- **Allora** la collezione non cambia

## ZCOMMON-DBM-012 Apertura e chiusura automatiche e in fase di progetto
`Loaded` (chiamata dopo la lettura del `.dfm`) apre tutti i dataset con `OpenAll` se: in esecuzione e `AutoOpen = True`, oppure in fase di progetto (`csDesigning`) e `OpenInDesigner = True`. Con `AutoOpen = False`, come nel modulo dati di base, non apre niente. La distruzione chiama `CloseAll` se si è in esecuzione e `AutoClose = True`; in fase di progetto o con `AutoClose = False` lascia i dataset come stanno. `OpenInDesigner` si cambia solo in progetto: impostarla a vero apre tutti i dataset, a falso li chiude; in esecuzione la proprietà cambia valore e basta. In WT e in Gesty `AutoOpen` e `AutoClose` sono sempre falsi: apertura e chiusura le decide il modulo dati (`OpenDataSets`, `CloseDataSets`).

### Scenario: apertura automatica
- **Dato** un componente con `AutoOpen = True`, in esecuzione, e una voce con un dataset chiuso
- **Quando** viene chiamata `Loaded`
- **Allora** il dataset è attivo

### Scenario: apertura automatica spenta
- **Dato** un componente con `AutoOpen = False` e una voce con un dataset chiuso
- **Quando** viene chiamata `Loaded`
- **Allora** il dataset resta chiuso

### Scenario: fase di progetto
- **Dato** un componente in fase di progetto con `AutoOpen = True` e `OpenInDesigner = False`
- **Quando** viene chiamata `Loaded`
- **Allora** il dataset resta chiuso
- **E** impostando `OpenInDesigner := True` il dataset si apre, con `OpenInDesigner := False` si chiude

### Scenario: `OpenInDesigner` in esecuzione
- **Dato** un componente in esecuzione
- **Quando** si imposta `OpenInDesigner := True`
- **Allora** la proprietà vale vero e nessun dataset è stato aperto

### Scenario: distruzione con chiusura automatica
- **Dato** un componente con `AutoClose = True` (valore predefinito), in esecuzione, e un dataset attivo
- **Quando** il componente viene distrutto
- **Allora** il dataset è chiuso
- **E** con `AutoClose = False`, oppure in fase di progetto, il dataset resta attivo

## ZCOMMON-DBM-013 Eventi: ordine e `Sender`
Gli eventi sono `TNotifyEvent`. Quelli del componente ricevono come `Sender` il componente stesso (`Self`); quelli di voce ricevono la voce. Per ogni operazione di gruppo l'ordine è: evento `Before` del componente, per ogni voce `Before` e `After` della voce, evento `After` del componente (per `OpenAll` l'avanzamento di ogni voce precede il suo `BeforeOpen`). Tre eventi del componente non rispettano la regola: `BeforePost` (in `PostAll`) e `BeforeCancel` (in `CancelAll`) ricevono la variabile locale `item` **non ancora assegnata**, e `AfterRefresh` (in `RefreshAll`) l'ultima voce (DIV-DBM-1, DIV-DBM-2). Un gestore che usi il `Sender` di questi tre eventi legge un valore casuale o la voce sbagliata.

### Scenario: `Sender` corretto
- **Dato** una voce `'A'` e tutti gli eventi collegati
- **Quando** si esegue un giro completo di `OpenAll`, `PostAll`, `CancelAll`, `RefreshAll` e `CloseAll`
- **Allora** `BeforeOpen`, `AfterOpen`, `BeforeClose`, `AfterClose`, `AfterPost`, `AfterCancel` e `BeforeRefresh` del componente ricevono il componente
- **E** tutti i dieci eventi di voce ricevono la voce `'A'`

### Scenario: `Sender` dei tre eventi difettosi
- **Dato** una voce con un dataset in inserimento e `BeforePost` del componente collegato
- **Quando** si chiama `PostAll`
- **Allora** (voluto, oggi non vero) il `Sender` ricevuto è il componente; lo stesso per `BeforeCancel` con `CancelAll` e per `AfterRefresh` con `RefreshAll`

## ZCOMMON-DBM-014 Uso da parte dei moduli dati di base
Il contratto con le applicazioni è questo: il componente nel modulo dati di base ha `AutoOpen = False` e `AutoClose = False`; apertura (`OpenAll`), chiusura (`CloseAll`), salvataggio (`PostAll`) e annullamento (`CancelAll`) vengono chiamati solo dal modulo dati, mai dai moduli che lo ereditano; i dataset dinamici entrano con `AddDataSet(nome, dataset)` e la loro voce riceve `IncludeInOpen := ActivationMode = amAutomatic`, così all'apertura generale restano chiusi i dataset ad attivazione manuale; le voci dei dataset messi nel `.dfm` (`inherited dbMaster`) hanno `OnClose = ocPost`, quindi chiudere un modulo con una modifica aperta la salva (ma `CloseDataSets` è sempre preceduto da `CloseQuery`, che chiede «Salvo le modifiche?»). `OnOpenProgress` serve al registro diagnostico (SmartInspect) e `OnSlowDataSet` al file `QueryLente.Log`. I requisiti ZCOMMON-DBM-003, 004, 005, 006, 007 e 002 valgono quindi per ogni modulo dati di WT, Gesty, zTicser, WinSinfo e ShareFood.

### Scenario: dataset ad attivazione manuale
- **Dato** una voce creata con `AddDataSet` il cui `IncludeInOpen` è stato messo a falso
- **Quando** il modulo dati chiama `OpenAll`
- **Allora** il dataset resta chiuso e può essere aperto a mano con `DataSet.Open`

## Divergenze note
Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `dbMaster.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DBM-1 🟡 (dedotta) | `PostAll` chiama `BeforePost(item)` e `CancelAll` chiama `BeforeCancel(item)` **prima** del ciclo (righe 448-449 e 405-406), quando `item` è una variabile locale di classe mai assegnata; gli altri eventi del componente passano `Self` | Un gestore che usi il `Sender` (per esempio `Sender as TdbMaster`) legge un puntatore casuale e può andare in errore di protezione; oggi nessun DFM collega l'evento, quindi non è mai successo. Prova `Divergenza_BeforePost_...` e `Divergenza_BeforeCancel_...` (rosse) |
| DIV-DBM-2 🟢 (dedotta) | `RefreshAll` chiama `AfterRefresh(item)` (riga 490) invece di `AfterRefresh(Self)`: `item` è l'ultima voce del ciclo, oppure una variabile non assegnata se non ci sono voci | Il `Sender` non è il componente; con zero voci è un valore casuale. Prova `Divergenza_AfterRefresh_...` (rossa) |
| DIV-DBM-3 ✅ (corretta, rilascio 002) | `TDataSetItem.Assign` copiava i campi ma poi chiamava `inherited Assign(Source)` anche per sorgenti valide, e `TPersistent.Assign` sollevava `EConvertError`; `DisplayName` non era copiato. Ora copia anche `DisplayName` e chiama `inherited` solo per sorgenti di altro tipo | Copiare una collezione (`DataSets := ...`, copia dall'editor) funziona. Prove `Divergenza_Assign_*` e `Divergenza_AssegnaCollezione_*` attive (prima ignorate) |
| DIV-DBM-4 🟡 (dedotta) | `OpenAll` mostra `ShowMessage('Errore apertura dataset ...')` (riga 328) prima di rilanciare l'eccezione; `LeaveMethod` di SmartInspect e `Stopwatch.Stop` non sono in un `finally` (righe 295, 364) | In un contesto senza utente (utilità pianificate, test automatici, servizi) la finestra blocca il programma; chi chiama (`InternalOpenDataSets` in `try ... Application.HandleException`) mostra poi anche l'errore vero, quindi l'utente vede due messaggi. La traccia SmartInspect resta con un `EnterMethod` senza `LeaveMethod`. Non si può provare senza finestre |
| DIV-DBM-5 🟡 (dedotta) | Le soglie di lentezza usano `Stopwatch.Elapsed.Seconds` (righe 337-350), che in `TTimeSpan` è il resto dei secondi (0-59), non il totale | Un'apertura di 62 secondi legge `Seconds = 2`: nessuna traccia e `OnSlowDataSet` non scatta; una da 70 secondi segnala il colore azzurro (soglia 10) e mai il rosso (soglia 60, mai raggiunta); `LogInteger('Secondi')` scrive il resto. Letto in `System.TimeSpan.pas` (`GetSeconds`: `(FTicks div TicksPerSecond) mod 60`) |
| DIV-DBM-6 🟢 | `IsModified` ingoia ogni eccezione di `UpdateRecord` (righe 274-278) | Un errore di validazione dei controlli collegati sparisce e il risultato dipende solo da `Modified`. Funzione mai chiamata. Provata dal test `IsModified_ErroreInUpdateRecord_Ingoiato` |
| DIV-DBM-7 🟢 | `CloseAll`, `PostAll`, `CancelAll` e `RefreshAll` non hanno `try ... except`: un errore su una voce interrompe il giro (righe 367-398 e seguenti); il distruttore con `AutoClose` non libera `FDataSets` se `CloseAll` solleva (righe 238-241) | Le voci successive restano aperte o in modifica e gli eventi `After` del componente non scattano; il distruttore perde la collezione. Provata per `CloseAll` dal test `CloseAll_ErroreNelSalvataggio_...` |
| DIV-DBM-8 🟢 (dedotta) | `TdbMaster.OnClose` (righe 104, 130) è pubblicata e salvata nel `.dfm` ma nessun metodo la legge: `CloseAll` usa solo `item.OnClose`, e `AddDataSet` non la copia sulla voce | Chi imposta `ocCancel` sul componente si aspetta che valga come predefinito per tutte le voci e invece non succede niente. Nei DFM vale sempre `ocPost`, uguale al valore predefinito di ogni voce |
| DIV-DBM-9 🟢 | `Notification` elimina solo la prima voce del dataset distrutto (`break`, riga 534), e `AddDataSet` con un nome esistente restituisce la voce vecchia senza guardare il dataset passato (righe 247-250) | Se lo stesso dataset è in due voci, la seconda tiene un puntatore a un oggetto distrutto e `CloseAll` (o qualunque ciclo sulle voci) va in errore di protezione; con `AddDataSet` due chiamate con lo stesso nome e dataset diversi lasciano nella voce il primo dataset. Prova `Divergenza_Notifica_StessoDataSetInDueVoci_...` (rossa) e `AddDataSet_NomeEsistente_...` |
| DIV-DBM-10 🟢 | `OpenCount` parte da 1 (riga 543) e conta le voci con `IncludeInOpen` vero anche senza dataset; `RefreshAll`, `IsModified`, `OpenCount` e `FindDataSetItem` (salvo la chiamata interna da `AddDataSet`) non sono chiamati da nessun sorgente di WT, Gesty, zTicser, WinSinfo e ShareFood | `OpenCount` restituisce uno in più del numero dei dataset che `OpenAll` apre; le altre sono codice morto che sembra parte del contratto. Prove `Divergenza_OpenCount_*` (rosse) |
| DIV-DBM-11 🟢 | Residui di codice: il messaggio `'Opening Dataset: + '` ha un `+` di troppo (riga 319); `GetDisplayName` assegna `inherited GetDisplayName` e subito dopo lo sovrascrive (righe 166-167), quindi una voce nuova ha `DisplayName` vuoto invece del nome della classe; commenti `// ShowMessage(...)` e `// Stopwatch.IsHighResolution` lasciati in `OpenAll`; il blocco in testa al file riporta la licenza di terzi (Jeff Swim, 1998) | Nessun effetto sul funzionamento; la licenza di terzi va chiarita prima di una distribuzione esterna di zPack |

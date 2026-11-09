---
area: Controller dei form
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Controller dei form

Questa specifica descrive `TzFormController` e il suo aiutante `TLayoutController`, che costruiscono a video le form documentali di WT e Gesty a partire dal dizionario LZ: un `TdxLayoutControl` con un albero di menu, un gruppo per ogni dataset (con le schede dei suoi controlli e i dettagli), i controlli (`TzDbView`, `TzDbCard`, `TzDbPivot`, `TzDbRecordView`, `TzDbTree`, `TzDbChart`, `TzDbScheduler`, visualizzatori di file) e la personalizzazione salvata nell'LZ e nei file `.layout` di ogni postazione. Il codice è tutto in `zBase\zFormController.pas`. Lo usano `TBaseForm` di WT (`Wintarif_Group\_src\BASE\BaseFrm.pas`), di Gesty (`Gesty_Group\_Sorgenti\BASE\BaseFrm.pas`), di zTicser e di ShareFood (nel conteggio: 42 file di WT, 35 di Gesty, 7 di zTicser, 4 di ShareFood citano `FormController`); le singole form lo raggiungono quasi solo per `LayoutController.FindGroup`, `TabChangedProc` e `TabChangingProc`. Dentro zPack lo usano `zLocalizer` (traduzione), `zDfmLayoutArranger`, `zDxLayoutCustomizeFrm` (la finestra di personalizzazione, che arriva al controller tramite `zLayoutMaintenance`) e `zDx`. La unit è compilata (compare nei `uses` di `WinTarif3.dpr` e `Gesty.dpr`). Il controller **non** conosce lo stato di modifica dei dati e non chiede conferme: lo spiega ZBASE-FRM-010.

**Come funziona.** `TBaseForm` crea un `TzFormController` con la form come proprietaria, gli assegna `zSystem`, `CtrlOwner` e `CtrlParent` (la form stessa), e quando ha un modulo dati gli assegna `DataModule` e `zDataModule`. `CreateControls` legge `zDataModule.DataSets` e costruisce il `TdxLayoutControl` di nome `dxLayout`, con una struttura di gruppi dai nomi prevedibili; i controlli veri nascono solo quando la scheda che li ospita diventa attiva. Il layout salvato (`zDataModule.Layouts`, scritto nell'LZ da `SaveToBase`) si applica sopra la struttura canonica; le sole dimensioni di ciascuna postazione stanno invece in un file `.layout` accanto alla configurazione. Lo stato del controller sta in `TLayoutController` (`dxLayoutControl`, `TreeMenu`, `Comps`, dizionari interni dei gruppi e dei controlli); `TzFormController` inoltra le chiamate e gestisce eventi, timer e notifiche dei componenti.

**Test che coprono quest'area.** Nessuna prova in `zPackTests` oggi. Il test `Test.zFormController` prova senza mostrare finestre: i valori predefiniti, i ripieghi di `GetCtrlOwner` e `GetCtrlParent`, l'azzeramento dei componenti distrutti (ZBASE-FRM-001, 002), il fatto che `CreateControls` con `BuildGUI` falso non crei niente (ZBASE-FRM-003), le chiamate che non devono fare danni prima della costruzione (ZBASE-FRM-007, 008, 013, 017), l'interfaccia `IzLayoutMaintenance` senza conteggio dei riferimenti (ZBASE-FRM-013) e il resoconto delle risoluzioni (ZBASE-FRM-017). Restano senza prova la costruzione vera del layout, il salvataggio, il file `.layout`, il cambio di scheda e l'altezza automatica: servono un `TdxLayoutControl` con le sue dimensioni a video, un dizionario LZ vero e il database.

## ZBASE-FRM-001 Collegamento della form al controller
Il controller si crea con `TzFormController.Create(Proprietario)`; tutte le proprietà di collegamento sono vuote e `DesignWidth` e `DesignHeight` valgono 1920 e 1200 (riferimento delle dimensioni salvate nell'LZ, ZBASE-FRM-012). `GetCtrlOwner` restituisce `CtrlOwner` se assegnato, altrimenti il proprietario del controller; `GetCtrlParent` restituisce `CtrlParent` se assegnato, altrimenti il proprietario **se è un controllo a finestra**, altrimenti `nil`. Il layout e tutti i controlli creati hanno `GetCtrlOwner` come proprietario e `GetCtrlParent` come contenitore. `TBaseForm` assegna `zSystem := Config.zSystem`, `CtrlOwner := Self`, `CtrlParent := Self` e gli eventi `OnSelect`, `OnDatasetAssigned`, `OnAfterCreateControls`, `OnAfterCreateComponent` (Gesty anche `OnAfterLayoutControlLoadProps`); `DataModule` e `zDataModule` si assegnano quando la form ha il suo modulo dati e si rimettono a `nil` quando il modulo dati viene distrutto (`DestroyDataModule`). Prima di `CreateControls`, `SaveProps` o `AfterShow` servono `zDataModule` e (per il file `.layout`) `zSystem`: senza, le chiamate vanno in errore di accesso (DIV-FRM-3).

### Scenario: valori iniziali
- **Dato** un controller appena creato, senza proprietà assegnate
- **Quando** si leggono le proprietà
- **Allora** `DesignWidth = 1920`, `DesignHeight = 1200`, `SkipSelectFirstNode` falso, `CtrlOwner`, `CtrlParent`, `zSystem`, `zDataModule` nulli e `LayoutController` assegnato

### Scenario: ripiego sul proprietario
- **Dato** un controller il cui proprietario è una form e `CtrlOwner`, `CtrlParent` vuoti
- **Quando** si chiamano `GetCtrlOwner` e `GetCtrlParent`
- **Allora** entrambe restituiscono la form
- **E** se il proprietario è un componente non visivo, `GetCtrlParent` restituisce `nil`

## ZBASE-FRM-002 Componenti collegati che vengono distrutti
Quando un componente che condivide il proprietario del controller viene liberato, il gestore `Notification` rimette a `nil` `zSystem`, `CtrlOwner` o `CtrlParent` se erano quel componente; se è un elemento del layout (`TdxCustomLayoutItem`) avvisa il `LayoutController`, che toglie l'elemento dai suoi dizionari (menu, gruppi dei dataset, controlli). Durante la distruzione del controller le notifiche si ignorano. `DataModule` e `zDataModule` non si azzerano da sole (la riga relativa è commentata): le rimette a `nil` chi le ha assegnate. Il controller non chiama `FreeNotification`: l'azzeramento funziona solo per componenti con lo stesso proprietario (DIV-FRM-15).

### Scenario: contenitore distrutto
- **Dato** un controller e un pannello con lo stesso proprietario, `CtrlParent` = pannello
- **Quando** si libera il pannello
- **Allora** `CtrlParent` torna `nil` e `GetCtrlParent` ripiega sul proprietario

## ZBASE-FRM-003 Costruzione dei controlli
`TzFormController.CreateControls` non fa niente se `zDataModule.BuildGUI` è falso (valore predefinito di ogni `TzDataModule`: la form senza interfaccia generata non ha layout). Altrimenti: se la raccolta delle prestazioni è attiva attribuisce le misure al modulo (classe di `CtrlOwner` o nome del modulo dati); poi `LayoutController.DestroyControls` e `LayoutController.CreateControls`. `LayoutController.CreateControls` crea il `TdxLayoutControl` una volta sola (nome `dxLayout`, allineato `alClient`, contenitore `GetCtrlParent`, proprietario `GetCtrlOwner`; alle chiamate seguenti lo riusa), registra il controller nel registro `TzLayoutMaintenanceRegistry` (ZBASE-FRM-013), poi nell'ordine: costruisce la struttura (ZBASE-FRM-004), scatta `OnAfterCreateControls` (a struttura canonica, **prima** di applicare il layout salvato), applica il layout salvato (ZBASE-FRM-012), toglie le parti vuote (`Pack`), prepara le schede (`InitLayoutGroups`: la prima scheda attiva, gestori di cambio scheda), scatta `OnAfterLayoutControlLoadProps`; infine crea i controlli della scheda attiva e apre i dataset (ZBASE-FRM-005 e 006), carica l'albero del menu e, se non è disattivato, seleziona la prima voce (ZBASE-FRM-008). `TBaseForm.BuildGui` fa sempre nell'ordine: `FormController.DestroyControls`, `DM.LoadDataModuleProps`, restrizioni, `FormController.CreateControls`, e `FormController.SaveProps` se `ShouldSaveController` è vero (dopo una personalizzazione del layout).

### Scenario: interfaccia non generata
- **Dato** un controller con `zDataModule` assegnato e `BuildGUI = False`
- **Quando** si chiama `CreateControls`
- **Allora** `LayoutController.dxLayoutControl` resta `nil` e nessun evento scatta

### Scenario: ordine degli eventi
- **Dato** un modulo con `BuildGUI = True`
- **Quando** si chiama `CreateControls`
- **Allora** `OnAfterCreateControls` scatta prima di `OnAfterLayoutControlLoadProps`, e `OnAfterCreateComponent` scatta una volta per ogni controllo nato

## ZBASE-FRM-004 Struttura dei gruppi e nomi
Il prefisso dei nomi è il nome del layout (`dxLayout`). Per ogni dataset del modulo che **non** è di sola consultazione (`IsLookupDataSet` falso) e con livello di accesso diverso da `alNone` si creano: un gruppo `dxLayoutGroup<dataset>` (verticale; orizzontale se il dataset ha un master), dentro un gruppo a schede `dxLayoutGroup<dataset>Controls` con un elemento per ogni controllo visibile (nell'ordine: viste, schede, pivot, viste a record, alberi, grafici, calendari, file, mappe) e, se il dataset ha dettagli, un divisore `dxLayoutSplitter<dataset>Details` e un gruppo a schede `dxLayoutGroup<dataset>Details` che contiene ricorsivamente i gruppi dei dettagli (allineato in basso per un dataset senza master, a destra per un dataset con master). Tutto sta nel gruppo a schede `dxLayoutGroupDataModule_<modulo>`; l'albero del menu ha gruppo `dxLayoutGroupTreeMenu`, divisore `dxLayoutSplitterTreeMenu` ed elemento `dxLayoutItemTreeMenu`, alla radice. Le voci di menu visibili che non hanno un gruppo proprio puntano al gruppo del modulo. I nomi sono resi univoci (spazi tolti; se esiste già si aggiunge `_1`, `_2`, ...). Le form degli utenti usano questi nomi (`dxLayoutGroupIntestatariControls`, `dxLayoutGroupManutenzioneDetails`, `dxLayoutGroupMain`): cambiarli rompe `FindGroup` nelle form e il layout salvato nell'LZ.

### Scenario: dataset con dettagli
- **Dato** un dataset `Intestatari` con master assente e almeno un dettaglio
- **Quando** si costruisce la struttura
- **Allora** esistono i gruppi `dxLayoutGroupIntestatari`, `dxLayoutGroupIntestatariControls`, `dxLayoutGroupIntestatariDetails` e il divisore `dxLayoutSplitterIntestatariDetails`
- **E** il gruppo dei dettagli è allineato in basso

### Scenario: dataset escluso
- **Dato** un dataset di sola consultazione o con accesso `alNone`
- **Quando** si costruisce la struttura
- **Allora** non ha gruppi né controlli e non compare fra le voci del menu

## ZBASE-FRM-005 Creazione dei controlli a richiesta
I controlli nascono solo quando servono: `CreateItemControls` scorre il layout e, in un gruppo a schede, visita solo la scheda attiva (`ItemIndex`, o la prima se manca); nei gruppi non a schede visita tutti gli elementi. Per ogni elemento senza controllo crea il componente del tipo del dizionario (`ctView`, `ctCard`, `ctPivot`, `ctRecordView`, `ctTree`, `ctChart`, `ctScheduler`, `ctFile`; `ctNull` no) solo se il dataset è accessibile e non è di sola consultazione. Se esiste già un componente con quel nome (`FindComponent` sul proprietario) lo riusa senza crearlo. Ogni controllo nuovo nasce fuori schermo e nascosto (`InitControl`), con `zSystem` assegnato, l'identificativo del dizionario (assegnato prima del dataset, perché `SetzDataSet` carica le proprietà), il titolo dell'elemento e `RestrictionReadOnly` vero se il livello di accesso del dataset **non** è `alFull`; viene registrato nella lista dei componenti da distruggere e comunicato a `OnAfterCreateComponent`. Le schede non attive restano senza controlli (e senza dataset aperto) fino alla loro attivazione.

### Scenario: scheda non attiva
- **Dato** un gruppo a schede con una vista e una scheda, e la vista attiva
- **Quando** si costruiscono i controlli
- **Allora** esiste il componente della vista e non quello della scheda
- **E** quello della scheda nasce quando la scheda diventa attiva (ZBASE-FRM-009) o quando `MakeVisible` la raggiunge

### Scenario: accesso in sola lettura
- **Dato** un dataset con livello di accesso `alRead`
- **Quando** nasce la sua vista
- **Allora** `RestrictionReadOnly` della vista è vero

## ZBASE-FRM-006 Assegnazione e apertura dei dataset
Dopo la creazione dei controlli, per ogni elemento con controllo e legato a un dataset: se il controllo gestisce `IzBaseDbComponent` e il suo dataset è diverso da quello del modulo, **prima** gli assegna il dataset (e scatta `OnDatasetAssigned` con nome del dataset e controllo, solo in questo caso), **poi** attiva il dataset con `DataModule.ActivateDataSet`. L'ordine è voluto: il componente costruisce colonne e filtri sui campi già creati e i filtri scrivono i valori predefiniti nei parametri, così l'apertura è già filtrata; invertendo l'ordine ogni dataset con filtri si apriva due volte. Per un dataset fuori dall'LZ senza campi, chiuso, con connessione attiva e SQL non vuoto, il controller chiama prima `BuildFields`. Niente di tutto questo accade se la costruzione è in corso (`SkipOpenDataSet`) o se il controller si sta distruggendo; senza `DataModule` il dataset trovato è `nil` e l'attivazione non fa niente.

### Scenario: dataset da assegnare
- **Dato** una vista senza dataset e il dataset `Intestatari` del modulo dati
- **Quando** la scheda diventa attiva
- **Allora** la vista riceve il dataset, scatta `OnDatasetAssigned('Intestatari', vista)` e solo dopo il dataset viene attivato

### Scenario: dataset già assegnato
- **Dato** un controllo che ha già quel dataset
- **Quando** si ripete l'assegnazione
- **Allora** `OnDatasetAssigned` non scatta e il dataset viene comunque attivato

## ZBASE-FRM-007 Distruzione dei controlli
`DestroyControls` non fa niente se il layout non è mai stato creato. Altrimenti, con l'apertura dei dataset sospesa e il layout in `BeginUpdate`: svuota i dizionari interni (compreso quello dell'altezza automatica, ZBASE-FRM-016), scollega e libera l'albero del menu, libera i componenti creati **in ordine inverso**, avvisando prima ciascuno con `OnBeforeDestroyComponent`, e libera tutti gli elementi del layout (anche quelli aggiunti dall'utente nella personalizzazione); il `TdxLayoutControl` resta, vuoto. `TzFormController.Destroy` la chiama prima di liberare il `LayoutController`. `CreateLayoutStructure` ricomincia da `DestroyControls`, quindi la sequenza di `TzFormController.CreateControls` la esegue due volte di fila, la seconda su un layout già vuoto.

### Scenario: prima della costruzione
- **Dato** un controller senza layout creato
- **Quando** si chiama `DestroyControls`
- **Allora** la chiamata non solleva eccezioni e non scatta alcun evento

### Scenario: ordine di distruzione
- **Dato** tre controlli creati nell'ordine A, B, C
- **Quando** si chiama `DestroyControls`
- **Allora** `OnBeforeDestroyComponent` scatta per C, poi B, poi A

## ZBASE-FRM-008 Albero del menu e selezione
L'albero (`TzTreeMenu`, nome `TreeMenu`) esiste solo se `zDataModule.ControllerOptions.TreeMenuVisible` è vero (predefinito vero); senza, `TreeMenu` è `nil`, non si seleziona niente e `OnSelect` non scatta mai. `LoadTreeMenu` carica le voci e, salvo `SkipSelectFirstNode`, seleziona la prima. Una voce selezionata fa: `MakeVisible(nome del dataset)` (porta in vista il gruppo del dataset, azzera lo scorrimento orizzontale, crea i controlli di tutte le parti attive; un nome sconosciuto non fa niente), poi `OnSelect`. `SelectedDataSet` e `SelectedDataSetName` rispondono `nil` e `''` quando non c'è l'albero; assegnare `SelectedDataSetName` senza albero non fa niente. `SkipSelectFirstNode` si propaga al `LayoutController`; durante `Translated` viene azzerato per il tempo della traduzione e poi ripristinato. Le form di Gesty `Orario` e `PrenotazioniAule` lo impostano a vero per scegliere da sole la voce iniziale.

### Scenario: nessun albero
- **Dato** `TreeMenuVisible = False`
- **Quando** si costruiscono i controlli
- **Allora** `LayoutController.TreeMenu` è `nil`, `SelectedDataSetName = ''` e `OnSelect` non scatta

### Scenario: voce sconosciuta
- **Dato** un layout costruito
- **Quando** `MakeVisible('NonEsiste')`
- **Allora** non cambia niente e non si creano controlli

## ZBASE-FRM-009 Cambio di scheda e veto
Per i gruppi a schede **con le linguette visibili** (`HideTabs` falso, di norma perché `ControllerOptions.UsePageControl` è vero) il controller ascolta `OnTabChanging` e `OnTabChanged`. Nel primo crea i controlli della scheda di arrivo (e apre i suoi dataset), poi, se la form ha assegnato `LayoutController.TabChangingProc`, usa il suo risultato come permesso: falso blocca il cambio. Nel secondo crea i controlli della scheda raggiunta e chiama `TabChangedProc(gruppo)`. Entrambi non fanno niente mentre il controller sta già creando controlli. Le form lo usano per il veto: `TFormIntestatari.FormControllerTabChanging` restituisce `CloseQuery` (che può chiedere di salvare). I gruppi con linguette nascoste (la configurazione predefinita) non passano di qui: il cambio avviene da codice o dall'albero (ZBASE-FRM-008) e i gestori non scattano. Un veto non annulla la creazione dei controlli già avvenuta (DIV-FRM-4).

### Scenario: veto
- **Dato** un gruppo con linguette visibili e `TabChangingProc` che restituisce falso
- **Quando** l'utente sceglie un'altra scheda
- **Allora** la scheda resta quella di prima e `TabChangedProc` non scatta

### Scenario: linguette nascoste
- **Dato** un gruppo a schede con `HideTabs` vero
- **Quando** si cambia scheda da codice
- **Allora** `TabChangingProc` e `TabChangedProc` non vengono chiamati

## ZBASE-FRM-010 Conferme e stato di modifica non sono del controller
Il controller non apre finestre di conferma e non sa se i dati sono modificati: non ha un concetto di «modificato», di «salva» o di «annulla» per i dati. Le uniche decisioni delegate sono due: il permesso di cambiare scheda (`TabChangingProc`, ZBASE-FRM-009) e le conferme di `TBaseForm`, che chiede `ConfirmYesNo('Annullare tutte le personalizzazioni ai layout?')` **prima** di chiamare `ResetLayout` e `ConfirmYesNo('Si desidera resettare le dimensioni dei controlli?')` prima di `ResetItemSize`. Anche i salvataggi sono solo del layout: `SaveProps`, `SaveToIni` e `ResetLayout` non toccano i dati dei dataset. Un controller che nasce senza `OnSelect`, senza `TabChangingProc` e senza gli altri eventi funziona: ogni evento è facoltativo.

### Scenario: azzeramento senza conferma
- **Dato** una form che chiama direttamente `FormController.ResetLayout`
- **Quando** il layout è costruito
- **Allora** le personalizzazioni sono azzerate senza alcuna domanda all'utente

## ZBASE-FRM-011 Salvataggio del layout nel dizionario
`TzFormController.SaveProps` fa `LayoutController.SaveProps(False)` e poi `zDataModule.SaveToBase(True)`. `LayoutController.SaveProps` toglie le parti vuote (`Pack`), cerca il layout salvato del modulo con il nome del `TdxLayoutControl` (`dxLayout`; se manca ne crea uno vuoto), vi fotografa **tutto** l'albero degli elementi compresi i gruppi generati dal controller (`LoadFromLayout(..., False)`: sono proprio ciò che l'amministratore personalizza), poi registra nel layout la risoluzione del monitor su cui la form si trova **solo se plausibile** (almeno 640 x 480; altrimenti non scrive nulla e resta il valore precedente) e scrive un avviso nel registro se è diversa da `DesignWidth` x `DesignHeight`. Con `SaveDataModule` vero (valore predefinito) salva il modulo nell'LZ: `SaveToBase(True)` copia il modulo nel dizionario di base e riscrive lo zip dei soli moduli dati. Salvare prima che il layout sia stato creato non è previsto (DIV-FRM-3).

### Scenario: monitor plausibile
- **Dato** una form su un monitor 2560 x 1440
- **Quando** si salva
- **Allora** il layout del modulo ha `DesignWidth = 2560` e `DesignHeight = 1440` e il registro riporta l'avviso di risoluzione diversa da 1920x1200

### Scenario: monitor assurdo
- **Dato** un monitor che dichiara 320 x 200
- **Quando** si salva
- **Allora** `DesignWidth` e `DesignHeight` del layout restano quelli di prima

## ZBASE-FRM-012 Lettura del layout dal dizionario e scalatura
`InternalLoadProps` (chiamata da `CreateLayoutStructure` e da `LoadProps`) non fa niente se è premuto Ctrl: così l'utente può aprire una form ignorando un layout rovinato. Altrimenti applica il layout del modulo (`SaveToLayout(..., True)`: anche padre e posizione dei gruppi generati), poi riscala le dimensioni, poi riarma l'altezza automatica (ZBASE-FRM-016) e traduce le didascalie dei gruppi e degli elementi con il `Localizer`. La scalatura usa come base la risoluzione registrata nel layout se `DesignWidth >= 640` e `DesignHeight >= 480`, altrimenti `DesignWidth` e `DesignHeight` del controller (1920 x 1200); i fattori sono `larghezza del monitor / base` e `altezza del monitor / base`; se sono entrambi 1 non si fa niente; ogni elemento che non sia un divisore e abbia una dimensione di almeno 20 pixel viene moltiplicato e arrotondato, con minimo 20. Il monitor è quello della finestra del layout; se manca la finestra, quello della form principale; altrimenti il primario.

### Scenario: monitor più grande
- **Dato** un layout registrato a 1920 x 1200, un monitor 2560 x 1440 e un elemento largo 300 e alto 200
- **Quando** si applica il layout
- **Allora** l'elemento diventa largo 400 e alto 240

### Scenario: Ctrl premuto
- **Dato** il tasto Ctrl premuto durante la costruzione
- **Quando** si legge il layout
- **Allora** il layout salvato non viene applicato e la form compare con la struttura canonica

## ZBASE-FRM-013 Personalizzazione, azzeramento e riparazione
`CustomizeLayout` apre l'editor di personalizzazione del `TdxLayoutControl` (`TzLayoutCustomizeForm`); `TBaseForm` lo offre solo agli amministratori. Alla chiusura dell'editor, se non è premuto Ctrl, salva con `SaveProps` (a meno che sia pendente un'operazione di manutenzione). `TLayoutController` implementa `IzLayoutMaintenance` **senza conteggio dei riferimenti** (`_AddRef` e `_Release` restituiscono -1: la vita è del `TzFormController`) ed è registrato in `TzLayoutMaintenanceRegistry` con chiave il `TdxLayoutControl`; l'editor lo ritrova da lì. `ResetLayout`: svuota il layout salvato (`DefaultProps`, compresa la risoluzione registrata), ricostruisce la struttura canonica e salva il modulo nell'LZ. `RepairLayout`: fotografa lo stato corrente, elimina i record incoerenti, ricostruisce, rimette i gruppi dei dataset nell'ordine logico del dizionario e salva. Se l'editor è aperto l'operazione viene solo prenotata (`FPendingMaintenanceOp`) ed eseguita **dopo** la sua chiusura (`TThread.ForceQueue`); `CanMaintainLayout` è falso se manca il layout, il modulo, o il controller si sta distruggendo, e in tal caso le due operazioni non fanno niente. I record eliminati dalla riparazione, ripetuti finché non cambia più niente: (a) elementi generati dal controller con padre vuoto o indice -1; (b) elementi il cui padre non si risolve né fra i record né fra i nomi canonici; (d) divisori non generati che stanno alla radice o accanto a un altro divisore; i divisori con allineamento `client` o con dimensioni proprie vengono normalizzati, non eliminati (c). In coda, i gruppi dei dataset rimasti nel contenitore di un vecchio master tornano al padre canonico con indice -1, **ma solo** se il contenitore è del controller (gruppo del modulo o gruppo `...Details`) e non è un antenato del dataset: i gruppi messi di proposito fra le schede di un antenato non si toccano.

### Scenario: azzeramento
- **Dato** un layout con personalizzazioni e risoluzione 2560x1440 registrata
- **Quando** si chiama `ResetLayout` con l'editor chiuso
- **Allora** il layout salvato è vuoto, `DesignWidth = DesignHeight = 0` e la struttura è quella canonica

### Scenario: editor aperto
- **Dato** l'editor di personalizzazione aperto
- **Quando** l'editor chiama `RepairLayout`
- **Allora** non succede niente subito
- **E** la riparazione parte dopo la chiusura dell'editor, senza il salvataggio ordinario

### Scenario: prima della costruzione
- **Dato** un controller senza layout
- **Quando** si chiamano `CanMaintainLayout`, `ResetLayout` e `RepairLayout`
- **Allora** la prima risponde falso e le altre non fanno niente

## ZBASE-FRM-014 File `.layout` della postazione
Le dimensioni scelte dall'utente su quella postazione stanno in `<ConfigFolder>\<nome del modulo>.<nome del layout>.layout` (per esempio `Studenti.dxLayout.layout`; `ConfigFolder` è `zSystem.ConfigFolder`, altrimenti la cartella dell'eseguibile). Il file è un `.ini`: sezione `_System_` con `SavedMonitorWidth`, `SavedMonitorHeight` (pixel fisici del monitor) e `SavedPPI`; una sezione per ogni elemento con `Width` e `Height` riportate a 96 PPI. **Scrittura** (`SaveToIni`, alla chiusura della form e dall'azione dedicata): per ogni elemento che non sia un divisore **e abbia contenuto reso a video** (almeno un discendente visibile con un controllo: i gruppi mai popolati non hanno una dimensione da salvare e il valore del file resta com'è), si scrive la larghezza se è almeno 20 pixel e l'allineamento orizzontale non è `client` né gestito dal padre, e l'altezza alle stesse condizioni (per il gruppo adattato a una card, quella scelta dall'utente e non quella della card); il valore deve essere plausibile alla sua dimensione riportata a 96 PPI: almeno 20 per gli elementi, almeno 50 per i gruppi. Ogni errore è ingoiato (DIV-FRM-16). **Lettura** (`LoadFromIni`, e `AfterShow` solo di Gesty): se esiste il vecchio nome con lo spazio prima dell'estensione, lo rinomina (o lo elimina se il nuovo esiste); poi, per ogni sezione con un elemento che non sia un divisore, applica larghezza e altezza (stesse esclusioni di allineamento) moltiplicate per `monitor attuale / monitor salvato` e per `SavedPPI / 96` (i valori mancanti valgono 1920 x 1200 e 96; se i monitor non sono noti il fattore è 1); il gruppo dell'albero non scende sotto la larghezza calcolata da `TzTreeMenu`. Un valore salvato sotto la soglia del suo tipo e maggiore di zero è «non valido»: viene ignorato, e se alla fine ce n'è anche uno solo **l'intero file viene cancellato** e si scrive un avviso nel registro; le dimensioni valide lette fino a quel punto restano applicate per quella sessione. `LoadFromIni` pubblico poi toglie le parti vuote, prepara le schede e crea i controlli.

### Scenario: scrittura e rilettura a 192 PPI
- **Dato** un portatile a 2880 x 1920 al 200% (192 PPI) con un gruppo largo 600 pixel fisici
- **Quando** si salva e si rilegge sullo stesso monitor
- **Allora** nel file c'è `Width=300` e alla lettura il gruppo torna largo 600

### Scenario: file degenere
- **Dato** un file con la larghezza 25 di un gruppo e la larghezza 300 di un altro
- **Quando** si legge
- **Allora** il secondo gruppo riceve 300, il primo non cambia, e il file viene cancellato con un avviso nel registro

### Scenario: gruppo mai popolato
- **Dato** un gruppo a schede la cui scheda non è mai stata attivata
- **Quando** si salva il file
- **Allora** per quel gruppo non si scrive niente e l'eventuale valore già nel file resta

## ZBASE-FRM-015 Controllo delle dimensioni dopo la comparsa
`AfterShow` (Gesty: `TBaseForm.FormShow`, solo se il modulo ha `BuildGUI`) legge il file `.layout` (ZBASE-FRM-014) e avvia un timer da 300 ms che scatta una volta sola. `CheckControlDimensions` esce se il contenitore non è pronto; poi, per ogni elemento che non sia un divisore e abbia un padre già disposto, se `larghezza del padre - larghezza dell'elemento < 150` porta la larghezza a `larghezza del padre - 150` (minimo 20), e lo stesso per l'altezza: serve a non lasciare agli altri elementi del gruppo meno di 150 pixel. Un padre non ancora disposto (senza `ViewInfo`) si salta. `AfterResize` oggi non fa niente (DIV-FRM-8): il timer parte solo da `AfterShow`. WT non chiama `AfterShow` (DIV-FRM-5).

### Scenario: elemento troppo largo
- **Dato** un elemento largo 900 in un gruppo la cui area è larga 1000
- **Quando** scatta il controllo
- **Allora** l'elemento diventa largo 850

## ZBASE-FRM-016 Altezza automatica delle card
Una `TzDbCard` con `AutoFitHeight` dentro un gruppo a schede del controller non può dimensionarsi da sola: comunica al controller (`OnAutoFitHeight`, impostato alla creazione) l'altezza voluta e se è visibile. Il controller individua il gruppo che decide l'altezza (`FindAutoFitGruppo`): se il gruppo `...Controls` non è `avClient`, è lui (segno +1: cresce con la card); altrimenti il fratello visibile allineato in basso, cioè `...Details` (segno -1: cala). Nessun gruppo adatto (dataset di dettaglio, card accanto alla vista): non fa niente. La nuova altezza è `base + segno × (altezza voluta - altezza attuale della card)`, limitata fra 100 pixel e `area del padre - 150`; si applica solo se differisce di più di 3 pixel. L'altezza scelta dall'utente (divisore, file `.layout`) si ricorda alla comparsa della card, si rimette quando la card si nasconde e si salva al posto di quella adattata. Se con la card visibile l'altezza del gruppo cambia da fuori (l'utente muove il divisore), per quel dataset l'adattamento si sospende fino alla chiusura della form. Non si adatta nulla con l'editor di personalizzazione aperto, durante la distruzione o con il gruppo non ancora disposto (si riprova al prossimo ridimensionamento della card). Le altezze lette dal file `.layout`, dall'LZ e da `CheckControlDimensions` rilanciano l'adattamento senza sospenderlo.

### Scenario: dettagli sotto la card
- **Dato** un dataset con i dettagli sotto, altezza dei dettagli 300, card alta 200 che chiede 260
- **Quando** la card si mostra
- **Allora** i dettagli scendono a 240 pixel

### Scenario: divisore mosso
- **Dato** una card adattata e visibile
- **Quando** l'utente sposta il divisore
- **Allora** l'adattamento di quel dataset si sospende e l'altezza scelta dall'utente è quella che si salva

## ZBASE-FRM-017 Strumenti di diagnostica
`DumpItemSize(ClientWidth, ClientHeight)` restituisce un testo con le dimensioni del client, lo spazio occupato dal layout e una riga per ogni elemento (nome, `UsualWidth`, `UsualHeight`), preceduta da `!!! ` se supera la larghezza o l'altezza del client; senza layout restituisce il testo vuoto. `TBaseForm` lo copia negli appunti e lo mostra in una finestra (azione `ControllerMostraDimensioni`). `ResetItemSize` azzera `SizeOptions.Width` e `Height` di tutti gli elementi (solo in memoria: non cancella né il file `.layout` né l'LZ) e non fa niente senza layout. `LayoutDesignResolutionReport(zDataModules, RefWidth, RefHeight)` è una funzione di sola lettura che elenca i layout dell'LZ con la risoluzione di redazione: salta quelli senza elementi, segnala come «non registrata» quelli con una dimensione zero o negativa e come «DIVERSA dal riferimento» quelli con risoluzione diversa; il testo ha un'intestazione col riferimento, una riga di riepilogo (`N layout esaminati: A in linea, B diversi, C senza risoluzione registrata.`), poi le righe `modulo.layout` o `  Nessuna segnalazione.`. `DumpItemSize` e `ResetItemSize` sono azioni di `TBaseForm` in WT e in Gesty; il rapporto delle risoluzioni non è chiamato da nessuno (è pensato per una voce di diagnostica).

### Scenario: layout con risoluzione diversa
- **Dato** un modulo `Studenti` con un layout `dxLayout` con elementi e risoluzione 1366 x 768
- **Quando** si chiama `LayoutDesignResolutionReport(moduli, 1920, 1200)`
- **Allora** il testo contiene `1 layout esaminati: 0 in linea, 1 diversi, 0 senza risoluzione registrata.` e una riga `Studenti.dxLayout` con `1366x768  DIVERSA dal riferimento 1920x1200`

### Scenario: nessun layout
- **Dato** `zDataModules` nullo
- **Quando** si chiama la funzione
- **Allora** il riepilogo dice `0 layout esaminati: 0 in linea, 0 diversi, 0 senza risoluzione registrata.` e il testo finisce con `  Nessuna segnalazione.`

## Divergenze note
Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zFormController.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-FRM-1 🟢 (dedotta) | `TLayoutController.GetComponent<T>` restituisce sempre `default(T)` (commento «implementare», righe 2575-2581) e `TzFormController.GetComponent<T>` (2015-2026) lo chiama e basta; nessun chiamante in `SRC` | Chi lo usasse riceverebbe `nil` in silenzio: codice morto che inganna |
| DIV-FRM-2 🟢 (dedotta) | `GetDbView`, `GetDbCard`, `GetDbRecordView`, `GetDbTree`, `GetDbChart`, `GetDbScheduler` (2028-2177) non hanno chiamanti in `SRC`; non esiste quello dei pivot né dei file | Restituiscono `nil` per una scheda mai attivata (i controlli nascono a richiesta): non sono un modo affidabile di ritrovare un controllo |
| DIV-FRM-3 🟡 (dedotta) | `TLayoutController.IniFileName` legge `FormController.zSystem.ConfigFolder` (riga 2603) **prima** di controllare `assigned(zSystem)` (2608); `SaveToIni`, `SaveProps`, `LoadFromIni` e `AfterShow` assumono layout e `zDataModule` già pronti | `SaveToIni` con `zSystem` vuoto e `LoadFromIni` o `SaveProps` prima di `CreateControls` vanno in violazione di accesso; i chiamanti di WT e Gesty proteggono con `BuildGui` |
| DIV-FRM-4 🟡 (dedotta) | `TabChanging` crea i controlli della scheda di arrivo e apre i suoi dataset (righe 2863-2864) **prima** di chiamare `TabChangingProc` (2866-2867) | Se il veto (per esempio `CloseQuery` di `TFormIntestatari`) risponde no, la scheda scartata ha già aperto i suoi dataset, magari con modifiche in sospeso sul master |
| DIV-FRM-5 🟡 (dedotta) | Gesty chiama `FormController.AfterShow` in `TBaseForm.FormShow` (riga 1363), WT no (`FormShow` manda solo `cmd_AfteShow`) | In WT il file `.layout` si scrive alla chiusura (`TBaseForm.Destroy` → `SaveToIni`) ma non si rilegge mai all'apertura, e il controllo delle dimensioni non parte; resta solo l'azione manuale, con livello `alNone` predefinito |
| DIV-FRM-6 🟢 (dedotta) | `IsControlVisible` (1031-1044) e `MakeVisible(Control)` (2985) chiamano `dxLayoutControl.FindItem` senza controllare che il layout esista; `MakeVisible(nome)` invece è protetta dal dizionario | Prima di `CreateControls` violazione di accesso; nessun chiamante di `IsControlVisible` in `SRC` |
| DIV-FRM-7 🟢 (dedotta) | `LayoutController.DestroyControls` (909-910) e `TzFormController.CreateControls` con `BuildGUI` falso (1743-1744) escono dopo `EnterMethod` senza `LeaveMethod` | Il registro SmartInspect resta con un livello di indentazione in più per ogni chiamata |
| DIV-FRM-8 🟢 (dedotta) | `AfterResize` (3727-3734) contiene `if False then` («AV») e `BaseFrm` di Gesty ha la chiamata commentata | Metodo pubblico che non fa nulla, e il timer del controllo dimensioni parte solo da `AfterShow` |
| DIV-FRM-9 🟢 | Dopo `end.` il file contiene righe di appunti (`InternalLoadFromIni; zRestrictions.form zSystem ...`, righe 3836-3839) | Il compilatore le ignora, ma sono testo estraneo che inganna chi legge |
| DIV-FRM-10 🟢 (dedotta) | In `Pack.RemoveEmptyItems` il ramo `ContainsKey` seguito da `not TryGetValue` (1104-1108) non si può mai eseguire; le procedure `EnableGoogleMapsHooks` e `DisableGoogleMapsHooks` (747-779) hanno il corpo tutto commentato ma sono chiamate | Resta in piedi solo il secondo ramo (elementi fuori dal dizionario e senza controllo): il commento «deve togliere gli item per i dataset eliminati» promette di più di quello che il codice fa |
| DIV-FRM-11 🟢 (dedotta) | `UniqueLayoutItemName` dopo la prima collisione ricostruisce il nome da `name` (riga 957) e non dal risultato senza spazi | Con un nome di dataset che contiene spazi il secondo tentativo (`..._1`) li ha ancora e `Name` solleva «nome non valido»; i dizionari di oggi non hanno spazi nei nomi |
| DIV-FRM-12 🟢 (dedotta) | `GetLayoutProps` (1897-1921) è una lettura ma crea un record vuoto in `zDataModule.Layouts` se manca; lo chiamano `GetDesignResolution` e `InternalLoadProps` a ogni costruzione | Ogni form aperta lascia nell'LZ un layout vuoto anche se nessuno lo personalizza (`LayoutDesignResolutionReport` li salta per questo) |
| DIV-FRM-13 🟢 (dedotta) | `LayoutDesignResolutionReport` conta in `Totale` anche i layout vuoti (3791) e poi li salta (3795), e `in linea` è `Totale - Deviate - NonRegistrate` | Il riepilogo dà per «in linea» layout che non hanno nessuna risoluzione da confrontare |
| DIV-FRM-14 🟢 (dedotta) | `DumpItemSize` stampa `UsualWidth` due volte (la seconda con l'etichetta `Width`) e lo stesso per l'altezza (1855-1858); legge `ViewInfo` senza controllo | Il testo non dà la larghezza vera dell'elemento; con un elemento non ancora disposto violazione di accesso |
| DIV-FRM-15 🟢 (dedotta) | `Notification` (2198-2231) azzera `zSystem`, `CtrlOwner`, `CtrlParent` ma nessuno chiama `FreeNotification`; `DataModule` e `zDataModule` hanno la riga commentata | Funziona per componenti con lo stesso proprietario; `Config.zSystem` (proprietà di un altro modulo) se distrutto prima della form resta un puntatore pendente |
| DIV-FRM-16 🟢 (dedotta) | `SaveToIni` ingoia ogni eccezione (`except end`, righe 3228-3229) | Un file `.layout` non scrivibile (cartella in sola lettura, disco pieno) non lascia traccia: l'utente crede di aver salvato |
| DIV-FRM-17 🟢 (dedotta) | `OnCustomization` esegue tutto sotto `not ctrlKey` (2665-2695): con Ctrl premuto alla chiusura l'operazione prenotata non viene né eseguita né annullata | Resta prenotata e parte alla chiusura successiva dell'editor, fuori contesto |

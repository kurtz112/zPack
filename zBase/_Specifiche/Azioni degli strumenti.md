---
area: Azioni degli strumenti
progetto: zBase
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/007
---

# Azioni degli strumenti

Questa specifica descrive `zBase\zToolActions.pas`: il modo in cui i componenti documentali (`TzDbView`, `TzDbCard`, `TzDbPivot`, `TzDbRecordView`, `TzDbTree`, `TzDbChart`, `TzDbScheduler`, `TzMap`, `TzFileViewer` e `TzDbViewDlg`) trasformano le azioni (`TCustomAction`) di una form in pulsanti della loro barra, in voci del menu a comparsa e in sottomenu. La unit contiene due metà che si parlano: i **dati persistenti** (`TzToolActionsProps` e `TzToolActionProps`, salvati nell'LZ dentro le proprietà del componente, chiave `ToolActions`) e i **dati in esecuzione** (`TzToolActions` e `TzToolAction`, ricostruiti a ogni caricamento), più due classi di servizio senza stato: `TzActionOwnerResolver` (trova la form o il modulo dati che possiede le azioni) e `TzActionBuilder` (copia i dati persistenti in quelli in esecuzione). La unit è compilata (compare in `WinTarif3.dpr`, riga 802, ed è usata da tutti i componenti elencati). Chi dichiara un'azione da codice usa `AddAction` di `TzDbView` (per esempio `Dialog.zDbView.AddAction(TuttaAnagrafe, dx.Immagini)` in `wizIntestatario_DM.pas`); chi la configura usa la finestra `zToolConfigDlg`, che si appoggia a `CandidateOwners`. Fuori da `zBase` la unit è citata da `zOffice.MultiViewer` (`ActionExistsInBar`).

**Come funziona.** Ogni componente ha un elenco persistente `Props.ToolActions` (una voce per nome di azione: gruppo, posizione, visibilità, sottomenu) e un elenco in esecuzione `ToolActions`. All'avvio del componente, `TzActionBuilder.BuildFromProps` svuota le voci volatili dell'elenco in esecuzione e le ricrea, risolvendo ogni nome di azione sul proprietario scelto da `TzActionOwnerResolver.ResolveOwner`; poi `ToolActions.CreateButtons` costruisce i pulsanti sulla barra e nel menu a comparsa. Le azioni dichiarate da codice entrano nell'elenco persistente con il segno `FromCode`, che le protegge dal ricaricamento del dizionario. I pulsanti sono creati da `TzDxBarHelper` (`zDxBarHelper.pas`).

**Test che coprono quest'area.** Nessuna prova esistente in `zPackTests`. Il test `Test.zToolActions` prova senza finestre: i valori predefiniti e la copia delle visibilità (ZBASE-TLA-001), i valori predefiniti, i metodi concatenabili e la copia delle voci persistenti (ZBASE-TLA-002), la protezione delle azioni da codice (ZBASE-TLA-003), l'inserimento senza doppioni, la ricerca e l'azzeramento alla distruzione di un'azione (ZBASE-TLA-004, 005), le voci volatili e la ricostruzione sospesa (ZBASE-TLA-006), `BuildFromProps` (ZBASE-TLA-007), la descrizione testuale (ZBASE-TLA-009) e la risoluzione del proprietario (ZBASE-TLA-010). Provano anche le correzioni di DIV-TLA-1 (copia del contenuto di `PopupProps` e `ToolbarProps`) e DIV-TLA-2 (`Assign` dell'azione in esecuzione copia il nome; il flag volatile non si copia dal ticket 319, che ha corretto la copia del flag introdotta dal rilascio 009 e ha aggiunto il test `BuildFromProps_VoceCopiataDaAltroElenco_Sopravvive`). Restano senza prova `CreateButtons` (ZBASE-TLA-008), che richiede un `TdxBarManager` con la sua barra a video, e la scelta della lista immagini, che dipende dal globale `Base`.

## ZBASE-TLA-001 Visibilità di un'azione per contesto
Ogni voce ha due gruppi di visibilità, `ToolbarProps` (barra) e `PopupProps` (menu a comparsa); ciascuno è un `TzTBCustomItemProps` con due interruttori, `VisibleInView` e `VisibleInCard`, **veri** per impostazione predefinita. Il contesto in cui una azione compare lo decide il componente che costruisce i pulsanti con il parametro `OwnerType` di `CreateButtons`: `otView` (griglia, pivot, vista a record, albero, calendario) guarda `VisibleInView`, `otCard` (scheda) guarda `VisibleInCard`, `otOther` (grafico, mappa, visualizzatore di file) **non guarda nessuno dei due**: l'azione compare sempre. `Assign` copia entrambi gli interruttori; assegnare un oggetto di altro tipo solleva l'errore standard di `TPersistent`.

### Scenario: valori iniziali
- **Dato** un `TzTBCustomItemProps` appena creato
- **Quando** si leggono le proprietà
- **Allora** `VisibleInView` e `VisibleInCard` sono veri

### Scenario: copia
- **Dato** un gruppo con `VisibleInView = False` e `VisibleInCard = True`
- **Quando** lo si assegna a un altro gruppo con `Assign`
- **Allora** il secondo ha `VisibleInView = False` e `VisibleInCard = True`

## ZBASE-TLA-002 Voce persistente di un'azione
`TzToolActionProps` descrive come una azione compare, ed è l'unico dato che finisce nel dizionario. Il nome (`Name`) è il nome dell'azione sulla form e fa da chiave. Valori predefiniti: `BeginGroup` falso, `Position` -1 (in coda), `ShowCaption` vero (il costruttore lo imposta, ma la proprietà non ha `default` e viene quindi sempre scritta), `SubMenu` vuoto (pulsante diretto sulla barra), `PopupProps` e `ToolbarProps` con tutto visibile. I metodi concatenabili ripetono quelli dell'azione in esecuzione, così la dichiarazione da codice resta `AddAction(X).HideInCard`: `HideInCard` e `HideInView` nascondono sia barra sia menu in quel contesto; `HideInPopups` e `HideInToolbar` nascondono in entrambi i contesti solo il menu o solo la barra; `SetShowCaption` e `SetSubMenu` impostano i campi; tutti restituiscono la voce stessa. Assegnare `PopupProps` o `ToolbarProps` ne copia il contenuto (non il riferimento) e la voce libera i suoi due oggetti alla distruzione. `Assign` copia nome, gruppo, posizione, didascalia, sottomenu e le due visibilità, **non** il segno `FromCode` (ZBASE-TLA-003). L'elenco `TzToolActionsProps` non è ordinato: l'ordine delle voci è quello di inserimento.

### Scenario: metodi concatenabili
- **Dato** una voce nuova
- **Quando** si chiama `HideInCard.SetSubMenu('Stampe')`
- **Allora** `ToolbarProps.VisibleInCard` e `PopupProps.VisibleInCard` sono falsi, quelle `VisibleInView` restano vere
- **E** `SubMenu = 'Stampe'`

### Scenario: nascondere solo il menu
- **Dato** una voce nuova
- **Quando** si chiama `HideInPopups`
- **Allora** `PopupProps` ha entrambe le visibilità false e `ToolbarProps` le ha vere

## ZBASE-TLA-003 Azioni dichiarate da codice
Un'azione dichiarata da codice (`TzDbView.AddAction` e gli equivalenti degli altri componenti) è scritta direttamente nell'elenco persistente, con `FromCode = True`; se esiste già una voce con quel nome (confronto senza distinzione fra maiuscole e minuscole) la riusa e la segna. `FromCode` non è pubblicata né copiata da `Assign`, quindi non ritorna mai vera da un caricamento. `TzToolActionsProps.Assign`, che il caricamento dall'LZ usa per riempire l'elenco, mantiene le voci `FromCode` che il dizionario non conosce: prima di sovrascrivere ne fa una copia, poi ricarica dal dizionario e riaggiunge **in coda** quelle il cui nome non è comparso, di nuovo con `FromCode = True`. Se il dizionario contiene lo stesso nome, vince il dizionario (la configurazione dell'utente prevale sulla dichiarazione di codice) e la voce non è più `FromCode`. `MergeFromCode(Origine)` aggiunge dall'origine i **soli** nomi assenti, marcandoli `FromCode`, e dice se ha aggiunto qualcosa; con origine nulla non fa niente. `HasFromCode` dice se esiste almeno una voce segnata, `ClearFromCode` toglie il segno a tutte (dopo il primo salvataggio nel dizionario).

### Scenario: l'elenco del dizionario non cancella la dichiarazione da codice
- **Dato** un elenco con la voce `Stampa` segnata `FromCode`
- **Quando** vi si assegna un elenco caricato dall'LZ che contiene solo `Salva`
- **Allora** l'elenco contiene `Salva` e `Stampa`, in questo ordine
- **E** `Stampa` è ancora `FromCode` e `Salva` no

### Scenario: il dizionario prevale
- **Dato** un elenco con `Stampa` segnata `FromCode` e `BeginGroup` vero
- **Quando** vi si assegna un elenco caricato dall'LZ con `Stampa` e `BeginGroup` falso
- **Allora** `Stampa` ha `BeginGroup` falso e `FromCode` falso

### Scenario: unione
- **Dato** un elenco con `Salva` e un'origine con `Salva` e `Stampa`
- **Quando** si chiama `MergeFromCode`
- **Allora** restituisce vero e l'elenco ha ora anche `Stampa`, segnata `FromCode`
- **E** una seconda chiamata restituisce falso

## ZBASE-TLA-004 Azioni in esecuzione: inserimento e ricerca
`TzToolActions` è l'elenco in esecuzione di un componente (non ordinato, proprietario il componente). `Add(Azione, ListaImmagini, Volatile)` non crea doppioni: se l'azione è già presente restituisce la voce esistente senza toccarla; altrimenti crea una voce, ne assegna azione e lista immagini e, se richiesto, la segna volatile. Assegnare l'azione a una voce ne fissa anche il nome (`Name := Action.Name`). `Add(ListaImmagini, Volatile)` crea invece una voce senza azione (da riempire poi). `Contains` e `FindByAction` cercano per azione; `Exists` cerca per nome senza distinzione fra maiuscole e minuscole.

### Scenario: nessun doppione
- **Dato** un elenco in esecuzione e un'azione `Salva`
- **Quando** la si aggiunge due volte
- **Allora** l'elenco ha una sola voce, di nome `Salva`, e la seconda chiamata restituisce la stessa voce

### Scenario: ricerca per nome
- **Dato** una voce di nome `Salva`
- **Quando** si chiama `Exists('SALVA')` e `Exists('Altra')`
- **Allora** la prima risponde vero e la seconda falso

## ZBASE-TLA-005 Azione o lista immagini distrutta
Quando un'azione viene liberata, il componente proprietario chiama `RemoveNotification`: ogni voce che puntava a quell'azione rimette l'azione a `nil` e **resta nell'elenco** (nome compreso); `CreateButtons` salta le voci senza azione. Lo stesso vale per una lista immagini assegnata a una voce. Per ricevere l'avviso, la voce chiede `FreeNotification` al proprietario dell'elenco al momento dell'assegnazione e lo restituisce quando l'azione cambia.

### Scenario: azione liberata
- **Dato** una voce con l'azione `Salva`
- **Quando** il proprietario chiama `RemoveNotification(Salva)`
- **Allora** la voce ha `Action = nil` e il nome `Salva`, e `Count` non cambia

## ZBASE-TLA-006 Voci volatili e ricostruzione sospesa
Le voci create da `BuildFromProps` sono **volatili**: `DestroyVolatiles` le elimina (scorrendo dalla fine) e lascia quelle non volatili, aggiunte direttamente da codice con `Add`. `BeginRebuild` sospende `OnChange` dell'elenco e apre un blocco di aggiornamento; `EndRebuild` chiude il blocco (che emette l'avviso, ma con `OnChange` ancora sospeso, quindi senza rientro) e **poi** ripristina `OnChange`. Le ricostruzioni si possono annidare: una seconda `BeginRebuild` mentre la ricostruzione è in corso non sospende di nuovo, ma conta un livello, e solo l'ultima `EndRebuild` chiude il blocco e ripristina `OnChange`; una `EndRebuild` senza `BeginRebuild` non fa niente. Durante la ricostruzione nessuna modifica fa scattare `OnChange`; subito dopo, ogni modifica lo fa scattare di nuovo.

**Una voce copiata da un altro elenco non è volatile.** `Assign` di una voce copia azione, nome, visibilità e posizione ma **non** il flag volatile: la voce copiata non nasce dalle impostazioni di questo componente, quindi la sua ricostruzione non deve eliminarla. È il caso delle azioni della vista copiate nella scheda all'apertura (`TzDbCardDlg.SetMasterView`): la scheda ricostruisce la propria barra dalle sue impostazioni, vuote, e le azioni della vista (Procedi, Respingi, Modifica estensore negli incarichi da gestire) devono restare (ticket 319).

### Scenario: nessun avviso durante la ricostruzione
- **Dato** un elenco con un gestore di `OnChange` che conta le chiamate
- **Quando** si chiama `BeginRebuild`, si aggiungono due azioni e si chiama `EndRebuild`
- **Allora** il contatore è rimasto a zero
- **E** una modifica successiva fa salire il contatore

### Scenario: eliminare i volatili
- **Dato** una voce volatile e una non volatile
- **Quando** si chiama `DestroyVolatiles`
- **Allora** resta solo la non volatile

### Scenario: azioni della vista nella scheda
- **Dato** una vista con una voce volatile e una scheda con impostazioni vuote
- **Quando** la scheda copia le azioni della vista con `Assign` e ricostruisce la propria barra
- **Allora** la voce copiata c'è ancora, con azione e nome della vista (ticket 319)

## ZBASE-TLA-007 Costruzione delle azioni dai dati persistenti
`TzActionBuilder.BuildFromProps(Props, InEsecuzione, Proprietario)` ricostruisce l'elenco in esecuzione: se `Props` o `InEsecuzione` sono nulli esce; altrimenti, dentro `BeginRebuild`/`EndRebuild`, elimina le voci volatili e, per ogni voce persistente **nell'ordine dell'elenco**, cerca l'azione per nome sul proprietario (`TzActionOwnerResolver.FindAction`, ZBASE-TLA-010). Se la trova la aggiunge come volatile, senza lista immagini, e ne copia `BeginGroup`, `Position`, `PopupProps`, `ToolbarProps` (copia dei valori, non del riferimento), `ShowCaption` e `SubMenu`. Se **non** la trova la voce è ignorata senza alcun avviso (DIV-TLA-8). Se l'azione era già presente come voce non volatile, quella voce è riusata e riceve i valori persistenti, ma resta non volatile. `LargeButton` non è né persistente né copiato: le azioni nate da qui usano sempre la lista immagini piccola (ZBASE-TLA-009). La costruzione dei pulsanti **non** avviene qui: è compito del componente, che chiama poi `CreateButtons`.

### Scenario: ricostruzione completa
- **Dato** un proprietario con le azioni `Salva` e `Stampa` e un elenco persistente con `Stampa` (gruppo vero, sottomenu `Stampe`, posizione 2) e `Salva`
- **Quando** si chiama `BuildFromProps`
- **Allora** l'elenco in esecuzione ha `Stampa` e `Salva`, in quest'ordine, entrambe volatili
- **E** `Stampa` ha `BeginGroup` vero, `SubMenu = 'Stampe'`, `Position = 2`

### Scenario: azione inesistente
- **Dato** una voce persistente `NonEsiste`
- **Quando** si chiama `BuildFromProps`
- **Allora** nessuna voce in esecuzione viene creata e non si solleva nessun errore

### Scenario: ricostruire due volte
- **Dato** un elenco in esecuzione già ricostruito
- **Quando** si richiama `BuildFromProps` con gli stessi dati
- **Allora** non ci sono voci doppie

## ZBASE-TLA-008 Pulsanti, sottomenu e menu a comparsa
`CreateButtons(Barra, MenuAComparsa, TipoProprietario)` costruisce l'interfaccia dall'elenco in esecuzione. In fase di progettazione (`csDesigning` sul proprietario) esce subito. Prima libera i pulsanti e i sottomenu costruiti dalla chiamata precedente (chi tenesse un riferimento a un vecchio pulsante lo troverebbe liberato). Il gestore delle barre è quello della barra; se manca, quello del menu a comparsa. Per ogni voce **con azione** crea un pulsante (anche se poi non compare né sulla barra né nel menu); le voci senza azione sono saltate. Sulla barra l'azione compare se la barra esiste e la visibilità del contesto (ZBASE-TLA-001) è vera. Posizione: `Position` -1 mette il pulsante in coda; `Position` maggiore o uguale a zero lo sposta all'indice `Min(Position, numero di elementi - 1)` **al momento dell'inserimento**, quindi vale rispetto agli elementi già presenti sulla barra e alle voci inserite prima. `BeginGroup` mette un separatore prima del pulsante. Con `SubMenu` non vuoto (spazi tolti) l'azione non è un pulsante diretto: si crea un sottomenu con quella didascalia, **uno solo per nome**, senza distinguere maiuscole e minuscole, alla prima azione che lo usa; il sottomenu prende posizione e separatore **di quella prima azione**, e ogni azione (compresa la prima) diventa una voce interna, con il proprio `BeginGroup`. Se manca il gestore delle barre, il sottomenu non si può creare e l'azione resta diretta. Nel menu a comparsa l'azione compare se il menu esiste e la visibilità del suo gruppo è vera: sempre come pulsante semplice, **mai nel sottomenu**, con `Position` e `BeginGroup` ignorati e inserita **all'inizio**, quindi con ordine inverso a quello dell'elenco (DIV-TLA-6). Lo stesso pulsante può quindi avere due collegamenti, uno sulla barra e uno nel menu. `ActionExistsInBar(Barra, Azione)` dice se la barra ha un collegamento diretto a un pulsante con quell'azione (non guarda dentro i sottomenu).

### Scenario: sottomenu condiviso
- **Dato** tre azioni, le prime due con `SubMenu = 'Stampe'` e la terza senza
- **Quando** si chiama `CreateButtons` su una barra
- **Allora** la barra contiene un sottomenu `Stampe` con due voci e un pulsante diretto per la terza
- **E** il sottomenu sta nella posizione della prima delle due

### Scenario: contesto scheda
- **Dato** un'azione con `ToolbarProps.VisibleInCard = False`
- **Quando** si chiama `CreateButtons` con `otCard`
- **Allora** l'azione non compare sulla barra, ma compare nel menu se `PopupProps.VisibleInCard` è vero
- **E** con `otOther` compare in tutti e due

## ZBASE-TLA-009 Descrizione testuale e immagini
`TzToolAction.Description` serve alle descrizioni per l'assistente (`zAI.Descriptors`, che ne replica la logica sui dati persistenti): senza azione restituisce `(azione non assegnata)`; altrimenti la didascalia dell'azione, seguita da ` — ` e dal suggerimento se non è vuoto, seguita da ` [solo card]` se `ToolbarProps.VisibleInView` è falso oppure, altrimenti, da ` [solo view]` se `ToolbarProps.VisibleInCard` è falso. Conta solo la barra, non il menu. La lista immagini di una voce è, in ordine: quella assegnata; se manca e `LargeButton` è vero, `Base.ImageList24`; altrimenti `Base.ImageList16` (globale di `zSystem`, DIV-TLA-7). `HideInCard`, `HideInView`, `HideInPopups` e `HideInToolbar` hanno sull'azione in esecuzione lo stesso effetto descritto in ZBASE-TLA-002.

### Scenario: descrizione completa
- **Dato** un'azione con didascalia `Salva` e suggerimento `Salva il record`, visibile ovunque
- **Quando** si chiama `Description`
- **Allora** il risultato è `Salva — Salva il record`

### Scenario: solo scheda
- **Dato** la stessa azione con `ToolbarProps.VisibleInView = False`
- **Quando** si chiama `Description`
- **Allora** il risultato termina con ` [solo card]`

## ZBASE-TLA-010 Proprietario delle azioni
`TzActionOwnerResolver` stabilisce dove cercare le azioni di un componente. `ResolveOwner(Componente, NomeForzato)` restituisce, in ordine: (1) se `NomeForzato` non è vuoto, il primo componente trovato risalendo la catena dei proprietari a partire dal componente, il cui nome coincide, oppure il cui proprietario ha quel nome, oppure che è un componente di nome `NomeForzato` posseduto da un proprietario della catena; (2) il proprietario del `TzDbViewDlg` che ospita il componente, se la catena dei proprietari ne attraversa uno (le azioni di dominio stanno nella form che ha aperto la finestra); (3) il proprietario diretto del componente. Un nome forzato che non si trova **non** dà errore: si ricade silenziosamente sui punti 2 e 3. Con componente nullo restituisce `nil`. `CandidateOwners(Componente)` serve alla finestra di configurazione: risale la catena dei proprietari partendo dal componente stesso e raccoglie quelli che possiedono almeno un'azione, poi aggiunge il proprietario del `TzDbViewDlg` ospitante se manca; senza doppioni, nell'ordine di scoperta. `ActionsOf(Proprietario)` elenca le azioni possedute direttamente; `FindAction(Proprietario, Nome)` cerca per nome un componente posseduto direttamente e lo restituisce solo se è un'azione (altrimenti `nil`; anche con proprietario nullo). `DeclaringClass(Proprietario, NomeCampo)` risale dalla classe del proprietario verso gli antenati e restituisce la **prima** (più derivata) che dichiara il campo, per distinguere le azioni proprie di una form concreta da quelle ereditate da `TBaseForm`; `nil` se nessuna lo dichiara o il proprietario è nullo. La ricerca per nome vede solo le azioni **possedute direttamente**: un'azione di un proprietario più in alto nella catena non si trova con `FindAction`.

### Scenario: ordine di risoluzione
- **Dato** un componente posseduto da una form `FormUno`, la quale è posseduta da `FormDue`
- **Quando** si chiama `ResolveOwner(Componente, 'FormDue')`
- **Allora** il risultato è `FormDue`
- **E** con nome forzato vuoto o inesistente il risultato è `FormUno`

### Scenario: finestra ospitante
- **Dato** un componente posseduto da un `TzDbViewDlg`, a sua volta posseduto dalla form `FormUno`
- **Quando** si chiama `ResolveOwner(Componente, '')`
- **Allora** il risultato è `FormUno`, non il `TzDbViewDlg`

### Scenario: azione omonima non azione
- **Dato** un proprietario con un componente `Salva` che non è un'azione
- **Quando** si chiama `FindAction(Proprietario, 'Salva')`
- **Allora** il risultato è `nil`

### Scenario: classe che dichiara il campo
- **Dato** una classe derivata da una classe base che dichiara il campo `Salva`
- **Quando** si chiama `DeclaringClass` su un'istanza della derivata con nome `Salva`
- **Allora** il risultato è la classe base

## Divergenze note
Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce «R-213» di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zToolActions.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-TLA-4 🟢 (dedotta) | `Description` (512-529) guarda solo `ToolbarProps` e, con la barra nascosta in tutti e due i contesti, risponde ` [solo card]` (il primo ramo scatta per `VisibleInView` falso senza controllare `VisibleInCard`) | L'assistente descrive come «solo scheda» un'azione che non compare mai sulla barra; il menu a comparsa non è considerato |
| DIV-TLA-5 🟢 (dedotta) | `AssignDefaultImageList` (313-334) comincia con `Exit; // da eliminare` e il resto è codice morto, con la scelta delle liste invertita (il pulsante grande riceve la lista piccola); è chiamata otto volte in `Init_Controls.pas` di WT | Le chiamate di WT non fanno niente: chi legge `Init_Controls.pas` crede che le immagini predefinite vengano assegnate. Il codice morto inganna e, se riattivato, scambierebbe le dimensioni |
| DIV-TLA-6 🟢 (dedotta) | Nel menu a comparsa `CreateButtons` (427-428) chiama `AddPopupLink` con `InsertAtBegin` predefinito vero (`zDxBarHelper.pas`, 248-263): ogni azione è messa all'inizio, e `Position` e `BeginGroup` non si applicano | Il menu mostra le azioni in ordine inverso a quello della barra e senza separatori; se non è voluto, la posizione configurata in `zToolConfigDlg` vale solo per la barra |
| DIV-TLA-7 🟢 (dedotta) | `TzToolAction.GetImageList` (599-608) legge `Base.ImageList24` e `Base.ImageList16` senza controllare che il globale `Base` esista | Senza `TzSystem` creato (strumenti da riga di comando, prove automatiche) una voce senza lista immagini assegnata va in violazione di accesso nella costruzione dei pulsanti |
| DIV-TLA-8 🟢 (dedotta) | `BuildFromProps` (1038-1048) ignora in silenzio le voci il cui nome non corrisponde a nessuna azione del proprietario risolto | Un nome sbagliato nel dizionario, o un proprietario risolto male (ZBASE-TLA-010), fa sparire il pulsante senza alcuna traccia nel registro |
| DIV-TLA-9 🟢 (dedotta) | `TzToolAction` ha `LargeButton` e `ImageList` pubblicati, ma `TzToolActionProps` non li ha e `BuildFromProps` non li copia (lo dice il commento di `TzDbView.AddAction`) | Le azioni configurate da dizionario usano sempre la lista da 16 punti; i pulsanti grandi sono raggiungibili solo con `Add` diretto sull'elenco in esecuzione |
| DIV-TLA-10 🟢 (dedotta) | `DumpActions` (197-208) è una funzione di debug che apre una finestra modale (`ConfirmOk`) e non ha chiamanti in `SRC`; `TzToolActions.Destroy` (245-250) non libera i pulsanti e i sottomenu, che appartengono al proprietario | Codice morto esposto nell'interfaccia; i pulsanti sopravvivono all'elenco fino alla distruzione del proprietario |

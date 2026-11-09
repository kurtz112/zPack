---
area: Dialogo della scheda
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/001
---

# Dialogo della scheda

Questa specifica descrive il componente `TzDbCardDlg` e la sua finestra `TzDbCardForm` (unit `zBase\zDbCardDlg.pas` e `zDbCardDlg.dfm`): una finestra modale che mostra una scheda (`TzDbCard`) per inserire o modificare il record corrente di un dataset. La disposizione dei campi, i comandi interni della scheda e le sue regole di modifica sono descritti dalle specifiche della scheda (`ZDBCARD-CTL`, `ZDBCARD-LAY`, `ZDBCARD-LKP`, `ZDBCARD-CMD`, rilascio `OUT/20261101-specifiche-vive-zdbcard/001`, non ancora integrato in `SRC`): qui si descrive solo il contenitore. La unit è compilata perché la richiamano `zDbView.pas` e `zDbRecordView.pas` (la riga `zDbCardDlg` in `zCommon\zBase_Common_104.dpk` è un residuo dopo `end.`, non una voce di `contains`).

I punti d'ingresso sono tre. Ogni `TzDbView` contiene un suo `zDbCardDlg` (proprietario: la vista), che si apre con il doppio clic sulla riga, con «Inserisci» e con l'azione «Scheda» (`TzDbView.ShowDbCard`, `ShowCardExecute`). Poi ci sono 26 file `.dfm` di WT e Gesty con un `TzDbCardDlg` autonomo (di solito `card...` in un DataModule, proprietario: il DataModule), aperto da codice con `Execute` (per esempio `cardOrario.Execute`, `cardPrenotazioni.Execute`, `cardNuovoOperatore.Execute`). Infine `TzDbRecordView` ne usa uno proprio.

**Come funziona.** `Execute` richiede un dataset; crea la finestra la prima volta e la riusa nelle aperture successive; la prepara (identificativo della scheda, azioni, eventi), la mostra in modo modale e restituisce vero se l'utente ha chiuso con OK. A OK la scheda salva il record (`Post`), con qualunque altro esito annulla la modifica in corso (`Cancel`). La finestra compare trasparente e diventa visibile solo quando la scheda ha la disposizione definitiva.

**Test che coprono quest'area.** Nessuno in `_UnitTest\_src`. La bozza `Test.zDbDlg.pas` prova solo ciò che non apre finestre: valori predefiniti, proprietà, `ReadOnly` senza finestra, errore di `Execute` senza dataset, distruzione senza finestra (requisiti `ZBASE-DCD-001`, `-002`, `-004` e `-008`). La funzione che calcola la firma delle azioni (`FirmaToolActions`) è privata (`ZBASE-DCD-005`) e non si può chiamare da una unit di prova.

## ZBASE-DCD-001 Contratto di Execute
`Execute` solleva l'eccezione «Dataset non assegnato: » seguita dal nome del componente se `DataSet` non è assegnato, prima di creare la finestra. Altrimenti: crea la finestra se non esiste (`CreateForm`); scrive `Caption` nella finestra se non è vuota (ma vedi `DIV-DCD-7`); configura l'identificativo della scheda (`ZBASE-DCD-005`, `-006`); richiama `OnInitDialog`; assegna il `PopupParent` (la prima `TCustomForm` risalendo i proprietari, altrimenti la finestra attiva); trasmette `OnBeforeExecute`; esegue `TzDbCardForm.Execute`; infine richiama `OnCloseDialog`. Restituisce vero solo con OK.

Se `TzDbCardForm.Execute` solleva un errore, il componente distrugge la finestra (`FreeAndNil`) e rilancia l'errore: `OnCloseDialog` non scatta e la prossima apertura ricostruirà la finestra da zero. Il dataset non viene aperto dal dialogo: se non è attivo la scheda non ha niente da mostrare (la vista chiamante, `ShowDbCard`, esce senza aprire la scheda se il dataset non è attivo o è vuoto).

### Scenario: dataset mancante
- **Dato** un `TzDbCardDlg` di nome `dlgScheda` senza `DataSet`
- **Quando** si chiama `Execute`
- **Allora** sale un'eccezione con messaggio `Dataset non assegnato: dlgScheda`
- **E** `zDbCardForm` resta `nil`

### Scenario: errore durante la comparsa
- **Dato** una scheda che solleva un errore mentre si apre
- **Quando** l'errore esce da `TzDbCardForm.Execute`
- **Allora** la finestra è distrutta, l'errore risale al chiamante e `OnCloseDialog` non scatta

## ZBASE-DCD-002 Valori predefiniti e proprietà
Dopo `Create`: `Caption` e `CardID` sono vuoti, `DataSet` e `zSystem` sono `nil`, `zDbCardForm` è `nil`, `ReadOnly` è falso (e non risulta ancora assegnato), tutti gli eventi sono non assegnati. `Caption`, `CardID`, `DataSet`, `zSystem` e gli eventi sono pubblicati; `ReadOnly` e `zDbCardForm` no. Cambiare `DataSet` con un valore diverso distrugge la finestra esistente (`DestroyForm`), perché la scheda è costruita sul dataset; assegnare lo stesso dataset non fa niente. Impostare `Caption`, `CardID` o un evento di sola memorizzazione non crea la finestra.

### Scenario: componente appena creato
- **Dato** un `TzDbCardDlg` creato con `Create(nil)`
- **Quando** si leggono le proprietà
- **Allora** `Caption` e `CardID` sono `''`, `ReadOnly` è falso e `zDbCardForm` è `nil`

### Scenario: cambio di dataset
- **Dato** una finestra già creata su `Servizi`
- **Quando** si assegna `DataSet = lkServizi`
- **Allora** la finestra viene distrutta e la prossima `Execute` ne crea una nuova

## ZBASE-DCD-003 Salvare o annullare alla chiusura
A decidere se salvare è il pulsante con cui l'utente chiude la finestra, non il chiamante. In `FormCloseQuery`:
- se il dataset della scheda non è assegnato la chiusura è libera;
- con `ModalResult = mrOk`, la scheda esegue `Post`: porta a termine la modifica dell'editor attivo (`PostEditValue`) e poi chiama `DataController.CheckBrowseMode`, che salva il record se il dataset è in inserimento o in modifica;
- con qualunque altro risultato (Annulla, X, Esc, chiusura da codice con `mrCancel`), se il dataset è in `dsEdit` o `dsInsert` la scheda esegue `Cancel` e il record in corso si perde; in `dsBrowse` non fa niente.

Il pulsante OK della finestra è abilitato solo se, quando il dataset è in modifica, tutti i campi obbligatori hanno un valore (`RequiredFieldsOk`); Annulla è sempre abilitato. L'abilitazione si riaggiorna a ogni cambio di stato e di dato del dataset (`ButtonsDataSource`). La chiusura sblocca anche i pulsanti premuti (`OkCancel.ResetButtons`).

Il chiamante ottiene quindi: esito vero = record già salvato (dataset tornato in navigazione); esito falso = nessuna modifica rimasta in sospeso. `TzDbView.ShowRecord` si fida di questo: con esito vero fa solo `CheckBrowseMode` (già fatto), con esito falso annulla se il dataset è ancora in modifica (per esempio dopo un inserimento).

### Scenario: OK con record valido
- **Dato** un record in modifica con tutti i campi obbligatori compilati
- **Quando** l'utente preme OK
- **Allora** il record viene salvato, `Execute` restituisce vero e il dataset è in `dsBrowse`

### Scenario: OK non disponibile
- **Dato** un record in inserimento con un campo obbligatorio vuoto
- **Quando** la scheda si apre
- **Allora** il pulsante OK è disabilitato e Annulla è abilitato

### Scenario: annullo di un inserimento
- **Dato** un dataset in `dsInsert`
- **Quando** l'utente chiude con la X
- **Allora** `Execute` restituisce falso e il record in inserimento viene scartato (`Cancel`)

## ZBASE-DCD-004 Sola lettura
La proprietà `ReadOnly` del componente (non pubblicata, impostabile solo da codice) governa la sola lettura della scheda: la prima assegnazione, vera o falsa, la rende «assegnata». Se è assegnata, alla creazione della finestra (e subito, se la finestra esiste già) imposta `zDbCard.ReadOnly` a `crForceReadOnly` con vero e a `crForceWriteable` con falso. Se non è mai stata assegnata, non tocca la scheda, che usa le proprie impostazioni e le restrizioni (`crUseLoadedProps`, specifica `ZDBCARD-CTL-002`). Non esiste un modo, dal dialogo, di tornare a `crUseLoadedProps` dopo un'assegnazione (`DIV-DCD-3`).

Per lo stesso scopo i chiamanti usano anche `zDbCardForm.zDbCard.ReadOnly` direttamente (`frmIntestatari`, `dmRegistroStudenti`, `frmRC_Ingiunzioni`). In Gesty `dmScheduler.Tools` imposta `ReadOnly := True` su sette schede (`cardOrario`, `cardAgenda`, `cardFuoriSede`, `cardPrenotazioneAule`, `cardRilevamento`, `cardRiunioni`, `cardScadenze`) e in WT su `cardPrenotazioni`.

### Scenario: scheda in sola lettura
- **Dato** `ReadOnly := True` prima di `Execute`
- **Quando** la finestra viene creata
- **Allora** `zDbCard.ReadOnly` vale `crForceReadOnly`

### Scenario: scrittura forzata
- **Dato** `ReadOnly := False` e una vista con `RestrictionReadOnly` vero
- **Quando** si apre la scheda
- **Allora** la scheda è scrivibile (`crForceWriteable`) anche con la restrizione (`DIV-DCD-3`)

### Scenario: mai assegnata
- **Dato** un dialogo su cui `ReadOnly` non è mai stato impostato
- **Quando** si crea la finestra
- **Allora** la modalità di sola lettura della scheda resta quella delle sue impostazioni

## ZBASE-DCD-005 Scheda aperta da una vista
Se il proprietario del componente è un `TzDbView` (è il caso del `zDbCardDlg` interno di ogni vista), `Execute` ignora `CardID` del dialogo e chiama `SetMasterView`, che a ogni apertura:
1. imposta come identificativo della scheda `CardID` della vista, o in sua assenza `ViewID`;
2. copia le `ToolActions` della vista nella scheda (`Assign`) solo se sono cambiate dall'ultima copia fatta in quella finestra: lo si capisce da una firma testuale (`FirmaToolActions`, funzione di classe privata) che comprende, per ogni azione, indirizzo dell'azione e della lista immagini, gruppo, pulsante grande, didascalia, posizione e visibilità in scheda e in vista di menu e barra. Una finestra nuova ha la firma segnaposto `<da copiare>`, quindi copia sempre, anche se la vista non ha azioni. Perché: `Assign` fa ricostruire la barra degli strumenti della scheda, costoso se si ripete senza bisogno;
3. copia nella scheda i sei eventi di creazione dei controlli e i tre eventi `OnDataSetDelete`, `OnDataSetEdit`, `OnDataSetInsert` **della vista**, sovrascrivendo quelli del dialogo (anche quando sono `nil`);
4. se la vista ha `Flags.CardInherits`, porta nella scheda i divieti: `DisableDelete = not ButtonDelete`, `DisableInsert = not ButtonInsert`, `DisableEdit = not ButtonUpdate`;
5. porta nella scheda `RestrictionReadOnly` della vista (il permesso di sola lettura da `zRestrictions`).

Gli eventi impostati direttamente sul `zDbCardDlg` di una vista sono quindi inefficaci per gli eventi di creazione e di dataset (`DIV-DCD-2`); si usano gli eventi `OnCard*` e `OnDataSet*` della vista. `OnInitDialog`, `OnBeforeExecute` e `OnCloseDialog` del dialogo invece funzionano.

### Scenario: due aperture con le stesse azioni
- **Dato** una vista con due azioni e una scheda già aperta una volta
- **Quando** si riapre la scheda senza toccare le azioni
- **Allora** le azioni non vengono copiate di nuovo

### Scenario: azione rimossa
- **Dato** una vista a cui è stata tolta un'azione dopo la prima apertura
- **Quando** si riapre la scheda
- **Allora** la firma è cambiata e le azioni vengono copiate di nuovo

### Scenario: divieti ereditati
- **Dato** `Flags.CardInherits` vero e `ButtonDelete` falso
- **Quando** si apre la scheda
- **Allora** `zDbCard.DisableDelete` è vero

## ZBASE-DCD-006 Scheda autonoma
Se il proprietario non è un `TzDbView` (un DataModule o una form), `Execute` assegna alla scheda il `CardID` del dialogo; se `CardID` è vuoto la scheda ricava l'identificativo dall'identificativo del dataset (`GetID_DataSet`). Gli eventi della creazione dei controlli e del dataset sono quelli impostati sul dialogo, collegati alla scheda alla creazione della finestra e, poi, a ogni assegnazione (i setter inoltrano a una finestra già esistente). Nei `.dfm` di WT e Gesty i `TzDbCardDlg` autonomi collegano `CardID` (10 volte), `OnDataSetInsert` (4), `OnInitDialog` (2) e pochi altri eventi. La finestra prende il nome `zDbCardForm__<proprietario>__<componente>`, per non collidere con altre schede.

### Scenario: identificativo esplicito
- **Dato** un dialogo autonomo con `CardID = 'RettificaRecapito'`
- **Quando** si chiama `Execute`
- **Allora** la scheda usa l'identificativo `RettificaRecapito`

### Scenario: identificativo ricavato
- **Dato** un dialogo autonomo con `CardID` vuoto su un dataset `Orario`
- **Quando** si chiama `Execute`
- **Allora** l'identificativo della scheda è quello del dataset

## ZBASE-DCD-007 Ordine degli eventi
Gli agganci del chiamante scattano in quest'ordine:
1. `OnInitDialog(zDbCardForm)`: dopo la configurazione dell'identificativo, delle azioni e degli eventi, prima di mostrare la finestra. La finestra esiste già, ma la scheda non ha ancora né dataset né controlli (li assegna `TzDbCardForm.Execute`) e titolo e larghezza sono ancora da calcolare: ciò che si scrive qui su titolo e larghezza viene sovrascritto da `LoadProps` (`DIV-DCD-7`);
2. `OnBeforeExecute(zDbCardForm)`: dentro `TzDbCardForm.Execute`, dopo `LoadProps` (che assegna a scheda sistema e dataset, calcola titolo e larghezza) e prima della traduzione e della comparsa; qui la scheda ha i dati e il chiamante può cambiare i controlli;
3. la finestra si mostra e si chiude;
4. `OnCloseDialog(zDbCardForm)`: dopo la chiusura, con OK **e** con Annulla, con la finestra ancora esistente (viene distrutta solo dal distruttore del componente, dal cambio di dataset o da `DestroyControls`).

`TzDbCardForm.Execute` imposta `zDbCard.Visible := False` e abilita la sorgente dati della scheda prima di tutto; alla fine la disabilita, perché la scheda non reagisca agli spostamenti del dataset mentre la vista padrone scorre. Prima di costruire la finestra chiude i filtri della vista rimasti aperti (`dx.ChiudiFiltriAperti`, Mantis #269): la scheda non deve avere accanto un filtro cliccabile.

### Scenario: titolo cambiato in OnBeforeExecute
- **Dato** un gestore `OnBeforeExecute` che scrive `Dialog.Caption`
- **Quando** si apre la scheda
- **Allora** il titolo scelto dal gestore è quello visibile (vince su `LoadProps`)

### Scenario: chiusura con Annulla
- **Dato** un gestore `OnCloseDialog`
- **Quando** l'utente annulla
- **Allora** il gestore scatta comunque, dopo che la scheda ha annullato la modifica

## ZBASE-DCD-008 Riuso e distruzione della finestra
La finestra non si distrugge a ogni chiusura: resta nel componente e si riusa all'apertura successiva (`CreateForm` non fa niente se esiste). Si distrugge in questi casi:
- nel distruttore del componente;
- con `DestroyForm` o `DestroyControls` (sinonimi: il secondo chiama il primo), richiamati dalla vista quando le impostazioni del dataset cambiano (`zDbView`, dopo `DataSetEditProps`) e quando alla vista si assegna un altro dataset;
- cambiando `DataSet`;
- dopo un errore in `Execute` (`ZBASE-DCD-001`).

`DestroyForm` non fa niente senza finestra; con la finestra visibile la chiude (`Close`) prima di distruggerla, e riporta `zDbCardForm` a `nil`. Dopo la distruzione, `CreateForm` ricostruisce tutto, compresa la firma delle azioni (`<da copiare>`). `TzDbView.CloseCard(doPost)` chiude la scheda visibile da codice, con `mrOk` o `mrCancel`, e quindi con le regole di `ZBASE-DCD-003`.

### Scenario: riuso
- **Dato** una scheda aperta e chiusa una volta
- **Quando** si richiama `Execute`
- **Allora** viene riusata la stessa finestra, senza ricostruire i controlli

### Scenario: distruzione senza finestra
- **Dato** un dialogo mai aperto
- **Quando** si chiama `DestroyForm` o `DestroyControls`
- **Allora** non succede niente e `zDbCardForm` resta `nil`

## ZBASE-DCD-009 Tastiera e finestra
Con `KeyPreview` attivo, la finestra tratta il tasto Invio come passaggio al campo successivo (`Wm_NextDlgCtl`), e Maiusc+Invio come passaggio al campo precedente, senza chiudere la scheda. Fanno eccezione, e l'Invio passa al controllo: un memo (anche RTF) attivo, oppure una tendina aperta (`DroppedDown`). L'Invio quindi non chiude la scheda: per chiuderla si usano i pulsanti OK e Annulla. Alla creazione la posizione è `poMainFormCenter`. La minimizzazione (`SC_MINIMIZE`) minimizza invece il pulsante dell'applicazione (`Application.Handle`, `SW_SHOWMINNOACTIVE`) e non la finestra; all'attivazione (`WM_ACTIVATE`) la finestra ripristina il pulsante dell'applicazione e si porta davanti. Alla prima comparsa, se il dataset è in `dsInsert`, la scheda forza la copia dei valori dei lookup (`ForceCopyMappingFields`).

### Scenario: Invio in un campo di testo
- **Dato** il fuoco su un campo di testo
- **Quando** l'utente preme Invio
- **Allora** il fuoco passa al campo successivo e la scheda resta aperta

### Scenario: Invio in un memo
- **Dato** il fuoco in un memo
- **Quando** l'utente preme Invio
- **Allora** il memo va a capo e il fuoco non si sposta

## ZBASE-DCD-010 Comparsa ritardata e dimensioni
La prima disposizione della scheda si calcola su una larghezza stimata; la vera si conosce solo a finestra mostrata. Perciò `Execute` mostra la finestra trasparente (`BeginHiddenSettle`: `AlphaBlend` con valore 0) e la rende visibile (`EndHiddenSettle`: valore 255, poi `AlphaBlend` spento) solo a disposizione assestata: dopo `FormShow` il dialogo ripete il calcolo dell'altezza e ripropone un comando di comparsa (`DLG_CMD_REVEAL`) finché `zDbCard.EnsureLayoutSettled` non risponde vero, oppure fino a 30 tentativi (`MAX_REVEAL_ATTEMPTS`): oltre, il dialogo si mostra comunque, «meglio un salto che una finestra invisibile». A quel punto l'altezza è definitiva (`UpdateHeight`), il dialogo si ricentra sulla finestra principale (`CenterOnMainForm`, se la posizione è `poMainFormCenter` e la finestra principale è visibile), tenuto dentro l'area di lavoro del monitor in cui si trova. La finestra torna sempre opaca, anche se `ShowModal` solleva un errore (`try/finally`).

Larghezza e altezza: all'apertura `ClientWidth` vale la larghezza della scheda (`GetDialogWidth`, specifica `ZDBCARD-CTL-008`); `UpdateHeight` porta `ClientHeight` all'altezza calcolata della scheda più l'altezza del pannello OK/Annulla più 7 pixel, e non lascia la finestra più alta dell'area di lavoro del monitor meno 50 pixel (barra delle applicazioni). Le dimensioni non si ricordano per utente (diversamente da `ZBASE-DVW-003`): le salva la scheda nelle sue impostazioni (`ZDBCARD-CTL-009`).

### Scenario: scheda lunga
- **Dato** una scheda più alta dell'area di lavoro del monitor
- **Quando** si apre
- **Allora** l'altezza della finestra è l'altezza dell'area di lavoro meno 50 pixel

### Scenario: layout che non si assesta
- **Dato** una scheda per cui `EnsureLayoutSettled` resta falso
- **Quando** passano 30 tentativi
- **Allora** la finestra viene resa visibile comunque

## ZBASE-DCD-011 Eventi inoltrati alla scheda
Gli eventi `OnDataSetDelete`, `OnDataSetEdit`, `OnDataSetInsert` (eseguiti dalla scheda quando l'utente elimina, modifica o inserisce un record, e che consentono al chiamante di intervenire) e `OnBeforeCreateControls`, `OnAfterCreateControls`, `OnBeforeCreateControl`, `OnAfterCreateControl`, `OnBeforeCreateDbControl`, `OnAfterCreateDbControl` (la costruzione dei controlli) si collegano alla scheda alla creazione della finestra. I setter di `OnDataSet*`, `OnBeforeCreateControls`, `OnAfterCreateControls`, `OnBeforeCreateControl` e `OnAfterCreateControl` inoltrano il nuovo valore a una finestra già esistente; quelli di `OnBeforeCreateDbControl` e `OnAfterCreateDbControl` no (`DIV-DCD-1`). Gli eventi di costruzione dei controlli scattano quando la scheda ricostruisce i controlli (alla prima apertura e dopo `DestroyControls`), quindi sono rari: per intervenire a ogni apertura servono `OnInitDialog` o `OnBeforeExecute`.

### Scenario: evento impostato con finestra aperta
- **Dato** una finestra già creata
- **Quando** si assegna `OnDataSetInsert`
- **Allora** la scheda esistente usa subito il nuovo gestore

### Scenario: evento DbControl con finestra già creata
- **Dato** una finestra già creata
- **Quando** si assegna `OnBeforeCreateDbControl`
- **Allora** la scheda esistente non lo riceve; lo riceverà solo alla prossima creazione (`DIV-DCD-1`)

## Divergenze note
Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DCD-1 🟢 (dedotta) | `SetOnBeforeCreateDbControl` e `SetOnAfterCreateDbControl` memorizzano il valore ma non lo inoltrano alla finestra già creata, mentre tutti gli altri setter lo fanno | Un gestore assegnato dopo la prima apertura non vale fino alla ricostruzione della finestra |
| DIV-DCD-2 🟡 (dedotta) | In un `zDbCardDlg` posseduto da una `TzDbView`, `SetMasterView` sovrascrive a ogni `Execute` i sei eventi di creazione e i tre `OnDataSet*` con quelli della vista, anche se `nil` | Un gestore collegato direttamente al `zDbCardDlg` della vista (per esempio da codice dopo `CreateForm`) va perso al primo `Execute`, senza avviso |
| DIV-DCD-3 🟡 (dedotta) | `ReadOnly := False` imposta `crForceWriteable`, che prevale anche su `RestrictionReadOnly`, e dopo un'assegnazione non si può tornare a `crUseLoadedProps` | Un chiamante che vuole solo «non forzare» e scrive `ReadOnly := False` rende scrivibile una scheda che la restrizione di sicurezza dichiarava in sola lettura. Oggi in WT e Gesty `ReadOnly` si imposta solo a `True` |
| DIV-DCD-4 🟢 (dedotta) | `OkCancelDblClick` è un residuo di prova: con il doppio clic sul pannello OK/Annulla il titolo diventa PPI e larghezza («120 - 800:795») | L'utente che fa doppio clic sul pannello vede il titolo della scheda cambiare in un numero |
| DIV-DCD-5 🟢 (dedotta) | `CreateForm` usa `Owner.Name` senza controllare `Owner`, e chiama `FreeNotification(self)` senza che il componente implementi `Notification` | Con un `TzDbCardDlg` creato con proprietario `nil` il nome della finestra solleva una violazione di accesso; la notifica non fa niente |
| DIV-DCD-6 🟢 (dedotta) | Se `ModalResult = mrOk` e `Post` solleva un errore (per esempio un vincolo del database), `CanClose` è stato messo a falso prima del salvataggio | La finestra resta aperta con il record in modifica e l'errore risale al gestore globale; il comportamento corretto, ma il messaggio e lo stato del pulsante OK dopo l'errore non sono provati. Da verificare sul banco |
| DIV-DCD-7 🟡 (dedotta) | `TzDbCardForm.LoadProps` scrive `Caption` e `ClientWidth` della finestra a ogni apertura (da `GetDialogTitle` e `GetDialogWidth`), dopo che `TzDbCardDlg.Execute` ha scritto `Caption` e dopo `OnInitDialog` | La proprietà `Caption` del dialogo e un titolo impostato in `OnInitDialog` non hanno effetto sul titolo mostrato; solo `OnBeforeExecute` (che scatta dopo `LoadProps`) lo cambia davvero. Nei `.dfm` `Caption` compare spesso su altri componenti: l'effetto sul titolo del dialogo va provato sul banco |

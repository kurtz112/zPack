---
area: Dialogo di selezione della vista
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/002
---

# Dialogo di selezione della vista

Questa specifica descrive il componente `TzDbViewDlg` e la sua finestra `TzDbViewForm` (unit `zBase\zDbViewDlg.pas` e `zDbViewDlg.dfm`): una finestra modale che mostra un `TzDbView` su un dataset, perché l'utente scelga uno o più record. Le unit non sono elencate nei `.dpk` di zBase ma sono compilate perché le richiamano `zDbCard.pas`, `zDX.pas`, `zSystem.pas` e `zToolActions.pas`. Lo usano WT e Gesty: 78 file `.dfm` contengono un `TzDbViewDlg` (di solito un componente `dlg...` o `lk...Dlg` in un DataModule), e le chiamate a `Execute` su questi componenti sono circa duecento. Lo usa anche `zDX` per la finestra di scelta delle tendine con lookup (`TzDbViewDlg.Create(nil)` con `idLookup` valorizzato) e `Base_DbDataModule` (`TzDbViewDlg.Create(Self)`).

**Come funziona.** Chi chiama imposta `DataSet` (e facoltativamente `Caption`, `Options`, `ToolActions`) e chiama `Execute`. Il componente crea ogni volta una `TzDbViewForm` nuova (proprietario `nil`), la prepara (attiva il dataset, costruisce la vista, copia le azioni), la mostra in modo modale e, alla chiusura, la distrugge. Il valore restituito è vero solo se l'utente ha chiuso con OK. Il record scelto è il record corrente del dataset: chi chiama lo legge dopo `Execute`. Con scelta multipla, a OK il componente ripete una procedura o un evento una volta per ogni record selezionato. Con `DestDataSet` e `idLookup` può anche copiare i campi scelti in un altro dataset.

**Test che coprono quest'area.** Nessuno in `_UnitTest\_src`. La bozza `Test.zDbDlg.pas` prova solo ciò che non apre finestre: valori predefiniti, proprietà, eventi memorizzati, errore di `Execute` senza dataset (requisiti `ZBASE-DVW-001`, `-002`, `-008` e `-010`). La finestra è modale e non si può mostrare in un programma di prova.

## ZBASE-DVW-001 Contratto di Execute
`Execute` esiste in due forme: `Execute(MultiSelectProc, BeforeExecuteProc)` e `Execute(aCaption, aDataSet, MultiSelectProc, BeforeExecuteProc)`. Entrambe richiedono un dataset: senza `DataSet` assegnato sollevano l'eccezione «Dataset non assegnato: » seguita dal nome del componente, prima di creare qualunque finestra. Restituiscono vero solo se la finestra si chiude con OK; con Annulla, con la X o con Esc restituiscono falso. La finestra (`zDbViewForm`, campo pubblico) esiste solo durante `Execute`: la crea la chiamata e la distrugge un blocco `finally`, anche se il codice di mezzo solleva un errore, e dopo la chiamata il campo vale `nil`. La forma con `aCaption` scrive `Caption` e `DataSet` nelle proprietà del componente, che restano così anche per le chiamate successive.

Il dialogo non decide niente sul dataset di chi chiama, a parte la copia su `DestDataSet` (`ZBASE-DVW-006`): non fa `Post`, non fa `Cancel`, non cambia lo stato del dataset di scelta. Chi chiama, se `Execute` vale vero, legge i campi del record corrente.

### Scenario: dataset mancante
- **Dato** un `TzDbViewDlg` di nome `dlgProva` senza `DataSet`
- **Quando** si chiama `Execute`
- **Allora** sale un'eccezione con messaggio `Dataset non assegnato: dlgProva`
- **E** `zDbViewForm` resta `nil`

### Scenario: scelta del record
- **Dato** `dlgIntestatari` con `DataSet` valorizzato (come in `dmAgenda`)
- **Quando** l'utente sceglie un record e preme OK
- **Allora** `Execute` restituisce vero e il record corrente del dataset è quello scelto

### Scenario: annullo
- **Dato** la finestra aperta
- **Quando** l'utente la chiude con Annulla
- **Allora** `Execute` restituisce falso e nessuna procedura o evento di scelta multipla viene chiamato

## ZBASE-DVW-002 Valori predefiniti e proprietà
Dopo `Create`: `Caption` è vuota, `DataSet`, `DestDataSet` e `zSystem` sono `nil`, `idLookup` è vuoto, `FindValue` è `null`, `zDbViewForm` è `nil`, tutti gli eventi sono non assegnati, `ToolActions` è una collezione vuota creata dal componente (che la distrugge nel distruttore) e `Options` vale `[ddAutoAppend, ddAutoPost, ddRaiseOnError]` (valore dichiarato `default`, quindi non scritto nel `.dfm` quando è questo). Assegnare `ToolActions` ne copia il contenuto (`Assign`), non sostituisce la collezione. Il significato delle opzioni: `ddAutoAppend` e `ddAutoPost` governano la copia su `DestDataSet` (`ZBASE-DVW-006`), `ddRaiseOnError` decide se un errore di `Post` risale (`ZBASE-DVW-006`), `ddShowSelectBtns` mostra Tutti e Nessuno (`ZBASE-DVW-007`), `ddClearFilterOnExit` azzera i filtri della vista alla chiusura (`ZBASE-DVW-004`).

Nei progetti reali le impostazioni più usate nei `.dfm` sono `[ddAutoAppend, ddAutoPost, ddClearFilterOnExit, ddRaiseOnError]` (9 volte), `[]` (6), `[ddClearFilterOnExit]` (4) e `[ddAutoAppend, ddAutoPost, ddShowSelectBtns, ddRaiseOnError]` (3).

### Scenario: componente appena creato
- **Dato** un `TzDbViewDlg` creato con `Create(nil)`
- **Quando** si leggono le proprietà
- **Allora** `Options` è `[ddAutoAppend, ddAutoPost, ddRaiseOnError]`, `Caption` è `''`, `FindValue` è `null` e `ToolActions.Count` è 0

## ZBASE-DVW-003 Preparazione e aspetto della finestra
Prima di mostrare la finestra, `TzDbViewForm.Execute` e `Init` fanno, in quest'ordine:
1. se il testo SQL del dataset non è vuoto, lo attivano (potrebbe arrivare spento); un errore di apertura non interrompe: lo gestisce `Application.HandleException`;
2. assegnano a `zDbView` il sistema e il dataset e adattano le colonne alla larghezza dei dati (`ApplyBestFit`);
3. portano `ClientHeight` e `ClientWidth` ai valori `DlgHeight` e `DlgWidth` delle impostazioni della vista, con il ricalcolo da ridimensionamento sospeso;
4. richiamano `OnBeforeExecute` (`ZBASE-DVW-004`);
5. se la vista ha azioni, le inizializzano (`InitToolActions`); le azioni vengono dal componente (`ToolActions`, copiate con `Assign`);
6. se la `Caption` è vuota, usano il titolo della vista (`GetDbViewProps.Title`);
7. leggono posizione e dimensione dal file `.Dlgs` dell'utente (`LoadFormPosition`, sezione `idLookup` oppure, se vuoto, `<classe del proprietario>.<nome del componente>`: DIV-DVW-3), poi chiamano `BeforeExecuteProc` (`ZBASE-DVW-004`);
8. traducono i testi con `Localizer` (chiave: `ViewID` della vista), impostano `DefaultMonitor = dmDesktop` e mostrano la finestra in modo modale.

Chiusa la finestra, posizione e dimensione si salvano (`SaveFormPosition`) anche con Annulla. Ogni ridimensionamento riporta `DlgHeight` e `DlgWidth` nelle impostazioni della vista. La finestra ha come `PopupParent` la prima `TCustomForm` che si trova risalendo i proprietari del componente (`GetPopupParent`); se il proprietario è un DataModule, quindi, ripiega sulla finestra attiva (`Screen.ActiveCustomForm`).

Il componente richiede `zSystem` assegnato: ne serve il nome del file di configurazione (`ConfigFileName('.Dlgs')`) e, con `idLookup`, la raccolta `zLookups`. Il codice non lo controlla (`DIV-DVW-6`).

### Scenario: titolo mancante
- **Dato** un dialogo con `Caption = ''` su una vista il cui titolo è `Elenco comuni`
- **Quando** la finestra si apre
- **Allora** il titolo della finestra è `Elenco comuni`

### Scenario: dataset spento
- **Dato** un dataset non attivo con testo SQL non vuoto
- **Quando** si chiama `Execute`
- **Allora** il dataset viene aperto prima di costruire la vista

## ZBASE-DVW-004 Ordine di eventi e procedure
Gli agganci del chiamante scattano in quest'ordine:
1. `OnInitDialog(zDbViewForm)`: dopo aver copiato nella finestra caption, sistema, dataset, `idLookup`, `ToolActions`, `FindValue` e i collegamenti di scelta multipla, **prima** di `PopupParent` e di `TzDbViewForm.Execute`. La finestra esiste già, quindi il chiamante può agire su `zDbViewForm.zDbView` (per esempio aggiungere una condizione di filtro prima che la vista si costruisca);
2. `OnBeforeExecute(zDbViewForm)`: dentro `TzDbViewForm.Execute`, dopo `Init` e prima di `InitToolActions`;
3. `BeforeExecuteProc` (parametro di `Execute`): dopo il caricamento della posizione, subito prima della traduzione e della comparsa; è il punto per `AddFilterCondition` quando serve la vista già costruita (esempio: `dmAgenda`, filtro sull'intestatario);
4. la finestra si mostra;
5. a OK e con dataset non vuoto, la scelta multipla (`ZBASE-DVW-005`);
6. `OnCloseDialog(zDbViewForm)`: dopo la chiusura, con OK **e** con Annulla, con la finestra ancora esistente;
7. con `ddClearFilterOnExit`, `zDbView.ClearFilter(DataSet.Active)`: dopo `OnCloseDialog`;
8. con `idLookup` risolto, `zLookup.UpdateDisplayColumnsFromView(True)`: riporta nel lookup l'ordine e la visibilità delle colonne decisi dall'utente, anche con Annulla.

Se `TzDbViewForm.Execute` solleva un'eccezione, i passi 6-8 non vengono eseguiti; la finestra si distrugge comunque.

### Scenario: filtro iniziale dal chiamante
- **Dato** un `BeforeExecuteProc` che chiama `zDbViewForm.zDbView.AddFilterCondition('ID_INTESTATARIO', foEqual, 12)`
- **Quando** si chiama `Execute`
- **Allora** la condizione è aggiunta dopo che la vista è stata costruita e prima che la finestra compaia

### Scenario: pulizia dei filtri
- **Dato** `ddClearFilterOnExit` in `Options` e un filtro impostato dall'utente nella finestra
- **Quando** la finestra si chiude, con OK o con Annulla
- **Allora** i filtri della vista vengono azzerati dopo `OnCloseDialog`

## ZBASE-DVW-005 Scelta multipla
Se la finestra si chiude con OK, il dataset non è vuoto e c'è una procedura (`MultiSelectProc`, parametro di `Execute`) o un evento di scelta multipla, la finestra scorre i record selezionati con `GetSelectedRows` (specifica `ZDBVIEW-SEL-001` e `ZDBVIEW-SEL-005`): una chiamata per ogni record selezionato, oppure una sola, sul record corrente, se nessuno è selezionato. La procedura ha la precedenza sull'evento. L'evento della finestra è impostato dal componente se è assegnato `MultiSelectEvent` oppure se sono assegnati `DestDataSet` e il lookup (`ZBASE-DVW-006`); in quel caso il componente passa alla finestra `Internal_MultiSelectEvent`, che richiama `MultiSelectEvent` se esiste.

La forma lunga `Execute(aCaption, aDataSet, MultiSelectProc, BeforeExecuteProc)` inoltra la procedura di scelta ma non `BeforeExecuteProc` (`DIV-DVW-1`). Con Annulla niente viene chiamato.

Il gestore tipico (`dlgEmissioniMultiSelectEvent` in `dmAccertamenti`) legge il record corrente del dataset di scelta e fa `Append` e `Post` su un altro dataset: prima di ogni chiamata il dataset di scelta è già posizionato sul record da trattare, quindi il gestore non deve scorrere niente. Circa venti componenti nei `.dfm` collegano `MultiSelectEvent`.

### Scenario: tre record selezionati
- **Dato** tre righe selezionate e un `MultiSelectEvent` collegato
- **Quando** l'utente preme OK
- **Allora** l'evento scatta tre volte, ognuna con il dataset di scelta sul record selezionato corrispondente

### Scenario: nessuna riga selezionata
- **Dato** nessuna riga selezionata e il cursore sul terzo record
- **Quando** l'utente preme OK
- **Allora** l'evento scatta una volta, sul terzo record

### Scenario: procedura ed evento insieme
- **Dato** una `MultiSelectProc` passata a `Execute` e un `MultiSelectEvent` collegato
- **Quando** l'utente preme OK
- **Allora** scatta solo la procedura

## ZBASE-DVW-006 Copia automatica su DestDataSet
Se non c'è `MultiSelectEvent` ma ci sono `DestDataSet` e il lookup dell'`idLookup`, per ogni record scelto `Internal_MultiSelectEvent` esegue, nell'ordine: `DestDataSet.Append` se `ddAutoAppend` è in `Options`; `DestDataSet.CopyMappingFields(DataSet, zLookup.Mappings, False)` (copia i campi secondo le associazioni del lookup); `DestDataSet.Post` se `ddAutoPost` è in `Options`. Se il `Post` fallisce, il dialogo fa `DestDataSet.Cancel` e rilancia l'errore solo con `ddRaiseOnError`; senza quell'opzione l'errore sparisce in silenzio e la scelta multipla prosegue con il record successivo. Con il dataset di scelta vuoto la procedura non fa niente. Senza `ddAutoAppend` la copia avviene sul record corrente di `DestDataSet` (che deve essere già in modifica o in inserimento).

Funziona solo con `idLookup` valorizzato: senza il lookup non ci sono associazioni da copiare e `Internal_MultiSelectEvent` non fa niente. Nei `.dfm` di WT `DestDataSet` compare quattro volte (in `dmAccertamenti`, `dmQta_Condomini` e `dmSolleciti`) e nessuno di quei dialoghi ha `idLookup` nel `.dfm`; l'unico che lo imposta da codice è `dmGera_ManutenzioniScheda` (`dlg.idLookup := lkDataSet.IdDataSet`). Vedi anche `DIV-DVW-2`.

### Scenario: copia con Post
- **Dato** `DestDataSet`, `idLookup` già noto al sistema e `Options` predefinite
- **Quando** l'utente sceglie due record e preme OK
- **Allora** in `DestDataSet` compaiono due record con i campi copiati secondo le associazioni del lookup

### Scenario: Post che fallisce senza ddRaiseOnError
- **Dato** `Options = [ddAutoAppend, ddAutoPost]` e un `Post` che solleva un errore
- **Quando** si elabora un record scelto
- **Allora** `DestDataSet.Cancel` viene chiamato e l'errore non risale

## ZBASE-DVW-007 Pulsanti Tutti e Nessuno
La finestra crea due pulsanti, `TuttiBtn` e `NessunoBtn`, sul pannello OK/Annulla (a sinistra, il secondo accanto al primo), collegati alle azioni `Tutti` e `Nessuno`. Le azioni sono visibili solo se `ddShowSelectBtns` è in `Options` (campo `ShowSelectBtns` della finestra, riletto a ogni aggiornamento delle azioni). `Tutti` esegue `zDbView.actSelezionaTutto`, `Nessuno` esegue `zDbView.actNessuno`: selezionano o deselezionano tutte le righe della vista (specifica `ZDBVIEW-SEL-003`). Il campo `ShowSelectBtns` parte falso; senza l'opzione i pulsanti non si vedono.

### Scenario: opzione assente
- **Dato** `Options` senza `ddShowSelectBtns`
- **Quando** la finestra si apre
- **Allora** i pulsanti Tutti e Nessuno non sono visibili

### Scenario: seleziona tutto
- **Dato** `ddShowSelectBtns` attivo e dieci righe
- **Quando** l'utente preme Tutti e poi OK
- **Allora** la scelta multipla tratta tutte le righe

## ZBASE-DVW-008 Ricerca iniziale con FindValue
`FindValue` (proprietà non pubblicata, `Variant`) vale `null` all'inizio. Se è valorizzata, quando la finestra compare (`FormShow`) la vista apre il pannello di ricerca e vi scrive il testo (`zDbView.FindValue`), e il fuoco passa alla vista. Se vale `null` non succede niente. Cambiare `FindValue` mentre la finestra è aperta la aggiorna subito (`SetFindValue` inoltra a `zDbViewForm`). Il valore **non** viene azzerato alla chiusura: la chiamata successiva con lo stesso componente riparte con la stessa ricerca (`DIV-DVW-4`). Nei sorgenti di WT, Gesty e zPack nessuna unit `.pas` imposta `FindValue` oggi; è prevista per i chiamanti che vogliono precompilare la ricerca.

### Scenario: ricerca precompilata
- **Dato** `FindValue = 'rossi'`
- **Quando** la finestra compare
- **Allora** il pannello di ricerca della vista è aperto e contiene `rossi`

### Scenario: nessuna ricerca
- **Dato** `FindValue = null`
- **Quando** la finestra compare
- **Allora** il pannello di ricerca resta come l'utente lo aveva lasciato

## ZBASE-DVW-009 Lookup persistente (idLookup)
Con `idLookup` non vuoto, prima di mostrare la finestra il componente cerca nel sistema (`zSystem.zLookups`) il lookup con quel nome. Se lo trova, lo ricorda (`zLookup`) e usa come vista della finestra quella indicata nel lookup (`zLookup.DbView`). Se non lo trova, ne aggiunge uno con quel nome e salva la raccolta (`SaveZip(csLookups, 'Execute DbViewDlg')`); la vista della finestra resta quella predefinita del dataset. La stessa `idLookup` è anche il nome della sezione del file `.Dlgs` dove si ricordano posizione e dimensione (`ZBASE-DVW-003`). `zDX` la valorizza con l'`IdDataSet` della tendina.

### Scenario: lookup nuovo
- **Dato** `idLookup = 'Comuni.Elenco'` e nessun lookup con quel nome
- **Quando** si chiama `Execute`
- **Allora** ne viene creato uno con quel nome e la raccolta viene salvata

### Scenario: lookup esistente
- **Dato** un lookup `Comuni.Elenco` con `DbView = 'ElencoComuniRidotto'`
- **Quando** si chiama `Execute`
- **Allora** la finestra mostra la vista `ElencoComuniRidotto`

## ZBASE-DVW-010 Eventi della card inoltrati
Il componente espone sei eventi `OnCardBeforeCreateControls`, `OnCardAfterCreateControls`, `OnCardBeforeCreateControl`, `OnCardAfterCreateControl`, `OnCardBeforeCreateDbControl`, `OnCardAfterCreateDbControl`: servono per agganciare la scheda aperta dalla vista della finestra. All'apertura `Execute` ne copia **quattro** nella vista (`zDbView`): quelli di creazione dei controlli e di ogni singolo controllo. I due `...DbControl` non vengono copiati all'apertura (`DIV-DVW-5`); vengono inoltrati solo se si assegnano mentre la finestra esiste (i setter inoltrano a `zDbViewForm.zDbView`). Nei `.dfm` di WT e Gesty nessun `TzDbViewDlg` li collega oggi.

### Scenario: evento impostato prima
- **Dato** `OnCardAfterCreateControls` collegato sul componente
- **Quando** si chiama `Execute`
- **Allora** la vista della finestra lo ha collegato prima di mostrarsi

### Scenario: evento DbControl impostato prima
- **Dato** `OnCardBeforeCreateDbControl` collegato sul componente
- **Quando** si chiama `Execute`
- **Allora** la vista della finestra **non** lo ha collegato (divergenza `DIV-DVW-5`)

## Divergenze note
Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DVW-1 🟡 (dedotta) | `Execute(aCaption, aDataSet, MultiSelectProc, BeforeExecuteProc)` chiama `Execute(MultiSelectProc)` e perde `BeforeExecuteProc` | Chi usa la forma lunga con una procedura «prima di mostrare» (per esempio un filtro iniziale) non la vede mai eseguita. Nessun chiamante di WT o Gesty passa il quarto argomento oggi, quindi il difetto è latente |
| DIV-DVW-2 🟡 (dedotta) | La condizione per usare `Internal_MultiSelectEvent` (`Assigned(DestDataSet) and Assigned(zLookup)`) si valuta **prima** del blocco `idLookup` che assegna `zLookup`; inoltre `zLookup` non si azzera a ogni `Execute` | Alla prima chiamata di un componente con `DestDataSet` e `idLookup` la copia automatica non parte; dalla seconda sì, perché `zLookup` è rimasto dalla prima. Se poi `idLookup` viene svuotato, resta il `zLookup` vecchio. Nei `.dfm` di oggi i quattro `DestDataSet` non hanno `idLookup`, quindi non copiano mai |
| DIV-DVW-3 ✅ (corretta, rilascio 002) | Senza `idLookup` (nessuno dei 78 `.dfm` lo imposta) la sezione del file `.Dlgs` era vuota e `LoadFormPosition` ripiegava sul nome della form, uguale per tutti. Ora `Execute` usa come sezione `<classe del proprietario>.<nome del componente>` (per esempio `TfrmComuni.dlgComuni`); con `idLookup` resta `idLookup`, e senza proprietario o senza nome resta vuota come prima | Ogni dialogo ricorda posizione e dimensione per conto suo. Le misure già salvate nella sezione comune non vengono riprese: la prima volta ogni dialogo si apre con la misura di `DlgHeight`/`DlgWidth`. Non provabile in automatico (finestra modale): da vedere sul banco |
| DIV-DVW-4 🟢 (dedotta) | `FindValue` non viene azzerato dopo la chiusura | Chi riusa il componente e imposta `FindValue` una volta sola ritrova la stessa ricerca a ogni apertura |
| DIV-DVW-5 🟢 (dedotta) | Solo quattro dei sei eventi `OnCard*` sono copiati all'apertura; `OnCardBeforeCreateDbControl` e `OnCardAfterCreateDbControl` sono ignorati a meno di assegnarli con la finestra aperta | Un evento collegato nel `.dfm` o prima di `Execute` non scatta mai |
| DIV-DVW-6 🟢 (dedotta) | `Execute` controlla `DataSet` ma non `zSystem`: `zSystem.ConfigFileName` e `zSystem.zLookups` sono usati senza controllo | Con `zSystem` mancante l'errore è una violazione di accesso, non un messaggio chiaro come per il dataset |
| DIV-DVW-7 🟢 (dedotta) | `Execute(aCaption, aDataSet, ...)` scrive `Caption` e `DataSet` nel componente e non li ripristina | Una chiamata successiva `Execute` senza argomenti riusa titolo e dataset della chiamata precedente |

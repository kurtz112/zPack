---
area: Costruttore di form
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/001
---

# Costruttore di form

Questa specifica descrive `TzFormBuilder` (`zBase\zFormBuilder.pas`), un piccolo costruttore di form scritto a mano: aggiunge gruppi, controlli di modifica, pulsanti e caselle di ricerca dentro un `TdxLayoutControl` già esistente, senza passare dal dizionario LZ. Non va confuso con il costruttore delle form documentali (`TzFormController`, specifica ZBASE-FRM in `Controller dei form.md`), che genera le form dal dizionario: questo serve alle finestre costruite in esecuzione. L'unico utilizzatore dentro zPack è `TzDialog` (`zDialog.pas`), che ne crea uno sul proprio `dxLayoutControl` e lo espone come proprietà `zFormBuilder`; la finestra dei parametri `TzParamDialog` (`zFrmParams.pas`) lo usa per costruire un editor per ogni parametro (`AddControl`), per cambiarne il tipo (`ChangeControlType`) e per ripartire da zero (`Clear`). WT e Gesty lo raggiungono come `zParamDialog.zDialog.zFormBuilder` per personalizzare gli editor delle finestre di parametri: `ChangeControlType` in `dmCommon`, `dmRC_Ingiunzioni`, `dmAssistenzaScolastica`, `dmRisorse`, `frmGRS`, `frmPrenotazioniAule`; `Exists`, `ControlByName`, `LayoutItemByControl` e `AddLayoutGroup` in `frmGRS`. La unit è compilata. `pippo.pas`, nella stessa cartella, ne contiene una copia di prova e non è specificata.

**Come funziona.** Il costruttore possiede i controlli che crea (sono suoi componenti e li tiene in un elenco interno) e le sorgenti dati delle caselle di ricerca (una per dataset). Gruppi ed elementi del layout appartengono invece al `TdxLayoutControl`, che il costruttore non possiede. Ogni aggiunta senza gruppo finisce nel **gruppo predefinito**, creato alla prima necessità. Le funzioni `Add...` di alto livello (`AddTextEdit`, `AddDate`, `AddTime`, `AddCheckBox`, `AddPickList`, `AddLookupCombo`, `AddLookupComboHyperLink`) sono sottili strati su `AddControl`, che a sua volta crea il controllo con `CreateControl` e gli dà un elemento di layout con `AddLayoutItem`. I tipi di controllo sono quelli di `TzCtrlType` (`zBaseLib.pas`) e la classe vera la sceglie `dx.GetCustomEditClass(Tipo, False)`, cioè sempre la versione **non legata a dati** (`TcxTextEdit`, `TcxDateEdit`, `TcxCheckBox`...).

**Test che coprono quest'area.** Nessuna prova esistente in `zPackTests`. Il test `Test.zFormBuilder` prova con un `TdxLayoutControl` non visualizzato: il collegamento al layout e l'azzeramento alla sua distruzione (ZBASE-FRB-001), i gruppi, i nomi e il gruppo predefinito (ZBASE-FRB-002), gli elementi di layout (ZBASE-FRB-003), le ricerche su un costruttore vuoto (ZBASE-FRB-005), il pulsante da azione (ZBASE-FRB-007), la sospensione degli aggiornamenti (ZBASE-FRB-010), `LoadLayout` e `SaveLayout` che non fanno niente (ZBASE-FRB-011) `Clear` con pulsanti e il gruppo predefinito dopo `Clear` (ZBASE-FRB-009) e le divergenze DIV-FRB-2, 3 e 4. Restano senza prova i controlli creati da `dx` (richiedono il modulo `Tdx` con gli stili e il gestore delle immagini), le caselle di ricerca e la finestra di personalizzazione.

## ZBASE-FRB-001 Collegamento al controllo di layout
`TzFormBuilder.Create(Proprietario, ControlloLayout, IdentificativoLayout)` richiede un controllo di layout assegnato (`Assert`) e salva l'identificativo (facoltativo, vuoto per impostazione predefinita) nella proprietà `LayoutID`. `dxLayoutControl` è di sola lettura. Quando il controllo di layout viene liberato e condivide il proprietario del costruttore (è il solo caso in cui `Notification` arriva: il costruttore non chiede `FreeNotification`), il riferimento torna `nil`. Da quel momento `BeginUpdate`, `EndUpdate`, `LayoutItemByName`, `LayoutItemByControl` e `Customize` non fanno niente, ma le funzioni di aggiunta, `Clear` e `ChangeControlType` non controllano il riferimento (DIV-FRB-8). La distruzione libera i due elenchi interni; i controlli e le sorgenti dati sono componenti del costruttore e muoiono con lui.

### Scenario: layout distrutto
- **Dato** un costruttore e un controllo di layout con lo stesso proprietario
- **Quando** si libera il controllo di layout
- **Allora** `dxLayoutControl` del costruttore torna `nil`
- **E** `BeginUpdate` ed `EndUpdate` non sollevano errori

### Scenario: identificativo
- **Dato** un costruttore creato con identificativo `Parametri`
- **Quando** si legge `LayoutID`
- **Allora** vale `Parametri`, e assegnandolo di nuovo vale il nuovo valore

## ZBASE-FRB-002 Gruppi, divisori e nomi
`AddLayoutGroup(Genitore, Nome, Direzione, Titolo, MostraBordo)` crea un gruppo dentro `Genitore`, o nel **gruppo predefinito** se nullo. Il gruppo predefinito (`<nome del layout>DefaultParentGroup`, titolo `DefaultParentGroup`) si crea una volta sola, in verticale, allineato `ahClient` e `avClient`, senza titolo né bordo, direttamente nella radice del layout. Il gruppo creato ha titolo `Titolo` o, se vuoto, il proprio nome; è allineato `ahClient`/`avClient`; ha il bordo **solo se** la direzione è a schede (`ldTabbed`), e allora le linguette sono visibili con cornice e `LayoutLookAndFeel` predefinito; altrimenti linguette nascoste e niente cornice. Il parametro `MostraBordo` non ha effetto (DIV-FRB-2). Il nome è assegnato **solo se `Nome` è vuoto**, nella forma `<nome del layout>Group` reso univoco (DIV-FRB-2: un nome passato dal chiamante non viene usato). `AddLayoutSplitter`, `AddLayoutEmptySpace` e `AddLayoutSeparator` creano l'elemento omonimo nel gruppo (o nel predefinito), senza titolo visibile; il divisore ha margini di 3 punti per lato; per il nome valgono le stesse regole del gruppo, con un difetto in più: il testo aggiunto è `Name`, che nel codice è il nome del **costruttore** e non il parametro `aName` (DIV-FRB-2). I nomi si rendono univoci aggiungendo `_1`, `_2` finché `FindItem` ne trova uno uguale; senza controllo di layout restano quelli richiesti.

### Scenario: gruppo a schede
- **Dato** un costruttore con layout
- **Quando** si chiama `AddLayoutGroup(nil, '', ldTabbed, 'Dati')`
- **Allora** il gruppo ha titolo `Dati`, `ShowBorder` vero e linguette visibili (`HideTabs` falso)

### Scenario: gruppo senza bordo
- **Dato** un costruttore con layout
- **Quando** si chiama `AddLayoutGroup(nil, '', ldHorizontal, '', True)`
- **Allora** il gruppo ha `ShowBorder` falso e linguette nascoste, nonostante `MostraBordo` vero

### Scenario: gruppo predefinito
- **Dato** un costruttore con layout
- **Quando** si aggiungono due gruppi senza genitore
- **Allora** entrambi sono figli dello stesso gruppo predefinito, che esiste una sola volta

## ZBASE-FRB-003 Elementi di layout per un controllo
`AddLayoutItem(Controllo, Gruppo, AllineamentoO, AllineamentoV, Titolo, PosizioneTitolo, Bordo)` crea un elemento nel gruppo (o nel predefinito) e vi mette il controllo. Il nome è `<nome del layout>Item<nome del controllo>`, reso univoco con `_1`, `_2`. Senza titolo, l'elemento nasconde il titolo (`ShowCaption` falso) e prende il nome del controllo come titolo interno; con un titolo lo mostra, con la posizione chiesta (predefinita a sinistra). Valori predefiniti: allineamento `ahClient`/`avClient`, nessun bordo; `ControlOptions.AutoColor` sempre vero. Senza controllo di layout restituisce `nil` e non crea niente. `AddControl` usa allineamento `ahClient`/`avTop`; `AddButton` usa `ahRight`/`avTop`.

### Scenario: elemento senza titolo
- **Dato** un controllo di nome `Ente`
- **Quando** si chiama `AddLayoutItem(Controllo)` senza titolo
- **Allora** l'elemento ha nome `<layout>ItemEnte`, `ShowCaption` falso e il controllo assegnato

### Scenario: nome già usato
- **Dato** un elemento `<layout>ItemEnte` già presente
- **Quando** se ne aggiunge un altro per un controllo `Ente`
- **Allora** il nome del nuovo è `<layout>ItemEnte_1`

## ZBASE-FRB-004 Controlli per tipo
`CreateControl(Tipo, Nome, Valore)` crea un controllo non legato a dati, con proprietario il costruttore, lo registra nell'elenco interno, gli dà il nome `Nome` **così com'è** (un nome già usato fra i componenti del costruttore solleva l'errore di nome duplicato di `TComponent`) e gli assegna il valore: un valore nullo o vuoto svuota il controllo (`Clear`), altrimenti lo scrive in `EditValue`. `AddControl` aggiunge il controllo con `CreateControl`, gli dà un elemento di layout (ZBASE-FRB-003), poi chiama la procedura facoltativa `initProc` con il controllo creato. Le funzioni per tipo sono: `AddTextEdit` (`ctEdit`), `AddDate` (`ctDate`), `AddTime` (`ctTime`), `AddCheckBox` (`ctCheckBox`), `AddPickList` (`ctPickListImage` con elenco di valori letto dal nome della lista), `AddLookupCombo` e `AddLookupComboHyperLink` (ZBASE-FRB-008). I parametri `Nome` e `Titolo` si scambiano di posto: `AddPickList(Lista, Titolo, Nome, ...)` ma `AddLookupCombo(Nome, Titolo, ...)` (DIV-FRB-7). Un tipo per cui `dx.GetCustomEditClass` non ha una classe non si può creare (la funzione restituisce `nil` e la creazione va in violazione di accesso).

### Scenario: valore nullo
- **Dato** un costruttore
- **Quando** si crea un controllo di testo con valore nullo
- **Allora** il controllo è vuoto

### Scenario: nome duplicato
- **Dato** un controllo creato con nome `Importo`
- **Quando** se ne crea un secondo con lo stesso nome
- **Allora** si solleva l'errore di componente già esistente

## ZBASE-FRB-005 Ricerche per nome
`Exists(Nome)` e `ControlByName<T>(Nome)` cercano **solo fra i controlli creati dal costruttore** (non fra gli elementi inseriti a mano con `AddLayoutItem`), senza distinzione fra maiuscole e minuscole; `ControlByName<T>` restituisce il primo controllo con quel nome che sia del tipo `T`, altrimenti `nil`. `GetControl(Nome)` è la ricerca per `TcxCustomEdit`. `GetValue(Nome)` restituisce `EditValue` del controllo, o `Null` se il controllo non esiste; `SetValue(Nome, Valore)` scrive `EditValue` e non fa niente se il controllo non esiste (non svuota con il valore nullo come `CreateControl`: scrive `Null` in `EditValue`). `LayoutItemByName` e `LayoutItemByControl` cercano nel layout (`FindItem`) e restituiscono `nil` se non trovano o se il layout non esiste.

### Scenario: costruttore vuoto
- **Dato** un costruttore senza controlli
- **Quando** si chiama `Exists('X')`, `GetControl('X')`, `GetValue('X')` e `SetValue('X', 1)`
- **Allora** `Exists` è falso, `GetControl` è `nil`, `GetValue` è `Null` e `SetValue` non solleva errori

### Scenario: tipo non corrispondente
- **Dato** un controllo di testo di nome `Nota`
- **Quando** si chiama `ControlByName<TcxCheckBox>('Nota')`
- **Allora** il risultato è `nil`

## ZBASE-FRB-006 Cambio del tipo di un controllo
`ChangeControlType(Tipo, Nome, Titolo, Valore)` sostituisce il controllo di nome `Nome` mantenendone l'elemento di layout: rinomina il vecchio in `_old<Nome>`, crea il nuovo con `CreateControl` (stesso nome), lo assegna all'elemento, toglie il vecchio dall'elenco e lo libera. Il titolo non cambia e `Titolo` è ignorato: serve solo se il controllo **non esiste**, nel qual caso equivale a `AddControl(Tipo, Nome, Titolo, Valore)` nel gruppo predefinito. Se il vecchio controllo esiste ma non ha un elemento di layout (creato con `CreateControl` e mai collocato) la funzione va in violazione di accesso (DIV-FRB-6). È il metodo più usato dalle finestre di parametri di WT e Gesty: sostituisce l'editor standard di un parametro con una casella di ricerca o un elenco di valori.

### Scenario: sostituzione
- **Dato** un controllo di testo `Ente` già collocato nel layout
- **Quando** si chiama `ChangeControlType(ctSpin, 'Ente', '', 0)`
- **Allora** esiste un solo controllo `Ente`, di classe numerica, nello stesso elemento
- **E** il vecchio controllo è stato liberato

### Scenario: controllo inesistente
- **Dato** un costruttore senza il controllo `Anno`
- **Quando** si chiama `ChangeControlType(ctSpin, 'Anno', 'Anno', 2026)`
- **Allora** viene aggiunto un controllo `Anno` con titolo `Anno` e valore 2026

## ZBASE-FRB-007 Pulsanti
`AddButton(Azione, Gruppo, initProc)` crea un `TcxButton` di proprietà del costruttore, lo registra, lo chiama `btn<nome dell'azione>`, gli assegna l'azione e, se l'azione appartiene a una lista di azioni, ne prende la lista di immagini. Lo colloca con `AddLayoutItem` (allineato a destra e in alto, senza titolo) e, se c'è, chiama `initProc(Pulsante, Elemento)`. Il pulsante entra nell'elenco dei controlli (quindi `Exists` e `ControlByName<TcxButton>` lo trovano) ma non è un `TcxCustomEdit` (`GetControl` non lo trova).

### Scenario: pulsante da azione
- **Dato** un'azione `Salva`
- **Quando** si chiama `AddButton(Salva)`
- **Allora** esiste un controllo di nome `btnSalva` con `Action = Salva`, e `GetControl('btnSalva')` è `nil`

## ZBASE-FRB-008 Caselle di ricerca
`AddLookupCombo(Nome, Titolo, Dataset, CampoChiave, CampoElenco, Valore, ...)` crea un controllo di ricerca (tipo `DefaultLookupCtrlType`) con valore nullo, cerca o crea **una sola sorgente dati per dataset** (un `TDataSource` di nome `<nome del dataset>Src`, proprietario il costruttore), inizializza la casella con `dx.InitLookup` e solo dopo assegna `Valore`. `AddLookupComboHyperLink` fa lo stesso con tipo `ctLookupHyperLink` e il modo «collegamento». Così il valore iniziale si applica a una casella già pronta (la selezione si mostra).

### Scenario: sorgente dati condivisa
- **Dato** due caselle di ricerca costruite sullo stesso dataset
- **Quando** si chiama `AddLookupCombo` due volte
- **Allora** esiste una sola sorgente dati per quel dataset

## ZBASE-FRB-009 Liberazione dei controlli
`Clear` svuota il layout con `dxLayoutControl.Clear` (se il layout esiste), rimette a `nil` il riferimento al gruppo predefinito e poi libera i controlli e le sorgenti dati creati dal costruttore. Il layout **distrugge anche i controlli esterni associati agli elementi** (proprietà `Control`) e i gruppi, compreso quello predefinito: il costruttore scorre quindi i propri componenti dall'ultimo al primo e libera solo quelli ancora vivi (un componente distrutto si toglie da solo dall'elenco dei componenti), poi svuota i due elenchi. Così nessun controllo si libera due volte e gli elenchi non si accorciano durante lo scorrimento. `Clear` su un costruttore senza controlli funziona e svuota solo il layout. `TzParamDialog.CreateEditors` la chiama all'inizio ogni volta che si costruiscono gli editor, quindi si può ricostruire una finestra già costruita.

### Scenario: costruttore vuoto
- **Dato** un costruttore senza controlli
- **Quando** si chiama `Clear`
- **Allora** non si solleva alcun errore e il layout è vuoto

### Scenario: più controlli collocati nel layout
- **Dato** un costruttore con tre pulsanti collocati nel layout
- **Quando** si chiama `Clear`
- **Allora** non si solleva alcun errore e nessuno dei tre pulsanti esiste più fra i controlli del costruttore

### Scenario: nuovo gruppo dopo Clear
- **Dato** un costruttore che ha già creato il gruppo predefinito
- **Quando** si chiama `Clear` e poi si aggiunge un gruppo senza genitore
- **Allora** il gruppo ha come genitore un nuovo gruppo predefinito, esistente

## ZBASE-FRB-010 Sospensione degli aggiornamenti
`BeginUpdate` e `EndUpdate` chiamano `BeginUpdate` ed `EndUpdate` del layout (se esiste), per costruire molti elementi senza ridisegnare ogni volta. `IsUpdating` dovrebbe dire se il layout è sospeso: nel codice di oggi risponde sempre falso (DIV-FRB-3).

### Scenario: sospensione
- **Dato** un costruttore con layout
- **Quando** si chiama `BeginUpdate`
- **Allora** il layout è sospeso (`Container.IsUpdateLocked` vero)
- **E** `IsUpdating` risponde falso (difetto)

## ZBASE-FRB-011 Personalizzazione e salvataggio
`Customize` assegna `TzLayoutCustomizeForm` come finestra di personalizzazione del layout e attiva la modalità di personalizzazione: l'utente può spostare e nascondere gli elementi con la finestra di `zDxLayoutCustomizeFrm`. È il solo punto in cui `LayoutID` dovrebbe servire, ma `LoadLayout` e `SaveLayout` sono vuoti (contengono solo un commento «Implementare») e `LayoutID` non è letto da nessun altro: la personalizzazione **non** si salva e non si ricarica. `TzDialog.Customize` chiama questa funzione (`zDialog.pas`, riga 212).

### Scenario: salvataggio non implementato
- **Dato** un costruttore con layout e `LayoutID` valorizzato
- **Quando** si chiamano `SaveLayout` e `LoadLayout`
- **Allora** non si solleva alcun errore e non cambia niente nel layout

## Divergenze note
Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce «R-213» di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `zFormBuilder.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| ~~DIV-FRB-1~~ ✅ corretta il 2026-11-01 (rilascio 002), provata da `Clear_ConPiuControlli_LiLiberaTuttiESvuotaLElenco` | Testo originale: `Clear` (353-375) chiama `dxLayoutControl.Clear`, che distrugge anche i controlli associati agli elementi (documentazione DevExpress, `TdxCustomLayoutControl.Clear`), e poi libera di nuovo ogni controllo dell'elenco `ctrls` (un puntatore già liberato); inoltre scorre `ctrls` e `lkDataSources` con `for i := 0 to Count - 1` togliendo gli elementi dall'elenco che scorre, quindi il limite resta quello iniziale | Doppia liberazione di ogni controllo collocato nel layout (violazione di accesso o memoria corrotta) e, con due o più elementi, errore di indice fuori intervallo. È raggiungibile: `TzParamDialog.CreateEditors` (`zFrmParams.pas`, 266) la chiama a ogni ricostruzione degli editor, quindi alla seconda ricostruzione di una finestra di parametri. Provata: sul codice vecchio la prova sollevava `EInvalidPointer` |
| DIV-FRB-2 🟡 (dedotta) | `AddLayoutGroup` (207-208), `AddLayoutSplitter` (280-281), `AddLayoutEmptySpace` (335-336) e `AddLayoutSeparator` (346-347) assegnano il nome solo se `aName` è **vuoto** (la condizione è rovesciata) e usano `Name`, che è il nome del costruttore, e non `aName`; in `AddLayoutGroup` `MostraBordo` è ignorato perché sovrascritto dalla riga 226 | Un nome passato dal chiamante (per esempio `'groupDate'` in `frmGRS.pas`, 378) non viene mai applicato: il gruppo ha il nome generato dal layout, e chi lo cerca poi con `LayoutItemByName('groupDate')` non lo trova. Il parametro `MostraBordo` non serve a niente |
| DIV-FRB-3 🟡 (dedotta) | `IsUpdating` (568-573) chiama `dxLayoutControl.Container.IsUpdateLocked` ma non ne usa il risultato: `result` resta falso | Chi controlla `IsUpdating` prima di intervenire sul layout crede sempre che non sia sospeso; il metodo non ha chiamanti in `SRC`, quindi oggi non produce errori |
| DIV-FRB-4 🟢 (dedotta) | `LoadLayout` e `SaveLayout` (575-583) sono vuoti (commento «Implementare») e `LayoutID` non è usato da nessuno; `Customize` permette all'utente una personalizzazione che non si salva | La personalizzazione del layout a mano si perde alla chiusura della finestra, anche se `TzDialog` espone `LayoutID` come se servisse a salvarla |
| ~~DIV-FRB-5~~ ✅ corretta il 2026-11-01 (rilascio 002), provata da `Clear_PoiNuovoGruppoSenzaGenitore_CreaUnGruppoPredefinitoVivo` | Testo originale: `Clear` non rimette a `nil` `DefaultParentGroup` dopo che `dxLayoutControl.Clear` ha eliminato il gruppo (353-375, 179-200) | Dopo `Clear`, la prima aggiunta senza gruppo usa un puntatore a un oggetto liberato e va in violazione di accesso; insieme a DIV-FRB-1 rende impossibile ricostruire gli editor di una finestra già costruita |
| DIV-FRB-6 🟢 (dedotta) | `ChangeControlType` (480-499) assume che il vecchio controllo abbia un elemento di layout: `LayoutItemByControl` può restituire `nil` e il codice lo converte e lo usa senza controllo | Un controllo creato con `CreateControl` e mai collocato manda in violazione di accesso il cambio di tipo; nell'uso normale (solo `AddControl`) non succede |
| DIV-FRB-7 🟢 (dedotta) | `AddPickList` ha l'ordine `(Lista, Titolo, Nome, ...)` mentre tutte le altre funzioni `Add...` hanno `(Nome, Titolo, ...)` (riga 97) | Due stringhe consecutive scambiabili senza errori di compilazione: un `AddPickList` scritto «a memoria» crea un controllo con il titolo come nome |
| DIV-FRB-8 🟢 (dedotta) | `Notification` (142-149) azzera il riferimento al layout, ma `AddLayoutGroup`, `AddLayoutSplitter`, `AddLayoutEmptySpace`, `AddLayoutSeparator`, `Clear`, `AddLookupCombo` e `ChangeControlType` usano `dxLayoutControl` senza controllarlo; e l'avviso arriva solo per componenti con lo stesso proprietario | Se il layout viene liberato prima del costruttore (proprietari diversi), ogni aggiunta va in violazione di accesso; in `TzDialog` layout e costruttore hanno lo stesso proprietario e il caso non si presenta |

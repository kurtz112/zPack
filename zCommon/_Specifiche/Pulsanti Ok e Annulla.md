---
area: Pulsanti Ok e Annulla
progetto: zCommon
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/021
---

# Pulsanti Ok e Annulla

Questa specifica descrive il frame `TOkCancel` (`zCommon\OkCancel.pas` e `OkCancel.dfm`), la barra con i pulsanti Ok, Annulla e Applica e la maniglia di ridimensionamento che sta in fondo alle finestre di dialogo, e, in una sezione finale breve, le azioni con finestre di file DevExpress della unit `zCommon\dxFileActions.pas` (`TdxFileOpen`, `TdxFileSaveAs`, `TdxOpenPicture`, `TdxSavePicture`). Entrambe le unit sono compilate: le richiama `zCommon_Register` (pacchetto `zBase_Common_*`, che registra `TOkCancel` nella tavolozza `zCommon` e le quattro azioni nella categoria `dxFile`) e, a catena, i progetti che le usano; `dxFileActions` è registrata una seconda volta da `zBaseRegister` (DIV-OKC-6). `TOkCancel` è nelle form di WT (14 `.dfm`), Gesty (5), zPack (21: fra queste `zDialog`, `zDbViewDlg`, `zDbCardDlg`, `zSecurityFrm`), WinSinfo (26) e ShareFood (1); le azioni di file in circa 80 azioni nei `.dfm` di WT, Gesty, zPack e zFbExpert.

**Come funziona (`TOkCancel`).** Il frame contiene tre `TcxButton` (`OkBtn` «Ok», `CancelBtn` «Annulla», `ApplyBtn` «Applica») e un `TPaintBox` a destra che disegna la maniglia di ridimensionamento. Sta sul fondo di una finestra (`Align = alBottom`); la finestra che lo contiene lo configura con quattro proprietà: `ReadOnly`, `DefaultOk`, `DefaultCancel`, `OnApply` (`AutoFocus`, corretta in DIV-OKC-1, dà il fuoco a `Ok` al caricamento). A ogni cambio di stato il frame ridisegna la visibilità dei pulsanti (`UpdateButtonsState`) e li ricolloca da destra verso sinistra (`AlignButtons`).

**Test che coprono quest'area.** `Test.OkCancel` (registrato in `zPackTests` dal rilascio 021) crea il frame con `TOkCancel.Create(nil)`, senza genitore e senza mostrarlo (la risorsa del `.dfm` è nel codice compilato: `{$R *.dfm}` in `OkCancel.pas`; `TFrame.Create` la carica anche senza genitore) e prova i valori iniziali (ZCOMMON-OKC-001), la sola lettura (002), Applica (003), `DefaultOk` e `DefaultCancel` (004), la disposizione dei pulsanti (005), `ResetButtons` (007), l'`AutoFocus` (008) e le azioni di file, con la sola creazione senza mostrare finestre (010, 011). Restano senza prova, perché richiedono una finestra, il disegno o il progettista: la maniglia, il disegno e la risposta ai messaggi di Windows (006), il comportamento in progettazione (009), il click vero dei pulsanti e la chiusura della finestra con `ModalResult`, e l'apertura delle finestre di file: si collaudano con la sonda `zapp` sul banco.

## ZCOMMON-OKC-001 Creazione e valori iniziali
`TOkCancel.Create` carica il `.dfm`, poi imposta: `AutoFocus`, `DefaultOk`, `DefaultCancel`, `ReadOnly` falsi; `OnApply` non assegnato; `AutoScroll` falso; `OkBtn.ModalResult = mrOk`, `CancelBtn.ModalResult = mrCancel` (il pulsante Applica non ha risultato modale e quindi non chiude la finestra). Misura la maniglia con `GetSystemMetrics` (`SM_CXVSCROLL` e `SM_CYHSCROLL`) una sola volta, alla creazione. Poi calcola la visibilità: in esecuzione `OkBtn` ha il testo `Ok`, `CancelBtn` è visibile e `ApplyBtn` è nascosto perché `OnApply` non c'è. I testi sono `Ok`, `Annulla` e `Applica`.

### Scenario: frame appena creato
- **Dato** un `TOkCancel` creato con `Create(nil)`
- **Quando** si leggono le proprietà
- **Allora** `ReadOnly`, `DefaultOk`, `DefaultCancel` e `AutoFocus` sono falsi, `OnApply` non è assegnato, `OkBtn.Caption = 'Ok'`, `CancelBtn.Caption = 'Annulla'`, `ApplyBtn.Caption = 'Applica'`
- **E** `OkBtn.ModalResult = mrOk`, `CancelBtn.ModalResult = mrCancel`, `ApplyBtn.ModalResult = mrNone`
- **E** `OkBtn` e `CancelBtn` sono visibili e `ApplyBtn` no

## ZCOMMON-OKC-002 Sola lettura
Con `ReadOnly = True` il pulsante principale diventa `Chiudi` (resta `mrOk`: chi controlla `ShowModal = mrOk` lo legge come una conferma), `Annulla` e `Applica` sono nascosti anche se c'è un `OnApply`. Con `ReadOnly = False` tornano `Ok`, `Annulla` e, se c'è `OnApply`, `Applica`. Assegnare il valore già presente non fa niente. Usano la sola lettura le finestre dell'editor SQL e JSON (`OkCancel.readonly := ReadOnly` in `Form_Editor_SQL` e `Form_Editor_JSON`) e `frmEditorHTML` (`.dfm`).

### Scenario: sola lettura
- **Dato** un frame con `OnApply` assegnato
- **Quando** si imposta `ReadOnly := True`
- **Allora** `OkBtn.Caption = 'Chiudi'`, `CancelBtn.Visible = False` e `ApplyBtn.Visible = False`

### Scenario: ritorno alla modifica
- **Dato** un frame in sola lettura
- **Quando** si imposta `ReadOnly := False`
- **Allora** `OkBtn.Caption = 'Ok'` e `CancelBtn.Visible = True`

## ZCOMMON-OKC-003 Applica
`ApplyBtn` è visibile solo se `OnApply` è assegnato e `ReadOnly` è falso: assegnare o togliere il gestore aggiorna subito la visibilità. Il click chiama `OnApply(Self)`, con il frame come mittente; non chiude la finestra. Il pulsante Applica ha già un gestore nel `.dfm`, quindi un click senza `OnApply` non fa niente. Lo usano `zDbView.Columns.Frm`, `zLocalizer.form`, `zRestrictions.Form`, `zSecurityFrm`, `zSystemFrm` e `zz.base.editor._form`.

### Scenario: gestore assegnato
- **Dato** un frame senza `OnApply`
- **Quando** si assegna un gestore
- **Allora** `ApplyBtn.Visible` diventa vero; se poi si assegna `nil` torna falso

### Scenario: click su Applica
- **Dato** un frame con `OnApply` che conta le chiamate
- **Quando** l'utente preme Applica
- **Allora** il gestore è chiamato una volta con il frame come mittente e la finestra resta aperta

## ZCOMMON-OKC-004 Pulsante predefinito e pulsante di uscita
`DefaultOk` imposta `OkBtn.Default` (Invio attiva Ok) e `DefaultCancel` imposta `CancelBtn.Cancel` (Esc attiva Annulla). Il valore predefinito è falso per entrambi e le form lo scrivono nel loro `.dfm` (le impostazioni vere sono quelle di `zDialog.dfm`, che le porta a vero, e di `FrmRegAziNotifiche` di WinSinfo, che porta a vero `DefaultOk`). Il dialogo dei parametri (ZBASE-PAR-009) ha entrambi veri; `TzDialog.SetEnterAsTab` riallinea `OkBtn.Default` a `not EnterAsTab` quando si cambia `EnterAsTab`, mentre il costruttore di `TzDialog` assegna il campo `FEnterAsTab` direttamente e lascia il valore del `.dfm`.

### Scenario: pulsanti predefiniti
- **Dato** un frame appena creato
- **Quando** si imposta `DefaultOk := True` e `DefaultCancel := True`
- **Allora** `OkBtn.Default` e `CancelBtn.Cancel` sono veri; riportandoli a falso tornano falsi

## ZCOMMON-OKC-005 Disposizione dei pulsanti
`AlignButtons` parte dal bordo sinistro della maniglia (`PaintBox.Left`) e dispone i pulsanti da destra verso sinistra con 5 pixel di intervallo: prima `Annulla` (se visibile), poi `Ok` (se visibile), poi `Applica` (se visibile). Con `Annulla` nascosto (sola lettura) `Ok` prende il suo posto. La disposizione è ricalcolata a ogni cambio di stato (`ReadOnly`, `OnApply`, `Loaded`) e a ogni ridimensionamento del frame (`FrameResize`, che ricalcola anche la maniglia e ridisegna il frame).

### Scenario: tre pulsanti
- **Dato** un frame con `OnApply`
- **Quando** il frame è disposto
- **Allora** `Annulla.Left + Annulla.Width + 5 = PaintBox.Left`, `Ok.Left + Ok.Width + 5 = Annulla.Left` e `Applica.Left + Applica.Width + 5 = Ok.Left`

### Scenario: sola lettura
- **Dato** un frame in sola lettura
- **Quando** il frame è disposto
- **Allora** `Ok.Left + Ok.Width + 5 = PaintBox.Left`

## ZCOMMON-OKC-006 Maniglia di ridimensionamento
`PaintBox` (allineato a destra, 22 pixel) disegna nell'angolo in basso a destra la maniglia di ridimensionamento: con gli stili VCL attivi con `StyleServices.DrawElement(tsSizeBoxRightAlign)`, altrimenti con `DrawFrameControl(DFC_SCROLL, DFCS_SCROLLSIZEGRIP)`. L'area della maniglia ha la dimensione delle barre di scorrimento di sistema, presa alla creazione. Alla richiesta di Windows «che cosa c'è sotto il mouse» (`WM_NCHITTEST`) il frame risponde `HTBOTTOMRIGHT` quando il punto cade sulla maniglia, altrimenti lascia la risposta della VCL: l'intento è far ridimensionare dal basso a destra le finestre ridimensionabili (`bsSizeToolWin` e simili) che hanno il frame sul fondo. Non è provata da test automatici.

### Scenario: trascinamento
- **Dato** una finestra ridimensionabile con il frame sul fondo
- **Quando** l'utente trascina la maniglia
- **Allora** la finestra cambia dimensione e i pulsanti restano a destra

## ZCOMMON-OKC-007 Ripristino dei pulsanti (`ResetButtons`)
`ResetButtons` nasconde e mostra di nuovo `OkBtn` e `CancelBtn`, nell'ordine: serve a far ridisegnare i pulsanti. Lo chiama `zDbCardDlg` in `FormCloseQuery`, «altrimenti il pulsante premuto risulterà invisibile alla successiva apertura». Dopo `Hide` e `Show` richiama `UpdateButtonsState`, che ricalcola la visibilità e rifà la disposizione: in sola lettura `Annulla` resta nascosto (DIV-OKC-2 corretta).

### Scenario: ripristino
- **Dato** un frame normale
- **Quando** si chiama `ResetButtons`
- **Allora** `OkBtn.Visible` e `CancelBtn.Visible` sono veri

### Scenario: ripristino in sola lettura
- **Dato** un frame con `ReadOnly = True`
- **Quando** si chiama `ResetButtons`
- **Allora** `CancelBtn.Visible` è falso

## ZCOMMON-OKC-008 Fuoco iniziale (`AutoFocus`)
`AutoFocus` dà il fuoco a `OkBtn` al caricamento (in `Loaded`, fuori dalla progettazione, se `OkBtn.CanFocus`). Il metodo che imposta la proprietà ora memorizza il valore (DIV-OKC-1 corretta; prima il corpo era vuoto e il ramo di `Loaded` non scattava mai). Nessun `.dfm` e nessun codice lo imposta.

### Scenario: AutoFocus memorizzato
- **Dato** un frame appena creato
- **Quando** si imposta `AutoFocus := True`
- **Allora** `AutoFocus` legge vero

## ZCOMMON-OKC-009 In progettazione
Con `csDesigning` la visibilità dei pulsanti non cambia (si vedono tutti); `ApplyBtn.Enabled` segue `OnApply`; in sola lettura il testo è `Chiudi`, `Annulla` è disabilitato e `Ok` sta a destra di `Annulla`, invertendo l'ordine di esecuzione; `DefineProperties` richiama l'aggiornamento al salvataggio del `.dfm` nel progettista. Non è provata da test: richiede il progettista di RAD Studio.

### Scenario: anteprima della sola lettura
- **Dato** un frame in progettazione
- **Quando** si porta `ReadOnly` a vero
- **Allora** `Annulla` è disabilitato ma visibile e `Chiudi` sta alla sua destra

## ZCOMMON-OKC-010 Azioni di file con finestre DevExpress (`TdxFileOpen`, `TdxFileSaveAs`)
`TdxFileOpen` e `TdxFileSaveAs` sono azioni (`TFileAction`) che al posto della finestra standard di Windows aprono quella di DevExpress (`dxShellDialogs`): la prima una `TdxOpenFileDialog` («apri»), la seconda una `TdxSaveFileDialog` («salva con nome»). La scelta della finestra sta in `GetDialogClass`; la proprietà pubblicata `Dialog` restituisce la finestra con il tipo giusto, per configurarla nel `.dfm` della form (`Dialog.Filter`, `Dialog.DefaultExt`, `Dialog.Options`, `Dialog.Title`). **Il costruttore non imposta altro che il nome della finestra** (`dxOpenDialog` per l'apertura, `dxSaveDialog` per il salvataggio): non impone filtri, titoli né opzioni, che ogni azione dichiara nel `.dfm` della form che la contiene (per esempio `Esporta` di `frmGRS`: `Dialog.Filter = 'File Excel|*.xlsx|Tutti|*.*'`, `Dialog.Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]`; le azioni con `Dialog.Title` sono rare). Dopo la conferma l'azione chiama il gestore `OnAccept`, nel quale le form leggono `Dialog.FileName` (`frmGRS`, `frmImportGenerici`); la classe pubblica anche `OnCancel` e `BeforeExecute` (ereditati dalla classe base della VCL, di cui in `SRC` non c'è il sorgente). Le proprietà pubblicate sono le solite delle azioni (`Caption`, `Hint`, `ImageIndex`, `ShortCut`, `Visible`, `Enabled`, `OnUpdate`, `OnHint`); `HelpKeyword` e `HelpType` ci sono per l'apertura e non per il salvataggio (DIV-OKC-5).

### Scenario: nome della finestra
- **Dato** un'azione `TdxFileOpen` creata con `Create(nil)`
- **Quando** si legge `Dialog`
- **Allora** è una `TdxOpenFileDialog` di nome `dxOpenDialog`; per `TdxFileSaveAs` è una `TdxSaveFileDialog` di nome `dxSaveDialog`

### Scenario: uso tipico
- **Dato** un'azione `Importa: TdxFileOpen` con `Dialog.Filter = 'File csv|*.csv|Tutti|*.*'` e `OnAccept = ImportaAccept`
- **Quando** l'utente sceglie un file e conferma
- **Allora** `ImportaAccept` legge `Importa.Dialog.FileName` e avvia l'importazione

## ZCOMMON-OKC-011 Azioni per le immagini (`TdxOpenPicture`, `TdxSavePicture`)
Sono azioni di finestra di dialogo (`TCommonDialogAction`) senza costruttore proprio: la finestra è una `TdxOpenPictureDialog` per l'apertura e una `TdxSavePictureDialog` per il salvataggio di immagini, restituita dalla proprietà `Dialog`. Non impongono né nome né filtro. Non le usa nessun `.dfm` e nessuna unit di WT, Gesty, zPack, zFbExpert o altri progetti in `SRC`: compaiono solo nella dichiarazione, nella registrazione fra le azioni (`zCommon_Register`, `zBaseRegister`) e nel loro codice (DIV-OKC-4).

### Scenario: finestra delle immagini
- **Dato** un'azione `TdxOpenPicture` creata con `Create(nil)`
- **Quando** si legge `Dialog`
- **Allora** è una `TdxOpenPictureDialog`; per `TdxSavePicture` una `TdxSavePictureDialog`

## Divergenze note
Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `OkCancel.pas` e `dxFileActions.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-OKC-1 ✅ (corretta, rilascio 020) | `SetAutoFocus` aveva il corpo vuoto: la proprietà pubblicata `AutoFocus` non scriveva mai `FAutoFocus`, quindi il ramo di `Loaded` che dà il fuoco a `OkBtn` non si eseguiva mai. Ora memorizza il valore | Chi imposta `AutoFocus = True` (nel `.dfm` o da codice) ottiene il fuoco su `Ok` al caricamento; oggi nessuna form lo usa. Prova `Divergenza_DIV_OKC_1_*` capovolta |
| DIV-OKC-2 ✅ (corretta, rilascio 020) | `ResetButtons` faceva `Hide` e `Show` su `OkBtn` e `CancelBtn` senza ripassare da `UpdateButtonsState`. Ora lo richiama in fondo | In sola lettura `Annulla` resta nascosto e la disposizione è rifatta; l'unico chiamante (`zDbCardDlg`) non usa la sola lettura. Prova `Divergenza_DIV_OKC_2_*` capovolta |
| DIV-OKC-3 🟢 (dedotta) | La maniglia misura le dimensioni con `GetSystemMetrics` una volta, nel costruttore (85-86), mentre la finestra può spostarsi fra monitor con DPI diversi; `OkCancel.pas` è salvato in Windows-1252 (commento alla riga 113 con carattere non UTF-8) e termina con righe di appunti sotto `end.` | La maniglia può risultare più piccola o più grande dell'angolo su un monitor con scala diversa; il file in Windows-1252 va conservato con la stessa codifica nelle correzioni |
| DIV-OKC-4 🟢 (dedotta) | `TdxOpenPicture` e `TdxSavePicture` non sono usate da nessun `.dfm` né codice in `SRC` (verificato con una ricerca in WT, Gesty, zPack, zFbExpert) | Codice che si compila e si registra nella tavolozza senza chiamanti; resta solo il costo di manutenzione |
| DIV-OKC-5 🟢 (dedotta) | `TdxFileOpen` pubblica `HelpKeyword` e `HelpType` (righe 24-25), `TdxFileSaveAs` no (45-60); le due azioni di immagini non pubblicano `BeforeExecute`, e i commenti `{ TFileOpen }`, `{ TFileSaveAs }` indicano le classi della VCL non quelle del file | Inoltrare un aiuto contestuale funziona per l'apertura e non per il salvataggio; asimmetria, non errore |
| DIV-OKC-6 🟢 (dedotta) | `RegisterActions('dxFile', [TdxFileOpen, TdxFileSaveAs, TdxOpenPicture, TdxSavePicture], nil)` compare identica in `zCommon_Register.pas` (riga 30) e in `zBaseRegister.pas` (riga 95) | Le stesse quattro azioni sono registrate da due pacchetti di progettazione: in RAD Studio la categoria `dxFile` può risultare duplicata o la seconda registrazione ignorata; da verificare nell'IDE |

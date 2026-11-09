---
area: Icone, barre e inizializzazione dei controlli
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/001
---

# Icone, barre e inizializzazione dei controlli

Questa specifica descrive la parte di `zBase\zDX.pas` che prepara icone, barre e controlli DevExpress perché abbiano lo stesso aspetto e lo stesso comportamento in tutto il programma: la lista unica delle icone (`Immagini`, `IndiceIcona`, `AgganciaImmagini`), le barre (`InitBar` e le funzioni sui menu a comparsa), le funzioni `InitXxx` per griglie, alberi, layout, etichette, schede, stampa e editor, la mappatura da `TzCtrlType` alle classi di editor e di proprietà (`GetCustomEditClass`, `GetPropertiesClass`, `InitProperties`), il correttore ortografico e la chiusura dei filtri aperti. Il modulo si usa sempre attraverso la funzione `dx` (unit `zDX`), che crea il `Tdx` alla prima chiamata e lo libera alla chiusura del programma. Le altre parti di `zDX` (colori e skin, valori degli editor, ricerche) hanno una specifica a parte. `TzCtrlType` è dichiarato in `zBaseLib.pas`.

Conteggio per righe `dx.<nome>` nei `.pas` di WT, Gesty e zPack, escluse `zDX.pas` e le prove (le copie di lavoro con " - Mio" nel nome di zPack sono comprese): `dx.Immagini` 183 (118 WT, 42 Gesty, 23 zPack), `dx.Visible` 170 (11, 10, 149), `InitLayoutControl` 63 (22, 26, 15), `AgganciaImmagini` 43 (tutte in zPack), `IndiceIcona` 30 (10, 15, 5), `InitPrinter` 29 (2, 6, 21), `InitBar` 18 (5, 9, 4), `InitTreeList` 18 (7, 3, 8), `InitTitle` 12, `InitProperties` 11, `dxBarRequiredWidth` 10, `dxBarAssignPopupMenu` 8, `GetBitmap` 6, `GetPropertiesClass` 6, `InitGrid` 5, `GetCustomEditClass` 5, `PrepareSpellCheckerPopup` 5, `InitLabel` 4, `InitScheduler` 4, `Alert` 4, `InitSkinChooserGalleryItem` 4, gli altri 0-2 (`InitPageControl`, `InitSplitter`, `InitDateEdit`, `InitButtonEdit`, `InitPivot`, `SetFilterControlFonts`, `InitSeparator`, `LayoutControlHeigth`, `InitSpellChecker`, `ShowSpellingOptionsDialog`, `InitRibbonSkinSelector`, `ChiudiFiltriAperti`); `InitColorCombo`, `InitTimeEdit`, `DrawBandSeparator`, `dxBarMouseDown` e `RibbonSkinSelectorApplySkin` non hanno nessun chiamante diretto (vedi DIV-ICO-9). I requisiti sono ordinati per uso reale: prima ciò che WT e Gesty chiamano più spesso. La unit è compilata da WT, Gesty e dai pacchetti di zPack.

**Come funziona.** `Tdx` è un `TDataModule` che porta con sé gli oggetti condivisi (controller di stile, repository di stili, lista `Immagini`, look and feel dei layout, finestra degli avvisi, correttore ortografico). Le funzioni `InitXxx` non creano controlli: prendono un controllo già creato (dal DFM o dal codice) e ne impostano le proprietà con valori fissi e gli stili del modulo. Sono idempotenti nel senso che chiamarle due volte dà lo stesso stato, tranne dove il requisito dice altrimenti. Quasi tutte cominciano con `Assert(Assigned(...))`: con un controllo nullo, in una compilazione con le asserzioni attive, sollevano `EAssertionFailed`.

**Test che coprono quest'area.** Nessuna prova in `D:\AI\SRC\zPack\_UnitTest\_src`. Il test `Test.zDX.Controlli` (bozza) copre: la mappatura delle classi per ogni tipo (ZBASE-ICO-011), `InitProperties` con e senza dominio (ZBASE-ICO-012, 013), `InitDateEdit`, `InitTimeEdit`, `InitButtonEdit`, `InitColorCombo` (ZBASE-ICO-014, 015), `GetBitmap` e `Visible` (ZBASE-ICO-003) su un `Tdx` creato con `CreateNew` (senza DFM); e, sul modulo completo, `IndiceIcona`, `AgganciaImmagini`, `InitLayoutControl` con le proprietà salvate dei layout, i look and feel, `InitBar`, `InitPrinter`, `InitGrid`, `InitTreeList`, `InitPivot`, etichette, scheda, separatore, filtro, correttore ortografico e `ChiudiFiltriAperti`. Restano senza prova, perché richiedono una finestra, un file di skin o uno stato dell'IDE: `InitSkinChooserGalleryItem`, `InitRibbonSkinSelector`, `RibbonSkinSelectorApplySkin`, `InitScheduler`, `Alert`, `ShowSpellingOptionsDialog`, `PrepareSpellCheckerPopup`, `dxBarMouseDown`, `DrawBandSeparator`, `ReadState`, `ApplicazioneModalBegin`, l'effetto delle funzioni del correttore con un dizionario vero e `zzSmartTextToDateFunc` (dipende dalle impostazioni regionali).

## ZBASE-ICO-001 Lista unica delle icone e ricerca per nome
`dx.Immagini` è la lista unica delle icone di zPack (immagini vettoriali a 16 pixel; i pulsanti grandi la riusano a 32). È la lista che le funzioni di questa specifica assegnano a layout, barre, menu, azioni e caselle con immagini, ed è quella che i `.dfm` di WT e Gesty scrivono come `Images = dx.Immagini`. Gli indici scritti nel codice cambiano quando il catalogo si rigenera; il nome del file no, quindi `IndiceIcona(Nome)` restituisce la posizione dell'icona dal nome del suo file SVG **senza estensione**, confrontato senza distinguere maiuscole e minuscole, oppure **-1** se non esiste. La ricerca scorre la lista dall'inizio e dà la prima corrispondenza. Con un nome scritto con l'estensione (`expandall.svg`) il risultato è -1.

La costante `ImmagineVoceTutti` (554) è l'indice dell'icona (pallino grigio) che i filtri aggiungono in testa alle picklist: è un numero fisso, quindi dipende dal catalogo corrente.

### Scenario: nome esistente
- **Dato** la lista con un'icona il cui file è `expandall.svg`
- **Quando** si chiama `dx.IndiceIcona('ExpandAll')`
- **Allora** il risultato è la posizione di quell'icona

### Scenario: nome inesistente
- **Dato** un nome che non è nel catalogo
- **Quando** si chiama `dx.IndiceIcona('icona-inesistente')`
- **Allora** il risultato è -1 e la chiamata non solleva nulla

## ZBASE-ICO-002 Aggancio automatico della lista alle form
`dx.AgganciaImmagini(Radice)` collega `Immagini` ai componenti **posseduti da `Radice`** (cioè in `Radice.Components`, non ai componenti dei frame annidati, che hanno un altro proprietario) che la usano ma l'hanno persa. Si chiama nel costruttore di form e frame, dopo `inherited`. Il motivo: l'IDE scrive `Images = dx.Immagini` nel DFM solo se il modulo `zDX` è aperto; salvando una form senza averlo aperto il riferimento sparisce in silenzio e le icone con lui. La funzione tocca **solo le proprietà vuote**: una lista diversa assegnata nel DFM resta com'è. Non fa nulla se `Radice` è nulla o se è in fase di progettazione (`csDesigning`), perché l'assegnazione verrebbe scritta nel DFM al primo salvataggio. I componenti trattati:
- `TCustomActionList` (e derivati): `Images`;
- `TdxBarManager`: `ImageOptions.Images`; `ImageOptions.LargeImages` **solo se** almeno un `TdxBarLargeButton` ha `LargeImageIndex` non negativo (con la lista grande assegnata il pulsante grande legge `LargeImageIndex` al posto di `ImageIndex` e senza indice resterebbe senza icona);
- `TdxBarPopupMenu`: `Images`;
- `TdxRibbonGalleryGroup`: `Options.Images`;
- `TPopupMenu`: `Images` **solo se** almeno una voce, a qualunque livello, ha `ImageIndex` non negativo o un'azione con `ImageIndex` non negativo (altrimenti la lista aggiungerebbe a ogni voce lo spazio vuoto dell'immagine).

### Scenario: lista già assegnata
- **Dato** un `TActionList` con `Images` già collegata a un'altra lista
- **Quando** si chiama `dx.AgganciaImmagini(Form)`
- **Allora** `Images` resta quella di prima

### Scenario: menu senza icone
- **Dato** un `TPopupMenu` le cui voci hanno tutte `ImageIndex` -1
- **Quando** si chiama `dx.AgganciaImmagini(Form)`
- **Allora** `Images` resta vuota

### Scenario: pulsante grande con indice
- **Dato** un `TdxBarManager` con un `TdxBarLargeButton` con `LargeImageIndex` 3
- **Quando** si chiama `dx.AgganciaImmagini(Form)`
- **Allora** `ImageOptions.Images` e `ImageOptions.LargeImages` sono `Immagini`

## ZBASE-ICO-003 Visibilità delle voci di barra, immagini da lista e avvisi
`dx.Visible(Vero)` restituisce `ivAlways` e `dx.Visible(Falso)` restituisce `ivNever`: serve ad assegnare un booleano a `Visible` di una voce di barra (`TdxBarItemVisible`) senza `if` (è la chiamata più frequente di tutta la specifica: 170 righe). `dx.GetBitmap(Glifo, Lista, Indice)` riempie un `TdxSmartGlyph` con l'immagine `Indice` di una lista (24 bit, fondo cancellato col colore del pennello, misure della lista) e notifica la modifica del glifo; con glifo o lista nulli solleva `EAssertionFailed`. `dx.Alert(Titolo, Testo, Indice=-1)` mostra una finestra di avviso con il gestore del modulo (`dxAlertWindowManager`) e restituisce la finestra.

### Scenario: booleano e barra
- **Dato** una voce di barra
- **Quando** si assegna `Item.Visible := dx.Visible(false)`
- **Allora** la voce è `ivNever`

### Scenario: immagine da lista
- **Dato** una lista con un'immagine 16 per 16
- **Quando** si chiama `dx.GetBitmap(Glifo, Lista, 0)`
- **Allora** il glifo non è vuoto ed è largo 16 pixel

## ZBASE-ICO-004 Preparazione di un layout
`dx.InitLayoutControl(Layout)` (63 chiamate, la più usata fra le funzioni sui controlli) imposta un `TdxLayoutControl` così: finestra di personalizzazione di classe `TzLayoutCustomizeForm`, senza vista a schede; salvataggio su file INI spento (`OptionsStoring.StoreToIniFile` falso, il salvataggio lo fa zPack con il suo archivio); `OptionsItem`: allineamento automatico dell'area del controllo, ordine di tabulazione automatico, clic sulla didascalia che dà il fuoco al controllo, elementi ridimensionabili in orizzontale e in verticale; bordi interno ed esterno assenti (`bvNone`); `LookAndFeel` e `LayoutLookAndFeel` uguali a `LayoutLookAndFeelNormal` (ZBASE-ICO-006). Le icone dei gruppi definiti nel dizionario LZ sono indici di `Immagini`: se `OptionsImage.Images` è vuota diventa `Immagini`, se la form ne ha già assegnata una resta quella. Infine collega i tre gestori delle proprietà salvate (ZBASE-ICO-005). Non cambia `Items.LayoutDirection` né l'allineamento della radice: rispetta quanto già impostato.

### Scenario: layout nuovo
- **Dato** un `TdxLayoutControl` appena creato
- **Quando** si chiama `dx.InitLayoutControl`
- **Allora** `OptionsStoring.StoreToIniFile` è falso, `OptionsItem.SizableHorz` e `SizableVert` sono veri e `OptionsImage.Images` è `Immagini`

### Scenario: lista della form
- **Dato** un layout con `OptionsImage.Images` già assegnata a una lista della form
- **Quando** si chiama `dx.InitLayoutControl`
- **Allora** `OptionsImage.Images` resta la lista della form

## ZBASE-ICO-005 Proprietà salvate degli elementi del layout
Quando il layout viene salvato e ricaricato dall'archivio delle impostazioni, i tre gestori agganciati da `InitLayoutControl` aggiungono alle proprietà standard di DevExpress queste, per tipo di elemento:
- `TdxLayoutItem` e `TdxLayoutLabeledItem`: `ImageIndex` (della didascalia) e `VisibleElements` (insieme degli elementi visibili della didascalia, scritto come testo dell'insieme);
- `TdxLayoutGroup`: `LookAndFeel` e `LayoutLookAndFeel` (il **nome** del look and feel, stringa vuota se non c'è), `HideTabs`, `ImageIndex`, `VisibleElements`, `ScrollOptionsHorizontal` e `ScrollOptionsVertical` (numero dell'enumerazione);
- ogni altro elemento (spazi vuoti, separatori, divisori): nessuna proprietà.

In ricarica i nomi dei look and feel si cercano in `dxLayoutLookAndFeelList` (`LayoutLookAndFeelNormal`, `LayoutLookAndFeelNoBorder`, ZBASE-ICO-006): un nome vuoto, sconosciuto o di un componente di altro tipo viene ignorato e il look and feel dell'elemento non cambia (DIV-ICO-14). Un nome di proprietà non riconosciuto è ignorato.

### Scenario: gruppo senza bordo
- **Dato** un gruppo con `LayoutLookAndFeel` uguale a `dx.LayoutLookAndFeelNoGroupBorder`
- **Quando** si legge la proprietà salvata `LayoutLookAndFeel`
- **Allora** il valore è `LayoutLookAndFeelNoBorder`
- **E** scrivendolo su un altro gruppo, quel gruppo ha lo stesso look and feel

### Scenario: nome sconosciuto
- **Dato** un gruppo senza look and feel
- **Quando** si scrive `LayoutLookAndFeel` con il valore `Inesistente`
- **Allora** il gruppo resta senza look and feel

### Scenario: elenco delle proprietà
- **Dato** un gruppo, un elemento con controllo e uno spazio vuoto
- **Quando** si chiede l'elenco delle proprietà salvate
- **Allora** sono 7 per il gruppo, 2 per l'elemento e nessuna per lo spazio vuoto

## ZBASE-ICO-006 Aspetto dei layout e altezza
`dx.LayoutLookAndFeelNormal` e `dx.LayoutLookAndFeelNoGroupBorder` sono due `TzLayoutLookAndFeel` creati dal costruttore del modulo, con nomi `LayoutLookAndFeelNormal` e `LayoutLookAndFeelNoBorder`, stile `lfUltraFlat`, stile nativo spento e margini della zona degli elementi radice di 3 pixel in orizzontale e in verticale. Differiscono solo per `HideGroupBorder`: nel secondo `GetGroupBorderOffset` restituisce sempre 0 (i gruppi non lasciano spazio per il bordo). Per entrambi il disegno dei gruppi è sempre quello standard (`TdxLayoutGroupStandardPainter`), perché quello ereditato disegna un bordo blu in modalità UltraFlat.

`dx.LayoutControlHeigth(Layout)` (il nome ha l'errore di battitura nel codice) restituisce l'altezza utile: il bordo inferiore più basso fra gli elementi visibili con informazioni di disegno, più il margine superiore dell'area del contenitore e il `Padding.Bottom` del layout. Se il contenitore non ha ancora informazioni di disegno restituisce solo il bordo più basso (0 se non ce ne sono). Si usa in Gesty (`frmFbMonitor`) per ridimensionare la form sul contenuto.

### Scenario: layout vuoto
- **Dato** un layout senza elementi e mai mostrato
- **Quando** si chiama `dx.LayoutControlHeigth`
- **Allora** il risultato non è negativo e la chiamata non solleva nulla

### Scenario: gruppi senza bordo
- **Dato** `dx.LayoutLookAndFeelNoGroupBorder`
- **Quando** si chiede `GetGroupBorderOffset` per qualunque lato
- **Allora** il risultato è 0

## ZBASE-ICO-007 Barre e menu a comparsa delle barre
`dx.InitBar(Barra)` rende la barra fissa e senza personalizzazioni: non chiudibile (`AllowClose`), non personalizzabile (`AllowCustomizing`, `AllowQuickCustomizing`), non ripristinabile (`AllowReset`), senza bordo (`bbsNone`), una sola barra per riga (`OneOnRow`), senza il segno di ulteriori comandi (`ShowMark`), occupa tutta la riga (`WholeRow`) e prende lo spazio residuo (`UseRestSpace`).

`dx.dxBarAssignPopupMenu(Barra, Menu)` collega a una barra un menu a comparsa per il clic destro sui pulsanti: salva il menu nel `Tag` del controllo della barra e imposta `OnMouseDown` con `dx.dxBarMouseDown`. Il controllo della barra esiste solo quando la barra è stata realizzata a video: se `Barra.Control` è nullo la funzione **non fa nulla e non lo segnala** (DIV-ICO-3).

`dx.dxBarMouseDown` (gestore interno, assegnato dalla funzione precedente): con il tasto destro su una voce di tipo `TdxBarButton` o `TdxBarLargeButton` mostra il menu alle coordinate dello schermo del clic, dopo aver messo nel `Tag` del menu il puntatore all'azione della voce, e **interrompe** l'evento con `Abort`; con altri tasti o altre voci non fa nulla (DIV-ICO-4).

`dx.dxBarRequiredWidth(Barra)` restituisce la larghezza che serve alla barra per mostrare tutti i pulsanti su una riga: 0 se la barra o il suo controllo sono nulli; la larghezza attuale del controllo se almeno una voce visibile non ha ancora il suo controllo (barra non finita di costruire, per non misurare una larghezza falsa); altrimenti la larghezza massima calcolata da DevExpress per la barra in alto. Qualunque eccezione durante il calcolo è ingoiata e il risultato resta quello già calcolato, di norma 0 (DIV-ICO-5).

### Scenario: barra fissa
- **Dato** una barra appena creata dal gestore di barre
- **Quando** si chiama `dx.InitBar`
- **Allora** `AllowClose`, `AllowCustomizing`, `AllowQuickCustomizing`, `AllowReset` e `ShowMark` sono falsi, `WholeRow`, `OneOnRow` e `UseRestSpace` sono veri e `BorderStyle` è `bbsNone`

### Scenario: barra non ancora realizzata
- **Dato** una barra il cui controllo non esiste
- **Quando** si chiama `dx.dxBarAssignPopupMenu` e poi `dx.dxBarRequiredWidth`
- **Allora** la prima non solleva e non collega nulla, la seconda restituisce 0

## ZBASE-ICO-008 Anteprima di stampa
`dx.InitPrinter(Stampante)` (29 chiamate, quasi tutte in zPack e nelle schede di stampa) prepara un `TdxComponentPrinter`: toglie `cpoShowHourGlass` dalle opzioni (la clessidra di ExpressPrinting usa un contatore e un cursore globali condivisi da tutti i printer del processo; se una sola operazione lunga non si chiude, la clessidra resta su tutta l'applicazione, come successo il 2026-09-29 stampando il contratto da Progetti: il cursore lo gestisce chi chiama la stampa), non salva posizione e zoom dell'anteprima, titolo `Anteprima`, finestra massimizzata, larghezza 800, a sinistra 0 e in alto 0. L'altezza non viene impostata (DIV-ICO-6).

### Scenario: stampante nuova
- **Dato** un `TdxComponentPrinter` con `cpoShowHourGlass` attivo
- **Quando** si chiama `dx.InitPrinter`
- **Allora** `cpoShowHourGlass` non è più nelle opzioni, il titolo dell'anteprima è `Anteprima` e `WindowState` è `wsMaximized`

## ZBASE-ICO-009 Griglie, alberi, tabelle pivot e calendario
- `dx.InitGrid(Vista)`: `BestFitMaxRecordCount` 50, formato dei filtri sulle date `dd.mm.yyyy`, selezione di cella attiva; stili di sfondo e contenuto `cxStyleContent`, righe pari `cxStyleContentEven`, dispari `cxStyleContentOdd`, riquadro filtro `cxStyleFilterBox`. Per una vista che ha un `TcxGridDBDataController` mette `GridMode` vero (la griglia legge i record a richiesta); per un `TcxGridDBTableView` aggiunge intestazione `cxStyleHeader`, piede `cxStyleFooter` e `HideSelection` falso (la selezione resta visibile senza fuoco). Una `TcxGridTableView` non collegata a un database non riceve intestazione, piede né `HideSelection`.
- `dx.InitTreeList` ha due versioni con lo stesso nome e `ApplyStyles` predefinito vero. Per `TcxTreeList`: senza bordo, stile `lfUltraFlat`, il rettangolo di fuoco resta visibile, e con `ApplyStyles` sfondo e contenuto con lo stile del controllo (`scControl`), piede `scFooter`, inattivo `cxStyleTreeListInactive`. Per `TcxDBTreeList`: senza bordo, stile **`lfFlat`**, rettangolo di fuoco visibile, e con `ApplyStyles` sfondo, contenuto **e inattivo** con `scControl`, piede `scFooter` (DIV-ICO-2). Con `ApplyStyles` falso gli stili restano quelli del controllo.
- `dx.InitPivot(Pivot)`: senza bordo, `lfUltraFlat`, stile nativo spento, contenuto e sfondo `cxStyleContent`, intestazioni di campo, colonna, riga e area dati `cxStyleHeader`, sfondo delle intestazioni `cxStyleHeaderBackground`, selezione `cxStyleHighlight`.
- `dx.InitScheduler(Calendario)`: vista classica (`svsClassic`), intestazione del giorno con giorno e data, intestazione non in contenitore, righello con i minuti; stili: contenuto `cxStyleContent`, evento `cxStyleInfoBk`, intestazione del giorno `cxStyleBtnFace`, selezione `cxStyleHighlight`.
- `dx.DrawBandSeparator` (quattro versioni per i tipi di cella di un albero a bande) disegna il separatore verticale fra le bande col colore `ckSeparator`; **nessun chiamante nel codice** (DIV-ICO-9).

### Scenario: griglia collegata a un database
- **Dato** un `TcxGridDBTableView` appena creato
- **Quando** si chiama `dx.InitGrid`
- **Allora** `BestFitMaxRecordCount` è 50, `GridMode` è vero, `Styles.Header` è `cxStyleHeader` e `HideSelection` è falso

### Scenario: albero con database
- **Dato** un `TcxDBTreeList` e un `TcxTreeList`
- **Quando** si chiama `dx.InitTreeList` su entrambi
- **Allora** il primo è `lfFlat` e il secondo `lfUltraFlat`

## ZBASE-ICO-010 Titoli, etichette, separatori, schede, divisori e filtri
- `dx.InitLabel(Etichetta, Trasparente=Vero)`: carattere e colore propri (non ereditati), controller di stile `LabelStyleController`, `Properties.ShowEndEllipsis` vero solo se `AutoSize` è falso (un'etichetta di larghezza fissa tronca con i puntini), trasparenza secondo il parametro.
- `dx.InitTitle(Titolo)`: come `InitLabel` con trasparenza falsa, poi controller `TitleStyleController` (grassetto). `dx.InitSeparator(Separatore)`: come `InitLabel` con trasparenza falsa, poi `SeparatorStyleController` (grassetto).
- `dx.InitPageControl(Schede)`: azzera i valori propri del look and feel, nessuna sosta con Tab, evidenziazione al passaggio del mouse (`HotTrack`), senza cornice, `RaggedRight` vero, una sola riga (`MultiLine` falso) **solo se le linguette sono in alto** (`tpTop`); se ci sono pagine attiva la prima **senza far scattare `OnPageChanging`** (il gestore è tolto e rimesso).
- `dx.InitSplitter(Divisore)`: stile della zona sensibile `TcxMediaPlayer9Style` e spessore 7 pixel: altezza se è allineato in alto o in basso, larghezza se a sinistra o a destra.
- `dx.SetFilterControlFonts(Filtro)`: carattere e dimensione di `MediumStyleController` (11 punti) su operatore booleano, condizione, voce e valore, e sul carattere del controllo se è un `TcxFilterControl`; con filtro nullo non fa nulla.

### Scenario: etichetta di larghezza fissa
- **Dato** un `TcxLabel` con `AutoSize` falso
- **Quando** si chiama `dx.InitLabel`
- **Allora** `Properties.ShowEndEllipsis` è vero, la trasparenza è vera e il controller di stile è `LabelStyleController`

### Scenario: schede con le linguette in basso
- **Dato** un `TcxPageControl` con `TabPosition` uguale a `tpBottom` e `MultiLine` vero
- **Quando** si chiama `dx.InitPageControl`
- **Allora** `MultiLine` resta vero, `ShowFrame` è falso e `HotTrack` è vero

### Scenario: divisore orizzontale
- **Dato** un `TcxSplitter` con `AlignSplitter` uguale a `salTop`
- **Quando** si chiama `dx.InitSplitter`
- **Allora** l'altezza è 7

## ZBASE-ICO-011 Dal tipo di controllo alla classe di editor e di proprietà
`dx.GetCustomEditClass(Tipo, DatiCollegati=Vero)` restituisce la classe dell'editor per un `TzCtrlType`; `dx.GetPropertiesClass(Tipo)` la classe delle sue proprietà (la usano le colonne di griglia, le righe della vista record, le colonne degli alberi e i campi pivot). Con `DatiCollegati` vero gli editor sono quelli con collegamento ai dati (`TcxDBxxx`). Mappatura (valida per entrambe, salvo dove indicato):

| Tipo | Editor (collegato ai dati) | Proprietà |
|---|---|---|
| `ctDefault`, `ctEdit` | `TcxDBTextEdit` | `TcxTextEditProperties` |
| `ctSpin` | `TcxDBSpinEdit` | `TcxSpinEditProperties` |
| `ctDate`, `ctDateTime` | `TcxDBDateEdit` | `TcxDateEditProperties` |
| `ctTime` | `TcxDBTimeEdit` | `TcxTimeEditProperties` |
| `ctComboBox` | `TcxDBComboBox` | `TcxComboBoxProperties` |
| `ctPickList`, `ctPickListImage` | `TcxDBImageComboBox` | `TcxImageComboBoxProperties` |
| `ctRadioGroup` | `TcxDBRadioGroup` | `TcxRadioGroupProperties` |
| `ctComboDlg`, `ctCustomDlg`, `ctButtonEdit` | `TcxDBButtonEdit` | `TcxButtonEditProperties` |
| `ctLookup` | `TcxDBLookupComboBox` | `TcxLookupComboBoxProperties` |
| `ctLookupExt`, `ctLookupHyperLink` | `TcxDBExtLookupComboBox` | `TcxExtLookupComboBoxProperties` |
| `ctCheckBox` | `TcxDBCheckBox` | `TcxCheckBoxProperties` |
| `ctMemo` | `TcxDBMemo` | `TcxMemoProperties` |
| `ctRTF` | `TcxDBRichEdit` | `TcxRichEditProperties` |
| `ctImage` | `TcxDBImage` | `TcxImageProperties` |
| `ctHyperLink` | `TcxDBHyperLinkEdit` | `TcxHyperLinkEditProperties` |
| `ctProgressBar` | `TcxDBProgressBar` | `TcxProgressBarProperties` |
| `ctRating` | `TdxDBRatingControl` | `TdxRatingControlProperties` |
| `ctColorCombo` | `TcxDBColorComboBox` | `TcxColorComboBoxProperties` |
| `ctCheckComboBox` | `TcxDBCheckComboBox` | `TcxCheckComboBoxProperties` |
| `ctToggleSwitch` | `TdxDBToggleSwitch` | `TdxToggleSwitchProperties` |
| `ctDateTimeWheelPicker` | `TdxDBDateTimeWheelPicker` | `TdxDateTimeWheelPickerProperties` |
| `ctTokenEdit` | `TdxDBTokenEdit` | `TdxTokenEditProperties` |
| `ctFormattedLabel` | `TdxDBFormattedLabel` | `TdxFormattedLabelProperties` |
| `ctCheckGroupBox` | `TdxDBCheckGroupBox` | `TdxCheckGroupBoxProperties` |
| `ctMaskEdit` | `TcxDBMaskEdit` | `TcxMaskEditProperties` |
| `ctCheckGroup` | `TcxDBCheckGroup` | `TcxCheckGroupProperties` |
| `ctShellComboBox` | `TcxDBShellComboBox` | `TcxShellComboBoxProperties` |

Con `DatiCollegati` falso gli editor sono quelli liberi (`TcxTextEdit`, `TcxSpinEdit`, ..., `TdxRatingControl`) per i tipi da `ctDefault` a `ctCustomDlg`; per i dieci tipi `ctCheckComboBox`, `ctToggleSwitch`, `ctDateTimeWheelPicker`, `ctTokenEdit`, `ctFormattedLabel`, `ctCheckGroupBox`, `ctButtonEdit`, `ctMaskEdit`, `ctCheckGroup`, `ctShellComboBox` la risposta resta la classe collegata ai dati (DIV-ICO-1). Per `ctGroupBox`, `ctButton`, `ctSeparator` e `ctLineBreak` (elementi di disposizione, non editor) entrambe le funzioni restituiscono **nil** (DIV-ICO-7).

### Scenario: data collegata ai dati
- **Dato** il tipo `ctDate`
- **Quando** si chiede `dx.GetCustomEditClass(ctDate)` e `dx.GetPropertiesClass(ctDate)`
- **Allora** le classi sono `TcxDBDateEdit` e `TcxDateEditProperties`

### Scenario: editor libero
- **Dato** il tipo `ctCheckBox`
- **Quando** si chiede `dx.GetCustomEditClass(ctCheckBox, false)`
- **Allora** la classe è `TcxCheckBox`

### Scenario: tipo di disposizione
- **Dato** il tipo `ctSeparator`
- **Quando** si chiede la classe dell'editor o delle proprietà
- **Allora** il risultato è nil

## ZBASE-ICO-012 Proprietà di base per tipo di controllo
`dx.InitProperties(Tipo, Proprietà)` imposta i valori predefiniti di un editor in base al tipo; le proprietà passate devono essere della classe giusta per il tipo (quella di `GetPropertiesClass`): il codice converte con un cast senza controllo del tipo. Con proprietà nulle solleva `EAssertionFailed`. I tipi `ctDefault`, `ctEdit`, `ctSpin`, `ctDateTime`, `ctComboBox`, `ctRadioGroup`, `ctMemo`, `ctRTF`, `ctCustomDlg`, `ctDateTimeWheelPicker`, `ctTokenEdit`, `ctFormattedLabel`, `ctCheckGroupBox`, `ctButtonEdit`, `ctMaskEdit`, `ctCheckGroup`, `ctShellComboBox` e gli elementi di disposizione non cambiano nulla. Gli altri:
- `ctDate`: come `InitDateEdit` (ZBASE-ICO-014); `ctTime`: come `InitTimeEdit`;
- `ctPickList`: nessuna lista di immagini (altrimenti il testo si sposta a destra) e conferma immediata; `ctPickListImage`: lista `Immagini` e conferma immediata;
- `ctComboDlg`: tasto di cancellazione `VK_DELETE`, sola lettura;
- `ctLookup` (`TcxLookupComboBoxProperties`): elenco largo quanto serve e ridimensionabile, 10 righe, stile modificabile (`lsEditList`), niente filtro incrementale, ripristinabile, conferma immediata, ordinamento delle colonne spento, sincronizzazione della lista, `GridMode` falso (dal 10.11.2022 non chiama più `DataSet.Locate`), nessun invio con Tab del valore in popup, caratteri validi con in più `.` e `,` (per interi e decimali); se ha un solo pulsante ne aggiunge uno di tipo `bkEllipsis`;
- `ctLookupExt` e `ctLookupHyperLink` (`TcxExtLookupComboBoxProperties`): stesse impostazioni (anche 10 righe, ripristinabile, conferma immediata), `GridMode` **vero** (altrimenti carica tutto il dataset), rotellina del mouse disattivata (non funziona), pulsante `bkEllipsis` aggiunto se ce n'è uno solo; per `ctLookupHyperLink` si aggiunge un secondo pulsante `bkGlyph` con l'immagine 0 della lista `Glyphs` del modulo. Nel ramo `ctLookup` il controllo su `ctLookupHyperLink` non può mai scattare (DIV-ICO-8);
- `ctCheckBox`: terzo stato non ammesso, didascalia vuota;
- `ctImage`: adatta mantenendo le proporzioni, classe grafica `TdxSmartImage`, nessuna voce nel menu dell'immagine;
- `ctHyperLink`: mai prefisso automatico (`upNever`), un clic basta;
- `ctProgressBar`: il valore mostrato come testo con `%` (DIV-ICO-10);
- `ctRating`: 10 elementi, conferma immediata;
- `ctColorCombo`: gli stessi valori e gli stessi due gestori di `InitColorCombo` (ZBASE-ICO-015);
- `ctCheckComboBox`: nessun testo per l'elenco vuoto, 12 righe, ridimensionabile, valore come elenco di indici, conferma immediata, separatore `; ` e i due gestori di conversione fra valore e stati;
- `ctToggleSwitch`: didascalia vuota, indicatore a testo dentro l'interruttore, `No` per spento e `Si` per acceso (senza accento: DIV-ICO-11).

### Scenario: elenco con immagini
- **Dato** proprietà `TcxImageComboBoxProperties` con una lista assegnata
- **Quando** si chiama `dx.InitProperties(ctPickList, Proprietà)`
- **Allora** `Images` è nulla e `ImmediatePost` è vero

### Scenario: ricerca con tre pulsanti
- **Dato** proprietà `TcxExtLookupComboBoxProperties` con un solo pulsante
- **Quando** si chiama `dx.InitProperties(ctLookupHyperLink, Proprietà)`
- **Allora** i pulsanti sono tre: il primo di partenza, poi `bkEllipsis` e `bkGlyph`

### Scenario: interruttore
- **Dato** proprietà `TdxToggleSwitchProperties`
- **Quando** si chiama `dx.InitProperties(ctToggleSwitch, Proprietà)`
- **Allora** `StateIndicator.OffText` è `No` e `OnText` è `Si`

## ZBASE-ICO-013 Proprietà dal dizionario dei dati
`dx.InitProperties(Tipo, Proprietà, Dominio, Campo)` (11 chiamate: schede, viste, alberi, pivot) chiama prima la versione a due parametri e poi adatta le proprietà al dominio (`TzDomain`) del campo:
- se le proprietà sono di testo (`TcxCustomTextEditProperties`): allineamento orizzontale, maiuscole/minuscole (`CharCase`), formato di visualizzazione e di modifica, sola lettura dal dominio (`Domain.ReadOnly`). Se il dominio è un indirizzo e-mail (`SanificaEmail`) le lettere sono **sempre minuscole**, anche se il dizionario dice maiuscole. Se `PasswordChar` non è vuoto e diverso da `#0`: carattere di password (il primo del testo), pulsante per scoprire la password e `EchoMode` uguale a `eemPassword`;
- se sono numeriche (`TcxSpinEditProperties`): `MinValue` e `MaxValue` del dominio (con 0 e 0 DevExpress non pone limiti);
- se sono di una casella (`TcxCheckBoxProperties`): didascalia vuota; i valori sono **`S`/`N`** (stringhe) se `Campo` è un `TStringField`, oppure se `Campo` è nullo e il dominio si chiama `SI_NO`; altrimenti `Vero`/`Falso` (booleani);
- se il dominio ha una lista di valori (`PickList` non vuoto) con l'oggetto collegato, la lista riempie l'elenco (voci con descrizione, valore e icona per le caselle con immagini, voci di scelta per i gruppi di opzioni, righe di testo per gli altri editor di testo).

### Scenario: indirizzo e-mail
- **Dato** un dominio con `SanificaEmail` vero e `CharCase` uguale a `ecUpperCase`
- **Quando** si chiama `dx.InitProperties(ctEdit, Proprietà, Dominio, nil)` su proprietà di testo
- **Allora** `CharCase` delle proprietà è `ecLowerCase`

### Scenario: password
- **Dato** un dominio con `PasswordChar` uguale a `*`
- **Quando** si inizializzano proprietà di testo
- **Allora** il carattere è `*`, `EchoMode` è `eemPassword` e il pulsante per scoprire la password è attivo

### Scenario: casella su campo di testo
- **Dato** un `TStringField` e un dominio qualunque
- **Quando** si inizializzano proprietà `TcxCheckBoxProperties`
- **Allora** `ValueChecked` è `S` e `ValueUnchecked` è `N`

## ZBASE-ICO-014 Date e ore
`dx.InitDateEdit(Proprietà)` (usata da WT in `frmGera_ExportSAP`): tasto Oggi aggiunto ai pulsanti già presenti, `Kind` uguale a `ckDate`, ora né salvata né mostrata, riga Oggi visibile. `dx.InitTimeEdit(Proprietà)`: formato ore e minuti (`tfHourMin`) e pulsanti di incremento a destra (`sbpHorzRight`). `InitProperties` dà lo stesso risultato per `ctDate` e `ctTime`. (Gesty ha una procedura locale con lo stesso nome `InitTimeEdit` in `frmCalendarioAvvioCorsi`, che non è questa.)

All'avvio del programma la unit imposta, nella sezione di inizializzazione, due cose per tutti gli editor di data:
- `InitRegExprDateEditMask` inserisce nella maschera a espressione regolare di DevExpress (`cxFormatController.RegExprDateEditMask`), subito dopo la voce `'eom'`, le scorciatoie `'D'` e `'l'` (DIV-ICO-13);
- `cxDateUtils.SmartTextToDateFunc` diventa `zzSmartTextToDateFunc`: il testo `D` o `d` dà la data di oggi, `L` o `l` il lunedì della settimana in corso (`StartOfTheWeek`), ogni altro testo è letto con `TryStrToDateTime` usando le impostazioni regionali del sistema ma con **il punto come separatore delle date** (`01.02.2026`).

### Scenario: pulsanti aggiunti
- **Dato** proprietà di data con i soli pulsanti `btnClear`
- **Quando** si chiama `dx.InitDateEdit`
- **Allora** i pulsanti sono `btnClear` e `btnToday`, `Kind` è `ckDate`, `ShowTime` e `SaveTime` sono falsi e `ShowToday` è vero

### Scenario: scorciatoia della data
- **Dato** un campo data con la maschera di zPack
- **Quando** l'utente scrive `D` e lascia il campo
- **Allora** il campo contiene la data di oggi

## ZBASE-ICO-015 Editor a pulsante e a colori
`dx.InitButtonEdit(Proprietà, Gestore, Modificabile=Falso)` (usata da WT in `wizIntestatarioFrm`): assegna `OnButtonClick`, crea un pulsante se non ce n'è nessuno, rende il primo di tipo `bkEllipsis`, sola lettura se non modificabile e, in quel caso, stile `vsHideCursor` (nessun cursore di testo: il campo si comporta come una scelta); con `Modificabile` vero stile `vsNormal` e lettura e scrittura. `dx.InitColorCombo(Proprietà)`: stessi valori del ramo `ctColorCombo` di `InitProperties`: 12 righe ridimensionabili, nomi X11 senza descrizioni, lista X11 preparata, valore come numero intero, scelta del colore personalizzato attiva (stile `cxccsComboList`, finestra del colore completa). I due gestori collegati aggiungono il colore personalizzato scelto alla lista dei colori personalizzati (senza descrizione) se non c'è già né fra i colori standard né fra quelli personalizzati.

### Scenario: scelta con pulsante
- **Dato** proprietà `TcxButtonEditProperties`
- **Quando** si chiama `dx.InitButtonEdit(Proprietà, Gestore, false)`
- **Allora** `OnButtonClick` è assegnato, il primo pulsante è `bkEllipsis`, `ReadOnly` è vero e `ViewStyle` è `vsHideCursor`

### Scenario: colore
- **Dato** proprietà `TcxColorComboBoxProperties`
- **Quando** si chiama `dx.InitColorCombo`
- **Allora** `DropDownRows` è 12, `ShowDescriptions` è falso e `ColorValueFormat` è `cxcvInteger`

## ZBASE-ICO-016 Skin: galleria e selettore del ribbon
`dx.InitSkinChooserGalleryItem(Voce)` (4 chiamate, WT e Gesty) riempie la galleria degli aspetti di una voce di barra: se esiste il file di skin del programma (`<eseguibile>.skinres`, accanto all'eseguibile) la voce diventa visibile (`ivAlways`), la galleria è svuotata e riempita con le skin del file e con il gruppo degli stili predefiniti di DevExpress (un elemento per ciascun painter registrato di stile fra `StiliPredefiniti`, non interno e con i suoi dettagli: nome, didascalia e icone vengono dal painter; il riempimento a mano è necessario perché DevExpress non esegue il proprio e `VisibleLookAndFeelStyles` resterebbe senza effetto); se il file non c'è la voce è `ivNever`.

`dx.InitRibbonSkinSelector(Selettore)` (WT e Gesty): se esiste l'icona `editcolors` in `Immagini` la usa come glifo del selettore chiuso nel ribbon (`CollapsedGlyph`; altrimenti sembrerebbe identico all'icona di «Seleziona Aspetto»); se esiste il file di skin il selettore è visibile e carica il file, altrimenti è nascosto. `dx.RibbonSkinSelectorApplySkin(Nome, Gestito)` imposta `SkinName` del modulo al nome scelto e segna l'evento come gestito: il file `.skinres` viene sempre caricato come skin interna `UserSkin` (invariante usata in tutta l'applicazione, `RibbonColorSchemeName` compresa) e DevExpress, se non intercettato, applicherebbe il nome direttamente al `dxSkinController`.

### Scenario: file di skin assente
- **Dato** nessun file `.skinres` accanto all'eseguibile
- **Quando** si chiama `dx.InitSkinChooserGalleryItem`
- **Allora** la voce non è mostrata

## ZBASE-ICO-017 Correttore ortografico
`dx.InitSpellChecker(CartellaUtente)` (una chiamata in WT e una in Gesty, all'avvio) carica il dizionario italiano Hunspell, che **non è nel programma**: i file `it_IT.aff` (regole) e `it_IT.dic` (parole) vanno copiati accanto all'eseguibile. Senza uno dei due il correttore resta spento senza errore: `CorrettoreAttivo` è falso e `CorrettoreMotivo` dice quale file manca (prima le regole, poi le parole), col percorso completo, e che i due file vanno copiati accanto all'eseguibile. Con entrambi i file crea la voce del dizionario italiano (lingua 1040, caricamento diretto) e quella del dizionario dell'utente `User.dic` (nella cartella dell'utente se indicata, altrimenti accanto all'eseguibile), attiva il caricamento e imposta `CorrettoreAttivo` vero. Ogni chiamata riparte da zero: elenco dei dizionari svuotato, caricamento automatico spento, esito azzerato. Le proprietà `CorrettoreAttivo` e `CorrettoreMotivo` rispondono alla domanda «perché non mi segna gli errori?»; nel codice di WT e Gesty nessuno le legge (DIV-ICO-12).

`dx.ShowSpellingOptionsDialog` apre la finestra delle opzioni del correttore di DevExpress. `dx.PrepareSpellCheckerPopup(Punto, Menu)` aggiunge al menu le proposte di correzione se il punto indicato sta su una parola segnata (usata in Gesty e zPack nei menu degli editor di testo); con menu nullo solleva `EAssertionFailed`. Il gestore `dxSpellCheckerCheckAsYouTypePopup` si limita a scrivere nel registro la classe del menu.

### Scenario: dizionario assente
- **Dato** nessun file `it_IT.aff` accanto all'eseguibile
- **Quando** si chiama `dx.InitSpellChecker('')`
- **Allora** `CorrettoreAttivo` è falso e `CorrettoreMotivo` comincia con `Manca il file delle regole`
- **E** l'elenco dei dizionari è vuoto

## ZBASE-ICO-018 Filtri aperti e finestre modali; lettura del DFM del modulo
**Filtri aperti (Mantis #269).** Una finestra a discesa DevExpress lasciata aperta sotto un dialogo modale (filtro di colonna di una griglia, di un pivot, di un albero o del vertical grid, tendina di un editor) resta cliccabile e può cambiare il filtro, quindi riaprire il dataset su cui il dialogo sta lavorando. `dx.ChiudiFiltriAperti` chiude con `CloseUp` ogni finestra visibile derivata da `TcxPopupWindow` fra quelle di `Screen.CustomForms`, dall'ultima alla prima. Il costruttore del modulo la collega a ogni apertura di una finestra modale con un `TApplicationEvents` (`OnModalBegin`; un componente invece di `Application.OnModalBegin` perché si somma agli altri gestori invece di sostituirli). Si può chiamare anche prima di ogni operazione che cambia lo stato del dataset di una vista (una chiamata in zPack). Senza finestre aperte non fa nulla.

**Lettura del DFM.** `Tdx.ReadState` ignora i DPI con cui l'IDE ha salvato `zDX.dfm`: se `PixelsPerInch` è diverso da 0 e non siamo in progettazione scrive un avviso nel registro (`zDX.dfm salvato con PixelsPerInch = N: ignorato, si usano i DPI di sistema`) e lo azzera. Senza questo, DevExpress prende quel valore come scala di repository di stili, controller e liste e i caratteri di griglie, pivot e alberi escono dimezzati (successo il 2026-10-14 salvando il DFM da desktop remoto).

### Scenario: nessun filtro aperto
- **Dato** nessuna finestra a discesa visibile
- **Quando** si chiama `dx.ChiudiFiltriAperti`
- **Allora** non succede nulla e non viene sollevata nessuna eccezione

### Scenario: DFM salvato a 192 DPI
- **Dato** `zDX.dfm` con `PixelsPerInch = 192`
- **Quando** il modulo viene creato in esecuzione
- **Allora** `PixelsPerInch` resta 0 e nel registro compare l'avviso

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-ICO-1 🟡 (dedotta) | `GetCustomEditClass` con `DatiCollegati` falso restituisce ancora la classe collegata ai dati (`TcxDBCheckComboBox`, `TdxDBToggleSwitch`, `TdxDBDateTimeWheelPicker`, `TdxDBTokenEdit`, `TdxDBFormattedLabel`, `TdxDBCheckGroupBox`, `TcxDBButtonEdit`, `TcxDBMaskEdit`, `TcxDBCheckGroup`, `TcxDBShellComboBox`) per dieci tipi: nel ramo «libero» sono state copiate le righe del ramo collegato | Chi chiede un editor libero per questi tipi riceve un editor collegato ai dati: senza `DataSource` funziona, ma non è l'editor atteso e il tipo cambia da un tipo all'altro della stessa funzione |
| DIV-ICO-2 🟡 (dedotta) | `InitTreeList` per `TcxDBTreeList` usa `lfFlat` e dà lo stile `scControl` anche allo stato inattivo; quello per `TcxTreeList` usa `lfUltraFlat` (con il commento «era lfFlat») e lo stile `cxStyleTreeListInactive` | Due alberi nella stessa form, uno con database e uno senza, hanno bordi e colore dell'albero non attivo diversi |
| DIV-ICO-3 🟡 (dedotta) | `dxBarAssignPopupMenu` non fa nulla se `Barra.Control` è nullo (barra non ancora realizzata: form non mostrata o chiamata nel costruttore) e non lo segnala | Il menu del clic destro sui pulsanti non compare mai e nessun errore dice perché; 8 chiamate (4 Gesty, 4 zPack) |
| DIV-ICO-4 🟢 (dedotta) | `dxBarMouseDown` legge `Tag` del controllo come `TdxBarPopupMenu` senza controllare che sia stato scritto da `dxBarAssignPopupMenu`; nessun chiamante lo assegna a mano | Se un giorno lo si assegnasse a una barra senza menu (o se altro codice usasse `Tag`), l'accesso a un puntatore a caso farebbe cadere il programma |
| DIV-ICO-5 🟡 (dedotta) | `dxBarRequiredWidth` racchiude tutto in un `try/except` con `except` vuoto | Un'eccezione di DevExpress (stato a metà del controllo) viene ingoiata e la funzione restituisce 0; i 10 chiamanti in zPack che la usano come larghezza minima dimensionerebbero la barra a 0 senza alcun avviso |
| DIV-ICO-6 🟢 | `InitPrinter` assegna `PreviewOptions.Width := 800` due volte; l'altezza non è mai impostata | Quasi certamente la seconda riga voleva essere `Height`; la finestra è comunque massimizzata, quindi non si vede |
| DIV-ICO-7 🟡 (dedotta) | `GetCustomEditClass` restituisce nil per `ctGroupBox`, `ctButton`, `ctSeparator`, `ctLineBreak`; `zDbCard` chiama `dx.GetCustomEditClass(Tipo).Create(Card)` senza controllo | Un dominio del dizionario con uno di questi tipi su un campo dati farebbe una violazione di accesso invece di un errore comprensibile (non verificato che i chiamanti escludano i quattro tipi a monte) |
| DIV-ICO-8 🟢 | Nel ramo `ctLookup` di `InitProperties` c'è `if ControlType = ctLookupHyperLink` con il pulsante a immagine: il tipo è gestito dal ramo `ctLookupExt, ctLookupHyperLink` e il controllo non può mai scattare | Codice morto che fa credere che le ricerche normali possano avere il pulsante di collegamento; i due rami sono duplicati quasi identici |
| DIV-ICO-9 🟢 | `InitColorCombo`, `InitTimeEdit`, `DrawBandSeparator` (quattro versioni), `dxBarMouseDown` e `InitSeparator` non hanno chiamanti diretti (`InitSeparator` solo nelle copie di lavoro « - Mio» di `zDbCard`; `InitProperties` ripete le impostazioni di `InitTimeEdit` nel ramo `ctTime` invece di chiamarla; `RibbonSkinSelectorApplySkin` è collegato dal DFM o da codice non ricercabile con una ricerca di testo) | Codice che invecchia senza prove: `InitColorCombo`, `InitTimeEdit` e `InitDateEdit` ripetono i rami `ctColorCombo`, `ctTime` e `ctDate` di `InitProperties` e le copie possono divergere |
| DIV-ICO-10 🟡 (dedotta) | `ProgressBarEditValueChanged` (collegato da `InitProperties` per `ctProgressBar`) scrive `s := s + '%'` e poi `Properties.Text := s + '%'` | Il testo della barra di avanzamento è `50%%` invece di `50%` (il commento dice che serve a mostrare il valore reale oltre 100) |
| DIV-ICO-11 🟢 | L'interruttore (`ctToggleSwitch`) scrive `Si` senza accento per il testo dell'acceso | Testo errato per l'utente: dovrebbe essere `Sì` |
| DIV-ICO-12 🟢 (dedotta) | `CorrettoreAttivo` e `CorrettoreMotivo` non sono letti da nessuna parte in WT e Gesty; se il caricamento di un dizionario vero ma rovinato solleva un'eccezione, `CorrettoreMotivo` resta vuoto e l'eccezione esce da `InitSpellChecker` nel codice di avvio (`ConfigModule`) | La domanda «perché non mi segna gli errori?» per cui le proprietà sono nate non ha ancora una risposta visibile all'utente |
| DIV-ICO-13 🟢 (dedotta) | `InitRegExprDateEditMask` cerca `'eom'` nella maschera di DevExpress e inserisce dopo la sua posizione senza controllare che la voce esista; chiamata due volte inserisce due volte | Con una versione di DevExpress che cambi la maschera, le scorciatoie `D` e `l` finirebbero in un punto sbagliato e la maschera sarebbe rovinata senza errore; oggi parte una sola volta all'avvio |
| DIV-ICO-14 🟢 (dedotta) | In ricarica del layout, un nome di `LookAndFeel` o `LayoutLookAndFeel` vuoto viene ignorato, mentre in salvataggio un gruppo senza look and feel scrive stringa vuota | Se fra salvataggio e ricarica a un gruppo è stato assegnato un look and feel, la ricarica di un layout che non ne aveva non lo toglie |

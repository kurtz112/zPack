---
area: Colori e skin
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdx-dbmaster/002
---

# Colori e skin

Questa specifica descrive la parte di `zBase\zDX.pas` che sceglie la skin (l'aspetto grafico DevExpress) e fornisce a WT, Gesty e zPack i colori e gli stili che ne dipendono. Nel modulo dati `Tdx` (accessibile con la funzione `dx`): `SkinName`, `SkinPaletteName`, `SkinActive`, `GetSkinNames`, `LoadSkin`, `RibbonColorSchemeName`, `GetColor` e `GetFontColor` (due coppie di overload, con `TColorKind` e con `TStyleColor`), `GetStyle`, `RegisterCustomStyle`, `UnregisterCustomStyle`, `BlendColor`, `GetSkinColor`, `GetBarColor`. Fuori dal modulo, nella stessa unit: `SkinScura`, `ColorePalette`, `ColoreLeggibile`, `ColoreSuSkin`, che non hanno bisogno del modulo. Restano fuori da questa specifica le altre parti di zDX: lookup, editor, icone, barre, correttore ortografico.

Uso reale, contato nelle unit `.pas` di `D:\AI\SRC\Wintarif_Group`, `D:\AI\SRC\Gesty_Group` e `D:\AI\SRC\zPack`, escluse le righe dentro `zDX.pas`: `dx.GetStyle` 133 chiamate (90 in WT, 27 in Gesty, 16 in zPack; gli stili più usati sono `scContentEven` 24, `scContentOdd` 17, `scInfoBk` 16, `scControl` 16, `scBtnFace` 15, `scFooter` 12, `scContent` 11, `scHeader` 10), `dx.GetColor` 14, `dx.GetFontColor` 6, `dx.SkinActive` 10, `dx.SkinName` 6, `dx.SkinPaletteName` 7 (assegnazioni al cambio di skin e di tavolozza in `MainForm.pas` di WT e di Gesty), `dx.RibbonColorSchemeName` 7 (tutte nelle form di `zOffice`), `dx.RegisterCustomStyle` 1 e `dx.UnregisterCustomStyle` 4 (calendario dei turni di WT, `frmGera_CalendarioTurni.pas`), `dx.GetSkinNames` 2 (`Sonda.zBase.pas`). **Non hanno nessun chiamante fuori da `zDX.pas`**: `GetBarColor`, `GetSkinColor`, `BlendColor`, `SkinScura`, `ColorePalette`, `ColoreSuSkin`, `GetColorPippo`. WT ha una sua funzione `ColoreLeggibile` in `Varie\Indicatori.Cruscotto.Riquadri.pas` (algoritmo diverso, vedi DIV-CSK-7), che non è quella di `zDX`. Descrive il comportamento atteso, non il codice.

**Come funziona.** `dx` crea il modulo la prima volta che serve (`Tdx.Create(nil)`, poi `UpdateStyles`) e lo libera alla chiusura del programma. Il modulo contiene un `dxSkinController` (all'inizio senza skin: `UseSkins` falso nel DFM) e un insieme di stili DevExpress (`cxStyle*`) i cui colori vengono ricalcolati da `UpdateStyles` a ogni cambio di skin o di tavolozza. I colori si chiedono per **tipo** (`TColorKind`, 21 valori: controllo, contenuto, titolo, editor normale/obbligatorio/sola lettura/disabilitato, etichetta, separatore, procedura guidata, griglia, piede, filtro, albero, ispettore, pulsante) oppure per **stile** (`TStyleColor`, 15 valori, nomi di colori storici: `scMoneyGreen`, `scCream`, `scSkyBlue`...). Con una skin attiva i colori vengono dal painter (il disegnatore) della skin; senza skin sono colori fissi, in parte di sistema di Windows. Le quattro funzioni di unit calcolano invece colori di testo leggibili partendo dal look and feel di base (`RootLookAndFeel`), anche nei programmi che applicano la skin senza il controller di `Tdx`, e non creano il modulo.

**Test che coprono quest'area.** Nessuna prova esistente in `D:\AI\SRC\zPack\_UnitTest\_src` (`Test.zFormBuilder` cita `Tdx` ma non lo prova). Il test `Test.zDX.Colori` (38 prove) copre le funzioni di unit (ZBASE-CSK-013, 014, 015, 016) e il modulo `dx` senza skin: tabelle dei colori predefiniti, stili, `BlendColor`, valori di ricaduta, registrazione degli stili personalizzati (ZBASE-CSK-002 e da 003 a 012). Restano senza prova tutti i rami con una skin DevExpress caricata, il caricamento di una skin vera da file, la propagazione dei colori agli stili personalizzati (`UpdateStyles` e `UpdateCustomStyles` sono privati) e `GetColorPippo`: motivi nel commento in testa al test.

## ZBASE-CSK-001 Modulo unico, creato alla prima richiesta
`dx` restituisce sempre lo stesso modulo `Tdx`. Alla prima chiamata lo crea e subito dopo applica i colori correnti agli stili (`UpdateStyles`). Alla creazione il modulo non ha nessuna skin attiva, traduce i testi di DevExpress in italiano (l'esito va nel registro; una risorsa mancante non ferma l'avvio), imposta il carattere degli stili sul carattere di base e ignora i DPI con cui l'IDE ha salvato il DFM (si usano quelli di sistema). Non apre finestre e non legge file di skin. Il modulo si libera alla chiusura del programma.

### Scenario: prima chiamata
- **Dato** un programma che non ha ancora usato `dx`
- **Quando** il codice scrive `dx.GetStyle(scControl)`
- **Allora** il modulo viene creato, gli stili hanno già colore e carattere, e `dx.SkinActive` è falso

## ZBASE-CSK-002 Skin attiva o assente
`SkinActive` è vero solo quando `dxSkinController.UseSkins` è vero, cioè dopo il caricamento riuscito di una skin da file (ZBASE-CSK-003). `GetSkinPainter` restituisce il painter della skin solo se `SkinActive` è vero, altrimenti `nil`. `GetSkinInfo` restituisce i dati della skin attiva (`TdxSkinInfo`) o `nil` quando non c'è skin o il painter non espone i dati. Chi usa la libreria controlla `SkinActive` per decidere se salvare la scelta dell'utente (`MainForm` di WT lo fa dopo ogni `dx.SkinName := ...`).

### Scenario: nessuna skin
- **Dato** un programma appena avviato senza file di skin
- **Quando** si legge `dx.SkinActive`, `dx.GetSkinPainter` e `dx.GetSkinInfo`
- **Allora** il primo è falso e gli altri due sono nulli

## ZBASE-CSK-003 Scelta della skin
Assegnare `dx.SkinName := Nome` ricorda il nome (`SkinName` lo restituisce com'è, anche se poi non si applica) e chiama sempre `LoadSkin` (privato), che ricarica anche se il nome è uguale a quello di prima. `LoadSkin`, dentro `BeginUpdate`/`EndUpdate` del controller, sceglie fra tre vie, nell'ordine:
1. se esiste il file `.skinres` accanto all'eseguibile (stesso nome, estensione `.skinres`), il nome non è vuoto e il file contiene una skin con quel nome: la carica sempre con il nome interno `UserSkin`, attiva le skin (`UseSkins` vero, `NativeStyle` falso) e applica la tavolozza ricordata (`SkinPaletteName`);
2. altrimenti, se il nome è quello di uno stile predefinito diverso dal nativo (Standard, Flat, UltraFlat, Office11, riconosciuti dai painter registrati): disattiva le skin, azzera il nome nel controller e imposta il tipo di aspetto corrispondente;
3. in ogni altro caso (nome vuoto, sconosciuto, file mancante) ricade sullo stile nativo di Windows: `NativeStyle` vero, `UseSkins` falso.
Alla fine ricalcola tutti gli stili (`UpdateStyles`). Dopo la scelta, `SkinActive` dice se una skin è stata davvero applicata. `GetSkinNames(Lista)` svuota la lista e la riempie con i nomi delle skin contenute nel file `.skinres`; con una lista nulla non fa niente. `RibbonSkinSelectorApplySkin` fa passare la scelta del selettore del ribbon da `SkinName` e dichiara l'evento gestito, perché DevExpress non applichi il nome direttamente al controller.

### Scenario: nome sconosciuto
- **Dato** nessun file `.skinres` accanto all'eseguibile
- **Quando** si assegna `dx.SkinName := 'Pippo'`
- **Allora** `dx.SkinName` vale `Pippo`, `dx.SkinActive` è falso e l'aspetto è quello nativo

### Scenario: skin caricata
- **Dato** un file `.skinres` con una skin di nome `Office 2019 Black` (esempio)
- **Quando** si assegna `dx.SkinName := 'Office 2019 Black'`
- **Allora** `dx.SkinActive` è vero e `dx.RibbonColorSchemeName` vale `UserSkin`

## ZBASE-CSK-004 Tavolozza della skin
`dx.SkinPaletteName := Nome` ricorda il nome. Se una skin è attiva lo applica subito al controller e ricalcola gli stili; se non c'è skin lo tiene soltanto: verrà applicato al prossimo caricamento di una skin (ZBASE-CSK-003, via 1). I colori restituiti senza skin non cambiano.

### Scenario: tavolozza prima della skin
- **Dato** nessuna skin attiva
- **Quando** si assegna `dx.SkinPaletteName := 'Red'`
- **Allora** `dx.SkinPaletteName` vale `Red` e `dx.GetColor(ckEditorNormal)` resta invariato

## ZBASE-CSK-005 Nome dello schema colori del ribbon
`RibbonColorSchemeName` restituisce `UserSkin` quando `SkinActive` è vero, `White` altrimenti. Va assegnato a `ColorSchemeName` dei ribbon.

### Scenario: senza skin
- **Dato** nessuna skin attiva
- **Quando** si legge `dx.RibbonColorSchemeName`
- **Allora** il risultato è `White`

## ZBASE-CSK-006 Colori di sfondo per tipo (`GetColor(TColorKind)`)
Con una skin attiva i colori vengono dal painter: controllo, titolo, etichetta, procedura guidata, filtro, albero, ispettore e pulsante usano `DefaultControlColor`; contenuto e contenuto di griglia `DefaultContentColor`; editor normale e obbligatorio `DefaultEditorBackgroundColorEx(esckNormal)` (**un editor obbligatorio sotto skin ha lo stesso sfondo di uno normale**), sola lettura e disabilitato le varianti `esckReadOnly` ed `esckDisabled`; separatore `DefaultHeaderBackgroundColor`; titolo e filigrana della procedura guidata `DefaultHeaderColor`; righe pari e dispari di griglia `DefaultContentEvenColor` e `DefaultContentOddColor`; piede di griglia `DefaultFooterColor`. Senza skin valgono colori fissi, che l'applicazione riconosce a vista (verde denaro per gli editor):

| Tipo | Colore senza skin |
|---|---|
| `ckControl`, `ckLabel`, `ckWizard`, `ckEditorDisabled` | grigio pulsante di sistema (`clBtnFace`) |
| `ckContent`, `ckTitle`, `ckEditorReadOnly` | sfondo dei suggerimenti di sistema (`clInfoBk`) |
| `ckEditorNormal`, `ckGridContent`, `ckGridContentOdd`, `ckTreeView` | verde denaro (`$00C0DCC0`) |
| `ckEditorRequired` | `$00A6CAF0` (valore numerico 10930928; il commento dice «clCream», vedi DIV-CSK-8) |
| `ckGridContentEven` | `$00DDECDD` |
| `ckSeparator` | ombra pulsante (`clBtnShadow`) |
| `ckWizardTitle` | finestra di sistema (`clWindow`) |
| `ckWizardWaterMark` | barra del titolo attiva (`clActiveCaption`) |
| `ckGridFooter`, `ckInspector`, `ckInspectorValues`, `ckBtnFace` | `clBtnFace` |
| `ckFilterBox` | `clBtnShadow` |

### Scenario: senza skin
- **Dato** nessuna skin attiva
- **Quando** si chiede `dx.GetColor(ckEditorNormal)`
- **Allora** il risultato è il verde denaro `$00C0DCC0`

### Scenario: etichetta con skin
- **Dato** una skin attiva
- **Quando** si chiede `dx.GetColor(ckLabel)`
- **Allora** il risultato è `DefaultControlColor` del painter della skin

## ZBASE-CSK-007 Colori del testo per tipo (`GetFontColor(TColorKind)`)
Senza skin il testo è nero (`TColors.Black`) per tutti i tipi, con tre eccezioni: `ckEditorDisabled` grigio di sistema (`clGrayText`), `ckSeparator` bianco pulsante (`clBtnHighlight`: il separatore ha sfondo ombra), `ckInspectorValues` blu scuro (`Navy`). Con una skin attiva il colore viene dal painter della coppia sfondo/testo corrispondente (`DefaultControlTextColor`, `DefaultContentTextColor`, `DefaultEditorTextColorEx(...)`, `DefaultHeaderBackgroundTextColor` per il separatore, `DefaultFooterTextColor` per il piede). Anche `ckFilterBox` usa `DefaultControlTextColor` (prima restituiva per errore `DefaultControlColor`, lo sfondo: DIV-CSK-1, corretta nel rilascio 002).

### Scenario: editor disabilitato senza skin
- **Dato** nessuna skin attiva
- **Quando** si chiede `dx.GetFontColor(ckEditorDisabled)`
- **Allora** il risultato è il grigio di sistema dei testi disabilitati

## ZBASE-CSK-008 Colori per stile (`GetColor` e `GetFontColor` con `TStyleColor`)
I dieci stili storici hanno un sfondo e un testo. Senza skin:

| Stile | Sfondo | Testo |
|---|---|---|
| `scBtnFace` | `clBtnFace` | nero |
| `scMoneyGreen` | verde denaro `$00C0DCC0` | nero |
| `scMoneyGreenLight` | `$00E7F1E7` | nero |
| `scCream` | `$00A6CAF0` | nero |
| `scInfoBk` | `clInfoBk` | `clInfoText` |
| `scSkyBlue` | azzurro cielo (`Skyblue`) | nero |
| `scSkyBlueLight` | `$00FAF1E4` | nero |
| `scHeader` | `clBtnFace` | `clBtnText` |
| `scHeaderBackground` | `clBtnShadow` | `clBtnFace` |
| `scHighlight` | `clHighlight` | nero |

Con skin: `scBtnFace` usa `DefaultControlColor`; `scMoneyGreen` `DefaultContentColor`; `scMoneyGreenLight` `DefaultContentEvenColor`; `scCream` `DefaultContentOddColor`; `scInfoBk` `DefaultInactiveColor`; `scSkyBlue` e `scHighlight` `DefaultSelectionColor`; `scSkyBlueLight` e `scHeaderBackground` `DefaultHeaderBackgroundColor`; `scHeader` `DefaultHeaderColor`. Il testo viene da `DefaultControlTextColor` salvo `scHeader` (`DefaultHeaderTextColor`), `scHeaderBackground` (`DefaultHeaderBackgroundTextColor`) e `scHighlight` (`DefaultSelectionTextColor`). I cinque stili `scControl`, `scContent`, `scContentOdd`, `scContentEven`, `scFooter` **non sono gestiti** da questi due metodi: restituiscono nero, con e senza skin (DIV-CSK-4); per quelli si usa `GetStyle` o il `TColorKind` corrispondente.

### Scenario: stile senza skin
- **Dato** nessuna skin attiva
- **Quando** si chiede `dx.GetColor(scHighlight)` e `dx.GetFontColor(scHighlight)`
- **Allora** i risultati sono `clHighlight` e nero

### Scenario: stile di contenuto
- **Dato** una qualunque skin
- **Quando** si chiede `dx.GetColor(scContentEven)`
- **Allora** il risultato è nero, non il colore delle righe pari (usare `dx.GetColor(ckGridContentEven)`)

## ZBASE-CSK-009 Stili DevExpress (`GetStyle`)
`GetStyle(Stile)` restituisce, per ognuno dei 15 valori di `TStyleColor`, uno `TcxStyle` esistente e diverso da tutti gli altri (mai `nil`): è il modo normale in cui il codice di WT e di Gesty assegna stili a griglie, alberi e pivot (`Styles.Content := dx.GetStyle(scContent)`). Colore e carattere degli stili sono tenuti allineati da `UpdateStyles`, chiamato alla creazione del modulo, a ogni `SkinName` e, se c'è una skin, a ogni `SkinPaletteName`:
- i dieci stili storici (da `scBtnFace` a `scHighlight`) prendono sfondo e testo dai due `GetColor` e `GetFontColor` con lo stesso `TStyleColor`;
- `scControl` prende i colori di `ckControl`; `scContent`, `scContentEven`, `scContentOdd`, `scFooter` quelli di `ckGridContent`, `ckGridContentEven`, `ckGridContentOdd`, `ckGridFooter`.
`UpdateStyles` aggiorna anche i controller di stile degli editor (titolo, etichetta, separatore, normale, sola lettura, obbligatorio, albero, pulsante) e il colore degli alberi inattivi (selezione del painter), e infine gli stili personalizzati (ZBASE-CSK-010). I controller di titolo e separatore ricevono anche `TextColor` esplicito: sotto skin la etichetta altrimenti scriverebbe col colore delle etichette della skin (bianco nelle skin scure) sopra lo sfondo chiaro dato qui.

### Scenario: stile di griglia
- **Dato** nessuna skin attiva
- **Quando** si legge `dx.GetStyle(scContentEven).Color`
- **Allora** vale `$00DDECDD`, come `dx.GetColor(ckGridContentEven)`

## ZBASE-CSK-010 Stili personalizzati
`RegisterCustomStyle(Stile, StileBase, ValoriAssegnati)` lega uno stile proprio a uno stile base: i valori NON elencati in `ValoriAssegnati` (`svBitmap`, `svColor`, `svFont`, `svTextColor`) vengono copiati subito dalla base e ricopiati a ogni `UpdateStyles` (cioè a ogni cambio di skin o tavolozza); i valori elencati restano quelli dello stile. Esempio d'uso reale (WT, calendario dei turni): stile con solo il colore del testo proprio, `[svTextColor]`, e sfondo e carattere che seguono la skin. `UnregisterCustomStyle(Stile)` toglie il legame; se lo stile non è registrato, non fa niente. **Chi registra uno stile deve annullarlo prima di liberarlo** (WT lo fa in `FormDestroy`): il modulo tiene un puntatore e non ha altro modo di accorgersi che lo stile non esiste più (DIV-CSK-3).

### Scenario: solo il testo è proprio
- **Dato** uno stile base con colore rosso e testo blu, e uno stile con colore verde e testo giallo
- **Quando** si registra lo stile con `[svTextColor]`
- **Allora** lo stile ha colore rosso (copiato) e testo giallo (proprio)

### Scenario: annullamento di uno stile estraneo
- **Dato** uno stile mai registrato
- **Quando** si chiama `UnregisterCustomStyle` con quello stile
- **Allora** non succede niente

## ZBASE-CSK-011 Miscela di colori (`BlendColor`)
`BlendColor(Colore1, Colore2, Percentuale)` restituisce il colore a `Percentuale`% della strada da `Colore1` a `Colore2`, canale per canale (rosso, verde, blu, con divisione intera arrotondata). La percentuale viene limitata fra 0 e 100: 0 dà `Colore1`, 100 dà `Colore2`. I colori di sistema vengono prima convertiti in RGB, quindi il risultato è sempre un valore RGB fisso.

### Scenario: venti per cento
- **Dato** nero e bianco
- **Quando** si chiama `dx.BlendColor(clBlack, clWhite, 20)`
- **Allora** il risultato è il grigio RGB (51, 51, 51)

### Scenario: percentuale fuori intervallo
- **Dato** nero e bianco
- **Quando** si chiama `dx.BlendColor(clBlack, clWhite, 150)`
- **Allora** il risultato è bianco

## ZBASE-CSK-012 Colori della skin e della barra (`GetSkinColor`, `GetBarColor`)
`GetSkinColor(Nome, Predefinito)` restituisce il colore di nome `Nome` della skin attiva, o `Predefinito` se non c'è skin attiva o la skin non ha quel colore. `GetBarColor` restituisce il colore di aggancio delle barre (`Dock.Color` della skin attiva) o `clWindow` se non c'è skin. Oggi nessun programma li usa (DIV-CSK-6).

### Scenario: senza skin
- **Dato** nessuna skin attiva
- **Quando** si chiama `dx.GetBarColor`
- **Allora** il risultato è `clWindow`

## ZBASE-CSK-013 Colore della palette (`ColorePalette`)
`ColorePalette(Nome, Predefinito)` restituisce il colore di nome `Nome` della tavolozza attiva della skin (`'Red'`, `'Green'`, `'Blue'`, `'Key Paint'`...) cercandolo nel look and feel di base; restituisce `Predefinito`, **senza convertirlo**, se non c'è skin, se la skin non ha una tavolozza attiva, se il nome non esiste o se il colore trovato è `clNone` o `clDefault`. Non corregge il colore per il contrasto: per un testo si usa `ColoreSuSkin` (ZBASE-CSK-015). Non crea il modulo `Tdx` e non dipende dal suo `SkinActive`.

### Scenario: nessuna skin
- **Dato** un programma senza skin applicata
- **Quando** si chiama `ColorePalette('Red', clFuchsia)`
- **Allora** il risultato è `clFuchsia`

## ZBASE-CSK-014 Colore leggibile (`ColoreLeggibile`)
`ColoreLeggibile(Colore, Sfondo=clDefault)` restituisce un colore di testo leggibile su `Sfondo`, cioè con rapporto di contrasto WCAG di almeno **4,5:1** (livello AA del testo normale). `Sfondo` uguale a `clDefault` significa il fondo del contenuto del painter attivo (`DefaultContentColor`). Il rapporto è `(L1 + 0,05) / (L2 + 0,05)`, con `L` la luminanza relativa WCAG 2.x (canali con correzione gamma sRGB e pesi 0,2126, 0,7152, 0,0722) del colore più chiaro e di quello più scuro. Regole:
- il risultato è sempre un valore RGB (`ColorToRGB` del colore): un colore di sistema perde il legame con il tema;
- se il contrasto è già sufficiente, il colore resta quello (convertito in RGB);
- altrimenti si mescola il colore, a passi del 10% da 10% a 100%, **verso il bianco se il bianco ha più contrasto del nero sullo sfondo, altrimenti verso il nero**, e ci si ferma al primo passo che raggiunge 4,5:1; così la tinta resta riconoscibile;
- su qualunque sfondo il risultato raggiunge 4,5:1: nero e bianco non possono fallire insieme (l'incrocio dei due contrasti è circa 4,58), e l'ultimo passo è proprio il bianco o il nero;
- applicata due volte con lo stesso sfondo, dà lo stesso risultato della prima.

### Scenario: già leggibile
- **Dato** nero su bianco
- **Quando** si chiama `ColoreLeggibile(clBlack, clWhite)`
- **Allora** il risultato è nero

### Scenario: giallo su bianco
- **Dato** il giallo (`clYellow`, contrasto circa 1,07 su bianco)
- **Quando** si chiama `ColoreLeggibile(clYellow, clWhite)`
- **Allora** il risultato è il giallo scurito al 60% verso il nero, RGB (102, 102, 0): al 50% il contrasto è ancora sotto 4,5

### Scenario: bianco su bianco
- **Dato** testo e sfondo bianchi
- **Quando** si chiama `ColoreLeggibile(clWhite, clWhite)`
- **Allora** il risultato è il grigio RGB (102, 102, 102), contrasto circa 5,7

### Scenario: sfondo grigio medio
- **Dato** lo sfondo grigio 128, su cui il nero ha contrasto circa 5,3 e il bianco circa 4
- **Quando** si chiama `ColoreLeggibile(clSilver, clGray)`
- **Allora** il colore viene scurito, non schiarito

## ZBASE-CSK-015 Colore della palette reso leggibile (`ColoreSuSkin`)
`ColoreSuSkin(NomePalette, Predefinito, Sfondo=clDefault)` è `ColoreLeggibile(ColorePalette(NomePalette, Predefinito), Sfondo)`: il colore della tavolozza della skin, o `Predefinito`, portato a 4,5:1 sullo sfondo. È la funzione da usare per un testo disegnato a mano (`OnCustomDraw` di alberi e griglie, etichette di stato) che deve seguire la skin.

### Scenario: nessuna skin
- **Dato** un programma senza skin
- **Quando** si chiama `ColoreSuSkin('Red', clYellow, clWhite)`
- **Allora** il risultato è quello di `ColoreLeggibile(clYellow, clWhite)`

## ZBASE-CSK-016 Skin scura (`SkinScura`)
`SkinScura` è vera quando sul fondo del contenuto del painter attivo (`DefaultContentColor` del look and feel di base) il bianco si legge meglio del nero, cioè quando il contrasto con il bianco è maggiore di quello con il nero (fondo con luminanza sotto circa 0,18). Vale anche nei programmi che applicano la skin senza il controller di `Tdx`, e non crea il modulo.

### Scenario: fondo chiaro
- **Dato** un fondo del contenuto bianco
- **Quando** si chiama `SkinScura`
- **Allora** il risultato è falso

### Scenario: fondo scuro
- **Dato** un fondo del contenuto grigio molto scuro (luminanza sotto 0,18)
- **Quando** si chiama `SkinScura`
- **Allora** il risultato è vero

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-214 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-CSK-1 ✅ (corretta, rilascio 002) | `GetFontColor(ckFilterBox)` con skin attiva restituiva `Painter.DefaultControlColor` (colore di sfondo). Ora restituisce `Painter.DefaultControlTextColor`, come `ckTreeView` e `ckInspector`; senza skin resta nero | Sotto skin il testo del riquadro del filtro è leggibile. Non provata in automatico: servirebbe una skin caricata (vedi «Test che coprono quest'area») |
| DIV-CSK-2 🟡 (dedotta) | `RegisterCustomStyle` aggiunge la voce a `CustomStyles` **prima** di chiamare `UpdateCustomStyle`, e non controlla che `Stile` e `StileBase` esistano | Con `StileBase` nullo la chiamata solleva un errore di accesso, ma la voce guasta resta nell'elenco: ogni `UpdateStyles` successivo (cambio di skin o di tavolozza) risolleva lo stesso errore |
| DIV-CSK-3 🟡 (dedotta) | `UnregisterCustomStyle` toglie solo la prima voce che coincide (poi `Break`), e `RegisterCustomStyle` non impedisce di registrare lo stesso stile due volte; uno stile liberato senza essere stato annullato resta nell'elenco | Dopo la distruzione dello stile il prossimo `UpdateStyles` usa un puntatore non valido e può dare un errore di accesso o scrivere in memoria liberata. Oggi l'unico chiamante (calendario dei turni di WT) annulla uno stile per volta in `FormDestroy`, quindi non si manifesta |
| DIV-CSK-4 🟢 (dedotta) | `GetColor` e `GetFontColor` con `TStyleColor` non gestiscono `scControl`, `scContent`, `scContentOdd`, `scContentEven`, `scFooter`: restituiscono il valore iniziale (nero) sia con skin sia senza. `GetStyle` invece li gestisce | Nessun chiamante oggi (verificato: le chiamate trovate usano solo gli altri dieci stili), ma chi scrivesse `dx.GetColor(scContent)` otterrebbe nero senza errori |
| DIV-CSK-5 🟢 | `GetColorPippo` ha il corpo tutto commentato («DA GUARDARE»), una variabile locale mai usata (`LSkinInfo`) e non assegna `Result` | Codice morto: nessun chiamante in WT, Gesty, zPack; se qualcuno lo chiamasse otterrebbe un valore indefinito (l'avviso del compilatore W1035 lo segnala). Da eliminare |
| DIV-CSK-6 🟢 (dedotta) | `GetSkinColor` non scarta `clNone` e `clDefault` e non controlla che `SkinInfo.Skin` esista, mentre `ColorePalette` fa entrambe le cose; cerca inoltre solo con skin attiva nel controller, mentre `ColorePalette` legge il look and feel di base. Né `GetSkinColor` né `GetBarColor` né `BlendColor` hanno chiamanti | Funzioni quasi equivalenti con comportamenti ai bordi diversi; finché nessuno le chiama non si vede. Anche `SkinName` ricorda il nome chiesto anche quando `LoadSkin` ricade sul nativo: chi lo legge per sapere «quale skin c'è» (e non `SkinActive`) ottiene un nome che non è in uso |
| DIV-CSK-7 🟢 | WT ha una funzione `ColoreLeggibile(Colore, Sfondo)` in `Varie\Indicatori.Cruscotto.Riquadri.pas` con lo stesso nome e gli stessi parametri della funzione di `zDX`, ma un altro algoritmo (luminosità percepita ITU-R BT.601, soglia 128, schiarisce del 40% verso il bianco solo sui fondi scuri, mai verso il nero) e nessuna garanzia di contrasto | Oggi nessuna unità le include entrambe (`frmCruscottoIndicatori.pas` usa quella di WT e non ha `zDX` nell'`uses`), ma chi aggiungesse `zDX` in una di quelle unit otterrebbe l'una o l'altra a seconda dell'ordine dell'`uses`. Il testo dei riquadri di WT non ha la garanzia 4,5:1 |
| DIV-CSK-8 🟢 (dedotta) | `ckEditorRequired` e `scCream` senza skin valgono il valore numerico `10930928` (`$00A6CAF0`) con il commento «clCream» / «TColors.Cream»; il codice altrove usa `TColors.MoneyGreen`, `TColors.Skyblue` per nome, non per numero | Se la costante di sistema `clCream` ha un altro valore, il commento mente; da verificare sul valore di `TColors.Cream` e, in caso, sostituire il numero con il nome |
| DIV-CSK-9 🟢 (dedotta) | `UpdateStyles` chiama `dx.GetColor(...)` e `dx.GetFontColor(...)` tramite la funzione globale `dx` invece che tramite `Self`: un `Tdx` creato con `Tdx.Create(nil)` fuori dalla funzione `dx` farebbe leggere e scrivere `UpdateStyles` sul modulo unico (che, se non esiste ancora, verrebbe creato in quel momento) | Oggi esiste un solo modulo, quindi nessun effetto; se un test o un secondo programma creasse un `Tdx` proprio, i suoi stili non verrebbero mai aggiornati. Da tenere presente per chi scrive prove |

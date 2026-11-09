---
area: Controller delle pagine
progetto: zBase
aggiornato: 2026-11-03
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/017
---

# Controller delle pagine

Questa specifica descrive `TPageControlController` (`zBase\PageControlController.pas`), il componente che ogni form (`TBaseForm`) e ogni frame (`TBaseFrame`) di WT e Gesty crea per gestire i contenitori a schede `TcxPageControl` messi nel loro disegno: fa aprire i dataset della scheda che diventa visibile, riporta i contenitori alla prima scheda visibile quando la form si apre e adatta l'altezza dei contenitori che portano schede di dati (`TzDbCard`). Lo creano `BaseFrm.pas` di WT (riga 565) e di Gesty (riga 452) e `Base_Frame.pas` di WT (riga 71) e di Gesty (riga 122), sempre con la form o il frame come proprietario; `frmInterrogazioni.pas` di WT lo estende a un pannello (`InitContainer(mainPanel)`) e `frmTariffe.pas` ne sospende il calcolo (`DisableCalcSize := BloccaDettagli`). È un'altra cosa rispetto al cambio scheda dei form documentali (`TzFormController`, ZBASE-FRM-009 in `Controller dei form.md`) e al controller delle azioni (`ActionListController.pas`, che sta nella stessa cartella `zBase` e **non** è oggetto di questa specifica). La unit è compilata (la usano le quattro unit base citate).

**Come funziona.** Il controller lavora sui `TcxPageControl` **posseduti** dal suo proprietario (quelli con `Owner` uguale al proprietario, cioè i componenti messi nel disegno della form o creati con quel proprietario). `InitForm`, `InitFrame` o `InitContainer` agganciano a ciascuno un gestore `OnChange` che attiva i dataset della scheda raggiunta e ricalcola l'altezza, poi richiama il gestore originale. `ResetActivePages`, `ActivateDataSets` e `AutoSizePageControls` sono azioni che la form richiama nei momenti giusti: all'apertura, dopo la costruzione dei controlli, dopo un ridimensionamento. Le schede di dati sono `TzDbCard` e `TzDbView` (anche dentro pannelli e dentro altri contenitori a schede); l'altezza di una scheda la dà `TzDbCard.CalcDialogHeight`.

**Test che coprono quest'area.** Nessuna prova esistente in `zPackTests`. Il test `Test.PageControlController` prova con una form creata con `CreateNew` e mai mostrata: i valori iniziali (ZBASE-PGC-001), il gestore originale richiamato dopo quello del controller (ZBASE-PGC-001), il ritorno alla prima scheda visibile (ZBASE-PGC-003, prova ignorata con voce R-213: senza finestra `TcxPageControl` non applica `ActivePageIndex`), il calcolo sospeso o impossibile senza finestra (ZBASE-PGC-004, 005), il `Tag` di un contenitore con una scheda di dati posseduta dalla form (DIV-PGC-3, con una `TzDbCard` di prova che prende come genitore la finestra della form) e la divergenza DIV-PGC-4. Restano senza prova l'attivazione dei dataset (richiede `TzDbCard`, `TzDbView` e il database) e il calcolo vero dell'altezza (richiede un contenitore visualizzato con un handle di finestra).

## ZBASE-PGC-001 Collegamento al proprietario e aggancio degli eventi
`TPageControlController.Create(Proprietario)` richiede un proprietario (`Assert`) e parte con `DisableCalcSize` falso. `InitForm(Form)`, `InitFrame(Frame)` e `InitContainer(Controllo)` fanno la stessa cosa sul componente indicato: per ogni `TcxPageControl` **posseduto** da quel componente che non è già registrato, ricordano l'`OnChange` originale (solo se assegnato) e lo sostituiscono con il gestore del controller. Quando il contenitore cambia scheda, il gestore: attiva i dataset della scheda attiva (ZBASE-PGC-002), ricalcola l'altezza (ZBASE-PGC-004) e **poi** richiama l'`OnChange` originale con lo stesso mittente. Se il contenitore ha allineamento in alto o in basso (`alTop`, `alBottom`), l'aggancio ne imposta anche `Tag`: l'altezza di partenza se contiene almeno una `TzDbCard` fra i controlli figli, a qualunque profondità e chiunque la possieda, altrimenti 0 (DIV-PGC-3 corretta nel rilascio 017; DIV-PGC-4), e fa il primo calcolo. Un contenitore già agganciato non viene agganciato una seconda volta, con o senza `OnChange` originale: è «già agganciato» se è registrato oppure se il suo `OnChange` è già il gestore di questo controller (DIV-PGC-1 corretta il 2026-11-02, rilascio 005). Un secondo `InitForm`, `InitFrame` o `InitContainer` è quindi innocuo e il gestore originale resta quello vero. `InitContainer` agisce sui componenti posseduti dal controllo indicato, non sul proprietario del controller: i contenitori così agganciati non sono poi visti da `ResetActivePages`, `ActivateDataSets` e `AutoSizePageControls`, che guardano solo il proprietario (DIV-PGC-2).

### Scenario: valori iniziali
- **Dato** un controller creato con una form come proprietaria
- **Quando** si legge `DisableCalcSize`
- **Allora** è falso

### Scenario: gestore originale richiamato
- **Dato** una form con un contenitore a schede che ha un proprio `OnChange` che conta le chiamate
- **Quando** si chiama `InitForm(Form)` e poi si invoca `OnChange` del contenitore
- **Allora** il contatore sale di uno
- **E** `OnChange` del contenitore non è più il gestore originale

### Scenario: contenitore senza gestore originale
- **Dato** una form con un contenitore a schede senza `OnChange`
- **Quando** si chiama `InitForm(Form)` e si invoca `OnChange` del contenitore
- **Allora** non si solleva alcun errore

### Scenario: aggancio ripetuto
- **Dato** una form con un contenitore a schede, senza `OnChange` oppure con un proprio `OnChange` che conta le chiamate
- **Quando** si chiama `InitForm(Form)` due volte e si invoca `OnChange` del contenitore
- **Allora** non c'è ricorsione e non si solleva alcun errore
- **E** il gestore originale, se c'è, è richiamato una sola volta

## ZBASE-PGC-002 Attivazione dei dataset della scheda visibile
`ActivateDataSets` scorre i `TcxPageControl` posseduti dal proprietario e, per ciascuno che sia **visibile**, attiva i dataset della sua scheda attiva. Un contenitore è visibile se lo è lui (`Visible`) e se ogni scheda `TcxTabSheet` che lo contiene, risalendo i genitori, è visibile ed è la scheda attiva del suo contenitore; non guarda se pannelli intermedi sono nascosti. L'attivazione (la stessa che parte dal cambio scheda) scende nella scheda attiva: ogni `TzDbCard` incontrata riceve `ActivateDataSet` e poi `ForceDisplay` e non è esplorata oltre; ogni `TzDbView` riceve `ActivateDataSet`; un contenitore a schede annidato è esplorato solo nella sua scheda attiva; ogni altro controllo a finestra è esplorato in profondità, **compresi** i pannelli nascosti. Le schede non attive di un contenitore a schede **non** si toccano: i loro dataset restano chiusi finché non diventano attive. Ogni attivazione scrive una riga di avviso nel registro SmartInspect con il nome del contenitore (DIV-PGC-6).

### Scenario: contenitore nascosto
- **Dato** un contenitore a schede con `Visible = False`
- **Quando** si chiama `ActivateDataSets`
- **Allora** nessun dataset è attivato

### Scenario: scheda non attiva
- **Dato** un contenitore a schede visibile con due schede, la prima attiva, e una `TzDbView` nella seconda
- **Quando** si chiama `ActivateDataSets`
- **Allora** il dataset della vista nella seconda scheda resta chiuso
- **E** passando alla seconda scheda (`OnChange`) viene attivato

## ZBASE-PGC-003 Ritorno alla prima scheda visibile
`ResetActivePages` porta ogni `TcxPageControl` posseduto dal proprietario e con almeno una pagina alla **prima pagina visibile**, in ordine di indice (`ActivePageIndex := FirstVisiblePage`). Se nessuna pagina è visibile sceglie la pagina 0 (nascosta). Contenitori senza pagine non fanno niente. Si usa all'apertura della form per evitare lo sfarfallio delle schede (WT la chiama subito dopo `InitForm` e prima della visualizzazione, Gesty prima della visualizzazione se non è in modalità di selezione `PkMode`) e quando si espande il pannello (`ExpandButtonActivated` di Gesty).

### Scenario: prima pagina visibile
- **Dato** un contenitore con tre pagine, la prima nascosta e la seconda attiva
- **Quando** si chiama `ResetActivePages`
- **Allora** la pagina attiva è la seconda (la prima visibile)

### Scenario: nessuna pagina visibile
- **Dato** un contenitore con due pagine entrambe nascoste
- **Quando** si chiama `ResetActivePages`
- **Allora** l'indice della pagina attiva è 0

### Scenario: contenitore vuoto
- **Dato** un contenitore senza pagine
- **Quando** si chiama `ResetActivePages`
- **Allora** non si solleva alcun errore

## ZBASE-PGC-004 Altezza dei contenitori con schede di dati
`AutoSizePageControls` chiama il calcolo dell'altezza su ogni `TcxPageControl` posseduto dal proprietario. Il calcolo (`CalcPageControlSize`) non fa niente se è sospeso (ZBASE-PGC-005), se il contenitore è nullo, se non ha ancora un handle di finestra (non mostrato: il layout delle schede non è pronto e ricalcolare ora dereferenzierebbe un oggetto nullo), o se l'allineamento non è in alto o in basso. Altrimenti, sulla scheda attiva cerca la `TzDbCard` più alta fra i controlli figli, a qualsiasi profondità, con `CalcDialogHeight`. **Se non ne trova** nessuna, mantiene l'altezza attuale quando `Tag` è 0 (nessuna scheda di dati in tutto il contenitore) e altrimenti torna all'altezza memorizzata in `Tag`. **Se ne trova**, l'altezza diventa quella più 3 più il bordo (altezza del contenitore meno altezza del client della scheda). In ogni caso non supera l'altezza del proprietario meno 50 punti (form: `Height`, frame: `Height`; limite inferiore 0) e si imposta solo se è diversa da quella attuale. Il calcolo ha il solo effetto di cambiare `Height` del contenitore.

### Scenario: senza finestra
- **Dato** un contenitore con allineamento in alto e senza handle di finestra, con altezza 120
- **Quando** si chiama `AutoSizePageControls`
- **Allora** l'altezza resta 120

### Scenario: allineamento diverso
- **Dato** un contenitore con allineamento `alClient`
- **Quando** si chiama `AutoSizePageControls`
- **Allora** l'altezza non cambia

## ZBASE-PGC-005 Sospensione del calcolo
`DisableCalcSize` vero fa uscire subito `CalcPageControlSize` (sia dal cambio scheda sia da `AutoSizePageControls`) senza toccare niente; si può cambiare in qualunque momento. `frmTariffe.pas` di WT lo imposta uguale a `BloccaDettagli` per tenere fermi i dettagli mentre l'utente li ridimensiona a mano.

### Scenario: calcolo sospeso
- **Dato** un controller con `DisableCalcSize = True` e un contenitore agganciato
- **Quando** si invoca `OnChange` del contenitore e si chiama `AutoSizePageControls`
- **Allora** l'altezza del contenitore non cambia

## Divergenze note
Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce «R-213» di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. Le righe citate sono quelle di `PageControlController.pas`.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| ~~DIV-PGC-1~~ ✅ corretta il 2026-11-02 (rilascio 005), provata da `InitForm_ChiamatoDueVolte...`; sul codice vecchio la prova faceva cadere il programma per overflow dello stack | Testo originale: `doInitPageControls` (213-219) registra il contenitore nel dizionario **solo se** aveva un `OnChange` originale; se non l'aveva, dopo il primo aggancio non risulta registrato e un secondo `InitForm`, `InitFrame` o `InitContainer` sullo stesso proprietario lo riaggancia leggendo come «originale» il gestore del controller stesso | Al cambio scheda il gestore richiama se stesso all'infinito e l'applicazione va in overflow dello stack. Oggi `BaseFrm` chiama `InitForm` una volta sola, quindi non si presenta; basta una seconda chiamata (per esempio `InitContainer` sul proprietario) per scatenarlo. |
| DIV-PGC-2 🟡 (dedotta) | `InitContainer(Controllo)` aggancia i contenitori posseduti da quel controllo, ma `ResetActivePages`, `ActivateDataSets` e `AutoSizePageControls` (107-164, 237-261) scorrono solo i componenti del proprietario del controller; in `frmInterrogazioni.pas` (riga 183) il controller della form è esteso al `mainPanel` | I contenitori creati con il pannello come proprietario reagiscono al cambio scheda, ma non sono mai riportati alla prima pagina, né attivati o ridimensionati dalle chiamate della form |
| DIV-PGC-3 ✅ (corretta) | `HasCard` cercava le `TzDbCard` fra i componenti posseduti dal contenitore, mentre il calcolo dell'altezza le cerca fra i controlli figli. Corretta nel rilascio 017: `HasCard` scende nei controlli figli, provata da `InitForm_SchedaDiDatiPossedutaDallaForm_TagUgualeAllAltezza` (sul codice vecchio dava `Tag` 0) | Nessuna |
| DIV-PGC-4 🟢 (dedotta) | Per i contenitori in alto o in basso `doInitPageControls` scrive in `Tag` (223-225) l'altezza di partenza o 0, senza tenere conto di un `Tag` che la form o il disegno avessero già impostato | Un `Tag` assegnato a un contenitore a schede per altri scopi viene cancellato dall'aggancio; chi lo legge dopo `InitForm` trova 0 o un'altezza |
| DIV-PGC-5 🟢 (dedotta) | In `EnumCtrls` (302-307) la riga `H := Max(result, ZCard.CalcDialogHeight)` assegna alla variabile `H` del metodo esterno e il valore si perde: serve la chiamata seguente (`EnumCtrls` sul figlio, che è una `TWinControl`) per far entrare l'altezza in `result` | `CalcDialogHeight` viene chiamato due volte per ogni scheda diretta, a ogni cambio scheda e a ogni ridimensionamento; il codice sembra voler scrivere `result := Max(...)` |
| DIV-PGC-6 🟢 (dedotta) | `InternalActivateDataSets` (102) scrive `LogWarning(PageControl.Name)` a ogni attivazione, cioè a ogni cambio scheda e a ogni `ActivateDataSets` | Il registro SmartInspect si riempie di avvisi per un'azione normale: sembra una riga di prova rimasta |
| DIV-PGC-7 🟢 (dedotta) | `CalcMaxHeight` (273-280) non ha ramo finale: se il proprietario non è una form né un frame il risultato non è assegnato | Con un proprietario di altro tipo (per esempio un componente non visivo) il limite massimo dell'altezza è un numero casuale; `BaseFrm` e `Base_Frame` passano sempre una form o un frame, quindi non si presenta |
| DIV-PGC-8 🟢 (dedotta) | `ResetActivePages` (237-261) sceglie la pagina 0 quando nessuna pagina è visibile (`FirstVisiblePage` parte da 0) | Un contenitore con tutte le pagine nascoste mostra la pagina 0 anche se nascosta: a seconda del componente, una scheda vuota o una pagina che l'utente non dovrebbe vedere |

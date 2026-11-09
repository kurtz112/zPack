---
area: Mappa
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Mappa

Questa specifica descrive `zBase\zMap.pas` (con `zMap.dfm`): il frame `TzMap`, il componente che mostra una mappa interattiva (componente `TTMSFNCMaps` di TMS FNC) dentro le form di WT, Gesty e zTicser, con marcatori, poligoni, ricerca degli indirizzi e strati cartografici letti da Firebird. È registrato nella palette `zBase` (`zBaseRegister`). Contiene anche i tipi `TMarkerIconColor`, `TGeocodeResult`, `TGeocodingResultStruct` e `TServiceApi` e la procedura `SetGoogleAPI`. Il tipo `TzMapType` è dichiarato con il commento «eliminare» e non ha nessun uso.

Chi lo usa (verificato con una ricerca in `D:\AI\SRC`):

| Progetto | Unit | Cosa chiama |
|---|---|---|
| WT | `dmCommon`, `WT.Globals` | `SetGoogleAPI(Get_GMAPS_API_KEY)` all'avvio |
| WT | `dmMaps` | strati GIS: `AddPolygons(Database, 'GIS_14_EDIFICI', ...)`, `AddMarkers(Database, 'GIS_13_CIVICI', ...)`, `ClearPolygons`, `ClearMarkers`, `ZoomLevel`, `Ready`; legge `DataObject` e `DataString` dei marcatori al clic |
| WT | `frmComuni`, `frmImmobili`, `frmIntestatari`, `frmQta_RFID`, `frmQta_Sacchi`, `frmQta_GiriRaccolta`, `frmAnalisiContenitori`, `frmWT_Import` | `GotoAddress`, `GotoAddressSync`, `AddMarker`, `AddMarkers(DataSet, ...)` quasi sempre con `FillMarker` |
| Gesty | `ConfigModule` (`SetGoogleAPI(Key)`), `frmAziende` (`GetAddressCoordinates`, `AddMarker`, `AddMarkers(DataSet, ...)`) | |
| zTicser | `ConfigModule` | `SetGoogleAPI(Key)` |

**Come funziona.** La mappa nasce con servizio cartografico OpenLayers e geocodifica OpenStreetMap, che non richiedono chiavi. `SetGoogleAPI(Chiave)` salva la chiave in una variabile globale (`ServiceApi`) che ogni `TzMap` legge **una volta sola, nel costruttore**; con una chiave il servizio configurato per quella mappa può essere uno di Google. Le operazioni di disegno (`AddMarker`, `AddPolygons`, ...) accettano un «nome di origine» (`SourceName`, tipicamente il nome del dataset o dello strato) che finisce in `DataString` dell'elemento: serve a togliere dalla mappa tutto ciò che viene da una sorgente senza toccare le altre. Le proprietà da mostrare al clic stanno in una `TStringList` (`DataObject` dell'elemento) posseduta dal frame. La configurazione di ogni mappa (servizio, intervallo, zoom, descrizione, azioni della barra) è salvata nel dizionario LZ con chiave `MapId`.

**Test che coprono quest'area.** `Test.zMap` (in `zPack\_UnitTest\_src`), nelle sole parti che non richiedono una mappa visibile: `SetGoogleAPI`, `TGeocodingResultStruct`, `IconUrl` e `GetProperties`. Il resto (disegno, geocodifica, strati GIS, attesa della mappa) richiede il browser incorporato (WebView2) e un database Firebird con gli strati: si prova con il collaudo sul banco, non con prove automatiche.

## ZBASE-MAP-001 Chiave dei servizi
`SetGoogleAPI(Chiave)` azzera `ServiceApi` (`MapAPI` e `GeocodingApi` diventano vuote) e, se la chiave **non è vuota**, la scrive in entrambi i campi. Con chiave vuota restano vuoti. All'avvio dell'unit `ServiceApi` è vuota. Ogni `TzMap` copia i due valori in `Map.ApiKey` e `Geocoding.ApiKey` nel proprio costruttore: una chiave impostata dopo la creazione di una mappa non la raggiunge (DIV-MAP-9).

### Scenario: chiave valida
- **Dato** `ServiceApi` vuota
- **Quando** si chiama `SetGoogleAPI('abc123')`
- **Allora** `ServiceApi.MapAPI` e `ServiceApi.GeocodingApi` valgono `abc123`

### Scenario: chiave vuota dopo una valida
- **Dato** `ServiceApi` con una chiave
- **Quando** si chiama `SetGoogleAPI('')`
- **Allora** entrambi i campi tornano vuoti

## ZBASE-MAP-002 Servizi predefiniti e ripiego
`GeocodingService` vale `gsOpenStreetMap` e `MapService` vale `msOpenLayers` alla creazione. Assegnare un servizio diverso ha effetto solo se la chiave corrispondente non è vuota: senza chiave la mappa resta su OpenLayers o OpenStreetMap, anche se la configurazione salvata chiede Google. `MapChangedInterval` predefinito 300 (millisecondi), `ZoomLevel` iniziale quello predefinito del componente (troncato a intero).

### Scenario: servizio Google senza chiave
- **Dato** una mappa con `ServiceApi` vuota
- **Quando** la configurazione salvata chiede un servizio di mappe diverso da OpenLayers
- **Allora** `MapService` resta `msOpenLayers`

## ZBASE-MAP-003 Esito della geocodifica
`TGeocodingResultStruct` riassume l'ultima ricerca di un indirizzo. `Clear` porta l'esito a `grNone`, azzera latitudine e longitudine e svuota `ResultString`. `SetCoordinates(Coordinata)` chiama prima `Clear`, poi copia latitudine e longitudine e imposta `grNotFound` se **entrambe valgono 0**, `grFound` altrimenti. Un esito `grBusy` indica una ricerca in corso (impostato da `GotoAddress` e `GotoAddressSync`).

### Scenario: indirizzo non trovato
- **Dato** una coordinata con latitudine 0 e longitudine 0
- **Quando** si chiama `SetCoordinates`
- **Allora** `Result` è `grNotFound`

### Scenario: indirizzo trovato
- **Dato** una coordinata con latitudine 45,5 e longitudine 9,1
- **Quando** si chiama `SetCoordinates`
- **Allora** `Result` è `grFound` e le coordinate sono quelle passate

### Scenario: un solo valore a zero
- **Dato** una coordinata con latitudine 0 e longitudine 9
- **Quando** si chiama `SetCoordinates`
- **Allora** `Result` è `grFound`

## ZBASE-MAP-004 Ricerca di un indirizzo
- `GetAddressCoordinates(Indirizzo)` interroga il servizio di geocodifica in modo sincrono e restituisce la coordinata (0, 0 se non trovato).
- `GotoAddressSync(Indirizzo, Colore, Zoom)` con indirizzo vuoto restituisce falso senza fare niente. Altrimenti geocodifica; se trova (coordinata diversa da 0, 0) centra la mappa, aggiunge un marcatore con titolo uguale all'indirizzo e identificativo −1 se `Colore` non è `icNone`, e restituisce vero; altrimenti restituisce falso e non tocca la mappa.
- `GotoAddress(Indirizzo, Callback, Colore, Zoom)` con indirizzo vuoto esce senza richiamare `Callback`. Altrimenti geocodifica in modo asincrono; al risultato aspetta che la mappa sia pronta (`WaitForReady`, al massimo 3 secondi e mai se la mappa non è visibile, è in distruzione o l'applicazione è chiusa), centra la mappa, aggiunge il marcatore come sopra e poi richiama `Callback`. Se la mappa non diventa pronta, non fa niente e **non richiama `Callback`**.
- Il parametro `Zoom` (predefinito 15) di entrambe le procedure **non viene usato** (DIV-MAP-1); `GotoAddress` non controlla l'esito della ricerca (DIV-MAP-2).

### Scenario: indirizzo vuoto
- **Dato** una mappa pronta
- **Quando** si chiama `GotoAddressSync('')`
- **Allora** il risultato è falso e la mappa non cambia

### Scenario: indirizzo trovato in modo sincrono
- **Dato** un indirizzo che il servizio sa risolvere
- **Quando** si chiama `GotoAddressSync(Indirizzo, icRed)`
- **Allora** la mappa è centrata sull'indirizzo, c'è un marcatore rosso con titolo uguale all'indirizzo e il risultato è vero

## ZBASE-MAP-005 Elementi con origine
`AddMarker`, `AddCircle`, `AddRectangle`, `AddPolygon` e `AddPolyline` creano l'elemento sulla mappa e gli assegnano `DataInteger` = identificativo (−1 se non c'è), `DataString` = nome di origine (stringa vuota se omesso) e `DataObject` = copia delle proprietà (ZBASE-MAP-006). `ClearMarkers`, `ClearPolygons`, `ClearCircles`, `ClearRectangles` e `ClearPolylines` con un nome di origine tolgono **solo** gli elementi il cui `DataString` è uguale al nome (**confronto con distinzione delle maiuscole**); con nome vuoto o omesso tolgono **tutti** gli elementi di quel tipo. `Clear` toglie tutto e libera le proprietà.

### Scenario: due sorgenti sulla stessa mappa
- **Dato** marcatori di origine `A` e marcatori di origine `B`
- **Quando** si chiama `ClearMarkers('A')`
- **Allora** restano solo i marcatori di `B`

### Scenario: nome vuoto
- **Dato** marcatori di origine `A` e `B`
- **Quando** si chiama `ClearMarkers`
- **Allora** non resta nessun marcatore (DIV-MAP-3)

## ZBASE-MAP-006 Proprietà mostrate al clic
`GetProperties(DataSet, Nomi, Elenco)` svuota `Elenco` e vi aggiunge una riga `Nome=Valore` per ogni campo elencato in `Nomi`, nell'ordine dato. I nomi sono separati da `;` o da `,`; i nomi vuoti sono saltati. Il valore è il testo del campo nel record corrente (`AsString`); un campo che non esiste nel dataset dà `Nome=` con valore vuoto, senza errori. I nomi non vengono ripuliti dagli spazi. Per gli strati GIS vale la stessa regola con `VarToStr` del valore e senza saltare i nomi vuoti (DIV-MAP-8). Le proprietà di un elemento si copiano in una `TStringList` nuova solo se non sono vuote; altrimenti `DataObject` resta `nil`. Le copie appartengono al frame e sono liberate da `Clear` e, quando `ClearCache` è vero, da ogni `AddMarkers` e `AddPolygons` (DIV-MAP-4).

### Scenario: due campi
- **Dato** un dataset con `ID` = 7 e `NOME` = `Rossi` nel record corrente
- **Quando** si chiama `GetProperties(DataSet, 'ID;NOME', Elenco)`
- **Allora** `Elenco` contiene `ID=7` e `NOME=Rossi`

### Scenario: separatore virgola e campo mancante
- **Dato** lo stesso dataset
- **Quando** si chiama `GetProperties(DataSet, 'ID,INESISTENTE', Elenco)`
- **Allora** `Elenco` contiene `ID=7` e `INESISTENTE=`

### Scenario: elenco precedente e nomi vuoti
- **Dato** un `Elenco` che contiene già una riga
- **Quando** si chiama `GetProperties(DataSet, ';ID;;', Elenco)`
- **Allora** `Elenco` contiene la sola riga `ID=7`

## ZBASE-MAP-007 Marcatori da un dataset
`AddMarkers(DataSet, CampoChiave, CampoTitolo, Proprietà, FillMarker, GetColor, ClearCache)` toglie prima i marcatori con origine uguale a `DataSet.Name` (con nome vuoto: tutti, DIV-MAP-3), poi scorre il dataset dal primo record all'ultimo. Per ogni riga: se `FillMarker` è assegnato lo chiama, e non fa altro (il disegno è a suo carico); altrimenti legge i campi **`LATITUDINE` e `LONGITUDINE`** (obbligatori: se mancano `FieldByName` solleva un errore del dataset), l'identificativo dal campo chiave (−1 se il nome del campo è vuoto), il titolo dal campo titolo (vuoto se il nome è vuoto), il colore da `GetColor` (predefinito `icRed`) e le proprietà con `GetProperties`; aggiunge il marcatore con origine `DataSet.Name`. In ogni caso, anche dopo un errore, chiude l'aggiornamento della mappa, richiama `ZoomToMarkers` e rimette `Busy` a falso. Il dataset resta posizionato a fine file (DIV-MAP-5).

### Scenario: dataset con coordinate
- **Dato** un dataset di nome `ElencoAziende` con tre righe con `LATITUDINE` e `LONGITUDINE`
- **Quando** si chiama `AddMarkers(DataSet, 'ID_AZIENDA', 'AZIENDA', '', nil, nil)`
- **Allora** sulla mappa ci sono tre marcatori rossi con origine `ElencoAziende`, titolo preso da `AZIENDA`, e la mappa è zoomata sui marcatori

### Scenario: FillMarker
- **Dato** una procedura `FillMarker` che aggiunge un marcatore per riga
- **Quando** si chiama `AddMarkers(DataSet, '', '', '', FillMarker, nil)`
- **Allora** la libreria non legge `LATITUDINE` e `LONGITUDINE` e i marcatori sono quelli aggiunti da `FillMarker`

## ZBASE-MAP-008 Strati cartografici su Firebird
`AddMarkers(Database, Strato, Proprietà, Filtro, GetColor, ClearCache)` e `AddPolygons(Database, Strato, Proprietà, Filtro, GetColor, ClearCache)` leggono uno strato nel formato OpenGIS: tabella `<Strato>` con `GID`, `XMIN`, `YMIN`, `XMAX`, `YMAX` e `WKB_GEOMETRY` (geometria in WKB, coordinate **UTM 32N**) e tabella `<Strato>_FEA` con `GID` e gli attributi. Con una sola query uniscono le due tabelle e prendono le geometrie il cui rettangolo si sovrappone all'**area visibile** (convertita in UTM da `VisibleExtent`: se la mappa non diventa pronta l'area è tutta zero e non si legge niente di utile); il `Filtro`, se non è vuoto, è accodato alla `WHERE` con `AND (Filtro)` così come è scritto, senza controlli e senza espansione delle macro di FireDAC. `Strato` è usato come nome di tabella e come **origine** degli elementi, e le righe sono tolte prima con `ClearMarkers(Strato)` o `ClearPolygons(Strato)`.
- Marcatori: uno per riga, sul **primo punto della prima parte** della geometria, con identificativo `GID` e colore da `GetColor` (predefinito `icBlue`).
- Poligoni: una figura per ogni parte **esterna** (i buchi non si disegnano); una parte con un solo punto diventa un cerchio di raggio 1; le altre un poligono. Il colore restituito da `GetColor` (se non è nullo) è applicato **solo al contorno**. Ogni elemento riceve come proprietà i campi elencati in `Proprietà`.

### Scenario: edifici del comune
- **Dato** lo strato `GIS_14_EDIFICI` e il filtro `BELFIORE='H501'`
- **Quando** si chiama `AddPolygons(Database, 'GIS_14_EDIFICI', 'C_VIA;INDIRIZZO', 'BELFIORE=''H501''', nil)`
- **Allora** la query è `... FROM GIS_14_EDIFICI JOIN GIS_14_EDIFICI_FEA ON ... WHERE ... AND (BELFIORE='H501')` e ogni parte esterna visibile diventa un poligono con origine `GIS_14_EDIFICI`

### Scenario: civici
- **Dato** lo strato `GIS_13_CIVICI` e nessun `GetColor`
- **Quando** si chiama `AddMarkers(Database, 'GIS_13_CIVICI', ...)`
- **Allora** i marcatori sono blu, uno per civico, sul primo punto della geometria

## ZBASE-MAP-009 Zoom sugli elementi
`ZoomToMarkers`, `ZoomToPolygons`, `ZoomToCircles`, `ZoomToRectangles` e `ZoomToPolylines` zoomano solo se ci sono **almeno due** elementi del tipo: l'area è quella che li contiene tutti, allargata di 0,005 gradi su ogni lato. Con zero o un elemento non fanno niente (la mappa non si sposta su un elemento solo). Le procedure di aggiunta da dataset e da strato le richiamano da sole al termine.

### Scenario: un solo marcatore
- **Dato** una mappa con un solo marcatore
- **Quando** si chiama `ZoomToMarkers`
- **Allora** centro e zoom restano quelli di prima

## ZBASE-MAP-010 Colori dei marcatori
`IconUrl(Colore)` restituisce l'indirizzo dell'immagine del segnaposto: stringa vuota per `icNone`, un indirizzo diverso e non vuoto per ciascuno di `icBlue`, `icGreen`, `icRed`, `icPurple`. Le immagini sono servite da `mt.google.com` e `mt.googleapis.com` con `http` (DIV-MAP-6); con `icNone` la mappa usa il segnaposto predefinito del componente.

### Scenario: nessun colore
- **Dato** il colore `icNone`
- **Quando** si chiama `IconUrl`
- **Allora** il risultato è la stringa vuota

### Scenario: colori diversi
- **Dato** i quattro colori non nulli
- **Quando** si chiama `IconUrl` per ciascuno
- **Allora** i quattro indirizzi sono non vuoti e tutti diversi fra loro

## ZBASE-MAP-011 Configurazione per mappa
Ogni mappa è identificata da `MapId`; se vuoto vale `NomeClasseDelProprietario.NomeDelFrame` (`GetMapId`). Con la base di configurazione disponibile (`Base` assegnata), `LoadFromBase` cerca nel dizionario la configurazione con quella chiave: se è nuova la scrive con i valori correnti, altrimenti applica servizio di geocodifica, servizio di mappe, intervallo e zoom salvati e carica la descrizione. La personalizzazione e la configurazione delle azioni della barra sono riservate agli amministratori (`Base.IsAdmin`); il menu contestuale si apre solo per loro.

### Scenario: mappa con identificatore esplicito
- **Dato** un frame con `MapId` = `MappaComuni`
- **Quando** si chiama `GetMapId`
- **Allora** il risultato è `MappaComuni`

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-MAP-1 🟡 | `GotoAddress` e `GotoAddressSync` dichiarano `ZoomLevel` (predefinito 15) ma nel corpo non lo usano mai | Il livello richiesto da `frmQta_RFID` (20) è ignorato: la mappa mantiene lo zoom che aveva |
| DIV-MAP-2 🟡 (dedotta) | Nella procedura anonima di `GotoAddress` non c'è nessun controllo su `GeocodingResult.Result`: se l'indirizzo non è trovato le coordinate valgono 0 e 0 e la mappa viene centrata lì, con un marcatore (se il colore non è `icNone`) e poi viene richiamato `Callback`. `GotoAddressSync` invece controlla | Un indirizzo non risolto porta la mappa nel golfo di Guinea con un marcatore, invece di non fare niente; riguarda `frmQta_RFID`, `frmComuni` e `frmIntestatari`, che passano un colore |
| DIV-MAP-3 🟡 | I metodi `Clear...` con nome di origine vuoto tolgono tutto, e `AddMarkers(DataSet, ...)` passa `DataSet.Name` come origine: un dataset senza nome toglie tutti i marcatori della mappa, anche quelli di altre sorgenti, e aggiunge i nuovi senza origine | Più sorgenti sulla stessa mappa si cancellano a vicenda se anche una sola ha il nome vuoto. Non risulta un caso reale, ma non è stato controllato dataset per dataset |
| DIV-MAP-4 🟡 (dedotta) | `ClearStringListCache` libera le proprietà di **tutti** gli elementi, ma `AddMarkers` e `AddPolygons` (con `ClearCache` predefinito vero) tolgono dalla mappa solo quelli della propria origine | Gli elementi di un'altra origine ancora sulla mappa restano con `DataObject` che punta a una lista già liberata: al clic `dmMaps` fa `Marker.DataObject is TStrings`, con una violazione d'accesso. Succede se una mappa ha due strati o due dataset caricati uno dopo l'altro con il valore predefinito |
| DIV-MAP-5 🟡 (dedotta) | `AddMarkers(DataSet, ...)` fa `First` e scorre fino a fine file senza `DisableControls` né segnalibro, e non controlla che le coordinate non siano nulle (`AsFloat` di un `NULL` vale 0) | I controlli collegati al dataset si ridisegnano a ogni riga e il record corrente dell'utente è perso (resta a fine file); un record senza coordinate mette un marcatore in 0, 0 e `ZoomToMarkers` allarga la mappa a tutto il mondo. I chiamanti attuali passano quasi sempre `FillMarker`, che aggira il secondo problema |
| DIV-MAP-6 🟢 | Gli indirizzi dei segnaposto sono `http` e di due forme diverse: `icBlue` e `icGreen` usano `icon?...&name=...`, `icRed` e `icPurple` usano `icon/name=...` (con la barra al posto del punto interrogativo) | Una pagina servita in `https` blocca il contenuto misto; le immagini del servizio esterno non sono state verificate (nessuna prova di rete da qui) |
| DIV-MAP-7 🟢 | Codice di servizio trascurato: `Geocode` ha il parametro `Service` che non usa; `AddMarkers(Database, ...)` chiude con `LeaveMethod(Self, 'AddPolygons')` dopo `EnterMethod(Self, 'AddMarkers')`; `TimerTimer` esce con `exit` senza `LeaveMethod`; `TzMapType` è inutilizzato; `GotoAddress` ha una variabile `start` mai usata | Il registro di SmartInspect mostra metodi che non si chiudono o con il nome sbagliato; il resto è rumore |
| DIV-MAP-8 🟢 (dedotta) | `GetProperties` salta i nomi vuoti e usa `AsString`; `GetGisLayerProperties` non li salta (`A;;B` dà anche `=`) e usa `VarToStr(Field.Value)`. Nessuna delle due toglie gli spazi dai nomi | Lo stesso elenco di proprietà può dare righe diverse nei due percorsi; un nome scritto con uno spazio dopo il separatore (`ID; NOME`) non trova il campo e dà un valore vuoto |
| DIV-MAP-9 🟡 (dedotta) | `SetGoogleAPI` non raggiunge le mappe già create (la chiave si legge solo in `LoadAPI`, chiamato dal costruttore), e `GetMapId` nel costruttore (da `LoadFromBase`) vede un `Name` ancora vuoto, perché il nome del frame è assegnato dopo la creazione: la chiave di configurazione diventa `Proprietario.` senza il nome. Se il proprietario è `nil` (`TzMap.Create(nil)`) `Owner.ClassName` dà una violazione d'accesso | Una form con due mappe (`frmComuni`: `mapStradario` e `mapZone`) condividerebbe all'inizio la stessa configurazione fino alla prima personalizzazione, che ricarica con il nome giusto. La prima parte (chiave) conta solo se `SetGoogleAPI` viene chiamata dopo la creazione di una form con mappe: oggi è chiamata all'avvio. Da verificare con il collaudo |
| DIV-MAP-10 🟢 | `Filtro` e `Strato` degli strati GIS sono concatenati nella query senza protezione (`Filtro` è per scelta SQL scritto dal chiamante; `Strato` entra come nome di tabella). In `dmMaps` il filtro è `'BELFIORE=''' + BelfioreDiLavoro + ''''` | Nessun rischio con i valori di oggi (Belfiore preso dalla configurazione), ma il metodo non è adatto a testo digitato da un utente |
| DIV-MAP-11 🟢 (dedotta) | `dmMaps` (riga 132), nell'ultimo ramo, legge `AEventData.PolyElement.DataObject` anche quando il clic è su un marcatore (`PolyElement` è `nil`) | Il clic su un marcatore che non è un civico (o senza proprietà) dà una violazione d'accesso. È un difetto del chiamante, non della mappa: si annota qui perché dipende da `DataObject` |

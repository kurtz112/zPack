---
area: Collezione LZ
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/003
---

# Collezione LZ

Questa specifica descrive la collezione degli oggetti del dizionario LZ così come vive in memoria e su disco: la classe base `TzCustomCollection`, la collezione tipizzata `TzCollection<T>` con i suoi elementi `TzCollectionItem` (chiave per nome, ricerca, ordinamento, legame master/dettaglio), il formato di persistenza DFM testuale e JSON, e l'archivio `.lz` (uno zip con un membro per collezione) gestito da `TZipper`. Il codice è in `zBase\zCollection.pas` e `zBase\zCollection.Json.pas`. Lo usano WT e Gesty attraverso `TzSystem.LoadZip` e `TzSystem.SaveZip` (`zSystem.pas`), che caricano e salvano le 21 collezioni del dizionario; il server `zlz` (`zToolsAI\MCP\zMCP_LZ`) carica gli stessi archivi con le stesse classi e usa `TzCollectionJson.ItemToJson` per mostrare le voci; `zSystem.Export` esporta l'LZ in JSON e JSON Schema. La unit `zLz.JsonExport.pas` fa la stessa esportazione di `zSystem.Export` ma non è usata da nessun progetto (nessun `uses` in `D:\AI\SRC`): non si specifica. Le chiavi LZ sono i nomi degli elementi (AGENTS.md sezione 4, punti 9-10): tutto quello che segue sulla ricerca per nome vale anche per i riferimenti fra collezioni.

**Come funziona.** Ogni collezione ha un nome di classe (`TzDataSets`, `TzDataModules`, `TzDbViews`, ...) che è anche il nome del suo membro nell'archivio: `TzDataSets.dfm` o `TzDataSets.json`. Il formato in scrittura lo decide una sola variabile globale, `zCollectionPersistence`, impostata (se serve) all'avvio; in lettura il formato si riconosce dai primi byte. Il JSON si scrive e si legge via RTTI sulle proprietà published, in flusso continuo, con le stesse regole di omissione dei valori predefiniti del DFM, così i due formati hanno lo stesso contenuto. In WT e Gesty nessuno modifica `zCollectionPersistence`: in produzione l'archivio è solo DFM.

**Test che coprono quest'area.** Nessuna prova diretta. `Test.zSystem.Componenti` (classe `TTestRecordViewRows`, prova `Json_RoundTrip`) prova indirettamente il giro `AsJSON` → `AsJSON` su `TzRecordViewRows`: categorie, campi, proprietà booleane e intere, elenco di stringhe `Members`. Restano senza prova il DFM, `TZipper`, il riconoscimento del formato, gli errori di lettura, `ItemToJson`/`MergeIntoItem` e lo schema.

## ZBASE-COL-001 Elementi con nome e ricerca per nome
Ogni elemento è un `TzCollectionItem` con la proprietà published `Name`. La ricerca `IndexOf(Name)` scorre la collezione e confronta i nomi **senza distinguere maiuscole e minuscole** (`AnsiCompareText`); un nome vuoto non si trova mai (-1). `Exists(Name)` è `IndexOf >= 0`. `Get(Name, CanAppend)` restituisce l'elemento; se non c'è e `CanAppend` è vero (valore predefinito) ne aggiunge uno nuovo con quel nome e lo marca `IsNew`; con nome vuoto restituisce `nil` senza aggiungere. `Get(Name, StartPos)` cerca a partire dalla posizione indicata e non aggiunge mai. `Find(func)` restituisce il primo elemento per cui la funzione è vera, altrimenti `nil`.

### Scenario: ricerca senza distinzione di maiuscole
- **Dato** una collezione con l'elemento `Anagrafica.Persone`
- **Quando** si chiama `IndexOf('ANAGRAFICA.PERSONE')`
- **Allora** il risultato è la posizione dell'elemento

### Scenario: Get che aggiunge
- **Dato** una collezione senza l'elemento `NUOVO`
- **Quando** si chiama `Get('NUOVO')`
- **Allora** viene aggiunto un elemento con `Name = 'NUOVO'` e `IsNew = True`
- **E** `Get('')` restituisce `nil` senza aggiungere niente

## ZBASE-COL-002 Indicatore IsNew
`IsNew` è vero solo per un elemento creato da `Get` con `CanAppend`. Torna falso quando la collezione viene salvata (`CollectionSaved` chiama `ItemSaved` su ogni elemento) o quando l'elemento viene caricato (`ItemLoaded`). `Assign` fra due elementi della stessa classe copia `Name` e `IsNew`.

### Scenario: salvataggio
- **Dato** un elemento appena creato da `Get`
- **Quando** la collezione viene salvata con `SaveToStream` o con `TZipper.SaveCollection`
- **Allora** `IsNew` è falso

## ZBASE-COL-003 Indice per nome facoltativo (`IndexEnabled`)
Con `IndexEnabled := True` la collezione costruisce un dizionario nome → posizione (`Reindex`); a parità di nome vale il primo elemento. Finché l'indice è attivo `IndexOf` cerca solo nel dizionario: il confronto **distingue** maiuscole e minuscole e i parametri `StartPos`, `ExcludeIndex` e `UseStartingWith` non hanno effetto. L'indice non si aggiorna da solo quando si aggiunge, rinomina o elimina un elemento: va ricostruito con `Reindex` o spegnendo e riaccendendo `IndexEnabled`. `IndexEnabled := False` svuota il dizionario. Oggi lo usa solo `zSystem_Init`, attorno al riallineamento di `zDataDictionary` dai metadati (vedi DIV-COL-2). `TzDomains` ha un proprio indice interno, insensibile alle maiuscole, che usa solo quando `IndexEnabled` è falso.

### Scenario: indice attivo
- **Dato** una collezione con `IndexEnabled = True` e l'elemento `CLIENTI`
- **Quando** si chiama `IndexOf('clienti')`
- **Allora** il risultato è -1

## ZBASE-COL-004 Ordinamento
Il costruttore riceve `aSorted` (vero se non indicato). Con `Sorted` vero la collezione si riordina per nome con `AnsiCompareStr` (che **distingue** le maiuscole) a ogni notifica di cambiamento della collezione (`Update`), quindi a ogni aggiunta, eliminazione o `EndUpdate`; dentro `BeginUpdate`/`EndUpdate` si riordina una volta sola alla fine. Assegnare il nome a un elemento non è una notifica: un elemento aggiunto e poi nominato resta dove l'ha messo l'aggiunta finché non arriva il cambiamento successivo (DIV-COL-4). Le collezioni annidate dei metadati (`TzmdTable.Fields`, `PrimaryKey`, ...) e le collezioni di `TzMetadata` sono create non ordinate e conservano l'ordine di lettura.

### Scenario: caricamento in una collezione ordinata
- **Dato** un archivio con gli elementi `B`, `A`, `C` in quest'ordine
- **Quando** la collezione ordinata viene caricata
- **Allora** gli elementi sono `A`, `B`, `C`

## ZBASE-COL-005 Nomi duplicati
La collezione ammette due elementi con lo stesso nome: la proprietà `NameDuplicates` (predefinita `ndAllow`) non ha effetto, perché il controllo in `ValidateName` è commentato (DIV-COL-3). `GetDuplicates` elenca un nome per riga, con il numero fra parentesi se compare più di due volte (`ANAGRAFICA (3)`); `DropDuplicates` tiene il primo elemento di ogni nome ed elimina gli altri. Entrambe confrontano i nomi distinguendo le maiuscole (DIV-COL-5). La ricerca per nome (ZBASE-COL-001) restituisce sempre il primo.

### Scenario: duplicati
- **Dato** tre elementi `X` e due elementi `Y`
- **Quando** si chiama `GetDuplicates`
- **Allora** il risultato contiene le righe `X (3)` e `Y`
- **E** dopo `DropDuplicates` resta un solo `X` e un solo `Y`, quelli in posizione più bassa

## ZBASE-COL-006 Master e dettaglio
Una collezione può avere un elemento `Master`: assegnarlo la toglie dall'elenco `Details` del master precedente e la aggiunge a quello del nuovo. Distruggere la collezione la toglie dall'elenco del master; distruggere l'elemento master azzera il `Master` delle sue collezioni dettaglio senza distruggerle. `RemoveFromCollection` elimina l'elemento passando da `Collection.Delete`, quindi con le notifiche della collezione; un elemento senza collezione viene solo liberato.

### Scenario: rimozione di un elemento
- **Dato** un elemento in una collezione ordinata con `OnChange` assegnato
- **Quando** si chiama `RemoveFromCollection`
- **Allora** l'elemento è liberato e `OnChange` scatta

## ZBASE-COL-007 Formato di scrittura
Il formato lo decide solo `zCollectionPersistence` (`DefaultFormat`, `WriteDFM`, `WriteJSON`, `StrictJSON`), predefinito `(pfDFM, True, False, False)`; le funzioni pubbliche di caricamento e salvataggio non accettano un formato. Per un singolo flusso (`SaveToStream`, `AsText`, `TzMetadata.SaveToStream`) vale `zResolveWriteFormat`: se sono attivi entrambi i flag decide `DefaultFormat`; se ne è attivo uno vince quello; se nessuno, DFM. `AsDFM` e `AsJSON` scrivono sempre nel loro formato. Assegnare una stringa vuota ad `AsText`, `AsDFM` o `AsJSON` svuota la collezione; una stringa non vuota viene caricata riconoscendo il formato (ZBASE-COL-008), qualunque sia la proprietà usata.

### Scenario: entrambi i formati attivi
- **Dato** `zCollectionPersistence = (DefaultFormat: pfJSON; WriteDFM: True; WriteJSON: True)`
- **Quando** si chiama `SaveToStream`
- **Allora** il flusso contiene JSON

### Scenario: nessun formato attivo
- **Dato** `WriteDFM` e `WriteJSON` entrambi falsi
- **Quando** si chiama `SaveToStream`
- **Allora** il flusso contiene DFM

## ZBASE-COL-008 Riconoscimento del formato in lettura
`TzCollectionJson.DetectFormat` legge dall'inizio del flusso, salta il BOM UTF-8 (`EF BB BF`) e gli spazi (tabulazione, a capo, spazio) e guarda il primo carattere entro 64 byte: `[` o `{` → JSON; `o` (`object`), `i` (`item`, `inherited`), `T` (`TPF0`), `FF` o un byte da `00` a `08` → DFM; altro → sconosciuto. Il flusso torna alla posizione di partenza. `LoadFromStream` tratta come DFM tutto ciò che non è JSON. Un flusso nullo o vuoto non viene letto e la collezione resta com'era.

### Scenario: JSON con BOM
- **Dato** un flusso che comincia con `EF BB BF` seguito da `[`
- **Quando** si chiama `DetectFormat`
- **Allora** il risultato è `pfJSON`

### Scenario: flusso vuoto
- **Dato** una collezione con tre elementi e un flusso di dimensione zero
- **Quando** si chiama `LoadFromStream`
- **Allora** la collezione ha ancora tre elementi

## ZBASE-COL-009 La lettura sostituisce il contenuto
Caricare una collezione da un flusso non vuoto la svuota e la riempie con gli elementi letti, poi chiama `CollectionLoaded`. Gli errori di lettura dipendono dal formato:
- **DFM**: ogni errore passa da `OnLoadErrorCallback`. Il costruttore vi assegna un dialogo «Errore leggendo la collezione: <Name>» con i pulsanti Annulla, Ignora e Tutti: Ignora salta l'errore, Tutti salta anche i successivi della stessa lettura, Annulla lascia propagare l'eccezione. Senza gestore l'errore propaga. Un programma senza finestre (come `zlz`) deve sostituire il gestore;
- **JSON**: una proprietà sconosciuta o un valore di tipo inatteso viene scritto nel registro (`JSON <problema>`) e saltato; con `StrictJSON` vero solleva `EzJsonReadError` con il messaggio `<collezione>, item <indice> "<Name>": <problema>`. Gli errori di struttura (radice che non è un array, elemento che non è un oggetto, nome di proprietà mancante) sollevano sempre `EzJsonReadError`, con o senza `StrictJSON`.

### Scenario: proprietà sconosciuta nel JSON
- **Dato** un JSON con un elemento che contiene `"Generatr": ""` e `StrictJSON` falso
- **Quando** si carica la collezione
- **Allora** l'elemento viene caricato senza quella proprietà e il registro riporta `proprieta' "Generatr" sconosciuta per la classe ...`

### Scenario: lettura rigorosa
- **Dato** lo stesso JSON e `StrictJSON` vero
- **Quando** si carica la collezione
- **Allora** viene sollevata `EzJsonReadError` con il nome della collezione, l'indice e il nome dell'elemento

### Scenario: radice sbagliata
- **Dato** un JSON che comincia con `{` passato a una collezione
- **Quando** si carica
- **Allora** viene sollevata `EzJsonReadError` «<collezione>: atteso array JSON come radice della collection»

## ZBASE-COL-010 Regole di scrittura del JSON
Una collezione è un array di oggetti, uno per elemento; il testo è UTF-8 **senza BOM**, indentato a due spazi. Per ogni elemento si scrivono le proprietà published leggibili **e** scrivibili, `Name` per prima e le altre in ordine alfabetico. Si omettono, come fa il DFM: le proprietà `stored False`; gli ordinali uguali al valore della clausola `default` (senza clausola si scrivono sempre); stringhe vuote, numeri decimali e `Int64` a zero; `TStrings` e collezioni vuote; oggetti nulli; i `Variant` vuoti o nulli. Rappresentazioni: booleani come `true`/`false`; enumerati e insiemi col nome dei valori (un insieme oltre i 32 elementi diventa `null`); `TStrings` come array di righe; collezioni annidate come array di oggetti; oggetti annidati come oggetto; `TDateTime`, `TDate` e `TTime` come testo ISO 8601; `Variant` come testo. I valori che nel DFM passano da `DefineProperties` si scrivono e si leggono con gli agganci `WriteJsonExtraProperties`, `ReadJsonExtraProperty` e `DescribeJsonExtraProperties` dell'elemento.

### Scenario: valore predefinito omesso
- **Dato** un elemento con una proprietà booleana `default true` che vale vero e una stringa vuota
- **Quando** si scrive in JSON
- **Allora** nessuna delle due compare nell'oggetto

### Scenario: elenco di stringhe
- **Dato** un elemento con `SQL_Select` di due righe
- **Quando** si scrive in JSON
- **Allora** compare `"SQL_Select": ["riga 1", "riga 2"]`

## ZBASE-COL-011 Regole di lettura del JSON
I nomi delle proprietà si riconoscono senza distinguere maiuscole e minuscole e in qualunque ordine. Un `null` vale stringa vuota per le stringhe, zero per interi e `Int64`, e lascia invariati decimali, booleani, enumerati, insiemi e oggetti. Un numero o un booleano letto in una stringa viene convertito in testo. Un enumerato o un elemento di insieme con un nome che non esiste è un problema (ZBASE-COL-009) e il valore resta invariato. Le proprietà oggetto si leggono nell'istanza esistente, come fa il DFM: se l'istanza manca il valore viene saltato con un problema. Un elenco di stringhe e una collezione annidata letti **sostituiscono** il contenuto precedente; un oggetto annidato si fonde (si assegnano solo le chiavi presenti).

### Scenario: null su un intero
- **Dato** un elemento con `"Width": null`
- **Quando** si carica
- **Allora** `Width` vale 0

### Scenario: enumerato sconosciuto
- **Dato** `"Alignment": "taGiustificato"`
- **Quando** si carica
- **Allora** `Alignment` resta al valore che aveva e il problema `valore "taGiustificato" non previsto ...` viene segnalato

## ZBASE-COL-012 Componenti con collezioni (MetaData)
`SaveComponentToStream` scrive un oggetto con una chiave per ogni proprietà published del componente che è una `TzCustomCollection`, nell'ordine di dichiarazione, con l'array della collezione come valore. `LoadComponentFromStream` legge ogni chiave nella collezione omonima (nome senza distinzione di maiuscole), dentro `BeginUpdate`/`EndUpdate`; una chiave che non corrisponde a una collezione è un problema e viene saltata; le collezioni non nominate nel JSON restano come erano.

### Scenario: sezione assente
- **Dato** un componente con le collezioni `Domains` e `Tables` già piene e un JSON con la sola chiave `"Tables"`
- **Quando** si chiama `LoadComponentFromStream`
- **Allora** `Tables` contiene gli elementi del JSON e `Domains` è invariata

## ZBASE-COL-013 Fotografia e fusione di un elemento
`ItemToJson(Item, SkipDefaults)` restituisce l'elemento come oggetto JSON su una riga; con `SkipDefaults` falso scrive ogni proprietà, valori predefiniti compresi (fotografia completa usata da `zCollection.Patcher`). `MergeIntoItem(Item, Json, Options)` applica un oggetto JSON a un elemento esistente con le regole di ZBASE-COL-011: assegna solo le proprietà nominate, fonde gli oggetti annidati e sostituisce per intero elenchi di stringhe e collezioni annidate. Se il testo non comincia con un oggetto solleva `EzJsonReadError` «<Classe>: atteso un oggetto JSON». I messaggi dei problemi riportano la collezione, la posizione e il nome dell'elemento.

### Scenario: fusione parziale
- **Dato** un elemento con `Caption = 'Vecchio'` e `Width = 100`
- **Quando** si chiama `MergeIntoItem` con `{"Caption": "Nuovo"}`
- **Allora** `Caption` vale `Nuovo` e `Width` resta 100

## ZBASE-COL-014 Schema JSON
`WriteSchema` e `WriteComponentSchema` producono uno schema JSON draft-07 ricavato dalla RTTI: per ogni elemento un oggetto con `additionalProperties: false`, i tipi delle proprietà, gli enumerati con l'elenco dei nomi, i valori `default` delle clausole `default`, il formato `date-time` per le date. Le proprietà con `stored False` costante non compaiono. Il primo elemento della collezione, se c'è, fa da prototipo per conoscere la classe degli elementi delle collezioni annidate; senza prototipo una collezione annidata è descritta come array di oggetti generici. La discesa si ferma a profondità 8.

### Scenario: collezione vuota
- **Dato** una collezione vuota la cui classe ha una collezione annidata
- **Quando** si scrive lo schema
- **Allora** la collezione annidata è descritta come `{"type": "array", "items": {"type": "object"}}`

## ZBASE-COL-015 Archivio LZ (`TZipper`)
L'archivio è uno zip; ogni collezione è un membro `<ClassName>.dfm` o `<ClassName>.json`, oppure col nome passato al posto del nome di classe. In lettura (`LoadCollection`) si cerca prima l'estensione di `DefaultFormat`, poi l'altra, poi il nome senza estensione (vecchi archivi); se non c'è niente la collezione resta com'è. In scrittura (`SaveCollection`), per ciascuno dei due formati, si elimina il membro esistente e lo si riscrive solo se il suo flag è attivo: disattivare un formato fa sparire il suo membro al salvataggio successivo. Poi gli elementi perdono `IsNew`. **Una collezione vuota non viene salvata affatto**: il membro precedente resta nell'archivio (DIV-COL-1). `GetFileNames` elenca i membri `.dfm` e `.json` di una cartella dell'archivio, con o senza percorso. La password, se impostata, cifra i membri aggiunti dopo e serve a leggere quelli cifrati.

### Scenario: entrambi i membri presenti
- **Dato** un archivio con `TzDataSets.dfm` e `TzDataSets.json` e `DefaultFormat = pfJSON`
- **Quando** si chiama `LoadCollection` su `TzDataSets`
- **Allora** viene letto `TzDataSets.json`

### Scenario: passaggio a JSON
- **Dato** un archivio con `TzDataSets.dfm` e i flag `WriteDFM = False`, `WriteJSON = True`
- **Quando** si chiama `SaveCollection` su una collezione non vuota
- **Allora** l'archivio contiene `TzDataSets.json` e non più `TzDataSets.dfm`

## ZBASE-COL-016 Errori dell'archivio
Un errore di estrazione o di aggiunta di un membro (password mancante o sbagliata, membro corrotto) solleva un'eccezione «<Lettura|Scrittura|Elaborazione> di <membro> in <archivio> fallita: <dettaglio>» invece di restituire un flusso vuoto in silenzio. In `LoadCollection` un errore di estrazione mostra il messaggio (`ConfirmOk`) e poi si propaga al chiamante, mentre un errore nel contenuto del membro (durante `LoadFromStream`) viene mostrato con `ApplicationShowException` e non si propaga: la collezione resta caricata fino al punto dell'errore. In `SaveCollection` ogni errore mostra il messaggio e si propaga. Un archivio che non si apre fa mostrare «Impossibile aprire il file <nome>» e propaga l'eccezione.

### Scenario: membro cifrato senza password
- **Dato** un archivio con il membro `TzDataSets.dfm` cifrato e `Password` vuota
- **Quando** si chiama `LoadCollection`
- **Allora** compare il messaggio «Lettura di TzDataSets.dfm in <archivio> fallita: ...» e l'eccezione arriva al chiamante

## Divergenze note
Si decidono nella voce R-201 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-COL-1 🟡 (dedotta) | `TZipper.SaveCollection` esce subito se la collezione è vuota (commento «ZZ 23.02.2016 Tentativo di evitare la rottura dell'lz»): il membro vecchio non viene né cancellato né riscritto | Svuotare una collezione (per esempio eliminare l'unica voce, anche con una patch) non arriva mai all'archivio: al caricamento successivo gli elementi eliminati ricompaiono |
| DIV-COL-2 🟡 (dedotta) | Con `IndexEnabled` vero `IndexOf` distingue le maiuscole, ignora `StartPos`, `ExcludeIndex` e `UseStartingWith`, e l'indice non segue aggiunte, rinomine ed eliminazioni | Lo stesso `IndexOf` cambia contratto a seconda dello stato: con l'indice attivo un nome scritto in modo diverso non si trova, un elemento aggiunto non si trova e `Get` con `CanAppend` può creare un doppione. Oggi l'uso in `zSystem_Init` è innocuo perché i nomi arrivano già maiuscoli e una volta sola |
| DIV-COL-3 🟢 (dedotta) | `NameDuplicates` (`ndAutoRename`, `ndRaiseError`) è pubblica ma `ValidateName` è tutta commentata | Chi imposta `ndRaiseError` crede di essere protetto dai doppioni e non lo è |
| DIV-COL-4 🟢 (dedotta) | In una collezione ordinata l'elemento aggiunto viene ordinato quando ha ancora il nome vuoto (va in testa); il nome assegnato dopo non lo ricolloca | Dopo `Get` con `CanAppend` o un'aggiunta da patch l'elemento resta in prima posizione fino alla notifica successiva, e può essere salvato in quella posizione: differenze spurie nei file esplosi |
| DIV-COL-5 🟢 (dedotta) | `IndexOf` non distingue le maiuscole, mentre `GetDuplicates`, `DropDuplicates` e l'ordinamento (`AnsiCompareStr`) le distinguono | `Clienti` e `CLIENTI` sono lo stesso elemento per la ricerca ma non sono doppioni per `GetDuplicates`, che quindi non segnala il caso più insidioso |
| DIV-COL-6 🟢 (dedotta) | Il commento di `OnLoadError` dice che senza gestore l'errore propaga e che decide il chiamante, ma il costruttore assegna sempre il dialogo `DefaultCollectionLoadErrorEvent` | Un programma senza finestre che non sostituisce il gestore resta bloccato sul dialogo (lo ha dovuto fare a mano `zlz`) |
| DIV-COL-7 🟢 (dedotta) | `TZipper.FileExists` cerca solo il membro `.dfm` (`FullFileName` con formato predefinito DFM) | Con un archivio solo JSON risponde falso; oggi nessuno la chiama (l'unica chiamata in `zSystem.LoadZip` è commentata) |
| DIV-COL-8 🟢 (dedotta) | `TzComponentList<T>.ItemByName` non assegna il risultato quando il nome non c'è | Restituisce un riferimento casuale invece di `nil`; oggi non è usata |
| DIV-COL-9 🟢 (dedotta) | In lettura JSON una data non ISO 8601 o un testo in una proprietà `Char` sollevano un'eccezione di conversione, non `EzJsonReadError`, anche con `StrictJSON` falso | Un solo valore malformato interrompe il caricamento invece di essere segnalato e saltato come gli altri problemi |
| DIV-COL-10 🟢 (dedotta) | Un `Variant` si scrive sempre come testo (`VarToStr`) e si rilegge come testo | Un valore numerico o booleano cambia tipo dopo un giro DFM → JSON → memoria |

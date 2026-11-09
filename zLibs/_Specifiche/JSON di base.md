---
area: JSON di base
progetto: zLibs
aggiornato: 2026-11-02
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/007
---

# JSON di base

Questa specifica descrive `zLibs\zz.JSON.pas`: due «helper di classe» (estensioni di una classe esistente) per `TJSONObject` e `TJSONArray` di `System.JSON`. All'oggetto aggiungono scrittura con valori predefiniti omessi (`Add`, `AddDateTime`), lettura tipizzata che non solleva errori sulle chiavi assenti (`GetString`, `GetInt64`, `GetFloat`, `GetBoolean`, `GetDateTime`, `GetJsonObject`, `GetJsonArray`), le proprietà indicizzate per chiave (`S`, `I`, `F`, `B`, `D`, `O`, `A`), le letture «Try», `Exist`, `Replace` e `Parse(testo)`; all'array `Clear` e `Replace`. Non è `zz.JSON.DTO` (la classe base delle risposte e richieste dei servizi web in JSON), che ha la sua specifica in `DTO JSON.md` (`ZLIBS-DTO`).

La unit **non è usata da nessun progetto**: nessuna clausola `uses` in `D:\AI\SRC` la cita (le ricerche trovano solo `zz.JSON.DTO`, una unit diversa), non è elencata in nessun pacchetto (`.dpk`) e non c'è nei `.dpr`. Nella stessa cartella ci sono due unit sorelle incomplete (`zz.JSON da completare.pas` e `completare jsonHelper.pas`, quest'ultima con un altro `TJSONObjectHelper`): non si compilano e non sono oggetto di questa specifica. La specifica descrive quindi un codice di riserva, pronto all'uso ma oggi senza chiamanti; con un solo helper per classe in vista, chi la cita insieme a un'altra unit che definisce un helper per `TJSONObject` ne vedrebbe attivo uno solo.

**Come funziona.** Tutte le funzioni lavorano sull'oggetto o sull'array su cui si chiamano. In lettura la chiave si cerca per nome **esatto** (distingue maiuscole e minuscole) e si prende la prima coppia che corrisponde; il valore si converte nel tipo richiesto con le regole di `System.JSON` (un numero si legge come testo, un testo numerico come numero, `"true"` e i numeri come booleano). Una chiave assente dà il valore vuoto del tipo (testo vuoto, 0, `False`, `nil`, data zero). In scrittura, un valore uguale al valore predefinito del tipo **non viene scritto**, per tenere il JSON corto.

**Test che coprono quest'area.** `Test.zz.JSON` (in `zPack\_UnitTest\_src`, 57 prove, su oggetti creati in memoria): scrittura, lettura, proprietà, date, oggetti e array figli, letture «Try», `Parse`, `Replace` sull'oggetto e sull'array, `Clear` sull'array, e le correzioni di DIV-JSN-6, 8 e 9 (rilascio 007) e di DIV-JSN-4, 5 e 7 (rilascio 008). Le funzioni che sostituiscono un valore (proprietà S, I, F, B, D, O, A, Replace e Clear) ne liberano il vecchio; Replace sull'oggetto, con chiavi che differiscono solo per le maiuscole, lascia una sola coppia.

## ZLIBS-JSN-001 Scrittura con valori predefiniti omessi (`Add`)
`Add(Chiave, Valore)` aggiunge una coppia solo se il valore è **diverso dal valore predefinito**: testo diverso da `''`, intero diverso da 0, decimale diverso da 0, booleano diverso da `False`. Il quarto parametro facoltativo `DefaultValue` cambia il valore da omettere (`Add('stato', 'A', 'A')` non scrive; `Add('abilitato', False, True)` scrive `false`). I numeri si scrivono come numeri JSON (con il punto decimale), i booleani come `true` e `false`, i testi fra virgolette. `Add` **non sostituisce** una chiave già presente: aggiunge una seconda coppia con lo stesso nome (la lettura trova la prima). Per sostituire servono le proprietà (ZLIBS-JSN-004) o `Replace` (ZLIBS-JSN-009).

### Scenario: testo e intero
- **Dato** un oggetto vuoto
- **Quando** si chiama `Add('nome', 'Rossi')`, `Add('quantita', 5)` e `Add('resto', 0)`
- **Allora** il JSON è `{"nome":"Rossi","quantita":5}`

### Scenario: valore predefinito personalizzato
- **Dato** un oggetto vuoto
- **Quando** si chiama `Add('stato', 'A', 'A')` e poi `Add('stato', 'B', 'A')`
- **Allora** solo la seconda scrive: `{"stato":"B"}`

### Scenario: chiave ripetuta
- **Dato** un oggetto vuoto
- **Quando** si chiama due volte `Add('chiave', ...)` con valori `a` e `b`
- **Allora** ci sono due coppie con la stessa chiave e `S['chiave']` restituisce `a`

## ZLIBS-JSN-002 Lettura tipizzata
`GetString`, `GetInt64`, `GetFloat`, `GetBoolean`, `GetDateTime` restituiscono il valore convertito oppure, se la chiave **non c'è**, il valore vuoto del tipo (testo vuoto, 0, 0, `False`, data zero); `GetJsonObject` e `GetJsonArray` restituiscono l'oggetto o l'array, oppure `nil` se la chiave manca **o se il valore è di un altro tipo** (un oggetto letto come array, un testo letto come oggetto). Le conversioni compatibili funzionano: il numero 5 letto come testo dà `5`, il testo `"7"` letto come intero dà 7, `"true"` e il numero 1 come booleano dànno vero, il numero 0 dà falso. Un valore `null` esplicito è una chiave presente: letto come testo dà `''`. Un valore **non convertibile** (il testo `abc` letto come intero) solleva `EJSONException`: è l'errore della libreria di base, non è gestito.

### Scenario: chiave assente
- **Dato** un oggetto senza la chiave `x`
- **Quando** si leggono `GetString('x')`, `GetInt64('x')`, `GetBoolean('x')`, `GetJsonObject('x')`
- **Allora** i risultati sono `''`, 0, `False` e `nil`

### Scenario: conversioni compatibili
- **Dato** un oggetto `{"n":5,"t":"7","v":"true","u":1,"z":0}`
- **Quando** si leggono `S['n']`, `I['t']`, `B['v']`, `B['u']`, `B['z']`
- **Allora** i risultati sono `5`, 7, vero, vero, falso

### Scenario: valore non convertibile
- **Dato** un oggetto `{"k":"abc"}`
- **Quando** si legge `GetInt64('k')`
- **Allora** viene sollevata `EJSONException`

## ZLIBS-JSN-003 Presenza di una chiave (`Exist`)
`Exist(Chiave)` è vero se esiste una coppia con quel nome **esatto** (`A` non è `a`), anche se il suo valore è `null`.

### Scenario: nome e maiuscole
- **Dato** un oggetto `{"a":"x"}`
- **Quando** si chiama `Exist('a')`, `Exist('b')` e `Exist('A')`
- **Allora** i risultati sono vero, falso, falso

## ZLIBS-JSN-004 Proprietà indicizzate (`S`, `I`, `F`, `B`)
`Oggetto.S['chiave'] := valore` (e `I` per `Int64`, `F` per `Double`, `B` per `Boolean`) **sostituisce** la coppia: toglie quella esistente e scrive la nuova **in fondo all'oggetto**, quindi riassegnare una chiave la sposta in coda (`{"a":"1","b":"2"}` dopo `S['a'] := '3'` diventa `{"b":"2","a":"3"}`). Se il valore è uguale al predefinito (testo vuoto, 0, `False`) la coppia esistente viene tolta e **nessuna ne viene scritta**: la chiave sparisce e `Exist` diventa falso, ma la lettura dà comunque il valore vuoto (DIV-JSN-3). `I` conserva anche i valori oltre i 32 bit.

### Scenario: sostituzione
- **Dato** un oggetto con `S['a'] := 'x'`
- **Quando** si assegna `S['a'] := 'y'`
- **Allora** c'è una sola coppia: `{"a":"y"}`

### Scenario: valore predefinito
- **Dato** un oggetto con `S['a'] := 'x'`
- **Quando** si assegna `S['a'] := ''`
- **Allora** `Exist('a')` è falso e `S['a']` dà `''`

### Scenario: intero grande
- **Dato** un oggetto
- **Quando** si assegna `I['grande'] := 5000000000`
- **Allora** il JSON è `{"grande":5000000000}` e la lettura dà lo stesso valore

## ZLIBS-JSN-005 Date
`AddDateTime(Chiave, Valore)` scrive la data come testo `aaaa-mm-gg hh:nn:ss` (con uno **spazio** fra data e ora, senza millisecondi, sempre con i due punti); la proprietà `D` scrive invece il numero della data (come `Double`); una data uguale a 0 non si scrive. In lettura (`GetDateTime`, `D`, `TryGetDateTime`) un testo in formato ISO 8601 con la `T` (`2026-11-01T10:30:15`) o la sola data (`2026-11-01`, mezzanotte) è accettato, e una chiave assente dà 0. Sono accettati anche il testo con lo spazio (quello scritto da `AddDateTime`, letto come ora locale così com'è scritta) e il numero scritto da `D`: ciò che la unit scrive si rilegge sempre.

### Scenario: scrittura
- **Dato** le 10:30:15 del primo novembre 2026
- **Quando** si chiama `AddDateTime('quando', Valore)`
- **Allora** il JSON è `{"quando":"2026-11-01 10:30:15"}`

### Scenario: lettura di una data ISO
- **Dato** un oggetto `{"d":"2026-11-01T10:30:15"}`
- **Quando** si legge `D['d']`
- **Allora** il valore è lo stesso istante

### Scenario: riletture del proprio testo
- **Dato** un oggetto con `D['quando']` scritta con la proprietà
- **Quando** si rilegge `D['quando']`
- **Allora** viene sollevata `EJSONException` (oggi)

## ZLIBS-JSN-006 Oggetti e array figli (`AddObject`, `AddArray`, `O`, `A`)
`AddObject(Chiave)` e `AddArray(Chiave)` creano un oggetto o un array vuoto, lo agganciano all'oggetto e lo restituiscono: il padre ne ha la proprietà e li libera con sé. `O['chiave'] := Figlio` e `A['chiave'] := Array` sostituiscono la coppia (stesse regole di ZLIBS-JSN-004) e anch'essi passano la proprietà al padre: l'oggetto assegnato non va liberato a parte. `O['chiave'] := nil` scrive `null`: la chiave esiste (`Exist` vero) ma `O['chiave']` restituisce `nil`.

### Scenario: figlio
- **Dato** un oggetto vuoto
- **Quando** si chiama `AddObject('cliente')` e si scrive `Add('nome', 'Rossi')` nel figlio
- **Allora** il JSON è `{"cliente":{"nome":"Rossi"}}` e `GetJsonObject('cliente')` restituisce lo stesso figlio

### Scenario: figlio nullo
- **Dato** un oggetto vuoto
- **Quando** si assegna `O['cliente'] := nil`
- **Allora** il JSON è `{"cliente":null}`, `Exist('cliente')` è vero e `O['cliente']` è `nil`

## ZLIBS-JSN-007 Letture «Try»
`TryGetString`, `TryGetInt` (per `Integer`, `Int64` e `Cardinal`), `TryGetFloat` (per `Double` e `Single`), `TryGetBoolean` e `TryGetDateTime` restituiscono vero e scrivono il valore nel parametro se la chiave c'è; restituiscono falso e **lasciano il parametro com'era** se manca. Un valore `null` esplicito conta come presente: `TryGetString` dà vero e `''`. Se la chiave c'è ma il valore non è convertibile (testo `abc` letto come intero), la funzione restituisce falso e lascia il parametro com'era, senza sollevare errori.

### Scenario: chiave assente
- **Dato** un oggetto senza la chiave `x` e parametri con valori già assegnati
- **Quando** si chiamano le letture «Try» su `x`
- **Allora** tutte restituiscono falso e i parametri non cambiano

### Scenario: tre tipi interi
- **Dato** un oggetto `{"i":42,"g":5000000000,"c":4000000000}`
- **Quando** si leggono `i` in un `Integer`, `g` in un `Int64`, `c` in un `Cardinal`
- **Allora** tutte restituiscono vero con i valori scritti

## ZLIBS-JSN-008 Lettura da testo (`Parse`)
`Oggetto.Parse(Testo)` analizza un testo JSON che descrive un **oggetto** e ne aggiunge le coppie all'oggetto, **senza svuotarlo**: le coppie già presenti restano. Se il testo non è un oggetto (per esempio vuoto o `questo non è JSON`) non succede niente e non viene segnalato nessun errore: l'esito dell'analisi (negativo in caso di errore) viene ignorato (DIV-JSN-2). Gli oggetti e gli array annidati diventano `TJSONObject` e `TJSONArray` figli. Il testo viene convertito in byte con la codifica predefinita di Windows, non con UTF-8 (DIV-JSN-1): il testo con soli caratteri ASCII funziona sempre.

### Scenario: oggetto valido
- **Dato** un oggetto vuoto
- **Quando** si chiama `Parse('{"a":"1","b":2}')`
- **Allora** l'oggetto ha due coppie e `S['a']` è `1`, `I['b']` è 2

### Scenario: oggetto già pieno
- **Dato** un oggetto con la coppia `prima`
- **Quando** si chiama `Parse('{"a":"1"}')`
- **Allora** l'oggetto ha due coppie: `prima` e `a`

### Scenario: testo che non è JSON
- **Dato** un oggetto vuoto
- **Quando** si chiama `Parse('questo non è JSON')`
- **Allora** non viene sollevata nessuna eccezione e l'oggetto resta vuoto

## ZLIBS-JSN-009 Sostituzione di una coppia (`Replace` sull'oggetto)
`Oggetto.Replace(Chiave, Valore)` sostituisce il valore della coppia che ha quella chiave **nella stessa posizione** (`{"a":"1","b":"2","c":"3"}` dopo `Replace('b', 'X')` dà `{"a":"1","b":"X","c":"3"}`); se la chiave non c'è accoda una coppia nuova; su un oggetto vuoto la aggiunge e restituisce l'oggetto stesso. Il confronto delle chiavi **ignora maiuscole e minuscole**, a differenza di ogni altra funzione della unit, e la coppia sostituita prende il nome scritto in `Replace` (`Replace('NOME', ...)` su `nome` dà una coppia `NOME`). L'oggetto prende la proprietà del valore passato. Il valore di ritorno è sempre l'oggetto stesso, anche quando non è vuoto.

### Scenario: stessa posizione
- **Dato** un oggetto `{"a":"1","b":"2","c":"3"}`
- **Quando** si chiama `Replace('b', ...)` con il testo `X`
- **Allora** il JSON è `{"a":"1","b":"X","c":"3"}`

### Scenario: maiuscole diverse
- **Dato** un oggetto `{"nome":"x","altro":"y"}`
- **Quando** si chiama `Replace('NOME', ...)` con il testo `Z`
- **Allora** il JSON è `{"NOME":"Z","altro":"y"}`

## ZLIBS-JSN-010 Array: `Clear` e `Replace`
`Array.Clear` toglie tutti gli elementi (l'array resta vuoto, anche se lo era già). `Array.Replace(Indice, Valore)` sostituisce l'elemento in posizione `Indice` (da 0 al numero di elementi) e restituisce l'array stesso; con l'indice uguale al numero di elementi **accoda** il valore. Un indice negativo o oltre il numero di elementi è un errore di programmazione (c'è un `Assert`, che nelle build senza controlli non protegge). L'array prende la proprietà del valore passato.

### Scenario: indice centrale
- **Dato** un array `[1,2,3]`
- **Quando** si chiama `Replace(1, ...)` con il numero 9
- **Allora** il JSON è `[1,9,3]` e il risultato è l'array stesso

### Scenario: indice uguale al conteggio
- **Dato** un array `[1,2,3]`
- **Quando** si chiama `Replace(3, ...)` con il numero 4
- **Allora** il JSON è `[1,2,3,4]`

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. Quelle marcate «dedotta» vengono dalla lettura del codice e del sorgente della libreria `System.JSON` di Delphi (`D:\AI\SandBox\__LIB\Delphi\source\rtl\common`), senza prova eseguita; DIV-JSN-6 e 8 hanno una prova che le fotografa.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-JSN-1 🟡 (dedotta) | `Parse(testo)` converte il testo in byte con `TEncoding.Default` (la pagina di codice di Windows) ma l'analizzatore di `TJSONObject` legge i byte come UTF-8 | Un testo con lettere accentate o altri caratteri fuori dall'ASCII viene letto male (caratteri sostitutivi o errore) |
| DIV-JSN-2 🟡 | `Parse` ignora l'esito dell'analisi (un numero negativo in caso di errore) | Un JSON non valido, o non un oggetto, non dà errore: l'oggetto resta vuoto o con le coppie lette fino al punto dell'errore, e il chiamante crede di aver letto tutto |
| DIV-JSN-3 🟢 | Le proprietà `S`, `I`, `F`, `B`, `D` con il valore predefinito (testo vuoto, 0, `False`) tolgono la chiave invece di scriverla | Un JSON destinato a un servizio che si aspetta la chiave con valore 0 o `false` non la contiene; `Exist` non distingue «mai scritta» da «scritta a zero» |
| DIV-JSN-10 🟢 | La unit non è usata da nessun progetto e ha due sorelle incomplete nella stessa cartella | È codice senza chiamanti e senza prove di funzionamento reale: le correzioni sopra non toccano nessun programma, ma chi la adottasse in un progetto nuovo erediterebbe questi difetti |

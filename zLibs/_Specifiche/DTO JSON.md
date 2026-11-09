---
area: DTO JSON
progetto: zLibs
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# DTO JSON

Questa specifica descrive `zLibs\zz.JSON.DTO.pas`: la classe base `TJsonDTO` con cui WT e Gesty rappresentano le risposte e le richieste dei servizi web in JSON, la classe di appoggio `TArrayMapper` (liste costruite da array) e i due attributi `GenericListReflect` e `SuppressZero`. Una classe DTO deriva da `TJsonDTO`, dichiara i **campi** privati con gli attributi di `REST.Json.Types` (`JSONName`, `JSONMarshalled`) e si legge o si scrive con la sola proprietà `AsJson`.

Chi la usa (verificato con una ricerca in `D:\AI\SRC`):

| Progetto | Unit | Uso |
|---|---|---|
| WT | `API\OpenApi\OpenApi.Geocode`, `.VerificaCF`, `.EuropeanVat`, `.Imprese.Base`, `.Imprese.Advance`, `.Imprese.Advance.Ricerca`, `.Imprese.Autocomplete`, `.Imprese.FormeGiuridiche`; `dmOpenApi.http` | Una istanza per risposta: `OpenApi_Xxx := TOpenApi_Xxx.Create; OpenApi_Xxx.AsJson := JSON` (lettura) |
| Gesty | `API\eSignAnyWhere\eSignAnyWhere.classes.Envelope`, `.EnvelopeFiles`, `.EnvelopeResponse`, `.FindRequest`, `.Prepare`, `.PrepareResponse`; `eSignAnyWhere` | Lettura delle risposte (`Result.AsJson := RESTResponse.Content`) e scrittura del corpo delle richieste (`Envelope.AsJson`, passato al registro `__JSONLog` e inviato) |
| Altri | `GeCo\sorgenti_wt_server\ANPR\ANPR.*`; `zServer\_src\Products\Gesty\Firma\zz.JSON.DTO.pas` (copia identica a quella di zLibs, controllata con un confronto del testo) | stesso schema |

La unit non è in nessun pacchetto `.dpk`. Esiste un'altra variante in `Gesty_Group\_Sorgenti\API\OpenApi\Pkg.Json.DTO.pas` (stessa classe `TJsonDTO`, unit diversa): non è oggetto di questa specifica.

**Come funziona.** In lettura `AsJson := testo` analizza il testo con `TJSONObject.ParseJSONValue` e copia i valori nei campi con `TJson.JsonToObject`, con le opzioni `joDateIsUTC` e `joDateFormatISO8601`. In scrittura `AsJson` costruisce il JSON con `TJson.ObjectToJsonString` (stesse opzioni) e lo rimpagina con `PrettyPrintJSON`. Le liste (`TList<T>`, `TObjectList<T>`) non sono gestite da `REST.Json`: la DTO tiene un **array** con il nome JSON e una **lista** per l'uso nel codice, e `TArrayMapper` li tiene allineati (ZLIBS-DTO-007). Le DTO che hanno liste ridefiniscono `GetAsJson` per chiamare `RefreshArray` prima di quella della base.

**Test che coprono quest'area.** `Test.zz.JSON.DTO` (in `zPack\_UnitTest\_src`): classi di prova locali che imitano gli schemi dei chiamanti (campi semplici, data, lista di numeri come `TGps`, lista di oggetti con `GenericListReflect` come `TOpenApi_Imprese_Autocomplete`).

## ZLIBS-DTO-001 Scrittura in JSON
`AsJson` (lettura della proprietà) restituisce un oggetto JSON con un membro per ogni campo della classe. Il nome del membro è quello dell'attributo `JSONName`; i campi con `JSONMarshalled(False)` non compaiono. Stringhe, numeri interi e decimali e booleani hanno il tipo JSON corrispondente. Il testo è già rimpaginato (ZLIBS-DTO-004). `ToString` restituisce lo stesso testo di `AsJson`.

### Scenario: campi semplici
- **Dato** una DTO con `nome` = `Rossi`, `quantita` = 3, `importo` = 12,5 e `attivo` = vero
- **Quando** si legge `AsJson`
- **Allora** il testo è un oggetto JSON in cui `nome` è la stringa `Rossi`, `quantita` il numero 3, `importo` il numero 12,5 e `attivo` il booleano vero

### Scenario: ToString
- **Dato** una DTO con valori assegnati
- **Quando** si chiama `ToString`
- **Allora** il risultato è uguale a `AsJson`

## ZLIBS-DTO-002 Lettura da JSON
`AsJson := testo` con un oggetto JSON valido assegna ai campi i valori dei membri con lo stesso nome (`JSONName`). I valori letti sono quelli scritti: scrivere un oggetto con `AsJson` e rileggerlo in una seconda istanza dà gli stessi valori, compresi accenti, virgolette, barre rovesciate e a capo dentro le stringhe.

### Scenario: lettura della risposta di un servizio
- **Dato** il testo `{"nome":"Bianchi","quantita":7,"importo":2.5,"attivo":false}`
- **Quando** lo si assegna a `AsJson`
- **Allora** `Nome` è `Bianchi`, `Quantita` è 7, `Importo` è 2,5 e `Attivo` è falso

### Scenario: andata e ritorno con caratteri speciali
- **Dato** una DTO con `Nome` che contiene una lettera accentata, il simbolo dell'euro, una virgoletta, una barra rovesciata e un a capo
- **Quando** si legge `AsJson` e lo si assegna a una seconda DTO
- **Allora** `Nome` della seconda è identico a quello della prima

## ZLIBS-DTO-003 Testo che non è un oggetto
- Stringa vuota, testo non valido come JSON o la parola `null`: l'assegnazione **non fa niente** e non solleva errori; i campi restano come erano.
- Un valore JSON semplice (numero, stringa, `true`, `false`): solleva `EConversionError` («Cannot create object»).
- Un array alla radice: la classe tenta di scriverlo nel campo `Items` (DIV-DTO-3); nessun chiamante lo usa e il comportamento non è specificato.

### Scenario: testo non valido
- **Dato** una DTO con `Nome` = `x`
- **Quando** si assegna a `AsJson` il testo `<html>errore</html>`
- **Allora** nessun errore e `Nome` è ancora `x` (DIV-DTO-5)

### Scenario: numero alla radice
- **Dato** una DTO qualunque
- **Quando** si assegna a `AsJson` il testo `123`
- **Allora** viene sollevata `EConversionError`

## ZLIBS-DTO-004 Rimpaginazione
`TJsonDTO.PrettyPrintJSON(testo)` restituisce il JSON rimpaginato: ogni livello rientra di due spazi, le parentesi graffe stanno su righe proprie, un membro per riga nella forma `"nome":valore` (**senza spazio dopo i due punti**), la virgola di fine riga per tutti i membri tranne l'ultimo, righe separate da `sLineBreak`, riga finale terminata da `sLineBreak`. L'oggetto alla radice è rientrato di due spazi, i suoi membri di quattro. Se il testo non è JSON valido il risultato è la stringa vuota, senza errori. Il testo rimpaginato, riletto, descrive gli stessi dati dell'originale, anche con array e oggetti annidati.

### Scenario: oggetto semplice
- **Dato** il testo `{"a":1,"b":"x"}`
- **Quando** si chiama `PrettyPrintJSON`
- **Allora** il risultato è, riga per riga: due spazi e `{`, quattro spazi e `"a":1,`, quattro spazi e `"b":"x"`, due spazi e `}`

### Scenario: oggetto annidato
- **Dato** il testo `{"o":{"c":2}}`
- **Quando** si chiama `PrettyPrintJSON`
- **Allora** il membro `o` apre la propria parentesi graffa sulla riga `"o":{` e il contenuto è rientrato di altri due spazi, fino alla graffa di chiusura

### Scenario: testo non valido
- **Dato** il testo `non json`
- **Quando** si chiama `PrettyPrintJSON`
- **Allora** il risultato è la stringa vuota

### Scenario: array
- **Dato** il testo `{"v":[1,{"k":"z"},[2,3]]}`
- **Quando** lo si rimpagina e si rilegge il risultato con `TJSONObject.ParseJSONValue`
- **Allora** il JSON riletto è uguale all'originale (DIV-DTO-2: i rientri degli array non sono coerenti)

## ZLIBS-DTO-005 Date in formato ISO 8601 UTC
I campi `TDateTime` sono scritti come testo ISO 8601 in UTC (con la `Z` finale) e letti con la stessa convenzione: l'ora locale viene convertita in UTC in scrittura e riconvertita in lettura. Scrivere e rileggere nello stesso fuso dà la stessa data e ora, con l'approssimazione del millisecondo.

### Scenario: andata e ritorno
- **Dato** una DTO con una data e ora (15 giugno 2026, 10:30)
- **Quando** si legge `AsJson` e lo si assegna a una seconda DTO
- **Allora** la seconda ha la stessa data e ora, e nel JSON il valore della data è un testo con `T` e `Z`

## ZLIBS-DTO-006 Attributo SuppressZero
Un campo `TDateTime` con `[SuppressZero]` è scritto come **stringa vuota** se vale 0, altrimenti come testo ISO 8601 UTC. In lettura la stringa vuota dà 0 e un testo ISO dà la data. Evita di scrivere la data zero di Delphi (30 dicembre 1899) come se fosse una data vera.

### Scenario: data zero
- **Dato** una DTO con un campo `[SuppressZero]` uguale a 0
- **Quando** si legge `AsJson`
- **Allora** il membro corrispondente è la stringa vuota

### Scenario: data valorizzata
- **Dato** lo stesso campo con 15 giugno 2026, 10:30
- **Quando** si scrive e si rilegge in un'altra istanza
- **Allora** la data torna uguale (con l'approssimazione del millisecondo)

### Scenario: stringa vuota in lettura
- **Dato** una DTO con il campo valorizzato
- **Quando** si assegna a `AsJson` un oggetto con quel membro uguale a `""`
- **Allora** il campo vale 0

## ZLIBS-DTO-007 Liste costruite da array
`TArrayMapper` offre tre metodi protetti che le DTO usano nei getter delle loro liste:
- `List<T>(Lista, Array)`: se la lista è `nil` ne crea una e vi copia gli elementi dell'array; se esiste già, **la restituisce com'è senza rileggere l'array**;
- `ObjectList<T>(Lista, Array)`: come sopra con `TObjectList<T>`, che **possiede gli oggetti** (predefinito di `TObjectList`);
- `RefreshArray<T>(Lista, Array)`: se la lista esiste copia i suoi elementi nell'array; se è `nil` lascia l'array com'è.

Il getter della lista crea quindi la lista alla prima lettura, a partire da ciò che `AsJson :=` ha messo nell'array. Prima di scrivere il JSON `GetAsJson` chiama `RefreshArray`, così le aggiunte fatte alla lista finiscono nell'array e quindi nel JSON. La DTO deve liberare la lista nel distruttore.

### Scenario: lettura di una lista di numeri
- **Dato** una DTO con lista `Numeri` costruita come in `TGps`
- **Quando** si assegna a `AsJson` il testo `{"numeri":[1.5,2.5]}`
- **Allora** `Numeri` contiene 1,5 e 2,5 nell'ordine

### Scenario: scrittura di una lista di numeri
- **Dato** una DTO a cui si aggiungono 1,5 e 2,5 a `Numeri`
- **Quando** si legge `AsJson`
- **Allora** il membro `numeri` è un array di due numeri; assegnando il testo a una seconda DTO la lista ha gli stessi due valori

### Scenario: la lista esistente non viene ricostruita
- **Dato** una lista già creata da `List<T>` con due elementi
- **Quando** si richiama `List<T>` con un array di cinque elementi
- **Allora** si ottiene la stessa lista con due elementi

### Scenario: proprietà degli oggetti
- **Dato** una `TObjectList` creata da `ObjectList<T>` con due oggetti
- **Quando** la lista viene liberata
- **Allora** i due oggetti sono liberati

### Scenario: array lasciato com'è
- **Dato** una lista `nil` e un array con tre elementi
- **Quando** si chiama `RefreshArray`
- **Allora** l'array ha ancora i tre elementi

## ZLIBS-DTO-008 Attributo GenericListReflect
Un campo `TObjectList<T>` con `[GenericListReflect]` è scritto nel JSON come array di oggetti, con il nome del campo senza la `F` iniziale e la prima lettera minuscola. Per funzionare serve una **proprietà con il nome del campo senza `F`** (`FVoci` e `Voci`): il convertitore legge la lista dalla proprietà con la riflessione. Il campo array parallelo (`FVociArray`) porta `JSONName` e `JSONMarshalled(False)` e serve alla lettura (ZLIBS-DTO-007).

### Scenario: lista di oggetti in scrittura
- **Dato** una DTO con due voci (`codice` = `A` e `B`) nella lista `Voci`
- **Quando** si legge `AsJson`
- **Allora** il membro `voci` è un array di due oggetti con `codice` = `A` e `B`

### Scenario: lista di oggetti in lettura
- **Dato** il testo `{"voci":[{"codice":"X"},{"codice":"Y"},{"codice":"Z"}]}`
- **Quando** lo si assegna a `AsJson`
- **Allora** `Voci.Count` è 3 e `Voci[2].Codice` è `Z`

### Scenario: lista vuota
- **Dato** una DTO senza voci
- **Quando** si legge `AsJson` e lo si assegna a una seconda DTO
- **Allora** `Voci.Count` della seconda è 0

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-DTO-1 🟢 (dedotta) | In `PrettyPrintJSON` (riga 95) il ramo degli array passa `i = TJSONObject(aJSONValue).Count - 1`, un cast di un `TJSONArray` a `TJSONObject`; il parametro `Last` è poi ignorato da `PrettyPrintArray` | Un cast non valido su un oggetto di tipo diverso: oggi funziona perché i due tipi hanno la stessa disposizione dei campi, ma può dare un accesso a memoria errato con un'altra versione della libreria JSON |
| DIV-DTO-2 🟢 (dedotta) | Rientri degli array incoerenti alla radice: per un array come documento intero `[` e gli elementi stanno a quattro spazi e `]` a due (dentro un oggetto invece i rientri tornano) | Solo estetica: il JSON resta valido, e si nota solo nei registri se un servizio risponde con un array alla radice |
| DIV-DTO-3 🟡 (dedotta) | `SetAsJson` con un array alla radice chiama `TJSONUnMarshal.SetFieldArray(Self, 'Items', ...)`, cioè cerca il campo di nome `Items`; per le DTO la convenzione dei campi è `FNome` e nessuna classe di WT o Gesty ha un campo `Items` | Un array alla radice probabilmente non riempie niente o solleva un errore della libreria; non è mai stato provato perché nessun servizio usato risponde con un array alla radice |
| DIV-DTO-4 🟡 | `List<T>` e `ObjectList<T>` costruiscono la lista **solo se è `nil`**; con una lista già creata ignorano l'array (ZLIBS-DTO-007) | Rileggere `AsJson :=` su una DTO di cui si è già letta una lista lascia la lista vecchia e `GetAsJson` poi riscrive l'array dalla lista, perdendo i dati nuovi. Oggi ogni chiamante crea una DTO nuova per ogni risposta, quindi non si manifesta |
| DIV-DTO-5 🟡 | `SetAsJson` ignora in silenzio il testo vuoto o non valido (anche una pagina HTML di errore del server o del proxy) e lascia la DTO con i valori predefiniti | I chiamanti (`dmOpenApi.http`) controllano solo che il testo non sia vuoto: una risposta non JSON produce una DTO «vuota» e non un errore, e può essere letta come «nessun risultato» |
| DIV-DTO-6 🟢 | Nel ramo «valore semplice» di `SetAsJson` la condizione `(aValue = '') and not Assigned(JSONValue)` non può mai essere vera (il caso `not Assigned` è già uscito prima) | Codice morto che fa credere a una gestione della stringa vuota diversa da quella reale |
| DIV-DTO-7 🟡 (dedotta) | Il lettore di `SuppressZero` chiama `ISO8601ToDate(Testo, True)` senza protezione per testi diversi da quelli ISO | Un servizio che invia `"N/D"` o una data in un altro formato fa fallire l'intera `AsJson :=` con una eccezione di conversione di data; i valori già letti prima restano nei campi |
| DIV-DTO-8 🟢 (dedotta) | Il convertitore di `GenericListReflect` ricava la proprietà con `Copy(Campo, 2, MAXINT)`: se la proprietà non esiste (campo non chiamato `F` + proprietà) il risultato è `nil` e la chiamata successiva dà una violazione d'accesso | Un errore di nome in una nuova DTO si scopre solo in esecuzione, con un errore poco leggibile |
| DIV-DTO-9 🟢 | La unit esiste in due copie identiche (zLibs e `zServer\_src\Products\Gesty\Firma`) e in una terza variante (`Pkg.Json.DTO` di Gesty) | Una correzione va riportata in tutte, altrimenti le copie divergono |

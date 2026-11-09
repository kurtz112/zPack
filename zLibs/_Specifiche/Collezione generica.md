---
area: Collezione generica
progetto: zLibs
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/001
---

# Collezione generica

Questa specifica descrive `TzGenericCollection<T>` di `zLibs\zz.GenericCollection.pas`: una `TCollection` di Delphi resa tipizzata, in modo che `Add`, `Insert`, `Items[i]` e il giro `for ... in` restituiscano direttamente l'elemento del tipo `T` (discendente di `TCollectionItem`) senza conversioni a mano. In più offre ricerca con una funzione (`IndexOf`, `Get`, `ForEach`), ordinamento con un confronto ridefinibile (`Sort`) e salvataggio e caricamento come testo nel formato dei file `.dfm` (`SaveToStream`, `LoadFromStream`, `SaveToFile`, `LoadFromFile`, `AsText`). La unit contiene anche la base astratta `TJSONCollection` (metodi `Decode` e `Encode` astratti e proprietà `JSON`), la classe di appoggio `TProxy` e un tipo `THackCollection` che non usa nessuno.

È la collezione tipizzata usata da WT, Gesty e zPack per i loro elenchi di oggetti in memoria (da non confondere con `zBase\zCollection.pas`, la collezione del dizionario LZ, specificata in `Collezione LZ.md`, `ZBASE-COL`). Chi la usa (verificato con una ricerca in `D:\AI\SRC`):

| Progetto | Unit | Uso |
|---|---|---|
| Gesty | `Varie\CalendarioAule.classes` (`TOre`, `TGiorni`, `TAule`, `TEventi`, con `Compare` ridefinito e `Sort`), `CalendarioCorsi.classes`, `CalendarioDocenti.classes`, `RegistroStudentiCollettiva.Classes`, `RiepilogoGiornalieroAule.classes`, `ValutazioniPrestazioni.classi` e `.types` (con una `Get` propria per identificativo) | elenchi costruiti da dataset e ordinati per la stampa |
| Gesty server | `_Sorgenti_Server\lib\lib.datasetProps`, `lib.widgetOptions` | opzioni di dataset e widget |
| WT | `Varie\CalendarioPrenotazioni.classes`, `Gera.CalendarioTurni.Filtri`, `Postel.DocuFE.lib` (qui `TzGenericCollection<TDoc>` si crea direttamente, senza classe derivata) | calendari, filtri, documenti del servizio postale |
| zPack | `zBase\zModuli`, `zBase\zRestrictions.Structs` (con una `IndexOf` per nome), `zBase\zLocalizer`, `zLibs\zz.DataSetClassGenerator`, `zOffice\zFileSystem` | moduli, restrizioni, lingue |
| Altri | `zFbExpert\zFbTools\_src\Json2db.classes` | strumenti |

La unit non è elencata in nessun pacchetto (`.dpk`): si compila perché sta nel percorso di ricerca ed è citata nelle clausole `uses`.

**Come funziona.** La collezione si crea con la classe dell'elemento, come ogni `TCollection`: `TElenco.Create(TElemento)`. Il generico non conosce quella classe: converte con un `T(...)` senza controlli ogni elemento che la `TCollection` gli passa, quindi la classe passata al costruttore deve essere `T` o un suo discendente. Le persistenze (`SaveToStream` e simili) non scrivono la collezione da sola: la agganciano a un componente di appoggio (`TProxy`) con una proprietà pubblicata, e fanno scrivere e leggere il componente al sistema di flusso di Delphi, nello stesso formato testuale dei `.dfm`. Gli elementi vi compaiono con le loro proprietà pubblicate (`published`), e solo quelle.

**Test che coprono quest'area.** `Test.zz.GenericCollection` (in `zPack\_UnitTest\_src`, 31 prove) con un elemento di prova (`TVoce`, con `Nome` e `Valore` pubblicati) e tre raccolte derivate: aggiunta e inserimento, giro `for ... in`, `IndexOf`, `Get`, `ForEach`, `Sort` con e senza `Compare` ridefinito, assegnazione di un elemento, salvataggio e caricamento su flusso, su testo e su file (compreso il testo con accenti), i casi con flusso nullo e file inesistente, i metodi astratti e la fotografia di DIV-GCO-1. In Gesty `Test.ValutazioniPrestazioni.Types` prova classi che derivano da questa collezione.

## ZLIBS-GCO-001 Aggiunta, inserimento, accesso e rimozione
`Add` crea un elemento nuovo in fondo e lo restituisce già del tipo `T`; `Insert(i)` lo crea in posizione `i`, con `Index` uguale a `i`; `Items[i]` e la proprietà predefinita `Collezione[i]` restituiscono l'elemento in posizione `i`; `Count` ne dà il numero. `Remove(Elemento)` toglie e libera quell'elemento: gli altri scalano di una posizione e conservano l'ordine.

### Scenario: due elementi
- **Dato** una collezione vuota
- **Quando** si aggiungono `Rossi` e `Bianchi` con `Add`
- **Allora** `Count` è 2, `Items[0]` è il primo e `Items[1]` il secondo

### Scenario: inserimento in testa
- **Dato** una collezione con `B` e `C`
- **Quando** si chiama `Insert(0)` e si dà il nome `A` al nuovo elemento
- **Allora** l'ordine è `A`, `B`, `C` e l'indice del nuovo elemento è 0

### Scenario: rimozione
- **Dato** una collezione con `A`, `B`, `C`
- **Quando** si chiama `Remove` sull'elemento `B`
- **Allora** restano `A` e `C`, in quest'ordine

## ZLIBS-GCO-002 Giro `for ... in`
`for Elemento in Collezione` restituisce gli elementi già del tipo `T`, in ordine di posizione, uno per volta. Una collezione vuota non fa nessun giro. L'enumeratore è creato a ogni giro e liberato da Delphi; non va usato modificando la collezione durante il giro.

### Scenario: tre elementi
- **Dato** una collezione con tre elementi di valori 10, 20 e 30
- **Quando** la si percorre con `for ... in` sommando i valori
- **Allora** i giri sono tre, nell'ordine di inserimento, e la somma è 60

## ZLIBS-GCO-003 Ricerca con una funzione (`IndexOf` e `Get`)
`IndexOf(Funzione)` restituisce la posizione del **primo** elemento per cui la funzione è vera, `-1` se nessuno lo è (anche su una collezione vuota). `Get(Funzione)` restituisce quell'elemento, oppure `nil` se non c'è. `Get(Funzione, True)` (cioè con `CanAppend` vero) invece, se non lo trova, **aggiunge** un elemento nuovo e lo restituisce: è vuoto, lo riempie il chiamante. La funzione non può essere `nil`: nessuno dei due metodi lo controlla (DIV-GCO-2).

### Scenario: più corrispondenze
- **Dato** una collezione con valori 5, 7, 7
- **Quando** si cerca con la funzione «valore uguale a 7»
- **Allora** `IndexOf` restituisce 1

### Scenario: non trovato con aggiunta
- **Dato** una collezione con un elemento di nome `A`
- **Quando** si chiama `Get` con una funzione che non trova niente e `CanAppend` vero
- **Allora** la collezione ha 2 elementi, il secondo è quello restituito e ha il nome vuoto

## ZLIBS-GCO-004 `ForEach` con interruzione
`ForEach(Funzione)` chiama la funzione su ogni elemento, in ordine. La funzione restituisce **vero per continuare e falso per fermarsi**: appena risponde falso il giro termina e gli elementi successivi non vengono visitati. La funzione non può essere `nil` (c'è un `Assert`, che nelle build senza controlli non protegge).

### Scenario: interruzione
- **Dato** una collezione con valori 1, 2, 3 e una funzione che risponde falso dal valore 2 in poi
- **Quando** si chiama `ForEach`
- **Allora** vengono visitati solo il primo e il secondo elemento

## ZLIBS-GCO-005 Ordinamento (`Sort`)
`Sort` ordina gli elementi in base a `Compare(Item1, Item2)`, un metodo virtuale che le classi derivate ridefiniscono restituendo un numero negativo, zero o positivo, come ogni funzione di confronto. La versione della base restituisce sempre 0: una collezione che non la ridefinisce non cambia di fatto l'ordine garantito (gli elementi restano tutti, ma l'ordine non è definito). Dopo `Sort` gli `Index` degli elementi corrispondono alle nuove posizioni. L'ordinamento non è stabile: elementi che il confronto giudica uguali possono scambiarsi di posto (DIV-GCO-3).

### Scenario: ordine per valore
- **Dato** una collezione che ridefinisce `Compare` sul campo `Valore` e contiene `C`=3, `A`=1, `B`=2, `D`=4
- **Quando** si chiama `Sort`
- **Allora** l'ordine è `A`, `B`, `C`, `D`

### Scenario: confronto non ridefinito
- **Dato** una collezione senza `Compare` ridefinito, con tre elementi
- **Quando** si chiama `Sort`
- **Allora** gli elementi restano tre, con gli stessi valori

## ZLIBS-GCO-006 Assegnazione di un elemento
`Collezione[i] := Elemento` non sostituisce l'oggetto in posizione `i`: chiama `Assign` sull'elemento già presente passandogli l'altro. Il risultato dipende quindi da come l'elemento ridefinisce `Assign`: se lo ridefinisce copia i suoi campi, se non lo fa eredita l'`Assign` di `TCollectionItem`, che copia solo l'identificativo interno e lascia le proprietà come sono. Le classi derivate che vogliono questa assegnazione devono ridefinire `Assign`.

### Scenario: elemento con `Assign` ridefinito
- **Dato** una collezione con `A` e `B`, il cui elemento copia `Nome` e `Valore` in `Assign`
- **Quando** si assegna l'elemento `B` alla posizione 0
- **Allora** la posizione 0 ha il nome e il valore di `B`, la collezione ha ancora 2 elementi e i due oggetti restano distinti

### Scenario: elemento senza `Assign`
- **Dato** una collezione i cui elementi non ridefiniscono `Assign`
- **Quando** si assegna il secondo elemento alla posizione 0
- **Allora** il nome della posizione 0 non cambia

## ZLIBS-GCO-007 Salvataggio e caricamento come testo
`SaveToStream`, `SaveToFile` e `AsText` (in lettura) scrivono la collezione come testo nel formato dei `.dfm`: gli elementi con le loro proprietà pubblicate, nell'ordine di posizione. `LoadFromStream`, `LoadFromFile` e `AsText` (in scrittura) la leggono: quando il testo contiene almeno un elemento, **gli elementi presenti vengono tolti** e sostituiti da quelli letti; non vengono accodati. Il testo con caratteri accentati torna uguale. Un flusso nullo (`nil`) in `SaveToStream` o `LoadFromStream` non fa niente e non dà errore. `AsText := ''` (testo vuoto) **svuota** la collezione. `LoadFromFile` su un file inesistente solleva `EFOpenError`. Il testo di una collezione vuota non contiene elementi, e leggerlo non svuota la destinazione (DIV-GCO-1).

### Scenario: viaggio di andata e ritorno
- **Dato** una collezione con tre elementi
- **Quando** si legge `AsText` e lo si assegna a una collezione nuova dello stesso tipo
- **Allora** la nuova ha tre elementi con gli stessi nomi, nello stesso ordine, e gli stessi valori

### Scenario: caricamento che sostituisce
- **Dato** una collezione con tre elementi e il testo di una collezione con un solo elemento
- **Quando** si assegna il testo ad `AsText`
- **Allora** la collezione ha un solo elemento, quello del testo

### Scenario: testo vuoto
- **Dato** una collezione con due elementi
- **Quando** si assegna la stringa vuota ad `AsText`
- **Allora** la collezione è vuota

### Scenario: file inesistente
- **Dato** un percorso senza file
- **Quando** si chiama `LoadFromFile`
- **Allora** viene sollevata `EFOpenError`

## ZLIBS-GCO-008 Base astratta `TJSONCollection`
`TzGenericCollection<T>` discende da `TJSONCollection`, che dichiara come astratti `Decode(JSONObject, NomeProprieta)`, `Decode(JSONArray)` e `Encode`, e ha una proprietà `JSON` (un testo) «utilizzato dalle discendenti». La unit non implementa nessuno di questi metodi e nessun chiamante in `D:\AI\SRC` lo fa (l'unico accenno, in `zz.JSON da completare.pas`, è commentato): chiamare `Encode` o `Decode` su una collezione creata dal generico solleva `EAbstractError`. La proprietà `JSON` conserva il testo assegnato e inizialmente è vuota.

### Scenario: Encode nella base
- **Dato** una collezione creata dal generico, senza classi derivate che implementino `Encode`
- **Quando** si chiama `Encode`
- **Allora** viene sollevata `EAbstractError`

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. Quelle marcate «dedotta» vengono dalla lettura del codice e della libreria di base, senza prova eseguita; DIV-GCO-1 ha una prova che la fotografa.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-GCO-1 🟡 (dedotta) | Il lettore di Delphi svuota la collezione di destinazione solo se il testo contiene almeno un elemento. Il testo di una collezione vuota (`AsText`, `SaveToStream`) non ne contiene, quindi caricarlo non toglie quelli già presenti; `AsText := ''` invece svuota, perché è gestito a parte | Copiare una collezione vuota in una piena attraverso il testo lascia la destinazione piena: chi lo fa per «ripristinare» uno stato vuoto trova ancora i vecchi elementi |
| DIV-GCO-2 🟢 (dedotta) | `IndexOf(nil)` e `Get(nil)` chiamano la funzione senza controllarla; `Remove(nil)` legge l'indice di un oggetto nullo; `ForEach(nil)` ha solo un `Assert` | Una chiamata sbagliata dà una violazione di accesso invece di un errore leggibile; `Remove` di un elemento già tolto (indice -1) dà un errore di lista |
| DIV-GCO-3 🟢 (dedotta) | `Sort` passa per l'ordinamento di `TCollection`, che non è stabile; `Compare` della base restituisce sempre 0 | Due elementi con la stessa chiave possono scambiarsi di posto a ogni ordinamento: chi stampa elenchi ordinati per una chiave non univoca può vedere l'ordine interno cambiare da una stampa all'altra |
| DIV-GCO-4 🟢 (dedotta) | Il generico non è legato alla classe passata al costruttore: converte con `T(...)` senza controllo | Una collezione creata con una classe che non discende da `T` restituisce oggetti del tipo sbagliato e dà violazioni di accesso lontane dall'errore; basterebbe un costruttore che passa `T` alla base |
| DIV-GCO-5 🟢 | Codice morto o ingannevole: `THackCollection` (dichiarata, non usata da nessuno), un `QuickSort` commentato, un `TODO IndexOf` commentato, e la parola `zcollection` dopo `end.` | Chi legge la unit può credere che l'ordinamento sia quello commentato o che l'accesso ai campi privati della collezione sia in uso; il testo dopo `end.` il compilatore lo ignora |
| DIV-GCO-6 🟢 | `TJSONCollection.Decode` e `Encode` sono astratti e nessuna classe li implementa | Ogni collezione creata dal generico è un oggetto con metodi astratti (il compilatore può avvisarne a ogni costruzione); chiamare `Encode` dà `EAbstractError`. O si implementano nelle derivate che servono, o si toglie la base |

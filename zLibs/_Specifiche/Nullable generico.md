---
area: Nullable generico
progetto: zLibs
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/001
---

# Nullable generico

Questa specifica descrive `TNullable<T>` di `zLibs\zz.Nullable.pas` dal punto di vista di chi lo usa su un tipo preciso: come si confrontano e si ordinano i valori di tipo stringa, numero, data, valuta e GUID, come passano da e verso `Variant`, che cosa succede copiando, azzerando o assegnando un puntatore, e quali sigle di tipo esistono. Non ripete ciò che dice già `Valori nullable.md` di zFIB, a cui si rimanda: il significato di «valore o nulla» (`ZFIB-NUL-001`), la creazione da `Variant` nulli (`ZFIB-NUL-002`), la lettura del valore (`ZFIB-NUL-003`), le conversioni di base (`ZFIB-NUL-004`), la regola «il nullo è uguale al predefinito» (`ZFIB-NUL-005`), il booleano (`ZFIB-NUL-006`) e il layout dei campi `fValue` e `fHasValue` che `TzStoredProc` legge per riflessione (`ZFIB-NUL-007`). Chi cambia quella unit deve rileggere entrambe le specifiche.

Chi lo usa (verificato con una ricerca in `D:\AI\SRC`): i wrapper generati delle stored procedure (`Wintarif_Group\_src\Wt3_StoredProcs.pas`, `Gesty_Group\_Sorgenti\Gesty_StoredProcs.pas`, `zTicser\_src\zTicser_StoredProcs.pas`, generati da `zBase\zStoredProcCodeFactory.pas`); in WT `dmStesei`, `dmInvitiAlContraddittorio`, `dmStradarioAnncsu` e `BD_ImportBancheDati_Dump_XML_MUI_ICI`; in Gesty `BaseWeb.PropertyEditors`; in zTicser `dmTicserConfigurazione`, `dmTicserPef` e `frmTicserPefImporta`; in zPack `zz.DataSetHelper`, `zz.DataSetClassGenerator` e `zz.RTTI`. La unit non è elencata in nessun pacchetto (`.dpk`): si compila perché sta nel percorso di ricerca ed è citata nelle clausole `uses`. Nella sezione `implementation` cita `SmartInspect.Vcl` e `SmartInspect.Vcl.SiAuto` senza più usarli (vedi DIV-NUL-7). Le altre copie del file (`zz.Nullable - NEW.pas` e simili) non sono autorevoli e non sono oggetto di questa specifica (DIV-NUL-4 di zFIB).

**Come funziona.** `TNullable<T>` è un record impacchettato con due campi: il valore e un indicatore di presenza di tipo stringa (`'@'` presente, vuoto assente). Tutti i confronti e l'ordinamento passano per i comparatori predefiniti della libreria di base di Delphi per il tipo `T` (`TEqualityComparer<T>.Default` e `TComparer<T>.Default`), dopo aver sostituito un eventuale nullo col valore predefinito del tipo. Le conversioni da e verso `Variant` passano da `TValue`, quindi funzionano solo per i tipi che `TValue` sa convertire.

**Test che coprono quest'area.** `Test.zz.Nullable` (in `zPack\_UnitTest\_src`, 38 prove): confronti e ordinamento per tipo, conversioni da e verso `Variant`, copia, azzeramento, assegnazione di puntatore, sigle di tipo e la fotografia di DIV-NUL-5. Le regole di ZFIB-NUL-001..007 (nullo uguale a zero e alla stringa vuota, `Value` che non solleva errori, layout dei campi) non sono ancora coperte da una prova propria.

## ZLIBS-NUL-001 Uguaglianza secondo il tipo
`=` e `<>` (fra nullable e valore, valore e nullable, due nullable) usano l'uguaglianza predefinita del tipo, dopo aver sostituito il nullo col valore predefinito (`ZFIB-NUL-005`). Per i tipi di uso corrente questo significa:
- stringhe: confronto **esatto**, che distingue maiuscole e minuscole e conta gli spazi (`'Abc'` non è uguale a `'abc'` né a `'Abc '`); vale anche per `AnsiString` e `WideString`;
- numeri decimali (`Double`): uguaglianza **esatta**, senza tolleranza: `1,5` e `1,5000001` sono diversi;
- date e ore (`TDateTime`, `TDate`, `TTime`): uguali solo se hanno lo stesso valore numerico, quindi un secondo di differenza basta;
- valute (`Currency`): uguaglianza esatta al centesimo di unità minima;
- `TGUID` (e in generale i record): confronto byte per byte; il nullo vale il GUID vuoto, tutto zeri.

### Scenario: maiuscole diverse
- **Dato** un `TNullableString` con `Abc`
- **Quando** si valuta `= 'abc'`
- **Allora** il risultato è falso, e `<> 'abc'` è vero

### Scenario: decimali vicini
- **Dato** un `TNullableDouble` con 1,5
- **Quando** lo si confronta con 1,5000001
- **Allora** non sono uguali

### Scenario: GUID nullo
- **Dato** un `TNullableGuid` nullo
- **Quando** lo si confronta con `TGUID.Empty`
- **Allora** sono uguali, e il confronto con un GUID vero è falso

## ZLIBS-NUL-002 Ordinamento secondo il tipo
`<`, `<=`, `>`, `>=` (con le tre combinazioni di operandi) usano il comparatore predefinito del tipo, dopo aver sostituito il nullo col valore predefinito. Conseguenze da conoscere:
- un nullo numerico vale 0: sta **sopra** un numero negativo e **sotto** uno positivo;
- le stringhe si ordinano per codice dei caratteri, senza tener conto della lingua: `'B'` viene prima di `'a'`, `'abc'` prima di `'abd'` e dopo `'ab'`;
- una data nulla vale la data zero (30 dicembre 1899), prima di qualunque data reale;
- due valori uguali sono sia `<=` sia `>=`, mai `<` né `>`;
- l'ordine fra `TGUID` è quello dei byte in memoria e non ha un significato utile: non si usa.

### Scenario: nullo e negativo
- **Dato** un `TNullableInt64` nullo
- **Quando** lo si confronta con -1
- **Allora** `> -1` e `>= -1` sono veri, `< -1` e `<= -1` sono falsi

### Scenario: maiuscole nell'ordine
- **Dato** un `TNullableString` con `B`
- **Quando** lo si confronta con `a`
- **Allora** `< 'a'` è vero (66 è minore di 97)

## ZLIBS-NUL-003 Il valore può stare a sinistra
Ogni operatore ha la forma con il valore a sinistra e il nullable a destra, con lo stesso risultato della forma speculare: `5 = n`, `6 <> n`, `4 < n`, `6 >= n` si comportano come `n = 5`, `n <> 6`, `n > 4`, `n <= 6`.

### Scenario: valore a sinistra
- **Dato** un `TNullableInt64` con 5
- **Quando** si valuta `5 = n` e `6 = n`
- **Allora** la prima è vera e la seconda falsa

## ZLIBS-NUL-004 Verso `Variant`
Assegnando un nullable a un `Variant`, un nullo dà `Null` (per ogni tipo: un parametro `NULL` per il server); un valore presente dà il valore del tipo corrispondente. Un valore uguale al predefinito (0, stringa vuota, `False`) è un valore presente e **non** diventa `Null`: per il server `0` e `NULL` sono cose diverse. Le date diventano date, le valute valute, i booleani booleani.

Non tutti i tipi sono convertibili: `TValue` non sa trasformare un record, quindi un `TNullableGuid` con valore non si converte in `Variant` (DIV-NUL-5).

### Scenario: valore predefinito presente
- **Dato** un `TNullableInteger` con valore 0
- **Quando** lo si assegna a un `Variant`
- **Allora** il `Variant` vale 0 e non è `Null`

### Scenario: nullo di un tipo qualunque
- **Dato** un nullable nullo di tipo stringa, intero, decimale, data, valuta o booleano
- **Quando** lo si assegna a un `Variant`
- **Allora** il `Variant` è `Null`

## ZLIBS-NUL-005 Da `Variant`
`Create(Variant)` converte il valore nel tipo `T` quando il `Variant` ha un tipo compatibile: una data di `Variant` dà un `TNullableDateTime`, una valuta un `TNullableCurrency`, un booleano un `TNullableBoolean`, un intero un `TNullableInt64`. Solo `Null` e `Unassigned` (vuoto) danno un nullo, per ogni tipo; uno spazio o più spazi sono un valore presente: il parametro che permetterebbe di togliere gli spazi prima del controllo non è mai usato con valore vero (DIV-NUL-6). Una conversione di andata e ritorno (nullable, `Variant`, nullable) conserva sia il valore sia la presenza.

### Scenario: data
- **Dato** un `Variant` creato con `VarFromDateTime` per le 10:30 del primo novembre 2026
- **Quando** si crea un `TNullableDateTime` da esso
- **Allora** il nullable ha valore e il valore è lo stesso istante

### Scenario: solo spazi
- **Dato** un `Variant` con tre spazi
- **Quando** si crea un `TNullableString`
- **Allora** il nullable ha valore e il testo è di tre spazi

### Scenario: andata e ritorno di un nullo
- **Dato** un `TNullableInteger` nullo
- **Quando** lo si passa a un `Variant` e si ricrea un `TNullableInteger`
- **Allora** il risultato è ancora nullo

## ZLIBS-NUL-006 Copia, azzeramento e valori predefiniti
`TNullable<T>` è un record: l'assegnazione fra due nullable copia valore e presenza, e le due copie sono poi indipendenti (azzerare o cambiare l'originale non tocca la copia; copiare un nullo dà un nullo). `Clear` toglie la presenza e riporta il valore al predefinito: dopo di esso `HasValue` è falso, `IsNull` e `IsEmpty` sono veri, `Value` è il predefinito e `GetValueOrDefault(x)` dà `x`; il nullable si può riassegnare. Assegnare esplicitamente il valore predefinito del tipo (0, stringa vuota, `False`) dà un nullable **con valore**: l'unico modo di dire «nullo» è non assegnare niente o chiamare `Clear`. `GetValueOrDefault(x)` su un nullable con valore (anche zero) restituisce il valore, non `x`.

### Scenario: copia indipendente
- **Dato** un `TNullableString` con `primo` e una copia fatta per assegnazione
- **Quando** l'originale viene azzerato
- **Allora** la copia ha ancora valore e vale `primo`

### Scenario: zero è un valore
- **Dato** un `TNullableInteger` a cui si assegna 0
- **Quando** si legge `HasValue`
- **Allora** è vero, e `GetValueOrDefault(7)` restituisce 0

## ZLIBS-NUL-007 Assegnazione di un puntatore
Assegnare `nil` a un nullable lo rende nullo. Assegnargli un puntatore diverso da `nil` solleva `EInvalidOperation` («Cannot assigned non-null pointer to nullable type.»). La conversione serve solo a poter scrivere `valore := nil` (`ZFIB-NUL-004` lo ricorda).

### Scenario: nil
- **Dato** un `TNullableInt64` con valore 10
- **Quando** gli si assegna `nil`
- **Allora** diventa nullo

### Scenario: puntatore vero
- **Dato** un `TNullableInt64`
- **Quando** gli si assegna un puntatore diverso da `nil`
- **Allora** viene sollevata `EInvalidOperation`

## ZLIBS-NUL-008 Sigle di tipo
Le sigle `TNullableString`, `TNullableAnsiString`, `TNullableWideString`, `TNullableInteger`, `TNullableInt64`, `TNullableNativeInt`, `TNullableDateTime`, `TNullableDate`, `TNullableTime`, `TNullableCurrency`, `TNullableDouble`, `TNullableBoolean` e `TNullableGuid` sono **lo stesso tipo** del generico corrispondente (`TNullableInteger` è `TNullable<Integer>`): si possono assegnare fra loro senza conversioni. Una variabile appena dichiarata di qualunque sigla è nulla.

### Scenario: sigla e generico
- **Dato** una variabile `TNullable<Integer>` con valore 5
- **Quando** la si assegna a una variabile `TNullableInteger`
- **Allora** l'assegnazione compila e la seconda vale 5

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`. La numerazione continua quella di `Valori nullable.md` di zFIB (DIV-NUL-1, 2 e 4 sono lì, DIV-NUL-3 è già corretta): questo file aggiunge le voci dalla 5. Quelle marcate «dedotta» vengono dalla lettura del codice e della libreria di base, senza prova eseguita; DIV-NUL-5 ha una prova che la fotografa.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-NUL-5 🟢 (dedotta) | Un `TNullableGuid` con valore non si converte in `Variant`: la conversione passa da `TValue`, che non sa trasformare un record, e solleva `EInvalidCast` | Oggi nessun chiamante converte un GUID in questo modo; chi lo facesse (per esempio assegnando il parametro di una procedura) avrebbe un errore in esecuzione invece di un testo. Va deciso se convertire il GUID in stringa |
| DIV-NUL-6 🟢 | `VarIsNullOrEmpty` ha un parametro `trimWhiteSpace` che toglie gli spazi prima del controllo, ma l'unico chiamante (`Create(Variant)`) non lo passa mai: il ramo è codice morto | Chi legge il codice può credere che un `Variant` di soli spazi dia un nullo; in realtà dà un valore presente |
| DIV-NUL-7 🟢 | La sezione `implementation` cita `SmartInspect.Vcl`, `SmartInspect.Vcl.SiAuto` e `Classes` senza usarli più dopo la correzione di DIV-NUL-3 | Un tipo di base, usato dai wrapper di tutte le stored procedure, resta legato a una libreria di terzi e alla VCL; per compilare un progetto che non le ha serve comunque il percorso di ricerca di SmartInspect |

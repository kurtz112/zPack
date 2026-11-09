---
area: Wrapper delle procedure
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-utilita-zpack/001
---

# Wrapper delle procedure

Questa specifica descrive il **contratto fra `TzStoredProc` e le classi `TSP_*` generate**: come una proprietà della classe diventa un parametro, come i valori entrano e escono dalle proprietà (`Nullable<T>`, `TStringList`, `TPicture`), che cosa deve contenere una classe generata perché la classe base funzioni e dove il contratto si rompe senza che il compilatore se ne accorga. Il codice è in `zBase\zStoredProc.pas` (classe base, attributi, gancio `InitStoredProc`) e `zBase\zStoredProcCodeFactory.pas` (generatore dei file `Wt3_StoredProcs.pas`, `Gesty_StoredProcs.pas`, `zTicser_StoredProcs.pas`); il tipo dei valori è in `zLibs\zz.Nullable.pas`. La semantica delle chiamate (esecuzione singola, cursore, conferma e annullamento della transazione, registrazione delle prestazioni, helper di `TFDStoredProc`) è già in `zFIB\_Specifiche\Procedure memorizzate.md` (ZFIB-SPR) e non si ripete qui; il comportamento di `Nullable<T>` è in `zFIB\_Specifiche\Valori nullable.md` (ZFIB-NUL).

La classe è usata da 14 file di WT e di Gesty (`Wt3_StoredProcs`, `Gesty_StoredProcs`, i due `ConfigModule`, `Base_DbDataModule` e `Base_DataModule`, `dmStesei`, `Stesei_Engine`, `dmCarteDiCredito`, `dmCatasto`, `dmPalmariExport`, `BD_ImportBancheDati_Dump_XML_MUI_ICI`, `BaseWeb.DM`, `BaseWeb.Repository`) e da altri programmi dei sorgenti (zTicser, ShareFood, WinSinfo). Le unit sono compilate in modo implicito dai progetti che le nominano nella clausola `uses`: nessun pacchetto zPack le elenca. Fuori dal perimetro: `zStoredProc -- pre selectable.pas` (copia di storia, vedi DIV-SPR-12).

**Come funziona.** Il generatore legge i metadati del database e scrive una classe `TSP_<nome>` per ogni procedura. La classe porta l'attributo `TStoredProcedure` (nome e se è selezionabile), una proprietà per parametro con l'attributo `TParamAttribute` (nome del parametro, ingresso o uscita) e la direttiva `{$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}`. `TzStoredProc` non conosce le classi derivate: le scopre in esecuzione con la riflessione (RTTI), cercando per nome del parametro la proprietà e poi il campo privato `f<NomeProprietà>` o, per i `Nullable`, i campi interni `fValue` e `fHasValue`. Il chiamante crea l'istanza (di norma con `GetSP<T>` di `TBaseDbDataModule`, che assegna `zSystem`, `Database` e la transazione di scrittura), scrive le proprietà di ingresso, chiama un metodo di esecuzione e legge le proprietà di uscita.

**Test che coprono quest'area.** `Test.zStoredProc` (bozza di questo rilascio): crea in prova classi `TSP_*` scritte a mano sul modello del generatore e prova, senza Firebird, la creazione e l'attributo, i nomi dei parametri, la scrittura, l'azzeramento, la nullità e la lettura dei valori per ogni tipo di proprietà, il round trip di un `TPicture`, la copia da un campo di dataset e lo stato di un'istanza senza connessione né cursore. Restano senza prova, perché servono Firebird, il generatore con i suoi metadati o la finestra: l'esecuzione vera, il cursore, le transazioni e la registrazione delle prestazioni (ZFIB-SPR).

## ZBASE-SPR-001 Che cosa serve a una classe generata
Una classe derivata da `TzStoredProc` funziona solo se: porta l'attributo `TStoredProcedure(nome[, selezionabile])` sulla propria dichiarazione (l'attributo non si eredita: si legge solo dalla classe istanziata); ha la direttiva `{$RTTI EXPLICIT PROPERTIES([vcPrivate, vcPublic, vcPublished])}`, senza la quale le proprietà private non sono visibili alla riflessione; ha un costruttore `Create` che chiama `inherited` e che crea i campi `TStringList` (con `CreateStringList`) e `TPicture`; per ogni parametro ha una proprietà con `TParamAttribute` e, per le proprietà di tipo oggetto, un campo privato che si chiama `f` più il nome della proprietà. Le uscite scalari sono di sola lettura e hanno una gemella privata scrivibile `<Nome>_internal`, che è quella che `TzStoredProc` usa per scriverle. Il costruttore `Create` è virtuale perché `GetSP<T>` lo chiama attraverso il vincolo `constructor`.

### Scenario: nome e selezionabile
- **Dato** una classe con `[TStoredProcedure('PROVA_SELEZIONE', True)]`
- **Quando** si crea
- **Allora** `StoredProcName = 'PROVA_SELEZIONE'` e `Selectable = True`

### Scenario: attributo senza il secondo argomento
- **Dato** una classe con `[TStoredProcedure('PROVA_ESEGUI')]`
- **Quando** si crea
- **Allora** `Selectable = False`

### Scenario: classe senza attributo
- **Dato** una classe derivata che non porta l'attributo `TStoredProcedure`
- **Quando** si crea
- **Allora** `StoredProcName` è vuoto e `Selectable` è falso; l'errore comparirà solo alla prima esecuzione, quando `FireDAC` non troverà la procedura

## ZBASE-SPR-002 Tipi ammessi per le proprietà dei parametri
Una proprietà con `TParamAttribute` può essere di tre tipi: un record `Nullable<T>` (qualunque scalare), un `TStringList` (parametro MEMO o BLOB di testo) o un `TPicture` (parametro BLOB). Qualunque altro tipo (un `Integer` semplice, una stringa) è un errore di progetto della classe: `ClearParam`, `SetParamValue` (con un valore non nullo), `ParamIsNull` e `GetParamValue` sollevano `(<operazione>) Tipo parametro non gestito: <NOME>`. Una proprietà di tipo oggetto che non sia `TStrings` né `TPicture` non solleva niente: viene ignorata in silenzio.

### Scenario: tipo semplice
- **Dato** una proprietà `Contatore: Integer` con `TParamAttribute('CONTATORE', ptInput)`
- **Quando** si chiama `ClearParam('CONTATORE')`
- **Allora** viene sollevata un'eccezione `(ClearParam) Tipo parametro non gestito: CONTATORE`

## ZBASE-SPR-003 Nome del parametro e nome della proprietà
Il chiamante ragiona sui **nomi dei parametri della procedura** (`ID_CLIENTE`), la classe sulle **proprietà** (`Id_Cliente`, scritta dal generatore con l'iniziale maiuscola dopo ogni trattino basso e il resto minuscolo). `RealInputParamNames` e `RealOutputParamNames` restituiscono i nomi dei parametri letti dagli attributi; `InputParamNames` e `OutputParamNames` quelli delle proprietà. La ricerca della proprietà dato il parametro **non distingue maiuscole da minuscole**. `ParamExists` risponde sui soli parametri dichiarati dalla classe (ingresso e uscita), non su quelli che il server conosce. Un nome di parametro senza proprietà solleva `Proprieta' non trovata per il parametro <nome>` da ogni operazione di lettura e scrittura per nome.

### Scenario: nomi
- **Dato** una classe con sette parametri di ingresso e uno di uscita (`ID_ESITO`)
- **Quando** si leggono `RealInputParamNames` e `RealOutputParamNames`
- **Allora** i nomi sono quelli degli attributi (`ID_CLIENTE`, ...) e l'uscita è `ID_ESITO`

### Scenario: ricerca senza distinzione di maiuscole
- **Dato** la stessa classe
- **Quando** si chiama `ParamExists('id_cliente')`
- **Allora** il risultato è vero

### Scenario: parametro sconosciuto
- **Dato** un nome che nessuna proprietà dichiara
- **Quando** si chiama `SetParamValue('ID_X', 1, False)`
- **Allora** l'eccezione dice `Proprieta' non trovata per il parametro ID_X`

## ZBASE-SPR-004 Scrittura di un valore (`SetParamValue`)
`SetParamValue(nome, valore, ENullo)` scrive la proprietà del parametro, di ingresso o di uscita (per le uscite passa dalla proprietà `_internal`). Con `ENullo` vero equivale a `ClearParam`. Per un `Nullable` imposta l'indicatore di presenza al carattere `'@'` (costante `HasValueFlag`, uguale a quella di `zz.Nullable`: ZFIB-NUL-007) e il valore, convertito per tipo: data e ora, valuta, stringa, intero, doppia precisione e booleano hanno un ramo esplicito; ogni altro tipo di variant (per esempio un intero a 64 bit) passa come `Variant` e la conversione verso il campo la fa la riflessione. Per un `TStringList` assegna `Text`. `SetParamValue(campo)` e `SetParamValue(nome, campo)` copiano il valore e la nullità di un campo di dataset; un campo `nil` non fa niente; il nome predefinito è quello del campo.

### Scenario: scalari
- **Dato** una proprietà `Id_Cliente: TNullableInt64`
- **Quando** si scrive 5, poi 5000000000
- **Allora** `HasValue` è vera e `Value` vale il numero scritto

### Scenario: uscita
- **Dato** un'uscita `Id_Esito: TNullableInteger` di sola lettura
- **Quando** si chiama `SetParamValue('ID_ESITO', 3, False)`
- **Allora** `Id_Esito.Value = 3`

### Scenario: da campo nullo
- **Dato** un campo `ID_CLIENTE` con valore 7, poi un record in cui è nullo
- **Quando** si chiama `SetParamValue('ID_CLIENTE', Campo)` su ciascuno
- **Allora** la proprietà vale 7, poi è nulla

## ZBASE-SPR-005 Azzeramento
`ClearParam(nome)` rende nulla la proprietà: un `Nullable` perde l'indicatore di presenza, un `TStringList` si svuota, un `TPicture` perde l'immagine. `ClearParams` azzera tutte le proprietà di ingresso **e di uscita**; `ClearOutputParams` (interna) solo quelle di uscita, ed è quella che `Next` usa quando il cursore è finito. Dopo l'azzeramento `Value` di un `Nullable` dà il valore predefinito del tipo (0, vuoto, `False`), come in ZFIB-NUL-003.

### Scenario: scalare
- **Dato** `Id_Cliente` con valore 5
- **Quando** si chiama `ClearParam('ID_CLIENTE')`
- **Allora** `IsNull` è vero e `Value = 0`

### Scenario: tutti i parametri
- **Dato** parametri di ingresso e un'uscita valorizzati
- **Quando** si chiama `ClearParams`
- **Allora** `ParamIsNull` è vero per tutti

## ZBASE-SPR-006 Nullità (`ParamIsNull`)
Un `Nullable` è nullo se non ha l'indicatore di presenza: una stringa vuota o uno zero **scritti** non sono nulli. Un `TStringList` è nullo se il testo è vuoto: **per un parametro MEMO non si può quindi passare una stringa vuota al posto di `NULL`** (arriva sempre come `NULL`). Un `TPicture` è nullo se non ha nessun `Graphic` o se questo è vuoto. Un record senza il campo `fHasValue` non risulta mai nullo.

### Scenario: zero e stringa vuota
- **Dato** `Id_Cliente` a cui si è scritto 0 e `Descrizione` a cui si è scritto `''`
- **Quando** si chiama `ParamIsNull` su ciascuno
- **Allora** il risultato è falso per entrambi

### Scenario: memo vuoto
- **Dato** un `TStringList` con testo vuoto
- **Quando** si chiama `ParamIsNull('NOTE')`
- **Allora** il risultato è vero

## ZBASE-SPR-007 Lettura di un valore (`GetParamValue`)
`GetParamValue(nome)` restituisce `Null` se il parametro è nullo (ZBASE-SPR-006); altrimenti il valore del `Nullable` come `Variant`, il `Text` del `TStringList`, i byte dell'immagine (ZBASE-SPR-008). I `TStringList` creati con `CreateStringList` non aggiungono un'interruzione di riga finale: un testo di due righe esce di due righe, senza una terza vuota.

### Scenario: nullo
- **Dato** `Id_Cliente` mai scritto
- **Quando** si chiama `GetParamValue('ID_CLIENTE')`
- **Allora** il risultato è `Null`

### Scenario: memo di due righe
- **Dato** `Note.Text` uguale a `a`, interruzione di riga, `b`
- **Quando** si chiama `GetParamValue('NOTE')`
- **Allora** il risultato è esattamente quel testo, senza interruzione finale

## ZBASE-SPR-008 Immagini (`TPicture`)
Un parametro BLOB senza sottotipo testo diventa una proprietà `TPicture`. In **ingresso** il contenuto passato al server è sempre quello di `Bitmap.SaveToStream`, cioè un file BMP, qualunque fosse il formato dell'immagine caricata, e `GetParamValue` lo restituisce come vettore di byte. In **uscita** `SetParamValue` carica i byte con `TPicture.LoadFromStream`, che riconosce il formato dai primi byte (BMP, PNG, JPEG, GIF) e poi copia il risultato nel `Bitmap` della proprietà: il resto del wrapper lavora sempre su un bitmap (DIV-SPR-7 corretta il 2026-11-01, rilascio 004). Un contenuto che non è un'immagine solleva ancora `EInvalidGraphic`. Le uscite di una procedura sono lette dopo la conferma della transazione (ZFIB-SPR-002), quindi un errore in questa fase arriva al chiamante a lavoro già confermato.

### Scenario: andata e ritorno di una bitmap
- **Dato** i byte di una bitmap 4 per 3 come vettore di byte
- **Quando** si chiama `SetParamValue('FIRMA', byte, False)` e poi `GetParamValue('FIRMA')`
- **Allora** la proprietà ha una bitmap 4 per 3, `ParamIsNull` è falso e si ottiene di nuovo un vettore di byte

### Scenario: formato non bitmap in uscita
- **Dato** i byte di un'immagine PNG
- **Quando** si chiama `SetParamValue('FIRMA', byte, False)`
- **Allora** viene sollevata un'eccezione

## ZBASE-SPR-009 Stato di un'istanza senza connessione né cursore
Appena creata, un'istanza non ha il `TFDStoredProc` interno (`StoredProc = nil`, creato alla prima esecuzione): `Active` è falso, `EOF` è vero, `Next` e `Close` non fanno niente e non sollevano, `DebugString` è la stringa vuota.

### Scenario: istanza nuova
- **Dato** un'istanza appena creata
- **Quando** si leggono `Active`, `EOF` e `DebugString` e si chiamano `Next` e `Close`
- **Allora** `Active` è falso, `EOF` è vero, `DebugString` è vuota e nessuna chiamata solleva

## ZBASE-SPR-010 Collegamento con l'applicazione
Il costruttore chiama, se assegnato, il gancio globale `InitStoredProc(Self)`. Nei `ConfigModule` di WT e di Gesty il gancio assegna **`zSystem` e `Database`, ma non la transazione**: la transazione la assegna il chiamante (`Create(Transazione)` o `GetSP<T>`, che usa sempre quella di scrittura `WriteTrans`, anche per i cursori letti con `Open`). Prima di `ExecuteAndCommit`, `ExecuteWithoutCommit` e `Open` servono `DataBase` e `Transaction`. Il `TFDStoredProc` interno prende connessione e transazione **al primo uso** e non le cambia più: assegnare un'altra transazione a un'istanza già usata non ha effetto (DIV-SPR-10). `ExecuteAndCommit` conferma l'intera transazione, comprese le scritture degli altri oggetti in sospeso sulla stessa transazione (di norma `WriteTrans` del DataModule). I `ConfigModule` impostano inoltre le regole di mappatura di FireDAC che portano i `NUMERIC` (`dtFmtBCD`, `dtBCD`) a `Double`: i `Nullable` numerici dei wrapper sono di tipo `Double` e nessun ramo di `SetParamValue` tratta un valore BCD in modo proprio.

### Scenario: gancio
- **Dato** `InitStoredProc` assegnato a una procedura di prova
- **Quando** si crea un'istanza
- **Allora** il gancio è chiamato una volta, con l'istanza appena creata

### Scenario: senza gancio
- **Dato** `InitStoredProc` uguale a `nil`
- **Quando** si crea un'istanza
- **Allora** `DataBase`, `Transaction` e `zSystem` sono nulli

## ZBASE-SPR-011 Il generatore
`TzStoredProcCodeFactory` scrive, per ogni procedura, `[TStoredProcedure('NOME', True)]` se la procedura contiene `SUSPEND` (`ptSelect`) e `[TStoredProcedure('NOME')]` altrimenti (Mantis #61), poi la direttiva RTTI, la classe con un campo per parametro, le gemelle `_internal` per le sole uscite non BLOB, un `TParamAttribute` per proprietà con la direzione e il flag BLOB, e, solo per le procedure con parametri BLOB, costruttore, distruttore e `Set<Nome>` per gli ingressi (`Assign` sull'immagine). Il tipo della proprietà segue il tipo del campo: `ftBlob` e `ftGraphic` danno `TPicture`, `ftMemo` dà `TStringList`, tutto il resto (testo, interi, date, numeri, booleani) un `TNullable...`. L'intestazione del file non porta data di generazione (2026-10-13). Il flag BLOB dell'attributo è informativo: `TzStoredProc` decide dal **tipo** della proprietà, non dal flag.

### Scenario: procedura selezionabile
- **Dato** una procedura con `SUSPEND`
- **Quando** il generatore scrive la classe
- **Allora** l'attributo è `TStoredProcedure('NOME', True)`

## Divergenze note

Si decidono nella voce R-213 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita. I codici partono da 7 perché DIV-SPR-1..6 sono già in `zFIB\_Specifiche\Procedure memorizzate.md` (tutte corrette o documentate).

| Codice | Divergenza | Conseguenza |
|---|---|---|
| ~~DIV-SPR-7~~ ✅ corretta il 2026-11-01 (rilascio 004), provata da `Immagine_PngInUscita_VieneLettaComeBitmap`; resta la parte sull'ingresso, sempre salvato come BMP | Testo originale: `SetParamValue` carica un'immagine in uscita con `Bitmap.LoadFromStream`, mentre i parametri BLOB generati sono `TPicture` per qualunque immagine; solo un BMP si legge | Una procedura che restituisce un PNG o un JPEG fa sollevare un'eccezione di immagine non valida dopo la conferma della transazione: le scritture della procedura sono già definitive e il chiamante riceve un errore. In ingresso ogni immagine viene salvata come BMP non compresso, più grande dell'originale |
| DIV-SPR-8 🟡 (dedotta) | Il generatore mappa ogni `ftBlob` (anche un file binario che non è un'immagine) a `TPicture`; non esiste una proprietà per i byte | Un parametro BLOB con un documento (PDF, archivio) non è rappresentabile col wrapper: l'ingresso sarebbe forzato a bitmap, l'uscita fallirebbe come DIV-SPR-7 |
| DIV-SPR-9 🟢 (dedotta) | `InternalExecute` e `Open` leggono `Transaction.Active` prima che `CreateInternalStoredProc` controlli con `Assert(Assigned(Transaction))` | Con la transazione assente si ha una violazione di accesso e non il messaggio dell'asserzione; il gancio `InitStoredProc` dei `ConfigModule` non assegna la transazione, quindi un `Create` senza argomenti è facile da usare male |
| DIV-SPR-10 🟢 (dedotta) | Connessione e transazione si assegnano al `TFDStoredProc` interno solo alla sua creazione; `DataBase` e `Transaction` sono proprietà scrivibili | Cambiare la transazione di un'istanza già usata viene ignorato senza avviso: la procedura continua sulla transazione vecchia |
| DIV-SPR-11 🟢 (dedotta) | `ClearParam` azzera il valore interno con un elenco di tipi che manca `tkUString` (il `string` di Delphi), le enumerazioni (`Boolean`) e i record, e usa -1 per gli interi mentre `TNullable.Clear` usa il valore predefinito | Il campo `fValue` di un parametro azzerato può conservare il valore vecchio o -1: non si vede da `Value` né dagli operatori, che guardano prima `HasValue` (ZFIB-NUL-003), ma lo vede chi legge i campi per riflessione o col debugger |
| DIV-SPR-12 🟢 (dedotta) | Esiste `zStoredProc -- pre selectable.pas` nella stessa cartella, con `unit zStoredProc;` identica | Il compilatore la ignora perché il nome del file non coincide, ma chi la aggiunge a un progetto per errore ottiene la versione senza la lettura a cursore (`Open`, `Close`, proprietà `Selectable`); ha 939 righe contro 1107 |
| DIV-SPR-13 🟢 (dedotta) | Per i tipi di campo non previsti (`ftBytes`, `ftVarBytes`, `ftFmtMemo`, `ftParadoxOle`, ...) il generatore scrive nomi di tipo che non esistono (`bytes`, `varBytes`, `fmtMemo`, ...) | Una procedura con un parametro di quel tipo produce un file generato che non compila, e l'errore compare lontano dalla causa |
| DIV-SPR-14 🟢 (dedotta) | `zSystem.pas` dichiara un secondo `TzStoredProc` (elemento di collezione) con lo stesso nome della classe di `zStoredProc.pas` | Una unit che nomina entrambe le unit nella clausola `uses` deve qualificare (`zStoredProc.TzStoredProc`, come fanno i `ConfigModule`); l'ordine delle unit decide altrimenti quale classe si ottiene |

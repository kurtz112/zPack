---
area: Valori nullable
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Valori nullable

Questa specifica descrive `TNullable<T>` (unit `zz.Nullable`, file `zPack\zLibs\zz.Nullable.pas`, **non** in zFIB), il tipo con cui i wrapper `TSP_*` delle stored procedure rappresentano i parametri scalari che possono essere `NULL` (`Procedure memorizzate.md`, ZFIB-SPR). Descrive il comportamento atteso, non il codice. Il tipo nasce da una versione ridotta di Spring4D, estesa con gli operatori di confronto. Esistono altre tre copie nella cartella `zPack`, **non autorevoli**: `zLibs\zz.Nullable - NEW.pas`, `zLibs\------------------------ zz.Nullable.pas` e `zFIB\zFDAC backup\zStoredProc.Nullable.pas`; la specifica vale per `zLibs\zz.Nullable.pas`.

**Test che coprono quest'area.** Nessuno.

## ZFIB-NUL-001 Valore o nulla
Un `TNullable<T>` è un record con un valore e un indicatore di presenza. Un record appena dichiarato non ha valore. Si crea con `Create(valore)` (ha valore) o per assegnazione implicita da un `T`. `HasValue` dice se c'è; `IsNull` e `IsEmpty` sono il contrario. `Clear` lo riporta a nullo e azzera il valore.

### Scenario: dichiarazione
- **Dato** una variabile `TNullableInt64` appena dichiarata
- **Quando** si chiede `HasValue`
- **Allora** la risposta è falsa e `IsNull` è vera

### Scenario: assegnazione
- **Dato** una variabile `TNullableInt64`
- **Quando** le si assegna 5
- **Allora** `HasValue` è vera e `Value = 5`

## ZFIB-NUL-002 Creazione da variant
`Create(Variant)` produce un nullable nullo se il variant è `Null` o vuoto (`Unassigned`/`Empty`), altrimenti converte il valore nel tipo `T`. Una stringa vuota **non** è nulla. Uno spazio non è nullo.

### Scenario: variant nullo
- **Dato** un `Variant` `Null`
- **Quando** si crea un `TNullableString` da esso
- **Allora** il risultato è nullo

### Scenario: stringa vuota
- **Dato** un `Variant` con stringa vuota
- **Quando** si crea un `TNullableString`
- **Allora** il risultato ha valore e il valore è la stringa vuota

## ZFIB-NUL-003 Lettura del valore
`Value` e `GetValueOrDefault` restituiscono il valore, oppure il valore predefinito del tipo (0, `False`, stringa vuota, ...) se il nullable è nullo; **non sollevano eccezioni** (vedi DIV-NUL-1) e non scrivono nel registro a ogni lettura (già DIV-NUL-3, rilascio 010). `GetValueOrDefault(Predefinito)` restituisce il predefinito indicato. Per distinguere «zero» da «nullo» bisogna usare `HasValue` o `IsNull`.

### Scenario: nullo con valore predefinito
- **Dato** un `TNullableInteger` nullo
- **Quando** si chiede `GetValueOrDefault(7)`
- **Allora** il risultato è 7

### Scenario: lettura di un nullo
- **Dato** un `TNullableInteger` nullo
- **Quando** si legge `Value`
- **Allora** si ottiene 0 e non viene sollevato nessun errore

## ZFIB-NUL-004 Conversioni
- Da `T` a nullable: implicita.
- Da nullable a `T`: implicita ed esplicita, con la regola di ZFIB-NUL-003 (il nullo dà il predefinito).
- Da nullable a `Variant`: `Null` se nullo, altrimenti il valore.
- Da `nil` a nullable: dà un nullable nullo; qualunque altro puntatore solleva `EInvalidOperation`.
- Da `Variant` a nullable: **non c'è conversione implicita**; si usa `Create(Variant)`.

### Scenario: verso un variant
- **Dato** un nullable nullo
- **Quando** lo si assegna a un `Variant`
- **Allora** il `Variant` è `Null` (un parametro `NULL` per il server)

### Scenario: nil
- **Dato** una variabile nullable con valore
- **Quando** le si assegna `nil`
- **Allora** diventa nulla

## ZFIB-NUL-005 Confronti: il nullo è uguale al predefinito
Gli operatori `=`, `<>`, `<`, `<=`, `>`, `>=` fra nullable e valore, valore e nullable, o due nullable, trattano un nullo **come il valore predefinito del tipo**: un `TNullableInt64` nullo è uguale a 0 e non è diverso da 0; un `TNullable<Boolean>` nullo è uguale a `False`; un `TNullableString` nullo è uguale alla stringa vuota. È una scelta di progetto: permette di scrivere `if id <> 0` senza `.Value`. Ha la conseguenza che **due nullable, uno nullo e uno con il valore predefinito, risultano uguali** (vedi DIV-NUL-2).

### Scenario: zero e nullo
- **Dato** un `TNullableInt64` nullo
- **Quando** lo si confronta con 0 con `=`
- **Allora** il risultato è vero

### Scenario: due nullable
- **Dato** un nullable nullo e uno con valore 0
- **Quando** li si confronta con `=`
- **Allora** il risultato è vero

### Scenario: ordine
- **Dato** un `TNullableInt64` nullo
- **Quando** lo si confronta con `< 1`
- **Allora** il risultato è vero (0 < 1)

## ZFIB-NUL-006 Il booleano nullable
Per il compilatore un `TNullable<Boolean>` non è un `Boolean`: `if flag then` non compila. Si scrive `if flag.Value then` oppure `if flag = True then`.

### Scenario: confronto booleano
- **Dato** un `TNullable<Boolean>` nullo
- **Quando** si valuta `flag = True`
- **Allora** il risultato è falso

## ZFIB-NUL-007 Layout dei campi: un contratto con `TzStoredProc`
`TzStoredProc` (`zBase\zStoredProc.pas`) legge e scrive i nullable per riflessione, cercando i campi privati `fValue` e `fHasValue`. L'indicatore di presenza è una **stringa** (`'@'` = presente, vuota = nulla), non un booleano. Rinominare quei due campi, cambiarne il tipo o il valore `'@'` rompe l'assegnazione dei parametri a runtime senza errori di compilazione. Le sigle già definite sono: `TNullableString`, `TNullableAnsiString`, `TNullableWideString`, `TNullableInteger`, `TNullableInt64`, `TNullableNativeInt`, `TNullableDateTime`, `TNullableDate`, `TNullableTime`, `TNullableCurrency`, `TNullableDouble`, `TNullableBoolean`, `TNullableGuid`.

### Scenario: parametro scritto dalla procedura
- **Dato** una proprietà `TNullableInteger` di una classe `TSP_*`
- **Quando** `TzStoredProc.SetParamValue` le assegna 5
- **Allora** `HasValue` è vera e `Value = 5`

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia. **DIV-NUL-1 e 2 non sono state corrette nel rilascio 008, per scelta:** `TNullable` compare più di 140.000 volte nei wrapper generati delle stored procedure (`Wt3_StoredProcs`, `Gesty_StoredProcs`, `zTicser_StoredProcs`), e far sollevare `Value` su un nullo o far distinguere il nullo da 0 negli operatori cambierebbe il comportamento di ogni chiamante che oggi legge un parametro nullo senza controllarlo. Una correzione sicura richiede prima di contare e riscrivere quei chiamanti, o di aggiungere un accessore che solleva (per esempio `ValueObbligatorio`) da usare dove serve.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-NUL-1 🟡 (decisione: non corretta, rilascio 008) | La documentazione di `Value` dice che solleva `EInvalidOperation` se il valore è nullo (come in Spring4D), ma `GetValue` chiama `GetValueOrDefault` e restituisce il predefinito | Chi legge il commento crede di avere una protezione contro la lettura di un nullo; un `Value` su un nullo dà silenziosamente 0, vuoto o `False`, e il programma prosegue con un dato inventato |
| DIV-NUL-2 🟡 (decisione: non corretta, rilascio 008) | Per le regole di ZFIB-NUL-005 `nullo = 0` e `Nullable(0) = nullo`; `<>` fra nullo e 0 è falso | Un parametro `NULL` e un parametro `0` non si distinguono con gli operatori; per le procedure che trattano diversamente i due casi va usato `HasValue` |
| DIV-NUL-4 🟢 | Quattro copie di `zz.Nullable` nella cartella `zPack`, tre non autorevoli, una nella cartella di backup | Chi apre la copia sbagliata può leggere un comportamento diverso (le altre copie non sono state confrontate con quella autorevole). Verificato il 2026-11-01: oltre a `zz.Nullable.pas` (451 righe) esiste in `zPack\zLibs` `zz.Nullable - NEW.pas` (645 righe, contenuto diverso); non è un file da toccare da qui, lo toglie o lo integra l'utente |

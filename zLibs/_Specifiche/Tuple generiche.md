---
area: Tuple generiche
progetto: zLibs
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zsystem/001
---

# Tuple generiche

Questa specifica descrive `zLibs\zz.Tuples.pas`: piccoli contenitori generici che tengono insieme da due a sette valori di tipo diverso (`TTuple<T1, T2>` ... `TTuple<T1, ..., T7>`, con le interfacce `ITuple<...>` corrispondenti). Il codice è di Malcolm Groves (Generics.Tuples, licenza MPL 2.0, copyright 2014, indicato nell'intestazione della unit). Non è nei pacchetti `.dpk` di zPack: si compila perché sta nel percorso di ricerca.

Chi le usa (verificato con una ricerca in `D:\AI\SRC\Wintarif_Group` e `Gesty_Group`): WT in `dmAccertamenti`, `dmDocumentazioneFirmaElettronica`, `dmGeCo`, `dmGeCoSync`, `dmGeDoEmail`, `dmGeDoRaccomandate`, `dmPagoPA`, `dmPagoPA_EFIL`, `dmPagoPA_InvioFlussi`, `dmRC_IngiunzioniInesigibili`, `dmRichieste`, `dmRiconciliazione`, `wizGeCoAperturaPratiche_DM` e le relative form; Gesty in `dmStudenti`, `frmStudenti`, `frmGeneraCalendarioStage`. L'uso tipico è una **lista di interfacce** (`TList<ITuple<Integer, Integer>>`) riempita in un ciclo sul dataset e poi letta da un altro ciclo, per passare più valori per riga a un metodo che non vuole un record dedicato. Un solo punto di uso vivo tiene la tupla come **classe** invece che come interfaccia: in Gesty `frmStudenti` (`CreaUtentiSistemaExecute`) costruisce una `TList<TTuple<Integer, string, string>>` e la passa a `dmStudenti.CreaUtentiSistema` (le copie `dmGeCo - Copia` e `frmGeCo - Copia` fanno lo stesso, ma sono file di storia).

**Come funziona.** `TTuple<T1, T2>` è la base; ogni arità successiva la estende con un campo e una proprietà in più (`Value3` ... `Value7`) e implementa la propria interfaccia oltre a quelle delle arità inferiori. Le tuple sono `TInterfacedObject`: quando si tengono in una variabile di tipo interfaccia vivono finché c'è un riferimento. **Alla distruzione la tupla libera i valori che sono oggetti** (ZLIBS-TUP-005).

**Test che coprono quest'area.** `Test.zz.Tuples` (in `zPack\_UnitTest\_src`): una prova per ogni requisito.

## ZLIBS-TUP-001 Creazione e lettura
Il costruttore `Create` riceve nell'ordine tutti i valori; `Value1` ... `ValueN` li restituiscono. Le tuple da 2 a 7 elementi hanno il costruttore con esattamente quel numero di parametri.

### Scenario: coppia
- **Dato** una variabile `ITuple<Integer, string>`
- **Quando** le si assegna `TTuple<Integer, string>.Create(7, 'Rossi')`
- **Allora** `Value1` è 7 e `Value2` è `Rossi`

### Scenario: sette elementi
- **Dato** una variabile `ITuple<Integer, string, Boolean, Double, Int64, Char, Currency>`
- **Quando** la si crea con sette valori distinti
- **Allora** ognuna delle sette proprietà restituisce il valore passato nella posizione corrispondente

## ZLIBS-TUP-002 Scrittura
Ogni proprietà `ValueN` si può riassegnare, sia dall'interfaccia sia dal riferimento di classe; la lettura successiva restituisce il valore nuovo e non tocca gli altri.

### Scenario: modifica dall'interfaccia
- **Dato** una tupla `ITuple<Integer, string>` con valori 1 e `a`
- **Quando** si assegna `Value2 := 'b'`
- **Allora** `Value2` è `b` e `Value1` è ancora 1

### Scenario: modifica dalla classe
- **Dato** una variabile `TTuple<Integer, string>` (classe, non interfaccia)
- **Quando** si assegna `Value1 := 5`
- **Allora** `Value1` è 5

## ZLIBS-TUP-003 Compatibilità verso l'alto
Una tupla di N elementi si può usare dove serve una tupla di meno elementi con gli stessi primi tipi: `ITuple<T1, T2, T3>` estende `ITuple<T1, T2>`, e così via fino a sette. Il valore letto è lo stesso.

### Scenario: tripla vista come coppia
- **Dato** una `TTuple<Integer, string, Boolean>` con valori 3, `x`, vero
- **Quando** la si assegna a una variabile `ITuple<Integer, string>`
- **Allora** `Value1` è 3 e `Value2` è `x`

## ZLIBS-TUP-004 Durata e liste
Con una variabile interfaccia la tupla è distrutta quando l'ultimo riferimento sparisce. Una `TList<ITuple<...>>` tiene un riferimento per elemento: svuotare o liberare la lista libera le tuple. Non serve liberarle a mano.

### Scenario: lista di tuple
- **Dato** una `TList<ITuple<Integer, string>>` con tre tuple
- **Quando** la lista viene liberata
- **Allora** le tre tuple sono distrutte

## ZLIBS-TUP-005 Proprietà dei valori oggetto
Il distruttore di ogni livello controlla il proprio valore con RTTI: se il tipo del valore è una **classe**, l'oggetto viene liberato con `Free`. I valori di altri tipi (numeri, stringhe, record, interfacce) non sono toccati. Un valore `nil` non provoca errori. Chi passa un oggetto a una tupla ne **cede la proprietà**: se lo stesso oggetto resta anche in una `TObjectList` o in un'altra tupla, viene liberato due volte (DIV-TUP-1).

### Scenario: oggetti nelle prime due posizioni
- **Dato** una tupla `ITuple<TOggetto, TOggetto>` con due oggetti
- **Quando** l'ultimo riferimento alla tupla viene azzerato
- **Allora** entrambi gli oggetti sono stati liberati

### Scenario: oggetto in una posizione alta
- **Dato** una tupla di sette elementi con un oggetto al settimo posto
- **Quando** la tupla viene distrutta
- **Allora** l'oggetto è stato liberato (ogni livello libera il proprio valore)

### Scenario: nessun oggetto
- **Dato** una tupla `ITuple<Integer, string>`
- **Quando** viene distrutta
- **Allora** nessun errore

### Scenario: valore nil
- **Dato** una tupla con un valore oggetto uguale a `nil`
- **Quando** viene distrutta
- **Allora** nessun errore

### Scenario: oggetto sostituito
- **Dato** una tupla `ITuple<Integer, TOggetto>` creata con un oggetto A
- **Quando** si assegna a `Value2` un oggetto B e poi si distrugge la tupla
- **Allora** la scrittura non libera A (resta a carico di chi lo possedeva) e la distruzione libera solo B

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-212 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-TUP-1 🟡 (dedotta) | Il distruttore libera ogni valore di tipo classe (`TValue.From<T>(...).IsObject` e `AsObject.Free`), ma la unit non lo dichiara nei commenti e il costruttore non lo rende evidente | Una tupla creata con un oggetto già posseduto altrove (una `TObjectList`, un campo di un form) lo libera due volte alla distruzione: violazione d'accesso. Oggi nessun chiamante di WT o Gesty usa classi come valori (solo numeri, stringhe, booleani, valuta), quindi il difetto è latente |
| DIV-TUP-2 🟢 | `TTuple<T1, T2>.Create` è `virtual` ma le arità superiori lo nascondono con `reintroduce` e firma diversa | Con un riferimento di classe `TTuple<T1, T2, T3>` si può chiamare solo il costruttore a tre argomenti: nessun problema, ma il `virtual` non serve a niente e inganna chi legge |
| DIV-TUP-3 🟡 | In `frmStudenti.CreaUtentiSistemaExecute` (Gesty) la lista è una `TList<TTuple<Integer, string, string>>` di classi e nel `finally` si fa solo `FreeAndNil(ElencoStudenti)`: le tuple create nel ciclo con `TTuple<...>.Create` non vengono mai liberate, perché sono `TInterfacedObject` senza nessun riferimento interfaccia che le distrugga | Una perdita di memoria per ogni studente selezionato a ogni esecuzione del comando «Crea utenti di sistema». Si corregge usando `TList<ITuple<...>>` come negli altri chiamanti, oppure una `TObjectList` |

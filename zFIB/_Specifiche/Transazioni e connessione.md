---
area: Transazioni e connessione
progetto: zFIB
aggiornato: 2026-10-31
rilascio: OUT/20261031-specifica-zpack-zfib/008
---

# Transazioni e connessione

Questa specifica descrive `TzFbDatabase`, `TzFbTransaction` e l'helper `Gen_ID` di `TFDConnection` (unit `zFbDataSet.pas`), e come i dataset e le procedure memorizzate li usano. Descrive il comportamento atteso, non il codice. Per `TzFbDataSet` vedi `Dataset Firebird.md` (ZFIB-DAT) e `Salvataggio e valori predefiniti.md` (ZFIB-SAL); per le procedure `Procedure memorizzate.md` (ZFIB-SPR).

**Regola dei DataModule.** In un `TBaseDbDataModule` le transazioni si chiudono con `Commit` e `Rollback` **del DataModule**, mai direttamente con quelli dell'oggetto transazione (AGENTS.md, sezioni 12-15). Il DataModule tiene il conto dei dataset che dipendono dalla transazione; chiudere la transazione di nascosto lo lascia incoerente. Questa specifica descrive l'oggetto transazione, non il DataModule.

**Test che coprono quest'area.** `Test.zFbDataSet.Divergenze` prova il controllo del nome in `RollBackToSavePoint` (ZFIB-TRA-004). La chiusura e `Gen_ID` non hanno prove automatiche.

## ZFIB-TRA-001 `TzFbDatabase` è una connessione FireDAC
`TzFbDatabase` discende da `TFDConnection` e non aggiunge comportamento: l'unica differenza è che `Connected` non viene salvata nel `.dfm`. Il motivo: una form salvata con la connessione attiva proverebbe ad aprirla in fase di progettazione e a ogni caricamento. Il commento nel sorgente la dichiara «eliminabile»; finché esiste, i wrapper delle procedure (`TzStoredProc.DataBase`) e i controlli la usano come tipo.

### Scenario: form salvata con la connessione attiva
- **Dato** una `TzFbDatabase` con `Connected = True` in un `.dfm` da salvare
- **Quando** si salva la form
- **Allora** il file non contiene `Connected`

## ZFIB-TRA-002 `TzFbTransaction` è una transazione FireDAC
`TzFbTransaction` discende da `TFDTransaction`. Come `Connected`, `Active` non viene salvata nel `.dfm`. Ogni istanza ha una pila privata di nomi per i punti di salvataggio (ZFIB-TRA-004), creata alla costruzione e liberata alla distruzione.

### Scenario: transazione nuova
- **Dato** una `TzFbTransaction` appena creata
- **Quando** si chiede `Active`
- **Allora** la risposta è falsa e la pila dei punti di salvataggio è vuota

## ZFIB-TRA-003 `CloseTransaction`
`CloseTransaction(doCommit)` non fa niente se la transazione non è attiva. Se è attiva, conferma con `Commit` (predefinito) o annulla con `Rollback` se `doCommit` è falso. Serve a chi non sa se la transazione è già stata chiusa e non vuole sollevare l'errore di FireDAC.

### Scenario: transazione già chiusa
- **Dato** una transazione non attiva
- **Quando** si chiama `CloseTransaction(False)`
- **Allora** non succede niente e non viene sollevato alcun errore

### Scenario: conferma
- **Dato** una transazione attiva con una modifica pendente
- **Quando** si chiama `CloseTransaction`
- **Allora** la modifica è confermata e la transazione non è più attiva

## ZFIB-TRA-004 Punti di salvataggio (`SetSavePoint`, `RollBackToSavePoint`)
Servono a poter annullare una parte di lavoro senza perdere quello fatto prima. **Non usano i punti di salvataggio di Firebird** (`SAVEPOINT`): sono un'imitazione basata su `CommitRetaining` e `RollbackRetaining`.
- `SetSavePoint(Nome)`: se la transazione è attiva, **conferma tutto il lavoro fatto finora** (`CommitRetaining`: la transazione resta aperta) e mette il nome sulla pila.
- `RollBackToSavePoint(Nome)`: **prima controlla il nome**. Con la pila vuota solleva «Punto di salvataggio "Nome" mai impostato», se il nome non coincide con l'ultimo impostato (senza distinguere maiuscole) solleva «Punto di salvataggio "Nome" diverso dall'ultimo impostato», in entrambi i casi **senza annullare niente**. Se il nome è giusto, toglie il nome dalla pila e, se la transazione è attiva, annulla il lavoro fatto **dopo l'ultimo `CommitRetaining`** (`RollbackRetaining`).

### Scenario: lavoro dopo il punto
- **Dato** una transazione attiva e un punto di salvataggio `P1` impostato dopo una modifica A
- **Quando** si fa una modifica B e si chiama `RollBackToSavePoint('P1')`
- **Allora** la modifica B è annullata e la A resta confermata

### Scenario: nome diverso
- **Dato** un punto di salvataggio `P1`
- **Quando** si chiama `RollBackToSavePoint('P2')`
- **Allora** viene sollevata un'eccezione che nomina i due punti, e nessun lavoro è annullato (il punto `P1` resta quello valido)

## ZFIB-TRA-005 Generatori (`Gen_ID`)
`Connessione.Gen_ID(Nome, Passo)` legge il generatore `Nome` con `SELECT GEN_ID(Nome, Passo) FROM RDB$DATABASE` e restituisce il valore in `Int64`. Il nome entra nel testo SQL, quindi deve essere un identificatore non quotato (lettera o `_`, poi lettere, cifre, `_` e `$`): un nome vuoto o con altri caratteri solleva `EArgumentException` prima di toccare il server (già DIV-TRA-3, rilascio 010). Con `Passo = 0` restituisce il valore attuale senza consumarne uno; con `Passo = 1` ne consuma uno. Il valore non torna indietro se la transazione che lo ha chiesto viene annullata: è una proprietà dei generatori di Firebird, non un difetto.

### Scenario: lettura senza consumo
- **Dato** un generatore a 100
- **Quando** si chiama `Gen_ID('GEN_X', 0)`
- **Allora** restituisce 100 e il generatore vale ancora 100

### Scenario: consumo di un valore
- **Dato** un generatore a 100
- **Quando** si chiama `Gen_ID('GEN_X', 1)`
- **Allora** restituisce 101

## ZFIB-TRA-006 Transazioni di un dataset
Un `TzFbDataSet` legge con `Transaction` e scrive con `UpdateTransaction`; possono essere la stessa o due diverse (`CreateFbDataSet`, ZFIB-DAT-002). `AutoCommit` conferma la transazione di scrittura dopo ogni salvataggio (ZFIB-SAL-008). `RecordCountFromServer` usa la transazione di lettura. Un dataset che dipende dal master non apre una transazione propria.

### Scenario: conteggio in lettura
- **Dato** un dataset con transazioni di lettura e scrittura distinte
- **Quando** si chiede `RecordCountFromServer`
- **Allora** la query di conteggio gira nella transazione di lettura

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti né giudicati difetti: si decidono nella voce R-196 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-TRA-1 🟡 (decisione: non corretta, rilascio 008) | I «punti di salvataggio» non sono annidabili: `RollBackToSavePoint` annulla sempre fino all'ultimo `CommitRetaining`, e `SetSavePoint` rende definitivo il lavoro precedente. Non si sono sostituiti con i `SAVEPOINT` veri di Firebird perché i chiamanti di WT contano sulla conferma: `WizGeneraAccertamento_DM` dice che serve a far vedere i dettagli alle transazioni di lettura, e il wizard dell'intestatario e la manutenzione della scheda chiamano `SetSavePoint` e `RollBackToSavePoint` con lo stesso nome | Chi apre due punti e torna al primo perde il lavoro fra i due punti ma non lo ritrova; impostare un punto in una transazione con lavoro pendente non annullabile lo conferma senza dirlo. Una correzione vera richiede di separare la conferma (per le transazioni di lettura) dal punto di salvataggio, e di riprovare i tre punti di WT

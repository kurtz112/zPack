---
area: Classificazione GDPR
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zpack/001
---

# Classificazione GDPR

Questa specifica descrive come zPack decide il livello di riservatezza di un campo prima che il suo valore entri nel contesto mandato all'assistente IA: in chiaro, mascherato, omesso, o tolto insieme al nome del campo. Il codice è in `zBase\zGdpr.Classifier.pas` (`TGdprClassifier`, interfaccia `IzGdprClassifier`); i livelli sono il tipo `TAISensitivity` di `zAI.Types`. Chi lo usa: `zAI.Context.Builder` e `zAI.Context.Orchestrator`, che ricevono il classificatore e ne applicano il risultato a ogni campo; in Gesty `Gesty.AI.Resolvers` (che costruisce il classificatore e il contesto del record con `AIRecordContextGesty` e `IsMinorGesty`), in zTicser `zTicser.AI.Resolvers`. WT non lo usa.

**Come funziona.** Il livello si decide in due fasi. Prima si cerca il livello **esplicito** del campo, dichiarato nel dizionario dati (colonna `SENSITIVITY` di `DATA_DICTIONARY`, con la precedenza del campo d'origine sul dominio già risolta al caricamento in `TzDomain.HasSensitivity` e `TzDomain.Sensitivity`). Poi si applicano il livello minimo della form, che vale solo per i campi non classificati, e la minore età del soggetto del record, che vale sempre.

**Test che coprono quest'area.** Nessuna. `zAI.Context.SmokeTest` non è una prova automatica: serializza il contesto di una form aperta per ispezionarlo a mano.

## ZBASE-GDP-001 Livelli di riservatezza
I livelli, dal più basso al più alto, sono `slNone` (in chiaro), `slMasked` (mascherabile in parte, per esempio `R***`), `slRedacted` (valore sostituito da `[omesso]`), `slSpecial` (categoria particolare dell'articolo 9 del GDPR: tolto sempre, anche il nome del campo). `MaxSensitivity(A, B)` restituisce il più alto dei due. Il classificatore decide solo il livello: che cosa diventi poi il valore (in chiaro, mascherato o `[omesso]`) lo stabilisce `zAI.Context.Builder` incrociando il livello con la politica del contesto, salvo `slSpecial`, che è tolto con qualunque politica.

### Scenario: confronto fra livelli
- **Dato** i livelli `slMasked` e `slRedacted`
- **Quando** si chiama `MaxSensitivity`
- **Allora** il risultato è `slRedacted`

## ZBASE-GDP-002 Non classificato e «non sensibile» sono opposti
Il livello esplicito è un valore facoltativo (`TAISensitivityOpt`): `None` significa **non classificato**, `Some(slNone)` significa **dichiarato non sensibile**. Un campo non classificato eredita il livello minimo della form; un campo dichiarato non sensibile resta in chiaro anche in una form sensibile.

### Scenario: campo non classificato in una form sensibile
- **Dato** un campo senza `SENSITIVITY` nel dizionario e una form con livello minimo `slRedacted`
- **Quando** si chiama `Classify` per un record di un adulto
- **Allora** il risultato è `slRedacted`

### Scenario: campo dichiarato non sensibile
- **Dato** un campo con `SENSITIVITY` = `slNone` e la stessa form
- **Quando** si chiama `Classify` per un record di un adulto
- **Allora** il risultato è `slNone`

## ZBASE-GDP-003 Il livello esplicito vince sulla form
Se il campo ha un livello esplicito, quello è il risultato anche quando è **più basso** del livello minimo della form; se è più alto, vince comunque lui. Il livello della form è solo il valore di prudenza per ciò che nessuno ha classificato.

### Scenario: campo speciale in una form qualunque
- **Dato** un campo dichiarato `slSpecial` e una form con livello minimo `slNone`
- **Quando** si chiama `Classify`
- **Allora** il risultato è `slSpecial`

## ZBASE-GDP-004 Minore età
Se il contesto del record ha `IsMinor` vero, il livello ottenuto dalle regole precedenti sale ad **almeno** `slRedacted`, anche per un campo dichiarato non sensibile (DIV-GDP-1); `slSpecial` resta `slSpecial`. È l'unica regola che sta sopra al livello esplicito, perché la tutela dei minori è un obbligo di legge.

### Scenario: dato non sensibile di un minore
- **Dato** un campo dichiarato `slNone` e un record con `IsMinor` vero
- **Quando** si chiama `Classify`
- **Allora** il risultato è `slRedacted`

### Scenario: dato mascherabile di un minore
- **Dato** un campo dichiarato `slMasked` e un record con `IsMinor` vero
- **Quando** si chiama `Classify`
- **Allora** il risultato è `slRedacted`

## ZBASE-GDP-005 Risolutore predefinito del livello esplicito
`TGdprClassifier.Create` senza argomenti usa `DefaultFieldLevelResolver`, che restituisce «non classificato» quando l'oggetto globale `Base` non esiste, quando `Base.GetDomain(Field)` non trova la voce del dizionario (per esempio campi calcolati) o quando la voce ha `HasSensitivity` falso (colonna `SENSITIVITY` nulla); altrimenti restituisce `Some(Sensitivity)`. Si può passare al costruttore un risolutore diverso (`TAIFieldLevelResolver`), per esempio nelle prove.

### Scenario: campo calcolato
- **Dato** un campo calcolato che non ha voce nel dizionario e una form con livello minimo `slMasked`
- **Quando** si chiama `Classify` con il risolutore predefinito
- **Allora** il risultato è `slMasked`

### Scenario: risolutore iniettato
- **Dato** un classificatore creato con un risolutore che restituisce sempre `Some(slNone)`
- **Quando** si chiama `Classify` per un record di un adulto in una form `slRedacted`
- **Allora** il risultato è `slNone`, senza accedere al dizionario

## ZBASE-GDP-006 Contesto del record
`TGdprRecordContext.Empty` descrive un record di un adulto e di persona fisica; `Create(IsMinor, IsLegalEntity)` imposta i due fatti. `IsLegalEntity` (azienda invece di persona fisica) è predisposto ma oggi `Classify` non lo usa (DIV-GDP-2).

### Scenario: record di un'azienda
- **Dato** un contesto con `IsLegalEntity` vero e `IsMinor` falso
- **Quando** si chiama `Classify` su un campo dichiarato `slMasked`
- **Allora** il risultato è `slMasked`, come per una persona fisica

## Divergenze note

Punti in cui il codice di oggi non fa ciò che chiaramente dovrebbe, o in cui un comportamento sembra dimenticato. Si decidono nella voce R-199 di `Attivita Rinviate.md`; quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-GDP-1 🟡 (dedotta) | Due commenti della unit si contraddicono: l'intestazione dice che la minore età innalza ad almeno `slRedacted` «anche un campo esplicitamente piu' basso», mentre il commento di `TGdprRecordContext` dice che innalza «i dati personali». Il codice innalza **ogni** campo, compresi quelli dichiarati `slNone` (identificativi, codici, date tecniche, descrizioni di corso) | Con la politica `ddMasked` (con `ddFull` tutto resta in chiaro) per un record di un minore l'assistente riceve solo `[omesso]` anche per i dati che non riguardano la persona, e non può rispondere su nulla di quel record; se l'intento era proteggere solo i dati personali, la regola va limitata ai campi non dichiarati `slNone` |
| DIV-GDP-2 🟢 | `IsLegalEntity` viene impostato da Gesty ma `Classify` lo ignora (il commento lo dichiara «predisposto») | Chi legge `Gesty.AI.Resolvers` può credere che un dato d'impresa sia trattato in modo meno restrittivo: non lo è |
| DIV-GDP-3 🟢 | L'intestazione elenca come «prerequisiti da fare» `HasSensitivity` e `Sensitivity` in `TzDomain` e nel caricamento del dizionario, che oggi esistono (`zSystem`, `zMetadata`, `zMetadata.Loader`); i commenti sono fra parentesi graffe, contro la regola di stile del progetto | Commento superato che fa pensare a un lavoro ancora aperto |

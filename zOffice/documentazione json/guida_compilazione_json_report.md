# Guida alla compilazione del file JSON dei report

**Per gli addetti all'assistenza** — come configurare il file JSON che accompagna ogni template di report (FastReport `.fr3`, Word `.docx`, Excel `.xlsx`) e, in particolare, le **azioni documentali** (Firma, Protocolla, Conserva, Invia PEC, Invia Mail).
File di esempio pronti all'uso nella cartella [`esempi\`](esempi/).

---

## 1. Cos'è e dove sta

Ogni template di report può avere accanto un file JSON ("sidecar") che ne descrive il comportamento. Il programma lo cerca **nella stessa cartella del template**, in quest'ordine:

1. `<nomefile>.<estensione>.json` — es. `IngiunzioneFiscale.fr3.json` ← **forma consigliata**
2. `<nomefile>.json` — es. `IngiunzioneFiscale.json`

Se esistono entrambi, vince il primo. Se non esiste nessuno dei due, il report funziona lo stesso ma **senza azioni documentali** e senza le altre configurazioni.

**Regole del file:**

- Codifica **UTF-8**.
- È un file JSON standard: **niente commenti**, virgole tra gli elementi ma **mai dopo l'ultimo**, stringhe sempre tra doppi apici `"`.
- Se il file contiene un errore di sintassi, **viene ignorato in blocco e senza messaggi**: il sintomo tipico è "ho aggiunto le azioni ma non compare niente". Prima di consegnare, validare sempre (vedi §7).

## 2. Struttura generale

```json
{
  "id": "ingiunzione-fiscale",
  "group": "Riscossione coattiva",
  "mainDataset": "qryIngiunzioni",
  "datasets": [ ],
  "variables": { },
  "azioni": { },
  "word": { },
  "excel": { },
  "fastreport": { }
}
```

| Nodo | Serve a | Obbligatorio |
|---|---|---|
| `id` | identità del report (minuscolo, parole separate da `-`); finisce nel registro delle generazioni: **una volta in uso non va più cambiato** | consigliato |
| `group` | raggruppamento nell'albero dei template | consigliato |
| `mainDataset` | nome del dataset principale che alimenta il report | dipende dal report |
| `datasets` | dataset aggiuntivi da attivare | solo se servono |
| `variables` | variabili statiche passate al template | solo se servono |
| `azioni` | **le azioni documentali** (§4) | solo se il documento le prevede |
| `word` / `excel` / `fastreport` | opzioni specifiche del motore (§5) | solo per quel tipo di template |

Tutti i nodi sono opzionali: si scrive solo ciò che serve.

## 3. Nodi base

### `datasets`

```json
"datasets": [
  { "name": "qryDettaglio", "close": true },
  { "name": "qryRiepilogo", "close": false }
]
```

`close: true` = il dataset viene chiuso e riaperto a ogni generazione.

### `variables`

```json
"variables": {
  "TITOLO": "Avviso di accertamento",
  "UFFICIO": "Ufficio Tributi"
}
```

Coppie nome → valore disponibili nel template. Solo valori fissi: i dati variabili arrivano dai dataset.

## 4. Il nodo `azioni` — le azioni documentali

Dichiara **che cosa si può fare** con il documento generato: è la carta d'identità della *tipologia* di documento. Un'azione non dichiarata (o con `enabled: false`) **non compare proprio** nella finestra di anteprima.

```json
"azioni": {
  "firma":         { "enabled": true, "engine": "SIGNHUB" },
  "protocollo":    { "enabled": true },
  "conservazione": { "enabled": true, "req": ["PRO"], "target": "PRO" },
  "inviaPec":      { "enabled": true, "req": ["FIR"], "target": "FIR" },
  "inviaMail":     { "enabled": false }
}
```

Le cinque azioni possibili: `firma`, `protocollo`, `conservazione`, `inviaPec`, `inviaMail`.

### I quattro campi di ogni azione

| Campo | Tipo | Significato |
|---|---|---|
| `enabled` | `true`/`false` | questo tipo di documento prevede l'azione? `false` o assente = bottone mai visibile |
| `req` | elenco di codici versione | **precondizioni**: quali passaggi devono già esistere sul documento prima che l'azione si sblocchi. Più codici = tutti richiesti |
| `target` | codice versione | su **quale versione** del documento agisce l'azione (es. la PEC spedisce il firmato, non l'originale). Assente = versione corrente |
| `engine` | nome fornitore | forza per questo template un fornitore diverso da quello configurato a livello di ente/azienda. Da usare solo su indicazione: normalmente **si omette** |

### I codici versione (per `req` e `target`)

Ogni documento è una **catena di versioni**: l'originale generato, poi via via le versioni prodotte dalle azioni.

| Codice | Versione |
|---|---|
| `ORI` | originale generato dal report |
| `FIR` | firmato |
| `PRO` | protocollato (con estremi stampati) |
| `STA` | versione per lo stampatore/postalizzatore |
| `PEC` | trasmissione PEC |
| `RIC` | ricevuta (audit firma, rapporto conservazione, ricevute PEC) |

Scriverli **in maiuscolo**. `req: ["FIR"]` si legge: *"questa azione si sblocca solo quando sul documento esiste una versione firmata"*.

### Attenzione: il JSON non basta da solo

Il bottone compare ed è utilizzabile solo se passano **tutti** questi controlli — il JSON governa solo il primo e il terzo:

1. **Template** (`enabled` nel JSON) → se fallisce: bottone **nascosto**
2. **Permesso utente** (configurato nei permessi dell'applicazione, chiavi `Report.Azione.*` — NON nel JSON) → se fallisce: bottone **nascosto**
3. **Precondizioni** (`req` nel JSON) → se fallisce: bottone **visibile ma disabilitato**, il motivo è nel tooltip
4. **Stato dell'azione** (già in corso / già fatta) → "in corso" con bottone *Aggiorna stato*, oppure *Vedi estremi*

Quindi: se il cliente dice *"il bottone Firma non c'è"*, le cause possibili sono il JSON (`enabled`), il **permesso dell'utente**, o il **fornitore non configurato** (senza fornitore di firma/PEC/conservazione l'azione non compare mai). Se dice *"il bottone c'è ma è grigio"*, la risposta è nel **tooltip** del bottone.

Nota: Firma e Protocolla si eseguono **una volta sola** per documento (poi diventano "Vedi estremi"); Conserva, Invia PEC e Invia Mail restano ripetibili.

## 5. Nodi specifici del motore

### `word` (template `.docx`)

```json
"word": {
  "readOnly": true,
  "fragments": [
    { "variable": "CLAUSOLE", "template": "clausole.docx", "dataset": "qryClausole" }
  ],
  "pdf": { "method": "tempfile", "fontEmbedding": "subset" }
}
```

- `readOnly`: il documento in anteprima non è modificabile.
- `fragments`: pezzi di documento generati da un sotto-template su un altro dataset, inseriti al posto della variabile indicata. Di norma li crea il programma (funzione dedicata nella form dei report): a mano solo per correzioni.
- ⚠️ `word.firma` e `word.inviaMail` (vecchi booleani) sono **deprecati**: nei nuovi JSON usare sempre il nodo `azioni`. Se un vecchio file li contiene ancora, funzionano ma vanno migrati alla prima occasione.

### `excel` (template `.xlsx`)

```json
"excel": {
  "readOnly": false,
  "allowBuildReport": true
}
```

`allowBuildReport` abilita la rigenerazione del report dai dati. Il nodo `databinding` viene scritto dal programma: **non modificarlo a mano**.

### `fastreport` (template `.fr3`)

```json
"fastreport": {
  "showDialog": false,
  "openAfterExport": true,
  "embeddedFonts": true,
  "overwritePrompt": true
}
```

### `pdf` (dentro `word` o `excel`)

| Campo | Valori | Significato |
|---|---|---|
| `method` | `dialog` / `filename` / `fieldname` / `tempfile` | come scegliere il nome del PDF esportato |
| `fileName` | testo | nome file fisso (con `method: "filename"`) |
| `fieldName` | testo | campo del dataset che dà il nome (con `method: "fieldname"`) |
| `fontEmbedding` | `none` / `full` / `subset` | incorporamento font (consigliato `subset` per documenti da firmare/conservare) |
| `openFileAfterExport` | `true`/`false` | apre il PDF dopo l'export |
| `showMessageAfterExport` | `true`/`false` | messaggio di conferma dopo l'export |

## 6. Ricette pronte

| Scenario | Cosa scrivere | Esempio completo |
|---|---|---|
| Atto da firmare, protocollare, conservare e spedire via PEC | firma + protocollo; conservazione `req:["PRO"]`; PEC `req:["FIR"]` e `target:"FIR"` | [`esempi/ingiunzione_fiscale.fr3.json`](esempi/ingiunzione_fiscale.fr3.json) |
| Contratto Word da firmare (busta con più firmatari) e conservare | firma (fornitore a busta) + conservazione `req:["FIR"]` | [`esempi/contratto_stage.docx.json`](esempi/contratto_stage.docx.json) |
| Atto in uscita solo protocollato, PEC dopo il protocollo | protocollo; conservazione e PEC con `req:["PRO"]` | [`esempi/atto_uscita_protocollato.fr3.json`](esempi/atto_uscita_protocollato.fr3.json) |
| Prospetto interno, solo invio mail ordinaria | solo `inviaMail: { "enabled": true }` | [`esempi/prospetto_riscossione.xlsx.json`](esempi/prospetto_riscossione.xlsx.json) |
| Documento senza alcuna azione | omettere del tutto il nodo `azioni` | — |
| Riferimento realistico FastReport | — | [`esempi/esempio_completo.fr3.json`](esempi/esempio_completo.fr3.json) |
| **Riferimento con TUTTE le voci possibili** (nodi `word`, `excel` e `fastreport` insieme) | solo consultazione: un template reale è di un solo tipo, quindi da questo file si **copia il nodo che serve**, non il file intero. Mancano solo `excel.databinding` (scritto dal programma) e i deprecati `word.firma`/`word.inviaMail` | [`esempi/riferimento_tutte_le_voci.json`](esempi/riferimento_tutte_le_voci.json) |

## 7. Errori comuni e diagnostica

| Sintomo | Causa probabile | Rimedio |
|---|---|---|
| Nessuna azione compare, JSON appena modificato | **errore di sintassi**: il file viene ignorato in silenzio | validare il JSON (editor con controllo sintassi o validatore online **senza incollare dati sensibili**); i colpevoli tipici sono la virgola dopo l'ultimo elemento e gli apici mancanti |
| Il bottone non compare per un solo utente | manca il **permesso** `Report.Azione.*` per il suo ruolo | configurare i permessi nell'applicazione, non nel JSON |
| Il bottone non compare per nessuno | `enabled` assente/false, oppure **fornitore non configurato** (firma/PEC/conservazione richiedono un fornitore attivo) | controllare JSON e configurazione fornitori |
| Bottone grigio | precondizione `req` non soddisfatta, o azione in corso | leggere il **tooltip**: dice sempre il motivo ("Invio PEC disponibile solo dopo la firma", "In attesa della firma, inviata il 12/07") |
| "Vedi estremi" al posto del bottone | l'azione è già stata completata (Firma e Protocolla non si ripetono) | è il comportamento corretto; il click mostra gli estremi |
| Azione ferma "in corso" | attesa di esito esterno (firmatari, ricevute PEC, conservatore) | bottone **Aggiorna stato** nell'anteprima; se persiste, verificare presso il fornitore |
| Modifiche al JSON senza effetto | file nella cartella sbagliata, o esiste anche `<nome>.<ext>.json` che vince su `<nome>.json` | il JSON deve stare **accanto al template**; controllare quale dei due file viene letto |
| Caratteri strani nelle variabili | file salvato in codifica diversa da UTF-8 | risalvare in UTF-8 |

## 8. Checklist prima della consegna

1. ☐ Il file è accanto al template e si chiama `<nomefile>.<estensione>.json`.
2. ☐ Il JSON è valido (nessuna virgola finale, apici doppi ovunque, UTF-8).
3. ☐ `id` presente, minuscolo con `-`, e mai cambiato se il report è già in uso.
4. ☐ Nodo `azioni`: solo le azioni davvero previste, `req`/`target` in **maiuscolo**.
5. ☐ `engine` omesso, salvo indicazione esplicita.
6. ☐ Niente `word.firma`/`word.inviaMail` nei file nuovi (deprecati).
7. ☐ Prova pratica: anteprima del report con un utente **con** i permessi e uno **senza**, verifica di bottoni visibili, bloccati (tooltip) e nascosti.

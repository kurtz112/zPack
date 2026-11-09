---
area: Vista record, layout personale
progetto: zBase
aggiornato: 2026-11-01
rilascio: OUT/20261101-specifiche-vive-zdbcard/003
---

# Vista record, layout personale

Questa specifica descrive il layout personale dell'utente per una vista record (`TzDbRecordView`): la larghezza delle etichette, quella dei record affiancati e le categorie chiuse, salvati in un file per vista. Il codice è in `zBase\zDbRecordView.Storage.pas` (`TzDbRecordViewStorage`, `TzRecordViewUserLayout`). Quello che decide l'amministratore (righe, ordine, categorie, visibilità) sta nel dizionario LZ (`TzDbRecordViewProps`) e non è qui; non sono in questa specifica nemmeno la costruzione delle righe della griglia (`zDbRecordView.Rows.pas`) e il componente (`zDbRecordView.pas`), che sono interfaccia DevExpress. La memorizzazione è la sola parte isolabile e testata. La stessa soluzione di `zDbView.Storage` per le viste a griglia evita il difetto D6 (due viste che si sovrascrivono). Descrive il comportamento atteso, non il codice.

**Come funziona.** Ogni vista ha un file `<identificativo>.recordview` nella cartella personale dell'utente (`TzSystem.PersonalFolder`), in formato INI con una sezione `Layout` e tre chiavi. La vista lo legge all'apertura e lo riscrive quando l'utente cambia una larghezza o chiude una categoria; `Reset` lo cancella e la vista torna al layout del dizionario.

**Test che coprono quest'area.** `Test.zDbRecordView.Storage`: nome del file, andata e ritorno su `TMemIniFile`, andata e ritorno su una cartella temporanea, file rovinato, `Reset`.

## ZDBRECORDVIEW-STO-001 Nome del file
`FileName` è la cartella più `<identificativo>.recordview`. L'identificativo, del tipo `Modulo.DataSet`, resta intero, con il punto: due viste dello stesso modulo dati hanno file diversi. I caratteri non ammessi nei nomi di file (`\ / : * ? " < > |`) diventano `_`. Senza cartella o senza identificativo il nome è vuoto e le operazioni sul file non fanno niente.

### Scenario: due viste dello stesso modulo
- **Dato** la cartella `C:\Utente` e gli identificativi `Anagrafica.Studenti` e `Anagrafica.Docenti`
- **Quando** si chiede il nome del file
- **Allora** i nomi sono `C:\Utente\Anagrafica.Studenti.recordview` e `C:\Utente\Anagrafica.Docenti.recordview`

### Scenario: caratteri non ammessi
- **Dato** l'identificativo `A/B:C*D?E`
- **Quando** si chiede il nome del file
- **Allora** il file si chiama `A_B_C_D_E.recordview`

## ZDBRECORDVIEW-STO-002 Contenuto del layout
Il layout ha `HeaderWidth` e `ValueWidth` (0 = non salvata) e l'elenco `CollapsedCategories` (i nomi degli elementi di categoria chiusi). `WriteLayout` cancella la sezione `Layout` e la riscrive con `HeaderWidth`, `ValueWidth` e `CollapsedCategories` (nomi separati da punto e virgola): le chiavi di una scrittura precedente non restano. `ReadLayout` restituisce un layout vuoto se il file o la sezione mancano; legge le voci dell'elenco saltando quelle vuote (`A;;B;` dà `A` e `B`). `IsCollapsed` confronta senza distinguere maiuscole e minuscole. Con un oggetto INI nullo le due operazioni non fanno niente.

### Scenario: andata e ritorno
- **Dato** un layout con larghezze 180 e 320 e categorie chiuse `Recapiti` e `Note`
- **Quando** lo si scrive e lo si rilegge
- **Allora** i valori tornano identici e `IsCollapsed('recapiti')` è vero

## ZDBRECORDVIEW-STO-003 File: lettura, scrittura e ripristino
`Save` crea la cartella se manca, scrive il file in UTF-8 e lo aggiorna; restituisce vero se ha scritto, falso se la scrittura non è riuscita (cartella in sola lettura, file bloccato) senza sollevare eccezioni: il layout personale non si salva, ma la vista continua a funzionare. `Load` restituisce un layout vuoto se il file non esiste; se il file ha byte non validi in UTF-8 (`EEncodingError`) o non si riesce ad aprirlo (file bloccato, senza permessi) restituisce un layout vuoto senza sollevare, perché un file rovinato o inaccessibile non deve impedire di aprire la vista. `Reset` cancella il file se esiste; dopo `Reset` `Load` restituisce un layout vuoto.

### Scenario: file rovinato
- **Dato** un file `.recordview` con byte non UTF-8
- **Quando** la vista lo carica
- **Allora** non solleva niente e la vista usa il layout del dizionario

### Scenario: cartella non scrivibile
- **Dato** una cartella personale in cui non si può scrivere
- **Quando** l'utente cambia una larghezza e la vista salva
- **Allora** `Save` restituisce falso senza sollevare e la vista resta utilizzabile

## Divergenze note

Punti in cui il codice di oggi non mantiene ciò che i requisiti dicono, o in cui un comportamento sembra dimenticato. Non sono stati corretti: si decidono nella voce R-211 di `Attivita Rinviate.md`. Quelle marcate «dedotta» vengono dalla lettura del codice, senza prova eseguita.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-STO-1 ✅ (corretta) | `Save` non proteggeva la scrittura e `Load` ingoiava solo `EEncodingError`: una cartella personale non scrivibile, un file bloccato o un errore di lettura sollevavano un'eccezione dentro la vista. Corretta nel rilascio 008 (`Save` restituisce vero o falso, `Load` ingoia anche gli errori di accesso al file) | Nessuna |
| DIV-STO-2 🟢 (dedotta) | L'elenco delle categorie chiuse è separato da punto e virgola: un nome di categoria che contiene `;` si divide in due voci alla lettura | La categoria non risulta chiusa e compaiono voci spurie, solo con nomi di categoria insoliti |
| DIV-STO-3 🟢 (dedotta) | Identificativi che differiscono solo per caratteri non ammessi (`A/B` e `A:B`) danno lo stesso file | Due viste con identificativi quasi uguali condividono il layout: i nomi `Modulo.DataSet` reali non li usano |

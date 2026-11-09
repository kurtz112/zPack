---
area: Ricerca dai metadati
progetto: zNg
aggiornato: 2026-10-30
rilascio: OUT/20261030-specifiche-vive-dei-progetti/005
---

# Ricerca dai metadati

Questa specifica descrive come il motore zz-* di zNg (Agorà, GestyWeb) trasforma un campo collegato a un'altra tabella in una casella di ricerca, e un campo a valori chiusi in un elenco di scelta, partendo dai metadati che zServer manda per il dataset. Descrive il comportamento atteso, non il codice. Il codice oggi sta in `core/services/lookup.helper.service.ts` (casella di ricerca nei moduli), `core/services/form-items-builder.service.ts` (aggancio al modulo), `core/components/zz-data-grid/zz-data-grid.component.ts` (decodifica in griglia, `_buildGridLookup`), `core/components/zz-form/zz-form.component.ts` (campi da svuotare), `core/services/zserver.service.ts` (`createDataStore`), `core/services/metadata.service.ts` (cache dei metadati), `core/models/metadata.models.ts` (`LookupConfig`, `PicklistConfig`) e `core/components/zz-lookup/` (componente a più colonne).

Il lato server è in zServer, `_src/_Specifiche/Contratto - Dataset dinamici.md` (requisiti `ZSRV-DSD-*`): i metadati arrivano da `GET data/{dataset}/metadata`, le righe da `GET data/{dataset}`. Gli indirizzi qui sotto sono relativi all'indirizzo di zServer (`UrlService.baseUrl`). L'apertura della scheda della tabella collegata non esiste: `fkTable` arriva nei metadati ma il client non lo usa.

## ZNG-RIC-001 Ricerca configurata dai metadati
Un campo che nei metadati ha `lookup` diventa nel modulo una casella di ricerca (`dxSelectBox`, salvo un `control.editorType` diverso) collegata al dataset `lookup.dataset`. Il valore salvato è il campo chiave (`valueExpr`), il testo mostrato è il primo campo di `displayExpr`. Così una schermata nuova non richiede codice: basta dichiarare il collegamento in `BASE_WEB_LOOKUPS`.

### Scenario: campo collegato
- **Dato** un campo con `lookup.dataset = COMUNI`, `valueExpr = BELFIORE`, `displayExpr = DESCRIZIONE`
- **Quando** il modulo si costruisce dai metadati
- **Allora** il campo è una casella di ricerca che legge le righe da `GET data/COMUNI` (ZSRV-DSD-003)
- **E** salva `BELFIORE` e mostra `DESCRIZIONE`

### Scenario: opzioni dell'editor nei metadati
- **Dato** un campo collegato con `control.editorOptions` e `control.readOnly`
- **Quando** il modulo si costruisce
- **Allora** le opzioni dei metadati prevalgono su quelle predefinite della casella, e il campo in sola lettura non si può cambiare

## ZNG-RIC-002 Ricerca mentre si digita
La ricerca la fa zServer, non il browser: le tabelle collegate possono avere migliaia di righe. La richiesta parte mezzo secondo dopo l'ultimo tasto, cerca il testo in qualunque punto del campo e ordina per lo stesso campo. Il campo di ricerca è la prima colonna di `lookup.columns`, se c'è, altrimenti il primo campo di `displayExpr`.

### Scenario: testo digitato
- **Dato** una casella di ricerca su `DESCRIZIONE`
- **Quando** l'utente scrive `bres` e si ferma
- **Allora** dopo 500 ms parte `GET data/{dataset}` con `searchExpr=["DESCRIZIONE"]`, `searchOperation=contains`, `searchValue=bres` e l'ordinamento crescente su `DESCRIZIONE` (ZSRV-DSD-004)
- **E** la tendina mostra le righe che contengono il testo, senza distinguere maiuscole e minuscole

### Scenario: tendina aperta senza testo
- **Dato** una casella di ricerca vuota
- **Quando** l'utente apre la tendina
- **Allora** compaiono le prime righe del dataset, senza bisogno di digitare (`minSearchLength` 0)

### Scenario: scorrimento della tendina
- **Dato** una tendina aperta
- **Quando** l'utente scorre fino in fondo
- **Allora** non si caricano altre pagine, perché il caricamento a pagine della lista ripeteva all'infinito le stesse righe

La larghezza della tendina è `lookup.dropDownWidth`, 500 pixel se manca.

## ZNG-RIC-003 Chiave composta
Quando `valueExpr` elenca più campi (`TIPO_RICHIESTA; TIPOLOGIA_RICHIESTA`), la casella vale il solo campo che modifica, e la riga corrispondente si cerca con tutte le parti della chiave, prendendo le altre dal modulo. Mandare il nome intero come un campo solo faceva rispondere 500 a zServer.

### Scenario: lettura della riga scelta
- **Dato** un collegamento con chiave `TIPO_RICHIESTA; TIPOLOGIA_RICHIESTA` sul campo `TIPOLOGIA_RICHIESTA`, e il modulo con `TIPO_RICHIESTA = A`
- **Quando** la casella deve mostrare la descrizione del valore `X`
- **Allora** parte `GET data/{dataset}` con il filtro `TIPOLOGIA_RICHIESTA = X and TIPO_RICHIESTA = A` e `take=1`
- **E** se un `mappings` collega la parte della chiave a un campo del modulo con un altro nome, il valore si legge da quel campo

### Scenario: parte della chiave vuota nel modulo
- **Dato** lo stesso collegamento e `TIPO_RICHIESTA` vuoto nel modulo
- **Quando** la casella cerca la riga
- **Allora** il filtro usa solo `TIPOLOGIA_RICHIESTA = X`

## ZNG-RIC-004 Campi che si riempiono con la scelta
`lookup.mappings` (`CAMPO_MODULO=CAMPO_COLLEGAMENTO;...`) copia nel modulo altre colonne della riga scelta. Si saltano il campo della casella stessa e i valori già uguali, così due caselle collegate fra loro non si rimandano il cambio all'infinito.

### Scenario: scelta di una riga
- **Dato** un collegamento con `mappings = CAP=CAP;PROVINCIA=SIGLA_PROVINCIA`
- **Quando** l'utente sceglie un comune
- **Allora** nel modulo `CAP` e `PROVINCIA` prendono i valori di `CAP` e `SIGLA_PROVINCIA` della riga scelta

### Scenario: casella svuotata
- **Dato** un campo collegato con dei `mappings` già applicati
- **Quando** l'utente svuota la casella
- **Allora** i campi dei `mappings` si svuotano

### Scenario: valore già uguale
- **Dato** un campo del modulo che ha già il valore della riga scelta
- **Quando** si applicano i `mappings`
- **Allora** quel campo non viene riscritto e non scatta un nuovo cambio

## ZNG-RIC-005 Valore che il collegamento non trova più
Un valore salvato che non esiste più nella tabella collegata non cancella niente: i dati della scheda restano come sono finché l'utente non cambia o svuota la casella. Una riga cancellata nella tabella collegata non deve far perdere i dati delle schede che la usavano.

### Scenario: riga collegata cancellata
- **Dato** una scheda con un campo collegato il cui valore non è più nel dataset collegato
- **Quando** la scheda si apre
- **Allora** il valore del campo resta quello salvato
- **E** i campi dei `mappings` non vengono toccati

## ZNG-RIC-006 Ricerca in cascata
`lookup.params` (`PARAMETRO=CAMPO;...`) restringe la ricerca con il valore di altri campi del modulo, per esempio le vie del solo comune scelto. Quando uno di quei campi cambia, il valore della casella si svuota e le righe si rileggono.

### Scenario: cambio del campo da cui dipende
- **Dato** una casella delle vie con `params = BELFIORE=BELFIORE`
- **Quando** l'utente cambia il comune nel modulo
- **Allora** la casella delle vie si svuota
- **E** la ricerca successiva manda `BELFIORE` con il nuovo valore

Oggi lo fa solo `zz-lookup` (ZNG-RIC-011); vedi DIV-RIC-2.

## ZNG-RIC-007 Campi da svuotare al cambio di un campo
`column.fields2Clear` elenca i campi che si svuotano quando il campo cambia: un valore scelto in una casella collegata rende senza senso quelli che ne dipendevano. Lo svuotamento lo fa la scheda (ZNG-SCH-007), che oggi non lo mantiene: la divergenza è DIV-SCH-1.

### Scenario: cambio di un campo con campi dipendenti
- **Dato** un campo `COMUNE` con `fields2Clear = VIA;CIVICO`
- **Quando** l'utente cambia `COMUNE`
- **Allora** `VIA` e `CIVICO` si svuotano nel modulo

Oggi non succede: vedi DIV-RIC-3.

## ZNG-RIC-008 Valori a scelta chiusa
Un campo che nei metadati ha `picklist` mostra un elenco di scelta con le voci di `picklist.items` (`value` salvato, `text` mostrato), nell'ordine in cui le manda zServer. Le voci arrivano con i metadati, quindi l'elenco non fa richieste.

### Scenario: elenco nel modulo
- **Dato** un campo con `picklist.items = [{ value: 'GEN', text: 'Formazione Generale' }, ...]`
- **Quando** il modulo si costruisce
- **Allora** la casella offre le voci, mostra `Formazione Generale` e salva `GEN`

### Scenario: decodifica in griglia
- **Dato** lo stesso campo come colonna della griglia
- **Quando** la griglia mostra una riga con `GEN`
- **Allora** la cella mostra `Formazione Generale`, e in modifica offre lo stesso elenco

## ZNG-RIC-009 Decodifica dei campi collegati in griglia
In griglia un campo collegato mostra la descrizione al posto del codice solo se la pagina lo chiede (`enableGridLookups`) e solo se il collegamento ha una chiave semplice sul campo stesso. Con una chiave composta la ricerca userebbe solo la prima parte e mostrerebbe descrizioni sbagliate: meglio il codice. Il testo è l'unione dei campi di `displayExpr` separati da ` - `.

### Scenario: collegamento semplice senza pagine
- **Dato** `enableGridLookups` attivo, un campo `BELFIORE` con `valueExpr = BELFIORE`, `displayExpr = DESCRIZIONE; PROVINCIA` e nessun `pageSize`
- **Quando** la griglia si apre
- **Allora** le righe del dataset collegato si leggono una volta sola con `GET data/{dataset}?take=0` e restano in memoria per tutte le celle
- **E** la cella mostra `Brescia - BS`

### Scenario: collegamento con pagine
- **Dato** lo stesso campo con `lookup.pageSize = 50`
- **Quando** l'utente apre la tendina della cella in modifica
- **Allora** le righe si leggono a pagine di 50, con `requireTotalCount`
- **E** la descrizione di un singolo valore si legge con il filtro sulla chiave e `take=1`

### Scenario: chiave composta o decodifica non chiesta
- **Dato** un collegamento con chiave composta, oppure `enableGridLookups` spento
- **Quando** la griglia mostra la colonna
- **Allora** la cella mostra il codice salvato

## ZNG-RIC-010 Configurazione letta una volta
I metadati di un dataset, collegamenti ed elenchi compresi, si leggono una volta e restano in cache per tutte le pagine che li usano, finché non vengono invalidati (`MetadataService.invalidateCache`, uscita, sessione scaduta: ZNG-ACC-007, ZNG-ACC-008). Una lettura non riuscita non resta in cache, così la successiva riprova. Le righe dei collegamenti nei moduli invece non hanno cache: ogni ricerca va a zServer, perché i dati collegati cambiano mentre si lavora.

### Scenario: due pagine sullo stesso dataset
- **Dato** i metadati di un dataset già letti
- **Quando** un'altra pagina li chiede
- **Allora** non parte un secondo `GET data/{dataset}/metadata`

### Scenario: lettura fallita
- **Dato** una lettura dei metadati fallita
- **Quando** la pagina li chiede di nuovo
- **Allora** parte una nuova richiesta

## ZNG-RIC-011 Ricerca a più colonne con `zz-lookup`
`<zz-lookup>` è una casella da usare in un modulo Angular (`formControlName`, `ngModel`) che apre una griglia nella tendina: colonne dal campo chiave più i campi di `displayExpr` (o da `columns`), filtro per colonna, una riga sola selezionabile, pagine di `pageSize` righe (50 se manca). Alla scelta il testo è l'unione dei campi mostrati separati da ` - `, ed emette `valueChange` e, se ci sono, i valori dei `mappings` in `onMappings`. Gestisce la cascata di ZNG-RIC-006 dai dati passati in `formData`.

### Scenario: scelta nella griglia della tendina
- **Dato** un `<zz-lookup>` con `config` di un collegamento
- **Quando** l'utente sceglie una riga
- **Allora** il controllo del modulo prende il valore della chiave e la tendina si chiude
- **E** `onMappings` emette i campi dei `mappings` presi dalla riga

### Scenario: valore impostato dal modulo
- **Dato** un `<zz-lookup>` a cui il modulo assegna un valore
- **Quando** il valore arriva
- **Allora** la casella legge la riga corrispondente e ne mostra il testo

Oggi il componente non funziona e nessuna applicazione lo usa: vedi DIV-RIC-1.

## ZNG-RIC-012 Errori della ricerca
Un errore di zServer durante una ricerca o una decodifica arriva all'utente con la notifica dell'applicazione (intercettore degli errori), come per ogni altra richiesta. La pagina resta usabile.

### Scenario: ricerca rifiutata
- **Dato** una casella di ricerca su un dataset che l'utente non è autorizzato a leggere
- **Quando** l'utente apre la tendina
- **Allora** zServer risponde 403 (ZSRV-DSD-008) e compare la notifica dell'errore
- **E** il modulo resta aperto e gli altri campi si possono modificare

### Scenario: decodifica in griglia fallita
- **Dato** una griglia con decodifica dei campi collegati
- **Quando** la lettura della descrizione di un valore fallisce
- **Allora** la cella resta senza descrizione e la griglia continua a funzionare

## Divergenze note

Punti in cui il codice di oggi non mantiene quello che promette o non rispetta il contratto dell'altro lato. Si correggono nella voce R-177 di `Attivita Rinviate.md`; con la correzione il requisito si aggiorna e questa sezione si accorcia.

| Codice | Divergenza | Conseguenza |
|---|---|---|
| DIV-RIC-1 | `zz-lookup` chiama `GET data/lk/{dataset}` e `GET data/lk/{dataset}/{chiave}`, rotte che zServer non ha più: `GetLookupData` è stato tolto e su `data/{dataset}/{chiave}` esistono solo `PUT` e `DELETE`. Divide inoltre `valueExpr` e `displayExpr` sulla virgola, mentre i metadati usano il punto e virgola Lato server è DIV-DSD-1. | Il componente non carica nessuna riga; oggi non lo usa nessuna applicazione, ma resta nella libreria come se funzionasse |
| DIV-RIC-2 | `lookup.params` arriva nei metadati, ma la casella dei moduli (`LookupHelperService.getEditorOptions`) e la decodifica in griglia lo ignorano: lo legge solo `zz-lookup` | Le ricerche in cascata dei moduli mostrano tutte le righe del dataset collegato, non solo quelle del valore scelto nel campo da cui dipendono |
| DIV-RIC-3 | `LookupConfig` prevede `columns` e `filter`, che zServer non manda: la casella dei moduli scrive un avviso in console per ogni campo collegato e non mostra mai l'intestazione a più colonne | La tendina dei moduli ha sempre una colonna sola; il filtro fisso dichiarato nel modello non si può configurare |
| DIV-RIC-4 | Nella decodifica in griglia con pagine, la ricerca della tendina sostituisce il filtro della richiesta con `[searchExpr, 'contains', valore]` invece di mandare `searchExpr`/`searchValue`; con più campi in `displayExpr` `searchExpr` è un elenco e il filtro risulta malformato | Con più campi mostrati la ricerca nella tendina della cella fallisce; con uno solo funziona, ma perde l'eventuale filtro già presente |
